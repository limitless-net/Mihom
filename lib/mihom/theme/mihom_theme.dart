import 'package:flutter/material.dart';

/// Mihom UI 主题参数
/// 三套主题共享同一套 Widget 结构，通过此类控制全部视觉差异
class MihomTheme {
  final String name;
  final String nameEn;
  final String subtitle;
  final String subtitleEn;
  final IconData icon;

  // 背景
  final Color scaffoldBg;
  final Color cardBg;
  final Gradient? scaffoldGradient; // 可选背景渐变

  // 主色调
  final Color primary;
  final Color secondary;
  final Gradient primaryGradient;
  final Gradient buttonGradient;

  // 文字
  final Color textPrimary;
  final Color textSecondary;
  final Color textHint;

  // 状态
  final Color success;
  final Color warning;
  final Color danger;

  // 卡片样式
  final double cardRadius;
  final List<BoxShadow> cardShadow;
  final Border? cardBorder;
  final Color? cardOverlayColor; // 毛玻璃叠加色

  // 导航栏
  final Color navBg;
  final Color navActive;
  final Color navInactive;
  final Gradient navActiveGradient;

  // 大按钮
  final Gradient connectedGradient;
  final Gradient disconnectedGradient;
  final Color connectedGlow;
  final Color disconnectedGlow;

  // 用户卡片
  final Gradient userCardGradient;

  // 节点选中
  final Gradient nodeSelectedGradient;

  // 是否深色
  final bool isDark;

  const MihomTheme({
    required this.name,
    required this.nameEn,
    required this.subtitle,
    required this.subtitleEn,
    required this.icon,
    required this.scaffoldBg,
    required this.cardBg,
    this.scaffoldGradient,
    required this.primary,
    required this.secondary,
    required this.primaryGradient,
    required this.buttonGradient,
    required this.textPrimary,
    required this.textSecondary,
    required this.textHint,
    required this.success,
    required this.warning,
    required this.danger,
    required this.cardRadius,
    required this.cardShadow,
    this.cardBorder,
    this.cardOverlayColor,
    required this.navBg,
    required this.navActive,
    required this.navInactive,
    required this.navActiveGradient,
    required this.connectedGradient,
    required this.disconnectedGradient,
    required this.connectedGlow,
    required this.disconnectedGlow,
    required this.userCardGradient,
    required this.nodeSelectedGradient,
    this.isDark = false,
  });

