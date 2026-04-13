import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_clash/controller.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/xboard/features/auth/providers/xboard_user_provider.dart';
import 'package:fl_clash/xboard/domain/models/subscription.dart';
import 'package:fl_clash/xboard/features/profile/providers/profile_import_provider.dart';
import 'package:flutter_xboard_sdk/flutter_xboard_sdk.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/mihom_theme.dart';
import '../../widgets/login_dialog.dart';
import '../../i18n.dart';
import '../../widgets/pill_toast.dart';
import '../../widgets/flag_badge.dart';
import '../../pages/support_chat_page.dart';
import 'package:fl_clash/views/proxies/common.dart' as proxies_common;
import 'plans_page.dart';

class DemoHomePage extends ConsumerStatefulWidget {
  final MihomTheme theme;
  final VoidCallback? onOpenSettings;
  final bool isGuest;
  final VoidCallback? onLogin;
  // ── 外部连接状态 ──
  final bool connected;
  final DateTime? connectedAt;
  final int latency;
  final bool isTesting;
  final VoidCallback? onToggleConnection;
  final VoidCallback? onTestLatency;
  final VoidCallback? onTapNodeName;
  final VoidCallback? onPlanPurchased;
  final String selectedNodeLabel;
  const DemoHomePage({
    super.key, required this.theme, this.onOpenSettings,
    this.isGuest = true, this.onLogin,
    this.connected = false, this.connectedAt, this.latency = 0, this.isTesting = false,
    this.onToggleConnection, this.onTestLatency, this.onTapNodeName, this.onPlanPurchased,
    this.selectedNodeLabel = '',
  });

  @override
  ConsumerState<DemoHomePage> createState() => _DemoHomePageState();
}

