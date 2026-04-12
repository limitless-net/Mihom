import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_clash/xboard/features/auth/providers/xboard_user_provider.dart';
import 'package:fl_clash/xboard/features/update_check/providers/update_check_provider.dart';
import 'package:flutter_xboard_sdk/flutter_xboard_sdk.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../theme/mihom_theme.dart';
import '../../i18n.dart';
import '../../widgets/pill_toast.dart';
import '../../pages/support_chat_page.dart';

/// 桌面端个人中心页 — 完整功能页面
class DesktopProfilePage extends ConsumerStatefulWidget {
  final MihomTheme theme;
  final bool isGuest;
  final VoidCallback onLogout;
  final VoidCallback? onLogin;
  final VoidCallback? onOpenSettings;

  const DesktopProfilePage({
    super.key,
    required this.theme,
    required this.isGuest,
    required this.onLogout,
    this.onLogin,
    this.onOpenSettings,
  });

  @override
  ConsumerState<DesktopProfilePage> createState() => _DesktopProfilePageState();
}

class _DesktopProfilePageState extends ConsumerState<DesktopProfilePage> {
  MihomTheme get t => widget.theme;

  @override
  void initState() {
    super.initState();
    // Refresh user data on page entry (data only, no config import)
    if (!widget.isGuest) {
      Future.microtask(() {
        ref.read(xboardUserProvider.notifier).refreshUserInfo();
        ref.read(xboardUserProvider.notifier).refreshSubscriptionInfo();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isGuest) return _guestView(context);
    return _loggedInView(context);
  }

  Widget _guestView(BuildContext context) {
    return Center(
      child: Container(
        width: 380, padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: t.cardBg, borderRadius: BorderRadius.circular(24),
          border: t.cardBorder, boxShadow: t.cardShadow,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64, height: 64,
              decoration: BoxDecoration(color: t.primary.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Icon(Icons.person_outline, color: t.primary, size: 32),
            ),
            const SizedBox(height: 16),
            Text(S.isEn ? 'Not Logged In' : '\u672a\u767b\u5f55', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: t.textPrimary)),
            const SizedBox(height: 8),
            Text(S.isEn ? 'Sign in to manage your account' : '\u767b\u5f55\u4ee5\u7ba1\u7406\u60a8\u7684\u8d26\u6237',
              style: TextStyle(fontSize: 13, color: t.textSecondary, height: 1.5), textAlign: TextAlign.center),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: widget.onLogin,
              child: Container(
                width: double.infinity, height: 44,
                decoration: BoxDecoration(gradient: t.buttonGradient, borderRadius: BorderRadius.circular(12)),
                child: Center(child: Text(S.login, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600))),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _loggedInView(BuildContext context) {
    final user = ref.watch(userInfoProvider);
    final sub = ref.watch(subscriptionInfoProvider);
    
    // Derive display values from real data
    // 流量数据优先使用 subscription（包含实际 u/d），user 的 uploadedBytes/downloadedBytes 始终为0
    final email = user?.email ?? 'user@example.com';
    final balanceYuan = (user?.balanceInCents ?? 0) / 100.0;
    final balanceStr = balanceYuan.toStringAsFixed(2);
    final commissionYuan = (user?.commissionBalanceInCents ?? 0) / 100.0;
    final totalBytes = sub?.transferLimit ?? user?.transferLimit ?? 0;
    final usedBytes = (sub?.uploadedBytes ?? 0) + (sub?.downloadedBytes ?? 0);
    final usageFraction = totalBytes > 0 ? (usedBytes / totalBytes).clamp(0.0, 1.0) : 0.0;
    final planName = sub?.planName ?? (user?.planId != null ? (S.isEn ? 'Plan #${user!.planId}' : '套餐 #${user!.planId}') : (S.isEn ? 'No Plan' : '无套餐'));
    final deviceLimit = sub?.deviceLimit;
    final expiresAt = user?.expiredAt ?? sub?.expiredAt;
    final hasPlan = user?.planId != null;
    final expiresStr = expiresAt != null
        ? '${expiresAt.year}-${expiresAt.month.toString().padLeft(2, '0')}-${expiresAt.day.toString().padLeft(2, '0')}'
        : (hasPlan ? (S.isEn ? 'Lifetime' : '长期有效') : (S.isEn ? 'N/A' : '无'));

    // 用户标签: 周期会员•id:xxx（如后端未适配则显示套餐名称）
    final bool hasAdaptedApi = user?.period != null && user!.period!.isNotEmpty && user?.userId != null;
    final String badgeText;
    if (hasAdaptedApi) {
      final periodLabel = _getPeriodLabel(user?.period);
      final userIdStr = '${user!.userId}'.padLeft(3, '0');
      badgeText = '$periodLabel•id:$userIdStr';
    } else {
      badgeText = planName;
    }
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // 响应式最大宽度：窗口较窄时填满，较宽时适度限制
          final maxW = constraints.maxWidth.clamp(400.0, 1200.0);
          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxW),
              child: CustomScrollView(
                slivers: [
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
              // ── 用户信息卡片（桌面宽布局） ──
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(gradient: t.primaryGradient, borderRadius: BorderRadius.circular(16)),
                child: Column(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 26, backgroundColor: Colors.white.withValues(alpha: 0.2),
                          child: const Icon(Icons.person, size: 28, color: Colors.white),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(S.userName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(6)),
                                    child: Text(badgeText, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(email, style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.7))),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(S.isEn ? 'Balance' : '\u8d26\u6237\u4f59\u989d', style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.7))),
                            const SizedBox(height: 2),
                            Text('\u00a5 $balanceStr', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                          ],
                        ),
                        const SizedBox(width: 12),
                        _HoverButton(
                          onTap: () => showPillToast(context, t, '${S.recharge} · ${S.devInProgress}'),
                          builder: (hover) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(color: Colors.white.withValues(alpha: hover ? 0.35 : 0.2), borderRadius: BorderRadius.circular(8)),
                            child: Text(S.recharge, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // 流量条（内嵌文字）
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: SizedBox(
                        height: 20,
                        child: Stack(
                          children: [
                            // 背景
                            Container(color: Colors.white.withValues(alpha: 0.15)),
                            // 已用部分（渐变）
                            FractionallySizedBox(
                              widthFactor: usageFraction,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Colors.white.withValues(alpha: 0.9), Colors.white.withValues(alpha: 0.55)],
                                  ),
                                ),
                              ),
                            ),
                            // 已用文字（左侧）
                            Positioned(
                              left: 8, top: 0, bottom: 0,
                              child: Center(
                                child: Text(
                                  S.isEn ? '${_formatBytes(usedBytes)} used' : '已用 ${_formatBytes(usedBytes)}',
                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600,
                                    color: t.primary.withValues(alpha: 0.85)),
                                ),
                              ),
                            ),
                            // 剩余文字（右侧）
                            Positioned(
                              right: 8, top: 0, bottom: 0,
                              child: Center(
                                child: Text(
                                  S.isEn ? '${_formatBytes((totalBytes - usedBytes).clamp(0, totalBytes))} left' : '剩余 ${_formatBytes((totalBytes - usedBytes).clamp(0, totalBytes))}',
                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600,
                                    color: Colors.white.withValues(alpha: 0.9)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // 套餐 + 到期 + 设备
                    Row(
                      children: [
                        Icon(Icons.diamond_outlined, size: 13, color: Colors.white.withValues(alpha: 0.7)),
                        const SizedBox(width: 4),
                        Text(planName, style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.8))),
                        const SizedBox(width: 16),
                        Icon(Icons.access_time, size: 13, color: Colors.white.withValues(alpha: 0.7)),
                        const SizedBox(width: 4),
                        Text('$expiresStr ${S.isEn ? "expires" : "\u5230\u671f"}', style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.8))),
                        const Spacer(),
                        Tooltip(
                          message: S.isEn ? 'Online devices' : '在线设备数',
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.devices, size: 13, color: Colors.white.withValues(alpha: 0.85)),
                                const SizedBox(width: 5),
                                Text(S.isEn
                                    ? 'Device ${deviceLimit != null && deviceLimit > 0 ? "1/$deviceLimit" : "Unlimited"}'
                                    : '设备 ${deviceLimit != null && deviceLimit > 0 ? "1/$deviceLimit" : "不限"}',
                                  style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 11, fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // ── 功能网格：撑满用户卡到底部按钮之间的空间 ──
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(child: _gridTile(context, icon: Icons.headset_mic, iconColor: const Color(0xFFFF6F00),
                            title: S.onlineSupport, subtitle: S.onlineSupportDesc, onTap: () => _openSupportChat(context))),
                          const SizedBox(width: 10),
                          Expanded(child: _gridTile(context, icon: Icons.people_outline, iconColor: const Color(0xFF9C27B0),
                            title: S.inviteFriends, subtitle: S.isEn ? 'Commission \u00a5${commissionYuan.toStringAsFixed(2)}' : '\u4f63\u91d1 \u00a5${commissionYuan.toStringAsFixed(2)}', onTap: () => _showInviteDialog(context))),
                          const SizedBox(width: 10),
                          Expanded(child: _gridTile(context, icon: Icons.receipt_long_outlined, iconColor: const Color(0xFF00BCD4),
                            title: S.isEn ? 'Orders' : '订单记录', subtitle: S.isEn ? 'View order history' : '查看订单记录', onTap: () => _showOrdersDialog(context))),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(child: _gridTile(context, icon: Icons.card_giftcard, iconColor: const Color(0xFFE91E63),
                            title: S.giftCard, subtitle: S.giftCardDesc, onTap: () => _showGiftCardDialog(context))),
                          const SizedBox(width: 10),
                          Expanded(child: _gridTile(context, icon: Icons.telegram, iconColor: const Color(0xFF2196F3),
                            title: S.bindTg, subtitle: S.isEn ? 'Get latest offers' : '\u63a5\u6536\u7fa4\u7ec4\u901a\u77e5', onTap: () => _showBindTgDialog(context))),
                          const SizedBox(width: 10),
                          Expanded(child: _gridTile(context, icon: Icons.help_outline, iconColor: const Color(0xFF607D8B),
                            title: S.helpCenter, subtitle: S.helpCenterDesc, onTap: () => _showHelpCenterDialog(context))),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(child: _gridTile(context, icon: Icons.history, iconColor: const Color(0xFF795548),
                            title: S.usageHistory, subtitle: S.usageHistoryDesc, onTap: () => _showUsageHistoryDialog(context))),
                          const SizedBox(width: 10),
                          Expanded(child: _gridTile(context, icon: Icons.system_update, iconColor: const Color(0xFF4CAF50),
                            title: S.isEn ? 'Check Update' : '版本检测', subtitle: S.isEn ? 'Check for new version' : '检测新版本更新', onTap: () => _showVersionCheckDialog(context))),
                          const SizedBox(width: 10),
                          const Expanded(child: SizedBox()),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // ── 底部：设置（左） + 退出登录（右） ──
              Row(
                children: [
                  _HoverButton(
                    onTap: widget.onOpenSettings,
                    builder: (hover) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: hover
                            ? (t.isDark ? const Color(0xFF252850) : const Color(0xFFE8EAF2))
                            : (t.isDark ? const Color(0xFF1E2140) : const Color(0xFFF0F2F8)),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: t.textHint.withValues(alpha: hover ? 0.18 : 0.1)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.settings_outlined, size: 16, color: hover ? t.primary : t.textSecondary),
                          const SizedBox(width: 6),
                          Text(S.settings,
                            style: TextStyle(fontSize: 13, color: hover ? t.primary : t.textSecondary, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                  _HoverButton(
                    onTap: () => _showLogoutDialog(context),
                    builder: (hover) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(
                        color: t.danger.withValues(alpha: hover ? 0.12 : 0.06),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: t.danger.withValues(alpha: hover ? 0.35 : 0.18)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.logout, size: 16, color: t.danger),
                          const SizedBox(width: 6),
                          Text(S.isEn ? 'Sign Out' : '退出',
                            style: TextStyle(fontSize: 13, color: t.danger, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
          ),
            ],
          ),
        ),
      );
      },
      ),
    );
  }

  Widget _gridTile(BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
  }) {
    return _HoverGridTile(
      theme: t,
      icon: icon,
      iconColor: iconColor,
      title: title,
      subtitle: subtitle,
      onTap: onTap,
    );
  }

  // ── 礼品卡弹窗 ──
  void _showGiftCardDialog(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true, barrierLabel: 'close', barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 200),
      transitionBuilder: (ctx, a1, a2, child) => Transform.scale(
        scale: Curves.easeOutBack.transform(a1.value), child: Opacity(opacity: a1.value, child: child)),
      pageBuilder: (ctx, a1, a2) => Center(
        child: Material(
          color: Colors.transparent,
          child: _GiftCardDialogContent(theme: t, parentContext: context),
        ),
      ),
    );
  }

