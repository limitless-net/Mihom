import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/mihom_theme.dart';
import '../i18n.dart';

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
