import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_clash/controller.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/providers/database.dart';
import 'package:fl_clash/xboard/features/auth/providers/xboard_user_provider.dart';
import 'package:fl_clash/xboard/domain/models/subscription.dart';
import 'package:fl_clash/xboard/features/profile/providers/profile_import_provider.dart';
import 'package:fl_clash/views/proxies/common.dart' as proxies_common;
import 'package:flutter_xboard_sdk/flutter_xboard_sdk.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import '../../theme/mihom_theme.dart';
import '../../providers/theme_provider.dart';
import '../../i18n.dart';
import '../../widgets/pill_toast.dart';
import '../../widgets/flag_badge.dart';

/// 桌面端首页 — 连接面板 + 内联节点选择
class DesktopHomePage extends ConsumerStatefulWidget {
  final MihomTheme theme;
  final bool isGuest;
  final bool connected;
  final DateTime? connectedAt;
  final int latency;
  final bool isTesting;
  final VoidCallback onToggleConnection;
  final VoidCallback onTestLatency;
  final VoidCallback? onLogin;

  const DesktopHomePage({
    super.key,
    required this.theme,
    required this.isGuest,
    required this.connected,
    this.connectedAt,
    required this.latency,
    required this.isTesting,
    required this.onToggleConnection,
    required this.onTestLatency,
    this.onLogin,
  });

  @override
  ConsumerState<DesktopHomePage> createState() => _DesktopHomePageState();
}

class _DesktopHomePageState extends ConsumerState<DesktopHomePage> with TickerProviderStateMixin {
  MihomTheme get t => widget.theme;
  Timer? _timer;
  String _elapsed = '00:00:00';
  late AnimationController _pulseCtrl;
  late AnimationController _marqueeCtrl;
  late AnimationController _tapScaleCtrl;

  // 当前选中节点 (flat index)
  int _selectedFlatIndex = 0;
  bool _pickerOpen = false;
  bool _isSyncing = false;
  bool _isTestingAll = false;
  bool _autoTestTriggered = false;
  bool _autoTestInProgress = false; // 标记当前延迟测试是否由自动跳转触发
  int _pendingAutoTestIndex = -1; // 待自动测速的节点索引
  Timer? _autoTestRetryTimer; // 重试定时器：等待URLTest核心解析完成

  // 多条公告轮播
  int _announceIndex = 0;
  Timer? _announceTimer;
  bool _announceHovered = false;  // 鼠标悬停暂停滚动

  // 公告数据: 从 API 获取的公告列表
  List<_NoticeItem> _notices = [];
  bool _noticesLoaded = false;
  bool _noticesVisible = false; // 跟随后端 show 开关

  // 校园网模式标记
  bool _isCampusMode = false;
  bool? _tunBeforeCampus; // 进入校园网前的 TUN 状态，退出时恢复

  // 代理模式: from real provider (0=Rule, 1=Global, 2=Campus)
  int get _proxyMode {
    if (_isCampusMode) return 2;
    final mode = ref.watch(patchClashConfigProvider.select((s) => s.mode));
    switch (mode) {
      case Mode.rule: return 0;
      case Mode.global: return 1;
      case Mode.direct: return 0; // treat direct as rule
    }
  }

  void _setProxyMode(int modeIndex) {
    final bool wasCampus = _isCampusMode;
    switch (modeIndex) {
      case 2:
        // ── 校园网模式 ──
        _tunBeforeCampus ??= ref.read(patchClashConfigProvider).tun.enable;
        _isCampusMode = true;
        // 1. 规则模式
        appController.changeMode(Mode.rule);
        // 2. 关闭 TUN（避免校园门户认证被拦截）
        ref.read(patchClashConfigProvider.notifier).update(
          (state) => state.copyWith.tun(enable: false),
        );
        // 3. 确保系统代理开启
        ref.read(networkSettingProvider.notifier).update(
          (state) => state.copyWith(systemProxy: true),
        );
        // 4. 追加校园直连域名到系统代理旁路列表
        _applyCampusBypass(true);
        showPillToast(context, t, S.campusEnabled);
      case 1:
        _isCampusMode = false;
        if (wasCampus) _restoreFromCampus();
        appController.changeMode(Mode.global);
      default:
        _isCampusMode = false;
        if (wasCampus) _restoreFromCampus();
        appController.changeMode(Mode.rule);
    }
    SharedPreferences.getInstance().then((p) => p.setBool('campus_mode_enabled', _isCampusMode));
  }

  /// 退出校园网模式时恢复 TUN 状态 + 移除校园域名
  void _restoreFromCampus() {
    _applyCampusBypass(false);
    final restoreTun = _tunBeforeCampus ?? true;
    _tunBeforeCampus = null;
    ref.read(patchClashConfigProvider.notifier).update(
      (state) => state.copyWith.tun(enable: restoreTun),
    );
  }

  /// 追加 / 移除校园网专用直连域名（系统代理 bypass 列表）
  void _applyCampusBypass(bool enable) {
    ref.read(networkSettingProvider.notifier).update((state) {
      final current = List<String>.from(state.bypassDomain);
      if (enable) {
        for (final d in campusBypassDomains) {
          if (!current.contains(d)) current.add(d);
        }
      } else {
        current.removeWhere((d) => campusBypassDomains.contains(d));
      }
      return state.copyWith(bypassDomain: current);
    });
  }

  // 首次引导气泡
  bool _guideShown = false;
  OverlayEntry? _guideOverlay;
  final GlobalKey _proxyModeKey = GlobalKey();

  // ── 核心健康检查 ──
  Timer? _coreHealthTimer;
  bool _coreRestarting = false;

  // 单节点测速中的索引 (-1=none)
  int _testingNodeIndex = -1;
  final Map<int, String> _testResults = {};

  final GlobalKey _pillKey = GlobalKey();
  final GlobalKey _pillLatencyKey = GlobalKey();
  OverlayEntry? _pickerOverlay;
  final LayerLink _pickerLink = LayerLink();

  // Flat node list — from real providers, filtered by mode
  List<_FlatNode> get _flatNodes {
    final allGroups = ref.read(groupsProvider);
    final mode = ref.read(patchClashConfigProvider).mode;

    // Filter groups by current proxy mode — only show Selector groups
    // (URLTest/Fallback/LoadBalance are sub-groups managed by mihomo core)
    final groups = switch (mode) {
      Mode.direct => <Group>[],
      Mode.global => allGroups.where((g) => g.name == GroupName.GLOBAL.name).toList(),
      Mode.rule => allGroups
          .where((g) => g.hidden == false && g.name != GroupName.GLOBAL.name)
          .where((g) => g.type == GroupType.Selector)
          .where((g) => !_isInfoNode(g.name))
          .toList(),
    };

    final list = <_FlatNode>[];
    for (final g in groups) {
      for (final p in g.all) {
        // Skip DIRECT / REJECT / subscription info nodes
        if (_isInfoNode(p.name)) continue;
        
        // Check if this proxy is a sub-group (URLTest/Fallback/LoadBalance)
        String displayName = p.name;
        final subGroup = allGroups.where((sg) => sg.name == p.name).firstOrNull;
        if (subGroup != null && subGroup.type.isComputedSelected) {
          // Sub-groups don't get a hint suffix — _syncSelectedIndex will jump
          // the selector to the resolved real node instead.
          // Extract flag from the resolved real node for correct country display
          String? resolvedHint;
          final resolvedNode = subGroup.now;
          if (resolvedNode != null && resolvedNode.isNotEmpty && !_isInfoNode(resolvedNode)) {
            resolvedHint = resolvedNode;
          } else {
            final firstReal = subGroup.all
                .where((n) => !_isInfoNode(n.name))
                .firstOrNull;
            if (firstReal != null) resolvedHint = firstReal.name;
          }
          final flag = _extractFlag(resolvedHint ?? p.name);
          final delay = ref.read(getDelayProvider(proxyName: p.name, testUrl: g.testUrl));
          list.add(_FlatNode(flag, g.name, p.name, displayName, g.name, g.testUrl, delay));
          continue;
        }
        
        // Filter: if displayName is an info node, skip
        if (_isInfoNode(displayName)) continue;
        
        final flag = _extractFlag(p.name);
        final delay = ref.read(getDelayProvider(proxyName: p.name, testUrl: g.testUrl));
        list.add(_FlatNode(flag, g.name, p.name, displayName, g.name, g.testUrl, delay));
      }
    }
    if (list.isEmpty) {
      final emptyMsg = mode == Mode.direct
          ? (S.isEn ? 'Direct mode' : '直连模式')
          : (S.isEn ? 'No nodes' : '无节点');
      String emptyHint;
      if (mode == Mode.direct) {
        emptyHint = S.isEn ? 'No proxy needed' : '直连模式无需代理';
      } else {
        final user = ref.read(userInfoProvider);
        if (user?.planId != null) {
          emptyHint = S.isEn ? 'Initializing...' : '正在初始化订阅...';
        } else {
          emptyHint = S.isEn ? 'Please purchase a plan first' : '请先购买套餐';
        }
      }
      list.add(_FlatNode('--', emptyMsg, emptyHint, emptyHint, '', null, null));
    }
    return list;
  }

