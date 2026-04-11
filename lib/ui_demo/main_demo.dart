import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';
import 'mihom_theme.dart';
import 'login_dialog.dart';
import 'i18n.dart';
import 'credential_store.dart';
import 'pages/home_page.dart';
import 'pages/nodes_page.dart';
import 'pages/profile_page.dart';
import 'pages/settings_page.dart';
import 'pages/plans_page.dart';
import 'mobile_onboarding.dart';

// ============================================================
//  Mihom UI Demo - 三套主题原型
//  运行: flutter run -t lib/ui_demo/main_demo.dart
// ============================================================

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  runApp(MihomDemoApp(prefs: prefs));
}

class MihomDemoApp extends StatefulWidget {
  final SharedPreferences prefs;
  const MihomDemoApp({super.key, required this.prefs});

  @override
  State<MihomDemoApp> createState() => _MihomDemoAppState();
}

class _MihomDemoAppState extends State<MihomDemoApp> {
  late MihomTheme _baseTheme; // 用户选的基础主题
  late bool _isFirstLaunch;
  bool _showOnboarding = false;

  int _darkModeOption = 0; // 0=跟随系统 1=浅色 2=深色

  @override
  void initState() {
    super.initState();
    final savedName = widget.prefs.getString('mihom_theme');
    _isFirstLaunch = savedName == null;
    _showOnboarding = _isFirstLaunch;

    _baseTheme = MihomTheme.all.firstWhere(
      (t) => t.name == savedName,
      orElse: () => MihomTheme.azure,
    );
    _darkModeOption = widget.prefs.getInt('mihom_dark_mode') ?? 0;
    S.localeNotifier.addListener(_onLocaleChange);
  }

  @override
  void dispose() {
    S.localeNotifier.removeListener(_onLocaleChange);
    super.dispose();
  }

  void _onLocaleChange() => setState(() {});

  void _changeTheme(MihomTheme theme) {
    widget.prefs.setString('mihom_theme', theme.name);
    setState(() => _baseTheme = theme);
    // 选择深色主题→自动切换到深色模式
    if (theme.isDark && _darkModeOption != 2) {
      _changeDarkMode(2);
    }
    // 深色模式下选择浅色主题→自动切换到浅色模式
    if (!theme.isDark && _darkModeOption == 2) {
      _changeDarkMode(1);
    }
  }

  void _changeDarkMode(int option) {
    widget.prefs.setInt('mihom_dark_mode', option);
    setState(() => _darkModeOption = option);
  }

  MihomTheme _resolveTheme(Brightness systemBrightness) {
    switch (_darkModeOption) {
      case 1: return _baseTheme.isDark ? MihomTheme.azure : _baseTheme; // 强制浅色
      case 2: return MihomTheme.night; // 强制深色
      default: // 跟随系统
        return systemBrightness == Brightness.dark ? MihomTheme.night : (_baseTheme.isDark ? MihomTheme.azure : _baseTheme);
    }
  }

  @override
  Widget build(BuildContext context) {
    final systemBrightness = MediaQuery.of(context).platformBrightness;
    final _theme = _resolveTheme(systemBrightness);

    SystemChrome.setSystemUIOverlayStyle(
      _theme.isDark
          ? SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent)
          : SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent),
    );

    return MaterialApp(
      title: 'Mihom',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: _theme.primary,
        brightness: _theme.isDark ? Brightness.dark : Brightness.light,
        scaffoldBackgroundColor: _theme.scaffoldBg,
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
      home: _showOnboarding
          ? MobileOnboarding(
              onComplete: () => setState(() => _showOnboarding = false),
            )
          : _isFirstLaunch
          ? ThemePicker(
              currentTheme: _theme,
              onThemeChanged: (t) {
                _changeTheme(t);
              },
              onConfirm: () => setState(() => _isFirstLaunch = false),
            )
          : MainScaffold(
              theme: _theme,
              onThemeChanged: _changeTheme,
              darkModeOption: _darkModeOption,
              onDarkModeChanged: _changeDarkMode,
              prefs: widget.prefs,
            ),
    );
  }
}

