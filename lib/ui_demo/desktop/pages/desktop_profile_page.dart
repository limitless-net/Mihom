import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../mihom_theme.dart';
import '../../i18n.dart';
import '../../pill_toast.dart';

/// 桌面端个人中心页 — 完整功能页面
class DesktopProfilePage extends StatelessWidget {
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

  MihomTheme get t => theme;

  @override
  Widget build(BuildContext context) {
    if (isGuest) return _guestView(context);
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
              onTap: onLogin,
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
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
                                    child: Text(S.vipMember, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text('user@example.com', style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.7))),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(S.isEn ? 'Balance' : '\u8d26\u6237\u4f59\u989d', style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.7))),
                            const SizedBox(height: 2),
                            const Text('\u00a5 128.00', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
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
                              widthFactor: 0.425,
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
                                  S.isEn ? '42.5 GB used' : '已用 42.5 GB',
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
                                  S.isEn ? '57.5 GB left' : '剩余 57.5 GB',
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
                        Text(S.planStandard, style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.8))),
                        const SizedBox(width: 16),
                        Icon(Icons.access_time, size: 13, color: Colors.white.withValues(alpha: 0.7)),
                        const SizedBox(width: 4),
                        Text('2025-07-15 ${S.isEn ? "expires" : "\u5230\u671f"}', style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.8))),
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
                                Text(S.isEn ? 'Device 1/3' : '\u8bbe\u5907 1/3',
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
              // ── 功能网格 3×2 ──
              Row(
                children: [
                  Expanded(child: _gridTile(context, icon: Icons.card_giftcard, iconColor: const Color(0xFFE91E63),
                    title: S.giftCard, subtitle: S.giftCardDesc, onTap: () => _showGiftCardDialog(context))),
                  const SizedBox(width: 10),
                  Expanded(child: _gridTile(context, icon: Icons.telegram, iconColor: const Color(0xFF2196F3),
                    title: S.bindTg, subtitle: S.isEn ? 'Get latest offers' : '\u63a5\u6536\u7fa4\u7ec4\u901a\u77e5', onTap: () => _showBindTgDialog(context))),
                  const SizedBox(width: 10),
                  Expanded(child: _gridTile(context, icon: Icons.people_outline, iconColor: const Color(0xFF9C27B0),
                    title: S.inviteFriends, subtitle: S.isEn ? '5 invited \u00b7 \u00a549.50' : '\u5df2\u9080\u8bf75\u4eba \u00b7 \u00a549.50', onTap: () => _showInviteDialog(context))),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: _gridTile(context, icon: Icons.headset_mic_outlined, iconColor: const Color(0xFF00BCD4),
                    title: S.onlineSupport, subtitle: S.onlineSupportDesc, onTap: () => showPillToast(context, t, '${S.onlineSupport} · ${S.devInProgress}'))),
                  const SizedBox(width: 10),
                  Expanded(child: _gridTile(context, icon: Icons.help_outline, iconColor: const Color(0xFF607D8B),
                    title: S.helpCenter, subtitle: S.helpCenterDesc, onTap: () => _showHelpCenterDialog(context))),
                  const SizedBox(width: 10),
                  Expanded(child: _gridTile(context, icon: Icons.history, iconColor: const Color(0xFF795548),
                    title: S.usageHistory, subtitle: S.usageHistoryDesc, onTap: () => _showUsageHistoryDialog(context))),
                ],
              ),
              const Spacer(),
              // ── 底部：设置（左） + 退出登录（右） ──
              Row(
                children: [
                  _HoverButton(
                    onTap: onOpenSettings,
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
    final ctrl = TextEditingController();
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
            width: 340, padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: t.cardBg, borderRadius: BorderRadius.circular(18), border: t.cardBorder,
              boxShadow: [BoxShadow(color: t.primary.withValues(alpha: 0.15), blurRadius: 30)]),
            child: Column(
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
                    controller: ctrl,
                    style: TextStyle(fontSize: 13, color: t.textPrimary),
                    decoration: InputDecoration(
                      hintText: S.giftCardHint, hintStyle: TextStyle(fontSize: 12, color: t.textHint),
                      border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11), isDense: true,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                GestureDetector(
                  onTap: () {
                    if (ctrl.text.trim().isEmpty) {
                      showPillToast(context, t, S.giftCardEmpty);
                      return;
                    }
                    Navigator.of(ctx).pop();
                    showPillToast(context, t, S.redeemSuccess);
                  },
                  child: Container(
                    width: double.infinity, height: 40,
                    decoration: BoxDecoration(gradient: t.buttonGradient, borderRadius: BorderRadius.circular(10)),
                    child: Center(child: Text(S.isEn ? 'Redeem' : '\u5151\u6362', style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600))),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── TG绑定弹窗 ──
  void _showBindTgDialog(BuildContext context) {
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
            width: 340, padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: t.cardBg, borderRadius: BorderRadius.circular(18), border: t.cardBorder,
              boxShadow: [BoxShadow(color: t.primary.withValues(alpha: 0.15), blurRadius: 30)]),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.telegram, color: const Color(0xFF2196F3), size: 32),
                const SizedBox(height: 10),
                Text(S.bindTg, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: t.textPrimary)),
                const SizedBox(height: 6),
                Text(S.bindTgDesc, textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: t.textSecondary, height: 1.4)),
                const SizedBox(height: 14),
                GestureDetector(
                  onTap: () => Navigator.of(ctx).pop(),
                  child: Container(
                    width: double.infinity, height: 40,
                    decoration: BoxDecoration(gradient: t.buttonGradient, borderRadius: BorderRadius.circular(10)),
                    child: Center(child: Text(S.isEn ? 'Go to Bind' : '\u53bb\u7ed1\u5b9a', style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600))),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── 邀请好友弹窗 ──
  void _showInviteDialog(BuildContext context) {
    const inviteCode = 'MH8X92KF';
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
            width: 380, padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.85),
            decoration: BoxDecoration(color: t.cardBg, borderRadius: BorderRadius.circular(18), border: t.cardBorder,
              boxShadow: [BoxShadow(color: t.primary.withValues(alpha: 0.15), blurRadius: 30)]),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 顶部关闭 X
                Align(
                  alignment: Alignment.topRight,
                  child: GestureDetector(
                    onTap: () => Navigator.of(ctx).pop(),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(Icons.close, size: 20, color: t.textHint),
                    ),
                  ),
                ),
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
                            _inviteStat(S.isEn ? 'Invited' : '已邀请', '5'),
                            Container(width: 1, height: 24, color: t.textHint.withValues(alpha: 0.15), margin: const EdgeInsets.symmetric(horizontal: 16)),
                            _inviteStat(S.isEn ? 'Commission' : '累计佣金', '¥49.50'),
                            Container(width: 1, height: 24, color: t.textHint.withValues(alpha: 0.15), margin: const EdgeInsets.symmetric(horizontal: 16)),
                            _inviteStat(S.isEn ? 'Rate' : '返利比例', '10%'),
                          ],
                        ),
                        const SizedBox(height: 14),
                        // 提现 / 划转到余额
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => showPillToast(ctx, t, S.isEn ? 'Withdraw · ${S.devInProgress}' : '提现 · ${S.devInProgress}'),
                                child: Container(
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: t.isDark ? const Color(0xFF1E2140) : const Color(0xFFF5F7FA),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: t.primary.withValues(alpha: 0.2)),
                                  ),
                                  child: Center(child: Text(S.isEn ? 'Withdraw' : '提现', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: t.primary))),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => showPillToast(ctx, t, S.isEn ? 'Transferred to balance' : '已划转到余额'),
                                child: Container(
                                  height: 36,
                                  decoration: BoxDecoration(gradient: t.buttonGradient, borderRadius: BorderRadius.circular(8)),
                                  child: Center(child: Text(S.isEn ? 'To Balance' : '划转到余额', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white))),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // 二维码区域
                        Container(
                          width: 150, height: 150,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: t.textHint.withValues(alpha: 0.12)),
                          ),
                          child: CustomPaint(
                            painter: _QrPlaceholderPainter(color: t.primary),
                            child: Center(
                              child: Container(
                                width: 32, height: 32,
                                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6)),
                                child: Image.asset('lib/ui_demo/branding/icon_black.png', width: 20, height: 20,
                                  color: t.primary, colorBlendMode: BlendMode.srcIn),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        // 扫码 + 保存二维码
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(S.isEn ? 'Scan to register' : '扫码注册',
                              style: TextStyle(fontSize: 11, color: t.textHint)),
                            const SizedBox(width: 12),
                            GestureDetector(
                              onTap: () => showPillToast(ctx, t, S.isEn ? 'QR code saved' : '二维码已保存'),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.download_rounded, size: 14, color: t.primary),
                                  const SizedBox(width: 3),
                                  Text(S.isEn ? 'Save' : '保存', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: t.primary)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        // 邀请码
                        Text(S.myInviteCode, style: TextStyle(fontSize: 12, color: t.textSecondary)),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: t.isDark ? const Color(0xFF1E2140) : const Color(0xFFF5F7FA),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(inviteCode, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: t.primary, letterSpacing: 3)),
                              const SizedBox(width: 12),
                              GestureDetector(
                                onTap: () {
                                  Clipboard.setData(const ClipboardData(text: inviteCode));
                                  showPillToast(ctx, t, S.inviteCodeCopied);
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(gradient: t.buttonGradient, borderRadius: BorderRadius.circular(6)),
                                  child: Text(S.isEn ? 'Copy' : '复制', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                                ),
                              ),
                            ],
                          ),
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

  Widget _inviteStat(String label, String value) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: t.primary)),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 10, color: t.textHint)),
      ],
    );
  }

  // ── 使用记录弹窗 ──
  void _showUsageHistoryDialog(BuildContext context) {
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
      transitionDuration: const Duration(milliseconds: 200),
      transitionBuilder: (ctx, a1, a2, child) => Transform.scale(
        scale: Curves.easeOutBack.transform(a1.value),
        child: Opacity(opacity: a1.value, child: child),
      ),
      pageBuilder: (ctx, a1, a2) => Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
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
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () => Navigator.of(ctx).pop(),
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
                                Text(totalUsed.toStringAsFixed(1), style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                                const SizedBox(width: 4),
                                const Text('GB', style: TextStyle(color: Colors.white70, fontSize: 13)),
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
                              Text('${S.upload} ${usageData.fold<double>(0, (s, d) => s + d.upload).toStringAsFixed(1)} GB',
                                style: const TextStyle(color: Colors.white70, fontSize: 11)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.arrow_downward, color: Colors.white70, size: 13),
                              const SizedBox(width: 4),
                              Text('${S.download} ${usageData.fold<double>(0, (s, d) => s + d.download).toStringAsFixed(1)} GB',
                                style: const TextStyle(color: Colors.white70, fontSize: 11)),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                // ── Daily Usage List ──
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      children: usageData.asMap().entries.map((entry) {
                        final i = entry.key;
                        final d = entry.value;
                        final barRatio = maxUsage > 0 ? d.total / maxUsage : 0.0;
                        return Padding(
                          padding: EdgeInsets.only(bottom: i < usageData.length - 1 ? 8 : 0),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: t.isDark ? const Color(0xFF1C1F3A) : const Color(0xFFF7F8FC),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Text(d.date, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: t.textPrimary)),
                                    const Spacer(),
                                    Text('${d.total.toStringAsFixed(1)} GB', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: t.primary)),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(3),
                                  child: SizedBox(
                                    height: 6,
                                    child: Row(
                                      children: [
                                        Expanded(flex: (d.upload * 100).round(),
                                          child: Container(decoration: BoxDecoration(gradient: LinearGradient(colors: [t.primary, t.primary.withValues(alpha: 0.7)])))),
                                        Expanded(flex: (d.download * 100).round(),
                                          child: Container(color: t.secondary.withValues(alpha: 0.6))),
                                        Expanded(flex: ((maxUsage - d.total) * 100).round().clamp(0, 99999),
                                          child: Container(color: t.textHint.withValues(alpha: 0.1))),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Row(
                                  children: [
                                    Container(width: 7, height: 7, decoration: BoxDecoration(color: t.primary, borderRadius: BorderRadius.circular(2))),
                                    const SizedBox(width: 4),
                                    Text('${S.upload} ${d.upload.toStringAsFixed(1)} GB', style: TextStyle(fontSize: 10, color: t.textSecondary)),
                                    const SizedBox(width: 10),
                                    Container(width: 7, height: 7, decoration: BoxDecoration(color: t.secondary.withValues(alpha: 0.6), borderRadius: BorderRadius.circular(2))),
                                    const SizedBox(width: 4),
                                    Text('${S.download} ${d.download.toStringAsFixed(1)} GB', style: TextStyle(fontSize: 10, color: t.textSecondary)),
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
            onLogout();
          }, child: Text(S.confirm, style: TextStyle(color: t.danger))),
        ],
      ),
    );
  }

  // ── 帮助中心弹窗 ──
  void _showHelpCenterDialog(BuildContext context) {
    final faqItems = [
      _FaqItem(
        q: S.isEn ? 'How to connect?' : '如何连接？',
        a: S.isEn ? 'Select a node on the home page and tap the connect button.' : '在首页选择节点后，点击连接按钮即可。',
      ),
      _FaqItem(
        q: S.isEn ? 'What if the connection fails?' : '连接失败怎么办？',
        a: S.isEn ? 'Try switching nodes or syncing your subscription.' : '可尝试切换节点或刷新订阅。',
      ),
      _FaqItem(
        q: S.isEn ? 'How to change my plan?' : '如何更换套餐？',
        a: S.isEn ? 'Go to Plans page to view and purchase plans.' : '进入套餐页面查看并购买新套餐。',
      ),
      _FaqItem(
        q: S.isEn ? 'How does the invite reward work?' : '邀请奖励如何发放？',
        a: S.isEn ? 'Share your invite code; you earn commission when friends purchase.' : '分享邀请码，好友购买后自动获得佣金。',
      ),
      _FaqItem(
        q: S.isEn ? 'How to contact support?' : '如何联系客服？',
        a: S.isEn ? 'Tap Online Support in profile page.' : '在个人中心点击在线客服。',
      ),
    ];

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
            width: 420, padding: const EdgeInsets.all(24),
            constraints: const BoxConstraints(maxHeight: 520),
            decoration: BoxDecoration(color: t.cardBg, borderRadius: BorderRadius.circular(18), border: t.cardBorder,
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
                    itemBuilder: (ctx, i) {
                      return _FaqTileWidget(item: faqItems[i], theme: t);
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

class _UsageDay {
  final String date;
  final double total;
  final double upload;
  final double download;
  _UsageDay(this.date, this.total, this.upload, this.download);
}