  // ═════════════════════════════════════
  //  蔚蓝 (Azure) - 蓝白极简
  // ═════════════════════════════════════
  static final azure = MihomTheme(
    name: '蔚蓝',
    nameEn: 'Azure',
    subtitle: '清爽极简 · 蓝白配色',
    subtitleEn: 'Clean & minimal · Blue-white',
    icon: Icons.water_drop,

    scaffoldBg: const Color(0xFFF6F9FF),
    cardBg: Colors.white,

    primary: const Color(0xFF1565C0),
    secondary: const Color(0xFF00BCD4),
    primaryGradient: const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF1A237E), Color(0xFF1565C0), Color(0xFF00BCD4)],
    ),
    buttonGradient: const LinearGradient(
      colors: [Color(0xFF1565C0), Color(0xFF00BCD4)],
    ),

    textPrimary: const Color(0xFF1A237E),
    textSecondary: const Color(0xFF5C6BC0),
    textHint: const Color(0xFF9FA8DA),

    success: const Color(0xFF00C853),
    warning: const Color(0xFFFFAB00),
    danger: const Color(0xFFFF5252),

    cardRadius: 16,
    cardShadow: [
      BoxShadow(
        color: const Color(0xFF1565C0).withValues(alpha: 0.06),
        blurRadius: 20,
      ),
    ],

    navBg: Colors.white,
    navActive: Colors.white,
    navInactive: const Color(0xFF9FA8DA),
    navActiveGradient: const LinearGradient(colors: [Color(0xFF1565C0), Color(0xFF00BCD4)]),

    connectedGradient: const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF00C853), Color(0xFF00BCD4)],
    ),
    disconnectedGradient: const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF1A237E), Color(0xFF1565C0), Color(0xFF00BCD4)],
    ),
    connectedGlow: const Color(0xFF00C853),
    disconnectedGlow: const Color(0xFF1565C0),

    userCardGradient: const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF1A237E), Color(0xFF1565C0), Color(0xFF00BCD4)],
    ),

    nodeSelectedGradient: const LinearGradient(
      colors: [Color(0xFF1565C0), Color(0xFF00BCD4)],
    ),
  );

  // ═════════════════════════════════════
  //  暖阳 (Warm) - 柔和暖色
  // ═════════════════════════════════════
  static final warm = MihomTheme(
    name: '暖阳',
    nameEn: 'Warm Sun',
    subtitle: '温柔友好 · 暖橘配色',
    subtitleEn: 'Warm & friendly · Orange tone',
    icon: Icons.wb_sunny,

    scaffoldBg: const Color(0xFFFFF8F3),
    cardBg: Colors.white,

    primary: const Color(0xFFFF6D00),
    secondary: const Color(0xFFFF8A65),
    primaryGradient: const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFE65100), Color(0xFFFF6D00), Color(0xFFFFAB40)],
    ),
    buttonGradient: const LinearGradient(
      colors: [Color(0xFFFF6D00), Color(0xFFFFAB40)],
    ),

    textPrimary: const Color(0xFF3E2723),
    textSecondary: const Color(0xFF795548),
    textHint: const Color(0xFFBCAAA4),

    success: const Color(0xFF66BB6A),
    warning: const Color(0xFFFFCA28),
    danger: const Color(0xFFEF5350),

    cardRadius: 20,
    cardShadow: [
      BoxShadow(
        color: const Color(0xFFFF6D00).withValues(alpha: 0.08),
        blurRadius: 24,
        offset: const Offset(0, 4),
      ),
    ],

    navBg: Colors.white,
    navActive: Colors.white,
    navInactive: const Color(0xFFBCAAA4),
    navActiveGradient: const LinearGradient(colors: [Color(0xFFFF6D00), Color(0xFFFFAB40)]),

    connectedGradient: const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF66BB6A), Color(0xFF81C784)],
    ),
    disconnectedGradient: const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFE65100), Color(0xFFFF6D00), Color(0xFFFFAB40)],
    ),
    connectedGlow: const Color(0xFF66BB6A),
    disconnectedGlow: const Color(0xFFFF6D00),

    userCardGradient: const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFE65100), Color(0xFFFF6D00), Color(0xFFFFAB40)],
    ),

    nodeSelectedGradient: const LinearGradient(
      colors: [Color(0xFFFF6D00), Color(0xFFFFAB40)],
    ),
  );

  // ═════════════════════════════════════
  //  星空 (Night) - 深色毛玻璃
  // ═════════════════════════════════════
  static final night = MihomTheme(
    name: '星空',
    nameEn: 'Starry Night',
    subtitle: '深邃优雅 · 暗夜配色',
    subtitleEn: 'Deep & elegant · Dark mode',
    icon: Icons.dark_mode,

    scaffoldBg: const Color(0xFF0A0E21),
    cardBg: const Color(0xFF1C1F3A),
    scaffoldGradient: const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF0A0E21), Color(0xFF141833)],
    ),

    primary: const Color(0xFF00E5FF),
    secondary: const Color(0xFF7C4DFF),
    primaryGradient: const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF7C4DFF), Color(0xFF00E5FF)],
    ),
    buttonGradient: const LinearGradient(
      colors: [Color(0xFF7C4DFF), Color(0xFF00E5FF)],
    ),

    textPrimary: const Color(0xFFE8EAF6),
    textSecondary: const Color(0xFF9FA8DA),
    textHint: const Color(0xFF5C6BC0),

    success: const Color(0xFF00E676),
    warning: const Color(0xFFFFD740),
    danger: const Color(0xFFFF5252),

    cardRadius: 18,
    cardShadow: [
      BoxShadow(
        color: const Color(0xFF7C4DFF).withValues(alpha: 0.1),
        blurRadius: 20,
      ),
    ],
    cardBorder: Border.all(
      color: const Color(0xFF7C4DFF).withValues(alpha: 0.15),
      width: 1,
    ),

    navBg: const Color(0xFF0F1229),
    navActive: Colors.white,
    navInactive: const Color(0xFF5C6BC0),
    navActiveGradient: const LinearGradient(colors: [Color(0xFF7C4DFF), Color(0xFF00E5FF)]),

    connectedGradient: const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF00E676), Color(0xFF00E5FF)],
    ),
    disconnectedGradient: const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF7C4DFF), Color(0xFF00E5FF)],
    ),
    connectedGlow: const Color(0xFF00E676),
    disconnectedGlow: const Color(0xFF7C4DFF),

    userCardGradient: const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF1A237E), Color(0xFF7C4DFF), Color(0xFF00E5FF)],
    ),

    nodeSelectedGradient: const LinearGradient(
      colors: [Color(0xFF7C4DFF), Color(0xFF00E5FF)],
    ),

    isDark: true,
  );

  // ═════════════════════════════════════
  //  樱花 (Sakura) - 浅色粉色系
  // ═════════════════════════════════════
  static final sakura = MihomTheme(
    name: '樱花',
    nameEn: 'Sakura',
    subtitle: '浪漫柔美 · 樱花粉色',
    subtitleEn: 'Romantic & soft · Cherry blossom',
    icon: Icons.local_florist,

    scaffoldBg: const Color(0xFFFFF5F7),
    cardBg: Colors.white,

    primary: const Color(0xFFE91E63),
    secondary: const Color(0xFFF48FB1),
    primaryGradient: const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFC2185B), Color(0xFFE91E63), Color(0xFFF06292)],
    ),
    buttonGradient: const LinearGradient(
      colors: [Color(0xFFE91E63), Color(0xFFF06292)],
    ),

    textPrimary: const Color(0xFF4A1942),
    textSecondary: const Color(0xFF8E4585),
    textHint: const Color(0xFFCE93D8),

    success: const Color(0xFF66BB6A),
    warning: const Color(0xFFFFCA28),
    danger: const Color(0xFFEF5350),

    cardRadius: 18,
    cardShadow: [
      BoxShadow(
        color: const Color(0xFFE91E63).withValues(alpha: 0.08),
        blurRadius: 22,
        offset: const Offset(0, 4),
      ),
    ],

    navBg: Colors.white,
    navActive: Colors.white,
    navInactive: const Color(0xFFCE93D8),
    navActiveGradient: const LinearGradient(colors: [Color(0xFFE91E63), Color(0xFFF06292)]),

    connectedGradient: const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF66BB6A), Color(0xFF81C784)],
    ),
    disconnectedGradient: const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFC2185B), Color(0xFFE91E63), Color(0xFFF06292)],
    ),
    connectedGlow: const Color(0xFF66BB6A),
    disconnectedGlow: const Color(0xFFE91E63),

    userCardGradient: const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFC2185B), Color(0xFFE91E63), Color(0xFFF06292)],
    ),

    nodeSelectedGradient: const LinearGradient(
      colors: [Color(0xFFE91E63), Color(0xFFF06292)],
    ),
  );

  static List<MihomTheme> get all => [azure, warm, sakura, night];
}
