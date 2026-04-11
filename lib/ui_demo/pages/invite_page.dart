import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../mihom_theme.dart';
import '../pill_toast.dart';
import '../i18n.dart';

class DemoInvitePage extends StatelessWidget {
  final MihomTheme theme;
  const DemoInvitePage({super.key, required this.theme});

  MihomTheme get t => theme;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: t.scaffoldBg,
      body: Container(
        decoration: t.scaffoldGradient != null ? BoxDecoration(gradient: t.scaffoldGradient) : null,
        child: SafeArea(
          child: Column(
            children: [
              // AppBar
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 24, 0),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back_ios_new, color: t.textPrimary, size: 20),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    Text(S.inviteFriends, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: t.textPrimary)),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                  child: Column(
                    children: [
                      // 邀请奖励 Banner
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: t.primaryGradient,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [BoxShadow(color: t.primary.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 8))],
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.card_giftcard, color: Colors.white, size: 40),
                            ),
                            const SizedBox(height: 16),
                            Text(S.inviteTitle, style: const TextStyle(
                              color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold,
                            )),
                            const SizedBox(height: 8),
                            Text(S.inviteRewardDesc, style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8), fontSize: 14,
                            )),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // 邀请统计
                      Row(
                        children: [
                          Expanded(child: _statCard(S.invited, '12', S.people)),
                          const SizedBox(width: 12),
                          Expanded(child: _statCard(S.trafficEarned, '120', 'GB')),
                          const SizedBox(width: 12),
                          Expanded(child: _statCard(S.commission, '¥36', '')),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // 邀请码
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: t.cardBg,
                          borderRadius: BorderRadius.circular(t.cardRadius),
                          border: t.cardBorder, boxShadow: t.cardShadow,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(S.myInviteCode, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: t.textSecondary)),
                            const SizedBox(height: 12),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              decoration: BoxDecoration(
                                color: t.isDark ? const Color(0xFF1C1F3A) : const Color(0xFFF5F7FF),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: t.primary.withValues(alpha: 0.2)),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text('MIHOM-XK8F2D', style: TextStyle(
                                      fontSize: 20, fontWeight: FontWeight.bold, color: t.primary,
                                      letterSpacing: 2,
                                    )),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      HapticFeedback.lightImpact();
                                      Clipboard.setData(const ClipboardData(text: 'MIHOM-XK8F2D'));
                                      showPillToast(context, t, S.inviteCodeCopied);
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: t.primary.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(Icons.copy, color: t.primary, size: 18),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            // 分享按钮
                            SizedBox(
                              width: double.infinity, height: 48,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: t.primaryGradient,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    HapticFeedback.mediumImpact();
                                    showPillToast(context, t, S.inviteLinkCopied);
                                  },
                                  icon: const Icon(Icons.share, color: Colors.white, size: 18),
                                  label: Text(S.shareInviteLink, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent, shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // 邀请记录
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: t.cardBg,
                          borderRadius: BorderRadius.circular(t.cardRadius),
                          border: t.cardBorder, boxShadow: t.cardShadow,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(S.inviteRecords, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: t.textSecondary)),
                            const SizedBox(height: 14),
                            _recordItem('用户 ***8821', '3 天前', '+10 GB'),
                            Divider(height: 20, color: t.textHint.withValues(alpha: 0.12)),
                            _recordItem('用户 ***5523', '1 周前', '+10 GB'),
                            Divider(height: 20, color: t.textHint.withValues(alpha: 0.12)),
                            _recordItem('用户 ***1107', '2 周前', '+10 GB'),
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
    );
  }

  Widget _statCard(String label, String value, String unit) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: t.cardBg,
        borderRadius: BorderRadius.circular(t.cardRadius),
        border: t.cardBorder, boxShadow: t.cardShadow,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: t.primary)),
              if (unit.isNotEmpty) Text(' $unit', style: TextStyle(fontSize: 12, color: t.textHint)),
            ],
          ),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 12, color: t.textSecondary)),
        ],
      ),
    );
  }

  Widget _recordItem(String user, String time, String reward) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: t.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(Icons.person_add, color: t.primary, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(user, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: t.textPrimary)),
              Text(time, style: TextStyle(fontSize: 12, color: t.textHint)),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: t.success.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(reward, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: t.success)),
        ),
      ],
    );
  }
}
