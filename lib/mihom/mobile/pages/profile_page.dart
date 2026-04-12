import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_xboard_sdk/flutter_xboard_sdk.dart';
import 'package:fl_clash/xboard/features/auth/providers/xboard_user_provider.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/mihom_theme.dart';
import '../../widgets/login_dialog.dart';
import '../../i18n.dart';
import '../../widgets/pill_toast.dart';
import '../../widgets/credential_store.dart';
import '../../pages/support_chat_page.dart';
import 'plans_page.dart';
import 'invite_page.dart';
import 'settings_page.dart';

String _formatBytes(int bytes) {
  if (bytes <= 0) return '0 B';
  const units = ['B', 'KB', 'MB', 'GB', 'TB'];
  double value = bytes.toDouble();
  int unitIndex = 0;
  while (value >= 1024 && unitIndex < units.length - 1) {
    value /= 1024;
    unitIndex++;
  }
  return '${value.toStringAsFixed(value >= 100 ? 0 : value >= 10 ? 1 : 2)} ${units[unitIndex]}';
}

class DemoProfilePage extends ConsumerStatefulWidget {
  final MihomTheme theme;
  final VoidCallback? onOpenSettings;
  final bool isGuest;
  final VoidCallback? onLogin;
  final VoidCallback? onLogout;
  const DemoProfilePage({super.key, required this.theme, this.onOpenSettings, this.isGuest = true, this.onLogin, this.onLogout});

  @override
  ConsumerState<DemoProfilePage> createState() => _DemoProfilePageState();
}

class _DemoProfilePageState extends ConsumerState<DemoProfilePage> {
  MihomTheme get t => widget.theme;
  bool get isGuest => widget.isGuest;
  VoidCallback? get onLogin => widget.onLogin;
  VoidCallback? get onLogout => widget.onLogout;
  VoidCallback? get onOpenSettings => widget.onOpenSettings;
  String _appVersion = '';

  @override
  void initState() {
    super.initState();
    _loadVersion();
    if (!widget.isGuest) {
      Future.microtask(() {
        ref.read(xboardUserProvider.notifier).refreshUserInfo();
        ref.read(xboardUserProvider.notifier).refreshSubscriptionInfo();
      });
    }
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    if (mounted) setState(() => _appVersion = info.version);
  }

