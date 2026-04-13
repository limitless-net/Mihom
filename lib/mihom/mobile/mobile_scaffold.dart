import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_clash/controller.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/xboard/features/auth/providers/xboard_user_provider.dart';
import 'package:fl_clash/xboard/domain/models/subscription.dart';
import '../theme/mihom_theme.dart';
import '../widgets/login_dialog.dart';
import '../widgets/pill_toast.dart';
import '../i18n.dart';
import '../widgets/credential_store.dart';
import 'pages/home_page.dart';
import 'pages/nodes_page.dart';
import 'pages/profile_page.dart';
import 'pages/settings_page.dart';
import 'pages/plans_page.dart';

// ════════════════════════════════════════════════════
//  移动端主框架 + 悬浮药丸导航（3 个标签）
// ════════════════════════════════════════════════════

class MobileScaffold extends ConsumerStatefulWidget {
  final MihomTheme theme;
  final ValueChanged<MihomTheme> onThemeChanged;
  final int darkModeOption;
  final ValueChanged<int> onDarkModeChanged;
  final SharedPreferences prefs;
  final bool isAuthenticated;
  final VoidCallback onLogin;
  final VoidCallback onLogout;
  const MobileScaffold({super.key, required this.theme, required this.onThemeChanged, required this.darkModeOption, required this.onDarkModeChanged, required this.prefs, required this.isAuthenticated, required this.onLogin, required this.onLogout});

  @override
  ConsumerState<MobileScaffold> createState() => MobileScaffoldState();
}

class MobileScaffoldState extends ConsumerState<MobileScaffold> {
  int _currentIndex = 0;
  bool _isTesting = false;

  MihomTheme get t => widget.theme;
  bool get _isGuest => !widget.isAuthenticated;

