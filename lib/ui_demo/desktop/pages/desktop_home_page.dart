import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../../mihom_theme.dart';
import '../../i18n.dart';
import '../../pill_toast.dart';
import '../../flag_badge.dart';

/// 桌面端首页 — 连接面板 + 内联节点选择
class DesktopHomePage extends StatefulWidget {
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
  State<DesktopHomePage> createState() => _DesktopHomePageState();
}

class _DesktopHomePageState extends State<DesktopHomePage> with TickerProviderStateMixin {
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

  // 多条公告轮播
  int _announceIndex = 0;
  Timer? _announceTimer;

  // 代理模式: 0=Rule, 1=Global
  int _proxyMode = 0;

  // 首次引导气泡
  bool _guideShown = false;
  OverlayEntry? _guideOverlay;
  final GlobalKey _proxyModeKey = GlobalKey();

  // 单节点测速中的索引 (-1=none)
  int _testingNodeIndex = -1;
  final Map<int, String> _testResults = {};

  final GlobalKey _pillKey = GlobalKey();
  final GlobalKey _pillLatencyKey = GlobalKey();
  OverlayEntry? _pickerOverlay;

  // Flat node list
  List<_FlatNode> get _flatNodes {
    final list = <_FlatNode>[];
    for (final g in _nodeGroups) {
      for (final n in g.nodes) {
        list.add(_FlatNode(g.flag, g.country, n.name, n.latency));
      }
    }
    return list;
  }

  List<_NodeGroup> get _nodeGroups => [
    _NodeGroup('JP', S.isEn ? 'Japan' : '日本', [
      _Node(S.isEn ? 'Tokyo 01' : '东京 01', 23),
      _Node(S.isEn ? 'Tokyo 02' : '东京 02', 45),
      _Node(S.isEn ? 'Osaka 01' : '大阪 01', 89),
      _Node(S.isEn ? 'Osaka 02' : '大阪 02', 112),
    ]),
    _NodeGroup('US', S.isEn ? 'USA' : '美国', [
      _Node(S.isEn ? 'Los Angeles' : '洛杉矶', 120),
      _Node(S.isEn ? 'New York' : '纽约', 180),
      _Node(S.isEn ? 'Seattle' : '西雅图', 320),
    ]),
    _NodeGroup('SG', S.isEn ? 'Singapore' : '新加坡', [
      _Node(S.isEn ? 'Singapore 01' : '新加坡 01', 65),
      _Node(S.isEn ? 'Singapore 02' : '新加坡 02', 98),
    ]),
    _NodeGroup('DE', S.isEn ? 'Germany' : '德国', [
      _Node(S.isEn ? 'Frankfurt' : '法兰克福', 200),
    ]),
    _NodeGroup('GB', S.isEn ? 'UK' : '英国', [
      _Node(S.isEn ? 'London' : '伦敦', 210),
    ]),
    _NodeGroup('KR', S.isEn ? 'Korea' : '韩国', [
      _Node(S.isEn ? 'Seoul 01' : '首尔 01', 35),
      _Node(S.isEn ? 'Seoul 02' : '首尔 02', 52),
    ]),
  ];

  String get _currentNodeLabel {
    final n = _flatNodes[_selectedFlatIndex];
    return '${n.country}·${n.nodeName}';
  }

  int get _currentLatency => _flatNodes[_selectedFlatIndex].latency;

