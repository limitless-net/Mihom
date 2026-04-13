import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_clash/controller.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/views/backup_and_restore.dart';
import 'package:fl_clash/views/access.dart';
import 'package:fl_clash/xboard/features/update_check/providers/update_check_provider.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/mihom_theme.dart';
import '../../widgets/theme_dialog.dart';
import '../../i18n.dart';
import '../../widgets/pill_toast.dart';
import '../../providers/theme_provider.dart';

class DemoSettingsPage extends ConsumerStatefulWidget {
  final MihomTheme theme;
  final ValueChanged<MihomTheme> onThemeChanged;
  final int darkModeOption;
  final ValueChanged<int> onDarkModeChanged;
  final bool isGuest;
  final VoidCallback? onLogin;
  const DemoSettingsPage({super.key, required this.theme, required this.onThemeChanged, required this.darkModeOption, required this.onDarkModeChanged, this.isGuest = false, this.onLogin});

  @override
  ConsumerState<DemoSettingsPage> createState() => _DemoSettingsPageState();
}

class _DemoSettingsPageState extends ConsumerState<DemoSettingsPage> {
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

  MihomTheme get t {
    final themeState = ref.watch(mobileThemeProvider);
    final systemBrightness = MediaQuery.of(context).platformBrightness;
    return resolveTheme(themeState, systemBrightness);
  }

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
                          if (widget.isGuest) { widget.onLogin?.call(); return; }
                          _showSelector(S.proxyMode, proxyLabels, _proxyMode, (i) => appController.changeMode(Mode.values[i]));
                        }),
                        if (system.isAndroid) _tileNav(Icons.tune, S.perAppProxy, onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AccessView()))),
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
                        _tileTap(Icons.delete_outline, S.clearCache, '23.4 MB', () {
                          showPillToast(context, t, S.cacheCleared);
                        }),
                        _tileTap(Icons.update, S.checkUpdate, _appVersion.isNotEmpty ? 'v$_appVersion' : 'v1.0.0', () {
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

  Widget _tileNav(IconData icon, String title, {String? subtitle, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap ?? () {
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
//  检测更新版本弹窗 (接入真实 API)
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
        child: _UpdateDialogContent(theme: t),
      ),
    ),
  );
}

class _UpdateDialogContent extends ConsumerStatefulWidget {
  final MihomTheme theme;
  const _UpdateDialogContent({required this.theme});
  @override
  ConsumerState<_UpdateDialogContent> createState() => _UpdateDialogContentState();
}

class _UpdateDialogContentState extends ConsumerState<_UpdateDialogContent> {
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
      width: MediaQuery.of(context).size.width * 0.84,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: t.cardBg,
        borderRadius: BorderRadius.circular(24),
        border: t.cardBorder,
        boxShadow: [BoxShadow(color: t.primary.withValues(alpha: 0.15), blurRadius: 30)],
      ),
      child: _checking
          ? _buildChecking()
          : _error != null
              ? _buildError()
              : _hasUpdate
                  ? _buildHasUpdate()
                  : _buildUpToDate(),
    );
  }

  Widget _buildChecking() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 16),
        SizedBox(width: 36, height: 36, child: CircularProgressIndicator(strokeWidth: 3, color: t.primary)),
        const SizedBox(height: 16),
        Text(S.isEn ? 'Checking for updates...' : '正在检测更新...',
            style: TextStyle(fontSize: 14, color: t.textSecondary)),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildError() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 56, height: 56,
          decoration: BoxDecoration(color: t.danger.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16)),
          child: Icon(Icons.error_outline, color: t.danger, size: 28),
        ),
        const SizedBox(height: 16),
        Text(S.isEn ? 'Check failed' : '检测失败',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: t.textPrimary)),
        const SizedBox(height: 8),
        Text(_error ?? '', style: TextStyle(fontSize: 12, color: t.textHint), textAlign: TextAlign.center, maxLines: 3, overflow: TextOverflow.ellipsis),
        const SizedBox(height: 18),
        GestureDetector(
          onTap: _checkVersion,
          child: Container(
            width: double.infinity, height: 44,
            decoration: BoxDecoration(gradient: t.buttonGradient, borderRadius: BorderRadius.circular(14)),
            child: Center(child: Text(S.isEn ? 'Retry' : '重试', style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600))),
          ),
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Text(S.isEn ? 'Close' : '关闭', style: TextStyle(fontSize: 13, color: t.textSecondary)),
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
          _ChangelogBox(
            releaseNotes: _releaseNotes,
            theme: t,
            maxHeight: 180,
          ),
        ],
        const SizedBox(height: 18),
        GestureDetector(
          onTap: () {
            HapticFeedback.mediumImpact();
            Navigator.of(context).pop();
            if (_updateUrl.isNotEmpty) {
              launchUrl(Uri.parse(_updateUrl), mode: LaunchMode.externalApplication);
            }
          },
          child: Container(
            width: double.infinity, height: 48,
            decoration: BoxDecoration(
              gradient: t.buttonGradient,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [BoxShadow(color: t.primary.withValues(alpha: 0.25), blurRadius: 14, offset: const Offset(0, 4))],
            ),
            child: Center(child: Text(S.updateNow, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600))),
          ),
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            width: double.infinity, height: 42,
            decoration: BoxDecoration(color: t.textHint.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(14)),
            child: Center(child: Text(S.updateLater, style: TextStyle(color: t.textSecondary, fontSize: 14, fontWeight: FontWeight.w600))),
          ),
        ),
      ],
    );
  }

  Widget _buildUpToDate() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 56, height: 56,
          decoration: BoxDecoration(color: t.success.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16)),
          child: Icon(Icons.check_circle, color: t.success, size: 28),
        ),
        const SizedBox(height: 16),
        Text(S.isEn ? 'Up to date!' : '已是最新版本！',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: t.textPrimary)),
        const SizedBox(height: 6),
        Text('v$_currentVersion', style: TextStyle(fontSize: 14, color: t.textSecondary)),
        const SizedBox(height: 18),
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            width: double.infinity, height: 44,
            decoration: BoxDecoration(color: t.textHint.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(14)),
            child: Center(child: Text(S.isEn ? 'Close' : '关闭', style: TextStyle(color: t.textSecondary, fontSize: 14, fontWeight: FontWeight.w600))),
          ),
        ),
      ],
    );
  }
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