  @override
  void initState() {
    super.initState();
    ref.listenManual(xboardUserProvider, (previous, next) {
      if (next.errorMessage == 'TOKEN_EXPIRED' && mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showTokenExpiredDialog();
        });
      }
    });
  }

  void _showTokenExpiredDialog() {
    if (!mounted) return;
    final userNotifier = ref.read(xboardUserProvider.notifier);
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: '',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 250),
      transitionBuilder: (ctx, a1, a2, child) => Transform.scale(
        scale: Curves.easeOutBack.transform(a1.value),
        child: Opacity(opacity: a1.value, child: child),
      ),
      pageBuilder: (ctx, a1, a2) => Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: MediaQuery.of(ctx).size.width * 0.82,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: t.cardBg,
              borderRadius: BorderRadius.circular(24),
              border: t.cardBorder,
              boxShadow: [BoxShadow(color: t.primary.withValues(alpha: 0.15), blurRadius: 30)],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 56, height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6B6B).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.lock_outline, color: Color(0xFFFF6B6B), size: 28),
                ),
                const SizedBox(height: 16),
                Text(
                  S.isEn ? 'Session Expired' : '登录已过期',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: t.textPrimary),
                ),
                const SizedBox(height: 8),
                Text(
                  S.isEn ? 'Your session has expired or your account is no longer available. Please log in again.' : '您的登录已过期或账户不可用，请重新登录。',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: t.textSecondary, height: 1.5),
                ),
                const SizedBox(height: 24),
                GestureDetector(
                  onTap: () async {
                    Navigator.of(ctx).pop();
                    userNotifier.clearTokenExpiredError();
                    await userNotifier.handleTokenExpired();
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(gradient: t.buttonGradient, borderRadius: BorderRadius.circular(12)),
                    child: Center(child: Text(
                      S.isEn ? 'Log In Again' : '重新登录',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
                    )),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleLogin() {
    widget.onLogin();
  }

  void _handleLogout() {
    widget.onLogout();
  }

  void toggleConnection() async {
    if (_isGuest) {
      HapticFeedback.mediumImpact();
      final result = await showLoginDialog(
        context, t,
        hint: S.loginFirst,
        initialEmail: SavedCredentials.email,
        initialPassword: SavedCredentials.password,
      );
      if (result == null || !mounted) return;
      SavedCredentials.email = result['email'] ?? '';
      SavedCredentials.password = result['password'] ?? '';
      final user = ref.read(userInfoProvider);
      if (user == null || user.planId == null) {
        _openPlansPage();
      }
      return;
    }
    final user = ref.read(userInfoProvider);
    final sub = ref.read(subscriptionInfoProvider);
    final isRunning = ref.read(isStartProvider);
    if (!isRunning && user != null && user.planId == null) {
      HapticFeedback.mediumImpact();
      showPillToast(context, t, S.isEn ? 'Please purchase a plan first' : '请先购买套餐');
      _openPlansPage();
      return;
    }
    // 套餐已过期时弹窗引导续费
    if (!isRunning && user != null && user.isExpired) {
      HapticFeedback.mediumImpact();
      _showPlanAlertDialog(
        icon: Icons.access_time_rounded,
        title: S.isEn ? 'Plan Expired' : '套餐已过期',
        message: S.isEn ? 'Your plan has expired. Please renew to continue using.' : '您的套餐已过期，请续费后继续使用。',
      );
      return;
    }
    // 流量用完时弹窗引导续费
    if (!isRunning && sub != null && sub.isTrafficExhausted) {
      HapticFeedback.mediumImpact();
      _showPlanAlertDialog(
        icon: Icons.data_usage_rounded,
        title: S.isEn ? 'Traffic Exhausted' : '流量已用完',
        message: S.isEn ? 'Your traffic has been used up. Please renew or upgrade your plan.' : '您的流量已用完，请续费或升级套餐。',
      );
      return;
    }
    HapticFeedback.mediumImpact();
    appController.updateStart();
  }

  void _showPlanAlertDialog({required IconData icon, required String title, required String message}) {
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
          child: Container(
            width: MediaQuery.of(ctx).size.width * 0.82,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: t.cardBg,
              borderRadius: BorderRadius.circular(24),
              border: t.cardBorder,
              boxShadow: [BoxShadow(color: t.primary.withValues(alpha: 0.15), blurRadius: 30)],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 56, height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6B6B).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, color: const Color(0xFFFF6B6B), size: 28),
                ),
                const SizedBox(height: 16),
                Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: t.textPrimary)),
                const SizedBox(height: 8),
                Text(message, textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: t.textSecondary, height: 1.5)),
                const SizedBox(height: 24),
                GestureDetector(
                  onTap: () {
                    Navigator.of(ctx).pop();
                    _openPlansPage();
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(gradient: t.buttonGradient, borderRadius: BorderRadius.circular(12)),
                    child: Center(child: Text(S.isEn ? 'Go to Plans' : '前往续费', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white))),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showNoPlanDialog() {
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
          child: Container(
            width: MediaQuery.of(ctx).size.width * 0.82,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: t.cardBg,
              borderRadius: BorderRadius.circular(24),
              border: t.cardBorder,
              boxShadow: [BoxShadow(color: t.primary.withValues(alpha: 0.15), blurRadius: 30)],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 56, height: 56,
                  decoration: BoxDecoration(gradient: t.primaryGradient, borderRadius: BorderRadius.circular(16)),
                  child: const Icon(Icons.shopping_cart_outlined, color: Colors.white, size: 28),
                ),
                const SizedBox(height: 16),
                Text(S.noActivePlan, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: t.textPrimary)),
                const SizedBox(height: 8),
                Text(
                  S.needPurchasePlan,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: t.textSecondary, height: 1.5),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.of(ctx).pop(),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: t.isDark ? const Color(0xFF2A2D45) : const Color(0xFFEEF0F5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(child: Text(S.cancel, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: t.textSecondary))),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(ctx).pop();
                          _openPlansPage();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(gradient: t.buttonGradient, borderRadius: BorderRadius.circular(12)),
                          child: Center(child: Text(S.buyNow, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white))),
                        ),
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

  void _openPlansPage() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (ctx, a1, a2) => DemoPlansPage(theme: widget.theme, isGuest: _isGuest, onLogin: _handleLogin, onGoHome: () {
          Navigator.of(ctx).pop();
          setState(() => _currentIndex = 0);
        }),
        transitionsBuilder: (ctx, a1, a2, child) => SlideTransition(
          position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
              .animate(CurvedAnimation(parent: a1, curve: Curves.easeOutCubic)),
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 300),
      ),
    ).then((result) {
      if (result == true && mounted) {
        setState(() {});
      }
    });
  }

  void testLatency() {
    if (_isTesting) return;
    setState(() => _isTesting = true);
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() => _isTesting = false);
      }
    });
  }

  void switchToNodesTab() {
    setState(() => _currentIndex = 1);
  }

  void openSettings() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (ctx, a1, a2) => DemoSettingsPage(
          theme: widget.theme,
          onThemeChanged: widget.onThemeChanged,
          darkModeOption: widget.darkModeOption,
          onDarkModeChanged: widget.onDarkModeChanged,
          isGuest: _isGuest,
          onLogin: _handleLogin,
        ),
        transitionsBuilder: (ctx, a1, a2, child) {
          return SlideTransition(
            position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
                .animate(CurvedAnimation(parent: a1, curve: Curves.easeOutCubic)),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isRunning = ref.watch(isStartProvider);
    final runTime = ref.watch(runTimeProvider);
    final connectedAt = (isRunning && runTime != null)
        ? DateTime.now().subtract(Duration(milliseconds: runTime))
        : null;

    final pages = [
      DemoHomePage(
        theme: t,
        onOpenSettings: openSettings,
        isGuest: _isGuest,
        onLogin: _handleLogin,
        connected: isRunning,
        connectedAt: connectedAt,
        latency: 0,
        isTesting: _isTesting,
        onToggleConnection: toggleConnection,
        onTestLatency: testLatency,
        onTapNodeName: switchToNodesTab,
        onPlanPurchased: () => setState(() {}),
        selectedNodeLabel: '',
      ),
      DemoNodesPage(theme: t, isGuest: _isGuest, onLogin: _handleLogin,
        selectedNode: 0, onNodeSelected: (_) {}),
      DemoPlansPage(theme: t, isGuest: _isGuest, onLogin: _handleLogin, embeddedMode: true, onGoHome: () {
        setState(() => _currentIndex = 0);
      }),
      DemoProfilePage(theme: t, onOpenSettings: openSettings, isGuest: _isGuest, onLogin: _handleLogin, onLogout: _handleLogout),
    ];

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: t.isDark ? Brightness.light : Brightness.dark,
        systemNavigationBarContrastEnforced: false,
      ),
      child: Scaffold(
      backgroundColor: t.scaffoldBg,
      body: Container(
        decoration: t.scaffoldGradient != null ? BoxDecoration(gradient: t.scaffoldGradient) : null,
        child: Stack(
          children: [
            Positioned.fill(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: child,
                ),
                child: KeyedSubtree(
                  key: ValueKey(_currentIndex),
                  child: pages[_currentIndex],
                ),
              ),
            ),
            Positioned(
              left: 0, right: 0,
              bottom: MediaQuery.of(context).padding.bottom + 16,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: t.isDark ? const Color(0xFF1A1D35) : Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    border: t.isDark
                        ? Border.all(color: t.primary.withValues(alpha: 0.15))
                        : null,
                    boxShadow: [
                      BoxShadow(
                        color: t.primary.withValues(alpha: t.isDark ? 0.15 : 0.12),
                        blurRadius: 24, spreadRadius: 0,
                        offset: const Offset(0, 8),
                      ),
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 8, offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _brandPillItem(t, 0, S.navHome),
                      const SizedBox(width: 4),
                      _pillItem(t, 1, Icons.language_outlined, Icons.language, S.navNodes),
                      const SizedBox(width: 4),
                      _pillItem(t, 2, Icons.card_giftcard_outlined, Icons.card_giftcard, S.navPlans),
                      const SizedBox(width: 4),
                      _pillItem(t, 3, Icons.person_outline, Icons.person, S.navProfile),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
    );
  }

  Widget _pillItem(MihomTheme t, int index, IconData icon, IconData activeIcon, String label) {
    final isActive = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() => _currentIndex = index);
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(horizontal: isActive ? 20 : 16, vertical: 10),
        decoration: isActive
            ? BoxDecoration(gradient: t.navActiveGradient, borderRadius: BorderRadius.circular(22))
            : null,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(isActive ? activeIcon : icon, size: 21, color: isActive ? Colors.white : t.navInactive),
            if (isActive) ...[
              const SizedBox(width: 6),
              Text(label, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _brandPillItem(MihomTheme t, int index, String label) {
    final isActive = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() => _currentIndex = index);
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(horizontal: isActive ? 20 : 16, vertical: 10),
        decoration: isActive
            ? BoxDecoration(gradient: t.navActiveGradient, borderRadius: BorderRadius.circular(22))
            : null,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/branding/icon_black.png',
              width: 26, height: 26,
              color: isActive ? Colors.white : t.navInactive,
              colorBlendMode: BlendMode.srcIn,
            ),
            if (isActive) ...[
              const SizedBox(width: 6),
              Text(label, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
            ],
          ],
        ),
      ),
    );
  }
}
