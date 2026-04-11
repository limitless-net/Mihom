/// Mihom Shell — 替换原有 AdaptiveShellLayout
/// 
/// 使用 Mihom 自定义 UI 主题系统，通过 Riverpod 桥接 XBoard SDK 数据。
/// 桌面端使用侧边栏导航，移动端使用底部悬浮药丸导航。
library;

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_clash/common/constant.dart' show appName;
import 'package:fl_clash/controller.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/providers/database.dart';
import 'package:fl_clash/xboard/features/auth/auth.dart';
import 'package:fl_clash/xboard/features/initialization/initialization.dart';
import '../providers/theme_provider.dart';
import '../providers/data_bridge.dart';
import '../theme/mihom_theme.dart';
import '../i18n.dart';
import '../desktop/desktop_scaffold.dart';
import '../mobile/mobile_scaffold.dart';
import '../desktop/desktop_onboarding.dart';
import '../desktop/desktop_theme_picker.dart';
import '../mobile/mobile_onboarding.dart';
import '../widgets/login_dialog.dart';
import '../widgets/credential_store.dart';

/// Mihom 主 Shell Widget
/// 
/// 自动检测平台，展示对应的桌面端/移动端 scaffold。
/// 处理首次启动引导流程（引导页 → 主题选择 → 主界面）。
class MihomShell extends ConsumerStatefulWidget {
  const MihomShell({super.key});

  @override
  ConsumerState<MihomShell> createState() => _MihomShellState();
}

class _MihomShellState extends ConsumerState<MihomShell> {
  static final bool _isDesktop = Platform.isWindows || Platform.isLinux || Platform.isMacOS;
  bool _showOnboarding = false;
  bool _showThemePicker = false;
  bool _checkedFirstLaunch = false;

  @override
  void initState() {
    super.initState();
    S.localeNotifier.addListener(_onLocaleChange);
  }

  @override
  void dispose() {
    S.localeNotifier.removeListener(_onLocaleChange);
    super.dispose();
  }

  void _onLocaleChange() => setState(() {});

  MihomTheme _resolveCurrentTheme(Brightness systemBrightness) {
    final themeState = _isDesktop
        ? ref.read(desktopThemeProvider)
        : ref.read(mobileThemeProvider);
    return resolveTheme(themeState, systemBrightness);
  }

  void _handleThemeChanged(MihomTheme theme) {
    if (_isDesktop) {
      ref.read(desktopThemeProvider.notifier).changeTheme(theme);
    } else {
      ref.read(mobileThemeProvider.notifier).changeTheme(theme);
    }
  }

  void _handleDarkModeChanged(int option) {
    if (_isDesktop) {
      ref.read(desktopThemeProvider.notifier).changeDarkMode(option);
    } else {
      ref.read(mobileThemeProvider.notifier).changeDarkMode(option);
    }
  }

  void _onOnboardingComplete() {
    setState(() {
      _showOnboarding = false;
      _showThemePicker = true;
    });
  }

  void _onThemePickerConfirm() {
    if (_isDesktop) {
      ref.read(desktopThemeProvider.notifier).completeFirstLaunch();
    } else {
      ref.read(mobileThemeProvider.notifier).completeFirstLaunch();
    }
    setState(() => _showThemePicker = false);
  }

  void _handleLogout() {
    // 停止 VPN 连接
    appController.updateStatus(false);
    // 删除所有 Profile（订阅、selectedMap、缓存文件）
    final profiles = ref.read(profilesProvider);
    for (final profile in profiles) {
      appController.deleteProfile(profile.id);
    }
    // 清除保存的登录凭证
    SavedCredentials.email = '';
    SavedCredentials.password = '';
    // 不再清除主题设置，退出登录后下次启动基于认证状态决定引导
    // 调用 SDK 退出登录
    ref.read(xboardUserProvider.notifier).logout();
  }