  // ── TG绑定弹窗 ──
  void _showBindTgDialog(BuildContext context) {
    final user = ref.read(userInfoProvider);
    final tgId = user?.telegramId;
    final isBound = tgId != null && tgId.isNotEmpty;

    showGeneralDialog(
      context: context,
      barrierDismissible: true, barrierLabel: 'close', barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 200),
      transitionBuilder: (ctx, a1, a2, child) => Transform.scale(
        scale: Curves.easeOutBack.transform(a1.value), child: Opacity(opacity: a1.value, child: child)),
      pageBuilder: (ctx, a1, a2) => Center(
        child: Material(
          color: Colors.transparent,
          child: _TgDialogContent(theme: t, isBound: isBound, tgId: tgId),
        ),
      ),
    );
  }

  Widget _tgStep(int num, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 20, height: 20,
          decoration: BoxDecoration(color: t.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
          child: Center(child: Text('$num', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: t.primary))),
        ),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: TextStyle(fontSize: 12, color: t.textSecondary, height: 1.4))),
      ],
    );
  }

  // ── 邀请好友弹窗 ──
  void _showInviteDialog(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true, barrierLabel: 'close', barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 200),
      transitionBuilder: (ctx, a1, a2, child) => Transform.scale(
        scale: Curves.easeOutBack.transform(a1.value), child: Opacity(opacity: a1.value, child: child)),
      pageBuilder: (ctx, a1, a2) => Center(
        child: Material(
          color: Colors.transparent,
          child: _InviteDialogContent(theme: t),
        ),
      ),
    );
  }

  // ── 使用记录弹窗 ──
  void _showOrdersDialog(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true, barrierLabel: 'close', barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 200),
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

  void _showUsageHistoryDialog(BuildContext context) {
    // Refresh data first (data only, no config import)
    ref.read(xboardUserProvider.notifier).refreshUserInfo();
    ref.read(xboardUserProvider.notifier).refreshSubscriptionInfo();

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'close',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 200),
      transitionBuilder: (ctx, a1, a2, child) => Transform.scale(
        scale: Curves.easeOutBack.transform(a1.value),
        child: Opacity(opacity: a1.value, child: child),
      ),
      pageBuilder: (ctx, a1, a2) => Center(
        child: Material(
          color: Colors.transparent,
          child: _UsageDialogContent(theme: t, ref: ref),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: t.cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(S.logoutConfirm, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: t.textPrimary)),
        content: Text(S.logoutDesc, style: TextStyle(fontSize: 14, color: t.textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(),
            child: Text(S.cancel, style: TextStyle(color: t.textSecondary))),
          TextButton(onPressed: () {
            Navigator.of(ctx).pop();
            widget.onLogout();
          }, child: Text(S.confirm, style: TextStyle(color: t.danger))),
        ],
      ),
    );
  }

  // ── 帮助中心弹窗 ──
  void _showHelpCenterDialog(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true, barrierLabel: 'close', barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 200),
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

  /// 将 period 字段转为中文/英文标签
  static String _getPeriodLabel(String? period) {
    if (period == null || period.isEmpty) return S.isEn ? 'Free' : '免费用户';
    switch (period) {
      case 'month':     return S.isEn ? 'Monthly' : '月费会员';
      case 'quarter':   return S.isEn ? 'Quarterly' : '季费会员';
      case 'half_year': return S.isEn ? 'Semi-Annual' : '半年会员';
      case 'year':      return S.isEn ? 'Annual' : '年费会员';
      case 'two_year':  return S.isEn ? '2-Year' : '两年会员';
      case 'three_year':return S.isEn ? '3-Year' : '三年会员';
      case 'onetime':   return S.isEn ? 'Lifetime' : '一次性会员';
      case 'reset':     return S.isEn ? 'Reset' : '流量重置';
      default:          return S.isEn ? 'Member' : '会员';
    }
  }

  void _openSupportChat(BuildContext context) {
    if (widget.isGuest) {
      showPillToast(context, t, '${S.onlineSupport} · ${S.isEn ? 'Please login first' : '请先登录'}');
      widget.onLogin?.call();
      return;
    }
    showGeneralDialog(
      context: context,
      barrierDismissible: true, barrierLabel: 'close', barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 200),
      transitionBuilder: (ctx, a1, a2, child) => Transform.scale(
        scale: Curves.easeOutBack.transform(a1.value), child: Opacity(opacity: a1.value, child: child)),
      pageBuilder: (ctx, a1, a2) => Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: 480,
            height: MediaQuery.of(context).size.height * 0.75,
            decoration: BoxDecoration(color: t.scaffoldBg, borderRadius: BorderRadius.circular(16)),
            clipBehavior: Clip.antiAlias,
            child: SupportChatPage(theme: t, isDesktop: true),
          ),
        ),
      ),
    );
  }

  void _showVersionCheckDialog(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true, barrierLabel: 'close', barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 200),
      transitionBuilder: (ctx, a1, a2, child) => Transform.scale(
        scale: Curves.easeOutBack.transform(a1.value), child: Opacity(opacity: a1.value, child: child)),
      pageBuilder: (ctx, a1, a2) => Center(
        child: Material(
          color: Colors.transparent,
          child: _VersionCheckDialogContent(theme: t),
        ),
      ),
    );
  }
}

