import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_clash/controller.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/views/backup_and_restore.dart';
import 'package:fl_clash/views/access.dart';
import '../../theme/mihom_theme.dart';
import '../../i18n.dart';
import '../../widgets/pill_toast.dart';
import 'package:fl_clash/xboard/features/update_check/update_check.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

/// 桌面端设置页 — 双列 section 布局
class DesktopSettingsPage extends ConsumerStatefulWidget {
  final MihomTheme theme;
  final ValueChanged<MihomTheme> onThemeChanged;
  final int darkModeOption;
  final ValueChanged<int> onDarkModeChanged;
  final bool isGuest;
  final VoidCallback onLogout;
  final VoidCallback? onLogin;
  const DesktopSettingsPage({
    super.key,
    required this.theme,
    required this.onThemeChanged,
    required this.darkModeOption,
    required this.onDarkModeChanged,
    required this.isGuest,
    required this.onLogout,
    this.onLogin,
  });

  @override
  ConsumerState<DesktopSettingsPage> createState() => _DesktopSettingsPageState();
}

class _DesktopSettingsPageState extends ConsumerState<DesktopSettingsPage> {
  late int _localDarkMode;
  String _appVersion = '';

  @override
  void initState() {
    super.initState();
    _localDarkMode = widget.darkModeOption;
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    if (mounted) setState(() => _appVersion = info.version);
  }

  MihomTheme get t => widget.theme;

  // Read real values from providers
  bool get _autoStart => ref.watch(appSettingProvider.select((s) => s.autoLaunch));
  bool get _tunMode => ref.watch(patchClashConfigProvider.select((s) => s.tun.enable));
  bool get _ipv6 => ref.watch(patchClashConfigProvider.select((s) => s.ipv6));
  int get _proxyMode => ref.watch(patchClashConfigProvider.select((s) => s.mode)).index;
  bool get _overrideDns => ref.watch(overrideDnsProvider);

  static const _darkModeLabels_zh = ['跟随系统', '浅色', '深色'];
  static const _darkModeLabels_en = ['Follow System', 'Light', 'Dark'];
  List<String> get _darkModeLabels => S.isEn ? _darkModeLabels_en : _darkModeLabels_zh;

  @override
  Widget build(BuildContext context) {
    final proxyLabels = S.isEn ? ['Rule', 'Global'] : ['规则', '全局'];

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(S.settings, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: t.textPrimary)),
          const SizedBox(height: 20),

