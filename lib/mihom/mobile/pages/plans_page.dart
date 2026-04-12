import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_xboard_sdk/flutter_xboard_sdk.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fl_clash/xboard/adapter/state/plan_state.dart';
import 'package:fl_clash/xboard/adapter/initialization/sdk_provider.dart';
import 'package:fl_clash/xboard/features/auth/providers/xboard_user_provider.dart';
import '../../theme/mihom_theme.dart';
import '../../i18n.dart';
import '../../widgets/login_dialog.dart';
import '../../widgets/credential_store.dart';
import '../../widgets/pill_toast.dart';

/// 移动端套餐页 — 全屏页面 + 底部弹窗购买流程
class DemoPlansPage extends ConsumerStatefulWidget {
  final MihomTheme theme;
  final bool isGuest;
  final VoidCallback? onLogin;
  final bool embeddedMode;
  const DemoPlansPage({super.key, required this.theme, this.isGuest = false, this.onLogin, this.embeddedMode = false});

  @override
  ConsumerState<DemoPlansPage> createState() => _DemoPlansPageState();
}

class _DemoPlansPageState extends ConsumerState<DemoPlansPage> {
  MihomTheme get t => widget.theme;
  int _filterIndex = 0;
  List<String> get _filterLabels => [S.allPlans, S.recurring, S.oneTime];

  bool _plansLoading = true;
  List<_Plan> _plans = [];
  String? _plansError;

  @override
  void initState() {
    super.initState();
    _loadPlans();
  }

