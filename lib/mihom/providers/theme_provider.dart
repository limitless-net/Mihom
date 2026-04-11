/// Mihom 主题状态管理 (Riverpod)
///
/// 管理当前主题、深色模式选项，持久化到 SharedPreferences
library;

import 'package:flutter/material.dart' show Brightness;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/mihom_theme.dart';

// ═══════════════════════════════════════════════════
//  SharedPreferences Provider
// ═══════════════════════════════════════════════════

/// 异步获取 SharedPreferences 实例
final sharedPrefsFutureProvider = FutureProvider<SharedPreferences>((ref) {
  return SharedPreferences.getInstance();
});

// ═══════════════════════════════════════════════════
//  Theme State
// ═══════════════════════════════════════════════════

class MihomThemeState {
  final MihomTheme baseTheme;
  final int darkModeOption; // 0=跟随系统 1=浅色 2=深色
  final bool isFirstLaunch;

  const MihomThemeState({
    required this.baseTheme,
    this.darkModeOption = 0,
    this.isFirstLaunch = false,
  });

  MihomThemeState copyWith({
    MihomTheme? baseTheme,
    int? darkModeOption,
    bool? isFirstLaunch,
  }) {
    return MihomThemeState(
      baseTheme: baseTheme ?? this.baseTheme,
      darkModeOption: darkModeOption ?? this.darkModeOption,
      isFirstLaunch: isFirstLaunch ?? this.isFirstLaunch,
    );
  }
}

// ═══════════════════════════════════════════════════
//  Desktop Theme Provider
// ═══════════════════════════════════════════════════

final desktopThemeProvider = StateNotifierProvider<DesktopThemeNotifier, MihomThemeState>((ref) {
  final prefsAsync = ref.watch(sharedPrefsFutureProvider);
  final prefs = prefsAsync.value;
  if (prefs == null) {
    return DesktopThemeNotifier.empty();
  }
  return DesktopThemeNotifier(prefs);
});

class DesktopThemeNotifier extends StateNotifier<MihomThemeState> {
  SharedPreferences? _prefs;

  DesktopThemeNotifier(SharedPreferences prefs)
      : _prefs = prefs,
        super(_loadFromPrefs(prefs, 'mihom_desktop_theme', 'mihom_desktop_dark'));

  DesktopThemeNotifier.empty()
      : _prefs = null,
        super(MihomThemeState(baseTheme: MihomTheme.azure, isFirstLaunch: true));

  static MihomThemeState _loadFromPrefs(SharedPreferences prefs, String themeKey, String darkKey) {
    final savedName = prefs.getString(themeKey);
    final darkMode = prefs.getInt(darkKey) ?? 0;
    final theme = MihomTheme.all.firstWhere(
      (t) => t.name == savedName,
      orElse: () => MihomTheme.azure,
    );
    return MihomThemeState(
      baseTheme: theme,
      darkModeOption: darkMode,
      isFirstLaunch: savedName == null,
    );
  }

  void changeTheme(MihomTheme theme) {
    _prefs?.setString('mihom_desktop_theme', theme.name);
    state = state.copyWith(baseTheme: theme);
    // 自动调整深色模式
    if (theme.isDark && state.darkModeOption != 2) changeDarkMode(2);
    if (!theme.isDark && state.darkModeOption == 2) changeDarkMode(1);
  }

  void changeDarkMode(int option) {
    _prefs?.setInt('mihom_desktop_dark', option);
    state = state.copyWith(darkModeOption: option);
  }

  void completeFirstLaunch() {
    state = state.copyWith(isFirstLaunch: false);
  }

  /// 退出登录时清除主题设置，下次启动将重新显示引导页
  void clearForLogout() {
    _prefs?.remove('mihom_desktop_theme');
    _prefs?.remove('mihom_desktop_dark');
  }
}

// ═══════════════════════════════════════════════════
//  Mobile Theme Provider
// ═══════════════════════════════════════════════════

final mobileThemeProvider = StateNotifierProvider<MobileThemeNotifier, MihomThemeState>((ref) {
  final prefsAsync = ref.watch(sharedPrefsFutureProvider);
  final prefs = prefsAsync.value;
  if (prefs == null) {
    return MobileThemeNotifier.empty();
  }
  return MobileThemeNotifier(prefs);
});

class MobileThemeNotifier extends StateNotifier<MihomThemeState> {
  SharedPreferences? _prefs;

  MobileThemeNotifier(SharedPreferences prefs)
      : _prefs = prefs,
        super(_loadFromPrefs(prefs, 'mihom_theme', 'mihom_dark_mode'));

  MobileThemeNotifier.empty()
      : _prefs = null,
        super(MihomThemeState(baseTheme: MihomTheme.azure, isFirstLaunch: true));

  static MihomThemeState _loadFromPrefs(SharedPreferences prefs, String themeKey, String darkKey) {
    final savedName = prefs.getString(themeKey);
    final darkMode = prefs.getInt(darkKey) ?? 0;
    final theme = MihomTheme.all.firstWhere(
      (t) => t.name == savedName,
      orElse: () => MihomTheme.azure,
    );
    return MihomThemeState(
      baseTheme: theme,
      darkModeOption: darkMode,
      isFirstLaunch: savedName == null,
    );
  }

  void changeTheme(MihomTheme theme) {
    _prefs?.setString('mihom_theme', theme.name);
    state = state.copyWith(baseTheme: theme);
    if (theme.isDark && state.darkModeOption != 2) changeDarkMode(2);
    if (!theme.isDark && state.darkModeOption == 2) changeDarkMode(1);
  }

  void changeDarkMode(int option) {
    _prefs?.setInt('mihom_dark_mode', option);
    state = state.copyWith(darkModeOption: option);
  }

  void completeFirstLaunch() {
    state = state.copyWith(isFirstLaunch: false);
  }

  void clearForLogout() {
    _prefs?.remove('mihom_theme');
    _prefs?.remove('mihom_dark_mode');
  }
}

// ═══════════════════════════════════════════════════
//  Theme Resolution Helper
// ═══════════════════════════════════════════════════

/// 根据 darkModeOption 和系统亮度解析最终主题
MihomTheme resolveTheme(MihomThemeState themeState, Brightness systemBrightness) {
  switch (themeState.darkModeOption) {
    case 1:
      return themeState.baseTheme.isDark ? MihomTheme.azure : themeState.baseTheme;
    case 2:
      return MihomTheme.night;
    default:
      return systemBrightness == Brightness.dark
          ? MihomTheme.night
          : (themeState.baseTheme.isDark ? MihomTheme.azure : themeState.baseTheme);
  }
}