  /// Extract ISO country code from a node name like "[anytls]新加坡" or "美国 01"
  static String _extractFlag(String name) {
    final lower = name.toLowerCase();
    // Chinese / English / abbreviation → ISO 3166-1 alpha-2
    const map = {
      '日本': 'JP', 'japan': 'JP',
      '美国': 'US', 'usa': 'US', 'us': 'US',
      '新加坡': 'SG', 'singapore': 'SG',
      '德国': 'DE', 'germany': 'DE',
      '英国': 'GB', 'uk': 'GB',
      '韩国': 'KR', 'korea': 'KR',
      '香港': 'HK', 'hong kong': 'HK',
      '台湾': 'TW', 'taiwan': 'TW',
      '加拿大': 'CA', 'canada': 'CA',
      '澳大利亚': 'AU', 'australia': 'AU', '澳洲': 'AU',
      '法国': 'FR', 'france': 'FR',
      '印度': 'IN', 'india': 'IN',
      '俄罗斯': 'RU', 'russia': 'RU',
      '巴西': 'BR', 'brazil': 'BR',
      '荷兰': 'NL', 'netherlands': 'NL',
      '意大利': 'IT', 'italy': 'IT',
      '西班牙': 'ES', 'spain': 'ES',
      '瑞士': 'CH', 'switzerland': 'CH',
      '土耳其': 'TR', 'turkey': 'TR', 'türkiye': 'TR',
      '泰国': 'TH', 'thailand': 'TH',
      '越南': 'VN', 'vietnam': 'VN',
      '菲律宾': 'PH', 'philippines': 'PH',
      '马来西亚': 'MY', 'malaysia': 'MY',
      '印尼': 'ID', 'indonesia': 'ID',
      '以色列': 'IL', 'israel': 'IL',
      '爱尔兰': 'IE', 'ireland': 'IE',
      '阿根廷': 'AR', 'argentina': 'AR',
      '阿联酋': 'AE', 'uae': 'AE',
      '波兰': 'PL', 'poland': 'PL',
      '埃及': 'EG', 'egypt': 'EG',
      '智利': 'CL', 'chile': 'CL',
      '墨西哥': 'MX', 'mexico': 'MX',
      '南非': 'ZA', 'south africa': 'ZA',
      '缅甸': 'MM', 'myanmar': 'MM',
      '柬埔寨': 'KH', 'cambodia': 'KH',
      '乌克兰': 'UA', 'ukraine': 'UA',
    };
    for (final entry in map.entries) {
      if (lower.contains(entry.key)) return entry.value;
    }
    return '--';
  }

  /// Whether a proxy name is a special non-connectable entry
  static bool _isInfoNode(String name) {
    final lower = name.toLowerCase();
    return lower == 'direct' ||
        lower == 'reject' ||
        lower.contains('剩余流量') ||
        lower.contains('套餐到期') ||
        lower.contains('距离下次重置') ||
        lower.contains('到期') ||
        lower.contains('expire') ||
        lower.contains('traffic') ||
        lower.contains('残余') ||
        lower.contains('官网') ||
        lower.contains('重置剩余') ||
        lower.contains('订阅链接') ||
        lower.contains('更新订阅') ||
        lower.contains('剩余') ||
        lower.contains('过期') ||
        lower.contains('到期时间') ||
        lower.contains('有效期') ||
        lower.contains('续费') ||
        lower.contains('购买') ||
        lower.contains('充值') ||
        lower.contains('邀请') ||
        lower.contains('tg群') ||
        lower.contains('telegram') ||
        lower.contains('频道') ||
        lower.contains('客服') ||
        lower.contains('公告') ||
        lower.contains('网址') ||
        lower.contains('官方') ||
        lower.contains('教程') ||
        lower.contains('使用说明') ||
        RegExp(r'\d+(\.\d+)?\s*(gb|tb|mb|pb)', caseSensitive: false).hasMatch(name) ||
        RegExp(r'\d+%').hasMatch(name);
  }

  String get _currentNodeLabel {
    final nodes = _flatNodes;
    _syncSelectedIndex(nodes);
    final n = nodes[_selectedFlatIndex];
    return n.displayName;
  }

  int? get _currentLatency {
    final nodes = _flatNodes;
    _syncSelectedIndex(nodes);
    return nodes[_selectedFlatIndex].latency;
  }

  /// Sync _selectedFlatIndex with the core's actual selectedMap so the pill
  /// reflects whatever node the Selector group really has selected.
  /// If the selected node is a URLTest/Fallback sub-group, auto-jump to
  /// whatever real node it resolved to and trigger a latency test.
  void _syncSelectedIndex(List<_FlatNode> nodes) {
    if (nodes.isEmpty || nodes.first.groupName.isEmpty) {
      _selectedFlatIndex = 0;
      return;
    }
    if (_selectedFlatIndex >= nodes.length) _selectedFlatIndex = 0;
    // Read the core's current selection for the first Selector group
    final groupName = nodes.first.groupName;
    final selectedName = appController.getSelectedProxyName(groupName);
    if (selectedName == null || selectedName.isEmpty) return;
    
    // Check if the selected proxy is a URLTest/Fallback sub-group
    final allGroups = ref.read(groupsProvider);
    final subGroup = allGroups.where((g) => g.name == selectedName).firstOrNull;
    if (subGroup != null && subGroup.type.isComputedSelected) {
      // Resolve to the real node the sub-group auto-selected
      String? realNode = subGroup.now;
      if (realNode == null || realNode.isEmpty || _isInfoNode(realNode)) {
        // Fallback: first real node in the sub-group
        final firstReal = subGroup.all
            .where((n) => !_isInfoNode(n.name))
            .firstOrNull;
        realNode = firstReal?.name;
      }
      if (realNode != null) {
        final idx = nodes.indexWhere((n) => n.nodeName == realNode);
        if (idx >= 0) {
          _selectedFlatIndex = idx;
          if (!_autoTestTriggered) {
            _pendingAutoTestIndex = idx;
          }
          return;
        }
      }
    }
    
    final idx = nodes.indexWhere((n) => n.nodeName == selectedName);
    if (idx >= 0) {
      _selectedFlatIndex = idx;
      // 普通节点也检查是否需要自动测速
      if (!_autoTestTriggered && (nodes[idx].latency == null || nodes[idx].latency! <= 0)) {
        _pendingAutoTestIndex = idx;
      }
    }
  }

