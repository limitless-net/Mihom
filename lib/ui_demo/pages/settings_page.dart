import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../mihom_theme.dart';
import '../main_demo.dart';
import '../i18n.dart';
import '../pill_toast.dart';

class DemoSettingsPage extends StatefulWidget {
  final MihomTheme theme;
  final ValueChanged<MihomTheme> onThemeChanged;
  final int darkModeOption;
  final ValueChanged<int> onDarkModeChanged;
  const DemoSettingsPage({super.key, required this.theme, required this.onThemeChanged, required this.darkModeOption, required this.onDarkModeChanged});

  @override
  State<DemoSettingsPage> createState() => _DemoSettingsPageState();
}

class _DemoSettingsPageState extends State<DemoSettingsPage> {
  bool _autoStart = true;
  bool _tunMode = true;
  bool _ipv6 = false;
  int _proxyMode = 0;
  int _dnsMode = 0;
  late int _localDarkMode;

  @override
  void initState() {
    super.initState();
    _localDarkMode = widget.darkModeOption;
  }

  MihomTheme get t => widget.theme;

  static const _darkModeLabels_zh = ['跟随系统', '浅色', '深色'];
  static const _darkModeLabels_en = ['Follow System', 'Light', 'Dark'];
  List<String> get _darkModeLabels => S.isEn ? _darkModeLabels_en : _darkModeLabels_zh;

  @override
  Widget build(BuildContext context) {
    final proxyLabels = S.isEn ? ['Rule', 'Global', 'Direct', 'Campus'] : ['规则', '全局', '直连', '校园网'];
    final dnsLabels = S.isEn ? ['Auto', 'Custom'] : ['自动', '自定义'];
    return Scaffold(
      backgroundColor: t.scaffoldBg,
      body: Container(
        decoration: t.scaffoldGradient != null ? BoxDecoration(gradient: t.scaffoldGradient) : null,
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 24, 0),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back_ios_new, color: t.textPrimary, size: 20),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    Text(S.settings, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: t.textPrimary)),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _section(S.proxy, [
                        _tileSelectable(Icons.route, S.proxyMode, proxyLabels[_proxyMode], () {
                          _showSelector(S.proxyMode, proxyLabels, _proxyMode, (i) => setState(() => _proxyMode = i));
                        }),
                        _tileSelectable(Icons.dns, S.customDns, dnsLabels[_dnsMode], () {
                          _showSelector(S.customDns, dnsLabels, _dnsMode, (i) => setState(() => _dnsMode = i));
                        }),
                        _tileNav(Icons.tune, S.perAppProxy),
                      ]),
                      const SizedBox(height: 16),

                      _section(S.general, [
                        _tileSelectable(Icons.dark_mode, S.darkMode, _darkModeLabels[_localDarkMode], () {
                          _showSelector(S.darkMode, _darkModeLabels, _localDarkMode, (i) {
                            widget.onDarkModeChanged(i);
                            setState(() => _localDarkMode = i);
                          });
                        }),
                        _tileSelectable(Icons.language, S.language, S.isEn ? 'English' : '简体中文', () {
                          _showSelector(S.language, ['简体中文', 'English'], S.isEn ? 1 : 0, (i) {
                            S.setLocale(i == 1 ? const Locale('en') : const Locale('zh'));
                            setState(() {});
                          });
                        }),
                        _tileTheme(Icons.color_lens_outlined, S.themeStyle),
                        _tileToggle(Icons.play_circle_outline, S.autoStart, _autoStart, (v) => setState(() => _autoStart = v)),
                      ]),
                      const SizedBox(height: 16),

                      _section(S.network, [
                        _tileNav(Icons.cloud_sync, S.webdavSync),
                        _tileToggle(Icons.vpn_key, S.tunMode, _tunMode, (v) => setState(() => _tunMode = v)),
                        _tileToggle(Icons.security, 'IPv6', _ipv6, (v) => setState(() => _ipv6 = v)),
                      ]),
                      const SizedBox(height: 16),