/// 带 hover 效果的通用按钮包装
class _HoverButton extends StatefulWidget {
  final VoidCallback? onTap;
  final Widget Function(bool hover) builder;
  const _HoverButton({this.onTap, required this.builder});
  @override
  State<_HoverButton> createState() => _HoverButtonState();
}

class _HoverButtonState extends State<_HoverButton> {
  bool _hover = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: widget.builder(_hover),
      ),
    );
  }
}

/// 带 hover 效果的功能网格块
class _HoverGridTile extends StatefulWidget {
  final MihomTheme theme;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  const _HoverGridTile({required this.theme, required this.icon, required this.iconColor, required this.title, this.subtitle, this.onTap});
  @override
  State<_HoverGridTile> createState() => _HoverGridTileState();
}

class _HoverGridTileState extends State<_HoverGridTile> {
  bool _hover = false;
  MihomTheme get t => widget.theme;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: _hover
                ? (t.isDark ? const Color(0xFF252850) : const Color(0xFFE8EAF2))
                : (t.isDark ? const Color(0xFF1E2140) : const Color(0xFFF0F2F8)),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _hover
                  ? (t.isDark ? Colors.white.withValues(alpha: 0.12) : const Color(0xFFCDD2E0))
                  : (t.isDark ? Colors.white.withValues(alpha: 0.06) : const Color(0xFFE0E4ED)),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(color: widget.iconColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
                child: Icon(widget.icon, color: widget.iconColor, size: 19),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(widget.title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: t.textPrimary)),
                    if (widget.subtitle != null) Text(widget.subtitle!, style: TextStyle(fontSize: 11, color: t.textHint), overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FaqItem {
  final String q;
  final String a;
  _FaqItem({required this.q, required this.a});
}

class _FaqTileWidget extends StatefulWidget {
  final _FaqItem item;
  final MihomTheme theme;
  const _FaqTileWidget({required this.item, required this.theme});

  @override
  State<_FaqTileWidget> createState() => _FaqTileWidgetState();
}

class _FaqTileWidgetState extends State<_FaqTileWidget> {
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
                Expanded(child: Text(widget.item.q, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: t.textPrimary))),
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
                child: Text(widget.item.a, style: TextStyle(fontSize: 12, color: t.textSecondary, height: 1.5)),
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

/// 帮助中心弹窗（从知识库 API 加载，回退到硬编码 FAQ）
class _HelpCenterDialogContent extends StatefulWidget {
  final MihomTheme theme;
  const _HelpCenterDialogContent({required this.theme});
  @override
  State<_HelpCenterDialogContent> createState() => _HelpCenterDialogContentState();
}

class _HelpCenterDialogContentState extends State<_HelpCenterDialogContent> {
  MihomTheme get t => widget.theme;
  bool _loading = true;
  List<_FaqItem> _faqItems = [];

  static final List<_FaqItem> _fallbackFaq = [
    _FaqItem(q: '如何连接？', a: '在首页选择节点后，点击连接按钮即可。'),
    _FaqItem(q: '连接失败怎么办？', a: '可尝试切换节点或刷新订阅。'),
    _FaqItem(q: '如何更换套餐？', a: '进入套餐页面查看并购买新套餐。'),
    _FaqItem(q: '邀请奖励如何发放？', a: '分享邀请码，好友购买后自动获得佣金。'),
    _FaqItem(q: '如何联系客服？', a: '在个人中心点击在线客服。'),
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
        // API 返回按分类分组的文章：{"常见问题": [...], "使用教程": [...]}
        // 查找包含"常见问题"或"FAQ"关键字的分类
        final List<_FaqItem> items = [];
        String? faqCategory;
        for (final key in data.keys) {
          final keyStr = key.toString();
          if (keyStr.contains('常见问题') || keyStr.toLowerCase().contains('faq')) {
            faqCategory = keyStr;
            break;
          }
        }
        // 如果没有"常见问题"分类，显示所有分类
        final categoriesToShow = faqCategory != null ? [faqCategory] : data.keys.toList();
        for (final cat in categoriesToShow) {
          final articles = data[cat];
          if (articles is List) {
            for (final article in articles) {
              final title = article['title'] as String? ?? '';
              final body = article['body'] as String? ?? '';
              // 去除 HTML 标签
              final cleanBody = body.replaceAll(RegExp(r'<[^>]*>'), '').trim();
              if (title.isNotEmpty) {
                items.add(_FaqItem(q: title, a: cleanBody.isNotEmpty ? cleanBody : '暂无详细内容'));
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
      width: 420, padding: const EdgeInsets.all(24),
      constraints: const BoxConstraints(maxHeight: 520),
      decoration: BoxDecoration(color: t.cardBg, borderRadius: BorderRadius.circular(18), border: t.cardBorder,
        boxShadow: [BoxShadow(color: t.primary.withValues(alpha: 0.15), blurRadius: 30)]),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.help_outline, color: const Color(0xFF607D8B), size: 24),
              const SizedBox(width: 10),
              Expanded(child: Text(S.helpCenter, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: t.textPrimary))),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Icon(Icons.close, size: 18, color: t.textHint),
                ),
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
                itemBuilder: (_, i) => _FaqTileWidget(item: _faqItems[i], theme: t),
              ),
            ),
        ],
      ),
    );
  }
}

/// 订单记录弹窗
class _OrdersDialogContent extends StatefulWidget {
  final MihomTheme theme;
  const _OrdersDialogContent({required this.theme});
  @override
  State<_OrdersDialogContent> createState() => _OrdersDialogContentState();
}