class _DemoHomePageState extends ConsumerState<DemoHomePage> with TickerProviderStateMixin {
  Timer? _timer;
  String _elapsed = '00:00:00';
  bool _warningsDismissed = false;

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
      case Mode.direct: return 0;
    }
  }

  void _setProxyMode(int modeIndex) {
    final bool wasCampus = _isCampusMode;
    switch (modeIndex) {
      case 2:
        // ── 校园网模式 ──
        // 1. 记住当前 TUN 状态
        _tunBeforeCampus ??= ref.read(patchClashConfigProvider).tun.enable;
        _isCampusMode = true;
        // 2. 切到规则模式
        appController.changeMode(Mode.rule);
        // 3. 关闭 TUN（避免校园门户认证被拦截）
        ref.read(patchClashConfigProvider.notifier).update(
          (state) => state.copyWith.tun(enable: false),
        );
        // 4. 确保系统代理开启
        ref.read(networkSettingProvider.notifier).update(
          (state) => state.copyWith(systemProxy: true),
        );
        // 5. 追加校园直连域名到系统代理旁路列表
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
    // 恢复 TUN 到校园网模式前的状态
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

  // 公告数据
  List<_NoticeData> _notices = [];
  bool _noticesLoaded = false;

  // 首次引导气泡
  bool _guideShown = false;
  OverlayEntry? _guideOverlay;
  final GlobalKey _proxyModeKey = GlobalKey();

  // ── 节点选择器 (药丸 + 浮层) ──
  bool _pickerOpen = false;
  OverlayEntry? _pickerOverlay;
  final LayerLink _pickerLink = LayerLink();
  final GlobalKey _pillKey = GlobalKey();
  int _selectedFlatIndex = 0;
  bool _isSyncing = false;
  bool _isTestingAll = false;
  final Set<int> _testingNodeIndices = {};
  bool _autoTestTriggered = false;
  int _pendingAutoTestIndex = -1;
  Timer? _autoTestRetryTimer;

  // ── 核心健康检查 ──
  Timer? _coreHealthTimer;
  bool _coreRestarting = false;

  // ── 连接过渡动画控制器 ──
  late AnimationController _connectController;
  late Animation<double> _connectFade;
  late Animation<double> _connectScale;

  // ── 呼吸脉冲（已连接） ──
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  // ── 悬浮动画（未连接） ──
  late AnimationController _floatController;
  late Animation<double> _floatAnim;

  MihomTheme get t => widget.theme;
  bool get _connected => widget.connected;

  @override
  void initState() {
    super.initState();

    _connectController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _connectFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _connectController, curve: const Interval(0.0, 0.5, curve: Curves.easeOut)),
    );
    _connectScale = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _connectController, curve: const Interval(0.1, 0.7, curve: Curves.easeOutCubic)),
    );
    _connectController.value = 1.0;

    _pulseController = AnimationController(duration: const Duration(milliseconds: 2500), vsync: this);
    _pulseAnim = Tween<double>(begin: 0.98, end: 1.02).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _floatController = AnimationController(duration: const Duration(milliseconds: 3000), vsync: this);
    _floatAnim = Tween<double>(begin: -6.0, end: 6.0).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    // 根据初始连接状态设置动画
    _syncAnimations(widget.connected, initial: true);
    // 恢复校园网模式状态
    SharedPreferences.getInstance().then((prefs) {
      if (!mounted) return;
      final campus = prefs.getBool('campus_mode_enabled') ?? false;
      if (campus) setState(() => _isCampusMode = true);
    });
    // 首次引导气泡延迟显示（仅首次）
    SharedPreferences.getInstance().then((prefs) {
      if (!mounted) return;
      if (prefs.getBool('mobile_guide_shown') == true) {
        _guideShown = true;
        return;
      }
      Future.delayed(const Duration(milliseconds: 1200), () {
        if (mounted && !_guideShown) _showGuideBubble();
      });
    });
    // Fetch notices from API
    _fetchNotices();
    // 启动核心健康检查定时器
    _coreHealthTimer = Timer.periodic(const Duration(seconds: 10), (_) => _checkCoreHealth());
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
    // 延迟重试自动选择节点测速（等待URLTest核心解析now字段）
    _autoTestRetryTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (!mounted) { timer.cancel(); return; }
      // 如果尚未触发自动测速，尝试从当前节点列表中找到被选中的节点
      if (!_autoTestTriggered && _pendingAutoTestIndex < 0) {
        final nodes = _buildFlatNodes();
        final selIdx = nodes.indexWhere((n) => n.isSelected);
        if (selIdx >= 0) {
          final sel = nodes[selIdx];
          // 只在没有延迟数据时触发自动测速
          if (sel.delay == null || sel.delay! <= 0) {
            _pendingAutoTestIndex = selIdx;
          }
        }
      }
      if (_pendingAutoTestIndex >= 0 && !_autoTestTriggered) {
        _autoTestTriggered = true;
        final idx = _pendingAutoTestIndex;
        _pendingAutoTestIndex = -1;
        final nodes = _buildFlatNodes();
        if (idx < nodes.length) {
          _handleTestSingleNode(idx, nodes);
        }
        timer.cancel();
        return;
      }
      if (_autoTestTriggered) { timer.cancel(); return; }
      if (mounted) setState(() {});
      if (timer.tick >= 15) timer.cancel();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _coreHealthTimer?.cancel();
    _autoTestRetryTimer?.cancel();
    _removePickerOverlay();
    _guideOverlay?.remove();
    _connectController.dispose();
    _pulseController.dispose();
    _floatController.dispose();
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

  @override
  void didUpdateWidget(covariant DemoHomePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.connected != widget.connected) {
      _syncAnimations(widget.connected, initial: false);
    }
    // 管理计时器
    if (widget.connected && widget.connectedAt != null) {
      _startTimer();
    } else {
      _stopTimer();
    }
  }

  void _syncAnimations(bool connected, {required bool initial}) {
    if (!initial) {
      _connectController.reset();
      _connectController.forward();
    } else {
      _connectController.value = 1.0;
    }
    if (connected) {
      _pulseController.repeat(reverse: true);
      _floatController.stop();
      _startTimer();
    } else {
      _pulseController.stop();
      _pulseController.reset();
      _floatController.repeat(reverse: true);
      _stopTimer();
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _updateElapsed();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateElapsed());
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
    if (mounted) setState(() => _elapsed = '00:00:00');
  }

  void _updateElapsed() {
    if (!mounted || widget.connectedAt == null) return;
    final d = DateTime.now().difference(widget.connectedAt!);
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    setState(() => _elapsed = '$h:$m:$s');
  }

  void _showGuideBubble() {
    _guideShown = true;
    final renderBox = _proxyModeKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    final pos = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    _guideOverlay = OverlayEntry(
      builder: (ctx) {
        final bubbleW = 240.0;
        final bubbleLeft = pos.dx + (size.width - bubbleW) / 2;
        final bubbleTop = pos.dy + size.height + 4;
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: _dismissGuide,
                behavior: HitTestBehavior.translucent,
                child: const SizedBox.expand(),
              ),
            ),
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
                      size: const Size(16, 8),
                      painter: _ArrowUpPainter(
                        fillColor: t.isDark ? const Color(0xFF2A2A3E) : Colors.white,
                        borderColor: t.primary.withValues(alpha: 0.3),
                      ),
                    ),
                    Container(
                      width: bubbleW,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
                          Icon(Icons.touch_app, size: 16, color: t.primary),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              S.isEn ? 'Long press for details' : '长按可查看详细说明',
                              style: TextStyle(fontSize: 12, color: t.textPrimary, fontWeight: FontWeight.w500),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            S.isEn ? 'OK' : '知道了',
                            style: TextStyle(fontSize: 11, color: t.primary, fontWeight: FontWeight.w600),
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
      prefs.setBool('mobile_guide_shown', true);
    });
  }

  Future<void> _fetchNotices() async {
    if (_noticesLoaded) return;
    try {
      final notices = widget.isGuest
          ? await XBoardSDK.instance.notice.getGuestNotices(pageSize: 20)
          : await XBoardSDK.instance.notice.getNotices(pageSize: 20);
      if (!mounted) return;
      final visibleNotices = notices.where((n) => n.show).toList();
      setState(() {
        _notices = visibleNotices.map((n) => _NoticeData(n.title, n.content)).toList();
        _noticesLoaded = true;
      });
    } catch (_) {
      if (mounted) setState(() => _noticesLoaded = true);
    }
  }

  void _showNoticeDialog() {
    HapticFeedback.lightImpact();
    // Fetch notices if not yet loaded
    if (!_noticesLoaded) _fetchNotices();
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '关闭',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      transitionBuilder: (ctx, a1, a2, child) {
        return Transform.scale(
          scale: Curves.easeOutBack.transform(a1.value),
          child: Opacity(opacity: a1.value, child: child),
        );
      },
      pageBuilder: (ctx, a1, a2) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: MediaQuery.of(ctx).size.width * 0.85,
              constraints: const BoxConstraints(maxHeight: 500),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: t.cardBg,
                borderRadius: BorderRadius.circular(24),
                border: t.cardBorder,
                boxShadow: [BoxShadow(color: t.primary.withValues(alpha: 0.15), blurRadius: 40)],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: t.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.campaign, color: t.primary, size: 20),
                      ),
                      const SizedBox(width: 10),
                      Text(S.systemNotice, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: t.textPrimary)),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => Navigator.of(ctx).pop(),
                        child: Icon(Icons.close, color: t.textHint, size: 20),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Flexible(
                    child: _notices.isEmpty
                        ? Center(
                            child: Text(
                              S.isEn ? 'No announcements' : '暂无公告',
                              style: TextStyle(fontSize: 14, color: t.textHint),
                            ),
                          )
                        : SingleChildScrollView(
                            child: Column(
                              children: _notices.map((n) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: t.isDark ? const Color(0xFF1C1F3A) : const Color(0xFFF7F8FC),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              width: 4, height: 16,
                                              decoration: BoxDecoration(
                                                color: t.primary,
                                                borderRadius: BorderRadius.circular(2),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(n.title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: t.textPrimary)),
                                            ),
                                          ],
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 10),
                                          child: Divider(height: 1, color: t.textHint.withValues(alpha: 0.12)),
                                        ),
                                        Builder(builder: (_) {
                                          final isHtml = RegExp(r'<(p|div|span|br|a|ul|ol|li|h[1-6]|img|table|strong|em|b|i)\b').hasMatch(n.content);
                                          if (isHtml) {
                                            return HtmlWidget(n.content, textStyle: TextStyle(fontSize: 13, color: t.textSecondary, height: 1.4));
                                          }
                                          return MarkdownBody(
                                            data: n.content,
                                            selectable: true,
                                            styleSheet: MarkdownStyleSheet(
                                              p: TextStyle(fontSize: 13, color: t.textSecondary, height: 1.4),
                                              strong: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: t.textPrimary),
                                              a: TextStyle(fontSize: 13, color: t.primary, decoration: TextDecoration.underline),
                                              listBullet: TextStyle(fontSize: 13, color: t.textSecondary),
                                            ),
                                            onTapLink: (text, href, title) {
                                              if (href != null) launchUrl(Uri.parse(href));
                                            },
                                          );
                                        }),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _noticeItem(String title, String content, String time, bool unread) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: t.isDark ? const Color(0xFF1C1F3A) : const Color(0xFFF7F8FC),
        borderRadius: BorderRadius.circular(14),
        border: unread ? Border.all(color: t.primary.withValues(alpha: 0.2), width: 1) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (unread)
                Container(
                  width: 7, height: 7,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(shape: BoxShape.circle, color: t.danger),
                ),
              Expanded(child: Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: t.textPrimary))),
              Text(time, style: TextStyle(fontSize: 11, color: t.textHint)),
            ],
          ),
          const SizedBox(height: 6),
          Text(content, style: TextStyle(fontSize: 13, color: t.textSecondary, height: 1.4)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ── 读取 TUN 和核心状态 ──
    final tunEnabled = ref.watch(patchClashConfigProvider.select((s) => s.tun.enable));
    final coreStatus = ref.watch(coreStatusProvider);
    // ── 构建节点列表 ──
    final nodeList = _buildFlatNodes();

    return SafeArea(
      child: Stack(
        children: [
          // ── 主内容 ──
          Column(
            children: [
              // ── Header: 品牌 + 公告 + 设置 ──
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: Row(
                  children: [
                    Container(
                      width: 32, height: 32,
                      decoration: BoxDecoration(gradient: t.primaryGradient, borderRadius: BorderRadius.circular(9)),
                      child: Padding(
                        padding: const EdgeInsets.all(3),
                        child: Image.asset('assets/branding/icon_white.png', fit: BoxFit.contain),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('无界', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: t.textPrimary)),
                    const Spacer(),
                    // 公告铃铛
                    GestureDetector(
                      onTap: _showNoticeDialog,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: t.cardBg, borderRadius: BorderRadius.circular(10),
                          border: t.cardBorder,
                        ),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Icon(Icons.notifications_outlined, color: t.textSecondary, size: 18),
                            if (_notices.isNotEmpty)
                              Positioned(
                                top: -2, right: -2,
                                child: Container(
                                  width: 7, height: 7,
                                  decoration: BoxDecoration(
                                    color: t.danger, shape: BoxShape.circle,
                                    border: Border.all(color: t.cardBg, width: 1),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    // 在线客服
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        if (widget.isGuest) {
                          showPillToast(context, t, '${S.onlineSupport} · ${S.loginFirst}');
                          return;
                        }
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => SupportChatPage(theme: t)),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: t.cardBg, borderRadius: BorderRadius.circular(10),
                          border: t.cardBorder,
                        ),
                        child: Icon(Icons.headset_mic_outlined, color: t.textSecondary, size: 18),
                      ),
                    ),
                    const SizedBox(width: 6),
                    // 设置齿轮
                    GestureDetector(
                      onTap: widget.onOpenSettings,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: t.cardBg, borderRadius: BorderRadius.circular(10),
                          border: t.cardBorder,
                        ),
                        child: Icon(Icons.settings_outlined, color: t.textSecondary, size: 18),
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(flex: 2),

              // ── 连接按钮 (居中, 140x140) ──
              AnimatedBuilder(
                animation: Listenable.merge([_pulseAnim, _floatAnim, _connectScale, _connectFade]),
                builder: (context, child) {
                  final scale = _connected
                      ? _pulseAnim.value * _connectScale.value
                      : _connectScale.value;
                  final translateY = _connected ? 0.0 : _floatAnim.value;
                  return Transform.translate(
                    offset: Offset(0, translateY),
                    child: Transform.scale(
                      scale: scale,
                      child: Opacity(
                        opacity: _connectFade.value.clamp(0.3, 1.0),
                        child: child,
                      ),
                    ),
                  );
                },
                child: GestureDetector(
                  onTap: () => widget.onToggleConnection?.call(),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 700),
                    curve: Curves.easeOutCubic,
                    width: 140, height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: _connected ? t.connectedGradient : t.disconnectedGradient,
                      boxShadow: [
                        BoxShadow(
                          color: (_connected ? t.connectedGlow : t.disconnectedGlow).withValues(alpha: 0.3),
                          blurRadius: 30, spreadRadius: 3,
                        ),
                      ],
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 450),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeIn,
                      transitionBuilder: (child, animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: ScaleTransition(
                            scale: Tween<double>(begin: 0.7, end: 1.0).animate(
                              CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
                            ),
                            child: child,
                          ),
                        );
                      },
                      child: Column(
                        key: ValueKey(_connected),
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _connected
                              ? Image.asset('assets/branding/icon_white.png', width: 40, height: 40)
                              : const Icon(Icons.power_settings_new, size: 40, color: Colors.white),
                          const SizedBox(height: 6),
                          Text(
                            _connected ? S.protected_ : S.tapToConnect,
                            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ── 状态文字 (连接时间 + 当前节点 + 延迟) ──
              AnimatedBuilder(
                animation: _connectController,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: CurvedAnimation(
                      parent: _connectController,
                      curve: const Interval(0.3, 0.8, curve: Curves.easeOut),
                    ),
                    child: SlideTransition(
                      position: Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
                        CurvedAnimation(parent: _connectController, curve: const Interval(0.3, 0.8, curve: Curves.easeOutCubic)),
                      ),
                      child: child,
                    ),
                  );
                },
                child: _connected
                    ? Column(
                        key: const ValueKey('status_on'),
                        children: [
                          Text('${S.connectionTime} $_elapsed', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: t.textPrimary)),
                        ],
                      )
                    : const SizedBox.shrink(key: ValueKey('status_off')),
              ),

              const SizedBox(height: 16),

              // ── 节点选择器 (药丸 + 浮层上拉, 桌面版风格) ──
              if (nodeList.isNotEmpty)
                CompositedTransformTarget(
                  link: _pickerLink,
                  child: GestureDetector(
                    key: _pillKey,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      _toggleNodePicker();
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 40),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: t.primary.withValues(alpha: t.isDark ? 0.08 : 0.04),
                        borderRadius: BorderRadius.circular(14),
                        border: _pickerOpen
                            ? Border.all(color: t.primary.withValues(alpha: 0.5), width: 1.5)
                            : Border.all(color: t.primary.withValues(alpha: 0.1)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Builder(builder: (_) {
                            final sel = nodeList.where((n) => n.isSelected).firstOrNull ?? (nodeList.isNotEmpty ? nodeList.first : null);
                            if (sel == null || sel.flag == '--') return const SizedBox.shrink();
                            return Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: FlagBadge(sel.flag, size: 22),
                            );
                          }),
                          Flexible(
                            child: Text(
                              _currentNodeLabel(nodeList),
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: t.textPrimary),
                              maxLines: 1, overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Builder(builder: (_) {
                            final nodes = nodeList;
                            final selIdx = nodes.indexWhere((n) => n.isSelected);
                            final delay = _currentNodeDelay(nodes);
                            final hasDelay = delay != null;
                            final isTimeout = hasDelay && delay <= 0;
                            final color = !hasDelay ? t.primary : (isTimeout ? t.danger : _latencyColor(delay));
                            final text = !hasDelay ? (S.isEn ? 'Test' : '测速') : (isTimeout ? (S.isEn ? 'Timeout' : '超时') : '${delay}ms');
                            final isTesting = selIdx >= 0 && _testingNodeIndices.contains(selIdx);
                            return GestureDetector(
                              onTap: () {
                                HapticFeedback.lightImpact();
                                if (selIdx >= 0) _handleTestSingleNode(selIdx, nodes);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: isTesting
                                    ? SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 1.5, color: color))
                                    : Row(mainAxisSize: MainAxisSize.min, children: [
                                        Container(width: 5, height: 5, decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
                                        const SizedBox(width: 3),
                                        Text(text, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: color)),
                                      ]),
                              ),
                            );
                          }),
                          const SizedBox(width: 4),
                          AnimatedRotation(
                            turns: _pickerOpen ? 0.5 : 0,
                            duration: const Duration(milliseconds: 200),
                            child: Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: t.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: 12),

              // ── 代理模式选择 (节点选择器下方) ──
              Container(
                key: _proxyModeKey,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: t.primary.withValues(alpha: t.isDark ? 0.08 : 0.04),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _proxyModeBtn(0, Icons.rule, S.ruleMode),
                    const SizedBox(width: 2),
                    _proxyModeBtn(1, Icons.public, S.globalMode),
                    const SizedBox(width: 2),
                    _proxyModeBtn(2, Icons.school, S.campusMode),
                  ],
                ),
              ),

              const Spacer(flex: 1),

              // 给悬浮药丸导航留出空间
              const SizedBox(height: 80),
            ],
          ), // Column

          // ── 核心状态 + TUN 开关 (右上角, 设置按钮下方) ──
          if (!widget.isGuest)
          Positioned(
            right: 20,
            top: 58,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                // 核心状态
                Builder(builder: (_) {
                  final Color dotColor;
                  final String label;
                  switch (coreStatus) {
                    case CoreStatus.connected:
                      dotColor = t.success;
                      label = S.isEn ? 'Core: ON' : '核心: 运行中';
                    case CoreStatus.connecting:
                      dotColor = t.warning;
                      label = S.isEn ? 'Core: Starting' : '核心: 启动中';
                    case CoreStatus.disconnected:
                      dotColor = t.danger;
                      label = S.isEn ? 'Core: OFF' : '核心: 未启动';
                  }
                  return GestureDetector(
                    onTap: () {
                      if (_coreRestarting) return;
                      HapticFeedback.lightImpact();
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: Text(
                            S.isEn ? 'Restart Core' : '重启核心',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: t.textPrimary),
                          ),
                          content: Text(
                            S.isEn
                                ? 'This will force restart the proxy core. The network may be briefly interrupted.'
                                : '将强制重启代理核心，网络可能会短暂中断。',
                            style: TextStyle(fontSize: 14, color: t.textSecondary),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: Text(S.isEn ? 'Cancel' : '取消', style: TextStyle(color: t.textHint)),
                            ),
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
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: dotColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6, height: 6,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: dotColor,
                              boxShadow: [BoxShadow(color: dotColor.withValues(alpha: 0.4), blurRadius: 3)],
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: dotColor)),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 6),
                // TUN 开关
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    // 校园网模式下禁止开启 TUN
                    if (_isCampusMode) {
                      showPillToast(context, t, S.isEn ? 'TUN is disabled in campus mode' : '校园网模式下 TUN 已禁用，请先切换到规则/全局模式');
                      return;
                    }
                    if (tunEnabled) {
                      // 关闭 TUN 时弹窗提醒
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: Text('关闭 TUN 模式', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: t.textPrimary)),
                          content: Text(
                            'TUN 模式可以接管设备全部流量，确保所有应用都通过代理连接。\n\n'
                            '关闭后部分应用可能无法正常使用代理，建议保持开启。',
                            style: TextStyle(fontSize: 14, color: t.textSecondary),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: Text('保持开启', style: TextStyle(color: t.primary, fontWeight: FontWeight.w600)),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(ctx);
                                ref.read(patchClashConfigProvider.notifier).update(
                                  (state) => state.copyWith.tun(enable: false),
                                );
                              },
                              child: Text('仍然关闭', style: TextStyle(color: t.textHint)),
                            ),
                          ],
                        ),
                      );
                    } else {
                      ref.read(patchClashConfigProvider.notifier).update(
                        (state) => state.copyWith.tun(enable: true),
                      );
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: tunEnabled ? t.primary.withValues(alpha: 0.12) : t.textHint.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: tunEnabled ? t.primary.withValues(alpha: 0.3) : Colors.transparent),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(tunEnabled ? Icons.shield : Icons.shield_outlined, size: 12, color: tunEnabled ? t.primary : t.textHint),
                        const SizedBox(width: 3),
                        Text('TUN', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600,
                            color: tunEnabled ? t.primary : t.textHint)),
                        const SizedBox(width: 4),
                        Container(
                          width: 24, height: 14,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(7),
                            color: tunEnabled ? t.success : t.textHint.withValues(alpha: 0.3),
                          ),
                          child: AnimatedAlign(
                            alignment: tunEnabled ? Alignment.centerRight : Alignment.centerLeft,
                            duration: const Duration(milliseconds: 200),
                            child: Container(
                              width: 10, height: 10,
                              margin: const EdgeInsets.symmetric(horizontal: 2),
                              decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── 悬浮警告横幅（顶部浮层，可收起） ──
          if (!widget.isGuest && !_warningsDismissed)
            Positioned(
              top: 60,
              left: 20,
              right: 20,
              child: Builder(builder: (_) {
                final user = ref.watch(userInfoProvider);
                final sub = ref.watch(subscriptionInfoProvider);
                final warnings = <Widget>[];

                // Check expired
                final bool isExpired = user?.isExpired ?? false;
                if (isExpired) {
                  warnings.add(_warningBanner(
                    icon: Icons.access_time_rounded,
                    color: t.danger,
                    text: S.isEn ? 'Plan expired, please renew' : '\u5957\u9910\u5df2\u8fc7\u671f\uff0c\u8bf7\u7eed\u8d39',
                    actionText: S.renew,
                    onAction: () => _openPlans(),
                  ));
                }

                // Check traffic exhausted
                final bool isTrafficExhausted = sub?.isTrafficExhausted ?? false;
                if (isTrafficExhausted) {
                  if (warnings.isNotEmpty) warnings.add(const SizedBox(height: 6));
                  warnings.add(_warningBanner(
                    icon: Icons.data_usage_rounded,
                    color: t.danger,
                    text: S.isEn ? 'Traffic exhausted' : '\u6d41\u91cf\u5df2\u7528\u5b8c',
                    actionText: S.upgrade,
                    onAction: () => _openPlans(),
                  ));
                }

                // Check plan expiry (within 7 days)
                if (!isExpired) {
                final expiresAt = user?.expiredAt ?? sub?.expiredAt;
                if (expiresAt != null) {
                  final daysLeft = expiresAt.difference(DateTime.now()).inDays;
                  if (daysLeft <= 7 && daysLeft >= 0) {
                    if (warnings.isNotEmpty) warnings.add(const SizedBox(height: 6));
                    warnings.add(_warningBanner(
                      icon: Icons.timer_outlined,
                      color: t.warning,
                      text: S.planExpirySoon,
                      actionText: S.renew,
                      onAction: () => _openPlans(),
                    ));
                  }
                }
                }

                // Check traffic usage (>= 85%)
                if (!isTrafficExhausted) {
                final totalBytes = sub?.transferLimit ?? user?.transferLimit ?? 0;
                final usedBytes = (sub?.uploadedBytes ?? 0) + (sub?.downloadedBytes ?? 0);
                if (totalBytes > 0) {
                  final usageRatio = usedBytes / totalBytes;
                  if (usageRatio >= 0.85) {
                    if (warnings.isNotEmpty) warnings.add(const SizedBox(height: 6));
                    warnings.add(_warningBanner(
                      icon: Icons.data_usage,
                      color: t.warning,
                      text: S.trafficUsed85,
                      actionText: S.upgrade,
                      onAction: () => _openPlans(),
                    ));
                  }
                }
                }

                if (warnings.isEmpty) return const SizedBox.shrink();
                return Column(children: warnings);
              }),
            ),
        ],
      ), // Stack
    );
  }

  void _openPlans() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (ctx, a1, a2) => DemoPlansPage(theme: t, isGuest: widget.isGuest, onLogin: widget.onLogin),
        transitionsBuilder: (ctx, a1, a2, child) => SlideTransition(
          position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
              .animate(CurvedAnimation(parent: a1, curve: Curves.easeOutCubic)),
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 300),
      ),
    ).then((result) {
      if (result == true) widget.onPlanPurchased?.call();
    });
  }

  Widget _warningBanner({
    required IconData icon,
    required Color color,
    required String text,
    required String actionText,
    required VoidCallback onAction,
    bool showClose = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: (t.isDark ? const Color(0xFF1A1D35) : Colors.white).withValues(alpha: 0.97),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.25)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: TextStyle(fontSize: 13, color: t.textPrimary, fontWeight: FontWeight.w500))),
          GestureDetector(
            onTap: onAction,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                gradient: t.buttonGradient,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(actionText, style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => setState(() => _warningsDismissed = true),
            child: Icon(Icons.close, size: 16, color: t.textHint),
          ),
        ],
      ),
    );
  }

  Widget _proxyModeBtn(int mode, IconData icon, String label) {
    final isActive = _proxyMode == mode;
    return GestureDetector(
      onTap: () {
        if (widget.isGuest) {
          widget.onLogin?.call();
          return;
        }
        HapticFeedback.mediumImpact();
        _setProxyMode(mode);
      },
      onLongPress: () => _showModeInfo(mode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          gradient: isActive ? t.buttonGradient : null,
          color: isActive ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: isActive ? Colors.white : t.textSecondary),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isActive ? Colors.white : t.textSecondary)),
          ],
        ),
      ),
    );
  }

  void _showModeInfo(int mode) {
    HapticFeedback.mediumImpact();
    final info = _modeInfoConfig(mode);
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
            width: MediaQuery.of(ctx).size.width * 0.85,
            constraints: const BoxConstraints(maxWidth: 360),
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
                      decoration: BoxDecoration(color: info.color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
                      child: Icon(info.icon, color: info.color, size: 20),
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: Text(info.title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: t.textPrimary))),
                    GestureDetector(
                      onTap: () => Navigator.of(ctx).pop(),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(color: t.textHint.withValues(alpha: 0.1), shape: BoxShape.circle),
                        child: Icon(Icons.close, color: t.textHint, size: 18),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(info.desc, style: TextStyle(fontSize: 13, color: t.textSecondary, height: 1.5)),
                const SizedBox(height: 14),
                Text(info.featuresLabel, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: t.textPrimary)),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: t.isDark ? const Color(0xFF1E2140) : const Color(0xFFF5F7FA),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: info.features.map((f) => Padding(
                      padding: const EdgeInsets.only(bottom: 3),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('•  ', style: TextStyle(color: info.color, fontSize: 12)),
                          Expanded(child: Text(f, style: TextStyle(fontSize: 12, color: t.textSecondary, height: 1.4))),
                        ],
                      ),
                    )).toList(),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Icon(Icons.info_outline, size: 14, color: t.textHint),
                    const SizedBox(width: 6),
                    Expanded(child: Text(S.isEn ? 'Long press mode button for this info' : '长按模式按钮可查看此说明', style: TextStyle(fontSize: 11, color: t.textHint))),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  ({IconData icon, Color color, String title, String desc, String featuresLabel, List<String> features}) _modeInfoConfig(int mode) {
    switch (mode) {
      case 0:
        return (
          icon: Icons.alt_route,
          color: t.primary,
          title: S.ruleModeTitle,
          desc: S.ruleModeDesc,
          featuresLabel: S.ruleModeFeatures,
          features: S.isEn
              ? ['Domestic sites → Direct connection (fast)', 'Blocked/foreign sites → Proxy tunnel', 'Ad & tracker domains → Auto blocked', 'Custom rules supported']
              : ['国内网站 → 直连访问（高速）', '被墙/海外网站 → 代理隧道', '广告/追踪域名 → 自动拦截', '支持自定义分流规则'],
        );
      case 1:
        return (
          icon: Icons.public,
          color: const Color(0xFFFF6B35),
          title: S.globalModeTitle,
          desc: S.globalModeDesc,
          featuresLabel: S.globalModeFeatures,
          features: S.isEn
              ? ['100% traffic through proxy', 'Maximum privacy & encryption', 'No DNS leaks', 'May slow domestic access']
              : ['100% 流量经过代理', '最大隐私保护与加密', '无 DNS 泄露风险', '国内访问速度可能下降'],
        );
      case 2:
        return (
          icon: Icons.school,
          color: const Color(0xFF00B4D8),
          title: S.campusModeTitle,
          desc: S.campusModeDesc,
          featuresLabel: S.isEn ? 'What it does:' : '实际操作：',
          features: S.isEn
              ? ['TUN mode → OFF (avoids portal conflicts)', 'System proxy → ON', 'Proxy mode → Rule (smart routing)', 'Campus domains (*.edu.cn etc.) → bypass proxy', 'Exit campus mode → restore TUN state']
              : ['TUN 模式 → 关闭（避免认证门户冲突）', '系统代理 → 开启', '代理模式 → 规则（智能分流）', '校园域名 (*.edu.cn 等) → 旁路直连', '退出校园网模式 → 自动恢复 TUN 设置'],
        );
      default:
        return (
          icon: Icons.rule,
          color: t.primary,
          title: S.ruleModeTitle,
          desc: S.ruleModeDesc,
          featuresLabel: S.ruleModeFeatures,
          features: S.isEn
              ? ['Domestic sites → Direct connection (fast)', 'Blocked/foreign sites → Proxy tunnel', 'Ad & tracker domains → Auto blocked', 'Custom rules supported']
              : ['国内网站 → 直连访问（高速）', '被墙/海外网站 → 代理隧道', '广告/追踪域名 → 自动拦截', '支持自定义分流规则'],
        );
    }
  }

  // ───────────── 节点选择器浮层 ─────────────

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

  void _syncSelectedIndex(List<_SimpleNode> nodes) {
    if (nodes.isEmpty || nodes.first.groupName.isEmpty) {
      _selectedFlatIndex = 0;
      return;
    }
    if (_selectedFlatIndex >= nodes.length) _selectedFlatIndex = 0;

    // isSelected is already resolved to the real node in _buildFlatNodes
    final idx = nodes.indexWhere((n) => n.isSelected);
    if (idx >= 0) {
      _selectedFlatIndex = idx;
      if (!_autoTestTriggered) {
        _pendingAutoTestIndex = idx;
      }
    }
  }

  Color _latencyColor(int? delay) {
    if (delay == null || delay <= 0) return t.textHint;
    if (delay < 600) return t.success;
    return t.warning;
  }

  void _showPickerOverlay() {
    final renderBox = _pillKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    setState(() => _pickerOpen = true);

    _pickerOverlay = OverlayEntry(
      builder: (ctx) {
        final rb = _pillKey.currentContext?.findRenderObject() as RenderBox?;
        if (rb == null || !rb.attached) return const SizedBox.shrink();
        final pillSize = rb.size;
        final pillPos = rb.localToGlobal(Offset.zero);
        final screenW = MediaQuery.of(context).size.width;

        final nodes = _buildFlatNodes();
        _syncSelectedIndex(nodes);
        const itemH = 52.0;
        const toolbarH = 40.0;
        final listContentH = nodes.length * itemH;
        // 向上展开
        final spaceAbove = pillPos.dy - MediaQuery.of(context).padding.top - 10;
        final maxListH = spaceAbove.clamp(120.0, 350.0) - toolbarH;
        final listH = listContentH.clamp(48.0, maxListH);
        // pillSize.width 包含 Container 两侧各 40dp 的 margin，需减去才是药丸视觉宽度
        final dropW = (pillSize.width - 80).clamp(240.0, screenW - 80);

        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: _removePickerOverlay,
                behavior: HitTestBehavior.translucent,
                child: const SizedBox.expand(),
              ),
            ),
            CompositedTransformFollower(
              link: _pickerLink,
              targetAnchor: Alignment.topCenter,
              followerAnchor: Alignment.bottomCenter,
              offset: const Offset(0, -6),
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: dropW,
                  constraints: BoxConstraints(maxHeight: listH + toolbarH + 8),
                  decoration: BoxDecoration(
                    color: t.cardBg,
                    borderRadius: BorderRadius.circular(14),
                    border: t.cardBorder ?? Border.all(color: t.textHint.withValues(alpha: 0.1)),
                    boxShadow: [
                      BoxShadow(color: t.primary.withValues(alpha: 0.1), blurRadius: 20),
                      BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 12, offset: const Offset(0, -4)),
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
                                label: S.isEn ? 'Sync' : '更新',
                                loading: _isSyncing,
                                onTap: _handleSyncSubscription,
                              ),
                              const SizedBox(width: 8),
                              _toolbarBtn(
                                icon: Icons.speed,
                                label: S.isEn ? 'Test' : '测速',
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
                              final delay = n.delay;
                              final isTimeout = delay != null && delay <= 0;
                              final delayText = delay == null
                                  ? (S.isEn ? 'Test' : '测速')
                                  : (isTimeout ? (S.isEn ? 'Timeout' : '超时') : '${delay}ms');
                              final delayColor = isTimeout ? t.danger : _latencyColor(delay);
                              return GestureDetector(
                                onTap: () {
                                  if (n.groupName.isEmpty) return;
                                  setState(() => _selectedFlatIndex = i);
                                  appController.updateCurrentSelectedMap(n.groupName, n.proxyName);
                                  appController.changeProxy(groupName: n.groupName, proxyName: n.proxyName);
                                  _removePickerOverlay();
                                  // 选择节点后自动测速
                                  Future.delayed(const Duration(milliseconds: 300), () {
                                    if (mounted) _handleTestSingleNode(i, _buildFlatNodes());
                                  });
                                },
                                child: Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
                                  decoration: BoxDecoration(
                                    gradient: isSel ? t.buttonGradient : null,
                                    color: isSel ? null : Colors.transparent,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    children: [
                                      FlagBadge(n.flag, size: 26),
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
                                      GestureDetector(
                                        onTap: () {
                                          HapticFeedback.lightImpact();
                                          _handleTestSingleNode(i, nodes);
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: delayColor.withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: _testingNodeIndices.contains(i)
                                              ? SizedBox(
                                                  width: 12, height: 12,
                                                  child: CircularProgressIndicator(
                                                    strokeWidth: 1.5,
                                                    color: isSel ? Colors.white70 : t.primary,
                                                  ),
                                                )
                                              : Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Container(
                                                      width: 5, height: 5,
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color: isSel ? Colors.white70 : delayColor,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Text(delayText, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500,
                                                        color: isSel ? Colors.white70 : delayColor)),
                                                  ],
                                                ),
                                        ),
                                      ),
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

  // ───────────── 节点列表辅助方法 ─────────────

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

  static String _extractFlag(String name) {
    final lower = name.toLowerCase();
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

  void _rebuildOverlay() {
    _pickerOverlay?.markNeedsBuild();
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

  Future<void> _handleSyncSubscription() async {
    if (_isSyncing) return;
    final wasConnected = widget.connected;
    setState(() => _isSyncing = true);
    _rebuildOverlay();
    final dismissSyncing = showPillToast(context, t, S.isEn ? 'Updating subscription...' : '正在更新订阅...', duration: const Duration(seconds: 30));
    try {
      // 1. Refresh XBoard subscription info to get latest subscribeUrl
      await ref.read(xboardUserProvider.notifier).refreshSubscriptionInfo();
      // 2. 清除旧配置 → 下载新配置 → 应用
      final sub = ref.read(subscriptionInfoProvider);
      if (sub != null && sub.subscribeUrl.isNotEmpty) {
        await ref.read(profileImportProvider.notifier).importSubscription(
          sub.subscribeUrl,
          forceRefresh: true,
        );
      } else {
        // Fallback: update existing profiles directly
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
    final nodes = _buildFlatNodes();
    if (nodes.isEmpty || nodes.first.groupName.isEmpty) return;
    setState(() => _isTestingAll = true);
    _rebuildOverlay();
    showPillToast(context, t, S.isEn ? 'Testing ${nodes.length} nodes...' : '正在批量测试 ${nodes.length} 个节点延迟...');
    int completed = 0;
    int failed = 0;
    final total = nodes.length;
    final groups = ref.read(groupsProvider);
    for (int i = 0; i < nodes.length; i++) {
      final node = nodes[i];
      final group = groups.where((g) => g.name == node.groupName).firstOrNull;
      final proxy = group?.all.where((p) => p.name == node.proxyName).firstOrNull;
      if (group == null || proxy == null) {
        completed++;
        continue;
      }
      setState(() => _testingNodeIndices.add(i));
      _rebuildOverlay();
      proxies_common.proxyDelayTest(proxy, group.testUrl).then((_) {
        if (!mounted) return;
        completed++;
        setState(() => _testingNodeIndices.remove(i));
        final delay = ref.read(getDelayProvider(proxyName: proxy.name, testUrl: group.testUrl));
        if (delay == null || delay <= 0) failed++;
        _rebuildOverlay();
        if (completed == total) {
          setState(() => _isTestingAll = false);
          _rebuildOverlay();
          final msg = failed > 0
              ? (S.isEn ? 'Done: ${total - failed} ok, $failed timeout' : '测速完成：${total - failed} 个成功，$failed 个超时')
              : (S.isEn ? 'All $total nodes tested' : '全部 $total 个节点测速完成');
          showPillToast(context, t, msg);
        }
      }).catchError((_) {
        if (!mounted) return;
        completed++;
        failed++;
        setState(() => _testingNodeIndices.remove(i));
        _rebuildOverlay();
        if (completed == total) {
          setState(() => _isTestingAll = false);
          _rebuildOverlay();
        }
      });
    }
  }

  void _handleTestSingleNode(int index, List<_SimpleNode> nodes) {
    if (_testingNodeIndices.contains(index)) return;
    if (index < 0 || index >= nodes.length) return;
    final node = nodes[index];
    if (node.groupName.isEmpty) return;
    final groups = ref.read(groupsProvider);
    final group = groups.where((g) => g.name == node.groupName).firstOrNull;
    final proxy = group?.all.where((p) => p.name == node.proxyName).firstOrNull;
    if (group == null || proxy == null) return;
    setState(() => _testingNodeIndices.add(index));
    _rebuildOverlay();
    proxies_common.proxyDelayTest(proxy, group.testUrl).then((_) {
      if (!mounted) return;
      setState(() => _testingNodeIndices.remove(index));
      _rebuildOverlay();
    }).catchError((_) {
      if (!mounted) return;
      setState(() => _testingNodeIndices.remove(index));
      _rebuildOverlay();
    });
  }

  List<_SimpleNode> _buildFlatNodes() {
    final allGroups = ref.read(groupsProvider);
    final mode = ref.read(patchClashConfigProvider).mode;

    final groups = switch (mode) {
      Mode.direct => <Group>[],
      Mode.global => allGroups.where((g) => g.name == GroupName.GLOBAL.name).toList(),
      Mode.rule => allGroups
          .where((g) => g.hidden == false && g.name != GroupName.GLOBAL.name)
          .where((g) => g.type == GroupType.Selector)
          .where((g) => !_isInfoNode(g.name))
          .toList(),
    };

    final list = <_SimpleNode>[];
    for (final g in groups) {
      final selectedName = appController.getSelectedProxyName(g.name);
      String? resolvedRealNodeName; // track resolved real node for isSelected transfer
      final startIdx = list.length;

      for (final p in g.all) {
        if (_isInfoNode(p.name)) continue;

        String displayName = p.name;
        bool isSelected = (selectedName == p.name);

        // Check if this proxy is a sub-group (URLTest/Fallback/LoadBalance)
        final subGroup = allGroups.where((sg) => sg.name == p.name).firstOrNull;
        String flagSource = p.name;
        if (subGroup != null && subGroup.type.isComputedSelected) {
          // Resolve the real node this sub-group auto-selected
          String? realNode = subGroup.now;
          if (realNode == null || realNode.isEmpty || _isInfoNode(realNode)) {
            // Fallback: first real (non-info) node in the sub-group
            realNode = subGroup.all
                .where((n) => !_isInfoNode(n.name))
                .firstOrNull?.name;
          }
          if (realNode != null && realNode.isNotEmpty) {
            flagSource = realNode; // use real node's country for flag
          }
          // Don't append sub-node name — just show group name
          // displayName stays as p.name (e.g. "自动选择", "故障转移")

          // Transfer isSelected to the resolved real node
          if (isSelected && realNode != null) {
            resolvedRealNodeName = realNode;
            isSelected = false; // group entry itself is not the "selected" display node
          }
        }

        final flag = _extractFlag(flagSource);
        final delay = ref.read(getDelayProvider(proxyName: p.name, testUrl: g.testUrl));
        list.add(_SimpleNode(
          flag: flag,
          displayName: displayName,
          groupName: g.name,
          proxyName: p.name,
          testUrl: g.testUrl,
          isSelected: isSelected,
          delay: delay,
        ));
      }

      // Mark the resolved real node as selected (so pill shows the actual node)
      if (resolvedRealNodeName != null) {
        for (var i = startIdx; i < list.length; i++) {
          if (list[i].proxyName == resolvedRealNodeName) {
            final old = list[i];
            list[i] = _SimpleNode(
              flag: old.flag,
              displayName: old.displayName,
              groupName: old.groupName,
              proxyName: old.proxyName,
              testUrl: old.testUrl,
              isSelected: true,
              delay: old.delay,
            );
            break;
          }
        }
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
      list.add(_SimpleNode(flag: '--', displayName: emptyHint, groupName: '', proxyName: emptyHint, isSelected: false));
    }
    return list;
  }

  String _currentNodeLabel(List<_SimpleNode> nodes) {
    final sel = nodes.where((n) => n.isSelected).firstOrNull;
    if (sel != null) return sel.displayName;
    if (nodes.isNotEmpty) return nodes.first.displayName;
    return S.isEn ? 'No node' : '未选择节点';
  }

  int? _currentNodeDelay(List<_SimpleNode> nodes) {
    final sel = nodes.where((n) => n.isSelected).firstOrNull;
    return sel?.delay;
  }
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

class _NoticeData {
  final String title;
  final String content;
  const _NoticeData(this.title, this.content);
}

class _SimpleNode {
  final String flag;
  final String displayName;
  final String groupName;
  final String proxyName;
  final String? testUrl;
  final bool isSelected;
  final int? delay;
  const _SimpleNode({
    required this.flag,
    required this.displayName,
    required this.groupName,
    required this.proxyName,
    this.testUrl,
    required this.isSelected,
    this.delay,
  });
}