  @override
  void didUpdateWidget(covariant DemoPlansPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isGuest != widget.isGuest) {
      _plansLoading = true;
      _plansError = null;
      _loadPlans();
    }
  }

  Future<void> _loadPlans() async {
    try {
      List<PlanModel> planModels;
      if (widget.isGuest) {
        planModels = await _loadGuestPlans();
      } else {
        planModels = await ref.read(getPlansProvider.future);
      }
      if (!mounted) return;
      setState(() {
        _plans = planModels
            .where((p) => p.isVisible && p.hasPrice)
            .map((p) => _Plan.fromModel(p))
            .toList();
        _plansLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _plansError = e.toString();
        _plansLoading = false;
      });
    }
  }

  Future<List<PlanModel>> _loadGuestPlans() async {
    final http = XBoardSDK.instance.httpService;
    final result = await http.getRequest('/api/v1/guest/plan/fetch');
    final data = result['data'];
    if (data is List) {
      return data.map((e) => PlanModel.fromJson(e as Map<String, dynamic>)).toList();
    }
    return [];
  }

  List<_Plan> get _filteredPlans {
    if (_plansLoading || _plans.isEmpty) return [];
    if (_filterIndex == 0) return _plans;
    if (_filterIndex == 1) return _plans.where((p) => p.type == _PlanType.recurring).toList();
    return _plans.where((p) => p.type == _PlanType.oneTime).toList();
  }

  void _showPurchaseSheet(BuildContext context, _Plan plan) {
    if (widget.isGuest) {
      HapticFeedback.mediumImpact();
      showLoginDialog(context, t, hint: S.loginToBuy,
        initialEmail: SavedCredentials.email,
        initialPassword: SavedCredentials.password,
      ).then((result) {
        if (result != null && mounted) {
          SavedCredentials.email = result['email'] ?? '';
          SavedCredentials.password = result['password'] ?? '';
          setState(() {});
        }
      });
      return;
    }
    HapticFeedback.mediumImpact();
    showGeneralDialog<bool>(
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
          child: _PurchaseSheet(
            theme: t,
            plan: plan,
            ref: ref,
            onPlanPurchased: () {
              Navigator.of(context).pop(true);
            },
          ),
        ),
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
              // AppBar (fixed)
              Padding(
                padding: EdgeInsets.fromLTRB(widget.embeddedMode ? 24 : 8, 8, 24, 0),
                child: Row(
                  children: [
                    if (!widget.embeddedMode)
                      IconButton(
                        icon: Icon(Icons.arrow_back_ios_new, color: t.textPrimary, size: 20),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    Text(S.selectPlan, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: t.textPrimary)),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Scrollable area with sticky filter tabs
              Expanded(
                child: _plansLoading
                    ? Center(child: CircularProgressIndicator(color: t.primary))
                    : _plansError != null
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.error_outline, color: t.danger, size: 36),
                                const SizedBox(height: 10),
                                Text(S.isEn ? 'Failed to load plans' : '加载套餐失败', style: TextStyle(color: t.textSecondary, fontSize: 14)),
                                const SizedBox(height: 10),
                                GestureDetector(
                                  onTap: () { setState(() { _plansLoading = true; _plansError = null; }); _loadPlans(); },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                    decoration: BoxDecoration(gradient: t.buttonGradient, borderRadius: BorderRadius.circular(10)),
                                    child: Text(S.isEn ? 'Retry' : '重试', style: const TextStyle(color: Colors.white, fontSize: 13)),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : _filteredPlans.isEmpty && !widget.isGuest
                            ? Center(child: Text(S.isEn ? 'No plans available' : '暂无可用套餐', style: TextStyle(color: t.textHint, fontSize: 14)))
                            : CustomScrollView(
                                slivers: [
                                  // 余额横幅 (scrolls with content)
                                  if (!widget.isGuest)
                                    SliverToBoxAdapter(
                                      child: Padding(
                                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                          decoration: BoxDecoration(gradient: t.primaryGradient, borderRadius: BorderRadius.circular(14)),
                                          child: Row(
                                            children: [
                                              const Icon(Icons.account_balance_wallet, color: Colors.white, size: 20),
                                              const SizedBox(width: 8),
                                              Text(S.accountBalance, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                                              const SizedBox(width: 6),
                                              () {
                                                final user = ref.watch(userInfoProvider);
                                                final balanceYuan = (user?.balanceInCents ?? 0) / 100.0;
                                                return Text('¥${balanceYuan.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold));
                                              }(),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),

                                  // Filter tabs (sticky)
                                  SliverPersistentHeader(
                                    pinned: true,
                                    delegate: _StickyFilterDelegate(
                                      child: Container(
                                        color: t.scaffoldBg,
                                        padding: const EdgeInsets.only(bottom: 12),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: List.generate(_filterLabels.length, (i) {
                                            final active = _filterIndex == i;
                                            return Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 4),
                                              child: GestureDetector(
                                                onTap: () { HapticFeedback.lightImpact(); setState(() => _filterIndex = i); },
                                                child: AnimatedContainer(
                                                  duration: const Duration(milliseconds: 200),
                                                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
                                                  decoration: BoxDecoration(
                                                    gradient: active ? t.buttonGradient : null,
                                                    color: active ? null : Colors.transparent,
                                                    borderRadius: BorderRadius.circular(10),
                                                    border: active ? null : Border.all(color: t.textHint.withValues(alpha: 0.25)),
                                                  ),
                                                  child: Text(_filterLabels[i], style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: active ? Colors.white : t.textSecondary)),
                                                ),
                                              ),
                                            );
                                          }),
                                        ),
                                      ),
                                      height: 46,
                                      scaffoldBg: t.scaffoldBg,
                                    ),
                                  ),

                                  // Plans list
                                  if (_filteredPlans.isEmpty)
                                    SliverFillRemaining(
                                      hasScrollBody: false,
                                      child: Center(child: Text(S.isEn ? 'No plans available' : '暂无可用套餐', style: TextStyle(color: t.textHint, fontSize: 14))),
                                    )
                                  else
                                    SliverPadding(
                                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 120),
                                      sliver: SliverList(
                                        delegate: SliverChildBuilderDelegate(
                                          (ctx, i) => _buildPlanCard(_filteredPlans[i]),
                                          childCount: _filteredPlans.length,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlanCard(_Plan plan) {
    return GestureDetector(
      onTap: () => _showPurchaseSheet(context, plan),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: t.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: t.cardBorder,
          boxShadow: t.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: icon + name + price
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
                      Row(children: [
                        Flexible(child: Text(plan.name, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: t.textPrimary), overflow: TextOverflow.ellipsis)),
                        if (plan.type == _PlanType.oneTime) ...[
                          const SizedBox(width: 5),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                            decoration: BoxDecoration(color: t.primary.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(4)),
                            child: Text(S.oneTimeLabel, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: t.primary)),
                          ),
                        ],
                      ]),
                      const SizedBox(height: 2),
                      Text(plan.traffic, style: TextStyle(fontSize: 11, color: t.textSecondary)),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text('¥', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: t.primary)),
                    Text('${plan.basePrice}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: t.primary)),
                    const SizedBox(width: 3),
                    Text(plan.type == _PlanType.oneTime ? S.oneTimeLabel : S.fromPerMonth, style: TextStyle(fontSize: 10, color: t.textHint)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Features
            if (plan.description != null && plan.description!.trim().isNotEmpty)
              _buildPlanDescription(plan.description!)
            else
              Wrap(
                spacing: 8, runSpacing: 4,
                children: plan.features.take(4).map((f) => Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle, size: 13, color: t.success),
                    const SizedBox(width: 3),
                    Text(f, style: TextStyle(fontSize: 12, color: t.textSecondary)),
                  ],
                )).toList(),
              ),
            const SizedBox(height: 12),
            // 立即购买按钮
            Container(
              width: double.infinity,
              height: 38,
              decoration: BoxDecoration(
                gradient: t.buttonGradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(S.buyNow, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanDescription(String desc) {
    if (desc.trim().isEmpty) return const SizedBox.shrink();
    final hasHtml = RegExp(r'<[a-zA-Z][^>]*>').hasMatch(desc);
    if (hasHtml) {
      return HtmlWidget(desc, textStyle: TextStyle(fontSize: 12, color: t.textSecondary));
    }
    return MarkdownBody(
      data: desc, shrinkWrap: true,
      styleSheet: MarkdownStyleSheet(
        p: TextStyle(fontSize: 12, color: t.textSecondary),
        strong: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: t.textPrimary),
        code: TextStyle(fontSize: 11, color: t.primary, backgroundColor: t.primary.withValues(alpha: 0.08)),
      ),
    );
  }
}

// ════════════════════════════════════════════════════
//  移动端购买底部弹窗（订单 → 支付 → 成功）
// ════════════════════════════════════════════════════

class _PurchaseSheet extends StatefulWidget {
  final MihomTheme theme;
  final _Plan plan;
  final WidgetRef ref;
  final VoidCallback? onPlanPurchased;
  const _PurchaseSheet({required this.theme, required this.plan, required this.ref, this.onPlanPurchased});

  @override
  State<_PurchaseSheet> createState() => _PurchaseSheetState();
}

enum _Step { order, paying, success }

class _PurchaseSheetState extends State<_PurchaseSheet> with SingleTickerProviderStateMixin {
  MihomTheme get t => widget.theme;
  WidgetRef get ref => widget.ref;
  _Step _step = _Step.order;
  int _selectedCycle = -1;
  int _selectedPayment = -1;
  final _couponCtrl = TextEditingController();
  bool _couponVerified = false;
  CouponModel? _couponData;
  bool _couponExpanded = false;
  late AnimationController _loadCtrl;

  // API state
  String? _tradeNo;
  List<_Payment> _payments = [];
  bool _isCreatingOrder = false;
  String? _orderError;
  String? _orderProgress;

  // Balance
  double _userBalance = 0;
  bool _balanceLoading = true;

  List<_Cycle> get _cycles => widget.plan.availableCycles;

  double get _totalPrice {
    if (_selectedCycle < 0 || _selectedCycle >= _cycles.length) return 0;
    return _cycles[_selectedCycle].totalPrice;
  }

  double get _effectivePrice {
    final base = _totalPrice;
    if (!_couponVerified || _couponData == null || base <= 0) return base;
    final discount = _calcCouponDiscount(base);
    return double.parse((base - discount).clamp(0, double.infinity).toStringAsFixed(2));
  }

  double get _balanceDeduction => _effectivePrice > 0 ? (_userBalance >= _effectivePrice ? _effectivePrice : _userBalance) : 0;
  double get _remainingToPay => (_effectivePrice - _balanceDeduction).clamp(0, double.infinity);

  @override
  void initState() {
    super.initState();
    _loadCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat();
    _couponCtrl.addListener(() => setState(() {}));
    _fetchBalance();
  }

  Future<void> _fetchBalance() async {
    try {
      final sdk = await ref.read(xboardSdkProvider.future);
      final user = await sdk.user.getUserInfo();
      if (!mounted) return;
      setState(() { _userBalance = user.balanceInYuan; _balanceLoading = false; });
    } catch (_) {
      if (!mounted) return;
      setState(() => _balanceLoading = false);
    }
  }

  @override
  void dispose() {
    _loadCtrl.dispose();
    _couponCtrl.dispose();
    super.dispose();
  }

  // ── Coupon ──
  Future<void> _verifyCoupon() async {
    HapticFeedback.mediumImpact();
    final code = _couponCtrl.text.trim();
    if (code.isEmpty || widget.plan.planId == null) return;
    try {
      final sdk = await ref.read(xboardSdkProvider.future);
      final coupon = await sdk.order.checkCoupon(code, widget.plan.planId!);
      if (!mounted) return;
      if (coupon != null) {
        setState(() { _couponVerified = true; _couponData = coupon; });
        showPillToast(context, t, S.isEn ? 'Coupon applied!' : '优惠码已生效！');
      } else {
        showPillToast(context, t, S.isEn ? 'Invalid coupon' : '无效优惠码');
      }
    } catch (e) {
      if (!mounted) return;
      final msg = (e is XBoardException) ? e.message : (S.isEn ? 'Coupon check failed' : '优惠码验证失败');
      showPillToast(context, t, msg);
    }
  }

  double _calcCouponDiscount(double price) {
    if (_couponData == null) return 0;
    if (_couponData!.type == 1) return double.parse(((_couponData!.value ?? 0) / 100.0).toStringAsFixed(2));
    if (_couponData!.type == 2) return double.parse((price * (_couponData!.value ?? 0) / 100.0).toStringAsFixed(2));
    return 0;
  }

  String _couponLabel() {
    if (_couponData == null) return '';
    if (_couponData!.type == 1) {
      final yuan = ((_couponData!.value ?? 0) / 100.0).toStringAsFixed(0);
      return S.isEn ? '¥$yuan off' : '减¥$yuan';
    } else if (_couponData!.type == 2) {
      final pct = _couponData!.value ?? 0;
      if (S.isEn) return '$pct% off';
      return '${(10 - pct / 10.0).toStringAsFixed(1)}折';
    }
    return '';
  }

  // ── Plan change confirmation ──
  Future<bool> _confirmPlanChangeIfNeeded() async {
    final user = ref.read(userInfoProvider);
    if (user == null) return true;
    if (user.planId == null || user.planId == widget.plan.planId) return true;
    if (user.expiredAt != null && user.expiredAt!.isBefore(DateTime.now())) return true;

    final result = await showGeneralDialog<bool>(
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
            width: MediaQuery.of(ctx).size.width * 0.84,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: t.cardBg, borderRadius: BorderRadius.circular(18),
              border: t.cardBorder,
              boxShadow: [BoxShadow(color: t.primary.withValues(alpha: 0.12), blurRadius: 24)],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(children: [
                  Icon(Icons.info_rounded, size: 24, color: t.primary),
                  const SizedBox(width: 8),
                  Text(S.isEn ? 'Notice' : '注意', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: t.textPrimary)),
                ]),
                const SizedBox(height: 14),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    S.isEn ? 'Changing subscription will overwrite the current one.' : '变更订阅会导致当前订阅被覆盖。',
                    style: TextStyle(fontSize: 14, color: t.textSecondary, height: 1.5),
                  ),
                ),
                const SizedBox(height: 20),
                Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  GestureDetector(
                    onTap: () => Navigator.of(ctx).pop(false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(border: Border.all(color: t.textHint.withValues(alpha: 0.3)), borderRadius: BorderRadius.circular(8)),
                      child: Text(S.isEn ? 'Cancel' : '取消', style: TextStyle(fontSize: 13, color: t.textSecondary)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () => Navigator.of(ctx).pop(true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(color: t.primary, borderRadius: BorderRadius.circular(8)),
                      child: Text(S.isEn ? 'Confirm' : '确定', style: const TextStyle(fontSize: 13, color: Colors.white)),
                    ),
                  ),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
    return result == true;
  }

  // ── Create order ──
  Future<void> _createOrder() async {
    if (widget.plan.planId == null || _selectedCycle < 0) return;
    setState(() { _isCreatingOrder = true; _orderError = null; _orderProgress = null; });
    try {
      final sdk = await ref.read(xboardSdkProvider.future);
      final cycle = _cycles[_selectedCycle];
      final coupon = _couponVerified ? _couponCtrl.text.trim() : null;

      String? tradeNo;
      try {
        tradeNo = await sdk.order.createOrder(widget.plan.planId!, cycle.period, couponCode: coupon);
      } on XBoardException catch (e) {
        if (e.message.contains('未付款') || e.message.contains('unpaid') || e.message.contains('pending')) {
          tradeNo = await _cancelPendingAndRetry(sdk, cycle.period, coupon);
        } else {
          rethrow;
        }
      }

      if (tradeNo == null || !mounted) { setState(() { _isCreatingOrder = false; }); return; }

      setState(() => _orderProgress = S.isEn ? 'Loading payment methods...' : '正在加载支付方式...');
      final paymentMethods = await sdk.order.getPaymentMethods(tradeNo);
      if (!mounted) return;

      ref.read(xboardUserProvider.notifier).refreshSubscriptionInfoAfterPayment();

      setState(() {
        _tradeNo = tradeNo;
        _payments = paymentMethods.map((pm) => _Payment(
          pm.id, pm.name, _paymentIcon(pm.name), _paymentColor(pm.name), method: pm.paymentMethod ?? pm.id,
        )).toList();
        _isCreatingOrder = false;
        _orderProgress = null;
      });
    } catch (e) {
      if (!mounted) return;
      final msg = (e is XBoardException) ? e.message : e.toString();
      setState(() { _isCreatingOrder = false; _orderError = msg; _orderProgress = null; });
    }
  }

  Future<String?> _cancelPendingAndRetry(dynamic sdk, String period, String? coupon) async {
    if (!mounted) return null;
    setState(() => _orderProgress = S.isEn ? 'Checking pending orders...' : '正在检查未付款订单...');
    final orders = await sdk.order.getOrders(page: 1, pageSize: 50);
    final pending = (orders as List).where((o) => o.status == 0).toList();
    if (pending.isEmpty) {
      throw ApiException(S.isEn ? 'You have a processing order, please wait or contact support' : '您有开通中的订单，请等待处理或联系客服');
    }
    for (int i = 0; i < pending.length; i++) {
      if (!mounted) return null;
      setState(() => _orderProgress = S.isEn ? 'Canceling old order (${i + 1}/${pending.length})...' : '正在取消旧订单 (${i + 1}/${pending.length})...');
      await sdk.order.cancelOrder(pending[i].tradeNo);
    }
    if (!mounted) return null;
    setState(() => _orderProgress = S.isEn ? 'Refreshing balance...' : '正在刷新余额...');
    await _fetchBalance();
    if (!mounted) return null;
    setState(() => _orderProgress = S.isEn ? 'Creating new order...' : '正在重新创建订单...');
    return await sdk.order.createOrder(widget.plan.planId!, period, couponCode: coupon);
  }

  // ── Checkout ──
  Future<void> _checkoutOrder(int paymentIdx) async {
    if (_tradeNo == null || paymentIdx >= _payments.length) return;
    try {
      final sdk = await ref.read(xboardSdkProvider.future);
      final payment = _payments[paymentIdx];
      final result = await sdk.order.checkoutOrder(_tradeNo!, payment.method ?? payment.id);
      if (!mounted) return;
      result.when(
        success: (transactionId, message, extra) {
          HapticFeedback.heavyImpact();
          setState(() => _step = _Step.success);
          widget.onPlanPurchased?.call();
          ref.read(xboardUserProvider.notifier).refreshSubscriptionInfoAfterPayment();
        },
        redirect: (url, method, headers) {
          if (url != null) launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
          HapticFeedback.mediumImpact();
          setState(() => _step = _Step.paying);
          _pollOrderStatus();
        },
        failed: (message, errorCode, extra) {
          setState(() { _step = _Step.order; _orderError = message; });
          showPillToast(context, t, message ?? (S.isEn ? 'Payment failed' : '支付失败'));
        },
        canceled: (message) {
          setState(() => _step = _Step.order);
          showPillToast(context, t, message ?? (S.isEn ? 'Payment canceled' : '支付已取消'));
        },
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _step = _Step.order);
      showPillToast(context, t, S.isEn ? 'Payment error' : '支付错误');
    }
  }

  Future<void> _pollOrderStatus() async {
    if (_tradeNo == null) return;
    final sdk = await ref.read(xboardSdkProvider.future);
    for (int i = 0; i < 60; i++) {
      await Future.delayed(const Duration(seconds: 3));
      if (!mounted || _step != _Step.paying) return;
      try {
        final order = await sdk.order.getOrder(_tradeNo!);
        if (order != null && order.status != null && order.status! >= 3) {
          HapticFeedback.heavyImpact();
          setState(() => _step = _Step.success);
          widget.onPlanPurchased?.call();
          ref.read(xboardUserProvider.notifier).refreshSubscriptionInfoAfterPayment();
          return;
        }
      } catch (_) {}
    }
  }

  // ── Payment helpers ──
  IconData _paymentIcon(String name) {
    final n = name.toLowerCase();
    if (n.contains('alipay') || n.contains('支付宝')) return Icons.account_balance_wallet;
    if (n.contains('wechat') || n.contains('微信')) return Icons.chat_bubble;
    if (n.contains('stripe') || n.contains('card')) return Icons.credit_card;
    return Icons.payment;
  }

  Color _paymentColor(String name) {
    final n = name.toLowerCase();
    if (n.contains('alipay') || n.contains('支付宝')) return const Color(0xFF1677FF);
    if (n.contains('wechat') || n.contains('微信')) return const Color(0xFF07C160);
    if (n.contains('stripe') || n.contains('card')) return const Color(0xFF6772E5);
    return const Color(0xFFFF9500);
  }

  String _smartSubtitle() {
    final p = widget.plan;
    final trafficNum = double.tryParse(p.traffic.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
    final isTB = p.traffic.contains('TB');
    final isEn = S.isEn;
    if (p.type == _PlanType.oneTime) return isEn ? 'One-time • ${p.traffic} total' : '一次性 · ${p.traffic} 总流量';
    if (isTB || trafficNum >= 1000) return isEn ? '${p.traffic}/mo · For power users' : '${p.traffic}/月 · 适合重度用户';
    if (trafficNum >= 300) return isEn ? '${p.traffic}/mo · Recommended' : '${p.traffic}/月 · 推荐日常使用';
    if (trafficNum >= 100) return isEn ? '${p.traffic}/mo · Great for regular use' : '${p.traffic}/月 · 适合常规使用';
    return isEn ? '${p.traffic}/mo · Ideal for light use' : '${p.traffic}/月 · 适合轻度使用';
  }

  List<String> _smartBenefits() {
    final p = widget.plan;
    final trafficNum = double.tryParse(p.traffic.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
    final isTB = p.traffic.contains('TB');
    final isLowest = !isTB && trafficNum <= 100 && trafficNum > 0;
    final isEn = S.isEn;
    final benefits = <String>[];
    benefits.add(isEn ? '${p.traffic} traffic' : '${p.traffic} 流量');
    if (p.deviceLimit != null && p.deviceLimit! > 0) {
      benefits.add(isEn ? '${p.deviceLimit} devices' : '${p.deviceLimit} 台设备');
    } else {
      benefits.add(isEn ? 'Unlimited devices' : '不限设备');
    }
    if (!isLowest) {
      benefits.add(isEn ? 'Unlock ChatGPT/Gemini' : '解锁 ChatGPT/Gemini');
      benefits.add(isEn ? 'Stream Netflix/YouTube' : '流媒体 Netflix/YouTube');
    }
    return benefits.take(4).toList();
  }

  // ── Action button ──
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
          boxShadow: enabled ? [BoxShadow(color: t.primary.withValues(alpha: 0.2), blurRadius: 12, offset: const Offset(0, 3))] : null,
        ),
        child: Center(child: Text(label, style: TextStyle(color: enabled ? Colors.white : t.textHint, fontSize: 15, fontWeight: FontWeight.w600))),
      ),
    );
  }

  // ── Cycle picker (居中弹窗) ──
  void _showCyclePicker() {
    HapticFeedback.lightImpact();
    showGeneralDialog<int>(
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
        width: MediaQuery.of(ctx).size.width * 0.88,
        padding: const EdgeInsets.fromLTRB(22, 20, 22, 24),
        decoration: BoxDecoration(
          color: t.cardBg,
          borderRadius: BorderRadius.circular(24),
          border: t.cardBorder,
          boxShadow: [BoxShadow(color: t.primary.withValues(alpha: 0.15), blurRadius: 40)],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(S.selectBillingCycle, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: t.textPrimary)),
            const SizedBox(height: 14),
            ...List.generate(_cycles.length, (i) {
              final c = _cycles[i];
              final monthly = c.months > 1 ? double.parse((c.totalPrice / c.months).toStringAsFixed(1)) : null;
              final selected = _selectedCycle == i;
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: GestureDetector(
                  onTap: () { HapticFeedback.lightImpact(); Navigator.of(ctx).pop(i); },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: selected ? t.primary.withValues(alpha: t.isDark ? 0.15 : 0.06) : t.isDark ? const Color(0xFF1E2140) : const Color(0xFFF5F7FA),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: selected ? t.primary.withValues(alpha: 0.5) : Colors.transparent, width: 1.5),
                    ),
                    child: Row(children: [
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
                      Expanded(child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Flexible(child: Text(c.name, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: selected ? t.primary : t.textPrimary), overflow: TextOverflow.ellipsis)),
                            if (c.discount < 1.0) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                decoration: BoxDecoration(color: t.danger.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(3)),
                                child: Text(
                                  S.isEn ? '${((1 - c.discount) * 100).round()}${S.discountLabel}' : '${(c.discount * 10).toStringAsFixed(1)}${S.discountLabel}',
                                  style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: t.danger),
                                ),
                              ),
                            ],
                          ]),
                          if (monthly != null) Text('${S.equivalentMonthly} ¥$monthly${S.perMonth}', style: TextStyle(fontSize: 11, color: t.textHint)),
                        ],
                      )),
                      Text('¥${c.totalPrice}', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: selected ? t.primary : t.textPrimary)),
                    ]),
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

  // ── Payment method picker (居中弹窗) ──
  void _showPaymentPicker(void Function(int) onSelected) {
    showGeneralDialog<int>(
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
        width: MediaQuery.of(ctx).size.width * 0.88,
        padding: const EdgeInsets.fromLTRB(22, 20, 22, 24),
        decoration: BoxDecoration(
          color: t.cardBg,
          borderRadius: BorderRadius.circular(24),
          border: t.cardBorder,
          boxShadow: [BoxShadow(color: t.primary.withValues(alpha: 0.15), blurRadius: 40)],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(S.selectPaymentMethod, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: t.textPrimary)),
            const SizedBox(height: 14),
            ...List.generate(_payments.length, (i) {
              final p = _payments[i];
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: GestureDetector(
                  onTap: () { HapticFeedback.lightImpact(); Navigator.of(ctx).pop(i); },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: t.isDark ? const Color(0xFF1E2140) : const Color(0xFFF5F7FA),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(children: [
                      Container(
                        width: 30, height: 30,
                        decoration: BoxDecoration(color: p.color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                        child: Icon(p.icon, color: p.color, size: 16),
                      ),
                      const SizedBox(width: 10),
                      Expanded(child: Text(p.name, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: t.textPrimary))),
                      Icon(Icons.chevron_right, size: 18, color: t.textHint),
                    ]),
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
      if (v != null) onSelected(v);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
      decoration: BoxDecoration(
        color: t.cardBg,
        borderRadius: BorderRadius.circular(24),
        border: t.cardBorder,
        boxShadow: [BoxShadow(color: t.primary.withValues(alpha: 0.15), blurRadius: 40)],
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: _step == _Step.order
            ? _buildOrderForm()
            : _step == _Step.paying
                ? _buildPayingStep()
                : _buildSuccessStep(),
      ),
    );
  }

  Widget _buildOrderForm() {
    final hasCycle = _selectedCycle >= 0;
    final couponText = _couponCtrl.text.trim();
    final couponBlocking = couponText.isNotEmpty && !_couponVerified;

    return SingleChildScrollView(
      key: const ValueKey('order'),
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header: icon + plan name + close
          Row(children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(color: t.primary.withValues(alpha: t.isDark ? 0.15 : 0.08), borderRadius: BorderRadius.circular(10)),
              child: Icon(widget.plan.icon, color: t.primary, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.plan.name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: t.textPrimary)),
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [t.primary.withValues(alpha: t.isDark ? 0.25 : 0.12), t.primary.withValues(alpha: t.isDark ? 0.10 : 0.04)]),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(_smartSubtitle(), style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: t.primary)),
                ),
              ],
            )),
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: t.textHint.withValues(alpha: 0.1), shape: BoxShape.circle),
                child: Icon(Icons.close, color: t.textHint, size: 18),
              ),
            ),
          ]),
          const SizedBox(height: 14),

          // Benefits (hide after cycle selected)
          AnimatedCrossFade(
            firstChild: Container(
              width: double.infinity, padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: t.isDark ? const Color(0xFF1E2140) : const Color(0xFFF5F7FA), borderRadius: BorderRadius.circular(10)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(S.planBenefits, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: t.textSecondary)),
                const SizedBox(height: 6),
                Wrap(spacing: 6, runSpacing: 4, children: _smartBenefits().map((b) => Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.check_circle, size: 12, color: t.success),
                  const SizedBox(width: 3),
                  Text(b, style: TextStyle(fontSize: 11, color: t.textPrimary)),
                ])).toList()),
              ]),
            ),
            secondChild: const SizedBox.shrink(),
            crossFadeState: hasCycle ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
          const SizedBox(height: 14),

          // Select cycle
          Text(S.selectBillingCycle, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: t.textSecondary)),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: _showCyclePicker,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: t.isDark ? const Color(0xFF1E2140) : const Color(0xFFF5F7FA),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: hasCycle ? t.primary.withValues(alpha: 0.3) : Colors.transparent, width: 1),
              ),
              child: Row(children: [
                Icon(Icons.calendar_today, size: 16, color: hasCycle ? t.primary : t.textHint),
                const SizedBox(width: 10),
                Expanded(
                  child: hasCycle
                      ? Row(children: [
                          Text(_cycles[_selectedCycle].name, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: t.textPrimary)),
                          if (_cycles[_selectedCycle].discount < 1.0) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                              decoration: BoxDecoration(color: t.danger.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(3)),
                              child: Text(
                                S.isEn ? '${((1 - _cycles[_selectedCycle].discount) * 100).round()}${S.discountLabel}' : '${(_cycles[_selectedCycle].discount * 10).toStringAsFixed(1)}${S.discountLabel}',
                                style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: t.danger),
                              ),
                            ),
                          ],
                        ])
                      : Text(S.pleaseSelectCycle, style: TextStyle(fontSize: 13, color: t.textHint)),
                ),
                if (hasCycle) Text('¥${_effectivePrice.toStringAsFixed(2)}', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: t.primary)),
                const SizedBox(width: 4),
                Icon(Icons.chevron_right, size: 18, color: t.textHint),
              ]),
            ),
          ),
          const SizedBox(height: 12),

          // Coupon
          if (!_couponExpanded && !_couponVerified)
            GestureDetector(
              onTap: () => setState(() => _couponExpanded = true),
              child: Row(children: [
                Icon(Icons.local_offer_outlined, size: 13, color: t.primary),
                const SizedBox(width: 5),
                Text(S.haveCoupon, style: TextStyle(fontSize: 12, color: t.primary, fontWeight: FontWeight.w500)),
                const SizedBox(width: 4),
                Text(S.tapToInput, style: TextStyle(fontSize: 11, color: t.textHint)),
              ]),
            ),
          if (_couponExpanded || _couponVerified) ...[
            const SizedBox(height: 4),
            Row(children: [
              Expanded(child: Container(
                height: 42,
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
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    isDense: true,
                    suffixIcon: _couponVerified ? Padding(padding: const EdgeInsets.only(right: 8), child: Icon(Icons.check_circle, color: t.success, size: 18)) : null,
                    suffixIconConstraints: const BoxConstraints(minWidth: 30, minHeight: 30),
                  ),
                ),
              )),
              const SizedBox(width: 6),
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
                  child: Center(child: Text(
                    _couponVerified ? S.verifiedLabel : S.verifyLabel,
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _couponVerified ? t.success : (couponText.isNotEmpty ? Colors.white : t.textHint)),
                  )),
                ),
              ),
            ]),
            if (couponBlocking) Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(S.verifyCouponFirst, style: TextStyle(fontSize: 11, color: t.warning)),
            ),
            if (_couponVerified) Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(S.isEn ? 'Coupon: ${_couponLabel()} applied' : '已享 ${_couponLabel()} 优惠', style: TextStyle(fontSize: 11, color: t.success, fontWeight: FontWeight.w500)),
            ),
          ],
          const SizedBox(height: 14),

          // Price detail
          if (hasCycle) ...[
            () {
              final c = _cycles[_selectedCycle];
              final originalPrice = c.months > 0 ? widget.plan.basePrice * c.months : c.totalPrice;
              final discountedPrice = c.totalPrice;
              final cycleDiscount = double.parse((originalPrice - discountedPrice).clamp(0, double.infinity).toStringAsFixed(1));
              final couponDiscount = _couponVerified ? _calcCouponDiscount(discountedPrice) : 0.0;
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: t.isDark ? const Color(0xFF1E2140) : const Color(0xFFF5F7FA), borderRadius: BorderRadius.circular(10)),
                child: Column(children: [
                  Row(children: [
                    Text(S.amountDue, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: t.textPrimary)),
                    const Spacer(),
                    if (originalPrice != _totalPrice)
                      Padding(
                        padding: const EdgeInsets.only(right: 5),
                        child: Text('¥$originalPrice', style: TextStyle(fontSize: 11, color: t.textHint, decoration: TextDecoration.lineThrough, decorationColor: t.textHint)),
                      ),
                    Text('¥', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: t.primary)),
                    Text(_effectivePrice.toStringAsFixed(2), style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: t.primary)),
                  ]),
                  if (c.discount < 1.0) _priceRow(
                    S.isEn ? '${c.name} (${((1 - c.discount) * 100).round()}% off)' : '${c.name}优惠 (${(c.discount * 10).toStringAsFixed(1)}折)',
                    '-¥$cycleDiscount', t.textSecondary, t.danger,
                  ),
                  if (_couponVerified) _priceRow('${S.couponLabel} (${_couponLabel()})', '-¥$couponDiscount', t.textSecondary, t.danger),
                  if (!_balanceLoading && _userBalance > 0) ...[
                    Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Divider(height: 1, color: t.textHint.withValues(alpha: 0.15))),
                    _priceRow(S.isEn ? 'Balance' : '余额', '¥${_userBalance.toStringAsFixed(2)}', t.textSecondary, t.success),
                    _priceRow(S.isEn ? 'Balance Hold' : '余额暂扣', '-¥${_balanceDeduction.toStringAsFixed(2)}', t.textSecondary, t.danger),
                    if (_remainingToPay > 0)
                      _priceRow(S.isEn ? 'Remaining' : '还需支付', '¥${_remainingToPay.toStringAsFixed(2)}', t.textSecondary, t.primary),
                    if (_remainingToPay <= 0)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Row(children: [
                          Icon(Icons.check_circle, size: 13, color: t.success),
                          const SizedBox(width: 4),
                          Text(S.isEn ? 'Balance covers full amount' : '余额足够，可直接支付', style: TextStyle(fontSize: 11, color: t.success, fontWeight: FontWeight.w500)),
                        ]),
                      ),
                  ],
                ]),
              );
            }(),
            const SizedBox(height: 14),
          ],

          // Buy button
          if (_isCreatingOrder)
            Center(child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(color: t.isDark ? const Color(0xFF1E2140) : const Color(0xFFF5F7FA), borderRadius: BorderRadius.circular(14)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: t.primary)),
                if (_orderProgress != null) ...[const SizedBox(width: 10), Text(_orderProgress!, style: TextStyle(fontSize: 12, color: t.textSecondary))],
              ]),
            ))
          else if (_orderError != null)
            Column(children: [
              Text(_orderError!, style: TextStyle(fontSize: 12, color: t.danger)),
              const SizedBox(height: 6),
              _actionButton(S.isEn ? 'Retry' : '重试', () async {
                await _createOrder();
                if (_tradeNo != null && mounted) {
                  _showPaymentPicker((idx) {
                    setState(() { _selectedPayment = idx; _step = _Step.paying; });
                    _checkoutOrder(idx);
                  });
                }
              }),
            ])
          else
            _actionButton(
              _effectivePrice <= 0 && _couponVerified
                  ? (S.isEn ? 'Free Claim' : '免费领取')
                  : _tradeNo != null
                      ? (_remainingToPay <= 0
                          ? (S.isEn ? 'Pay with Balance' : '余额支付')
                          : (S.isEn ? 'Select Payment' : '选择支付方式'))
                      : S.buyNow,
              () async {
                if (_selectedCycle < 0) { _showCyclePicker(); return; }
                final coupon = _couponCtrl.text.trim();
                if (coupon.isNotEmpty && !_couponVerified) {
                  showPillToast(context, t, S.verifyCouponFirst);
                  return;
                }
                if (_tradeNo == null) {
                  final confirmed = await _confirmPlanChangeIfNeeded();
                  if (!confirmed || !mounted) return;
                  await _createOrder();
                  if (_tradeNo == null || !mounted) return;
                }
                // Free order (coupon covers full amount) or balance covers full amount
                if (_effectivePrice <= 0 || (_remainingToPay <= 0 && _userBalance > 0)) {
                  setState(() => _step = _Step.paying);
                  try {
                    final sdk = await ref.read(xboardSdkProvider.future);
                    final result = await sdk.order.checkoutOrder(_tradeNo!, 'balance');
                    if (!mounted) return;
                    result.when(
                      success: (_, __, ___) { HapticFeedback.heavyImpact(); setState(() => _step = _Step.success); widget.onPlanPurchased?.call(); ref.read(xboardUserProvider.notifier).refreshSubscriptionInfoAfterPayment(); },
                      redirect: (_, __, ___) { HapticFeedback.heavyImpact(); setState(() => _step = _Step.success); widget.onPlanPurchased?.call(); ref.read(xboardUserProvider.notifier).refreshSubscriptionInfoAfterPayment(); },
                      failed: (message, __, ___) { setState(() { _step = _Step.order; _orderError = message; }); showPillToast(context, t, message ?? (S.isEn ? 'Balance payment failed' : '余额支付失败')); _showPaymentPicker((idx) { setState(() { _selectedPayment = idx; _step = _Step.paying; }); _checkoutOrder(idx); }); },
                      canceled: (_) { setState(() => _step = _Step.order); },
                    );
                  } catch (e) {
                    if (!mounted) return;
                    setState(() => _step = _Step.order);
                    showPillToast(context, t, S.isEn ? 'Balance payment failed' : '余额支付失败');
                    _showPaymentPicker((idx) { setState(() { _selectedPayment = idx; _step = _Step.paying; }); _checkoutOrder(idx); });
                  }
                  return;
                }
                _showPaymentPicker((idx) {
                  setState(() { _selectedPayment = idx; _step = _Step.paying; });
                  _checkoutOrder(idx);
                });
              },
            ),
        ],
      ),
    );
  }

  Widget _priceRow(String label, String value, Color labelColor, Color valueColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: TextStyle(fontSize: 12, color: labelColor)),
        Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: valueColor)),
      ]),
    );
  }

  // ── Paying step ──
  Widget _buildPayingStep() {
    final paymentName = (_selectedPayment >= 0 && _selectedPayment < _payments.length) ? _payments[_selectedPayment].name : (S.isEn ? 'payment app' : '支付应用');
    final displayAmount = _remainingToPay > 0 ? '¥${_remainingToPay.toStringAsFixed(2)}' : '¥${_effectivePrice.toStringAsFixed(2)}';
    return Padding(
      key: const ValueKey('paying'),
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 36),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Center(child: Container(width: 36, height: 4, decoration: BoxDecoration(color: t.textHint.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(2)))),
        const SizedBox(height: 20),
        SizedBox(
          width: 48, height: 48,
          child: RotationTransition(
            turns: _loadCtrl,
            child: Container(
              decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: t.primary.withValues(alpha: 0.2), width: 3)),
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
        Text(S.isEn ? 'Complete payment in $paymentName' : '请在${paymentName}中完成支付', style: TextStyle(fontSize: 13, color: t.textSecondary)),
        const SizedBox(height: 8),
        Text(displayAmount, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: t.primary)),
        if (_balanceDeduction > 0) ...[
          const SizedBox(height: 4),
          Text(S.isEn ? 'Balance held: ¥${_balanceDeduction.toStringAsFixed(2)}' : '余额暂扣 ¥${_balanceDeduction.toStringAsFixed(2)}', style: TextStyle(fontSize: 11, color: t.success)),
        ],
        const SizedBox(height: 20),
        _actionButton(S.isEn ? "I've Paid" : '我已支付', () async {
          if (_tradeNo == null) return;
          try {
            final sdk = await ref.read(xboardSdkProvider.future);
            final order = await sdk.order.getOrder(_tradeNo!);
            if (!mounted) return;
            if (order != null && order.status != null && order.status! >= 3) {
              HapticFeedback.heavyImpact();
              setState(() => _step = _Step.success);
              widget.onPlanPurchased?.call();
              ref.read(xboardUserProvider.notifier).refreshSubscriptionInfoAfterPayment();
            } else {
              showPillToast(context, t, S.isEn ? 'Payment not confirmed yet...' : '暂未确认到付款，请稍候...');
            }
          } catch (_) {
            showPillToast(context, t, S.isEn ? 'Check failed, retrying...' : '查询失败，请稍后重试');
          }
        }),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => setState(() => _step = _Step.order),
          child: Text(S.isEn ? 'Cancel' : '取消', style: TextStyle(fontSize: 12, color: t.textHint)),
        ),
      ]),
    );
  }

  // ── Success step ──
  Widget _buildSuccessStep() {
    return Padding(
      key: const ValueKey('success'),
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 36),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Center(child: Container(width: 36, height: 4, decoration: BoxDecoration(color: t.textHint.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(2)))),
        const SizedBox(height: 20),
        Container(
          width: 56, height: 56,
          decoration: BoxDecoration(shape: BoxShape.circle, color: t.success.withValues(alpha: 0.12)),
          child: Icon(Icons.check_circle, color: t.success, size: 38),
        ),
        const SizedBox(height: 12),
        Text(S.purchaseSuccess, style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: t.textPrimary)),
        const SizedBox(height: 4),
        Text('${widget.plan.name}${_selectedCycle >= 0 && _selectedCycle < _cycles.length ? ' · ${_cycles[_selectedCycle].name}' : ''}', style: TextStyle(fontSize: 12, color: t.textSecondary)),
        const SizedBox(height: 2),
        Text('${S.paid} ¥${_effectivePrice.toStringAsFixed(2)}', style: TextStyle(fontSize: 12, color: t.textHint)),
        const SizedBox(height: 20),
        _actionButton(S.okStartConnect, () {
          Navigator.of(context).pop(true);
        }),
      ]),
    );
  }
}