  void _push(BuildContext context, Widget page) {
    Navigator.of(context).push(PageRouteBuilder(
      pageBuilder: (ctx, a1, a2) => page,
      transitionsBuilder: (ctx, a1, a2, child) => SlideTransition(
        position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
            .animate(CurvedAnimation(parent: a1, curve: Curves.easeOutCubic)),
        child: child,
      ),
      transitionDuration: const Duration(milliseconds: 300),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RefreshIndicator(
        color: t.primary,
        onRefresh: () async {
          HapticFeedback.lightImpact();
          if (!isGuest) {
            await Future.wait([
              ref.read(xboardUserProvider.notifier).refreshUserInfo(),
              ref.read(xboardUserProvider.notifier).refreshSubscriptionInfo(),
            ]);
          }
          if (context.mounted) {
            showPillToast(context, t, S.dataRefreshed);
          }
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──
              Row(
                children: [
                  Text(S.myPage, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: t.textPrimary)),
                  const Spacer(),
                  GestureDetector(
                    onTap: onOpenSettings,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: t.cardBg, borderRadius: BorderRadius.circular(12),
                        border: t.cardBorder, boxShadow: t.cardShadow,
                      ),
                      child: Icon(Icons.settings_outlined, color: t.textSecondary, size: 20),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ── 用户卡片 / 游客卡片 ──
              if (isGuest) _guestCard(context) else _userCard(context),

              if (!isGuest) ...[
              const SizedBox(height: 16),

              // ── 余额卡片（独立） ──
              Builder(builder: (_) {
                final user = ref.watch(userInfoProvider);
                final balanceYuan = (user?.balanceInCents ?? 0) / 100.0;
                final balanceStr = balanceYuan.toStringAsFixed(2);
                return Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: t.cardBg, borderRadius: BorderRadius.circular(t.cardRadius),
                  border: t.cardBorder, boxShadow: t.cardShadow,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: t.warning.withValues(alpha: t.isDark ? 0.15 : 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.account_balance_wallet, color: t.warning, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(S.balance, style: TextStyle(fontSize: 12, color: t.textSecondary)),
                          const SizedBox(height: 2),
                          Text('¥ $balanceStr', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: t.textPrimary)),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        showPillToast(context, t, '${S.recharge} · ${S.devInProgress}');
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(gradient: t.buttonGradient, borderRadius: BorderRadius.circular(10)),
                        child: Text(S.recharge, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
                      ),
                    ),
                  ],
                ),
              );
              }),
              ],

              const SizedBox(height: 24),

              // ── 快捷操作 ──
              Row(
                children: [
                  Expanded(child: _quickAction(context, Icons.card_giftcard, S.inviteFriends, t.secondary, () {
                    if (isGuest) {
                      showLoginDialog(context, t, hint: S.loginToInvite,
                      initialEmail: SavedCredentials.email,
                      initialPassword: SavedCredentials.password,
                    ).then((result) {
                      if (result != null && mounted) {
                        SavedCredentials.email = result['email'] ?? '';
                        SavedCredentials.password = result['password'] ?? '';
                        setState(() {});
                      }
                    });
                    } else {
                      showInviteDialog(context, t);
                    }
                  })),
                  const SizedBox(width: 12),
                  Expanded(child: _quickAction(context, Icons.diamond_outlined, S.buyPlan, t.warning, () {
                    _push(context, DemoPlansPage(theme: t, isGuest: isGuest, onLogin: onLogin));
                  })),
                  const SizedBox(width: 12),
                  Expanded(child: _quickAction(context, Icons.shopping_cart_outlined, S.myOrders, t.primary, () {
                    if (isGuest) {
                      showLoginDialog(context, t, hint: S.loginToViewOrders,
                      initialEmail: SavedCredentials.email,
                      initialPassword: SavedCredentials.password,
                    ).then((result) {
                      if (result != null && mounted) {
                        SavedCredentials.email = result['email'] ?? '';
                        SavedCredentials.password = result['password'] ?? '';
                        setState(() {});
                      }
                    });
                    } else {
                      HapticFeedback.lightImpact();
                      _showOrdersDialog(context);
                    }
                  })),
                ],
              ),

              const SizedBox(height: 24),

              _menuCard(context, [
                _menuItemUsageHistory(context),
                _menuItemSupport(context),
                _menuItemGiftCard(context),
              ]),
              const SizedBox(height: 16),
              _menuCard(context, [
                _menuItemTg(context),
                _menuItemHelpCenter(context),
                _menuItemUpdate(context),
              ]),

              if (!isGuest) ...[              const SizedBox(height: 24),
              _logoutButton(context),
              ],

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _quickAction(BuildContext context, IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: t.cardBg,
          borderRadius: BorderRadius.circular(t.cardRadius),
          border: t.cardBorder,
          boxShadow: [BoxShadow(color: color.withValues(alpha: 0.08), blurRadius: 15)],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: color.withValues(alpha: t.isDark ? 0.15 : 0.1), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: t.textPrimary)),
          ],
        ),
      ),
    );
  }

  // ── 游客卡片 ──
  Widget _guestCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: t.userCardGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: t.primary.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 50, height: 50,
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(16)),
                child: const Icon(Icons.person_outline, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(S.guestMode, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Text(S.loginForFull, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    showLoginDialog(context, t, startAsRegister: false,
                      initialEmail: SavedCredentials.email,
                      initialPassword: SavedCredentials.password,
                    ).then((result) {
                      if (result != null && mounted) {
                        SavedCredentials.email = result['email'] ?? '';
                        SavedCredentials.password = result['password'] ?? '';
                        setState(() {});
                      }
                    });
                  },
                  child: Container(
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(child: Text(S.login, style: TextStyle(color: t.primary, fontSize: 15, fontWeight: FontWeight.w600))),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    showLoginDialog(context, t, startAsRegister: true,
                      initialEmail: SavedCredentials.email,
                      initialPassword: SavedCredentials.password,
                    ).then((result) {
                      if (result != null && mounted) {
                        SavedCredentials.email = result['email'] ?? '';
                        SavedCredentials.password = result['password'] ?? '';
                        setState(() {});
                      }
                    });
                  },
                  child: Container(
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
                    ),
                    child: Center(child: Text(S.register, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600))),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── 已登录用户卡片 ──
  Widget _userCard(BuildContext context) {
    final user = ref.watch(userInfoProvider);
    final sub = ref.watch(subscriptionInfoProvider);
    final email = user?.email ?? 'user@example.com';
    final totalBytes = sub?.transferLimit ?? user?.transferLimit ?? 0;
    final usedBytes = (sub?.uploadedBytes ?? 0) + (sub?.downloadedBytes ?? 0);
    final usageFraction = totalBytes > 0 ? (usedBytes / totalBytes).clamp(0.0, 1.0) : 0.0;
    final planName = sub?.planName ?? (user?.planId != null ? (S.isEn ? 'Plan #${user!.planId}' : '套餐 #${user!.planId}') : (S.isEn ? 'No Plan' : '无套餐'));
    final expiresAt = user?.expiredAt ?? sub?.expiredAt;
    final hasPlan = user?.planId != null;

    // User badge
    final bool hasAdaptedApi = user?.period != null && user!.period!.isNotEmpty && user?.userId != null;
    final String badgeText;
    if (hasAdaptedApi) {
      final periodLabel = _getPeriodLabel(user?.period);
      final userIdStr = '${user!.userId}'.padLeft(3, '0');
      badgeText = '$periodLabel•id:$userIdStr';
    } else {
      badgeText = planName;
    }

    // Expiry display
    final bool isExpired = user?.isExpired ?? false;
    final String expiresStr;
    if (expiresAt != null) {
      if (isExpired) {
        expiresStr = S.isEn ? 'Expired' : '已过期';
      } else {
        final daysLeft = expiresAt.difference(DateTime.now()).inDays;
        expiresStr = S.isEn ? '$daysLeft days left' : '剩余 $daysLeft 天';
      }
    } else {
      expiresStr = hasPlan ? (S.isEn ? 'Lifetime' : '长期有效') : (S.isEn ? 'N/A' : '无');
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: t.userCardGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: t.primary.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 50, height: 50,
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(16)),
                child: const Icon(Icons.person, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(S.userName, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(6)),
                          child: Text(badgeText, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(email, style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(S.usedTraffic, style: const TextStyle(color: Colors.white70, fontSize: 12)),
              Text('${_formatBytes(usedBytes)} / ${_formatBytes(totalBytes)}', style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 12)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: usageFraction,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              valueColor: const AlwaysStoppedAnimation(Colors.white),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(S.expiresDate, style: const TextStyle(color: Colors.white70, fontSize: 12)),
              Text(expiresStr, style: TextStyle(color: isExpired ? const Color(0xFFFF6B6B) : Colors.white.withValues(alpha: 0.9), fontSize: 12, fontWeight: isExpired ? FontWeight.w600 : FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }

  String _getPeriodLabel(String? period) {
    if (period == null) return '';
    switch (period) {
      case 'month_price': return S.isEn ? 'Monthly' : '月付';
      case 'quarter_price': return S.isEn ? 'Quarterly' : '季付';
      case 'half_year_price': return S.isEn ? 'Semi-annual' : '半年付';
      case 'year_price': return S.isEn ? 'Annual' : '年付';
      case 'two_year_price': return S.isEn ? '2-Year' : '两年付';
      case 'three_year_price': return S.isEn ? '3-Year' : '三年付';
      case 'onetime_price': return S.isEn ? 'One-time' : '一次性';
      default: return period;
    }
  }

  Widget _menuCard(BuildContext context, List<Widget> items) {
    return Container(
      decoration: BoxDecoration(
        color: t.cardBg,
        borderRadius: BorderRadius.circular(t.cardRadius),
        border: t.cardBorder, boxShadow: t.cardShadow,
      ),
      child: Column(
        children: items.asMap().entries.map((entry) {
          final isLast = entry.key == items.length - 1;
          return Column(children: [
            entry.value,
            if (!isLast) Padding(
              padding: const EdgeInsets.symmetric(horizontal: 56),
              child: Divider(height: 1, color: t.textHint.withValues(alpha: 0.15)),
            ),
          ]);
        }).toList(),
      ),
    );
  }

  Widget _menuItem(BuildContext context, IconData icon, String title, String subtitle) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
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
            Text(subtitle, style: TextStyle(fontSize: 12, color: t.textHint.withValues(alpha: 0.7))),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right, color: t.textHint.withValues(alpha: 0.5), size: 18),
          ],
        ),
      ),
    );
  }

  // ── 在线客服 ──
  Widget _menuItemSupport(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        if (isGuest) {
          showPillToast(context, t, '${S.onlineSupport} · ${S.loginFirst}');
          return;
        }
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => SupportChatPage(theme: t)),
        );
      },
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(Icons.headset_mic, color: t.textSecondary, size: 22),
            const SizedBox(width: 14),
            Expanded(child: Text(S.onlineSupport, style: TextStyle(fontSize: 15, color: t.textPrimary))),
            Text(S.onlineSupportDesc, style: TextStyle(fontSize: 12, color: t.textHint.withValues(alpha: 0.7))),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right, color: t.textHint.withValues(alpha: 0.5), size: 18),
          ],
        ),
      ),
    );
  }

  // ── 使用记录弹窗 ──
  Widget _menuItemUsageHistory(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        if (isGuest) {
          showPillToast(context, t, '${S.usageHistory} · ${S.loginFirst}');
          return;
        }
        _showUsageHistoryDialog(context);
      },
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(Icons.history, color: t.textSecondary, size: 22),
            const SizedBox(width: 14),
            Expanded(child: Text(S.usageHistory, style: TextStyle(fontSize: 15, color: t.textPrimary))),
            Text(S.usageHistoryDesc, style: TextStyle(fontSize: 12, color: t.textHint.withValues(alpha: 0.7))),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right, color: t.textHint.withValues(alpha: 0.5), size: 18),
          ],
        ),
      ),
    );
  }

  void _showUsageHistoryDialog(BuildContext context) {
    // 先刷新用户数据
    ref.read(xboardUserProvider.notifier).refreshUserInfo();
    ref.read(xboardUserProvider.notifier).refreshSubscriptionInfo();
    // Read real subscription data from API
    final sub = ref.read(subscriptionInfoProvider);
    final user = ref.read(userInfoProvider);
    final uploadBytes = sub?.uploadedBytes ?? 0;
    final downloadBytes = sub?.downloadedBytes ?? 0;
    final totalBytes = sub?.transferLimit ?? user?.transferLimit ?? 0;
    final totalUsedBytes = uploadBytes + downloadBytes;
    final remainBytes = (totalBytes - totalUsedBytes).clamp(0, totalBytes);
    final usageFraction = totalBytes > 0 ? (totalUsedBytes / totalBytes).clamp(0.0, 1.0) : 0.0;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'close',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      transitionBuilder: (ctx, a1, a2, child) => Transform.scale(
        scale: Curves.easeOutBack.transform(a1.value),
        child: Opacity(opacity: a1.value, child: child),
      ),
      pageBuilder: (ctx, a1, a2) => Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: MediaQuery.of(ctx).size.width * 0.88,
            constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.72),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: t.cardBg,
              borderRadius: BorderRadius.circular(24),
              border: t.cardBorder,
              boxShadow: [BoxShadow(color: t.primary.withValues(alpha: 0.15), blurRadius: 40)],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Header ──
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: t.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.history, color: t.primary, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(S.usageHistoryTitle, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: t.textPrimary)),
                          const SizedBox(height: 2),
                          Text(S.usageHistoryDesc, style: TextStyle(fontSize: 12, color: t.textSecondary)),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(ctx).pop(),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(color: t.textHint.withValues(alpha: 0.1), shape: BoxShape.circle),
                        child: Icon(Icons.close, color: t.textHint, size: 18),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // ── 总用量概览 ──
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    gradient: t.primaryGradient,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(S.totalUsed, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                            const SizedBox(height: 4),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(_formatBytes(totalUsedBytes), style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.arrow_upward, color: Colors.white70, size: 14),
                              const SizedBox(width: 4),
                              Text('${S.upload} ${_formatBytes(uploadBytes)}',
                                style: const TextStyle(color: Colors.white70, fontSize: 12)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.arrow_downward, color: Colors.white70, size: 14),
                              const SizedBox(width: 4),
                              Text('${S.download} ${_formatBytes(downloadBytes)}',
                                style: const TextStyle(color: Colors.white70, fontSize: 12)),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ── 流量详情卡片 ──
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // 上传详情
                        _usageDetailCard(
                          icon: Icons.arrow_upward,
                          label: S.upload,
                          valueBytes: uploadBytes,
                          color: t.primary,
                          fraction: totalUsedBytes > 0 ? uploadBytes / totalUsedBytes : 0.0,
                        ),
                        const SizedBox(height: 10),
                        // 下载详情
                        _usageDetailCard(
                          icon: Icons.arrow_downward,
                          label: S.download,
                          valueBytes: downloadBytes,
                          color: t.secondary,
                          fraction: totalUsedBytes > 0 ? downloadBytes / totalUsedBytes : 0.0,
                        ),
                        const SizedBox(height: 10),
                        // 剩余流量
                        _usageDetailCard(
                          icon: Icons.data_usage,
                          label: S.isEn ? 'Remaining' : '剩余流量',
                          valueBytes: remainBytes,
                          color: t.success,
                          fraction: totalBytes > 0 ? remainBytes / totalBytes : 0.0,
                        ),
                        const SizedBox(height: 16),
                        // 总量进度条
                        Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(S.isEn ? 'Usage' : '总量使用', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: t.textPrimary)),
                                Text('${_formatBytes(totalUsedBytes)} / ${_formatBytes(totalBytes)}',
                                    style: TextStyle(fontSize: 12, color: t.textSecondary)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: SizedBox(
                                height: 10,
                                child: totalBytes > 0 ? Row(
                                  children: [
                                    if (uploadBytes > 0)
                                      Expanded(
                                        flex: (uploadBytes * 10000 ~/ totalBytes).clamp(1, 10000),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(colors: [t.primary, t.primary.withValues(alpha: 0.7)]),
                                          ),
                                        ),
                                      ),
                                    if (downloadBytes > 0)
                                      Expanded(
                                        flex: (downloadBytes * 10000 ~/ totalBytes).clamp(1, 10000),
                                        child: Container(color: t.secondary.withValues(alpha: 0.6)),
                                      ),
                                    if (remainBytes > 0)
                                      Expanded(
                                        flex: (remainBytes * 10000 ~/ totalBytes).clamp(1, 10000),
                                        child: Container(color: t.textHint.withValues(alpha: 0.1)),
                                      ),
                                  ],
                                ) : const SizedBox.shrink(),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Container(width: 8, height: 8, decoration: BoxDecoration(color: t.primary, borderRadius: BorderRadius.circular(2))),
                                const SizedBox(width: 4),
                                Text(S.upload, style: TextStyle(fontSize: 11, color: t.textSecondary)),
                                const SizedBox(width: 12),
                                Container(width: 8, height: 8, decoration: BoxDecoration(color: t.secondary.withValues(alpha: 0.6), borderRadius: BorderRadius.circular(2))),
                                const SizedBox(width: 4),
                                Text(S.download, style: TextStyle(fontSize: 11, color: t.textSecondary)),
                                const SizedBox(width: 12),
                                Container(width: 8, height: 8, decoration: BoxDecoration(color: t.textHint.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(2))),
                                const SizedBox(width: 4),
                                Text(S.isEn ? 'Remaining' : '剩余', style: TextStyle(fontSize: 11, color: t.textSecondary)),
                              ],
                            ),
                          ],
                        ),
                      ],
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

  Widget _usageDetailCard({
    required IconData icon,
    required String label,
    required int valueBytes,
    required Color color,
    required double fraction,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: t.isDark ? const Color(0xFF1C1F3A) : const Color(0xFFF7F8FC),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: t.textSecondary)),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: fraction.clamp(0.0, 1.0),
                    backgroundColor: t.textHint.withValues(alpha: 0.1),
                    valueColor: AlwaysStoppedAnimation(color),
                    minHeight: 4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(_formatBytes(valueBytes),
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: t.textPrimary)),
        ],
      ),
    );
  }

  Widget _menuItemUpdate(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        showUpdateDialog(context, t);
      },
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(Icons.update, color: t.textSecondary, size: 22),
            const SizedBox(width: 14),
            Expanded(child: Text(S.checkUpdate, style: TextStyle(fontSize: 15, color: t.textPrimary))),
            Text(_appVersion.isNotEmpty ? 'v$_appVersion' : '', style: TextStyle(fontSize: 12, color: t.textHint.withValues(alpha: 0.7))),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right, color: t.textHint.withValues(alpha: 0.5), size: 18),
          ],
        ),
      ),
    );
  }

  Widget _menuItemTg(BuildContext context) {
    final user = ref.watch(userInfoProvider);
    final tgId = user?.telegramId;
    final isBound = tgId != null && tgId.isNotEmpty;
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        showGeneralDialog(
          context: context,
          barrierDismissible: true, barrierLabel: '关闭', barrierColor: Colors.black54,
          transitionDuration: const Duration(milliseconds: 250),
          transitionBuilder: (ctx, a1, a2, child) => Transform.scale(
            scale: Curves.easeOutBack.transform(a1.value),
            child: Opacity(opacity: a1.value, child: child),
          ),
          pageBuilder: (ctx, a1, a2) => Center(
            child: Material(
              color: Colors.transparent,
              child: _TgDialogContent(theme: t, isBound: isBound, tgId: tgId),
            ),
          ),
        );
      },
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            const Icon(Icons.send, color: Color(0xFF0088CC), size: 22),
            const SizedBox(width: 14),
            Expanded(child: Text(S.bindTg, style: TextStyle(fontSize: 15, color: t.textPrimary))),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: isBound ? const Color(0xFF4CAF50).withValues(alpha: 0.1) : const Color(0xFF0088CC).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                isBound ? (S.isEn ? 'Bound' : '已绑定') : S.notBound,
                style: TextStyle(fontSize: 11, color: isBound ? const Color(0xFF4CAF50) : const Color(0xFF0088CC), fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right, color: t.textHint.withValues(alpha: 0.5), size: 18),
          ],
        ),
      ),
    );
  }

  // ── 礼品卡兑换 ──
  Widget _menuItemGiftCard(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        _showGiftCardDialog(context);
      },
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(Icons.card_giftcard, color: t.textSecondary, size: 22),
            const SizedBox(width: 14),
            Expanded(child: Text(S.giftCard, style: TextStyle(fontSize: 15, color: t.textPrimary))),
            Text(S.giftCardDesc, style: TextStyle(fontSize: 12, color: t.textHint.withValues(alpha: 0.7))),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right, color: t.textHint.withValues(alpha: 0.5), size: 18),
          ],
        ),
      ),
    );
  }

  // ── 礼品卡弹窗 ──
  void _showGiftCardDialog(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true, barrierLabel: 'close', barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 220),
      transitionBuilder: (ctx, a1, a2, child) => Transform.scale(
        scale: Curves.easeOutBack.transform(a1.value), child: Opacity(opacity: a1.value, child: child)),
      pageBuilder: (ctx, a1, a2) => Center(
        child: Material(
          color: Colors.transparent,
          child: _MobileGiftCardDialog(theme: t, onSuccess: () {
            ref.read(xboardUserProvider.notifier).refreshUserInfo();
            ref.read(xboardUserProvider.notifier).refreshSubscriptionInfo();
          }),
        ),
      ),
    );
  }

  // ── 帮助中心菜单项 ──
  Widget _menuItemHelpCenter(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        _showHelpCenterDialog(context);
      },
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(Icons.help_outline, color: t.textSecondary, size: 22),
            const SizedBox(width: 14),
            Expanded(child: Text(S.helpCenter, style: TextStyle(fontSize: 15, color: t.textPrimary))),
            Text(S.helpCenterDesc, style: TextStyle(fontSize: 12, color: t.textHint.withValues(alpha: 0.7))),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right, color: t.textHint.withValues(alpha: 0.5), size: 18),
          ],
        ),
      ),
    );
  }

  // ── 帮助中心弹窗 (接入知识库 API) ──
  void _showHelpCenterDialog(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true, barrierLabel: 'close', barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 220),
      transitionBuilder: (ctx, a1, a2, child) => Transform.scale(
        scale: Curves.easeOutBack.transform(a1.value), child: Opacity(opacity: a1.value, child: child)),
      pageBuilder: (ctx, a1, a2) => Center(
        child: Material(
          color: Colors.transparent,
          child: _HelpCenterDialogContent(theme: t),
        ),
      ),
    );
  }

  // ── 我的订单弹窗 ──
  void _showOrdersDialog(BuildContext context) async {
    // Show loading state first
    showGeneralDialog(
      context: context,
      barrierDismissible: true, barrierLabel: 'close', barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 220),
      transitionBuilder: (ctx, a1, a2, child) => Transform.scale(
        scale: Curves.easeOutBack.transform(a1.value), child: Opacity(opacity: a1.value, child: child)),
      pageBuilder: (ctx, a1, a2) => Center(
        child: Material(
          color: Colors.transparent,
          child: _OrdersDialogContent(theme: t),
        ),
      ),
    );
  }

  // ── 退出登录按钮 ──
  Widget _logoutButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
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
                width: MediaQuery.of(ctx).size.width * 0.72,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: t.cardBg,
                  borderRadius: BorderRadius.circular(20),
                  border: t.cardBorder,
                  boxShadow: [BoxShadow(color: Colors.red.withValues(alpha: 0.1), blurRadius: 30)],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.logout, color: Colors.red, size: 28),
                    ),
                    const SizedBox(height: 16),
                    Text(S.logoutConfirm, style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: t.textPrimary)),
                    const SizedBox(height: 8),
                    Text(S.logoutDesc, style: TextStyle(fontSize: 13, color: t.textSecondary)),
                    const SizedBox(height: 20),
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
                              onLogout?.call();
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(colors: [Color(0xFFFF6B6B), Color(0xFFEE5A24)]),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(child: Text(S.confirm, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white))),
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
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: t.cardBg,
          borderRadius: BorderRadius.circular(t.cardRadius),
          border: t.cardBorder,
          boxShadow: t.cardShadow,
        ),
        child: Center(
          child: Text(S.logout, style: const TextStyle(color: Colors.red, fontSize: 15, fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }
}

/// FAQ 可展开折叠组件
class _FaqTile extends StatefulWidget {
  final String q;
  final String a;
  final MihomTheme theme;
  const _FaqTile({required this.q, required this.a, required this.theme});
  @override
  State<_FaqTile> createState() => _FaqTileState();
}

class _FaqTileState extends State<_FaqTile> {
  bool _expanded = false;
  @override
  Widget build(BuildContext context) {
    final t = widget.theme;
    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 22, height: 22,
                  decoration: BoxDecoration(color: t.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                  child: Center(child: Text('Q', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: t.primary))),
                ),
                const SizedBox(width: 10),
                Expanded(child: Text(widget.q, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: t.textPrimary))),
                AnimatedRotation(
                  turns: _expanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(Icons.expand_more, size: 18, color: t.textHint),
                ),
              ],
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Padding(
                padding: const EdgeInsets.only(left: 32, top: 8),
                child: Text(widget.a, style: TextStyle(fontSize: 12, color: t.textSecondary, height: 1.5)),
              ),
              crossFadeState: _expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 200),
            ),
          ],
        ),
      ),
    );
  }
}

