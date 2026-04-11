import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../mihom_theme.dart';
import '../login_dialog.dart';
import '../i18n.dart';
import '../pill_toast.dart';
import 'plans_page.dart';

class DemoHomePage extends StatefulWidget {
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
    this.selectedNodeLabel = '🇯🇵  日本 · 东京 01',
  });

  @override
  State<DemoHomePage> createState() => _DemoHomePageState();
}

class _DemoHomePageState extends State<DemoHomePage> with TickerProviderStateMixin {
  Timer? _timer;
  String _elapsed = '00:00:00';
  bool _warningsDismissed = false;
  int _proxyMode = 0; // 0=Rule, 1=Global, 2=Campus

  // 首次引导气泡
  bool _guideShown = false;
  OverlayEntry? _guideOverlay;
  final GlobalKey _proxyModeKey = GlobalKey();

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

  @override
  void dispose() {
    _timer?.cancel();
    _connectController.dispose();
    _pulseController.dispose();
    _floatController.dispose();
    _dismissGuide();
    super.dispose();
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

  void _showNoticeDialog() {
    HapticFeedback.lightImpact();
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
              constraints: const BoxConstraints(maxHeight: 420),
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
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          _noticeItem(
                            S.announcementTitle1,
                            S.announcementDesc1,
                            S.announcementTime1,
                            true,
                          ),
                          const SizedBox(height: 12),
                          _noticeItem(
                            S.announcementTitle2,
                            S.announcementDesc2,
                            S.announcementTime2,
                            true,
                          ),
                          const SizedBox(height: 12),
                          _noticeItem(
                            S.announcementTitle3,
                            S.announcementDesc3,
                            S.announcementTime3,
                            false,
                          ),
                        ],
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
    return SafeArea(
      child: Stack(
        children: [
          // ── 主内容 ──
          Column(
            children: [
              // ── Header ──
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
            child: Row(
              children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(gradient: t.primaryGradient, borderRadius: BorderRadius.circular(10)),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Image.asset('lib/ui_demo/branding/icon_white.png', fit: BoxFit.contain),
                  ),
                ),
                const SizedBox(width: 10),
                Text('Mihom', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: t.textPrimary)),
                const Spacer(),
                // 公告铃铛
                GestureDetector(
                  onTap: _showNoticeDialog,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: t.cardBg, borderRadius: BorderRadius.circular(12),
                      border: t.cardBorder, boxShadow: t.cardShadow,
                    ),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Icon(Icons.notifications_outlined, color: t.textSecondary, size: 20),
                        Positioned(
                          top: -3, right: -3,
                          child: Container(
                            width: 8, height: 8,
                            decoration: BoxDecoration(
                              color: t.danger,
                              shape: BoxShape.circle,
                              border: Border.all(color: t.cardBg, width: 1.5),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // 设置齿轮
                GestureDetector(
                  onTap: widget.onOpenSettings,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: t.cardBg, borderRadius: BorderRadius.circular(12),
                      border: t.cardBorder, boxShadow: t.cardShadow,
                    ),
                    child: Icon(Icons.settings_outlined, color: t.textSecondary, size: 20),
                  ),
                ),
              ],
            ),
          ),

          const Spacer(flex: 2),

          // ── 大按钮 ──
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
                width: 200, height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: _connected ? t.connectedGradient : t.disconnectedGradient,
                  boxShadow: [
                    BoxShadow(
                      color: (_connected ? t.connectedGlow : t.disconnectedGlow).withValues(alpha: 0.35),
                      blurRadius: 40, spreadRadius: 5,
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
                          ? Image.asset('lib/ui_demo/branding/icon_white.png', width: 56, height: 56)
                          : const Icon(Icons.power_settings_new, size: 56, color: Colors.white),
                      const SizedBox(height: 8),
                      Text(
                        _connected ? S.protected_ : S.tapToConnect,
                        style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // ── 状态文字 ──
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () => widget.onTapNodeName?.call(),
                            child: Text(widget.selectedNodeLabel, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: t.textPrimary)),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () => widget.onTestLatency?.call(),
                            child: Builder(builder: (_) {
                              final isTimeout = widget.latency < 0;
                              final badgeColor = isTimeout ? t.danger : t.success;
                              final latencyText = isTimeout
                                  ? (S.isEn ? 'Timeout' : '超时')
                                  : '${widget.latency}ms';
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: badgeColor.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: widget.isTesting
                                    ? SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: t.textHint))
                                    : Text(latencyText, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: badgeColor)),
                              );
                            }),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text('${S.connectionTime} $_elapsed', style: TextStyle(fontSize: 13, color: t.textSecondary.withValues(alpha: 0.7))),
                    ],
                  )
                : const SizedBox.shrink(key: ValueKey('status_off')),
          ),

          const Spacer(flex: 1),

          // ── 代理模式选择 (仅未连接时显示，紧凑药丸) ──
          AnimatedCrossFade(
            firstChild: Container(
              key: _proxyModeKey,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: t.isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF3F4F8),
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
            secondChild: const SizedBox.shrink(),
            crossFadeState: _connected ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
            sizeCurve: Curves.easeInOut,
          ),
          const SizedBox(height: 8),

          // 给悬浮药丸导航留出空间
          const SizedBox(height: 80),
            ],
          ), // Column

          // ── 悬浮警告横幅（顶部浮层，可收起） ──
          if (!widget.isGuest && !_warningsDismissed)
            Positioned(
              top: 60,
              left: 24,
              right: 24,
              child: Column(
                children: [
                  _warningBanner(
                    icon: Icons.timer_outlined,
                    color: t.warning,
                    text: S.planExpirySoon,
                    actionText: S.renew,
                    onAction: () => _openPlans(),
                  ),
                  const SizedBox(height: 6),
                  _warningBanner(
                    icon: Icons.data_usage,
                    color: t.warning,
                    text: S.trafficUsed85,
                    actionText: S.upgrade,
                    onAction: () => _openPlans(),
                  ),
                ],
              ),
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
        HapticFeedback.mediumImpact();
        setState(() => _proxyMode = mode);
        if (mode == 2) showPillToast(context, t, S.campusEnabled);
      },
      onLongPress: () => _showModeInfo(mode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          gradient: isActive ? (mode == 2 ? const LinearGradient(colors: [Color(0xFF00B4D8), Color(0xFF0077B6)]) : t.buttonGradient) : null,
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
      default:
        return (
          icon: Icons.school,
          color: const Color(0xFF00B4D8),
          title: S.campusModeTitle,
          desc: S.campusModeDesc,
          featuresLabel: S.campusBypassDomains,
          features: ['*.edu.cn / *.edu / *.ac.cn', '*.edu.tw / *.edu.hk / *.edu.mo', '10.* / 172.16-31.* / 192.168.*', '202.112.* / 210.25-35.* (CERNET)', '*.local / localhost / 127.*'],
        );
    }
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
