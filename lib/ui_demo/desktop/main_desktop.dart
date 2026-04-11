import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../mihom_theme.dart';
import '../i18n.dart';
import 'desktop_scaffold.dart';
import 'desktop_theme_picker.dart';
import 'desktop_onboarding.dart';

// ============================================================
//  Mihom Desktop UI Demo
//  运行: flutter run -t lib/ui_demo/desktop/main_desktop.dart
// ============================================================

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  runApp(MihomDesktopApp(prefs: prefs));
}

class MihomDesktopApp extends StatefulWidget {
  final SharedPreferences prefs;
  const MihomDesktopApp({super.key, required this.prefs});

  @override
  State<MihomDesktopApp> createState() => _MihomDesktopAppState();
}

class _MihomDesktopAppState extends State<MihomDesktopApp> {
  late MihomTheme _baseTheme;
  late bool _isFirstLaunch;
  bool _showOnboarding = false;
  int _darkModeOption = 0; // 0=跟随系统 1=浅色 2=深色

  @override
  void initState() {
    super.initState();
    final savedName = widget.prefs.getString('mihom_desktop_theme');
    _isFirstLaunch = savedName == null;
    _showOnboarding = _isFirstLaunch;
    _baseTheme = MihomTheme.all.firstWhere(
      (t) => t.name == savedName,
      orElse: () => MihomTheme.azure,
    );
    _darkModeOption = widget.prefs.getInt('mihom_desktop_dark') ?? 0;
    S.localeNotifier.addListener(_onLocaleChange);
  }

  @override
  void dispose() {
    S.localeNotifier.removeListener(_onLocaleChange);
    super.dispose();
  }

  void _onLocaleChange() => setState(() {});

  void _changeTheme(MihomTheme theme) {
    widget.prefs.setString('mihom_desktop_theme', theme.name);
    setState(() => _baseTheme = theme);
    if (theme.isDark && _darkModeOption != 2) _changeDarkMode(2);
    if (!theme.isDark && _darkModeOption == 2) _changeDarkMode(1);
  }

  void _changeDarkMode(int option) {
    widget.prefs.setInt('mihom_desktop_dark', option);
    setState(() => _darkModeOption = option);
  }

  MihomTheme _resolveTheme(Brightness systemBrightness) {
    switch (_darkModeOption) {
      case 1: return _baseTheme.isDark ? MihomTheme.azure : _baseTheme;
      case 2: return MihomTheme.night;
      default:
        return systemBrightness == Brightness.dark
            ? MihomTheme.night
            : (_baseTheme.isDark ? MihomTheme.azure : _baseTheme);
    }
  }

  @override
  Widget build(BuildContext context) {
    final systemBrightness = MediaQuery.of(context).platformBrightness;
    final theme = _resolveTheme(systemBrightness);

    return MaterialApp(
      title: 'Mihom Desktop',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: theme.primary,
        brightness: theme.isDark ? Brightness.dark : Brightness.light,
        scaffoldBackgroundColor: theme.scaffoldBg,
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
          ? DesktopOnboarding(
              onComplete: () => setState(() => _showOnboarding = false),
            )
          : _isFirstLaunch
          ? DesktopThemePicker(
              currentTheme: theme,
              onThemeChanged: _changeTheme,
              onConfirm: () => setState(() => _isFirstLaunch = false),
            )
          : DesktopScaffold(
              theme: theme,
              onThemeChanged: _changeTheme,
              darkModeOption: _darkModeOption,
              onDarkModeChanged: _changeDarkMode,
              prefs: widget.prefs,
            ),
    );
  }
}