// ── Sticky filter header delegate ──
class _StickyFilterDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double height;
  final Color scaffoldBg;
  const _StickyFilterDelegate({required this.child, required this.height, required this.scaffoldBg});

  @override
  double get minExtent => height;
  @override
  double get maxExtent => height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  bool shouldRebuild(covariant _StickyFilterDelegate oldDelegate) => true;
}

// ──  数据模型 ──
enum _PlanType { recurring, oneTime }

class _Plan {
  final int? planId;
  final String name, subtitle;
  final double basePrice;
  final String traffic;
  final IconData icon;
  final List<String> features;
  final _PlanType type;
  final String? description;
  final int? speedLimit;
  final int? deviceLimit;
  final int? resetTrafficMethod;
  final double? monthPrice, quarterPrice, halfYearPrice, yearPrice, onetimePrice;
  _Plan(this.name, this.subtitle, this.basePrice, this.traffic, this.icon, this.features, {
    this.type = _PlanType.recurring,
    this.description,
    this.planId,
    this.speedLimit,
    this.deviceLimit,
    this.resetTrafficMethod,
    this.monthPrice,
    this.quarterPrice,
    this.halfYearPrice,
    this.yearPrice,
    this.onetimePrice,
  });

  List<_Cycle> get availableCycles {
    final cycles = <_Cycle>[];
    if (monthPrice != null && monthPrice! > 0) {
      cycles.add(_Cycle(S.isEn ? 'Monthly' : '月付', 1, 1.0, 'month_price', monthPrice!));
    }
    if (quarterPrice != null && quarterPrice! > 0) {
      cycles.add(_Cycle(S.isEn ? 'Quarterly' : '季付', 3, monthPrice != null && monthPrice! > 0 ? quarterPrice! / (monthPrice! * 3) : 1.0, 'quarter_price', quarterPrice!));
    }
    if (halfYearPrice != null && halfYearPrice! > 0) {
      cycles.add(_Cycle(S.isEn ? 'Semi-Annual' : '半年付', 6, monthPrice != null && monthPrice! > 0 ? halfYearPrice! / (monthPrice! * 6) : 1.0, 'half_year_price', halfYearPrice!));
    }
    if (yearPrice != null && yearPrice! > 0) {
      cycles.add(_Cycle(S.isEn ? 'Annual' : '年付', 12, monthPrice != null && monthPrice! > 0 ? yearPrice! / (monthPrice! * 12) : 1.0, 'year_price', yearPrice!));
    }
    if (onetimePrice != null && onetimePrice! > 0) {
      cycles.add(_Cycle(S.isEn ? 'One-Time' : '一次性', 0, 1.0, 'onetime_price', onetimePrice!));
    }
    return cycles;
  }

