import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fl_clash/mihom/theme/mihom_theme.dart';
import 'package:fl_clash/mihom/providers/theme_provider.dart';
import 'package:fl_clash/mihom/i18n.dart';
import '../models/update_check_state.dart';
class UpdateDialog extends ConsumerWidget {
  final UpdateCheckState state;
  const UpdateDialog({super.key, required this.state});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(desktopThemeProvider).baseTheme;
    
    return Container(
      width: 420,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: t.cardBg,
        borderRadius: BorderRadius.circular(24),
        border: t.cardBorder,
        boxShadow: [BoxShadow(color: t.primary.withValues(alpha: 0.15), blurRadius: 30)],
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 图标
            Container(
              width: 56, height: 56,
              decoration: BoxDecoration(
                gradient: state.forceUpdate ? null : t.primaryGradient,
                color: state.forceUpdate ? t.danger : null,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                state.forceUpdate ? Icons.warning_rounded : Icons.system_update,
                color: Colors.white, size: 28,
              ),
            ),
            const SizedBox(height: 16),
            // 标题
            Text(
              S.newVersion,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: state.forceUpdate ? t.danger : t.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            // 版本对比
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: t.textHint.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'v${state.currentVersion ?? ''}',
                    style: TextStyle(fontSize: 12, color: t.textHint),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Icon(Icons.arrow_forward, size: 14, color: t.textHint),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: t.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'v${state.latestVersion ?? ''}',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: t.primary),
                  ),
                ),
              ],
            ),
            // 更新日志
            if (state.releaseNotes != null && state.releaseNotes!.isNotEmpty) ...[
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxHeight: 160),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: t.isDark ? const Color(0xFF1E2140) : const Color(0xFFF5F7FA),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        S.changelog,
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: t.textSecondary),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        state.releaseNotes!,
                        style: TextStyle(fontSize: 13, color: t.textPrimary, height: 1.4),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 18),
            // 更新按钮
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.mediumImpact();
                  if (state.updateUrl != null) {
                    _launchUrl(state.updateUrl!);
                  }
                  if (!state.forceUpdate) {
                    Navigator.of(context).pop();
                  }
                },
                child: Container(
                  width: double.infinity, height: 48,
                  decoration: BoxDecoration(
                    gradient: state.forceUpdate ? null : t.buttonGradient,
                    color: state.forceUpdate ? t.danger : null,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: (state.forceUpdate ? t.danger : t.primary).withValues(alpha: 0.25),
                        blurRadius: 14,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      S.updateNow,
                      style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),
            ),
            // 稍后更新按钮（非强制时）
            if (!state.forceUpdate) ...[
              const SizedBox(height: 10),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: double.infinity, height: 42,
                    decoration: BoxDecoration(
                      color: t.textHint.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Text(
                        S.updateLater,
                        style: TextStyle(color: t.textSecondary, fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}