/// 帮助中心弹窗 — 从知识库 API 加载
class _HelpCenterDialogContent extends StatefulWidget {
  final MihomTheme theme;
  const _HelpCenterDialogContent({required this.theme});
  @override
  State<_HelpCenterDialogContent> createState() => _HelpCenterDialogContentState();
}

class _HelpCenterDialogContentState extends State<_HelpCenterDialogContent> {
  MihomTheme get t => widget.theme;
  bool _loading = true;
  List<(String, String)> _faqItems = [];

  static final _fallbackFaq = [
    (S.isEn ? 'How to connect?' : '如何连接？', S.isEn ? 'Select a node on the home page and tap the connect button.' : '在首页选择节点后，点击连接按钮即可。'),
    (S.isEn ? 'What if the connection fails?' : '连接失败怎么办？', S.isEn ? 'Try switching nodes or syncing your subscription.' : '可尝试切换节点或刷新订阅。'),
    (S.isEn ? 'How to change my plan?' : '如何更换套餐？', S.isEn ? 'Go to Plans page to view and purchase plans.' : '进入套餐页面查看并购买新套餐。'),
    (S.isEn ? 'How does the invite reward work?' : '邀请奖励如何发放？', S.isEn ? 'Share your invite code; you earn commission when friends purchase.' : '分享邀请码，好友购买后自动获得佣金。'),
    (S.isEn ? 'How to contact support?' : '如何联系客服？', S.isEn ? 'Tap Online Support in profile page.' : '在个人中心点击在线客服。'),
  ];