class _OrdersDialogContentState extends State<_OrdersDialogContent> {
  MihomTheme get t => widget.theme;
  bool _loading = true;
  List<dynamic> _orders = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    setState(() { _loading = true; _error = null; });
    try {
      final orders = await XBoardSDK.instance.order.getOrders(pageSize: 50);
      if (mounted) setState(() { _orders = orders; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e is XBoardException ? e.message : e.toString(); _loading = false; });
    }
  }

  String _periodLabel(String? period) {
    switch (period) {
      case 'monthly': case 'month_price': return S.isEn ? 'Monthly' : '月付';
      case 'quarterly': case 'quarter_price': return S.isEn ? 'Quarterly' : '季付';
      case 'half_yearly': case 'half_year_price': return S.isEn ? 'Semi-Annual' : '半年付';
      case 'yearly': case 'year_price': return S.isEn ? 'Annual' : '年付';
      case 'two_yearly': case 'two_year_price': return S.isEn ? '2 Years' : '两年付';
      case 'three_yearly': case 'three_year_price': return S.isEn ? '3 Years' : '三年付';
      case 'onetime': case 'onetime_price': return S.isEn ? 'One-time' : '一次性';
      case 'reset_traffic': case 'reset_price': return S.isEn ? 'Traffic Reset' : '流量重置';
      default: return period ?? '-';
    }
  }

  String _statusLabel(int? status) {
    switch (status) {
      case 0: return S.isEn ? 'Pending' : '待支付';
      case 1: return S.isEn ? 'Processing' : '开通中';
      case 2: return S.isEn ? 'Cancelled' : '已取消';
      case 3: return S.isEn ? 'Completed' : '已完成';
      case 4: return S.isEn ? 'Discounted' : '已折抵';
      default: return '-';
    }
  }

  Color _statusColor(int? status) {
    switch (status) {
      case 0: return const Color(0xFFFF9800);
      case 1: return const Color(0xFF2196F3);
      case 2: return const Color(0xFF9E9E9E);
      case 3: return const Color(0xFF4CAF50);
      case 4: return const Color(0xFF9C27B0);
      default: return const Color(0xFF9E9E9E);
    }
  }

  void _confirmCancelOrder(dynamic order) {
    final tradeNo = order.tradeNo as String?;
    if (tradeNo == null) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: t.cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(S.isEn ? 'Cancel Order?' : '取消订单？', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: t.textPrimary)),
        content: Text(S.isEn ? 'This action cannot be undone.' : '取消后不可恢复，确认取消此订单？',
          style: TextStyle(fontSize: 14, color: t.textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(),
            child: Text(S.cancel, style: TextStyle(color: t.textSecondary))),
          TextButton(onPressed: () {
            Navigator.of(ctx).pop();
            _doCancelOrder(tradeNo);
          }, child: Text(S.confirm, style: TextStyle(color: t.danger))),
        ],
      ),
    );
  }

  Future<void> _doCancelOrder(String tradeNo) async {
    setState(() => _loading = true);
    try {
      await XBoardSDK.instance.order.cancelOrder(tradeNo);
      if (mounted) {
        await _fetchOrders();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 480, padding: const EdgeInsets.all(24),
      constraints: const BoxConstraints(maxHeight: 560),
      decoration: BoxDecoration(color: t.cardBg, borderRadius: BorderRadius.circular(18), border: t.cardBorder,
        boxShadow: [BoxShadow(color: t.primary.withValues(alpha: 0.15), blurRadius: 30)]),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: const Color(0xFF00BCD4).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.receipt_long, color: Color(0xFF00BCD4), size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(S.isEn ? 'Order History' : '订单记录',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: t.textPrimary))),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: _loading ? null : _fetchOrders,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(color: t.primary.withValues(alpha: 0.1), shape: BoxShape.circle),
                    child: _loading
                        ? SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: t.primary))
                        : Icon(Icons.refresh, color: t.primary, size: 16),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(color: t.textHint.withValues(alpha: 0.1), shape: BoxShape.circle),
                    child: Icon(Icons.close, color: t.textHint, size: 16),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_loading)
            const Padding(padding: EdgeInsets.all(30), child: CircularProgressIndicator(strokeWidth: 2))
          else if (_error != null)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(S.isEn ? 'Failed to load orders' : '加载订单失败', style: TextStyle(color: t.textSecondary)),
            )
          else if (_orders.isEmpty)
            Padding(
              padding: const EdgeInsets.all(30),
              child: Column(
                children: [
                  Icon(Icons.inbox_outlined, size: 40, color: t.textHint.withValues(alpha: 0.3)),
                  const SizedBox(height: 8),
                  Text(S.isEn ? 'No orders yet' : '暂无订单记录', style: TextStyle(color: t.textSecondary, fontSize: 13)),
                ],
              ),
            )
          else
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: _orders.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) {
                  final order = _orders[i];
                  final planName = order.orderPlan?.name ?? (S.isEn ? 'Plan #${order.planId}' : '套餐 #${order.planId}');
                  final amount = order.totalAmount ?? 0;
                  final createdAt = order.createdAt;
                  final dateStr = createdAt != null
                      ? '${createdAt.year}-${createdAt.month.toString().padLeft(2, '0')}-${createdAt.day.toString().padLeft(2, '0')}'
                      : '-';
                  final isActive = order.status == 3;
                  final canCancel = order.status == 0 || order.status == 1; // 待支付或开通中可取消
                  return Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: t.isDark ? const Color(0xFF1E2140) : const Color(0xFFF7F8FC),
                      borderRadius: BorderRadius.circular(14),
                      border: isActive ? Border.all(color: t.primary.withValues(alpha: 0.2)) : null,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(child: Text(planName, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: t.textPrimary))),
                            Text('¥${(amount / 100).toStringAsFixed(2)}',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: t.primary)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text('${_periodLabel(order.period)} · $dateStr',
                              style: TextStyle(fontSize: 12, color: t.textSecondary)),
                            const Spacer(),
                            if (canCancel) ...[
                              MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: GestureDetector(
                                  onTap: () => _confirmCancelOrder(order),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: t.danger.withValues(alpha: 0.08),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: t.danger.withValues(alpha: 0.2)),
                                    ),
                                    child: Text(S.isEn ? 'Cancel' : '取消订单',
                                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: t.danger)),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                            ],
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: _statusColor(order.status).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(_statusLabel(order.status),
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _statusColor(order.status))),
                            ),
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

/// TG 绑定弹窗内容（异步加载 bot info + discuss link）
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
      // 并行获取 bot info 和 comm config
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
    return Container(
      width: 400, padding: const EdgeInsets.all(24),
      constraints: const BoxConstraints(maxHeight: 560),
      decoration: BoxDecoration(color: t.cardBg, borderRadius: BorderRadius.circular(18), border: t.cardBorder,
        boxShadow: [BoxShadow(color: t.primary.withValues(alpha: 0.15), blurRadius: 30)]),
      child: SingleChildScrollView(
        child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Header ──
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: const Color(0xFF2196F3).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.telegram, color: Color(0xFF2196F3), size: 28),
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
          const SizedBox(height: 20),
          if (_loading)
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: t.primary)),
            )
          else ...[
            // ── Section 1: 绑定账号 ──
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: t.isDark ? const Color(0xFF1C1F3A) : const Color(0xFFF7F8FC),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: t.textHint.withValues(alpha: 0.08)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.link, color: t.primary, size: 18),
                      const SizedBox(width: 8),
                      Text(S.isEn ? 'Bind Account' : '绑定账号',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: t.textPrimary)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(S.isEn
                      ? 'Bind your account via Telegram Bot to receive expiry reminders, traffic alerts, and daily check-in rewards.'
                      : '通过 Telegram Bot 绑定您的账号，即可接收到期提醒、流量预警和每日签到领流量等功能。',
                    style: TextStyle(fontSize: 12, color: t.textSecondary, height: 1.5)),
                  const SizedBox(height: 14),
                  // 复制绑定命令
                  _tgActionButton(
                    icon: Icons.copy_outlined,
                    label: S.isEn ? 'Copy Bind Command' : '复制绑定命令',
                    color: const Color(0xFF2196F3),
                    onTap: () {
                      final baseUrl = XBoardSDK.instance.baseUrl ?? '';
                      // 绑定命令格式: /binduser@botname <token>
                      // 简化为让用户复制后发送给 bot
                      Clipboard.setData(ClipboardData(text: '/binduser'));
                      showPillToast(context, t, S.isEn ? 'Bind command copied' : '绑定命令已复制');
                    },
                  ),
                  const SizedBox(height: 8),
                  // 打开 Telegram Bot
                  _tgActionButton(
                    icon: Icons.open_in_new,
                    label: S.isEn ? 'Open Telegram Bot' : '打开 Telegram Bot',
                    color: const Color(0xFF2196F3),
                    onTap: () async {
                      if (_botUsername != null && _botUsername!.isNotEmpty) {
                        final uri = Uri.parse('https://t.me/$_botUsername');
                        await launchUrl(uri, mode: LaunchMode.externalApplication);
                      } else {
                        showPillToast(context, t, S.isEn ? 'Bot not configured' : 'Bot 未配置');
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            // ── Section 2: 加入交流群 ──
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: t.isDark ? const Color(0xFF1C1F3A) : const Color(0xFFF7F8FC),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: t.textHint.withValues(alpha: 0.08)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.groups_outlined, color: const Color(0xFF4CAF50), size: 18),
                      const SizedBox(width: 8),
                      Text(S.isEn ? 'Join Community' : '加入交流群',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: t.textPrimary)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(S.isEn
                      ? 'Join the Telegram group to get the latest announcements, participate in discussions and get technical support.'
                      : '加入 Telegram 群组，获取最新公告、参与讨论和获得技术支持。',
                    style: TextStyle(fontSize: 12, color: t.textSecondary, height: 1.5)),
                  const SizedBox(height: 14),
                  _tgActionButton(
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

  Widget _tgActionButton({required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
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
      ),
    );
  }
}

/// 模拟二维码图案的 CustomPainter
class _QrPlaceholderPainter extends CustomPainter {
  final Color color;
  _QrPlaceholderPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final cellSize = size.width / 21;
    // 三个定位角 (7×7)
    _drawFinder(canvas, paint, 0, 0, cellSize);
    _drawFinder(canvas, paint, 14 * cellSize, 0, cellSize);
    _drawFinder(canvas, paint, 0, 14 * cellSize, cellSize);
    // 随机数据模块
    final seed = 42;
    for (int r = 0; r < 21; r++) {
      for (int c = 0; c < 21; c++) {
        if (_inFinder(r, c)) continue;
        if ((r * 31 + c * 17 + seed) % 3 == 0) {
          canvas.drawRRect(
            RRect.fromRectAndRadius(Rect.fromLTWH(c * cellSize + 0.5, r * cellSize + 0.5, cellSize - 1, cellSize - 1), const Radius.circular(1)),
            paint,
          );
        }
      }
    }
  }

  bool _inFinder(int r, int c) {
    if (r < 8 && c < 8) return true;
    if (r < 8 && c > 12) return true;
    if (r > 12 && c < 8) return true;
    return false;
  }

  void _drawFinder(Canvas canvas, Paint paint, double x, double y, double cell) {
    // 外框
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(x, y, 7 * cell, 7 * cell), const Radius.circular(2)), paint);
    // 内白
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(x + cell, y + cell, 5 * cell, 5 * cell), const Radius.circular(1)), Paint()..color = Colors.white);
    // 内实心
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(x + 2 * cell, y + 2 * cell, 3 * cell, 3 * cell), const Radius.circular(1)), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ══════════════════════════════════════════════
// 邀请好友弹窗（独立 StatefulWidget，支持异步加载）
// ══════════════════════════════════════════════