// ════════════════════════════════════════════════════
//  主题选择器 - 仅首次启动显示
// ════════════════════════════════════════════════════

class ThemePicker extends StatelessWidget {
  final MihomTheme currentTheme;
  final ValueChanged<MihomTheme> onThemeChanged;
  final VoidCallback onConfirm;

  const ThemePicker({
    super.key,
    required this.currentTheme,
    required this.onThemeChanged,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFF1A237E), Color(0xFF00BCD4)]),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Image.asset('lib/ui_demo/branding/icon_white.png', fit: BoxFit.contain),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Mihom', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1A237E))),
                      Text(S.selectYourStyle, style: const TextStyle(fontSize: 14, color: Color(0xFF5C6BC0))),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 40),
              Text(S.uiStyle, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A237E))),
              const SizedBox(height: 4),
              Text(S.canSwitchLater, style: const TextStyle(fontSize: 13, color: Color(0xFF9FA8DA))),
              const SizedBox(height: 20),

              Expanded(
                child: ListView.separated(
                  itemCount: MihomTheme.all.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final theme = MihomTheme.all[index];
                    final isSelected = currentTheme.name == theme.name;
                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        onThemeChanged(theme);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: isSelected
                              ? Border.all(color: theme.primary, width: 2.5)
                              : Border.all(color: Colors.transparent, width: 2.5),
                          boxShadow: [
                            BoxShadow(
                              color: isSelected ? theme.primary.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.04),
                              blurRadius: isSelected ? 24 : 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 48, height: 48,
                              decoration: BoxDecoration(gradient: theme.primaryGradient, borderRadius: BorderRadius.circular(14)),
                              child: Icon(theme.icon, color: Colors.white, size: 24),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(S.isEn ? theme.nameEn : theme.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A237E))),
                                  const SizedBox(height: 2),
                                  Text(S.isEn ? theme.subtitleEn : theme.subtitle, style: const TextStyle(fontSize: 13, color: Color(0xFF9FA8DA))),
                                ],
                              ),
                            ),
                            if (isSelected)
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(gradient: theme.primaryGradient, shape: BoxShape.circle),
                                child: const Icon(Icons.check, color: Colors.white, size: 16),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity, height: 52,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: currentTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: currentTheme.primary.withValues(alpha: 0.3), blurRadius: 16, offset: const Offset(0, 4))],
                  ),
                  child: ElevatedButton(
                    onPressed: onConfirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent, shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text(S.enterMihom, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════
//  居中弹窗 - 主题切换（设置页调用）
// ════════════════════════════════════════════════════

void showThemeDialog(BuildContext context, MihomTheme current, ValueChanged<MihomTheme> onChanged) {
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
            width: MediaQuery.of(ctx).size.width * 0.82,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: current.cardBg,
              borderRadius: BorderRadius.circular(24),
              border: current.cardBorder,
              boxShadow: [
                BoxShadow(color: current.primary.withValues(alpha: 0.2), blurRadius: 40, spreadRadius: 2),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(S.selectTheme, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: current.textPrimary)),
                const SizedBox(height: 20),
                ...MihomTheme.all.map((th) {
                  final isActive = th.name == current.name;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        onChanged(th);
                        Navigator.of(ctx).pop();
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          gradient: isActive ? th.primaryGradient : null,
                          color: isActive ? null : (current.isDark ? const Color(0xFF1C1F3A) : const Color(0xFFF5F7FF)),
                          borderRadius: BorderRadius.circular(16),
                          border: isActive ? null : Border.all(color: current.textHint.withValues(alpha: 0.15)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40, height: 40,
                              decoration: BoxDecoration(
                                gradient: isActive ? null : th.primaryGradient,
                                color: isActive ? Colors.white.withValues(alpha: 0.2) : null,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(th.icon, color: isActive ? Colors.white : th.primary, size: 20),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(S.isEn ? th.nameEn : th.name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: isActive ? Colors.white : current.textPrimary)),
                                  Text(S.isEn ? th.subtitleEn : th.subtitle, style: TextStyle(fontSize: 12, color: isActive ? Colors.white70 : current.textHint)),
                                ],
                              ),
                            ),
                            if (isActive) const Icon(Icons.check_circle, color: Colors.white, size: 22),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      );
    },
  );
}