  @override
  void initState() {
    super.initState();
    _fetchKnowledge();
  }

  Future<void> _fetchKnowledge() async {
    try {
      final lang = S.isEn ? 'en' : 'zh-CN';
      final http = XBoardSDK.instance.httpService;
      final result = await http.getRequest('/api/v1/user/knowledge/fetch?language=$lang');
      final data = result['data'];
      if (data is Map) {
        final List<(String, String)> items = [];
        String? faqCategory;
        for (final key in data.keys) {
          final keyStr = key.toString();
          if (keyStr.contains('常见问题') || keyStr.toLowerCase().contains('faq')) {
            faqCategory = keyStr;
            break;
          }
        }
        final categoriesToShow = faqCategory != null ? [faqCategory] : data.keys.toList();
        for (final cat in categoriesToShow) {
          final articles = data[cat];
          if (articles is List) {
            for (final article in articles) {
              final title = article['title'] as String? ?? '';
              final body = article['body'] as String? ?? '';
              final cleanBody = body.replaceAll(RegExp(r'<[^>]*>'), '').trim();
              if (title.isNotEmpty) {
                items.add((title, cleanBody.isNotEmpty ? cleanBody : S.isEn ? 'No details available' : '暂无详细内容'));
              }
            }
          }
        }
        if (mounted) {
          setState(() {
            _faqItems = items.isNotEmpty ? items : _fallbackFaq;
            _loading = false;
          });
        }
        return;
      }
    } catch (_) {}
    if (mounted) setState(() { _faqItems = _fallbackFaq; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.85,
      constraints: const BoxConstraints(maxWidth: 400, maxHeight: 520),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(color: t.cardBg, borderRadius: BorderRadius.circular(20), border: t.cardBorder,
        boxShadow: [BoxShadow(color: t.primary.withValues(alpha: 0.15), blurRadius: 30)]),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.help_outline, color: const Color(0xFF607D8B), size: 24),
              const SizedBox(width: 10),
              Expanded(child: Text(S.helpCenter, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: t.textPrimary))),
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Icon(Icons.close, size: 18, color: t.textHint),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_loading)
            const Padding(padding: EdgeInsets.all(30), child: CircularProgressIndicator(strokeWidth: 2))
          else
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: _faqItems.length,
                separatorBuilder: (_, __) => Divider(height: 1, color: t.textHint.withValues(alpha: 0.1)),
                itemBuilder: (_, i) => _FaqTile(q: _faqItems[i].$1, a: _faqItems[i].$2, theme: t),
              ),
            ),
        ],
      ),
    );
  }
}

