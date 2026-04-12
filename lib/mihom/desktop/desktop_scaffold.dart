import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_clash/controller.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/xboard/features/auth/providers/xboard_user_provider.dart';
import 'package:fl_clash/xboard/domain/models/subscription.dart';
import '../theme/mihom_theme.dart';
import '../i18n.dart';
import '../widgets/login_dialog.dart';
import '../widgets/pill_toast.dart';
import '../widgets/credential_store.dart';
import 'pages/desktop_home_page.dart';
import 'pages/desktop_nodes_page.dart';
import 'pages/desktop_settings_page.dart';
import 'pages/desktop_plans_page.dart';
import 'pages/desktop_profile_page.dart';

/// 桌面端主框架 — 左侧边栏 + 右侧内容区
class DesktopScaffold extends ConsumerStatefulWidget {
  final MihomTheme theme;
  final ValueChanged<MihomTheme> onThemeChanged;
  final int darkModeOption;
  final ValueChanged<int> onDarkModeChanged;
  final SharedPreferences prefs;
  final bool isAuthenticated;
  final VoidCallback onLogin;
  final VoidCallback onLogout;
  const DesktopScaffold({super.key, required this.theme, required this.onThemeChanged, required this.darkModeOption, required this.onDarkModeChanged, required this.prefs, required this.isAuthenticated, required this.onLogin, required this.onLogout});

  @override
  ConsumerState<DesktopScaffold> createState() => _DesktopScaffoldState();
}

class _DesktopScaffoldState extends ConsumerState<DesktopScaffold> {
  int _currentIndex = 0;
  bool _isTesting = false;