                      _section(S.other, [
                        _tileNav(Icons.bug_report, S.debugLog),
                        _tileTap(Icons.delete_outline, S.clearCache, '23.4 MB', () {
                          showPillToast(context, t, S.cacheCleared);
                        }),
                        _tileTap(Icons.update, S.checkUpdate, 'v1.0.0', () {
                          showUpdateDialog(context, t);
                        }),
                      ]),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── sections ──

  Widget _section(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: t.textSecondary.withValues(alpha: 0.7))),
        ),
        Container(
          decoration: BoxDecoration(
            color: t.cardBg, borderRadius: BorderRadius.circular(t.cardRadius),
            border: t.cardBorder, boxShadow: t.cardShadow,
          ),
          child: Column(
            children: items.asMap().entries.map((e) {
              final isLast = e.key == items.length - 1;
              return Column(children: [
                e.value,
                if (!isLast) Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 56),
                  child: Divider(height: 1, color: t.textHint.withValues(alpha: 0.15)),
                ),
              ]);
            }).toList(),
          ),
        ),
      ],
    );
  }

  // ── tile variants ──

  Widget _tileToggle(IconData icon, String title, bool value, ValueChanged<bool> onChanged) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onChanged(!value);
      },
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: t.textSecondary, size: 22),
            const SizedBox(width: 14),
            Expanded(child: Text(title, style: TextStyle(fontSize: 15, color: t.textPrimary))),
            _animatedToggle(value),
          ],
        ),
      ),
    );
  }

  Widget _tileSelectable(IconData icon, String title, String current, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: t.textSecondary, size: 22),
            const SizedBox(width: 14),
            Expanded(child: Text(title, style: TextStyle(fontSize: 15, color: t.textPrimary))),
            _chip(current),
          ],
        ),
      ),
    );
  }

  Widget _tileNav(IconData icon, String title, {String? subtitle}) {
    return GestureDetector(
      onTap: () {
        showPillToast(context, t, '$title · ${S.devInProgress}');
      },
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: t.textSecondary, size: 22),
            const SizedBox(width: 14),
            Expanded(child: Text(title, style: TextStyle(fontSize: 15, color: t.textPrimary))),
            if (subtitle != null) Text(subtitle, style: TextStyle(fontSize: 13, color: t.textHint)),
            if (subtitle != null) const SizedBox(width: 4),
            Icon(Icons.chevron_right, size: 18, color: t.textHint),
          ],
        ),
      ),
    );
  }

  Widget _tileTheme(IconData icon, String title) {
    return GestureDetector(
      onTap: () => showThemeDialog(context, t, widget.onThemeChanged),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: t.textSecondary, size: 22),
            const SizedBox(width: 14),
            Expanded(child: Text(title, style: TextStyle(fontSize: 15, color: t.textPrimary))),
            _themeDots(),
          ],
        ),
      ),
    );
  }

  Widget _tileTap(IconData icon, String title, String info, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: t.textSecondary, size: 22),
            const SizedBox(width: 14),
            Expanded(child: Text(title, style: TextStyle(fontSize: 15, color: t.textPrimary))),
            Text(info, style: TextStyle(fontSize: 13, color: t.textHint)),
          ],
        ),
      ),
    );
  }

  // ── helpers ──

  Widget _chip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: t.primary.withValues(alpha: t.isDark ? 0.15 : 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label, style: TextStyle(fontSize: 12, color: t.primary, fontWeight: FontWeight.w600)),
    );
  }

  Widget _animatedToggle(bool value) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: 44, height: 26,
      decoration: BoxDecoration(
        gradient: value ? t.buttonGradient : null,
        color: value ? null : (t.isDark ? const Color(0xFF2A2D45) : const Color(0xFFE0E0E0)),
        borderRadius: BorderRadius.circular(13),
      ),
      child: AnimatedAlign(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        alignment: value ? Alignment.centerRight : Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.all(3),
          child: Container(width: 20, height: 20, decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white)),
        ),
      ),
    );
  }

  Widget _themeDots() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: MihomTheme.all.map((th) {
        final isActive = th.name == t.name;
        return Container(
          width: 18, height: 18,
          margin: const EdgeInsets.only(left: 5),
          decoration: BoxDecoration(
            gradient: th.primaryGradient, shape: BoxShape.circle,
            border: isActive ? Border.all(color: Colors.white, width: 2) : null,
            boxShadow: isActive ? [BoxShadow(color: th.primary.withValues(alpha: 0.4), blurRadius: 6)] : null,
          ),
        );
      }).toList(),
    );
  }

  void _showSelector(String title, List<String> items, int current, ValueChanged<int> onSelect) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '关闭',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 250),
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
              width: MediaQuery.of(ctx).size.width * 0.72,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: t.cardBg, borderRadius: BorderRadius.circular(20),
                border: t.cardBorder,
                boxShadow: [BoxShadow(color: t.primary.withValues(alpha: 0.15), blurRadius: 30)],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ...items.asMap().entries.map((e) {
                    final isActive = e.key == current;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          onSelect(e.key);
                          Navigator.of(ctx).pop();
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          decoration: BoxDecoration(
                            gradient: isActive ? t.buttonGradient : null,
                            color: isActive ? null : (t.isDark ? const Color(0xFF1C1F3A) : const Color(0xFFF5F7FF)),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(e.value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: isActive ? Colors.white : t.textPrimary)),
                              if (isActive) ...[
                                const SizedBox(width: 8),
                                const Icon(Icons.check, color: Colors.white, size: 18),
                              ],
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
}

// ══════════════════════════════════════════════════
//  检测更新版本弹窗
// ══════════════════════════════════════════════════

void showUpdateDialog(BuildContext context, MihomTheme t) {
  HapticFeedback.mediumImpact();
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: '关闭',
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
          width: MediaQuery.of(ctx).size.width * 0.84,
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
              // 图标
              Container(
                width: 56, height: 56,
                decoration: BoxDecoration(
                  gradient: t.primaryGradient,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.system_update, color: Colors.white, size: 28),
              ),
              const SizedBox(height: 16),
              Text(S.newVersion, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: t.textPrimary)),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(color: t.textHint.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)),
                    child: Text('v1.0.0', style: TextStyle(fontSize: 12, color: t.textHint)),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Icon(Icons.arrow_forward, size: 14, color: t.textHint),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(color: t.primary.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)),
                    child: Text('v1.2.0', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: t.primary)),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // 更新日志
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: t.isDark ? const Color(0xFF1E2140) : const Color(0xFFF5F7FA),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(S.changelog, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: t.textSecondary)),
                    const SizedBox(height: 10),
                    _updateLogItem(t, S.updateLog1),
                    _updateLogItem(t, S.updateLog2),
                    _updateLogItem(t, S.updateLog3),
                    _updateLogItem(t, S.updateLog4),
                    _updateLogItem(t, S.updateLog5),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // 包大小
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.download, size: 14, color: t.textHint),
                  const SizedBox(width: 4),
                  Text('${S.packageSize}: 32.6 MB', style: TextStyle(fontSize: 12, color: t.textHint)),
                ],
              ),
              const SizedBox(height: 18),

              // 立即更新按钮
              GestureDetector(
                onTap: () {
                  HapticFeedback.mediumImpact();
                  Navigator.of(ctx).pop();
                  showPillToast(context, t, S.downloading);
                },
                child: Container(
                  width: double.infinity, height: 48,
                  decoration: BoxDecoration(
                    gradient: t.buttonGradient,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [BoxShadow(color: t.primary.withValues(alpha: 0.25), blurRadius: 14, offset: const Offset(0, 4))],
                  ),
                  child: Center(
                    child: Text(S.updateNow, style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // 稍后更新
              GestureDetector(
                onTap: () => Navigator.of(ctx).pop(),
                child: Container(
                  width: double.infinity, height: 42,
                  decoration: BoxDecoration(
                    color: t.textHint.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(S.updateLater, style: TextStyle(color: t.textSecondary, fontSize: 14, fontWeight: FontWeight.w600)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

Widget _updateLogItem(MihomTheme t, String text) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 3),
          child: Icon(Icons.check_circle, size: 13, color: t.success),
        ),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: TextStyle(fontSize: 13, color: t.textPrimary, height: 1.3))),
      ],
    ),
  );
}