class _InviteDialogContent extends StatefulWidget {
  final MihomTheme theme;
  const _InviteDialogContent({required this.theme});
  @override
  State<_InviteDialogContent> createState() => _InviteDialogContentState();
}

class _InviteDialogContentState extends State<_InviteDialogContent> {
  MihomTheme get t => widget.theme;
  bool _loading = true;
  String? _error;
  List<InviteCodeModel> _codes = [];
  int _totalInvites = 0;
  double _totalCommissionYuan = 0;
  int _commissionRate = 0;
  double _pendingYuan = 0;
  bool _transferring = false;
  bool _generating = false;

  // 提现配置
  List<String> _withdrawMethods = [];
  bool _withdrawClosed = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() { _loading = true; _error = null; });
    try {
      final results = await Future.wait([
        XBoardSDK.instance.invite.getInviteInfo(),
        XBoardSDK.instance.httpService.getRequest('/api/v1/user/comm/config').catchError((_) => <String, dynamic>{}),
      ]);
      final info = results[0] as InviteInfoModel;
      final commConfig = results[1] as Map<String, dynamic>;
      final commData = commConfig['data'] as Map<String, dynamic>? ?? commConfig;
      if (!mounted) return;
      setState(() {
        _codes = info.codes;
        _totalInvites = info.totalInvites;
        _totalCommissionYuan = info.totalCommission / 100.0;
        _commissionRate = info.commissionRate;
        _pendingYuan = info.pendingCommission / 100.0;
        _withdrawClosed = (commData['withdraw_close'] ?? 1) == 1;
        final methods = commData['withdraw_methods'];
        if (methods is List) {
          _withdrawMethods = methods.map((e) => e.toString()).toList();
        }
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Future<void> _handleGenerate() async {
    setState(() => _generating = true);
    try {
      await XBoardSDK.instance.invite.generateInviteCode();
      await _loadData();
      if (mounted) showPillToast(context, t, S.isEn ? 'Invite code generated' : '邀请码已生成');
    } catch (e) {
      if (mounted) showPillToast(context, t, e is XBoardException ? e.message : '$e');
    } finally {
      if (mounted) setState(() => _generating = false);
    }
  }

  Future<void> _handleTransfer() async {
    if (_pendingYuan <= 0) {
      showPillToast(context, t, S.isEn ? 'No commission to transfer' : '暂无可划转佣金');
      return;
    }
    setState(() => _transferring = true);
    try {
      await XBoardSDK.instance.invite.transferCommissionToBalance(_pendingYuan * 100);
      await _loadData();
      if (mounted) showPillToast(context, t, S.isEn ? 'Transferred to balance' : '已划转到余额');
    } catch (e) {
      if (mounted) showPillToast(context, t, S.isEn ? 'Transfer failed' : '划转失败');
    } finally {
      if (mounted) setState(() => _transferring = false);
    }
  }

  void _showWithdrawDialog() {
    if (_pendingYuan <= 0) {
      showPillToast(context, t, S.isEn ? 'No commission to withdraw' : '暂无可提现佣金');
      return;
    }
    String? selectedMethod = _withdrawMethods.isNotEmpty ? _withdrawMethods.first : null;
    final accountCtrl = TextEditingController();
    bool submitting = false;

    showGeneralDialog(
      context: context,
      barrierDismissible: true, barrierLabel: 'close', barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 220),
      transitionBuilder: (ctx, a1, a2, child) => Transform.scale(
        scale: Curves.easeOutBack.transform(a1.value), child: Opacity(opacity: a1.value, child: child)),
      pageBuilder: (ctx, a1, a2) => Center(
        child: Material(
          color: Colors.transparent,
          child: StatefulBuilder(
            builder: (ctx2, setDialogState) {
              return Container(
                width: 380,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(color: t.cardBg, borderRadius: BorderRadius.circular(18), border: t.cardBorder,
                  boxShadow: [BoxShadow(color: t.primary.withValues(alpha: 0.15), blurRadius: 30)]),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(S.isEn ? 'Withdraw Commission' : '佣金提现', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: t.textPrimary)),
                    const SizedBox(height: 4),
                    Text(S.isEn ? 'Available: ¥${_pendingYuan.toStringAsFixed(2)}' : '可提现: ¥${_pendingYuan.toStringAsFixed(2)}',
                      style: TextStyle(fontSize: 12, color: t.textSecondary)),
                    const SizedBox(height: 16),
                    // 提现方式选择
                    Align(alignment: Alignment.centerLeft,
                      child: Text(S.isEn ? 'Withdraw Method' : '提现方式', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: t.textSecondary))),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8, runSpacing: 8,
                      children: _withdrawMethods.map((m) {
                        final sel = m == selectedMethod;
                        return MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: () => setDialogState(() => selectedMethod = m),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: sel ? t.primary.withValues(alpha: 0.1) : (t.isDark ? const Color(0xFF1E2140) : const Color(0xFFF5F7FA)),
                                borderRadius: BorderRadius.circular(8),
                                border: sel ? Border.all(color: t.primary.withValues(alpha: 0.5)) : null,
                              ),
                              child: Text(m, style: TextStyle(fontSize: 13, fontWeight: sel ? FontWeight.w600 : FontWeight.normal, color: sel ? t.primary : t.textPrimary)),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 14),
                    // 提现账号
                    Align(alignment: Alignment.centerLeft,
                      child: Text(S.isEn ? 'Withdraw Account' : '提现账号', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: t.textSecondary))),
                    const SizedBox(height: 8),
                    Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: t.isDark ? const Color(0xFF1E2140) : const Color(0xFFF5F7FA),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TextField(
                        controller: accountCtrl,
                        style: TextStyle(fontSize: 13, color: t.textPrimary),
                        decoration: InputDecoration(
                          hintText: S.isEn ? 'Enter your account' : '请输入提现账号',
                          hintStyle: TextStyle(fontSize: 12, color: t.textHint),
                          border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12), isDense: true,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: submitting ? null : () async {
                          if (selectedMethod == null) {
                            showPillToast(context, t, S.isEn ? 'Select a method' : '请选择提现方式');
                            return;
                          }
                          if (accountCtrl.text.trim().isEmpty) {
                            showPillToast(context, t, S.isEn ? 'Enter account' : '请输入提现账号');
                            return;
                          }
                          setDialogState(() => submitting = true);
                          try {
                            final http = XBoardSDK.instance.httpService;
                            await http.postRequest('/api/v1/user/ticket/withdraw', {
                              'withdraw_method': selectedMethod,
                              'withdraw_account': accountCtrl.text.trim(),
                            });
                            if (ctx2.mounted) Navigator.of(ctx2).pop();
                            if (mounted) {
                              showPillToast(context, t, S.isEn ? 'Withdrawal request submitted' : '提现申请已提交');
                              _loadData();
                            }
                          } catch (e) {
                            if (ctx2.mounted) showPillToast(ctx2, t, e is XBoardException ? e.message : e.toString());
                            setDialogState(() => submitting = false);
                          }
                        },
                        child: Container(
                          width: double.infinity, height: 44,
                          decoration: BoxDecoration(gradient: t.buttonGradient, borderRadius: BorderRadius.circular(12)),
                          child: Center(
                            child: submitting
                                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                : Text(S.isEn ? 'Submit Withdrawal' : '提交提现', style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeCode = _codes.where((c) => c.isActive).toList();
    final displayCode = activeCode.isNotEmpty ? activeCode.first.code : (_codes.isNotEmpty ? _codes.first.code : '');

    return Container(
      width: 380, padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
      decoration: BoxDecoration(color: t.cardBg, borderRadius: BorderRadius.circular(18), border: t.cardBorder,
        boxShadow: [BoxShadow(color: t.primary.withValues(alpha: 0.15), blurRadius: 30)]),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.topRight,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Padding(padding: const EdgeInsets.all(4), child: Icon(Icons.close, size: 20, color: t.textHint)),
            ),
          ),
          if (_loading)
            const Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator())
          else if (_error != null)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Icon(Icons.error_outline, color: t.danger, size: 32),
                  const SizedBox(height: 8),
                  Text(_error!, style: TextStyle(fontSize: 12, color: t.textSecondary), textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  GestureDetector(onTap: _loadData, child: Text(S.isEn ? 'Retry' : '重试', style: TextStyle(color: t.primary, fontWeight: FontWeight.w600))),
                ],
              ),
            )
          else
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 48, height: 48,
                      decoration: BoxDecoration(gradient: t.primaryGradient, borderRadius: BorderRadius.circular(14)),
                      child: const Icon(Icons.people, color: Colors.white, size: 24),
                    ),
                    const SizedBox(height: 12),
                    Text(S.inviteFriends, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: t.textPrimary)),
                    const SizedBox(height: 12),
                    // 统计
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _stat(S.isEn ? 'Invited' : '已邀请', '$_totalInvites'),
                        Container(width: 1, height: 24, color: t.textHint.withValues(alpha: 0.15), margin: const EdgeInsets.symmetric(horizontal: 16)),
                        _stat(S.isEn ? 'Commission' : '累计佣金', '¥${_totalCommissionYuan.toStringAsFixed(2)}'),
                        Container(width: 1, height: 24, color: t.textHint.withValues(alpha: 0.15), margin: const EdgeInsets.symmetric(horizontal: 16)),
                        _stat(S.isEn ? 'Rate' : '返利比例', '$_commissionRate%'),
                      ],
                    ),
                    const SizedBox(height: 14),
                    // 待划转佣金 + 提现/划转按钮（紧凑排版）
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: t.isDark ? const Color(0xFF1E2140) : const Color(0xFFF5F7FA),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          // 待划转金额
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(S.isEn ? 'Pending' : '待划转', style: TextStyle(fontSize: 10, color: t.textHint)),
                              const SizedBox(height: 2),
                              Text('¥${_pendingYuan.toStringAsFixed(2)}', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: t.primary)),
                            ],
                          ),
                          const Spacer(),
                          // 提现按钮
                          MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
                              onTap: () {
                                if (_withdrawClosed) {
                                  showPillToast(context, t, S.isEn ? 'Withdrawal is currently closed' : '提现功能暂未开放');
                                } else {
                                  _showWithdrawDialog();
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: t.primary.withValues(alpha: 0.3)),
                                ),
                                child: Text(S.isEn ? 'Withdraw' : '提现', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: t.primary)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // 划转到余额按钮
                          GestureDetector(
                            onTap: _transferring ? null : _handleTransfer,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(gradient: t.buttonGradient, borderRadius: BorderRadius.circular(6)),
                              child: _transferring
                                ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                : Text(S.isEn ? 'To Balance' : '划转到余额', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // 邀请二维码
                    if (displayCode.isNotEmpty) ...[
                      Builder(builder: (_) {
                        final baseUrl = XBoardSDK.instance.baseUrl ?? '';
                        final inviteUrl = baseUrl.isNotEmpty ? '$baseUrl/#/register?code=$displayCode' : displayCode;
                        return Column(
                          children: [
                            Container(
                              width: 150, height: 150,
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: t.textHint.withValues(alpha: 0.12)),
                              ),
                              child: QrImageView(
                                data: inviteUrl,
                                version: QrVersions.auto,
                                size: 134,
                                eyeStyle: QrEyeStyle(eyeShape: QrEyeShape.square, color: t.primary),
                                dataModuleStyle: QrDataModuleStyle(dataModuleShape: QrDataModuleShape.square, color: t.primary),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(S.isEn ? 'Scan to register' : '扫码注册',
                                  style: TextStyle(fontSize: 11, color: t.textHint)),
                                const SizedBox(width: 12),
                                GestureDetector(
                                  onTap: () {
                                    Clipboard.setData(ClipboardData(text: inviteUrl));
                                    showPillToast(context, t, S.isEn ? 'Invite link copied' : '邀请链接已复制');
                                  },
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.link, size: 14, color: t.primary),
                                      const SizedBox(width: 3),
                                      Text(S.isEn ? 'Copy Link' : '复制链接', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: t.primary)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      }),
                      const SizedBox(height: 14),
                    ],
                    // 邀请码
                    Text(S.myInviteCode, style: TextStyle(fontSize: 12, color: t.textSecondary)),
                    const SizedBox(height: 6),
                    if (displayCode.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: t.isDark ? const Color(0xFF1E2140) : const Color(0xFFF5F7FA),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(displayCode, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: t.primary, letterSpacing: 3)),
                            const SizedBox(width: 12),
                            GestureDetector(
                              onTap: () {
                                Clipboard.setData(ClipboardData(text: displayCode));
                                showPillToast(context, t, S.inviteCodeCopied);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(gradient: t.buttonGradient, borderRadius: BorderRadius.circular(6)),
                                child: Text(S.isEn ? 'Copy' : '复制', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      GestureDetector(
                        onTap: _generating ? null : _handleGenerate,
                        child: Container(
                          height: 40, width: double.infinity,
                          decoration: BoxDecoration(gradient: t.buttonGradient, borderRadius: BorderRadius.circular(10)),
                          child: Center(child: _generating
                            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : Text(S.isEn ? 'Generate Invite Code' : '生成邀请码',
                                style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600))),
                        ),
                      ),
                    // 邀请码列表（如果有多个）
                    if (_codes.length > 1) ...[
                      const SizedBox(height: 12),
                      Text(S.isEn ? 'All Codes' : '所有邀请码', style: TextStyle(fontSize: 12, color: t.textSecondary)),
                      const SizedBox(height: 6),
                      ..._codes.map((c) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: t.isDark ? const Color(0xFF1C1F3A) : const Color(0xFFF7F8FC),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(c.isActive ? Icons.check_circle : Icons.cancel, size: 14,
                                color: c.isActive ? const Color(0xFF4CAF50) : t.textHint),
                              const SizedBox(width: 8),
                              Expanded(child: Text(c.code, style: TextStyle(fontSize: 12, color: t.textPrimary, fontFamily: 'monospace'))),
                              Text('${S.isEn ? "Views" : "浏览"}: ${c.pv}', style: TextStyle(fontSize: 10, color: t.textHint)),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () {
                                  Clipboard.setData(ClipboardData(text: c.code));
                                  showPillToast(context, t, S.inviteCodeCopied);
                                },
                                child: Icon(Icons.copy, size: 14, color: t.primary),
                              ),
                            ],
                          ),
                        ),
                      )),
                    ],
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _stat(String label, String value) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: t.primary)),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 10, color: t.textHint)),
      ],
    );
  }
}