/// Orders dialog that fetches real data from SDK
class _OrdersDialogContent extends StatefulWidget {
  final MihomTheme theme;
  const _OrdersDialogContent({required this.theme});
  @override
  State<_OrdersDialogContent> createState() => _OrdersDialogContentState();
}

class _OrdersDialogContentState extends State<_OrdersDialogContent> {
  MihomTheme get t => widget.theme;
  List<dynamic> _orders = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    try {
      final orders = await XBoardSDK.instance.order.getOrders(pageSize: 50);
      if (mounted) {
        setState(() {
          _orders = orders;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _periodLabel(String? period) {
    if (period == null) return '';
    switch (period) {
      case 'month_price': return S.isEn ? 'Monthly' : '月付';
      case 'quarter_price': return S.isEn ? 'Quarterly' : '季付';
      case 'half_year_price': return S.isEn ? 'Semi-Annual' : '半年付';
      case 'year_price': return S.isEn ? 'Annual' : '年付';
      case 'onetime_price': return S.isEn ? 'One-time' : '一次性';
      default: return period;
    }
  }

  String _statusLabel(dynamic status) {
    switch (status) {
      case 0: return S.isEn ? 'Pending' : '待支付';
      case 1: return S.isEn ? 'Processing' : '开通中';
      case 2: return S.isEn ? 'Cancelled' : '已取消';
      case 3: return S.isEn ? 'Active' : '已完成';
      case 4: return S.isEn ? 'Refunded' : '已折抵';
      default: return status.toString();
    }
  }

  bool _isActive(dynamic status) => status == 3 || status == 1;
  bool _canCancel(dynamic status) => status == 0;

  Future<void> _cancelOrder(dynamic order) async {
    final tradeNo = order.tradeNo;
    if (tradeNo == null || tradeNo.toString().isEmpty) return;
    final confirmed = await showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true, barrierLabel: 'close', barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 220),
      transitionBuilder: (ctx, a1, a2, child) => Transform.scale(
        scale: Curves.easeOutBack.transform(a1.value), child: Opacity(opacity: a1.value, child: child)),
      pageBuilder: (ctx, a1, a2) => Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: MediaQuery.of(ctx).size.width * 0.8,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(color: t.cardBg, borderRadius: BorderRadius.circular(20), border: t.cardBorder,
              boxShadow: [BoxShadow(color: t.primary.withValues(alpha: 0.15), blurRadius: 30)]),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.warning_amber_rounded, color: t.warning, size: 36),
                const SizedBox(height: 12),
                Text(S.isEn ? 'Cancel Order?' : '取消订单？', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: t.textPrimary)),
                const SizedBox(height: 8),
                Text(S.isEn ? 'This action cannot be undone.' : '取消后不可恢复',
                  style: TextStyle(fontSize: 13, color: t.textSecondary)),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.of(ctx).pop(false),
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
                        onTap: () => Navigator.of(ctx).pop(true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(color: t.danger, borderRadius: BorderRadius.circular(12)),
                          child: Center(child: Text(S.isEn ? 'Confirm Cancel' : '确认取消', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white))),
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
    if (confirmed != true || !mounted) return;
    try {
      await XBoardSDK.instance.order.cancelOrder(tradeNo.toString());
      if (mounted) {
        showPillToast(context, t, S.isEn ? 'Order cancelled' : '订单已取消');
        _loadOrders();
      }
    } catch (e) {
      if (mounted) showPillToast(context, t, e is XBoardException ? e.message : e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      constraints: const BoxConstraints(maxWidth: 400, maxHeight: 520),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(color: t.cardBg, borderRadius: BorderRadius.circular(20), border: t.cardBorder,
        boxShadow: [BoxShadow(color: t.primary.withValues(alpha: 0.15), blurRadius: 30)]),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(gradient: t.primaryGradient, borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.receipt_long, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(child: Text(S.myOrders, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: t.textPrimary))),
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(color: t.textHint.withValues(alpha: 0.1), shape: BoxShape.circle),
                  child: Icon(Icons.close, color: t.textHint, size: 18),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_loading)
            const Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator())
          else if (_orders.isEmpty)
            Padding(padding: const EdgeInsets.all(32),
              child: Text(S.isEn ? 'No orders' : '暂无订单', style: TextStyle(color: t.textHint)))
          else
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: _orders.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (ctx2, i) {
                  final order = _orders[i];
                  final planName = order.orderPlan?.name ?? 'Plan #${order.planId}';
                  final period = _periodLabel(order.period);
                  final amount = order.totalAmount ?? 0;
                  final totalAmount = (amount / 100).toStringAsFixed(2);
                  final status = order.status;
                  final createdAt = order.createdAt;
                  final dateStr = createdAt != null
                      ? '${createdAt.year}-${createdAt.month.toString().padLeft(2, '0')}-${createdAt.day.toString().padLeft(2, '0')}'
                      : '';
                  final active = _isActive(status);

                  return Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: t.isDark ? const Color(0xFF1E2140) : const Color(0xFFF7F8FC),
                      borderRadius: BorderRadius.circular(14),
                      border: active ? Border.all(color: t.primary.withValues(alpha: 0.2)) : null,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(child: Text(planName, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: t.textPrimary))),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: active ? t.success.withValues(alpha: 0.1) : t.textHint.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(_statusLabel(status), style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                                color: active ? t.success : t.textHint)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(period, style: TextStyle(fontSize: 12, color: t.textSecondary)),
                            const SizedBox(width: 12),
                            Text('¥$totalAmount', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: t.primary)),
                            const Spacer(),
                            if (_canCancel(status))
                              GestureDetector(
                                onTap: () => _cancelOrder(order),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: t.danger.withValues(alpha: 0.3)),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(S.isEn ? 'Cancel' : '取消', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: t.danger)),
                                ),
                              )
                            else ...[
                              Icon(Icons.access_time, size: 12, color: t.textHint),
                              const SizedBox(width: 4),
                              Text(dateStr, style: TextStyle(fontSize: 11, color: t.textHint)),
                            ],
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════
// Telegram 绑定弹窗（动态加载 bot info + discuss link）
// ══════════════════════════════════════════════