  List<_NoticeItem> get _announcements {
    return _notices;
  }

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..repeat(reverse: true);
    _marqueeCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 10))..repeat();
    _announceTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (mounted && !_announceHovered && _announcements.length > 1) setState(() => _announceIndex = (_announceIndex + 1) % _announcements.length);
    });
    _tapScaleCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 120), lowerBound: 0.0, upperBound: 1.0);
    if (widget.connected) _startTimer();
    // 拉取公告API
    _fetchNotices();
    // 延迟重试自动选择节点测速（等待URLTest核心解析now字段）
    _autoTestRetryTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (!mounted) { timer.cancel(); return; }
      // 如果尚未触发自动测速，主动扫描当前选中节点
      if (!_autoTestTriggered && _pendingAutoTestIndex < 0) {
        final nodes = _flatNodes;
        _syncSelectedIndex(nodes);
        if (_pendingAutoTestIndex < 0 && _selectedFlatIndex >= 0 && _selectedFlatIndex < nodes.length) {
          final sel = nodes[_selectedFlatIndex];
          if (sel.latency == null || sel.latency! <= 0) {
            _pendingAutoTestIndex = _selectedFlatIndex;
          }
        }
      }
      // 检测是否有待测速的自动跳转节点
      if (_pendingAutoTestIndex >= 0 && !_autoTestTriggered) {
        _autoTestTriggered = true;
        _autoTestInProgress = true;
        final idx = _pendingAutoTestIndex;
        _pendingAutoTestIndex = -1;
        _handleTestSingleNode(idx);
        timer.cancel();
        return;
      }
      if (_autoTestTriggered) {
        timer.cancel();
        return;
      }
      // 重新触发 build 让 _syncSelectedIndex 获取最新的 subGroup.now
      if (mounted) setState(() {});
      // 最多重试15次(30秒)
      if (timer.tick >= 15) timer.cancel();
    });
    // 启动核心健康检查定时器
    _coreHealthTimer = Timer.periodic(const Duration(seconds: 10), (_) => _checkCoreHealth());
    // 恢复校园网模式状态
    SharedPreferences.getInstance().then((prefs) {
      if (!mounted) return;
      final campus = prefs.getBool('campus_mode_enabled') ?? false;
      if (campus) setState(() => _isCampusMode = true);
    });
    // 启动时后台静默刷新订阅，确保 hy2 等节点不因旧缓存丢失
    Future.delayed(const Duration(seconds: 8), () async {
      if (!mounted) return;
      try {
        final profile = ref.read(currentProfileProvider);
        if (profile?.type == ProfileType.url) {
          await appController.updateProfile(profile!);
        }
      } catch (_) {}
    });
    // 首次引导气泡延迟显示（仅首次）
    SharedPreferences.getInstance().then((prefs) {
      if (!mounted) return;
      if (prefs.getBool('desktop_guide_shown') == true) {
        _guideShown = true;
        return;
      }
      Future.delayed(const Duration(milliseconds: 1200), () {
        if (mounted && !_guideShown) _showGuideBubble();
      });
    });
  }

  @override
  void didUpdateWidget(DesktopHomePage old) {
    super.didUpdateWidget(old);
    if (widget.connected && !old.connected) _startTimer();
    if (!widget.connected && old.connected) _stopTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || widget.connectedAt == null) return;
      final d = DateTime.now().difference(widget.connectedAt!);
      setState(() => _elapsed = '${d.inHours.toString().padLeft(2, '0')}:${(d.inMinutes % 60).toString().padLeft(2, '0')}:${(d.inSeconds % 60).toString().padLeft(2, '0')}');
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _elapsed = '00:00:00';
  }

  Future<void> _fetchNotices() async {
    if (_noticesLoaded) return;
    try {
      // 根据登录状态选择对应API
      final notices = widget.isGuest
          ? await XBoardSDK.instance.notice.getGuestNotices(pageSize: 20)
          : await XBoardSDK.instance.notice.getNotices(pageSize: 20);
      if (!mounted) return;
      // 过滤后端 show=true 的公告
      final visibleNotices = notices.where((n) => n.show).toList();
      if (visibleNotices.isEmpty) {
        // 后端所有公告都关闭了
        setState(() {
          _noticesVisible = false;
          _noticesLoaded = true;
        });
        return;
      }
      final items = visibleNotices.map((n) {
        // 从公告内容中提取所有URL
        final urls = RegExp(r'https?://[^\s<>"]+').allMatches(n.content).map((m) => m.group(0)!).toList();
        final firstUrl = urls.isNotEmpty ? urls.first : null;
        return _NoticeItem(n.title, firstUrl, n.content);
      }).toList();
      setState(() {
        _notices = items;
        _noticesLoaded = true;
        _noticesVisible = true;
        _announceIndex = 0;
      });
    } catch (_) {
      // API 失败时使用硬编码后备公告
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _coreHealthTimer?.cancel();
    _announceTimer?.cancel();
    _autoTestRetryTimer?.cancel();
    _pulseCtrl.dispose();
    _marqueeCtrl.dispose();
    _tapScaleCtrl.dispose();
    _removePickerOverlay();
    _dismissGuide();
    super.dispose();
  }

  /// 核心健康检查：当 VPN 正在运行但核心断开时自动重启核心
  void _checkCoreHealth() {
    if (!mounted || widget.isGuest || _coreRestarting) return;
    final isRunning = ref.read(isStartProvider);
    final coreStatus = ref.read(coreStatusProvider);
    if (isRunning && coreStatus == CoreStatus.disconnected) {
      _coreRestarting = true;
      appController.restartCore().then((_) {
        if (mounted) setState(() => _coreRestarting = false);
      }).catchError((_) {
        if (mounted) setState(() => _coreRestarting = false);
      });
    }
  }

  Color _latencyColor(int? ms) {
    if (ms == null) return t.textHint;
    if (ms < 0) return t.danger;
    if (ms == 0) return t.textHint;
    if (ms < 600) return t.success;
    return t.warning;
  }

  void _showGuideBubble() {
    _guideShown = true;
    final renderBox = _proxyModeKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    final pos = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    _guideOverlay = OverlayEntry(
      builder: (ctx) {
        final bubbleW = 260.0;
        final bubbleLeft = pos.dx + (size.width - bubbleW) / 2;
        final bubbleTop = pos.dy + size.height + 2;
        return Stack(
          children: [
            // 点击任意位置关闭
            Positioned.fill(
              child: GestureDetector(
                onTap: _dismissGuide,
                behavior: HitTestBehavior.translucent,
                child: const SizedBox.expand(),
              ),
            ),
            // 气泡
            Positioned(
              left: bubbleLeft,
              top: bubbleTop,
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOutBack,
                builder: (_, v, child) => Opacity(
                  opacity: v.clamp(0.0, 1.0),
                  child: Transform.translate(
                    offset: Offset(0, 8 * (1 - v)),
                    child: Transform.scale(scale: 0.85 + 0.15 * v, child: child),
                  ),
                ),
                child: GestureDetector(
                  onTap: _dismissGuide,
                  child: Column(
                  children: [
                    // 三角箭头（朝上，带边框）
                    CustomPaint(
                      size: const Size(18, 9),
                      painter: _ArrowUpPainter(
                        fillColor: t.isDark ? const Color(0xFF2A2A3E) : Colors.white,
                        borderColor: t.primary.withValues(alpha: 0.3),
                      ),
                    ),
                    Container(
                      width: bubbleW,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: t.isDark ? const Color(0xFF2A2A3E) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 20, offset: const Offset(0, 4)),
                        ],
                        border: Border.all(color: t.primary.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.touch_app, size: 18, color: t.primary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              S.isEn ? 'Long press mode for details' : '长按模式按钮可查看详细说明',
                              style: TextStyle(fontSize: 13, color: t.textPrimary, fontWeight: FontWeight.w500),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            S.isEn ? 'Got it' : '知道了',
                            style: TextStyle(fontSize: 12, color: t.primary, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                ),
              ),
            ),
          ],
        );
      },
    );
    Overlay.of(context).insert(_guideOverlay!);
  }

  void _dismissGuide() {
    _guideOverlay?.remove();
    _guideOverlay = null;
    if (!_guideShown) return;
    SharedPreferences.getInstance().then((prefs) {
      prefs.setBool('desktop_guide_shown', true);
    });
  }

  void _toggleNodePicker() {
    if (_pickerOpen) {
      _removePickerOverlay();
    } else {
      _showPickerOverlay();
    }
  }

  void _removePickerOverlay() {
    _pickerOverlay?.remove();
    _pickerOverlay = null;
    if (_pickerOpen && mounted) setState(() => _pickerOpen = false);
  }

  Future<void> _handleSyncSubscription() async {
    if (_isSyncing) return;
    final wasConnected = widget.connected;
    _removePickerOverlay();
    setState(() => _isSyncing = true);
    final dismissSyncing = showPillToast(context, t, S.isEn ? 'Updating subscription...' : '正在更新订阅...', duration: const Duration(seconds: 30));
    try {
      // 1. 刷新 XBoard 订阅信息，获取最新 subscribeUrl
      await ref.read(xboardUserProvider.notifier).refreshSubscriptionInfo();
      // 2. 清除旧配置 → 下载新配置 → 应用
      final sub = ref.read(subscriptionInfoProvider);
      if (sub != null && sub.subscribeUrl.isNotEmpty) {
        await ref.read(profileImportProvider.notifier).importSubscription(
          sub.subscribeUrl,
          forceRefresh: true,
        );
      } else {
        // 回退：直接更新现有 profile
        final currentProfile = ref.read(currentProfileProvider);
        if (currentProfile != null) {
          await appController.updateProfile(currentProfile);
        }
      }
    } finally {
      if (mounted) {
        dismissSyncing();
        setState(() => _isSyncing = false);
        _rebuildOverlay();
        final msg = wasConnected
            ? (S.isEn ? 'Subscription updated, please reconnect' : '订阅已更新，请重新连接')
            : (S.isEn ? 'Subscription updated' : '订阅已更新');
        showPillToast(context, t, msg);
      }
    }
  }

  void _handleTestAllLatency() {
    if (_isTestingAll) return;
    final nodes = _flatNodes;
    if (nodes.isEmpty || nodes.first.groupName.isEmpty) return;
    final totalNodes = nodes.length;
    setState(() {
      _isTestingAll = true;
      _testResults.clear();
      _testingNodeIndex = -2; // batch mode
    });
    _rebuildOverlay();
    showPillToast(context, t, S.isEn ? 'Testing $totalNodes nodes...' : '正在批量测试 $totalNodes 个节点延迟...');
    int completed = 0;
    int failed = 0;
    final groups = ref.read(groupsProvider);
    for (int i = 0; i < nodes.length; i++) {
      final node = nodes[i];
      final group = groups.where((g) => g.name == node.groupName).firstOrNull;
      final proxy = group?.all.where((p) => p.name == node.nodeName).firstOrNull;
      if (group == null || proxy == null) {
        completed++;
        continue;
      }
      final idx = i;
      _testResults[idx] = '__testing__';
      proxies_common.proxyDelayTest(proxy, group.testUrl).then((_) {
        if (!mounted) return;
        completed++;
        final delay = ref.read(getDelayProvider(proxyName: proxy.name, testUrl: group.testUrl));
        if (delay == null || delay <= 0) failed++;
        setState(() {
          _testResults[idx] = delay != null && delay > 0 ? '${delay}ms' : (S.isEn ? 'Timeout' : '超时');
        });
        _rebuildOverlay();
        if (completed == totalNodes) {
          setState(() {
            _isTestingAll = false;
            _testingNodeIndex = -1;
          });
          _rebuildOverlay();
          final msg = failed > 0
              ? (S.isEn ? 'Done: ${totalNodes - failed} ok, $failed timeout' : '测速完成：${totalNodes - failed} 个成功，$failed 个超时')
              : (S.isEn ? 'All $totalNodes nodes tested' : '全部 $totalNodes 个节点测速完成');
          showPillToast(context, t, msg);
        }
      }).catchError((_) {
        if (!mounted) return;
        completed++;
        failed++;
        setState(() {
          _testResults[idx] = S.isEn ? 'Timeout' : '超时';
        });
        _rebuildOverlay();
        if (completed == totalNodes) {
          setState(() {
            _isTestingAll = false;
            _testingNodeIndex = -1;
          });
          _rebuildOverlay();
          final msg = failed > 0
              ? (S.isEn ? 'Done: ${totalNodes - failed} ok, $failed timeout' : '测速完成：${totalNodes - failed} 个成功，$failed 个超时')
              : (S.isEn ? 'All $totalNodes nodes tested' : '全部 $totalNodes 个节点测速完成');
          showPillToast(context, t, msg);
        }
      });
    }
  }

  void _handleTestSingleNode(int index) {
    if (_testingNodeIndex >= 0) return;
    final nodes = _flatNodes;
    if (index < 0 || index >= nodes.length) return;
    final node = nodes[index];
    if (node.groupName.isEmpty) return; // empty/placeholder node
    setState(() {
      _testingNodeIndex = index;
      _testResults.remove(index);
    });
    _rebuildOverlay();
    // Find the proxy in the group
    final groups = ref.read(groupsProvider);
    final group = groups.where((g) => g.name == node.groupName).firstOrNull;
    final proxy = group?.all.where((p) => p.name == node.nodeName).firstOrNull;
    if (group == null || proxy == null) {
      setState(() => _testingNodeIndex = -1);
      _rebuildOverlay();
      return;
    }
    proxies_common.proxyDelayTest(proxy, group.testUrl).then((_) {
      if (!mounted) return;
      final delay = ref.read(getDelayProvider(proxyName: proxy.name, testUrl: group.testUrl));
      final isTimeout = delay == null || delay <= 0;
      setState(() {
        _testingNodeIndex = -1;
        _testResults[index] = isTimeout ? (S.isEn ? 'Timeout' : '超时') : '${delay}ms';
      });
      // 自动跳转测速超时：重置标志，让核心的自动选择组故障转移后可以再次跳转
      if (isTimeout && _autoTestInProgress) {
        _autoTestTriggered = false;
      }
      _autoTestInProgress = false;
      _rebuildOverlay();
    }).catchError((_) {
      if (!mounted) return;
      setState(() {
        _testingNodeIndex = -1;
        _testResults[index] = S.isEn ? 'Timeout' : '超时';
      });
      // 超时：重置自动跳转标志以允许故障转移
      if (_autoTestInProgress) {
        _autoTestTriggered = false;
      }
      _autoTestInProgress = false;
      _rebuildOverlay();
    });
  }

  void _handlePillLatencyTest() {
    if (_testingNodeIndex >= 0) return;
    _handleTestSingleNode(_selectedFlatIndex);
  }

  void _rebuildOverlay() {
    _pickerOverlay?.markNeedsBuild();
  }

  void _showPickerOverlay() {
    final renderBox = _pillKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    setState(() => _pickerOpen = true);

    _pickerOverlay = OverlayEntry(
      builder: (ctx) {
        // 实时获取药丸尺寸用于宽度和高度计算
        final rb = _pillKey.currentContext?.findRenderObject() as RenderBox?;
        if (rb == null || !rb.attached) return const SizedBox.shrink();
        final pillPos = rb.localToGlobal(Offset.zero);
        final pillSize = rb.size;

        final nodes = _flatNodes;
        const toolbarH = 40.0;
        final itemH = 48.0;
        final listContentH = nodes.length * itemH;
        // 药丸上方可用空间（留 窗口标题栏 40px + 24px 安全边距）
        final spaceAbove = pillPos.dy - 64;
        final maxListH = spaceAbove - toolbarH;
        final listH = listContentH.clamp(48.0, maxListH.clamp(48.0, 400.0));
        final dropH = toolbarH + listH;
        // 宽度跟随药丸
        final dropW = pillSize.width;

        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: _removePickerOverlay,
                behavior: HitTestBehavior.translucent,
                child: const SizedBox.expand(),
              ),
            ),
            // 使用 CompositedTransformFollower 原生跟随药丸位置
            CompositedTransformFollower(
              link: _pickerLink,
              targetAnchor: Alignment.topCenter,
              followerAnchor: Alignment.bottomCenter,
              offset: const Offset(0, -6), // 底部与药丸保留 6px 缝隙
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: dropW,
                  constraints: BoxConstraints(maxHeight: dropH),
                  decoration: BoxDecoration(
                    color: t.cardBg,
                    borderRadius: BorderRadius.circular(14),
                    border: t.cardBorder ?? Border.all(color: t.textHint.withValues(alpha: 0.1)),
                    boxShadow: [
                      BoxShadow(color: t.primary.withValues(alpha: 0.1), blurRadius: 20),
                      BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 8, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // ── Toolbar ──
                        Container(
                          height: toolbarH,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            border: Border(bottom: BorderSide(color: t.textHint.withValues(alpha: 0.08))),
                          ),
                          child: Row(
                            children: [
                              Text(
                                '${nodes.length} ${S.isEn ? 'nodes' : '个节点'}',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: t.textSecondary),
                              ),
                              const Spacer(),
                              _toolbarBtn(
                                icon: Icons.sync,
                                label: S.subscribe,
                                loading: _isSyncing,
                                onTap: _handleSyncSubscription,
                              ),
                              const SizedBox(width: 8),
                              _toolbarBtn(
                                icon: Icons.speed,
                                label: S.speedTest,
                                loading: _isTestingAll,
                                onTap: _handleTestAllLatency,
                              ),
                            ],
                          ),
                        ),
                        // ── Node list ──
                        Flexible(
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            shrinkWrap: true,
                            itemCount: nodes.length,
                            itemBuilder: (ctx, i) {
                              final n = nodes[i];
                              final isSel = i == _selectedFlatIndex;
                              final latencyKey = GlobalKey();
                              return GestureDetector(
                                onTapUp: (details) {
                                  final latencyBox = latencyKey.currentContext?.findRenderObject() as RenderBox?;
                                  if (latencyBox != null) {
                                    final localPos = latencyBox.globalToLocal(details.globalPosition);
                                    if (latencyBox.paintBounds.contains(localPos)) {
                                      _handleTestSingleNode(i);
                                      return;
                                    }
                                  }
                                  setState(() => _selectedFlatIndex = i);
                                  final selNode = nodes[i];
                                  if (selNode.groupName.isNotEmpty) {
                                    appController.updateCurrentSelectedMap(selNode.groupName, selNode.nodeName);
                                    appController.changeProxy(groupName: selNode.groupName, proxyName: selNode.nodeName);
                                    // 切换节点后自动测速
                                    if (selNode.latency == null || selNode.latency! <= 0) {
                                      _handleTestSingleNode(i);
                                    }
                                  }
                                  _removePickerOverlay();
                                },
                                child: Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                                  decoration: BoxDecoration(
                                    gradient: isSel ? t.buttonGradient : null,
                                    color: isSel ? null : Colors.transparent,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    children: [
                                      FlagBadge(n.flag, size: 28),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          n.displayName,
                                          style: TextStyle(
                                            fontSize: 13, fontWeight: FontWeight.w500,
                                            color: isSel ? Colors.white : t.textPrimary,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Builder(builder: (_) {
                                        final isTesting = _testingNodeIndex == i || _testResults[i] == '__testing__';
                                        final result = _testResults[i];
                                        final hasResult = result != null && result != '__testing__';
                                        final isTimeout = hasResult && (result == '超时' || result == 'Timeout');
                                        final delayText = hasResult ? result! : (n.latency != null && n.latency! > 0 ? '${n.latency}ms' : (S.isEn ? 'Test' : '测速'));
                                        int? effectiveDelay = n.latency;
                                        if (hasResult && !isTimeout) {
                                          effectiveDelay = int.tryParse(result!.replaceAll('ms', '')) ?? n.latency;
                                        }
                                        final dotColor = isTesting
                                            ? (isSel ? Colors.white38 : t.textHint)
                                            : isTimeout
                                                ? (isSel ? Colors.white70 : t.danger)
                                                : (isSel ? Colors.white70 : _latencyColor(effectiveDelay));
                                        final txtColor = isSel ? Colors.white70
                                            : isTimeout ? t.danger : _latencyColor(effectiveDelay);
                                        return MouseRegion(
                                          key: latencyKey,
                                          cursor: SystemMouseCursors.click,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: (isTimeout ? t.danger : _latencyColor(effectiveDelay)).withValues(alpha: 0.1),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Container(
                                                  width: 6, height: 6,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: dotColor,
                                                  ),
                                                ),
                                                const SizedBox(width: 4),
                                                if (isTesting)
                                                  SizedBox(
                                                    width: 12, height: 12,
                                                    child: CircularProgressIndicator(
                                                      strokeWidth: 1.5,
                                                      color: isSel ? Colors.white70 : t.textHint,
                                                    ),
                                                  )
                                                else
                                                  Text(
                                                    delayText,
                                                    style: TextStyle(
                                                      fontSize: 12, fontWeight: FontWeight.w500,
                                                      color: txtColor,
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                        );
                                      }),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    Overlay.of(context).insert(_pickerOverlay!);
  }

  Widget _toolbarBtn({required IconData icon, required String label, required bool loading, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: loading ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: t.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            loading
                ? SizedBox(width: 13, height: 13, child: CircularProgressIndicator(strokeWidth: 1.5, color: t.primary))
                : Icon(icon, size: 13, color: t.primary),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: t.primary)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Watch providers to trigger rebuild when groups/mode changes
    ref.watch(groupsProvider);
    ref.watch(patchClashConfigProvider.select((s) => s.mode));
    final statusTop = _noticesVisible ? 62.0 : 24.0;
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(24),
          child: _buildConnectionPanel(),
        ),
        Positioned(
          left: 32, right: 32, top: 16,
          child: _noticesVisible ? _buildAnnouncementBanner() : const SizedBox.shrink(),
        ),
        AnimatedPositioned(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          right: 36, top: statusTop,
          bottom: 24,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _buildCoreStatus(),
              const SizedBox(height: 8),
              _buildTunToggle(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAnnouncementBanner() {
    final items = _announcements;
    final current = items.isNotEmpty ? items[_announceIndex % items.length] : _NoticeItem('', null, null);
    final hasContent = current.title.isNotEmpty;
    return MouseRegion(
      cursor: hasContent ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) {
        _announceHovered = true;
        _marqueeCtrl.stop();
      },
      onExit: (_) {
        _announceHovered = false;
        _marqueeCtrl.repeat();
      },
      child: GestureDetector(
        onTap: () {
          if (hasContent) {
            _showNoticeDialog(current);
          }
        },
        child: Container(
          height: 38,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                t.primary.withValues(alpha: t.isDark ? 0.2 : 0.1),
                t.secondary.withValues(alpha: t.isDark ? 0.12 : 0.06),
              ],
            ),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: t.primary.withValues(alpha: 0.15)),
          ),
          child: Row(
            children: [
              Container(
                width: 24, height: 24,
                decoration: BoxDecoration(gradient: t.primaryGradient, borderRadius: BorderRadius.circular(6)),
                child: const Icon(Icons.campaign, color: Colors.white, size: 14),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ClipRect(
                  child: AnimatedBuilder(
                    animation: _marqueeCtrl,
                    builder: (ctx, child) {
                      return FractionalTranslation(
                        translation: Offset(1.0 - 2.0 * _marqueeCtrl.value, 0),
                        child: child,
                      );
                    },
                    child: Text(
                      current.title,
                      style: TextStyle(fontSize: 13, color: t.textPrimary, fontWeight: FontWeight.w600),
                      maxLines: 1, softWrap: false,
                    ),
                  ),
                ),
              ),
              if (hasContent) ...[
                const SizedBox(width: 6),
                Icon(Icons.chevron_right, size: 16, color: t.primary),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWarningBanners() {
    final user = ref.watch(userInfoProvider);
    final sub = ref.watch(subscriptionInfoProvider);
    final isExpired = user?.isExpired ?? false;
    final isTrafficExhausted = sub?.isTrafficExhausted ?? false;
    if (!isExpired && !isTrafficExhausted) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isExpired)
            _warningChip(
              icon: Icons.access_time_rounded,
              label: S.isEn ? 'Plan expired, please renew' : '套餐已过期，请续费',
              color: const Color(0xFFFF6B6B),
            ),
          if (isExpired && isTrafficExhausted) const SizedBox(width: 8),
          if (isTrafficExhausted)
            _warningChip(
              icon: Icons.data_usage_rounded,
              label: S.isEn ? 'Traffic exhausted' : '流量已用完',
              color: const Color(0xFFFF9800),
            ),
        ],
      ),
    );
  }

  Widget _warningChip({required IconData icon, required String label, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }

  /// 预处理 HTML：将 ul/ol/li 转为居中段落，移除子弹符号，确保 HtmlWidget 能正确居中
  String _preprocessNoticeHtml(String html) {
    // 移除 ul/ol 包裹标签
    var result = html.replaceAll(RegExp(r'</?(?:ul|ol)[^>]*>', caseSensitive: false), '');
    // 将 <li> 转为 <p>，</li> 转为 </p>
    result = result.replaceAll(RegExp(r'<li[^>]*>', caseSensitive: false), '<p>');
    result = result.replaceAll(RegExp(r'</li>', caseSensitive: false), '</p>');
    // 移除各种子弹符号（Unicode bullet, HTML entity 等）
    result = result.replaceAll(RegExp(r'[•·‣▪▸►]'), '');
    result = result.replaceAll(RegExp(r'&bull;|&#8226;|&#x2022;', caseSensitive: false), '');
    // 清理多余空白
    result = result.replaceAll(RegExp(r'<p>\s*</p>', caseSensitive: false), '');
    return result;
  }

  void _showNoticeDialog(_NoticeItem notice) {
    final displayContent = notice.content ?? notice.title;
    // 检测内容是否为 HTML
    final isHtml = RegExp(
      r'<(p|div|span|h[1-6]|ul|ol|li|br|hr|strong|em|a|img|table|tr|td|th|blockquote|pre|code)[>\s/]',
      caseSensitive: false,
    ).hasMatch(displayContent);
    // 预处理：始终处理以确保居中生效（会检测HTML/Markdown中的列表结构）
    final processedContent = _preprocessNoticeHtml(displayContent);
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'close',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 250),
      transitionBuilder: (ctx, a1, a2, child) => Transform.scale(
        scale: Curves.easeOutBack.transform(a1.value),
        child: Opacity(opacity: a1.value, child: child),
      ),
      pageBuilder: (ctx, a1, a2) => Center(
        child: Material(
          color: Colors.transparent,
          child: Consumer(
            builder: (ctx2, ref2, _) {
              final themeState = ref2.watch(desktopThemeProvider);
              final currentTheme = resolveTheme(themeState, MediaQuery.of(ctx2).platformBrightness);
              return Container(
                width: 440,
                constraints: const BoxConstraints(maxHeight: 420),
                decoration: BoxDecoration(
                  color: currentTheme.cardBg,
                  borderRadius: BorderRadius.circular(20),
                  border: currentTheme.cardBorder,
                  boxShadow: [BoxShadow(color: currentTheme.primary.withValues(alpha: 0.15), blurRadius: 30)],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 标题栏
                    Padding(
                      padding: const EdgeInsets.fromLTRB(22, 18, 18, 0),
                      child: Row(
                        children: [
                          Container(
                            width: 36, height: 36,
                            decoration: BoxDecoration(
                              color: currentTheme.primary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(Icons.campaign, color: currentTheme.primary, size: 20),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              notice.title,
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: currentTheme.textPrimary),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
                              onTap: () => Navigator.of(ctx2).pop(),
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(color: currentTheme.textHint.withValues(alpha: 0.1), shape: BoxShape.circle),
                                child: Icon(Icons.close, color: currentTheme.textHint, size: 18),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // 内容
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(22, 0, 22, 18),
                        child: SingleChildScrollView(
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: currentTheme.isDark ? const Color(0xFF1E2140) : const Color(0xFFF5F7FA),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: isHtml
                                ? DefaultTextStyle(
                                    style: TextStyle(fontSize: 14, color: currentTheme.textSecondary, height: 1.6),
                                    textAlign: TextAlign.center,
                                    child: HtmlWidget(
                                      '<div style="text-align:center;">$processedContent</div>',
                                      onTapUrl: (url) {
                                        launchUrl(Uri.parse(url));
                                        return true;
                                      },
                                      textStyle: TextStyle(fontSize: 14, color: currentTheme.textSecondary, height: 1.6),
                                      customStylesBuilder: (element) {
                                        final styles = <String, String>{'text-align': 'center'};
                                        switch (element.localName) {
                                          case 'a':
                                            styles['color'] = _colorToHex(currentTheme.primary);
                                            styles['font-weight'] = '600';
                                            styles['text-decoration'] = 'underline';
                                            styles['text-decoration-thickness'] = '2px';
                                          case 'strong':
                                          case 'b':
                                            styles['color'] = _colorToHex(currentTheme.textPrimary);
                                            styles['font-weight'] = 'bold';
                                        }
                                        return styles;
                                      },
                                    ),
                                  )
                                : MarkdownBody(
                                    data: processedContent,
                                    selectable: true,
                                    styleSheet: MarkdownStyleSheet(
                                      p: TextStyle(fontSize: 14, color: currentTheme.textSecondary, height: 1.6),
                                      pPadding: const EdgeInsets.only(bottom: 4),
                                      textAlign: WrapAlignment.center,
                                      h1Align: WrapAlignment.center,
                                      h2Align: WrapAlignment.center,
                                      h3Align: WrapAlignment.center,
                                      strong: TextStyle(fontSize: 14, color: currentTheme.textPrimary, fontWeight: FontWeight.bold, height: 1.6),
                                      a: TextStyle(fontSize: 14, color: currentTheme.primary, fontWeight: FontWeight.w600, decoration: TextDecoration.underline, decorationColor: currentTheme.primary.withValues(alpha: 0.6), decorationThickness: 2, height: 1.6),
                                      listBullet: TextStyle(fontSize: 14, color: currentTheme.textSecondary, fontFamily: 'serif'),
                                      listBulletPadding: const EdgeInsets.only(right: 6),
                                      unorderedListAlign: WrapAlignment.center,
                                      orderedListAlign: WrapAlignment.center,
                                      code: TextStyle(fontSize: 13, color: currentTheme.primary, backgroundColor: currentTheme.primary.withValues(alpha: 0.08)),
                                      h1: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: currentTheme.textPrimary),
                                      h2: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: currentTheme.textPrimary),
                                      h3: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: currentTheme.textPrimary),
                                    ),
                                    onTapLink: (text, href, title) {
                                      if (href != null) launchUrl(Uri.parse(href));
                                    },
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCoreStatus() {
    final coreStatus = ref.watch(coreStatusProvider);
    final Color dotColor;
    final String label;
    switch (coreStatus) {
      case CoreStatus.connected:
        dotColor = t.success;
        label = S.isEn ? 'Core: Running' : '核心: 运行中';
      case CoreStatus.connecting:
        dotColor = t.warning;
        label = S.isEn ? 'Core: Starting' : '核心: 启动中';
      case CoreStatus.disconnected:
        dotColor = t.danger;
        label = S.isEn ? 'Core: Stopped' : '核心: 未启动';
    }
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          if (_coreRestarting) return;
          showGeneralDialog(
            context: context,
            barrierDismissible: true,
            barrierLabel: 'close',
            barrierColor: Colors.black54,
            transitionDuration: const Duration(milliseconds: 220),
            transitionBuilder: (ctx, a1, a2, child) => Transform.scale(
              scale: Curves.easeOutBack.transform(a1.value),
              child: Opacity(opacity: a1.value, child: child),
            ),
            pageBuilder: (ctx, a1, a2) => Center(
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: 380,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: t.cardBg,
                    borderRadius: BorderRadius.circular(20),
                    border: t.cardBorder,
                    boxShadow: [BoxShadow(color: t.primary.withValues(alpha: 0.15), blurRadius: 30)],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 36, height: 36,
                            decoration: BoxDecoration(color: t.warning.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
                            child: Icon(Icons.restart_alt, color: t.warning, size: 20),
                          ),
                          const SizedBox(width: 10),
                          Expanded(child: Text(S.isEn ? 'Restart Core' : '重启核心', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: t.textPrimary))),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(
                        S.isEn
                            ? 'This will force restart the proxy core. The network may be briefly interrupted.'
                            : '将强制重启代理核心，网络可能会短暂中断。',
                        style: TextStyle(fontSize: 13, color: t.textSecondary, height: 1.5),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: Text(S.isEn ? 'Cancel' : '取消', style: TextStyle(color: t.textHint)),
                          ),
                          const SizedBox(width: 8),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(ctx);
                              setState(() => _coreRestarting = true);
                              showPillToast(context, t, S.isEn ? 'Core restarting...' : '核心重启中...');
                              appController.restartCore().then((_) {
                                if (mounted) {
                                  setState(() => _coreRestarting = false);
                                  showPillToast(context, t, S.isEn ? 'Core restarted' : '核心已重启');
                                }
                              }).catchError((_) {
                                if (mounted) {
                                  setState(() => _coreRestarting = false);
                                  showPillToast(context, t, S.isEn ? 'Core restart failed' : '核心重启失败');
                                }
                              });
                            },
                            child: Text(S.isEn ? 'Restart' : '重启', style: TextStyle(color: t.primary, fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8, height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: dotColor,
                boxShadow: [BoxShadow(color: dotColor.withValues(alpha: 0.4), blurRadius: 4)],
              ),
            ),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(fontSize: 12, color: t.textHint, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildTunToggle() {
    final tunEnabled = ref.watch(patchClashConfigProvider.select((s) => s.tun.enable));
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          // 校园网模式下禁止开启 TUN
          if (_isCampusMode) {
            showPillToast(context, t, S.isEn ? 'TUN is disabled in campus mode' : '校园网模式下 TUN 已禁用，请先切换到规则/全局模式');
            return;
          }
          final newValue = !tunEnabled;
          ref.read(patchClashConfigProvider.notifier).update((state) => state.copyWith.tun(enable: newValue));
          if (!newValue) {
            // 关闭 TUN 时提示说明
            showGeneralDialog(
              context: context,
              barrierDismissible: true,
              barrierLabel: 'close',
              barrierColor: Colors.black54,
              transitionDuration: const Duration(milliseconds: 220),
              transitionBuilder: (ctx, a1, a2, child) => Transform.scale(
                scale: Curves.easeOutBack.transform(a1.value),
                child: Opacity(opacity: a1.value, child: child),
              ),
              pageBuilder: (ctx, a1, a2) => Center(
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    width: 380,
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: t.cardBg,
                      borderRadius: BorderRadius.circular(20),
                      border: t.cardBorder,
                      boxShadow: [BoxShadow(color: t.primary.withValues(alpha: 0.15), blurRadius: 30)],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 36, height: 36,
                              decoration: BoxDecoration(color: t.warning.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
                              child: Icon(Icons.info_outline, color: t.warning, size: 20),
                            ),
                            const SizedBox(width: 10),
                            Expanded(child: Text(S.isEn ? 'TUN Mode Disabled' : 'TUN 模式已关闭', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: t.textPrimary))),
                            MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: GestureDetector(
                                onTap: () => Navigator.of(ctx).pop(),
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(color: t.textHint.withValues(alpha: 0.1), shape: BoxShape.circle),
                                  child: Icon(Icons.close, color: t.textHint, size: 18),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Text(
                          S.isEn
                              ? 'TUN mode captures all system traffic through a virtual network adapter. When disabled, only traffic from apps that use system proxy settings will be routed through the VPN. Some apps may bypass the proxy.'
                              : 'TUN 模式通过虚拟网卡接管系统全部流量。关闭后，只有使用系统代理设置的应用流量会通过 VPN 转发，部分应用可能会绕过代理直连。建议保持开启以获得最佳体验。',
                          style: TextStyle(fontSize: 13, color: t.textSecondary, height: 1.5),
                        ),
                        const SizedBox(height: 16),
                        MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: () => Navigator.of(ctx).pop(),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(gradient: t.buttonGradient, borderRadius: BorderRadius.circular(10)),
                              child: Center(child: Text(S.isEn ? 'Got it' : '知道了', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14))),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              tunEnabled ? Icons.shield : Icons.shield_outlined,
              size: 14,
              color: tunEnabled ? t.success : t.textHint,
            ),
            const SizedBox(width: 4),
            Text(
              'TUN',
              style: TextStyle(fontSize: 12, color: tunEnabled ? t.success : t.textHint, fontWeight: FontWeight.w500),
            ),
            const SizedBox(width: 4),
            Container(
              width: 28, height: 16,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: tunEnabled ? t.success : t.textHint.withValues(alpha: 0.3),
              ),
              child: AnimatedAlign(
                alignment: tunEnabled ? Alignment.centerRight : Alignment.centerLeft,
                duration: const Duration(milliseconds: 200),
                child: Container(
                  width: 12, height: 12,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectionPanel() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      decoration: BoxDecoration(
        color: t.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: t.cardBorder,
        boxShadow: t.cardShadow,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
        final compact = constraints.maxHeight < 400;
        return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: compact ? 24 : 48),
          // 大按钮 — 带点击缩放反馈 + 连接脉冲
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              // 悬浮横幅（不占布局空间）
              Positioned(
                top: -36,
                child: _buildWarningBanners(),
              ),
              MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
            onTapDown: (_) => _tapScaleCtrl.forward(),
            onTapUp: (_) {
              _tapScaleCtrl.reverse();
              widget.onToggleConnection();
            },
            onTapCancel: () => _tapScaleCtrl.reverse(),
            child: AnimatedBuilder(
              animation: Listenable.merge([_pulseCtrl, _tapScaleCtrl]),
              builder: (ctx, child) {
                final tapShrink = 1.0 - _tapScaleCtrl.value * 0.08;
                final glowAlpha = widget.connected ? 0.25 + _pulseCtrl.value * 0.2 : 0.15;
                final glowSpread = widget.connected ? 2.0 + _pulseCtrl.value * 8.0 : 2.0;
                return Transform.scale(
                  scale: tapShrink,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 150, height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: widget.connected ? t.connectedGradient : t.disconnectedGradient,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.25),
                        width: 2.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (widget.connected ? t.connectedGlow : t.disconnectedGlow).withValues(alpha: glowAlpha),
                          blurRadius: 36, spreadRadius: glowSpread,
                        ),
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 10, offset: const Offset(0, 6),
                        ),
                        BoxShadow(
                          color: Colors.white.withValues(alpha: 0.15),
                          blurRadius: 2, offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        widget.connected
                          ? Image.asset('assets/branding/icon_white.png', width: 52, height: 52)
                          : Icon(Icons.power_settings_new, color: Colors.white, size: 42),
                        const SizedBox(height: 6),
                        Text(widget.connected ? S.protected_ : (S.isEn ? 'Disconnected' : '未连接'),
                          style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          ),
            ],
          ),
          SizedBox(height: compact ? 12 : 24),

          // 连接时间 — 平滑过渡
          AnimatedCrossFade(
              firstChild: const SizedBox(height: 8),
              secondChild: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(S.connectionTime, style: TextStyle(fontSize: 13, color: t.textHint)),
                  const SizedBox(height: 3),
                  Text(_elapsed, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: t.textPrimary,
                    fontFeatures: const [FontFeature.tabularFigures()])),
                  const SizedBox(height: 12),
                ],
              ),
              crossFadeState: widget.connected ? CrossFadeState.showSecond : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 350),
              sizeCurve: Curves.easeInOut,
            ),

          // 节点选择 药丸 — 点击展开悬浮下拉
          CompositedTransformTarget(
            link: _pickerLink,
            child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
            key: _pillKey,
            onTapUp: (details) {
              // 检测是否点击了延迟徽章 — 无论连接状态都只测速不展开
              final latencyBox = _pillLatencyKey.currentContext?.findRenderObject() as RenderBox?;
              if (latencyBox != null) {
                final localPos = latencyBox.globalToLocal(details.globalPosition);
                if (latencyBox.paintBounds.contains(localPos)) {
                  _handlePillLatencyTest();
                  return;
                }
              }
              _toggleNodePicker();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: _pickerOpen
                    ? t.primary.withValues(alpha: t.isDark ? 0.18 : 0.1)
                    : t.primary.withValues(alpha: t.isDark ? 0.1 : 0.05),
                borderRadius: BorderRadius.circular(14),
                border: _pickerOpen ? Border.all(color: t.primary.withValues(alpha: 0.3)) : null,
              ),
              child: Builder(builder: (_) {
                final nodes = _flatNodes;
                _syncSelectedIndex(nodes);
                final selNode = nodes[_selectedFlatIndex];
                return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FlagBadge(selNode.flag, size: 28),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text(selNode.displayName,
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: t.textPrimary),
                      overflow: TextOverflow.ellipsis),
                  ),
                  const SizedBox(width: 8),
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: Builder(builder: (_) {
                      final pillResult = _testResults[_selectedFlatIndex];
                      final pillTesting = pillResult == '__testing__' || _testingNodeIndex == _selectedFlatIndex;
                      final pillHasResult = pillResult != null && pillResult != '__testing__';
                      final pillTimeout = pillHasResult && (pillResult == '超时' || pillResult == 'Timeout');
                      final pillText = pillHasResult ? pillResult! : (selNode.latency != null && selNode.latency! > 0 ? '${selNode.latency}ms' : (S.isEn ? 'Test' : '测速'));
                      // 从测试结果文本解析延迟值，确保颜色立即更新
                      int? effectiveDelay = selNode.latency;
                      if (pillHasResult && !pillTimeout) {
                        effectiveDelay = int.tryParse(pillResult!.replaceAll('ms', '')) ?? selNode.latency;
                      }
                      final pillColor = pillTimeout ? t.danger : _latencyColor(effectiveDelay);
                      return Container(
                        key: _pillLatencyKey,
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: pillColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: pillTesting
                            ? SizedBox(
                                width: 14, height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 1.5,
                                  color: t.textHint,
                                ),
                              )
                            : Text(
                                pillText,
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: pillColor),
                              ),
                      );
                    }),
                  ),
                  const SizedBox(width: 6),
                  AnimatedRotation(
                    turns: _pickerOpen ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(Icons.expand_more, size: 20, color: t.textHint),
                  ),
                ],
              );
              }),
            ),
          ),
          ),
          ),
          SizedBox(height: compact ? 8 : 16),

          // 代理模式选择: 规则 / 全局
          Container(
            key: _proxyModeKey,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: t.primary.withValues(alpha: t.isDark ? 0.08 : 0.04),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _proxyModeBtn(0, Icons.rule, S.ruleMode),
                const SizedBox(width: 3),
                _proxyModeBtn(1, Icons.public, S.globalMode),
                const SizedBox(width: 3),
                _proxyModeBtn(2, Icons.school, S.campusMode),
              ],
            ),
          ),
          const SizedBox(height: 4),
        ],
      );
      },
      ),
    );
  }

  Widget _proxyModeBtn(int mode, IconData icon, String label) {
    final isActive = _proxyMode == mode;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          if (widget.isGuest) {
            widget.onLogin?.call();
            return;
          }
          _setProxyMode(mode);
        },
        onLongPress: () => _showModeInfo(mode),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          gradient: isActive ? t.buttonGradient : null,
          color: isActive ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: isActive ? Colors.white : t.textSecondary),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(
              fontSize: 14, fontWeight: FontWeight.w600,
              color: isActive ? Colors.white : t.textSecondary,
            )),
          ],
        ),
      ),
    ),
    );
  }

  void _showModeInfo(int mode) {
    final config = _modeInfoConfig(mode);
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'close',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 220),
      transitionBuilder: (ctx, a1, a2, child) => Transform.scale(
        scale: Curves.easeOutBack.transform(a1.value),
        child: Opacity(opacity: a1.value, child: child),
      ),
      pageBuilder: (ctx, a1, a2) => Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: 400,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: t.cardBg,
              borderRadius: BorderRadius.circular(20),
              border: t.cardBorder,
              boxShadow: [BoxShadow(color: t.primary.withValues(alpha: 0.15), blurRadius: 30)],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        color: config.color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(config.icon, color: config.color, size: 20),
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: Text(config.title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: t.textPrimary))),
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () => Navigator.of(ctx).pop(),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(color: t.textHint.withValues(alpha: 0.1), shape: BoxShape.circle),
                          child: Icon(Icons.close, color: t.textHint, size: 18),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(config.desc, style: TextStyle(fontSize: 13, color: t.textSecondary, height: 1.5)),
                const SizedBox(height: 14),
                Text(config.featuresLabel, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: t.textPrimary)),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: t.isDark ? const Color(0xFF1E2140) : const Color(0xFFF5F7FA),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    config.features,
                    style: TextStyle(fontSize: 12, color: config.color, height: 1.6),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Icon(Icons.info_outline, size: 14, color: t.textHint),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        S.isEn ? 'Long press any mode button for details' : '长按任意模式按钮可查看说明',
                        style: TextStyle(fontSize: 11, color: t.textHint),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _ModeInfo _modeInfoConfig(int mode) {
    switch (mode) {
      case 0:
        return _ModeInfo(
          icon: Icons.rule,
          color: t.primary,
          title: S.ruleModeTitle,
          desc: S.ruleModeDesc,
          featuresLabel: S.ruleModeFeatures,
          features: S.isEn
              ? '• Domestic sites → Direct connection\n• Foreign/blocked sites → Proxy\n• Ad domains → Block\n• Private IPs → Direct'
              : '• 国内网站 → 直连访问\n• 海外/被屏蔽网站 → 代理转发\n• 广告域名 → 拦截\n• 内网 IP → 直连',
        );
      case 1:
        return _ModeInfo(
          icon: Icons.public,
          color: const Color(0xFFFF6B35),
          title: S.globalModeTitle,
          desc: S.globalModeDesc,
          featuresLabel: S.globalModeFeatures,
          features: S.isEn
              ? '• ALL traffic → Proxy server\n• Maximum privacy & encryption\n• Bypass geo-restrictions\n• May slow domestic access'
              : '• 所有流量 → 代理服务器\n• 最大化隐私与加密保护\n• 突破地域限制\n• 国内访问可能变慢',
        );
      case 2:
        return _ModeInfo(
          icon: Icons.school,
          color: const Color(0xFF00B4D8),
          title: S.campusModeTitle,
          desc: S.campusModeDesc,
          featuresLabel: S.isEn ? 'What it does:' : '实际操作：',
          features: S.isEn
              ? '• TUN mode → OFF (avoids portal conflicts)\n• System proxy → ON\n• Proxy mode → Rule (smart routing)\n• Campus domains (*.edu.cn etc.) → bypass proxy\n• Exit campus mode → restore TUN state'
              : '• TUN 模式 → 关闭（避免认证门户冲突）\n• 系统代理 → 开启\n• 代理模式 → 规则（智能分流）\n• 校园域名 (*.edu.cn 等) → 旁路直连\n• 退出校园网模式 → 自动恢复 TUN 设置',
        );
      default:
        return _ModeInfo(
          icon: Icons.rule,
          color: t.primary,
          title: S.ruleModeTitle,
          desc: S.ruleModeDesc,
          featuresLabel: S.ruleModeFeatures,
          features: S.isEn
              ? '• Domestic sites → Direct connection\n• Foreign/blocked sites → Proxy\n• Ad domains → Block\n• Private IPs → Direct'
              : '• 国内网站 → 直连访问\n• 海外/被屏蔽网站 → 代理转发\n• 广告域名 → 拦截\n• 内网 IP → 直连',
        );
    }
  }
}

