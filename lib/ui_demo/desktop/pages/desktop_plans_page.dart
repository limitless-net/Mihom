import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import '../../mihom_theme.dart';
import '../../i18n.dart';
import '../../login_dialog.dart';
import '../../credential_store.dart';
import '../../pill_toast.dart';

/// 桌面端套餐页 — 宽卡片 grid + 购买弹窗
class DesktopPlansPage extends StatefulWidget {
  final MihomTheme theme;
  final bool isGuest;
  final VoidCallback? onLogin;
  final VoidCallback? onPlanPurchased;
  final VoidCallback? onGoHome;
  const DesktopPlansPage({super.key, required this.theme, this.isGuest = false, this.onLogin, this.onPlanPurchased, this.onGoHome});

  @override
  State<DesktopPlansPage> createState() => _DesktopPlansPageState();
}

class _DesktopPlansPageState extends State<DesktopPlansPage> {
  MihomTheme get t => widget.theme;
  int _filterIndex = 0;
  List<String> get _filterLabels => [S.allPlans, S.recurring, S.oneTime];

  List<_Plan> get _plans => [
    _Plan(S.planLite, S.planLiteDesc, 9.9, '30 GB', Icons.flash_on, [
      S.feat30gb, S.featAllNodes, S.feat2Devices,
    ], description: '<p>✅ 30 GB 流量/月</p><p>✅ 全部节点可用</p><p>✅ <b>2</b> 台设备同时在线</p><p style="color:#888;font-size:11px">适合轻度用户，日常浏览与社交媒体</p>'),
    _Plan(S.planStandard, S.planStandardDesc, 19.9, '100 GB', Icons.diamond_outlined, [
      S.feat100gb, S.featAllNodes, S.feat3Devices, S.featPrioritySupport,
    ], description: '<p>✅ 100 GB 流量/月</p><p>✅ 全部节点可用</p><p>✅ <b>3</b> 台设备同时在线</p><p>✅ 优先客服支持</p><p style="color:#ff9500;font-size:11px">⭐ <b>最受欢迎</b> — 性价比之选</p>'),
    _Plan(S.planPro, S.planProDesc, 39.9, '200 GB', Icons.rocket_launch, [
      S.feat200gb, S.featAllNodesPremium, S.feat5Devices, S.featPrioritySupport,
    ], description: '<p>✅ 200 GB 流量/月</p><p>✅ 全部节点 + <b>专线节点</b></p><p>✅ <b>5</b> 台设备同时在线</p><p>✅ 优先客服支持</p><p style="color:#888;font-size:11px">适合重度用户与小团队</p>'),
    _Plan(S.planUnlimited, S.planUnlimitedDesc, 69.9, S.unlimited, Icons.all_inclusive, [
      S.featUnlimitedTraffic, S.featAllNodesPremium, S.featUnlimitedDevices, S.featDedicatedSupport, S.featFreeUpgrade,
    ], description: '<p>✅ <b>无限</b>流量</p><p>✅ 全部节点 + 专线节点</p><p>✅ <b>无限</b>设备同时在线</p><p>✅ 专属客服 + 免费升级</p><p style="color:#888;font-size:11px">终极方案，无限制体验</p>'),
    _Plan(S.planTrial, S.planTrialDesc, 3.9, '10 GB', Icons.timer_outlined, [
      S.feat10gb, S.featAllNodesBasic, S.feat1Device, S.feat3DayValid,
    ], type: _PlanType.oneTime, description: '<p>✅ 10 GB 流量</p><p>✅ 基础节点可用</p><p>✅ 1 台设备</p><p>⏰ <b>3 天</b>有效期</p><p style="color:#888;font-size:11px">先试后买，体验服务质量</p>'),
    _Plan(S.planBooster, S.planBoosterDesc, 9.9, '50 GB', Icons.bolt, [
      S.feat50gbBoost, S.featNoExpiry, S.featAllNodesBasic,
    ], type: _PlanType.oneTime, description: '<p>✅ 50 GB 流量加油包</p><p>✅ <b>永不过期</b></p><p>✅ 基础节点可用</p><p style="color:#888;font-size:11px">流量不够时随时补充</p>'),
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

  void _showPurchaseDialog(BuildContext context, _Plan plan) async {
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
    await showGeneralDialog<bool>(
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
        child: _PurchaseDialog(
          theme: t, plan: plan, cycles: _cycles, payments: _payments,
          onPlanPurchased: widget.onPlanPurchased,
          onGoHome: () {
            Navigator.of(ctx).pop();
            widget.onGoHome?.call();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 28, right: 28, bottom: 28),
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
        child: LayoutBuilder(builder: (ctx2, constraints) {
          final w = constraints.maxWidth;
          final cols = w > 860 ? 3 : (w > 520 ? 2 : 1);
          final ratio = cols == 1 ? 2.4 : (cols == 2 ? 1.15 : 0.95);
          return CustomScrollView(
            slivers: [
              // 顶部间距
              const SliverToBoxAdapter(child: SizedBox(height: 28)),
              // Title — 跟着滚动
              SliverToBoxAdapter(
                child: Text(S.selectPlan, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: t.textPrimary)),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),

              // 余额横幅 — 跟着滚动
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  decoration: BoxDecoration(gradient: t.primaryGradient, borderRadius: BorderRadius.circular(16)),
                  child: Row(
                    children: [
                      const Icon(Icons.account_balance_wallet, color: Colors.white, size: 22),
                      const SizedBox(width: 10),
                      Text(S.accountBalance, style: const TextStyle(color: Colors.white70, fontSize: 14)),
                      const SizedBox(width: 8),
                      const Text('\u00a5 128.00', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                      const Spacer(),
                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () => showPillToast(context, t, S.devInProgress),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.22),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(S.recharge, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 12)),

              // Filter tabs — 吸顶固定
              SliverPersistentHeader(
                pinned: true,
                delegate: _StickyFilterDelegate(
                  child: Container(
                    color: t.scaffoldBg,
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(_filterLabels.length, (i) {
                          final active = _filterIndex == i;
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: GestureDetector(
                              onTap: () { HapticFeedback.lightImpact(); setState(() => _filterIndex = i); },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                decoration: BoxDecoration(
                                  gradient: active ? t.buttonGradient : null,
                                  color: active ? null : Colors.transparent,
                                  borderRadius: BorderRadius.circular(10),
                                  border: active ? null : Border.all(color: t.textHint.withValues(alpha: 0.25)),
                                ),
                                child: Text(_filterLabels[i], style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: active ? Colors.white : t.textSecondary)),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                ),
              ),

              // 套餐卡片 Grid
              SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: cols, mainAxisSpacing: 14, crossAxisSpacing: 14,
                  childAspectRatio: ratio,
                ),
                delegate: SliverChildBuilderDelegate(
                  (ctx3, i) => _buildPlanCard(_filteredPlans[i]),
                  childCount: _filteredPlans.length,
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildPlanCard(_Plan plan) {
    final isPopular = plan.name == S.planStandard;
    final hovered = ValueNotifier(false);
    return ValueListenableBuilder<bool>(
      valueListenable: hovered,
      builder: (ctx, isHovered, child) => MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => hovered.value = true,
        onExit: (_) => hovered.value = false,
        child: GestureDetector(
          onTap: () => _showPurchaseDialog(context, plan),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: t.cardBg,
              borderRadius: BorderRadius.circular(18),
              border: isPopular ? Border.all(color: t.primary.withValues(alpha: isHovered ? 0.7 : 0.4), width: 1.5) : isHovered ? Border.all(color: t.primary.withValues(alpha: 0.3), width: 1) : t.cardBorder,
              boxShadow: [BoxShadow(
                color: (isPopular ? t.primary : Colors.black).withValues(alpha: isHovered ? 0.18 : (isPopular ? 0.1 : 0.04)),
                blurRadius: isHovered ? 20 : 12,
                offset: Offset(0, isHovered ? 2 : 4),
              )],
            ),
            transform: isHovered ? (Matrix4.identity()..translate(0.0, -3.0)) : Matrix4.identity(),
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 头部：图标+名称 左，价格 右上
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: t.primary.withValues(alpha: t.isDark ? 0.15 : 0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(plan.icon, color: t.primary, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(child: Text(plan.name, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: t.textPrimary), overflow: TextOverflow.ellipsis)),
                            if (isPopular) ...[
                              const SizedBox(width: 5),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                decoration: BoxDecoration(color: t.warning.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(4)),
                                child: Text(S.recommended, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: t.warning)),
                              ),
                            ],
                            if (plan.type == _PlanType.oneTime) ...[
                              const SizedBox(width: 5),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                decoration: BoxDecoration(color: t.primary.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(4)),
                                child: Text(S.oneTimeLabel, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: t.primary)),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(plan.subtitle, style: TextStyle(fontSize: 11, color: t.textSecondary), overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  // 价格在右上角
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text('\u00a5', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: t.primary)),
                      Text('${plan.basePrice}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: t.primary)),
                      const SizedBox(width: 3),
                      Text(plan.type == _PlanType.oneTime ? S.oneTimeLabel : S.fromPerMonth, style: TextStyle(fontSize: 10, color: t.textHint)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // 特性列表 — 支持 Markdown + HTML 混合格式
              Expanded(
                child: SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  child: plan.description != null
                    ? HtmlWidget(
                        plan.description!,
                        textStyle: TextStyle(fontSize: 12, color: t.textSecondary, height: 1.5),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: plan.features.take(4).map((f) => Padding(
                          padding: const EdgeInsets.only(bottom: 2),
                          child: Row(
                            children: [
                              Icon(Icons.check_circle, size: 13, color: t.success),
                              const SizedBox(width: 4),
                              Flexible(child: Text(f, style: TextStyle(fontSize: 12, color: t.textSecondary), overflow: TextOverflow.ellipsis)),
                            ],
                          ),
                        )).toList(),
                      ),
                ),
              ),
              const SizedBox(height: 6),
              // 购买按钮 底部居中
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 8),
                  decoration: BoxDecoration(gradient: t.buttonGradient, borderRadius: BorderRadius.circular(10)),
                  child: Text(S.buyNow, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
    );
  }
}

// ══════════════════════════════════════════════════
//  桌面端购买弹窗（订单 → 支付 → 成功）
// ══════════════════════════════════════════════════

class _PurchaseDialog extends StatefulWidget {
  final MihomTheme theme;
  final _Plan plan;
  final List<_Cycle> cycles;
  final List<_Payment> payments;
  final VoidCallback? onPlanPurchased;
  final VoidCallback? onGoHome;
  const _PurchaseDialog({required this.theme, required this.plan, required this.cycles, required this.payments, this.onPlanPurchased, this.onGoHome});

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
  bool _couponExpanded = false;
  bool _priceDetailExpanded = false;
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

  void _verifyCoupon() {
    HapticFeedback.mediumImpact();
    if (_couponCtrl.text.trim().isEmpty) return;
    setState(() => _couponVerified = true);
  }

  void _done() {
    widget.onGoHome?.call();
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
            width: 400,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: t.cardBg,
              borderRadius: BorderRadius.circular(20),
              border: t.cardBorder,
              boxShadow: [BoxShadow(color: t.primary.withValues(alpha: 0.15), blurRadius: 30)],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(S.selectBillingCycle, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: t.textPrimary)),
                const SizedBox(height: 14),
                ...List.generate(widget.cycles.length, (i) {
                  final c = widget.cycles[i];
                  final price = double.parse((widget.plan.basePrice * c.months * c.discount).toStringAsFixed(1));
                  final monthly = c.months > 1 ? double.parse((price / c.months).toStringAsFixed(1)) : null;
                  final selected = _selectedCycle == i;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () { HapticFeedback.lightImpact(); Navigator.of(ctx).pop(i); },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: selected
                                ? t.primary.withValues(alpha: t.isDark ? 0.15 : 0.06)
                                : t.isDark ? const Color(0xFF1E2140) : const Color(0xFFF5F7FA),
                            borderRadius: BorderRadius.circular(12),
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
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(children: [
                                      Flexible(child: Text(c.name, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: selected ? t.primary : t.textPrimary), overflow: TextOverflow.ellipsis)),
                                      if (c.discount < 1.0) ...[
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                          decoration: BoxDecoration(color: t.danger.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(3)),
                                          child: Text(S.isEn ? '${((1 - c.discount) * 100).round()}${S.discountLabel}' : '${(c.discount * 10).toStringAsFixed(1)}${S.discountLabel}', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: t.danger)),
                                        ),
                                      ],
                                    ]),
                                    if (monthly != null) Text('${S.equivalentMonthly} \u00a5$monthly${S.perMonth}', style: TextStyle(fontSize: 11, color: t.textHint)),
                                  ],
                                ),
                              ),
                              Text('\u00a5$price', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: selected ? t.primary : t.textPrimary)),
                            ],
                          ),
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
                width: 380,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: t.cardBg,
                  borderRadius: BorderRadius.circular(20),
                  border: t.cardBorder,
                  boxShadow: [BoxShadow(color: t.primary.withValues(alpha: 0.15), blurRadius: 30)],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 标题 + 金额
                    Row(
                      children: [
                        Text(S.isEn ? 'Confirm Payment' : '确认支付', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: t.textPrimary)),
                        const Spacer(),
                        Text('¥$_totalPrice', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: t.primary)),
                      ],
                    ),
                    const SizedBox(height: 14),
                    // 支付方式选择器行（折叠，点击弹出嵌套弹窗）
                    Text(S.selectPaymentMethod, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: t.textSecondary)),
                    const SizedBox(height: 6),
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
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
                                  width: 380,
                                  padding: const EdgeInsets.all(22),
                                  decoration: BoxDecoration(
                                    color: t.cardBg,
                                    borderRadius: BorderRadius.circular(20),
                                    border: t.cardBorder,
                                    boxShadow: [BoxShadow(color: t.primary.withValues(alpha: 0.15), blurRadius: 30)],
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(S.selectPaymentMethod, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: t.textPrimary)),
                                      const SizedBox(height: 14),
                                      ...List.generate(widget.payments.length, (i) {
                                        final p = widget.payments[i];
                                        final selected = tempSelected == i;
                                        return Padding(
                                          padding: const EdgeInsets.only(bottom: 6),
                                          child: MouseRegion(
                                            cursor: SystemMouseCursors.click,
                                            child: GestureDetector(
                                              onTap: () { HapticFeedback.lightImpact(); Navigator.of(c3).pop(i); },
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                                decoration: BoxDecoration(
                                                  color: selected
                                                      ? t.primary.withValues(alpha: t.isDark ? 0.15 : 0.06)
                                                      : t.isDark ? const Color(0xFF1E2140) : const Color(0xFFF5F7FA),
                                                  borderRadius: BorderRadius.circular(12),
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
                                                          Text(p.name, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: selected ? t.primary : t.textPrimary)),
                                                          if (i == 2) Text('${S.balance} ¥128.00', style: TextStyle(fontSize: 11, color: t.textHint)),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
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
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
                                    ? Text(widget.payments[tempSelected].name, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: t.textPrimary))
                                    : Text(S.pleaseSelectPayment, style: TextStyle(fontSize: 13, color: t.textHint)),
                              ),
                              const SizedBox(width: 4),
                              Icon(Icons.chevron_right, size: 18, color: t.textHint),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    // 确认支付按钮
                    MouseRegion(
                      cursor: hasPayment ? SystemMouseCursors.click : SystemMouseCursors.basic,
                      child: GestureDetector(
                        onTap: hasPayment ? () {
                          HapticFeedback.mediumImpact();
                          Navigator.of(ctx2).pop(tempSelected);
                        } : null,
                        child: Container(
                          width: double.infinity, height: 44,
                          decoration: BoxDecoration(
                            gradient: hasPayment ? t.buttonGradient : null,
                            color: hasPayment ? null : t.textHint.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: hasPayment
                                ? [BoxShadow(color: t.primary.withValues(alpha: 0.2), blurRadius: 12, offset: const Offset(0, 3))]
                                : null,
                          ),
                          child: Center(
                            child: Text(
                              hasPayment ? '${S.confirmPaymentWithPrice}  ¥$_totalPrice' : S.pleaseSelectPayment,
                              style: TextStyle(
                                color: hasPayment ? Colors.white : t.textHint,
                                fontSize: 14, fontWeight: FontWeight.w600,
                              ),
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
            widget.onPlanPurchased?.call();
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isOrderStep = _step == _Step.order;
    final dialogWidth = isOrderStep ? 420.0 : 360.0;
    final maxH = isOrderStep
        ? MediaQuery.of(context).size.height * 0.78
        : MediaQuery.of(context).size.height * 0.55;
    return Material(
      color: Colors.transparent,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: dialogWidth,
        constraints: BoxConstraints(maxHeight: maxH),
        decoration: BoxDecoration(
          color: t.cardBg,
          borderRadius: BorderRadius.circular(20),
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

  Widget _buildOrderForm() {
    final hasCycle = _selectedCycle >= 0;
    final couponText = _couponCtrl.text.trim();
    final couponBlocking = couponText.isNotEmpty && !_couponVerified;

    return SingleChildScrollView(
      key: const ValueKey('order'),
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── 标题 + 关闭
          Row(
            children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: t.primary.withValues(alpha: t.isDark ? 0.15 : 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(widget.plan.icon, color: t.primary, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.plan.name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: t.textPrimary)),
                    Text('${widget.plan.traffic}${S.perMonth} \u00b7 ${widget.plan.subtitle}', style: TextStyle(fontSize: 11, color: t.textSecondary)),
                  ],
                ),
              ),
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
          const SizedBox(height: 14),

          // ── 产品介绍
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: t.isDark ? const Color(0xFF1E2140) : const Color(0xFFF5F7FA),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(S.planBenefits, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: t.textSecondary)),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6, runSpacing: 4,
                  children: widget.plan.features.map((f) => Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle, size: 12, color: t.success),
                      const SizedBox(width: 3),
                      Text(f, style: TextStyle(fontSize: 11, color: t.textPrimary)),
                    ],
                  )).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // ── 选择周期（点击弹居中弹窗）
          Text(S.selectBillingCycle, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: t.textSecondary)),
          const SizedBox(height: 6),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: _showCyclePicker,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
                              Text(widget.cycles[_selectedCycle].name, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: t.textPrimary)),
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
                          : Text(S.pleaseSelectCycle, style: TextStyle(fontSize: 13, color: t.textHint)),
                    ),
                    if (hasCycle) Text('\u00a5$_totalPrice', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: t.primary)),
                    const SizedBox(width: 4),
                    Icon(Icons.chevron_right, size: 18, color: t.textHint),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // ── 优惠码（折叠式）
          if (!_couponExpanded && !_couponVerified)
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => setState(() => _couponExpanded = true),
                child: Row(
                  children: [
                    Icon(Icons.local_offer_outlined, size: 13, color: t.primary),
                    const SizedBox(width: 5),
                    Text(S.haveCoupon, style: TextStyle(fontSize: 12, color: t.primary, fontWeight: FontWeight.w500)),
                    const SizedBox(width: 4),
                    Text(S.tapToInput, style: TextStyle(fontSize: 11, color: t.textHint)),
                  ],
                ),
              ),
            ),
          if (_couponExpanded || _couponVerified) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 38,
                    decoration: BoxDecoration(
                      color: t.isDark ? const Color(0xFF1E2140) : const Color(0xFFF5F7FA),
                      borderRadius: BorderRadius.circular(12),
                      border: _couponVerified ? Border.all(color: t.success.withValues(alpha: 0.4)) : couponBlocking ? Border.all(color: t.warning.withValues(alpha: 0.5)) : null,
                    ),
                    child: TextField(
                      controller: _couponCtrl,
                      enabled: !_couponVerified,
                      style: TextStyle(fontSize: 13, color: t.textPrimary),
                      decoration: InputDecoration(
                        hintText: S.enterCouponCode,
                        hintStyle: TextStyle(fontSize: 12, color: t.textHint),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                        isDense: true,
                        suffixIcon: _couponVerified
                            ? Padding(padding: const EdgeInsets.only(right: 8), child: Icon(Icons.check_circle, color: t.success, size: 18))
                            : null,
                        suffixIconConstraints: const BoxConstraints(minWidth: 30, minHeight: 30),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: (couponText.isNotEmpty && !_couponVerified) ? _verifyCoupon : null,
                    child: Container(
                      height: 38,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        gradient: (couponText.isNotEmpty && !_couponVerified) ? t.buttonGradient : null,
                        color: (couponText.isNotEmpty && !_couponVerified) ? null : t.textHint.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          _couponVerified ? S.verifiedLabel : S.verifyLabel,
                          style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w600,
                            color: _couponVerified ? t.success : (couponText.isNotEmpty ? Colors.white : t.textHint),
                          ),
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
          const SizedBox(height: 14),

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
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: t.isDark ? const Color(0xFF1E2140) : const Color(0xFFF5F7FA),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    // ── 应付金额（始终可见）
                    GestureDetector(
                      onTap: hasDiscount ? () => setState(() => _priceDetailExpanded = !_priceDetailExpanded) : null,
                      behavior: HitTestBehavior.opaque,
                      child: Row(
                        children: [
                          Text(S.amountDue, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: t.textPrimary)),
                          if (hasDiscount) ...[
                            const SizedBox(width: 4),
                            AnimatedRotation(
                              turns: _priceDetailExpanded ? 0.5 : 0,
                              duration: const Duration(milliseconds: 200),
                              child: Icon(Icons.expand_more, size: 16, color: t.textHint),
                            ),
                          ],
                          const Spacer(),
                          if (hasDiscount && originalPrice != _totalPrice)
                            Padding(
                              padding: const EdgeInsets.only(right: 5),
                              child: Text('\u00a5$originalPrice', style: TextStyle(fontSize: 11, color: t.textHint, decoration: TextDecoration.lineThrough, decorationColor: t.textHint)),
                            ),
                          Text('\u00a5', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: t.primary)),
                          Text('$_totalPrice', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: t.primary)),
                        ],
                      ),
                    ),
                    // ── 价格明细（折叠区域）
                    AnimatedCrossFade(
                      firstChild: const SizedBox.shrink(),
                      secondChild: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Divider(height: 1, color: t.textHint.withValues(alpha: 0.15)),
                          ),
                          if (hasDiscount) _priceRow(S.originalPriceLabel, '\u00a5$originalPrice', t.textSecondary, t.textPrimary),
                          if (c.discount < 1.0) _priceRow(
                            S.isEn ? '${c.name} (${((1 - c.discount) * 100).round()}% off)' : '${c.name}优惠 (${(c.discount * 10).toStringAsFixed(1)}折)',
                            '-\u00a5$cycleDiscount', t.textSecondary, t.danger),
                          if (_couponVerified) _priceRow('${S.couponLabel} (${S.isEn ? "10% off" : "9折"})', '-\u00a5$couponDiscount', t.textSecondary, t.danger),
                          if (couponText.isNotEmpty && !_couponVerified) _priceRow(S.couponLabel, S.pendingVerify, t.textSecondary, t.warning),
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
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 48, height: 48,
            child: RotationTransition(
              turns: _loadCtrl,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: t.primary.withValues(alpha: 0.2), width: 3),
                ),
                child: Container(
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(shape: BoxShape.circle, gradient: SweepGradient(colors: [t.primary.withValues(alpha: 0), t.primary])),
                  width: 40, height: 40,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(S.waitingPayment, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: t.textPrimary)),
          const SizedBox(height: 6),
          Text('${S.isEn ? 'Complete payment in ' : '请在'}${widget.payments[_selectedPayment].name}${S.isEn ? '' : '中完成支付'}',
            style: TextStyle(fontSize: 13, color: t.textSecondary)),
          const SizedBox(height: 8),
          Text('\u00a5$_totalPrice', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: t.primary)),
        ],
      ),
    );
  }

  bool _detailsExpanded = false;

  // ── 购买成功 ──
  Widget _buildSuccessStep() {
    return SingleChildScrollView(
      key: const ValueKey('success'),
      padding: const EdgeInsets.all(22),
      child: StatefulBuilder(
        builder: (ctx, setLocalState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56, height: 56,
                decoration: BoxDecoration(shape: BoxShape.circle, color: t.success.withValues(alpha: 0.12)),
                child: Icon(Icons.check_circle, color: t.success, size: 38),
              ),
              const SizedBox(height: 12),
              Text(S.purchaseSuccess, style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: t.textPrimary)),
              const SizedBox(height: 4),
              Text('${widget.plan.name} \u00b7 ${widget.cycles[_selectedCycle].name}', style: TextStyle(fontSize: 12, color: t.textSecondary)),
              const SizedBox(height: 2),
              Text('${S.paid} \u00a5$_totalPrice', style: TextStyle(fontSize: 12, color: t.textHint)),
              const SizedBox(height: 14),
              // 可折叠订单详情
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () => setLocalState(() => _detailsExpanded = !_detailsExpanded),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: t.isDark ? const Color(0xFF1E2140) : const Color(0xFFF5F7FA),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.receipt_long, size: 16, color: t.textSecondary),
                        const SizedBox(width: 8),
                        Text(S.orderDetails, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: t.textPrimary)),
                        const Spacer(),
                        AnimatedRotation(
                          turns: _detailsExpanded ? 0.5 : 0,
                          duration: const Duration(milliseconds: 200),
                          child: Icon(Icons.expand_more, size: 20, color: t.textHint),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              AnimatedCrossFade(
                firstChild: const SizedBox(width: double.infinity),
                secondChild: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(top: 6),
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
                crossFadeState: _detailsExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 250),
                sizeCurve: Curves.easeInOut,
              ),
              const SizedBox(height: 16),
              _actionButton(S.okStartConnect, _done),
            ],
          );
        },
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
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: labelColor)),
          Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: valueColor)),
        ],
      ),
    );
  }

  Widget _actionButton(String label, VoidCallback? onTap) {
    final enabled = onTap != null;
    return MouseRegion(
      cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity, height: 44,
          decoration: BoxDecoration(
            gradient: enabled ? t.buttonGradient : null,
            color: enabled ? null : t.textHint.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
            boxShadow: enabled ? [BoxShadow(color: t.primary.withValues(alpha: 0.2), blurRadius: 12, offset: const Offset(0, 3))] : null,
          ),
          child: Center(
            child: Text(label, style: TextStyle(color: enabled ? Colors.white : t.textHint, fontSize: 14, fontWeight: FontWeight.w600)),
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════
//  独立居中弹窗：选择支付方式 + 确认支付
// ══════════════════════════════════════════════════



// ── 吸顶筛选栏 Delegate ──
class _StickyFilterDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  _StickyFilterDelegate({required this.child});

  @override
  double get minExtent => 50;
  @override
  double get maxExtent => 50;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) => child;

  @override
  bool shouldRebuild(covariant _StickyFilterDelegate oldDelegate) => true;
}

// ── 数据模型 ──
enum _PlanType { recurring, oneTime }

class _Plan {
  final String name, subtitle;
  final double basePrice;
  final String traffic;
  final IconData icon;
  final List<String> features;
  final _PlanType type;
  final String? description;
  _Plan(this.name, this.subtitle, this.basePrice, this.traffic, this.icon, this.features, {this.type = _PlanType.recurring, this.description});
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