class _TgDialogContent extends StatefulWidget {
  final MihomTheme theme;
  final bool isBound;
  final String? tgId;
  const _TgDialogContent({required this.theme, required this.isBound, this.tgId});
  @override
  State<_TgDialogContent> createState() => _TgDialogContentState();
}

class _TgDialogContentState extends State<_TgDialogContent> {
  MihomTheme get t => widget.theme;
  String? _botUsername;
  String? _discussLink;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchTgInfo();
  }

  Future<void> _fetchTgInfo() async {
    try {
      final http = XBoardSDK.instance.httpService;
      final results = await Future.wait([
        http.getRequest('/api/v1/user/telegram/getBotInfo').catchError((_) => <String, dynamic>{}),
        http.getRequest('/api/v1/user/comm/config').catchError((_) => <String, dynamic>{}),
      ]);
      final botData = results[0];
      final commData = results[1];
      if (mounted) {
        setState(() {
          _botUsername = (botData['data'] as Map?)?['username'] as String?;
          _discussLink = (commData['data'] as Map?)?['telegram_discuss_link'] as String?;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    return Container(
      width: sw * 0.88,
      padding: const EdgeInsets.all(22),
      constraints: const BoxConstraints(maxHeight: 520),
      decoration: BoxDecoration(color: t.cardBg, borderRadius: BorderRadius.circular(20), border: t.cardBorder,
        boxShadow: [BoxShadow(color: t.primary.withValues(alpha: 0.15), blurRadius: 30)]),
      child: SingleChildScrollView(
        child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: const Color(0xFF2196F3).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.telegram, color: Color(0xFF2196F3), size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Telegram', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Text(widget.isBound ? (S.isEn ? 'Bound' : '已绑定') : (S.isEn ? 'Not Bound' : '未绑定'),
                      style: TextStyle(fontSize: 12, color: t.textSecondary)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: widget.isBound ? const Color(0xFF4CAF50).withValues(alpha: 0.1) : const Color(0xFFFF5722).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(widget.isBound ? (S.isEn ? 'Bound' : '已绑定') : (S.isEn ? 'Not Bound' : '未绑定'),
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                    color: widget.isBound ? const Color(0xFF4CAF50) : const Color(0xFFFF5722))),
              ),
            ],
          ),
          const SizedBox(height: 18),
          if (_loading)
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: t.primary)),
            )
          else ...[
            // Section 1: 绑定账号
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: t.isDark ? const Color(0xFF1C1F3A) : const Color(0xFFF7F8FC),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: t.textHint.withValues(alpha: 0.08)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Icon(Icons.link, color: t.primary, size: 16),
                    const SizedBox(width: 6),
                    Text(S.isEn ? 'Bind Account' : '绑定账号',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: t.textPrimary)),
                  ]),
                  const SizedBox(height: 8),
                  Text(S.isEn
                      ? 'Bind via Telegram Bot for expiry reminders, traffic alerts, and daily rewards.'
                      : '通过 Telegram Bot 绑定账号，接收到期提醒、流量预警和签到领流量。',
                    style: TextStyle(fontSize: 12, color: t.textSecondary, height: 1.5)),
                  const SizedBox(height: 12),
                  _tgActionBtn(
                    icon: Icons.copy_outlined,
                    label: S.isEn ? 'Copy Bind Command' : '复制绑定命令',
                    color: const Color(0xFF2196F3),
                    onTap: () {
                      Clipboard.setData(const ClipboardData(text: '/binduser'));
                      showPillToast(context, t, S.isEn ? 'Bind command copied' : '绑定命令已复制');
                    },
                  ),
                  const SizedBox(height: 8),
                  _tgActionBtn(
                    icon: Icons.open_in_new,
                    label: S.isEn ? 'Open Telegram Bot' : '打开 Telegram Bot',
                    color: const Color(0xFF2196F3),
                    onTap: () async {
                      if (_botUsername != null && _botUsername!.isNotEmpty) {
                        await launchUrl(Uri.parse('https://t.me/$_botUsername'), mode: LaunchMode.externalApplication);
                      } else {
                        showPillToast(context, t, S.isEn ? 'Bot not configured' : 'Bot 未配置');
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Section 2: 加入交流群
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: t.isDark ? const Color(0xFF1C1F3A) : const Color(0xFFF7F8FC),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: t.textHint.withValues(alpha: 0.08)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    const Icon(Icons.groups_outlined, color: Color(0xFF4CAF50), size: 16),
                    const SizedBox(width: 6),
                    Text(S.isEn ? 'Join Community' : '加入交流群',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: t.textPrimary)),
                  ]),
                  const SizedBox(height: 8),
                  Text(S.isEn
                      ? 'Join the Telegram group for announcements, discussions and support.'
                      : '加入 Telegram 群组，获取公告、参与讨论和技术支持。',
                    style: TextStyle(fontSize: 12, color: t.textSecondary, height: 1.5)),
                  const SizedBox(height: 12),
                  _tgActionBtn(
                    icon: Icons.groups,
                    label: S.isEn ? 'Join Telegram Group' : '加入 Telegram 群',
                    color: const Color(0xFF4CAF50),
                    onTap: () async {
                      if (_discussLink != null && _discussLink!.isNotEmpty) {
                        final uri = Uri.tryParse(_discussLink!);
                        if (uri != null) {
                          await launchUrl(uri, mode: LaunchMode.externalApplication);
                          return;
                        }
                      }
                      showPillToast(context, t, S.isEn ? 'Group link not configured' : '群组链接未配置');
                    },
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
      ),
    );
  }

  Widget _tgActionBtn({required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: color)),
          ],
        ),
      ),
    );
  }
}

