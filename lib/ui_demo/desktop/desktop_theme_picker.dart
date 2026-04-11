import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../mihom_theme.dart';
import '../i18n.dart';

/// 桌面端首次启动主题选择器
class DesktopThemePicker extends StatelessWidget {
  final MihomTheme currentTheme;
  final ValueChanged<MihomTheme> onThemeChanged;
  final VoidCallback onConfirm;

  const DesktopThemePicker({
    super.key,
    required this.currentTheme,
    required this.onThemeChanged,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      body: Center(
        child: Container(
          width: 520,
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 52, height: 52,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFF1A237E), Color(0xFF00BCD4)]),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(7),
                      child: Image.asset('lib/ui_demo/branding/icon_white.png', fit: BoxFit.contain),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Mihom Desktop', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1A237E))),
                      Text(S.selectYourStyle, style: const TextStyle(fontSize: 15, color: Color(0xFF5C6BC0))),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 36),
              Text(S.uiStyle, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A237E))),
              const SizedBox(height: 4),
              Text(S.canSwitchLater, style: const TextStyle(fontSize: 13, color: Color(0xFF9FA8DA))),
              const SizedBox(height: 24),

              // 4 个主题横排
              Row(
                children: MihomTheme.all.map((theme) {
                  final isSelected = currentTheme.name == theme.name;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          onThemeChanged(theme);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: isSelected
                                ? Border.all(color: theme.primary, width: 2.5)
                                : Border.all(color: Colors.transparent, width: 2.5),
                            boxShadow: [
                              BoxShadow(
                                color: isSelected ? theme.primary.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.04),
                                blurRadius: isSelected ? 20 : 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Container(
                                width: 44, height: 44,
                                decoration: BoxDecoration(gradient: theme.primaryGradient, borderRadius: BorderRadius.circular(13)),
                                child: Icon(theme.icon, color: Colors.white, size: 22),
                              ),
                              const SizedBox(height: 10),
                              Text(S.isEn ? theme.nameEn : theme.name,
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1A237E)),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 2),
                              Text(S.isEn ? theme.subtitleEn : theme.subtitle,
                                style: const TextStyle(fontSize: 10, color: Color(0xFF9FA8DA)),
                                textAlign: TextAlign.center, maxLines: 2,
                              ),
                              if (isSelected) ...[
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.all(3),
                                  decoration: BoxDecoration(gradient: theme.primaryGradient, shape: BoxShape.circle),
                                  child: const Icon(Icons.check, color: Colors.white, size: 14),
                                ),
                              ] else
                                const SizedBox(height: 25),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: 240, height: 48,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: currentTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [BoxShadow(color: currentTheme.primary.withValues(alpha: 0.3), blurRadius: 16, offset: const Offset(0, 4))],
                  ),
                  child: ElevatedButton(
                    onPressed: onConfirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent, shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text(S.enterMihom, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
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