// ════════════════════════════════════════════════════
//  主框架 + 悬浮药丸导航（3 个标签）
// ════════════════════════════════════════════════════

class MainScaffold extends StatefulWidget {
  final MihomTheme theme;
  final ValueChanged<MihomTheme> onThemeChanged;
  final int darkModeOption;
  final ValueChanged<int> onDarkModeChanged;
  final SharedPreferences prefs;
  const MainScaffold({super.key, required this.theme, required this.onThemeChanged, required this.darkModeOption, required this.onDarkModeChanged, required this.prefs});

  @override
  State<MainScaffold> createState() => MainScaffoldState();
}

class MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;
  bool _isGuest = true;
  bool _hasPlan = false; // 是否已购套餐
  int _selectedNode = 0; // 跨页面保持的节点选中索引

  // 节点 flat list（与 nodes_page 一致，用于首页显示）
  static List<(String flag, String country, String name)> get _flatNodes {
    final isEn = S.isEn;
    final groups = [
      ('🇯🇵', isEn ? 'Japan' : '日本', [isEn ? 'Tokyo 01' : '东京 01', isEn ? 'Tokyo 02' : '东京 02', isEn ? 'Osaka 01' : '大阪 01', isEn ? 'Osaka 02' : '大阪 02']),
      ('🇺🇸', isEn ? 'USA' : '美国', [isEn ? 'Los Angeles' : '洛杉矶', isEn ? 'New York' : '纽约', isEn ? 'Seattle' : '西雅图']),
      ('🇸🇬', isEn ? 'Singapore' : '新加坡', [isEn ? 'Singapore 01' : '新加坡 01', isEn ? 'Singapore 02' : '新加坡 02']),
      ('🇩🇪', isEn ? 'Germany' : '德国', [isEn ? 'Frankfurt' : '法兰克福']),
    ];
    final list = <(String, String, String)>[];
    for (final g in groups) {
      for (final n in g.$3) list.add((g.$1, g.$2, n));
    }
    return list;
  }

  String get _selectedNodeLabel {
    final nodes = _flatNodes;
    if (_selectedNode < 0 || _selectedNode >= nodes.length) return '';
    final n = nodes[_selectedNode];
    return '${n.$1}  ${n.$2} · ${n.$3}';
  }

  // ── 记住的账号密码 ──
  String _savedEmail = '';
  String _savedPassword = '';

  // ── 连接状态（提升到 scaffold 保持跨页面） ──
  bool _connected = false;
  DateTime? _connectedAt;
  int _latency = 23;
  bool _isTesting = false;

  bool get connected => _connected;
  DateTime? get connectedAt => _connectedAt;
  int get latency => _latency;
  bool get isTesting => _isTesting;

  void toggleConnection() {
    if (_isGuest) {
      HapticFeedback.mediumImpact();
      showLoginDialog(context, widget.theme, hint: S.loginFirst,
        initialEmail: SavedCredentials.email, initialPassword: SavedCredentials.password,
      ).then((result) {
        if (result != null) {
          _handleLoginWithCredentials(result['email']!, result['password']!);
        }
      });
      return;
    }
    // 登录了但没有套餐 → 引导购买
    if (!_hasPlan) {
      HapticFeedback.mediumImpact();
      _showNoPlanDialog();
      return;
    }
    HapticFeedback.mediumImpact();
    setState(() {
      _connected = !_connected;
      _connectedAt = _connected ? DateTime.now() : null;
      _latency = _connected ? 23 : 0;
    });
  }

  void _showNoPlanDialog() {
    final t = widget.theme;
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
        pageBuilder: (ctx, a1, a2) => DemoPlansPage(theme: widget.theme, isGuest: _isGuest, onLogin: _handleLogin),
        transitionsBuilder: (ctx, a1, a2, child) => SlideTransition(
          position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
              .animate(CurvedAnimation(parent: a1, curve: Curves.easeOutCubic)),
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 300),
      ),
    ).then((result) {
      if (result == true && mounted) {
        setState(() => _hasPlan = true);
      }
    });
  }

  void testLatency() {
    if (!_connected || _isTesting) return;
    setState(() => _isTesting = true);
    final rng = Random();
    final ms = 800 + rng.nextInt(1700);
    final isTimeout = rng.nextDouble() < 0.2;
    Future.delayed(Duration(milliseconds: ms), () {
      if (mounted) {
        setState(() {
          if (isTimeout) {
            _latency = -1;
          } else {
            _latency = 15 + rng.nextInt(40);
          }
          _isTesting = false;
        });
      }
    });
  }

  void switchToNodesTab() {
    setState(() => _currentIndex = 1);
  }

  void _handleLogin() {
    setState(() => _isGuest = false);
  }

  void _handleLoginWithCredentials(String email, String password) {
    SavedCredentials.email = email;
    SavedCredentials.password = password;
    setState(() {
      _isGuest = false;
      _savedEmail = email;
      _savedPassword = password;
    });
  }

  void _handleLogout() {
    // 清除主题和深色模式设置，下次启动时重新显示引导页
    widget.prefs.remove('mihom_theme');
    widget.prefs.remove('mihom_dark_mode');
    setState(() {
      _isGuest = true;
      _connected = false;
      _connectedAt = null;
      _latency = 0;
      _isTesting = false;
      // 保留 _savedEmail 和 _savedPassword 不清空
    });
  }

  void openSettings() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (ctx, a1, a2) => DemoSettingsPage(
          theme: widget.theme,
          onThemeChanged: widget.onThemeChanged,
          darkModeOption: widget.darkModeOption,
          onDarkModeChanged: widget.onDarkModeChanged,
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
    final t = widget.theme;
    final pages = [
      DemoHomePage(
        theme: t,
        onOpenSettings: openSettings,
        isGuest: _isGuest,
        onLogin: _handleLogin,
        connected: _connected,
        connectedAt: _connectedAt,
        latency: _latency,
        isTesting: _isTesting,
        onToggleConnection: toggleConnection,
        onTestLatency: testLatency,
        onTapNodeName: switchToNodesTab,
        onPlanPurchased: () => setState(() => _hasPlan = true),
        selectedNodeLabel: _selectedNodeLabel,
      ),
      DemoNodesPage(theme: t, isGuest: _isGuest, onLogin: _handleLogin,
        selectedNode: _selectedNode, onNodeSelected: (i) => setState(() => _selectedNode = i)),
      DemoProfilePage(theme: t, onOpenSettings: openSettings, isGuest: _isGuest, onLogin: _handleLogin, onLogout: _handleLogout),
    ];

    return Scaffold(
      backgroundColor: t.scaffoldBg,
      body: Container(
        decoration: t.scaffoldGradient != null ? BoxDecoration(gradient: t.scaffoldGradient) : null,
        child: Stack(
          children: [
            // 页面内容（底部给药丸留空间）
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

            // 悬浮药丸导航
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
                      _pillItem(t, 2, Icons.person_outline, Icons.person, S.navProfile),
                    ],
                  ),
                ),
              ),
            ),
          ],
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
              'lib/ui_demo/branding/icon_black.png',
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