          Expanded(
            child: SingleChildScrollView(
              child: LayoutBuilder(builder: (ctx, constraints) {
                final wide = constraints.maxWidth > 640;
                if (wide) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 左列
                      Expanded(
                        child: Column(
                          children: [
                            _section(S.proxy, [
                              _tileSelectable(Icons.route, S.proxyMode, proxyLabels[_proxyMode],
                                () { if (widget.isGuest) { widget.onLogin?.call(); return; } _showSelector(S.proxyMode, proxyLabels, _proxyMode, (i) => appController.changeMode(Mode.values[i])); }),
                              if (system.isAndroid) _tileNav(Icons.tune, S.perAppProxy, onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AccessView()))),
                            ]),
                            const SizedBox(height: 20),
                            _section(S.network, [
                              _tileToggle(Icons.vpn_key, S.tunMode, _tunMode, (v) => ref.read(patchClashConfigProvider.notifier).update((state) => state.copyWith.tun(enable: v))),
                              _tileToggle(Icons.security, 'IPv6', _ipv6, (v) => ref.read(patchClashConfigProvider.notifier).update((state) => state.copyWith(ipv6: v))),
                            ]),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                      // 右列
                      Expanded(
                        child: Column(
                          children: [
                            _section(S.general, [
                              _tileSelectable(Icons.dark_mode, S.darkMode, _darkModeLabels[_localDarkMode],
                                () => _showSelector(S.darkMode, _darkModeLabels, _localDarkMode, (i) {
                                  widget.onDarkModeChanged(i);
                                  setState(() => _localDarkMode = i);
                                })),
                              _tileSelectable(Icons.language, S.language, S.isEn ? 'English' : '简体中文',
                                () => _showSelector(S.language, ['简体中文', 'English'], S.isEn ? 1 : 0, (i) {
                                  S.setLocale(i == 1 ? const Locale('en') : const Locale('zh'));
                                  setState(() {});
                                })),
                              _tileTheme(Icons.color_lens_outlined, S.themeStyle),
                              _tileToggle(Icons.play_circle_outline, S.autoStart, _autoStart, (v) => appController.updateAutoLaunch()),
                            ]),
                            const SizedBox(height: 20),
                            _section(S.other, [
                              _tileNav(Icons.bug_report, S.debugLog),
                              _tileTap(Icons.delete_outline, S.clearCache, '23.4 MB',
                                () => showPillToast(context, t, S.cacheCleared)),
                              _tileTap(Icons.update, S.checkUpdate, _appVersion.isNotEmpty ? 'v$_appVersion' : '',
                                () => _showUpdateDialog()),
                            ]),
                          ],
                        ),
                      ),
                    ],
                  );
                }
                // 窄屏单列
                return Column(
                  children: [
                    _section(S.proxy, [
                      _tileSelectable(Icons.route, S.proxyMode, proxyLabels[_proxyMode],
                        () { if (widget.isGuest) { widget.onLogin?.call(); return; } _showSelector(S.proxyMode, proxyLabels, _proxyMode, (i) => appController.changeMode(Mode.values[i])); }),
                      if (system.isAndroid) _tileNav(Icons.tune, S.perAppProxy, onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AccessView()))),
                    ]),
                    const SizedBox(height: 16),
                    _section(S.general, [
                      _tileSelectable(Icons.dark_mode, S.darkMode, _darkModeLabels[_localDarkMode],
                        () => _showSelector(S.darkMode, _darkModeLabels, _localDarkMode, (i) {
                          widget.onDarkModeChanged(i);
                          setState(() => _localDarkMode = i);
                        })),
                      _tileSelectable(Icons.language, S.language, S.isEn ? 'English' : '简体中文',
                        () => _showSelector(S.language, ['简体中文', 'English'], S.isEn ? 1 : 0, (i) {
                          S.setLocale(i == 1 ? const Locale('en') : const Locale('zh'));
                          setState(() {});
                        })),
                      _tileTheme(Icons.color_lens_outlined, S.themeStyle),
                      _tileToggle(Icons.play_circle_outline, S.autoStart, _autoStart, (v) => appController.updateAutoLaunch()),
                    ]),
                    const SizedBox(height: 16),
                    _section(S.network, [
                      _tileToggle(Icons.vpn_key, S.tunMode, _tunMode, (v) => ref.read(patchClashConfigProvider.notifier).update((state) => state.copyWith.tun(enable: v))),
                      _tileToggle(Icons.security, 'IPv6', _ipv6, (v) => ref.read(patchClashConfigProvider.notifier).update((state) => state.copyWith(ipv6: v))),
                    ]),
                    const SizedBox(height: 16),
                    _section(S.other, [
                      _tileNav(Icons.bug_report, S.debugLog),
                      _tileTap(Icons.delete_outline, S.clearCache, '23.4 MB',
                        () => showPillToast(context, t, S.cacheCleared)),
                      _tileTap(Icons.update, S.checkUpdate, _appVersion.isNotEmpty ? 'v$_appVersion' : '',
                        () => _showUpdateDialog()),
                    ]),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  // ── Section ──

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

  // ── Tile 变体 ──

  Widget _tileToggle(IconData icon, String title, bool value, ValueChanged<bool> onChanged) {
    return GestureDetector(
      onTap: () { HapticFeedback.lightImpact(); onChanged(!value); },
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

  Widget _tileNav(IconData icon, String title, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap ?? () => showPillToast(context, t, '$title · ${S.devInProgress}'),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: t.textSecondary, size: 22),
            const SizedBox(width: 14),
            Expanded(child: Text(title, style: TextStyle(fontSize: 15, color: t.textPrimary))),
            Icon(Icons.chevron_right, size: 18, color: t.textHint),
          ],
        ),
      ),
    );
  }

  Widget _tileTheme(IconData icon, String title) {
    return GestureDetector(
      onTap: () => _showThemeDialog(),
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

  // ── 帮助组件 ──

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

  // ── 选择器弹窗 ──

  void _showSelector(String title, List<String> items, int current, ValueChanged<int> onSelect) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'close',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 80),
      transitionBuilder: (ctx, a1, a2, child) =>
        Transform.scale(scale: Curves.easeOut.transform(a1.value), child: Opacity(opacity: a1.value, child: child)),
      pageBuilder: (ctx, a1, a2) => Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: 240,
            padding: const EdgeInsets.all(16),
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
      ),
    );
  }

  // ── 主题选择弹窗 ──

  void _showThemeDialog() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'close',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      transitionBuilder: (ctx, a1, a2, child) =>
        Transform.scale(scale: Curves.easeOutBack.transform(a1.value), child: Opacity(opacity: a1.value, child: child)),
      pageBuilder: (ctx, a1, a2) => Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: 420,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: t.cardBg, borderRadius: BorderRadius.circular(24),
              border: t.cardBorder,
              boxShadow: [BoxShadow(color: t.primary.withValues(alpha: 0.2), blurRadius: 40, spreadRadius: 2)],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(S.selectTheme, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: t.textPrimary)),
                const SizedBox(height: 20),
                ...MihomTheme.all.map((th) {
                  final isActive = th.name == t.name;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        widget.onThemeChanged(th);
                        Navigator.of(ctx).pop();
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          gradient: isActive ? th.primaryGradient : null,
                          color: isActive ? null : (t.isDark ? const Color(0xFF1C1F3A) : const Color(0xFFF5F7FF)),
                          borderRadius: BorderRadius.circular(16),
                          border: isActive ? null : Border.all(color: t.textHint.withValues(alpha: 0.15)),
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
                                  Text(S.isEn ? th.nameEn : th.name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: isActive ? Colors.white : t.textPrimary)),
                                  Text(S.isEn ? th.subtitleEn : th.subtitle, style: TextStyle(fontSize: 12, color: isActive ? Colors.white70 : t.textHint)),
                                ],
                              ),
                            ),
                            if (isActive) const Icon(Icons.check_circle, color: Colors.white, size: 20),
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
      ),
    );
  }

  // ── 更新弹窗 ──

  void _showUpdateDialog() {
    HapticFeedback.mediumImpact();
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'close',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 250),
      transitionBuilder: (ctx, a1, a2, child) =>
        Transform.scale(scale: Curves.easeOutBack.transform(a1.value), child: Opacity(opacity: a1.value, child: child)),
      pageBuilder: (ctx, a1, a2) => Center(
        child: Material(
          color: Colors.transparent,
          child: _SettingsUpdateDialogContent(theme: t),
        ),
      ),
    );
  }
}