  factory _Plan.fromModel(PlanModel m) {
    final transferGB = m.transferEnable;
    final trafficStr = transferGB >= 1024 ? '${(transferGB / 1024).toStringAsFixed(0)} TB' : '${transferGB.toStringAsFixed(0)} GB';
    final lowestPrice = [m.monthPrice, m.quarterPrice, m.halfYearPrice, m.yearPrice, m.onetimePrice]
        .whereType<double>()
        .where((p) => p > 0)
        .fold<double>(double.infinity, (a, b) => a < b ? a : b);
    final hasOnlyOnetime = m.onetimePrice != null && m.onetimePrice! > 0 && (m.monthPrice == null || m.monthPrice! <= 0);
    final feats = <String>[];
    feats.add('$trafficStr ${S.isEn ? "traffic" : "流量"}');
    if (m.deviceLimit != null && m.deviceLimit! > 0) feats.add('${m.deviceLimit} ${S.isEn ? "devices" : "台设备"}');
    if (m.speedLimit != null && m.speedLimit! > 0) feats.add('${m.speedLimit} Mbps');
    return _Plan(
      m.name,
      m.content ?? '',
      lowestPrice.isFinite ? lowestPrice : 0,
      trafficStr,
      hasOnlyOnetime ? Icons.bolt : Icons.diamond_outlined,
      feats,
      type: hasOnlyOnetime ? _PlanType.oneTime : _PlanType.recurring,
      description: m.content,
      planId: m.id,
      speedLimit: m.speedLimit,
      deviceLimit: m.deviceLimit,
      resetTrafficMethod: m.resetTrafficMethod,
      monthPrice: m.monthPrice,
      quarterPrice: m.quarterPrice,
      halfYearPrice: m.halfYearPrice,
      yearPrice: m.yearPrice,
      onetimePrice: m.onetimePrice,
    );
  }
}

class _Cycle {
  final String name;
  final int months;
  final double discount;
  final String period;
  final double totalPrice;
  _Cycle(this.name, this.months, this.discount, this.period, this.totalPrice);
}

class _Payment {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final String? method;
  _Payment(this.id, this.name, this.icon, this.color, {this.method});
}