// ══════════════════════════════════════════════
// 使用记录弹窗（独立 StatefulWidget，支持实时刷新）
// ══════════════════════════════════════════════

String _formatBytes(int bytes) {
  if (bytes <= 0) return '0 B';
  const units = ['B', 'KB', 'MB', 'GB', 'TB'];
  int i = 0;
  double size = bytes.toDouble();
  while (size >= 1024 && i < units.length - 1) {
    size /= 1024;
    i++;
  }
  return '${size.toStringAsFixed(i > 1 ? 2 : 0)} ${units[i]}';
}

class _UsageDialogContent extends StatefulWidget {
  final MihomTheme theme;
  final WidgetRef ref;
  const _UsageDialogContent({required this.theme, required this.ref});
  @override
  State<_UsageDialogContent> createState() => _UsageDialogContentState();
}

class _UsageDialogContentState extends State<_UsageDialogContent> {
  MihomTheme get t => widget.theme;
  bool _refreshing = false;

  Future<void> _refresh() async {
    setState(() => _refreshing = true);
    try {
      await widget.ref.read(xboardUserProvider.notifier).refreshUserInfo();
      await widget.ref.read(xboardUserProvider.notifier).refreshSubscriptionInfo();
    } catch (_) {}
    if (mounted) setState(() => _refreshing = false);
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.ref.read(userInfoProvider);
    final sub = widget.ref.read(subscriptionInfoProvider);

    // 流量数据优先从 subscription 获取（user 的 uploadedBytes/downloadedBytes 始终为0）
    final uploadBytes = sub?.uploadedBytes ?? 0;
    final downloadBytes = sub?.downloadedBytes ?? 0;
    final totalUsedBytes = uploadBytes + downloadBytes;
    final transferLimit = sub?.transferLimit ?? user?.transferLimit ?? 0;
    final usagePct = transferLimit > 0 ? (totalUsedBytes / transferLimit * 100).clamp(0, 100) : 0.0;

    final nextReset = sub?.nextResetAt;
    final nextResetStr = nextReset != null
        ? '${nextReset.year}-${nextReset.month.toString().padLeft(2, '0')}-${nextReset.day.toString().padLeft(2, '0')}'
        : (S.isEn ? 'N/A' : '无');

    return Container(
      width: 420,
      constraints: const BoxConstraints(maxHeight: 520),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: t.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: t.cardBorder,
        boxShadow: [BoxShadow(color: t.primary.withValues(alpha: 0.15), blurRadius: 30)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Header ──
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: t.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                child: Icon(Icons.history, color: t.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(S.usageHistoryTitle, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: t.textPrimary)),
                    const SizedBox(height: 2),
                    Text(S.usageHistoryDesc, style: TextStyle(fontSize: 11, color: t.textSecondary)),
                  ],
                ),
              ),
              // 刷新按钮
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: _refreshing ? null : _refresh,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(color: t.primary.withValues(alpha: 0.1), shape: BoxShape.circle),
                    child: _refreshing
                        ? SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: t.primary))
                        : Icon(Icons.refresh, color: t.primary, size: 16),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(color: t.textHint.withValues(alpha: 0.1), shape: BoxShape.circle),
                    child: Icon(Icons.close, color: t.textHint, size: 16),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // ── Total Usage Summary ──
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(gradient: t.primaryGradient, borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(S.totalUsed, style: const TextStyle(color: Colors.white70, fontSize: 11)),
                      const SizedBox(height: 4),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(_formatBytes(totalUsedBytes), style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
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
                        const Icon(Icons.arrow_upward, color: Colors.white70, size: 13),
                        const SizedBox(width: 4),
                        Text('${S.upload} ${_formatBytes(uploadBytes)}',
                          style: const TextStyle(color: Colors.white70, fontSize: 11)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.arrow_downward, color: Colors.white70, size: 13),
                        const SizedBox(width: 4),
                        Text('${S.download} ${_formatBytes(downloadBytes)}',
                          style: const TextStyle(color: Colors.white70, fontSize: 11)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          // ── 详细信息 ──
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: t.isDark ? const Color(0xFF1C1F3A) : const Color(0xFFF7F8FC),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _infoRow(S.isEn ? 'Total Quota' : '总流量', _formatBytes(transferLimit)),
                const SizedBox(height: 8),
                _infoRow(S.isEn ? 'Remaining' : '剩余流量', _formatBytes((transferLimit - totalUsedBytes).clamp(0, transferLimit))),
                const SizedBox(height: 8),
                _infoRow(S.isEn ? 'Usage' : '使用率', '${usagePct.toStringAsFixed(1)}%'),
                const SizedBox(height: 8),
                _infoRow(S.isEn ? 'Upload' : '上传', _formatBytes(uploadBytes)),
                const SizedBox(height: 8),
                _infoRow(S.isEn ? 'Download' : '下载', _formatBytes(downloadBytes)),
                const SizedBox(height: 8),
                _infoRow(S.isEn ? 'Next Reset' : '下次重置', nextResetStr),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // 流量条
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              height: 20,
              child: Stack(
                children: [
                  Container(color: t.textHint.withValues(alpha: 0.12)),
                  FractionallySizedBox(
                    widthFactor: usagePct / 100,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [t.primary, t.primary.withValues(alpha: 0.6)]),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 8, top: 0, bottom: 0,
                    child: Center(
                      child: Text(
                        S.isEn ? '${_formatBytes(totalUsedBytes)} used' : '已用 ${_formatBytes(totalUsedBytes)}',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: t.primary.withValues(alpha: 0.85)),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 8, top: 0, bottom: 0,
                    child: Center(
                      child: Text(
                        S.isEn ? '${_formatBytes((transferLimit - totalUsedBytes).clamp(0, transferLimit))} left' : '剩余 ${_formatBytes((transferLimit - totalUsedBytes).clamp(0, transferLimit))}',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: t.textSecondary),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: t.textSecondary)),
        const Spacer(),
        Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: t.textPrimary)),
      ],
    );
  }
}