// ── Mobile Gift Card Dialog (with check → preview → redeem flow) ──
class _MobileGiftCardDialog extends StatefulWidget {
  final MihomTheme theme;
  final VoidCallback? onSuccess;
  const _MobileGiftCardDialog({required this.theme, this.onSuccess});
  @override
  State<_MobileGiftCardDialog> createState() => _MobileGiftCardDialogState();
}

class _MobileGiftCardDialogState extends State<_MobileGiftCardDialog> {
  MihomTheme get t => widget.theme;
  final _ctrl = TextEditingController();
  bool _loading = false;
  bool _checked = false;
  bool _redeemed = false;
  String? _error;
  bool _canRedeem = false;
  String? _templateName;
  String? _templateTypeName;
  List<String> _previewLines = [];
  Map<String, dynamic>? _rewards;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _check() async {
    final code = _ctrl.text.trim();
    if (code.isEmpty) {
      setState(() => _error = S.giftCardEmpty);
      return;
    }
    setState(() { _loading = true; _error = null; _checked = false; });
    try {
      final result = await XBoardSDK.instance.giftCard.checkCode(code);
      setState(() {
        _loading = false;
        _checked = true;
        _canRedeem = result.canRedeem;
        _templateName = result.codeInfo.template.name;
        _templateTypeName = result.codeInfo.template.typeName;
        _previewLines = parseRewardPreview(result.rewardPreview);
        if (!result.canRedeem && result.reason != null) _error = result.reason;
      });
    } catch (e) {
      final msg = e is NetworkException
          ? (S.isEn ? 'This gift card is temporarily unavailable' : '该礼品卡暂不可用，请稍后重试')
          : e is XBoardException ? e.message : (S.isEn ? 'Check failed' : '查询失败');
      setState(() { _loading = false; _error = msg; });
    }
  }