/// 设置页更新检测弹窗（接入API）
class _SettingsUpdateDialogContent extends ConsumerStatefulWidget {
  final MihomTheme theme;
  const _SettingsUpdateDialogContent({required this.theme});
  @override
  ConsumerState<_SettingsUpdateDialogContent> createState() => _SettingsUpdateDialogContentState();
}

class _SettingsUpdateDialogContentState extends ConsumerState<_SettingsUpdateDialogContent> {
  MihomTheme get t => widget.theme;
  bool _checking = true;
  bool _hasUpdate = false;
  String _currentVersion = '';
  String _latestVersion = '';
  String _releaseNotes = '';
  String _updateUrl = '';
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkVersion());
  }

  Future<void> _checkVersion() async {
    if (!mounted) return;
    setState(() { _checking = true; _error = null; });
    try {
      final notifier = ref.read(updateCheckProvider.notifier);
      await notifier.checkForUpdates();
      final state = ref.read(updateCheckProvider);
      if (!mounted) return;
      setState(() {
        _checking = false;
        _hasUpdate = state.hasUpdate;
        _currentVersion = state.currentVersion ?? '';
        _latestVersion = state.latestVersion ?? '';
        _releaseNotes = state.releaseNotes ?? '';
        _updateUrl = state.updateUrl ?? '';
        _error = state.error;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() { _checking = false; _error = e.toString(); });
    }
  }

  @override
  Widget build(BuildContext context) {
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
        child: _checking
            ? _buildChecking()
            : _error != null
                ? _buildError()
                : _hasUpdate
                    ? _buildHasUpdate()
                    : _buildUpToDate(),
      ),
    );
  }

  Widget _buildChecking() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 56, height: 56,
          decoration: BoxDecoration(gradient: t.primaryGradient, borderRadius: BorderRadius.circular(16)),
          child: const Icon(Icons.system_update, color: Colors.white, size: 28),
        ),
        const SizedBox(height: 16),
        Text(S.checkUpdate, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: t.textPrimary)),
        const SizedBox(height: 20),
        CircularProgressIndicator(color: t.primary),
        const SizedBox(height: 16),
        Text(S.isEn ? 'Checking for updates...' : '正在检测更新...', style: TextStyle(fontSize: 14, color: t.textSecondary)),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildError() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.error_outline, color: t.danger, size: 48),
        const SizedBox(height: 12),
        Text(S.isEn ? 'Check failed' : '检测失败', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: t.textPrimary)),
        const SizedBox(height: 8),
        Text(_error!, style: TextStyle(fontSize: 12, color: t.textSecondary), textAlign: TextAlign.center),
        const SizedBox(height: 18),
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: _checkVersion,
            child: Container(
              width: double.infinity, height: 48,
              decoration: BoxDecoration(gradient: t.buttonGradient, borderRadius: BorderRadius.circular(14)),
              child: Center(child: Text(S.isEn ? 'Retry' : '重试', style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600))),
            ),
          ),
        ),
        const SizedBox(height: 10),
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: double.infinity, height: 42,
              decoration: BoxDecoration(color: t.textHint.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(14)),
              child: Center(child: Text(S.isEn ? 'Close' : '关闭', style: TextStyle(color: t.textSecondary, fontSize: 14, fontWeight: FontWeight.w600))),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHasUpdate() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 56, height: 56,
          decoration: BoxDecoration(gradient: t.primaryGradient, borderRadius: BorderRadius.circular(16)),
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
              child: Text('v$_currentVersion', style: TextStyle(fontSize: 12, color: t.textHint)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Icon(Icons.arrow_forward, size: 14, color: t.textHint),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(color: t.primary.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)),
              child: Text('v$_latestVersion', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: t.primary)),
            ),
          ],
        ),
        if (_releaseNotes.isNotEmpty) ...[
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
                  Text(S.changelog, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: t.textSecondary)),
                  const SizedBox(height: 10),
                  MarkdownBody(
                    data: _releaseNotes,
                    selectable: true,
                    styleSheet: MarkdownStyleSheet(
                      p: TextStyle(fontSize: 13, color: t.textPrimary, height: 1.4),
                      a: TextStyle(fontSize: 13, color: t.primary, decoration: TextDecoration.underline, decorationColor: t.primary),
                      strong: TextStyle(fontSize: 13, color: t.textPrimary, fontWeight: FontWeight.bold),
                      listBullet: TextStyle(fontSize: 13, color: t.textSecondary),
                      code: TextStyle(fontSize: 12, color: t.primary, backgroundColor: t.primary.withValues(alpha: 0.08)),
                    ),
                    onTapLink: (text, href, title) {
                      if (href != null) launchUrl(Uri.parse(href));
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
        const SizedBox(height: 18),
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () {
              HapticFeedback.mediumImpact();
              if (_updateUrl.isNotEmpty) launchUrl(Uri.parse(_updateUrl));
              Navigator.of(context).pop();
            },
            child: Container(
              width: double.infinity, height: 48,
              decoration: BoxDecoration(
                gradient: t.buttonGradient, borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(color: t.primary.withValues(alpha: 0.25), blurRadius: 14, offset: const Offset(0, 4))],
              ),
              child: Center(child: Text(S.updateNow, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600))),
            ),
          ),
        ),
        const SizedBox(height: 10),
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: double.infinity, height: 42,
              decoration: BoxDecoration(color: t.textHint.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(14)),
              child: Center(child: Text(S.updateLater, style: TextStyle(color: t.textSecondary, fontSize: 14, fontWeight: FontWeight.w600))),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUpToDate() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.check_circle, color: t.success, size: 56),
        const SizedBox(height: 16),
        Text(S.isEn ? 'Up to Date!' : '已是最新版本！', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: t.textPrimary)),
        const SizedBox(height: 8),
        Text(
          S.isEn ? 'Current version: $_currentVersion' : '当前版本: $_currentVersion',
          style: TextStyle(fontSize: 14, color: t.textSecondary),
        ),
        const SizedBox(height: 18),
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: double.infinity, height: 42,
              decoration: BoxDecoration(color: t.textHint.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(14)),
              child: Center(child: Text(S.isEn ? 'Close' : '关闭', style: TextStyle(color: t.textSecondary, fontSize: 14, fontWeight: FontWeight.w600))),
            ),
          ),
        ),
      ],
    );
  }
}