/// 版本检测弹窗
class _VersionCheckDialogContent extends ConsumerStatefulWidget {
  final MihomTheme theme;
  const _VersionCheckDialogContent({required this.theme});
  @override
  ConsumerState<_VersionCheckDialogContent> createState() => _VersionCheckDialogContentState();
}

class _VersionCheckDialogContentState extends ConsumerState<_VersionCheckDialogContent> {
  MihomTheme get t => widget.theme;
  bool _checking = false;
  bool _checked = false;
  bool _hasUpdate = false;
  String _currentVersion = '';
  String _latestVersion = '';
  String _releaseNotes = '';
  String _updateUrl = '';
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkVersion();
    });
  }

  Future<void> _checkVersion() async {
    setState(() { _checking = true; _error = null; });
    try {
      final notifier = ref.read(updateCheckProvider.notifier);
      await notifier.checkForUpdates();
      final state = ref.read(updateCheckProvider);
      if (!mounted) return;
      setState(() {
        _checking = false;
        _checked = true;
        _hasUpdate = state.hasUpdate;
        _currentVersion = state.currentVersion ?? '';
        _latestVersion = state.latestVersion ?? '';
        _releaseNotes = state.releaseNotes ?? '';
        _updateUrl = state.updateUrl ?? '';
        _error = state.error;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _checking = false;
        _checked = true;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 420,
      constraints: const BoxConstraints(maxHeight: 460),
      decoration: BoxDecoration(
        color: t.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: t.cardBorder,
        boxShadow: [BoxShadow(color: t.primary.withValues(alpha: 0.15), blurRadius: 30)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 标题栏
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 18, 18, 0),
            child: Row(
              children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(color: const Color(0xFF4CAF50).withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.system_update, color: Color(0xFF4CAF50), size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(child: Text(S.isEn ? 'Version Check' : '版本检测', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: t.textPrimary))),
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(color: t.textHint.withValues(alpha: 0.1), shape: BoxShape.circle),
                      child: Icon(Icons.close, color: t.textHint, size: 18),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // 内容
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: _checking
                ? Column(
                    children: [
                      const SizedBox(height: 30),
                      CircularProgressIndicator(color: t.primary),
                      const SizedBox(height: 16),
                      Text(S.isEn ? 'Checking for updates...' : '正在检测更新...', style: TextStyle(fontSize: 14, color: t.textSecondary)),
                      const SizedBox(height: 30),
                    ],
                  )
                : _error != null
                    ? Column(
                        children: [
                          const SizedBox(height: 20),
                          Icon(Icons.error_outline, color: t.danger, size: 40),
                          const SizedBox(height: 12),
                          Text(S.isEn ? 'Check failed' : '检测失败', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: t.textPrimary)),
                          const SizedBox(height: 8),
                          Text(_error!, style: TextStyle(fontSize: 12, color: t.textSecondary), textAlign: TextAlign.center),
                          const SizedBox(height: 16),
                          MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
                              onTap: _checkVersion,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                                decoration: BoxDecoration(gradient: t.buttonGradient, borderRadius: BorderRadius.circular(10)),
                                child: Text(S.isEn ? 'Retry' : '重试', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      )
                    : _hasUpdate
                        ? Column(
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
                                  child: Scrollbar(
                                    thumbVisibility: true,
                                    child: SingleChildScrollView(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(S.changelog, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: t.textSecondary)),
                                        const SizedBox(height: 10),
                                        Text(_releaseNotes, style: TextStyle(fontSize: 13, color: t.textPrimary, height: 1.4)),
                                      ],
                                    ),
                                    ),
                                  ),
                                ),
                              ],
                              const SizedBox(height: 18),
                              // 按钮行
                              Row(
                                children: [
                                  Expanded(
                                    child: MouseRegion(
                                      cursor: SystemMouseCursors.click,
                                      child: GestureDetector(
                                        onTap: () => Navigator.of(context).pop(),
                                        child: Container(
                                          height: 44,
                                          decoration: BoxDecoration(color: t.textHint.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(14)),
                                          child: Center(child: Text(S.updateLater, style: TextStyle(color: t.textSecondary, fontSize: 14, fontWeight: FontWeight.w600))),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: MouseRegion(
                                      cursor: SystemMouseCursors.click,
                                      child: GestureDetector(
                                        onTap: () {
                                          HapticFeedback.mediumImpact();
                                          if (_updateUrl.isNotEmpty) launchUrl(Uri.parse(_updateUrl));
                                          Navigator.of(context).pop();
                                        },
                                        child: Container(
                                          height: 44,
                                          decoration: BoxDecoration(
                                            gradient: t.buttonGradient, borderRadius: BorderRadius.circular(14),
                                            boxShadow: [BoxShadow(color: t.primary.withValues(alpha: 0.25), blurRadius: 14, offset: const Offset(0, 4))],
                                          ),
                                          child: Center(child: Text(S.updateNow, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600))),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          )
                        : Column(
                            children: [
                              const SizedBox(height: 20),
                              Icon(Icons.check_circle, color: t.success, size: 48),
                              const SizedBox(height: 12),
                              Text(S.isEn ? 'Up to Date!' : '已是最新版本！', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: t.textPrimary)),
                              const SizedBox(height: 8),
                              Text(
                                S.isEn ? 'Current version: $_currentVersion' : '当前版本: $_currentVersion',
                                style: TextStyle(fontSize: 13, color: t.textSecondary),
                              ),
                              const SizedBox(height: 24),
                            ],
                          ),
          ),
        ],
      ),
    );
  }
}

/// 礼品卡兑换弹窗（接入API）
class _GiftCardDialogContent extends StatefulWidget {
  final MihomTheme theme;
  final BuildContext parentContext;
  const _GiftCardDialogContent({required this.theme, required this.parentContext});
  @override
  State<_GiftCardDialogContent> createState() => _GiftCardDialogContentState();
}

class _GiftCardDialogContentState extends State<_GiftCardDialogContent> {
  MihomTheme get t => widget.theme;
  final _ctrl = TextEditingController();
  bool _loading = false;
  bool _redeemed = false;
  String? _error;
  Map<String, dynamic>? _rewards;
  String? _templateName;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _redeem() async {
    final code = _ctrl.text.trim();
    if (code.isEmpty) {
      setState(() => _error = S.giftCardEmpty);
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      final http = XBoardSDK.instance.httpService;
      final resp = await http.postRequest('/api/v1/user/gift-card/redeem', {'code': code});
      final data = resp['data'];
      if (resp['status'] == 'error' || resp['data'] == null) {
        final msg = resp['message'] ?? (S.isEn ? 'Redemption failed' : '兑换失败');
        setState(() { _loading = false; _error = msg.toString(); });
        return;
      }
      setState(() {
        _loading = false;
        _redeemed = true;
        _rewards = data['rewards'] as Map<String, dynamic>?;
        _templateName = data['template_name']?.toString();
      });
    } catch (e) {
      final msg = e is XBoardException ? e.message : (S.isEn ? 'Redemption failed, please try again' : '兑换失败，请稍后重试');
      setState(() { _loading = false; _error = msg; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 360, padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: t.cardBg, borderRadius: BorderRadius.circular(18), border: t.cardBorder,
        boxShadow: [BoxShadow(color: t.primary.withValues(alpha: 0.15), blurRadius: 30)]),
      child: _redeemed ? _buildSuccess() : _buildInput(),
    );
  }

  Widget _buildInput() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.card_giftcard, color: const Color(0xFFE91E63), size: 32),
        const SizedBox(height: 10),
        Text(S.giftCardTitle, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: t.textPrimary)),
        const SizedBox(height: 14),
        Container(
          height: 42,
          decoration: BoxDecoration(
            color: t.isDark ? const Color(0xFF1E2140) : const Color(0xFFF5F7FA),
            borderRadius: BorderRadius.circular(10),
          ),
          child: TextField(
            controller: _ctrl,
            enabled: !_loading,
            autofillHints: const [],
            autocorrect: false,
            enableSuggestions: false,
            style: TextStyle(fontSize: 13, color: t.textPrimary),
            decoration: InputDecoration(
              hintText: S.giftCardHint, hintStyle: TextStyle(fontSize: 12, color: t.textHint),
              border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11), isDense: true,
            ),
            onSubmitted: (_) => _redeem(),
          ),
        ),
        if (_error != null) ...[
          const SizedBox(height: 8),
          Text(_error!, style: TextStyle(fontSize: 12, color: t.danger), textAlign: TextAlign.center),
        ],
        const SizedBox(height: 14),
        MouseRegion(
          cursor: _loading ? SystemMouseCursors.basic : SystemMouseCursors.click,
          child: GestureDetector(
            onTap: _loading ? null : _redeem,
            child: Container(
              width: double.infinity, height: 40,
              decoration: BoxDecoration(
                gradient: _loading ? null : t.buttonGradient,
                color: _loading ? t.textHint.withValues(alpha: 0.2) : null,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: _loading
                    ? SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: t.primary))
                    : Text(S.redeem, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccess() {
    // 构建奖励描述列表
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
                    child: Row(
                      children: [
                        Icon(Icons.star, size: 12, color: t.success),
                        const SizedBox(width: 6),
                        Text(line, style: TextStyle(fontSize: 12, color: t.textSecondary)),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 16),
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: double.infinity, height: 40,
              decoration: BoxDecoration(gradient: t.buttonGradient, borderRadius: BorderRadius.circular(10)),
              child: Center(child: Text(S.isEn ? 'OK' : '确定', style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600))),
            ),
          ),
        ),
      ],
    );
  }
}
