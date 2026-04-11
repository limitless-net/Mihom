import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../mihom_theme.dart';
import '../login_dialog.dart';
import '../pill_toast.dart';
import '../i18n.dart';
import '../credential_store.dart';

class DemoPlansPage extends StatefulWidget {
  final MihomTheme theme;
  final bool isGuest;
  final VoidCallback? onLogin;
  const DemoPlansPage({super.key, required this.theme, this.isGuest = false, this.onLogin});

  @override
  State<DemoPlansPage> createState() => _DemoPlansPageState();
}

class _DemoPlansPageState extends State<DemoPlansPage> {
  MihomTheme get t => widget.theme;
  int _filterIndex = 0;
  List<String> get _filterLabels => [S.allPlans, S.recurring, S.oneTime];

  List<_Plan> get _plans => [
    _Plan(S.planLite, S.planLiteDesc, 9.9, '30 GB', Icons.flash_on, [
      S.feat30gb, S.featAllNodes, S.feat2Devices,
    ]),
    _Plan(S.planStandard, S.planStandardDesc, 19.9, '100 GB', Icons.diamond_outlined, [
      S.feat100gb, S.featAllNodes, S.feat3Devices, S.featPrioritySupport,
    ]),
    _Plan(S.planPro, S.planProDesc, 39.9, '200 GB', Icons.rocket_launch, [
      S.feat200gb, S.featAllNodesPremium, S.feat5Devices, S.featPrioritySupport,
    ]),
    _Plan(S.planUnlimited, S.planUnlimitedDesc, 69.9, S.unlimited, Icons.all_inclusive, [
      S.featUnlimitedTraffic, S.featAllNodesPremium, S.featUnlimitedDevices, S.featDedicatedSupport, S.featFreeUpgrade,
    ]),
    _Plan(S.planTrial, S.planTrialDesc, 3.9, '10 GB', Icons.timer_outlined, [
      S.feat10gb, S.featAllNodesBasic, S.feat1Device, S.feat3DayValid,
    ], type: _PlanType.oneTime),
    _Plan(S.planBooster, S.planBoosterDesc, 9.9, '50 GB', Icons.bolt, [
      S.feat50gbBoost, S.featNoExpiry, S.featAllNodesBasic,
    ], type: _PlanType.oneTime),
  ];

  List<_Plan> get _filteredPlans {
    if (_filterIndex == 0) return _plans;
    if (_filterIndex == 1) return _plans.where((p) => p.type == _PlanType.recurring).toList();
    return _plans.where((p) => p.type == _PlanType.oneTime).toList();
  }

  List<_Cycle> get _cycles => [
    _Cycle(S.monthlyPlan, 1, 1.0),
    _Cycle(S.quarterlyPlan, 3, 0.9),
    _Cycle(S.semiAnnualPlan, 6, 0.85),
    _Cycle(S.annualPlan, 12, 0.75),
  ];

  List<_Payment> get _payments => [
    _Payment(S.alipay, Icons.account_balance_wallet, const Color(0xFF1677FF)),
    _Payment(S.wechatPay, Icons.chat_bubble, const Color(0xFF07C160)),
    _Payment(S.balancePay, Icons.savings, const Color(0xFFFF9500)),
  ];