  List<String> get _announcements => [
    S.announcementDesc1,
    S.announcementDesc2,
    S.announcementDesc3,
  ];

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..repeat(reverse: true);
    _marqueeCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 10))..repeat();
    _announceTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (mounted && _announcements.length > 1) setState(() => _announceIndex = (_announceIndex + 1) % _announcements.length);
    });
    _tapScaleCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 120), lowerBound: 0.0, upperBound: 1.0);
    if (widget.connected) _startTimer();
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

  @override
  void dispose() {
    _timer?.cancel();
    _announceTimer?.cancel();
    _pulseCtrl.dispose();
    _marqueeCtrl.dispose();
    _tapScaleCtrl.dispose();
    _removePickerOverlay();
    _dismissGuide();
    super.dispose();
  }

  Color _latencyColor(int ms) {
    if (ms < 80) return t.success;
    if (ms < 200) return t.warning;
    return t.danger;
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
        final bubbleTop = pos.dy + size.height + 6;
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

  void _handleSyncSubscription() {
    if (_isSyncing) return;
    setState(() => _isSyncing = true);
    _rebuildOverlay();
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() => _isSyncing = false);
        _rebuildOverlay();
        showPillToast(context, t, S.isEn ? 'Subscription updated' : '订阅已更新');
      }
    });
  }

  void _handleTestAllLatency() {
    if (_isTestingAll) return;
    final nodes = _flatNodes;
    setState(() {
      _isTestingAll = true;
      _testResults.clear();
    });
    _rebuildOverlay();
    showPillToast(context, t, S.isEn ? 'Testing ${nodes.length} nodes...' : '正在批量测试 ${nodes.length} 个节点延迟...');
    final rng = Random();
    int completed = 0;
    int failed = 0;
    for (var i = 0; i < nodes.length; i++) {
      final ms = 800 + rng.nextInt(2200);
      final isTimeout = rng.nextDouble() < 0.15;
      // 所有节点标记为测试中
      setState(() => _testingNodeIndex = -2); // -2 = batch mode
      _testResults[i] = '__testing__';
      Future.delayed(Duration(milliseconds: ms), () {
        if (!mounted) return;
        completed++;
        if (isTimeout) failed++;
        setState(() {
          if (isTimeout) {
            _testResults[i] = S.isEn ? 'Timeout' : '超时';
          } else {
            final newDelay = 20 + rng.nextInt(300);
            _testResults[i] = '${newDelay}ms';
          }
        });
        _rebuildOverlay();
        if (completed == nodes.length) {
          setState(() {
            _isTestingAll = false;
            _testingNodeIndex = -1;
          });
          _rebuildOverlay();
          final msg = failed > 0
              ? (S.isEn ? 'Done: ${nodes.length - failed} ok, $failed timeout' : '测速完成：${nodes.length - failed} 个成功，$failed 个超时')
              : (S.isEn ? 'All ${nodes.length} nodes tested' : '全部 ${nodes.length} 个节点测速完成');
          showPillToast(context, t, msg);
        }
      });
    }
  }

  void _handleTestSingleNode(int index) {
    if (_testingNodeIndex >= 0) return;
    setState(() {
      _testingNodeIndex = index;
      _testResults.remove(index);
    });
    _rebuildOverlay();
    final rng = Random();
    final ms = 800 + rng.nextInt(1700);
    final isTimeout = rng.nextDouble() < 0.2;
    Future.delayed(Duration(milliseconds: ms), () {
      if (mounted) {
        setState(() {
          _testingNodeIndex = -1;
          if (isTimeout) {
            _testResults[index] = S.isEn ? 'Timeout' : '超时';
          } else {
            final newDelay = 20 + rng.nextInt(300);
            _testResults[index] = '${newDelay}ms';
          }
        });
        _rebuildOverlay();
      }
    });
  }

  void _handlePillLatencyTest() {
    if (widget.isTesting) return;
    widget.onTestLatency();
  }

  void _rebuildOverlay() {
    _pickerOverlay?.markNeedsBuild();
  }

  void _showPickerOverlay() {
    final renderBox = _pillKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    final pillPos = renderBox.localToGlobal(Offset.zero);
    final pillSize = renderBox.size;

    setState(() => _pickerOpen = true);

    _pickerOverlay = OverlayEntry(
      builder: (ctx) {
        final nodes = _flatNodes;
        const toolbarH = 40.0;
        final screenH = MediaQuery.of(context).size.height;
        // 自适应列表高度：节点数 × 每项高度，上限为可用空间
        final itemH = 48.0;
        final listContentH = nodes.length * itemH;
        final spaceAbove = pillPos.dy - 16;
        final spaceBelow = screenH - pillPos.dy - pillSize.height - 16;
        // 优先向上展示
        final goUp = spaceAbove >= spaceBelow || spaceAbove > 120;
        final maxListH = (goUp ? spaceAbove : spaceBelow) - toolbarH - 8;
        final listH = listContentH.clamp(48.0, maxListH.clamp(80.0, 360.0));
        final dropH = toolbarH + listH;
        final dropW = pillSize.width.clamp(280.0, 380.0);
        final double top = goUp ? pillPos.dy - dropH - 8 : pillPos.dy + pillSize.height + 8;

        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: _removePickerOverlay,
                behavior: HitTestBehavior.translucent,
                child: const SizedBox.expand(),
              ),
            ),
            Positioned(
              left: pillPos.dx + (pillSize.width - dropW) / 2,
              top: top,
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
                                  // Check if tap was on the latency badge
                                  final latencyBox = latencyKey.currentContext?.findRenderObject() as RenderBox?;
                                  if (latencyBox != null) {
                                    final localPos = latencyBox.globalToLocal(details.globalPosition);
                                    if (latencyBox.paintBounds.contains(localPos)) {
                                      _handleTestSingleNode(i);
                                      return;
                                    }
                                  }
                                  setState(() => _selectedFlatIndex = i);
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
                                          '${n.country}·${n.nodeName}',
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
                                        final delayText = hasResult ? result! : '${n.latency}ms';
                                        final dotColor = isTesting
                                            ? (isSel ? Colors.white38 : t.textHint)
                                            : isTimeout
                                                ? (isSel ? Colors.white70 : t.danger)
                                                : (isSel ? Colors.white70 : _latencyColor(n.latency));
                                        final txtColor = isSel ? Colors.white70
                                            : isTimeout ? t.danger : _latencyColor(n.latency);
                                        return MouseRegion(
                                          key: latencyKey,
                                          cursor: SystemMouseCursors.click,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: (isTimeout ? t.danger : _latencyColor(n.latency)).withValues(alpha: 0.1),
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
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(24),
          child: _buildConnectionPanel(),
        ),
        Positioned(
          left: 32, right: 32, top: 16,
          child: IgnorePointer(child: _buildAnnouncementBanner()),
        ),
      ],
    );
  }

  Widget _buildAnnouncementBanner() {
    return Container(
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
                  _announcements[_announceIndex],
                  style: TextStyle(fontSize: 13, color: t.textPrimary, fontWeight: FontWeight.w600),
                  maxLines: 1, softWrap: false,
                ),
              ),
            ),
          ),
        ],
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
          SizedBox(height: compact ? 4 : 12),
          // 大按钮 — 带点击缩放反馈 + 连接脉冲
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
                  child: Container(
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
                          ? Image.asset('lib/ui_demo/branding/icon_white.png', width: 52, height: 52)
                          : const Icon(Icons.power_settings_new, color: Colors.white, size: 42),
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

          // 节点选择 药丸 — 点击展开内联下拉
          MouseRegion(
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
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FlagBadge(_flatNodes[_selectedFlatIndex].flag, size: 28),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text(_currentNodeLabel,
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: t.textPrimary),
                      overflow: TextOverflow.ellipsis),
                  ),
                  const SizedBox(width: 8),
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: Builder(builder: (_) {
                      final pillResult = _testResults[_selectedFlatIndex];
                      final pillTesting = pillResult == '__testing__' || widget.isTesting;
                      final pillHasResult = pillResult != null && pillResult != '__testing__';
                      final pillTimeout = pillHasResult && (pillResult == '超时' || pillResult == 'Timeout');
                      final pillText = pillHasResult ? pillResult! : '${_currentLatency}ms';
                      final pillColor = pillTimeout ? t.danger : _latencyColor(_currentLatency);
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
          const SizedBox(height: 8),
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
          setState(() => _proxyMode = mode);
          if (mode == 2) {
            showPillToast(context, t, S.campusEnabled);
          }
        },
        onLongPress: () => _showModeInfo(mode),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          gradient: isActive ? (mode == 2 ? LinearGradient(colors: [const Color(0xFF00B4D8), const Color(0xFF0077B6)]) : t.buttonGradient) : null,
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
      default:
        return _ModeInfo(
          icon: Icons.school,
          color: const Color(0xFF00B4D8),
          title: S.campusModeTitle,
          desc: S.campusModeDesc,
          featuresLabel: S.campusBypassDomains,
          features: '*.edu.cn  *.edu  *.ac.cn\n*.edu.tw  *.edu.hk  *.edu.mo\n10.*  172.16-31.*  192.168.*\n202.112.*  210.25-35.*  (CERNET)\n*.local  localhost  127.*',
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
  final int latency;
  _Node(this.name, this.latency);
}

class _FlatNode {
  final String flag;
  final String country;
  final String nodeName;
  final int latency;
  _FlatNode(this.flag, this.country, this.nodeName, this.latency);
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