class _ModeInfo {
  final IconData icon;
  final Color color;
  final String title, desc, featuresLabel, features;
  _ModeInfo({required this.icon, required this.color, required this.title, required this.desc, required this.featuresLabel, required this.features});
}

class _NodeGroup {
  final String flag;
  final String country;
  final List<_Node> nodes;
  _NodeGroup(this.flag, this.country, this.nodes);
}

class _Node {
  final String name;
  final int? latency;
  _Node(this.name, this.latency);
}

class _FlatNode {
  final String flag;
  final String country;
  final String nodeName;      // original proxy name (for testing/selection)
  final String displayName;   // resolved display name (e.g. "自动选择 · tokyo-01")
  final String groupName;     // parent group name (for proxyDelayTest)
  final String? testUrl;      // group test url
  final int? latency;
  _FlatNode(this.flag, this.country, this.nodeName, this.displayName, this.groupName, this.testUrl, this.latency);
}

class _NoticeItem {
  final String title;
  final String? url;
  final String? content;
  _NoticeItem(this.title, this.url, [this.content]);
}

String _colorToHex(Color color) {
  final argb = color.toARGB32();
  return '#${argb.toRadixString(16).substring(2)}';
}

class _ArrowUpPainter extends CustomPainter {
  final Color fillColor;
  final Color borderColor;
  _ArrowUpPainter({required this.fillColor, required this.borderColor});
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, size.height)
      ..lineTo(size.width / 2, 0)
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = borderColor);
    // 内部填充（缩小 1px 模拟边框）
    final inner = Path()
      ..moveTo(1.5, size.height)
      ..lineTo(size.width / 2, 2)
      ..lineTo(size.width - 1.5, size.height)
      ..close();
    canvas.drawPath(inner, Paint()..color = fillColor);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
