import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../mihom_theme.dart';
import '../login_dialog.dart';
import '../i18n.dart';
import '../pill_toast.dart';
import '../credential_store.dart';
import 'plans_page.dart';
import 'invite_page.dart';
import 'settings_page.dart';

class DemoProfilePage extends StatelessWidget {
  final MihomTheme theme;
  final VoidCallback? onOpenSettings;
  final bool isGuest;
  final VoidCallback? onLogin;
  final VoidCallback? onLogout;
  const DemoProfilePage({super.key, required this.theme, this.onOpenSettings, this.isGuest = true, this.onLogin, this.onLogout});

  MihomTheme get t => theme;

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
          await Future.delayed(const Duration(seconds: 1));
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
              Container(
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
                          Text('¥ 128.00', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: t.textPrimary)),
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
              ),
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
                      if (result != null) {
                        SavedCredentials.email = result['email'] ?? '';
                        SavedCredentials.password = result['password'] ?? '';
                        onLogin?.call();
                      }
                    });
                    } else {
                      _push(context, DemoInvitePage(theme: t));
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
                      if (result != null) {
                        SavedCredentials.email = result['email'] ?? '';
                        SavedCredentials.password = result['password'] ?? '';
                        onLogin?.call();
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
                _menuItem(context, Icons.headset_mic, S.onlineSupport, S.onlineSupportDesc),
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
                      if (result != null) {
                        SavedCredentials.email = result['email'] ?? '';
                        SavedCredentials.password = result['password'] ?? '';
                        onLogin?.call();
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
                      if (result != null) {
                        SavedCredentials.email = result['email'] ?? '';
                        SavedCredentials.password = result['password'] ?? '';
                        onLogin?.call();
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
                    Text(S.userName, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Text(S.vipMember, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
                child: const Text('VIP', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(S.usedTraffic, style: const TextStyle(color: Colors.white70, fontSize: 12)),
              Text('60 GB / 100 GB', style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 12)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: 0.6,
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
              Text(S.remainingDays, style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 12, fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
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
    // Mock daily usage data
    final usageData = [
      _UsageDay(S.today, 2.8, 1.2, 1.6),
      _UsageDay(S.yesterday, 4.5, 1.8, 2.7),
      _UsageDay('04-01', 3.2, 1.3, 1.9),
      _UsageDay('03-31', 5.1, 2.0, 3.1),
      _UsageDay('03-30', 1.7, 0.6, 1.1),
      _UsageDay('03-29', 6.3, 2.5, 3.8),
      _UsageDay('03-28', 3.8, 1.5, 2.3),
    ];
    final totalUsed = usageData.fold<double>(0, (sum, d) => sum + d.total);
    final maxUsage = usageData.map((d) => d.total).reduce((a, b) => a > b ? a : b);

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
                                Text(totalUsed.toStringAsFixed(1), style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                                const SizedBox(width: 4),
                                const Text('GB', style: TextStyle(color: Colors.white70, fontSize: 14)),
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
                              Text('${S.upload} ${usageData.fold<double>(0, (s, d) => s + d.upload).toStringAsFixed(1)} GB',
                                style: const TextStyle(color: Colors.white70, fontSize: 12)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.arrow_downward, color: Colors.white70, size: 14),
                              const SizedBox(width: 4),
                              Text('${S.download} ${usageData.fold<double>(0, (s, d) => s + d.download).toStringAsFixed(1)} GB',
                                style: const TextStyle(color: Colors.white70, fontSize: 12)),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ── 每日列表 ──
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      children: usageData.asMap().entries.map((entry) {
                        final i = entry.key;
                        final d = entry.value;
                        final barRatio = maxUsage > 0 ? d.total / maxUsage : 0.0;
                        return Padding(
                          padding: EdgeInsets.only(bottom: i < usageData.length - 1 ? 10 : 0),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: t.isDark ? const Color(0xFF1C1F3A) : const Color(0xFFF7F8FC),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Text(d.date, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: t.textPrimary)),
                                    const Spacer(),
                                    Text('${d.total.toStringAsFixed(1)} GB', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: t.primary)),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                // 用量条
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: SizedBox(
                                    height: 8,
                                    child: Row(
                                      children: [
                                        Expanded(
                                          flex: (d.upload * 100).round(),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(colors: [t.primary, t.primary.withValues(alpha: 0.7)]),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: (d.download * 100).round(),
                                          child: Container(color: t.secondary.withValues(alpha: 0.6)),
                                        ),
                                        Expanded(
                                          flex: ((maxUsage - d.total) * 100).round().clamp(0, 99999),
                                          child: Container(color: t.textHint.withValues(alpha: 0.1)),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Container(width: 8, height: 8, decoration: BoxDecoration(color: t.primary, borderRadius: BorderRadius.circular(2))),
                                    const SizedBox(width: 4),
                                    Text('${S.upload} ${d.upload.toStringAsFixed(1)} GB',
                                      style: TextStyle(fontSize: 11, color: t.textSecondary)),
                                    const SizedBox(width: 12),
                                    Container(width: 8, height: 8, decoration: BoxDecoration(color: t.secondary.withValues(alpha: 0.6), borderRadius: BorderRadius.circular(2))),
                                    const SizedBox(width: 4),
                                    Text('${S.download} ${d.download.toStringAsFixed(1)} GB',
                                      style: TextStyle(fontSize: 11, color: t.textSecondary)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
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
            Text('v1.0.0', style: TextStyle(fontSize: 12, color: t.textHint.withValues(alpha: 0.7))),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right, color: t.textHint.withValues(alpha: 0.5), size: 18),
          ],
        ),
      ),
    );
  }

  Widget _menuItemTg(BuildContext context) {
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
              child: Container(
                width: MediaQuery.of(ctx).size.width * 0.8,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: t.cardBg, borderRadius: BorderRadius.circular(20),
                  border: t.cardBorder,
                  boxShadow: [BoxShadow(color: t.primary.withValues(alpha: 0.15), blurRadius: 30)],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0088CC).withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.send, color: Color(0xFF0088CC), size: 32),
                    ),
                    const SizedBox(height: 16),
                    Text(S.bindTg, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: t.textPrimary)),
                    const SizedBox(height: 8),
                    Text(S.bindTgDesc, textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: t.textSecondary, height: 1.4)),
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: t.isDark ? const Color(0xFF1C1F3A) : const Color(0xFFF5F7FF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(child: Text('@Mihom_Official', style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600, color: t.primary,
                      ))),
                    ),
                    const SizedBox(height: 16),
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
                              child: Center(child: Text(S.cancel, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white70))),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.of(ctx).pop();
                              Clipboard.setData(const ClipboardData(text: 'https://t.me/Mihom_Official'));
                              showPillToast(context, t, S.tgLinkCopied);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(gradient: t.buttonGradient, borderRadius: BorderRadius.circular(12)),
                              child: Center(child: Text(S.goToBind, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white))),
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
              decoration: BoxDecoration(color: const Color(0xFF0088CC).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
              child: Text(S.notBound, style: const TextStyle(fontSize: 11, color: Color(0xFF0088CC), fontWeight: FontWeight.w500)),
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
    final ctrl = TextEditingController();
    showGeneralDialog(
      context: context,
      barrierDismissible: true, barrierLabel: 'close', barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 220),
      transitionBuilder: (ctx, a1, a2, child) => Transform.scale(
        scale: Curves.easeOutBack.transform(a1.value), child: Opacity(opacity: a1.value, child: child)),
      pageBuilder: (ctx, a1, a2) => Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: MediaQuery.of(ctx).size.width * 0.85,
            constraints: const BoxConstraints(maxWidth: 340),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: t.cardBg, borderRadius: BorderRadius.circular(20), border: t.cardBorder,
              boxShadow: [BoxShadow(color: t.primary.withValues(alpha: 0.15), blurRadius: 30)]),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.card_giftcard, color: const Color(0xFFE91E63), size: 32),
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
                    controller: ctrl,
                    style: TextStyle(fontSize: 13, color: t.textPrimary),
                    decoration: InputDecoration(
                      hintText: S.giftCardHint, hintStyle: TextStyle(fontSize: 12, color: t.textHint),
                      border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12), isDense: true,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () {
                    if (ctrl.text.trim().isEmpty) {
                      showPillToast(context, t, S.giftCardEmpty);
                      return;
                    }
                    Navigator.of(ctx).pop();
                    showPillToast(context, t, S.isEn ? 'Gift card redeemed!' : '礼品卡已兑换！');
                  },
                  child: Container(
                    width: double.infinity, height: 44,
                    decoration: BoxDecoration(gradient: t.buttonGradient, borderRadius: BorderRadius.circular(12)),
                    child: Center(child: Text(S.isEn ? 'Redeem' : '兑换', style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600))),
                  ),
                ),
              ],
            ),
          ),
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

  // ── 帮助中心弹窗 ──
  void _showHelpCenterDialog(BuildContext context) {
    final faqItems = [
      (S.isEn ? 'How to connect?' : '如何连接？', S.isEn ? 'Select a node on the home page and tap the connect button.' : '在首页选择节点后，点击连接按钮即可。'),
      (S.isEn ? 'What if the connection fails?' : '连接失败怎么办？', S.isEn ? 'Try switching nodes or syncing your subscription.' : '可尝试切换节点或刷新订阅。'),
      (S.isEn ? 'How to change my plan?' : '如何更换套餐？', S.isEn ? 'Go to Plans page to view and purchase plans.' : '进入套餐页面查看并购买新套餐。'),
      (S.isEn ? 'How does the invite reward work?' : '邀请奖励如何发放？', S.isEn ? 'Share your invite code; you earn commission when friends purchase.' : '分享邀请码，好友购买后自动获得佣金。'),
      (S.isEn ? 'How to contact support?' : '如何联系客服？', S.isEn ? 'Tap Online Support in profile page.' : '在个人中心点击在线客服。'),
    ];
    showGeneralDialog(
      context: context,
      barrierDismissible: true, barrierLabel: 'close', barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 220),
      transitionBuilder: (ctx, a1, a2, child) => Transform.scale(
        scale: Curves.easeOutBack.transform(a1.value), child: Opacity(opacity: a1.value, child: child)),
      pageBuilder: (ctx, a1, a2) => Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: MediaQuery.of(ctx).size.width * 0.85,
            constraints: const BoxConstraints(maxWidth: 400, maxHeight: 520),
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(color: t.cardBg, borderRadius: BorderRadius.circular(20), border: t.cardBorder,
              boxShadow: [BoxShadow(color: t.primary.withValues(alpha: 0.15), blurRadius: 30)]),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.help_outline, color: const Color(0xFF607D8B), size: 32),
                const SizedBox(height: 10),
                Text(S.helpCenter, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: t.textPrimary)),
                const SizedBox(height: 16),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: faqItems.length,
                    separatorBuilder: (_, __) => Divider(height: 1, color: t.textHint.withValues(alpha: 0.1)),
                    itemBuilder: (ctx2, i) {
                      return _FaqTile(q: faqItems[i].$1, a: faqItems[i].$2, theme: t);
                    },
                  ),
                ),
                const SizedBox(height: 14),
                GestureDetector(
                  onTap: () => Navigator.of(ctx).pop(),
                  child: Text(S.isEn ? 'Close' : '关闭', style: TextStyle(fontSize: 13, color: t.textSecondary)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── 我的订单弹窗 ──
  void _showOrdersDialog(BuildContext context) {
    final orders = [
      (S.isEn ? 'Standard Plan' : '标准套餐', S.isEn ? 'Monthly' : '月付', '¥29.90', '2026-03-15', S.isEn ? 'Active' : '生效中', true),
      (S.isEn ? 'Standard Plan' : '标准套餐', S.isEn ? 'Monthly' : '月付', '¥29.90', '2026-02-15', S.isEn ? 'Expired' : '已过期', false),
      (S.isEn ? 'Basic Plan' : '基础套餐', S.isEn ? 'Quarterly' : '季付', '¥59.70', '2025-11-20', S.isEn ? 'Expired' : '已过期', false),
    ];
    showGeneralDialog(
      context: context,
      barrierDismissible: true, barrierLabel: 'close', barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 220),
      transitionBuilder: (ctx, a1, a2, child) => Transform.scale(
        scale: Curves.easeOutBack.transform(a1.value), child: Opacity(opacity: a1.value, child: child)),
      pageBuilder: (ctx, a1, a2) => Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: MediaQuery.of(ctx).size.width * 0.9,
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
                      onTap: () => Navigator.of(ctx).pop(),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(color: t.textHint.withValues(alpha: 0.1), shape: BoxShape.circle),
                        child: Icon(Icons.close, color: t.textHint, size: 18),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: orders.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (ctx2, i) {
                      final o = orders[i];
                      return Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: t.isDark ? const Color(0xFF1E2140) : const Color(0xFFF7F8FC),
                          borderRadius: BorderRadius.circular(14),
                          border: o.$6 ? Border.all(color: t.primary.withValues(alpha: 0.2)) : null,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(child: Text(o.$1, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: t.textPrimary))),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: o.$6 ? t.success.withValues(alpha: 0.1) : t.textHint.withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(o.$5, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                                    color: o.$6 ? t.success : t.textHint)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Text(o.$2, style: TextStyle(fontSize: 12, color: t.textSecondary)),
                                const SizedBox(width: 12),
                                Text(o.$3, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: t.primary)),
                                const Spacer(),
                                Icon(Icons.access_time, size: 12, color: t.textHint),
                                const SizedBox(width: 4),
                                Text(o.$4, style: TextStyle(fontSize: 11, color: t.textHint)),
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
          ),
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

class _UsageDay {
  final String date;
  final double total;
  final double upload;
  final double download;
  _UsageDay(this.date, this.total, this.upload, this.download);
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