  void _showPurchaseDialog(BuildContext context, _Plan plan) {
    if (widget.isGuest) {
      HapticFeedback.mediumImpact();
      showLoginDialog(context, t, hint: S.loginToBuy,
        initialEmail: SavedCredentials.email,
        initialPassword: SavedCredentials.password,
      ).then((result) {
        if (result != null) {
          SavedCredentials.email = result['email'] ?? '';
          SavedCredentials.password = result['password'] ?? '';
          widget.onLogin?.call();
        }
      });
      return;
    }
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
        child: _PurchaseDialog(theme: t, plan: plan, cycles: _cycles, payments: _payments),
      ),
    );
  }

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
                    Text(S.selectPlan, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: t.textPrimary)),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 余额横幅
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: t.primaryGradient,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.account_balance_wallet, color: Colors.white, size: 20),
                      const SizedBox(width: 10),
                      Flexible(child: Text(S.accountBalance, style: const TextStyle(color: Colors.white70, fontSize: 13), overflow: TextOverflow.ellipsis)),
                      const SizedBox(width: 6),
                      const Text('¥ 128.00', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(S.recharge, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // ── 筛选标签 ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: List.generate(_filterLabels.length, (i) {
                    final active = _filterIndex == i;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          setState(() => _filterIndex = i);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                          decoration: BoxDecoration(
                            gradient: active ? t.buttonGradient : null,
                            color: active ? null : t.isDark ? const Color(0xFF1E2140) : const Color(0xFFF0F2F5),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            _filterLabels[i],
                            style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w600,
                              color: active ? Colors.white : t.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 12),

              // 套餐卡片列表
              Expanded(
                child: RefreshIndicator(
                  color: t.primary,
                  onRefresh: () async {
                    await Future.delayed(const Duration(milliseconds: 1200));
                    if (mounted) showPillToast(context, t, S.plansUpdated);
                  },
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                  itemCount: _filteredPlans.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (ctx, i) {
                    final plan = _filteredPlans[i];
                    final isPopular = plan.name == S.planStandard;
                    return GestureDetector(
                      onTap: () => _showPurchaseDialog(context, plan),
                      child: Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: t.cardBg,
                          borderRadius: BorderRadius.circular(18),
                          border: isPopular
                              ? Border.all(color: t.primary.withValues(alpha: 0.4), width: 1.5)
                              : t.cardBorder,
                          boxShadow: [
                            BoxShadow(
                              color: (isPopular ? t.primary : Colors.black).withValues(alpha: isPopular ? 0.1 : 0.04),
                              blurRadius: 12, offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // 图标
                            Container(
                              width: 48, height: 48,
                              decoration: BoxDecoration(
                                color: t.primary.withValues(alpha: t.isDark ? 0.15 : 0.08),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(plan.icon, color: t.primary, size: 24),
                            ),
                            const SizedBox(width: 14),
                            // 名称 + 描述
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Flexible(child: Text(plan.name, style: TextStyle(
                                        fontSize: 16, fontWeight: FontWeight.w600, color: t.textPrimary,
                                      ), overflow: TextOverflow.ellipsis)),
                                      if (isPopular) ...[
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                          decoration: BoxDecoration(
                                            color: t.warning.withValues(alpha: 0.15),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(S.recommended, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: t.warning)),
                                        ),
                                      ],
                                      if (plan.type == _PlanType.oneTime) ...[
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                          decoration: BoxDecoration(
                                            color: t.primary.withValues(alpha: 0.12),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(S.oneTimeLabel, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: t.primary)),
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text('${plan.traffic}${plan.type == _PlanType.recurring ? S.perMonth : ''} · ${plan.subtitle}',
                                    style: TextStyle(fontSize: 12, color: t.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                            // 价格 + 箭头
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.baseline,
                                  textBaseline: TextBaseline.alphabetic,
                                  children: [
                                    Text('¥', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: t.primary)),
                                    Text('${plan.basePrice}', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: t.primary)),
                                  ],
                                ),
                                Text(plan.type == _PlanType.oneTime ? S.oneTimeLabel : S.fromPerMonth, style: TextStyle(fontSize: 11, color: t.textHint)),
                              ],
                            ),
                            const SizedBox(width: 4),
                            Icon(Icons.chevron_right, color: t.textHint.withValues(alpha: 0.5), size: 20),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════
//  居中购买弹窗（订单 → 支付选择 → 等待 → 成功）
// ══════════════════════════════════════════════════

class _PurchaseDialog extends StatefulWidget {
  final MihomTheme theme;
  final _Plan plan;
  final List<_Cycle> cycles;
  final List<_Payment> payments;
  const _PurchaseDialog({required this.theme, required this.plan, required this.cycles, required this.payments});

  @override
  State<_PurchaseDialog> createState() => _PurchaseDialogState();
}

enum _Step { order, paying, success }

class _PurchaseDialogState extends State<_PurchaseDialog> with SingleTickerProviderStateMixin {
  MihomTheme get t => widget.theme;
  _Step _step = _Step.order;
  int _selectedCycle = -1;
  int _selectedPayment = -1;
  final _couponCtrl = TextEditingController();
  bool _couponVerified = false;
  bool _couponExpanded = false; // 优惠码默认折叠
  bool _priceDetailExpanded = false; // 价格明细默认折叠
  late AnimationController _loadCtrl;

  double get _totalPrice {
    if (_selectedCycle < 0) return 0;
    final c = widget.cycles[_selectedCycle];
    var price = widget.plan.basePrice * c.months * c.discount;
    if (_couponVerified) price *= 0.9;
    return double.parse(price.toStringAsFixed(1));
  }

  bool get _canOrder {
    if (_selectedCycle < 0) return false;
    if (_couponCtrl.text.trim().isNotEmpty && !_couponVerified) return false;
    return true;
  }

  @override
  void initState() {
    super.initState();
    _loadCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat();
    _couponCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _loadCtrl.dispose();
    _couponCtrl.dispose();
    super.dispose();
  }

  // ── 居中弹窗：选择周期 ──
  void _showCyclePicker() {
    HapticFeedback.lightImpact();
    showGeneralDialog<int>(
      context: context,
      barrierDismissible: true,
      barrierLabel: '关闭',
      barrierColor: Colors.black45,
      transitionDuration: const Duration(milliseconds: 220),
      transitionBuilder: (ctx, a1, a2, child) => Transform.scale(
        scale: Curves.easeOutBack.transform(a1.value),
        child: Opacity(opacity: a1.value, child: child),
      ),
      pageBuilder: (ctx, a1, a2) => Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: MediaQuery.of(ctx).size.width * 0.82,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: t.cardBg,
              borderRadius: BorderRadius.circular(22),
              border: t.cardBorder,
              boxShadow: [BoxShadow(color: t.primary.withValues(alpha: 0.15), blurRadius: 30)],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(S.selectBillingCycle, style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: t.textPrimary)),
                const SizedBox(height: 16),
                ...List.generate(widget.cycles.length, (i) {
                  final c = widget.cycles[i];
                  final price = double.parse((widget.plan.basePrice * c.months * c.discount).toStringAsFixed(1));
                  final monthly = c.months > 1 ? double.parse((price / c.months).toStringAsFixed(1)) : null;
                  final selected = _selectedCycle == i;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: GestureDetector(
                      onTap: () { HapticFeedback.lightImpact(); Navigator.of(ctx).pop(i); },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                        decoration: BoxDecoration(
                          color: selected
                              ? t.primary.withValues(alpha: t.isDark ? 0.15 : 0.06)
                              : t.isDark ? const Color(0xFF1E2140) : const Color(0xFFF5F7FA),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: selected ? t.primary.withValues(alpha: 0.5) : Colors.transparent, width: 1.5),
                        ),
                        child: Row(
                          children: [
                            // radio 圈
                            Container(
                              width: 20, height: 20,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: selected ? t.primary : Colors.transparent,
                                border: Border.all(color: selected ? t.primary : t.textHint.withValues(alpha: 0.4), width: 2),
                              ),
                              child: selected ? const Icon(Icons.check, size: 13, color: Colors.white) : null,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(children: [
                                    Flexible(child: Text(c.name, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: selected ? t.primary : t.textPrimary), overflow: TextOverflow.ellipsis)),
                                    if (c.discount < 1.0) ...[
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                        decoration: BoxDecoration(color: t.danger.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(3)),
                                        child: Text(S.isEn ? '${((1 - c.discount) * 100).round()}${S.discountLabel}' : '${(c.discount * 10).toStringAsFixed(1)}${S.discountLabel}', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: t.danger)),
                                      ),
                                    ],
                                  ]),
                                  if (monthly != null) Text('${S.equivalentMonthly} ¥$monthly${S.perMonth}', style: TextStyle(fontSize: 11, color: t.textHint)),
                                ],
                              ),
                            ),
                            Text('¥$price', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: selected ? t.primary : t.textPrimary)),
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
    ).then((v) {
      if (v != null) setState(() => _selectedCycle = v);
    });
  }

  // ── 居中弹窗：支付确认（折叠选择器 + 嵌套弹窗选择支付方式）──
  void _showPaymentDialog() {
    HapticFeedback.mediumImpact();
    int tempSelected = _selectedPayment;
    showGeneralDialog<int>(
      context: context,
      barrierDismissible: true,
      barrierLabel: '关闭',
      barrierColor: Colors.black45,
      transitionDuration: const Duration(milliseconds: 220),
      transitionBuilder: (ctx, a1, a2, child) => Transform.scale(
        scale: Curves.easeOutBack.transform(a1.value),
        child: Opacity(opacity: a1.value, child: child),
      ),
      pageBuilder: (ctx, a1, a2) => Center(
        child: Material(
          color: Colors.transparent,
          child: StatefulBuilder(
            builder: (ctx2, setDialogState) {
              final hasPayment = tempSelected >= 0;
              return Container(
                width: MediaQuery.of(ctx2).size.width * 0.82,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: t.cardBg,
                  borderRadius: BorderRadius.circular(22),
                  border: t.cardBorder,
                  boxShadow: [BoxShadow(color: t.primary.withValues(alpha: 0.15), blurRadius: 30)],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 标题 + 金额
                    Row(
                      children: [
                        Text(S.isEn ? 'Confirm Payment' : '确认支付', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: t.textPrimary)),
                        const Spacer(),
                        Text('¥$_totalPrice', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: t.primary)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // 支付方式选择器行（折叠，点击弹出嵌套弹窗）
                    Text(S.selectPaymentMethod, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: t.textSecondary)),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        // 嵌套弹窗：选择支付方式
                        showGeneralDialog<int>(
                          context: ctx2,
                          barrierDismissible: true,
                          barrierLabel: '关闭',
                          barrierColor: Colors.black45,
                          transitionDuration: const Duration(milliseconds: 220),
                          transitionBuilder: (c3, a3, _, child) => Transform.scale(
                            scale: Curves.easeOutBack.transform(a3.value),
                            child: Opacity(opacity: a3.value, child: child),
                          ),
                          pageBuilder: (c3, a3, _) => Center(
                            child: Material(
                              color: Colors.transparent,
                              child: Container(
                                width: MediaQuery.of(c3).size.width * 0.82,
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: t.cardBg,
                                  borderRadius: BorderRadius.circular(22),
                                  border: t.cardBorder,
                                  boxShadow: [BoxShadow(color: t.primary.withValues(alpha: 0.15), blurRadius: 30)],
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(S.selectPaymentMethod, style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: t.textPrimary)),
                                    const SizedBox(height: 16),
                                    ...List.generate(widget.payments.length, (i) {
                                      final p = widget.payments[i];
                                      final selected = tempSelected == i;
                                      return Padding(
                                        padding: const EdgeInsets.only(bottom: 8),
                                        child: GestureDetector(
                                          onTap: () { HapticFeedback.lightImpact(); Navigator.of(c3).pop(i); },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                                            decoration: BoxDecoration(
                                              color: selected
                                                  ? t.primary.withValues(alpha: t.isDark ? 0.15 : 0.06)
                                                  : t.isDark ? const Color(0xFF1E2140) : const Color(0xFFF5F7FA),
                                              borderRadius: BorderRadius.circular(14),
                                              border: Border.all(color: selected ? t.primary.withValues(alpha: 0.5) : Colors.transparent, width: 1.5),
                                            ),
                                            child: Row(
                                              children: [
                                                Container(
                                                  width: 20, height: 20,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: selected ? t.primary : Colors.transparent,
                                                    border: Border.all(color: selected ? t.primary : t.textHint.withValues(alpha: 0.4), width: 2),
                                                  ),
                                                  child: selected ? const Icon(Icons.check, size: 13, color: Colors.white) : null,
                                                ),
                                                const SizedBox(width: 12),
                                                Container(
                                                  width: 30, height: 30,
                                                  decoration: BoxDecoration(color: p.color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                                                  child: Icon(p.icon, color: p.color, size: 16),
                                                ),
                                                const SizedBox(width: 10),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(p.name, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: selected ? t.primary : t.textPrimary)),
                                                      if (i == 2) Text('${S.balance} ¥128.00', style: TextStyle(fontSize: 11, color: t.textHint)),
                                                    ],
                                                  ),
                                                ),
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
                        ).then((v) {
                          if (v != null) setDialogState(() => tempSelected = v);
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                        decoration: BoxDecoration(
                          color: t.isDark ? const Color(0xFF1E2140) : const Color(0xFFF5F7FA),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: hasPayment ? t.primary.withValues(alpha: 0.3) : Colors.transparent, width: 1),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              hasPayment ? widget.payments[tempSelected].icon : Icons.payment,
                              size: 16,
                              color: hasPayment ? widget.payments[tempSelected].color : t.textHint,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: hasPayment
                                  ? Text(widget.payments[tempSelected].name, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: t.textPrimary))
                                  : Text(S.pleaseSelectPayment, style: TextStyle(fontSize: 14, color: t.textHint)),
                            ),
                            const SizedBox(width: 4),
                            Icon(Icons.chevron_right, size: 18, color: t.textHint),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // 确认支付按钮
                    GestureDetector(
                      onTap: hasPayment ? () {
                        HapticFeedback.mediumImpact();
                        Navigator.of(ctx2).pop(tempSelected);
                      } : null,
                      child: Container(
                        width: double.infinity, height: 48,
                        decoration: BoxDecoration(
                          gradient: hasPayment ? t.buttonGradient : null,
                          color: hasPayment ? null : t.textHint.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: hasPayment
                              ? [BoxShadow(color: t.primary.withValues(alpha: 0.25), blurRadius: 14, offset: const Offset(0, 4))]
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            hasPayment ? '${S.confirmPaymentWithPrice}  ¥$_totalPrice' : S.pleaseSelectPayment,
                            style: TextStyle(
                              color: hasPayment ? Colors.white : t.textHint,
                              fontSize: 15, fontWeight: FontWeight.w600,
                            ),
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
    ).then((v) {
      if (v != null && v >= 0) {
        setState(() {
          _selectedPayment = v;
          _step = _Step.paying;
        });
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            HapticFeedback.heavyImpact();
            setState(() => _step = _Step.success);
          }
        });
      }
    });
  }

  void _verifyCoupon() {
    HapticFeedback.mediumImpact();
    final code = _couponCtrl.text.trim();
    if (code.isEmpty) return;
    setState(() => _couponVerified = true);
  }

  void _done() {
    Navigator.of(context).pop(true);
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width * 0.88;
    return Material(
      color: Colors.transparent,
      child: Container(
        width: w,
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.82),
        decoration: BoxDecoration(
          color: t.cardBg,
          borderRadius: BorderRadius.circular(24),
          border: t.cardBorder,
          boxShadow: [BoxShadow(color: t.primary.withValues(alpha: 0.15), blurRadius: 30)],
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          switchInCurve: Curves.easeOut,
          child: _step == _Step.order
              ? _buildOrderForm()
              : _step == _Step.paying
                  ? _buildPayingStep()
                  : _buildSuccessStep(),
        ),
      ),
    );
  }

  // ── 订单表单（不含支付方式） ──
  Widget _buildOrderForm() {
    final hasCycle = _selectedCycle >= 0;
    final couponText = _couponCtrl.text.trim();
    final couponBlocking = couponText.isNotEmpty && !_couponVerified;

    return SingleChildScrollView(
      key: const ValueKey('order'),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── 标题 + 关闭
          Row(
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: t.primary.withValues(alpha: t.isDark ? 0.15 : 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(widget.plan.icon, color: t.primary, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.plan.name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: t.textPrimary)),
                    Text('${widget.plan.traffic}${S.perMonth} · ${widget.plan.subtitle}', style: TextStyle(fontSize: 12, color: t.textSecondary)),
                  ],
                ),
              ),
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

          // ── 产品介绍
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: t.isDark ? const Color(0xFF1E2140) : const Color(0xFFF5F7FA),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(S.planBenefits, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: t.textSecondary)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6, runSpacing: 6,
                  children: widget.plan.features.map((f) => Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle, size: 13, color: t.success),
                      const SizedBox(width: 4),
                      Text(f, style: TextStyle(fontSize: 12, color: t.textPrimary)),
                    ],
                  )).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── 选择周期（点击弹居中弹窗）
          Text(S.selectBillingCycle, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: t.textSecondary)),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: _showCyclePicker,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              decoration: BoxDecoration(
                color: t.isDark ? const Color(0xFF1E2140) : const Color(0xFFF5F7FA),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: hasCycle ? t.primary.withValues(alpha: 0.3) : Colors.transparent, width: 1),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: hasCycle ? t.primary : t.textHint),
                  const SizedBox(width: 10),
                  Expanded(
                    child: hasCycle
                        ? Row(children: [
                            Text(widget.cycles[_selectedCycle].name, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: t.textPrimary)),
                            if (widget.cycles[_selectedCycle].discount < 1.0) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                decoration: BoxDecoration(color: t.danger.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(3)),
                                child: Text(
                                  S.isEn
                                    ? '${((1 - widget.cycles[_selectedCycle].discount) * 100).round()}${S.discountLabel}'
                                    : '${(widget.cycles[_selectedCycle].discount * 10).toStringAsFixed(1)}${S.discountLabel}',
                                  style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: t.danger)),
                              ),
                            ],
                          ])
                        : Text(S.pleaseSelectCycle, style: TextStyle(fontSize: 14, color: t.textHint)),
                  ),
                  if (hasCycle) Text('¥$_totalPrice', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: t.primary)),
                  const SizedBox(width: 4),
                  Icon(Icons.chevron_right, size: 18, color: t.textHint),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          // ── 优惠码（折叠式）
          if (!_couponExpanded && !_couponVerified)
            GestureDetector(
              onTap: () => setState(() => _couponExpanded = true),
              child: Row(
                children: [
                  Icon(Icons.local_offer_outlined, size: 14, color: t.primary),
                  const SizedBox(width: 6),
                  Text(S.haveCoupon, style: TextStyle(fontSize: 13, color: t.primary, fontWeight: FontWeight.w500)),
                  const SizedBox(width: 4),
                  Text(S.tapToInput, style: TextStyle(fontSize: 12, color: t.textHint)),
                ],
              ),
            ),
          if (_couponExpanded || _couponVerified) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 42,
                    decoration: BoxDecoration(
                      color: t.isDark ? const Color(0xFF1E2140) : const Color(0xFFF5F7FA),
                      borderRadius: BorderRadius.circular(12),
                      border: _couponVerified
                          ? Border.all(color: t.success.withValues(alpha: 0.4))
                          : couponBlocking ? Border.all(color: t.warning.withValues(alpha: 0.5)) : null,
                    ),
                    child: TextField(
                      controller: _couponCtrl,
                      enabled: !_couponVerified,
                      style: TextStyle(fontSize: 14, color: t.textPrimary),
                      decoration: InputDecoration(
                        hintText: S.enterCouponCode,
                        hintStyle: TextStyle(fontSize: 13, color: t.textHint),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                        isDense: true,
                        suffixIcon: _couponVerified
                            ? Padding(padding: const EdgeInsets.only(right: 8), child: Icon(Icons.check_circle, color: t.success, size: 18))
                            : null,
                        suffixIconConstraints: const BoxConstraints(minWidth: 30, minHeight: 30),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: (couponText.isNotEmpty && !_couponVerified) ? _verifyCoupon : null,
                  child: Container(
                    height: 42,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      gradient: (couponText.isNotEmpty && !_couponVerified) ? t.buttonGradient : null,
                      color: (couponText.isNotEmpty && !_couponVerified) ? null : t.textHint.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        _couponVerified ? S.verifiedLabel : S.verifyLabel,
                        style: TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600,
                          color: _couponVerified ? t.success : (couponText.isNotEmpty ? Colors.white : t.textHint),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (couponBlocking) Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(S.verifyCouponFirst, style: TextStyle(fontSize: 11, color: t.warning)),
            ),
            if (_couponVerified) Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(S.coupon10Off, style: TextStyle(fontSize: 11, color: t.success, fontWeight: FontWeight.w500)),
            ),
          ],
          const SizedBox(height: 18),

          // ── 价格明细
          if (hasCycle) ...[
            () {
              final c = widget.cycles[_selectedCycle];
              final originalPrice = double.parse((widget.plan.basePrice * c.months).toStringAsFixed(1));
              final discountedPrice = double.parse((widget.plan.basePrice * c.months * c.discount).toStringAsFixed(1));
              final cycleDiscount = double.parse((originalPrice - discountedPrice).toStringAsFixed(1));
              final couponDiscount = _couponVerified ? double.parse((discountedPrice * 0.1).toStringAsFixed(1)) : 0.0;
              final hasDiscount = c.discount < 1.0 || _couponVerified || couponText.isNotEmpty;
              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: t.isDark ? const Color(0xFF1E2140) : const Color(0xFFF5F7FA),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    // ── 应付金额（始终可见，点击展开明细）
                    GestureDetector(
                      onTap: hasDiscount ? () => setState(() => _priceDetailExpanded = !_priceDetailExpanded) : null,
                      behavior: HitTestBehavior.opaque,
                      child: Row(
                        children: [
                          Text(S.amountDue, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: t.textPrimary)),
                          if (hasDiscount) ...[
                            const SizedBox(width: 4),
                            AnimatedRotation(
                              turns: _priceDetailExpanded ? 0.5 : 0,
                              duration: const Duration(milliseconds: 200),
                              child: Icon(Icons.expand_more, size: 18, color: t.textHint),
                            ),
                          ],
                          const Spacer(),
                          if (hasDiscount && originalPrice != _totalPrice)
                            Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: Text('¥$originalPrice', style: TextStyle(
                                fontSize: 12, color: t.textHint,
                                decoration: TextDecoration.lineThrough,
                                decorationColor: t.textHint,
                              )),
                            ),
                          Text('¥', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: t.primary)),
                          Text('$_totalPrice', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: t.primary)),
                        ],
                      ),
                    ),
                    // ── 价格明细（折叠区域）
                    AnimatedCrossFade(
                      firstChild: const SizedBox.shrink(),
                      secondChild: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Divider(height: 1, color: t.textHint.withValues(alpha: 0.15)),
                          ),
                          if (hasDiscount)
                            _priceRow(S.originalPriceLabel, '¥$originalPrice', t.textSecondary, t.textPrimary),
                          if (c.discount < 1.0)
                            _priceRow(
                              S.isEn
                                ? '${c.name} (${((1 - c.discount) * 100).round()}% off)'
                                : '${c.name}优惠 (${(c.discount * 10).toStringAsFixed(1)}折)',
                              '-¥$cycleDiscount', t.textSecondary, t.danger),
                          if (_couponVerified)
                            _priceRow('${S.couponLabel} (${S.isEn ? "10% off" : "9折"})', '-¥$couponDiscount', t.textSecondary, t.danger),
                          if (couponText.isNotEmpty && !_couponVerified)
                            _priceRow(S.couponLabel, S.pendingVerify, t.textSecondary, t.warning),
                        ],
                      ),
                      crossFadeState: _priceDetailExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                      duration: const Duration(milliseconds: 200),
                    ),
                  ],
                ),
              );
            }(),
            const SizedBox(height: 14),
          ],

          // ── 立即购买 → 未选周期自动弹出周期选择，优惠码未核销提醒，已选则弹支付方式
          _actionButton(
            S.buyNow,
            () {
              if (_selectedCycle < 0) {
                _showCyclePicker();
                return;
              }
              final coupon = _couponCtrl.text.trim();
              if (coupon.isNotEmpty && !_couponVerified) {
                showPillToast(context, t, S.verifyCouponFirst);
                return;
              }
              _showPaymentDialog();
            },
          ),
        ],
      ),
    );
  }

  // ── 支付中 ──
  Widget _buildPayingStep() {
    return Padding(
      key: const ValueKey('paying'),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 52, height: 52,
            child: RotationTransition(
              turns: _loadCtrl,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: t.primary.withValues(alpha: 0.2), width: 3),
                ),
                child: Container(
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: SweepGradient(colors: [t.primary.withValues(alpha: 0), t.primary]),
                  ),
                  width: 44, height: 44,
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(S.waitingPayment, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: t.textPrimary)),
          const SizedBox(height: 6),
          Text('${S.isEn ? 'Complete payment in ' : '请在'}${widget.payments[_selectedPayment].name}${S.isEn ? '' : '中完成支付'}',
            style: TextStyle(fontSize: 13, color: t.textSecondary)),
          const SizedBox(height: 8),
          Text('¥$_totalPrice', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: t.primary)),
        ],
      ),
    );
  }

  // ── 购买成功 ──
  Widget _buildSuccessStep() {
    return SingleChildScrollView(
      key: const ValueKey('success'),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64, height: 64,
            decoration: BoxDecoration(shape: BoxShape.circle, color: t.success.withValues(alpha: 0.12)),
            child: Icon(Icons.check_circle, color: t.success, size: 42),
          ),
          const SizedBox(height: 14),
          Text(S.purchaseSuccess, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: t.textPrimary)),
          const SizedBox(height: 6),
          Text('${widget.plan.name} · ${widget.cycles[_selectedCycle].name}', style: TextStyle(fontSize: 13, color: t.textSecondary)),
          const SizedBox(height: 2),
          Text('${S.paid} ¥$_totalPrice', style: TextStyle(fontSize: 12, color: t.textHint)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: t.isDark ? const Color(0xFF1E2140) : const Color(0xFFF5F7FA),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _summaryRow(S.planLabel, widget.plan.name),
                _summaryRow(S.cycleLabel, widget.cycles[_selectedCycle].name),
                _summaryRow(S.trafficLabel, '${widget.plan.traffic}${S.perMonth}'),
                _summaryRow(S.paymentMethod, widget.payments[_selectedPayment].name),
                if (_couponVerified) _summaryRow(S.couponLabel, S.coupon10Off),
                _summaryRow(S.expiryTime, '2027-04-04'),
              ],
            ),
          ),
          const SizedBox(height: 18),
          _actionButton(S.okStartConnect, _done),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: t.textSecondary)),
          Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: t.textPrimary)),
        ],
      ),
    );
  }

  Widget _priceRow(String label, String value, Color labelColor, Color valueColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 13, color: labelColor)),
          Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: valueColor)),
        ],
      ),
    );
  }

  Widget _actionButton(String label, VoidCallback? onTap) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity, height: 48,
        decoration: BoxDecoration(
          gradient: enabled ? t.buttonGradient : null,
          color: enabled ? null : t.textHint.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(14),
          boxShadow: enabled
              ? [BoxShadow(color: t.primary.withValues(alpha: 0.25), blurRadius: 14, offset: const Offset(0, 4))]
              : null,
        ),
        child: Center(
          child: Text(label, style: TextStyle(
            color: enabled ? Colors.white : t.textHint,
            fontSize: 15, fontWeight: FontWeight.w600,
          )),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════
//  独立居中弹窗：选择支付方式 + 确认支付
// ══════════════════════════════════════════════════



// ── 数据模型 ──
enum _PlanType { recurring, oneTime }

class _Plan {
  final String name;
  final String subtitle;
  final double basePrice;
  final String traffic;
  final IconData icon;
  final List<String> features;
  final _PlanType type;
  _Plan(this.name, this.subtitle, this.basePrice, this.traffic, this.icon, this.features, {this.type = _PlanType.recurring});
}

class _Cycle {
  final String name;
  final int months;
  final double discount;
  _Cycle(this.name, this.months, this.discount);
}

class _Payment {
  final String name;
  final IconData icon;
  final Color color;
  _Payment(this.name, this.icon, this.color);
}