  @override
  Widget build(BuildContext context) {
    // ── 阶段 1: 初始化检查 ──
    final initState = ref.watch(initializationProvider);
    if (!initState.isReady) {
      return _buildInitScreen(context, initState);
    }

    // ── 阶段 2: SharedPreferences 就绪 ──
    final prefsAsync = ref.watch(sharedPrefsFutureProvider);
    final prefs = prefsAsync.value;
    if (prefs == null) {
      return _buildLoadingPlaceholder(context, '正在准备...');
    }

    // ── 阶段 3: 主题状态 ──
    final themeState = _isDesktop
        ? ref.watch(desktopThemeProvider)
        : ref.watch(mobileThemeProvider);
    
    final systemBrightness = MediaQuery.of(context).platformBrightness;
    final theme = resolveTheme(themeState, systemBrightness);

    // ── 阶段 4: 认证状态 ──
    final userState = ref.watch(xboardUserProvider);
    // 等待认证状态初始化完成后再决定是否展示引导
    if (!userState.isInitialized) {
      return _buildLoadingPlaceholder(context, '正在验证...');
    }
    final isAuthenticated = userState.isAuthenticated;

    // 未登录时每次启动都展示引导页和主题选择页
    if (!_checkedFirstLaunch) {
      _checkedFirstLaunch = true;
      if (!isAuthenticated) {
        _showOnboarding = true;
      }
    }

    // ── 引导流程 ──
    if (_showOnboarding) {
      return _isDesktop
          ? DesktopOnboarding(onComplete: _onOnboardingComplete)
          : MobileOnboarding(onComplete: _onOnboardingComplete);
    }

    if (_showThemePicker) {
      return _isDesktop
          ? DesktopThemePicker(
              currentTheme: theme,
              onThemeChanged: _handleThemeChanged,
              onConfirm: _onThemePickerConfirm,
            )
          : _buildMobileThemePicker(theme);
    }

    // ── 主界面（登录非必须，auth 状态传入 scaffold） ──
    // 使用 Theme 注入统一 TextTheme，不创建嵌套 MaterialApp
    return Theme(
      data: Theme.of(context).copyWith(
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          displayMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          headlineLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          headlineMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          headlineSmall: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          titleLarge: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          titleMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          titleSmall: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          bodyLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
          bodyMedium: TextStyle(fontSize: 13, fontWeight: FontWeight.normal),
          bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
          labelLarge: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          labelMedium: TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
          labelSmall: TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
        ),
      ),
      child: _isDesktop
          ? DesktopScaffold(
              theme: theme,
              onThemeChanged: _handleThemeChanged,
              darkModeOption: themeState.darkModeOption,
              onDarkModeChanged: _handleDarkModeChanged,
              prefs: prefs,
              isAuthenticated: isAuthenticated,
              onLogin: () => _showLoginFlow(context, theme),
              onLogout: _handleLogout,
            )
          : MobileScaffold(
              theme: theme,
              onThemeChanged: _handleThemeChanged,
              darkModeOption: themeState.darkModeOption,
              onDarkModeChanged: _handleDarkModeChanged,
              prefs: prefs,
              isAuthenticated: isAuthenticated,
              onLogin: () => _showLoginFlow(context, theme),
              onLogout: _handleLogout,
            ),
    );
  }

  /// 初始化中/失败界面
  Widget _buildInitScreen(BuildContext context, InitializationState initState) {
    if (initState.isFailed) {
      return Scaffold(
        backgroundColor: const Color(0xFFF0F4FF),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.cloud_off_rounded, size: 64, color: Colors.redAccent),
                const SizedBox(height: 16),
                const Text('服务初始化失败',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A237E))),
                const SizedBox(height: 8),
                Text(initState.errorMessage ?? '未知错误',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Color(0xFF5C6BC0))),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () =>
                      ref.read(initializationProvider.notifier).refresh(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('重试'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return _buildLoadingPlaceholder(
      context,
      initState.currentStepDescription ?? '正在初始化...',
    );
  }

  /// 通用加载占位界面
  Widget _buildLoadingPlaceholder(BuildContext context, String message) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: Color(0xFF1A237E)),
            const SizedBox(height: 16),
            Text(message,
                style: const TextStyle(color: Color(0xFF5C6BC0), fontSize: 14)),
          ],
        ),
      ),
    );
  }

  /// 弹出登录流程 — 对话框内部已对接 XBoard SDK
  Future<void> _showLoginFlow(BuildContext context, MihomTheme theme) async {
    await showLoginDialog(context, theme);
    if (mounted) setState(() {});
  }

  /// 全屏登录界面 — 替代弹窗叠加方式
  Widget _buildLoginScreen(BuildContext context, MihomTheme theme) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 应用图标
            Container(
              width: 72, height: 72,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF1A237E), Color(0xFF00BCD4)]),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: const Color(0xFF1A237E).withValues(alpha: 0.25), blurRadius: 20, offset: const Offset(0, 6))],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Image.asset('assets/branding/icon_white.png', fit: BoxFit.contain),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(appName, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1A237E))),
            const SizedBox(height: 8),
            Text(
              S.isEn ? 'Sign in to continue' : '登录以继续',
              style: const TextStyle(fontSize: 14, color: Color(0xFF5C6BC0)),
            ),
            const SizedBox(height: 32),
            // 登录按钮
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => _showLoginFlow(context, theme),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFF1A237E), Color(0xFF00BCD4)]),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [BoxShadow(color: const Color(0xFF1A237E).withValues(alpha: 0.25), blurRadius: 14, offset: const Offset(0, 4))],
                  ),
                  child: Text(
                    S.isEn ? 'Sign In' : '登录',
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // 注册链接
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () async {
                  final result = await showLoginDialog(context, theme, startAsRegister: true);
                  if (result != null && mounted) {
                    try {
                      final email = result['email'] ?? '';
                      final password = result['password'] ?? '';
                      await ref.read(xboardUserProvider.notifier).login(email, password);
                    } catch (e) {
                      if (mounted) setState(() {});
                    }
                  }
                },
                child: Text.rich(TextSpan(
                  text: S.isEn ? 'No account? ' : '没有账号？',
                  style: const TextStyle(fontSize: 13, color: Color(0xFF5C6BC0)),
                  children: [
                    TextSpan(
                      text: S.isEn ? 'Register' : '注册',
                      style: const TextStyle(color: Color(0xFF1A237E), fontWeight: FontWeight.w600),
                    ),
                  ],
                )),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 移动端主题选择页 (引导流程中)
  Widget _buildMobileThemePicker(MihomTheme theme) {
    // 复用桌面端主题选择器（它在移动端也工作良好）
    return DesktopThemePicker(
      currentTheme: theme,
      onThemeChanged: _handleThemeChanged,
      onConfirm: _onThemePickerConfirm,
    );
  }
}