  MihomTheme get t => widget.theme;
  bool get _isGuest => !widget.isAuthenticated;

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
        hint: S.isEn ? 'Please log in to purchase a plan' : '请先登录后购买套餐',
        initialEmail: SavedCredentials.email,
        initialPassword: SavedCredentials.password,
      );
      if (result == null || !mounted) return;
      // 登录成功 — xboardUserProvider.login() 已在弹窗内完成
      SavedCredentials.email = result['email'] ?? '';
      SavedCredentials.password = result['password'] ?? '';
      // 检查是否已购买套餐（login() 已填充 userInfoProvider）
      final user = ref.read(userInfoProvider);
      if (user == null || user.planId == null) {
        setState(() => _currentIndex = 2); // 跳转到购买套餐页
      }
      return;
    }
    // 未购买套餐时引导用户去购买
    final user = ref.read(userInfoProvider);
    final sub = ref.read(subscriptionInfoProvider);
    final isRunning = ref.read(isStartProvider);
    if (!isRunning && user != null && user.planId == null) {
      HapticFeedback.mediumImpact();
      showPillToast(context, t, S.isEn ? 'Please purchase a plan first' : '请先购买套餐');
      setState(() => _currentIndex = 2); // 跳转到购买套餐页
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
            width: 360,
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: t.cardBg,
              borderRadius: BorderRadius.circular(20),
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
                Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: t.textPrimary)),
                const SizedBox(height: 8),
                Text(message, textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: t.textSecondary, height: 1.5)),
                const SizedBox(height: 24),
                GestureDetector(
                  onTap: () {
                    Navigator.of(ctx).pop();
                    setState(() => _currentIndex = 2);
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

  void testLatency() {
    if (_isTesting) return;
    setState(() => _isTesting = true);
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _isTesting = false;
        });
      }
    });
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
            width: 380,
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: t.cardBg,
              borderRadius: BorderRadius.circular(20),
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
                Text(S.noActivePlan, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: t.textPrimary)),
                const SizedBox(height: 8),
                Text(S.needPurchasePlan, textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: t.textSecondary, height: 1.5)),
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
                          setState(() => _currentIndex = 2); // jump to plans page
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

  @override
  Widget build(BuildContext context) {
    final isRunning = ref.watch(isStartProvider);
    final runTime = ref.watch(runTimeProvider);
    final connectedAt = (isRunning && runTime != null)
        ? DateTime.now().subtract(Duration(milliseconds: runTime))
        : null;

    return Scaffold(
      backgroundColor: t.scaffoldBg,
      body: Container(
        decoration: t.scaffoldGradient != null ? BoxDecoration(gradient: t.scaffoldGradient) : null,
        child: Stack(
          children: [
            // ── 内容区 ──
            Padding(
              padding: const EdgeInsets.only(left: 98),
              child: _buildContent(),
            ),
            // ── 悬浮导航栏 ──
            Positioned(
              left: 10, top: 10, bottom: 10,
              child: _buildSidebar(),
            ),

          ],
        ),
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 92,
      decoration: BoxDecoration(
        color: (t.isDark ? const Color(0xFF151838) : Colors.white).withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 12, offset: const Offset(2, 0)),
        ],
        border: Border.all(color: t.textHint.withValues(alpha: 0.08)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 16),
          // 首页使用品牌图标
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            child: _BrandNavItem(
              isActive: _currentIndex == 0,
              theme: t,
              label: S.navHome,
              onTap: () => setState(() => _currentIndex = 0),
            ),
          ),
          _navItem(1, Icons.language_outlined, Icons.language, S.navNodes),
          _navItem(2, Icons.diamond_outlined, Icons.diamond, S.plans),
          const Spacer(),
          _navItem(3, Icons.person_outline, Icons.person, S.navProfile),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _navItem(int index, IconData icon, IconData activeIcon, String label) {
    final isActive = _currentIndex == index;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      child: _HoverNavItem(
        isActive: isActive,
        theme: t,
        icon: icon,
        activeIcon: activeIcon,
        label: label,
        onTap: () {
          HapticFeedback.lightImpact();
          setState(() => _currentIndex = index);
        },
      ),
    );
  }

  Widget _buildContent() {
    final isRunning = ref.watch(isStartProvider);
    final runTime = ref.watch(runTimeProvider);
    final connectedAt = (isRunning && runTime != null)
        ? DateTime.now().subtract(Duration(milliseconds: runTime))
        : null;

    switch (_currentIndex) {
      case 0:
        return DesktopHomePage(
          theme: t,
          isGuest: _isGuest,
          connected: isRunning,
          connectedAt: connectedAt,
          latency: 0,
          isTesting: _isTesting,
          onToggleConnection: toggleConnection,
          onTestLatency: testLatency,
          onLogin: _handleLogin,
        );
      case 1:
        return DesktopNodesPage(theme: t, isGuest: _isGuest, onLogin: _handleLogin);
      case 2:
        return DesktopPlansPage(theme: t, isGuest: _isGuest, onLogin: _handleLogin, onPlanPurchased: () {
          // Plan purchase handled by XBoard SDK
        }, onGoHome: () {
          setState(() => _currentIndex = 0);
        });
      case 3:
        return DesktopProfilePage(
          theme: t,
          isGuest: _isGuest,
          onLogout: _handleLogout,
          onLogin: _handleLogin,
          onOpenSettings: _showSettingsDialog,
        );
      default:
        return const SizedBox();
    }
  }

  void _showLogoutConfirm() {
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
            width: 340,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: t.cardBg,
              borderRadius: BorderRadius.circular(20),
              border: t.cardBorder,
              boxShadow: [BoxShadow(color: t.primary.withValues(alpha: 0.15), blurRadius: 30)],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(color: t.danger.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(14)),
                  child: Icon(Icons.logout, color: t.danger, size: 24),
                ),
                const SizedBox(height: 14),
                Text(S.isEn ? 'Sign Out' : '退出登录', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: t.textPrimary)),
                const SizedBox(height: 8),
                Text(S.isEn ? 'Are you sure you want to sign out?' : '确定要退出当前账号吗？',
                  style: TextStyle(fontSize: 13, color: t.textSecondary), textAlign: TextAlign.center),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () => Navigator.of(ctx).pop(),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 11),
                            decoration: BoxDecoration(
                              color: t.isDark ? const Color(0xFF2A2D45) : const Color(0xFFEEF0F5),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(child: Text(S.cancel, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: t.textSecondary))),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(ctx).pop();
                            _handleLogout();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 11),
                            decoration: BoxDecoration(color: t.danger, borderRadius: BorderRadius.circular(10)),
                            child: Center(child: Text(S.isEn ? 'Sign Out' : '退出', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white))),
                          ),
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

  void _showSettingsDialog() {
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
            width: 480,
            constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.85),
            decoration: BoxDecoration(
              color: t.cardBg,
              borderRadius: BorderRadius.circular(20),
              border: t.cardBorder,
              boxShadow: [BoxShadow(color: t.primary.withValues(alpha: 0.15), blurRadius: 30)],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: DesktopSettingsPage(
                theme: t,
                onThemeChanged: widget.onThemeChanged,
                darkModeOption: widget.darkModeOption,
                onDarkModeChanged: widget.onDarkModeChanged,
                isGuest: _isGuest,
                onLogin: () {
                  Navigator.of(ctx).pop();
                  _handleLogin();
                },
                onLogout: () {
                  Navigator.of(ctx).pop();
                  _handleLogout();
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 带 hover 效果的侧边栏导航项
class _HoverNavItem extends StatefulWidget {
  final bool isActive;
  final MihomTheme theme;
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final VoidCallback onTap;
  final bool isDanger;
  const _HoverNavItem({required this.isActive, required this.theme, required this.icon, required this.activeIcon, required this.label, required this.onTap, this.isDanger = false});
  @override
  State<_HoverNavItem> createState() => _HoverNavItemState();
}

class _HoverNavItemState extends State<_HoverNavItem> {
  bool _hover = false;
  MihomTheme get t => widget.theme;

  @override
  Widget build(BuildContext context) {
    final dangerColor = const Color(0xFFEF4444);
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            gradient: widget.isActive ? t.buttonGradient : null,
            color: widget.isActive
                ? null
                : widget.isDanger
                    ? (_hover ? dangerColor.withValues(alpha: 0.12) : Colors.transparent)
                    : (_hover ? t.primary.withValues(alpha: 0.08) : Colors.transparent),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.isActive ? widget.activeIcon : widget.icon, size: 20,
                color: widget.isActive ? Colors.white
                    : widget.isDanger ? (_hover ? dangerColor : dangerColor.withValues(alpha: 0.6))
                    : (_hover ? t.primary : t.textSecondary)),
              const SizedBox(height: 3),
              Text(widget.label, style: TextStyle(
                fontSize: 11, fontWeight: FontWeight.w600,
                color: widget.isActive ? Colors.white
                    : widget.isDanger ? (_hover ? dangerColor : dangerColor.withValues(alpha: 0.6))
                    : (_hover ? t.primary : t.textSecondary),
              ), overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ),
    );
  }
}

/// 品牌图标导航项（首页）
class _BrandNavItem extends StatefulWidget {
  final bool isActive;
  final MihomTheme theme;
  final String label;
  final VoidCallback onTap;
  const _BrandNavItem({required this.isActive, required this.theme, required this.label, required this.onTap});
  @override
  State<_BrandNavItem> createState() => _BrandNavItemState();
}

class _BrandNavItemState extends State<_BrandNavItem> {
  bool _hover = false;
  MihomTheme get t => widget.theme;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            gradient: widget.isActive ? t.buttonGradient : null,
            color: widget.isActive ? null : (_hover ? t.primary.withValues(alpha: 0.08) : Colors.transparent),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                widget.isActive
                    ? 'assets/branding/icon_white.png'
                    : 'assets/branding/icon_black.png',
                width: 28, height: 28,
                color: widget.isActive ? Colors.white : (_hover ? t.primary : t.textSecondary),
                colorBlendMode: BlendMode.srcIn,
              ),
              const SizedBox(height: 3),
              Text(widget.label, style: TextStyle(
                fontSize: 11, fontWeight: FontWeight.w600,
                color: widget.isActive ? Colors.white : (_hover ? t.primary : t.textSecondary),
              ), overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ),
    );
  }
}

/// 右下角浮动设置按钮
class _SettingsFab extends StatefulWidget {
  final MihomTheme theme;
  final VoidCallback onTap;
  const _SettingsFab({required this.theme, required this.onTap});
  @override
  State<_SettingsFab> createState() => _SettingsFabState();
}

class _SettingsFabState extends State<_SettingsFab> {
  bool _hover = false;
  MihomTheme get t => widget.theme;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 44, height: 44,
          decoration: BoxDecoration(
            color: _hover
                ? (t.isDark ? const Color(0xFF252850) : Colors.white)
                : (t.isDark ? const Color(0xFF1E2140) : Colors.white).withValues(alpha: 0.9),
            shape: BoxShape.circle,
            border: Border.all(color: t.textHint.withValues(alpha: _hover ? 0.18 : 0.1)),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: _hover ? 0.12 : 0.06), blurRadius: _hover ? 16 : 8, offset: const Offset(0, 2)),
            ],
          ),
          child: Icon(Icons.settings_outlined, size: 20, color: _hover ? t.primary : t.textSecondary),
        ),
      ),
    );
  }
}