/// 带底部渐变提示的更新日志区域，内容超出时提示用户可滚动
class _ChangelogBox extends StatefulWidget {
  final String releaseNotes;
  final MihomTheme theme;
  final double maxHeight;
  const _ChangelogBox({required this.releaseNotes, required this.theme, this.maxHeight = 180});
  @override
  State<_ChangelogBox> createState() => _ChangelogBoxState();
}

class _ChangelogBoxState extends State<_ChangelogBox> {
  final ScrollController _scrollController = ScrollController();
  bool _showBottomHint = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkOverflow());
  }

  void _checkOverflow() {
    if (!mounted || !_scrollController.hasClients) return;
    final hasOverflow = _scrollController.position.maxScrollExtent > 0;
    if (hasOverflow != _showBottomHint) {
      setState(() => _showBottomHint = hasOverflow);
    }
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final atBottom = _scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 8;
    if (_showBottomHint && atBottom) {
      setState(() => _showBottomHint = false);
    } else if (!_showBottomHint && !atBottom && _scrollController.position.maxScrollExtent > 0) {
      setState(() => _showBottomHint = true);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.theme;
    final bgColor = t.isDark ? const Color(0xFF1E2140) : const Color(0xFFF5F7FA);
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(maxHeight: widget.maxHeight),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(14),
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(S.changelog, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: t.textSecondary)),
                    const SizedBox(height: 10),
                    Text(widget.releaseNotes, style: TextStyle(fontSize: 13, color: t.textPrimary, height: 1.4)),
                  ],
                ),
              ),
            ),
            if (_showBottomHint)
              Positioned(
                left: 0, right: 0, bottom: 0,
                child: Container(
                  height: 32,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [bgColor.withValues(alpha: 0), bgColor],
                    ),
                  ),
                  child: Center(
                    child: Icon(Icons.keyboard_arrow_down, size: 18, color: t.textHint),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