  Future<void> _redeem() async {
    final code = _ctrl.text.trim();
    if (code.isEmpty) return;
    setState(() { _loading = true; _error = null; });
    try {
      final result = await XBoardSDK.instance.giftCard.redeemCode(code);
      setState(() {
        _loading = false;
        _redeemed = true;
        _rewards = result.rewards;
        _templateName = result.templateName;
      });
      widget.onSuccess?.call();
    } catch (e) {
      final msg = e is NetworkException
          ? (S.isEn ? 'Redemption temporarily unavailable' : '兑换服务暂不可用，请稍后重试')
          : e is XBoardException ? e.message : (S.isEn ? 'Redemption failed' : '兑换失败');
      setState(() { _loading = false; _error = msg; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width * 0.85;
    return Container(
      width: w.clamp(280, 340),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: t.cardBg, borderRadius: BorderRadius.circular(20), border: t.cardBorder,
        boxShadow: [BoxShadow(color: t.primary.withValues(alpha: 0.15), blurRadius: 30)]),
      child: _redeemed ? _buildSuccess() : _buildInput(),
    );
  }

  Widget _buildInput() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.card_giftcard, color: Color(0xFFE91E63), size: 32),
        const SizedBox(height: 10),
        Text(S.giftCardTitle, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: t.textPrimary)),
        const SizedBox(height: 14),
        Container(
          height: 44,
          decoration: BoxDecoration(
            color: t.isDark ? const Color(0xFF1E2140) : const Color(0xFFF5F7FA),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: _ctrl,
            enabled: !_loading && !_checked,
            autofillHints: const [],
            autocorrect: false,
            enableSuggestions: false,
            enableIMEPersonalizedLearning: false,
            keyboardType: TextInputType.visiblePassword,
            style: TextStyle(fontSize: 13, color: t.textPrimary),
            decoration: InputDecoration(
              hintText: S.giftCardHint, hintStyle: TextStyle(fontSize: 12, color: t.textHint),
              border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12), isDense: true,
            ),
            onSubmitted: (_) => _checked ? _redeem() : _check(),
          ),
        ),
        // Preview area
        if (_checked && _previewLines.isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(
            width: double.infinity, padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: t.primary.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: t.primary.withValues(alpha: 0.15)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.card_giftcard, size: 14, color: t.primary),
                    const SizedBox(width: 6),
                    Expanded(child: Text(_templateName ?? '', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: t.textPrimary), overflow: TextOverflow.ellipsis)),
                    if (_templateTypeName != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: t.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                        child: Text(_templateTypeName!, style: TextStyle(fontSize: 10, color: t.primary)),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(S.isEn ? 'Rewards preview:' : '奖励预览:', style: TextStyle(fontSize: 11, color: t.textSecondary)),
                const SizedBox(height: 4),
                for (final line in _previewLines)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 3),
                    child: Row(children: [
                      const Icon(Icons.star, size: 12, color: Color(0xFFFF9800)),
                      const SizedBox(width: 6),
                      Text(line, style: TextStyle(fontSize: 12, color: t.textPrimary)),
                    ]),
                  ),
              ],
            ),
          ),
        ],
        if (_error != null) ...[
          const SizedBox(height: 8),
          Text(_error!, style: TextStyle(fontSize: 12, color: t.danger), textAlign: TextAlign.center),
        ],
        const SizedBox(height: 16),
        if (_checked) ...[
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() { _checked = false; _canRedeem = false; _previewLines = []; _error = null; }),
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: t.isDark ? const Color(0xFF252850) : const Color(0xFFF0F2F8),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(child: Text(S.isEn ? 'Change' : '换一个', style: TextStyle(color: t.textSecondary, fontSize: 14, fontWeight: FontWeight.w600))),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: GestureDetector(
                  onTap: (_loading || !_canRedeem) ? null : _redeem,
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: (_loading || !_canRedeem) ? null : t.buttonGradient,
                      color: (_loading || !_canRedeem) ? t.textHint.withValues(alpha: 0.2) : null,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: _loading
                          ? SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: t.primary))
                          : Text(S.redeem, style: TextStyle(color: _canRedeem ? Colors.white : t.textHint, fontSize: 14, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ] else
          GestureDetector(
            onTap: _loading ? null : _check,
            child: Container(
              width: double.infinity, height: 44,
              decoration: BoxDecoration(
                gradient: _loading ? null : t.buttonGradient,
                color: _loading ? t.textHint.withValues(alpha: 0.2) : null,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: _loading
                    ? SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: t.primary))
                    : Text(S.isEn ? 'Check' : '查询', style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSuccess() {
    final rewardLines = <String>[];
    if (_rewards != null) {
      final r = _rewards!;
      if (r['balance'] != null && (r['balance'] as num) > 0) {
        final yuan = (r['balance'] as num) / 100;
        rewardLines.add(S.isEn ? 'Balance +¥${yuan.toStringAsFixed(2)}' : '余额 +¥${yuan.toStringAsFixed(2)}');
      }
      if (r['transfer_enable'] != null && (r['transfer_enable'] as num) > 0) {
        final gb = (r['transfer_enable'] as num) / (1024 * 1024 * 1024);
        rewardLines.add(S.isEn ? 'Traffic +${gb.toStringAsFixed(1)} GB' : '流量 +${gb.toStringAsFixed(1)} GB');
      }
      if (r['plan_id'] != null) {
        final days = r['plan_validity_days'] ?? 0;
        rewardLines.add(S.isEn ? 'Plan assigned (${days}d)' : '已分配套餐（${days}天）');
      }
      if (r['expire_days'] != null && (r['expire_days'] as num) > 0) {
        rewardLines.add(S.isEn ? 'Validity +${r['expire_days']}d' : '有效期 +${r['expire_days']}天');
      }
      if (r['device_limit'] != null && (r['device_limit'] as num) > 0) {
        rewardLines.add(S.isEn ? 'Device limit +${r['device_limit']}' : '设备数 +${r['device_limit']}');
      }
      if (r['reset_package'] == true) {
        rewardLines.add(S.isEn ? 'Traffic reset' : '流量已重置');
      }
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.check_circle, color: t.success, size: 48),
        const SizedBox(height: 12),
        Text(S.redeemSuccess, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: t.textPrimary)),
        if (_templateName != null && _templateName!.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(_templateName!, style: TextStyle(fontSize: 12, color: t.textSecondary)),
        ],
        if (rewardLines.isNotEmpty) ...[
          const SizedBox(height: 14),
          Container(
            width: double.infinity, padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: t.success.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: t.success.withValues(alpha: 0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(S.isEn ? 'Rewards:' : '奖励内容:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: t.textPrimary)),
                const SizedBox(height: 6),
                for (final line in rewardLines)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 3),
                    child: Row(children: [
                      Icon(Icons.star, size: 12, color: t.success),
                      const SizedBox(width: 6),
                      Text(line, style: TextStyle(fontSize: 12, color: t.textSecondary)),
                    ]),
                  ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 16),
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            width: double.infinity, height: 44,
            decoration: BoxDecoration(gradient: t.buttonGradient, borderRadius: BorderRadius.circular(12)),
            child: Center(child: Text(S.isEn ? 'OK' : '确定', style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600))),
          ),
        ),
      ],
    );
  }
}
