import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_xboard_sdk/flutter_xboard_sdk.dart';
import 'package:fl_clash/xboard/adapter/state/plan_state.dart';
import 'package:fl_clash/xboard/adapter/state/order_state.dart';
import 'package:fl_clash/xboard/adapter/initialization/sdk_provider.dart';
import 'package:fl_clash/xboard/features/auth/providers/xboard_user_provider.dart';
import '../../theme/mihom_theme.dart';
import '../../i18n.dart';
import '../../widgets/login_dialog.dart';
import '../../widgets/credential_store.dart';
import '../../widgets/pill_toast.dart';

/// 妗岄潰绔椁愰〉 鈥?瀹藉崱鐗?grid + 璐拱寮圭獥
class DesktopPlansPage extends ConsumerStatefulWidget {
  final MihomTheme theme;
  final bool isGuest;
  final VoidCallback? onLogin;
  final VoidCallback? onPlanPurchased;
  final VoidCallback? onGoHome;
  const DesktopPlansPage({super.key, required this.theme, this.isGuest = false, this.onLogin, this.onPlanPurchased, this.onGoHome});

  @override
  ConsumerState<DesktopPlansPage> createState() => _DesktopPlansPageState();
}

class _DesktopPlansPageState extends ConsumerState<DesktopPlansPage> {
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
  void didUpdateWidget(covariant DesktopPlansPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isGuest != widget.isGuest) {
      // 登录状态变化后重新加载套餐（切换 guest → authenticated API）
      _plansLoading = true;
      _plansError = null;
      _loadPlans();
    }
  }

  Future<void> _loadPlans() async {
    try {
      List<PlanModel> planModels;
      if (widget.isGuest) {
        // 游客模式：使用免认证的 guest API 获取套餐列表
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
          theme: t, plan: plan,
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
          return CustomScrollView(
            slivers: [
              // 椤堕儴闂磋窛
              const SliverToBoxAdapter(child: SizedBox(height: 28)),
              // Title 鈥?璺熺潃婊氬姩
              SliverToBoxAdapter(
                child: Text(S.selectPlan, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: t.textPrimary)),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),

              // 浣欓妯箙 鈥?璺熺潃婊氬姩
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
                      () {
                        final user = ref.watch(userInfoProvider);
                        final balanceYuan = (user?.balanceInCents ?? 0) / 100.0;
                        return Text('\u00a5 ${balanceYuan.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold));
                      }(),
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

              // Filter tabs 鈥?鍚搁《鍥哄畾
              SliverPersistentHeader(
                pinned: true,
                delegate: _StickyFilterDelegate(
                  child: Container(
                    color: t.scaffoldBg,
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


              const SliverToBoxAdapter(child: SizedBox(height: 14)),
              // 濂楅鍗＄墖 Grid (or loading/error)
              if (_plansLoading)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 60),
                    child: Center(child: CircularProgressIndicator(color: t.primary)),
                  ),
                )
              else if (_plansError != null)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 60),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.error_outline, color: t.danger, size: 36),
                          const SizedBox(height: 10),
                          Text(S.isEn ? 'Failed to load plans' : '加载套餐失败',
                            style: TextStyle(color: t.textSecondary, fontSize: 14)),
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
                    ),
                  ),
                )
              else if (_filteredPlans.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 60),
                    child: Center(child: Text(S.isEn ? 'No plans available' : '暂无可用套餐',
                      style: TextStyle(color: t.textHint, fontSize: 14))),
                  ),
                )
              else
                SliverToBoxAdapter(
                  child: Wrap(
                    spacing: 14,
                    runSpacing: 14,
                    children: _filteredPlans.map((plan) {
                      final cardWidth = cols == 1
                          ? w
                          : cols == 2
                              ? (w - 14) / 2
                              : (w - 28) / 3;
                      return SizedBox(
                        width: cardWidth,
                        child: _buildPlanCard(plan),
                      );
                    }).toList(),
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
            ],
          );
        }),
      ),
    );
  }

  /// 从描述中提取 --- 分隔符下方的营销文案部分
  static String _extractMarketingContent(String desc) {
    // 匹配 Markdown 水平分割线: ---, ***, ___ (至少3个)，兼容行首和各种换行
    final re = RegExp(r'(?:^|\n)\s*[-*_]{3,}\s*(?:\n|$)');
    final match = re.firstMatch(desc);
    if (match != null) {
      final after = desc.substring(match.end).trim();
      if (after.isNotEmpty) return after;
    }
    // 没有分隔线或分隔线后无内容，返回空
    return '';
  }

  /// 从描述中提取 --- 分隔符上方的结构化参数部分
  static String _extractStructuredContent(String desc) {
    final re = RegExp(r'(?:^|\n)\s*[-*_]{3,}\s*(?:\n|$)');
    final match = re.firstMatch(desc);
    if (match != null) {
      return desc.substring(0, match.start).trim();
    }
    return desc.trim();
  }

  /// 套餐描述：渲染后台配置的全部内容
  Widget _buildPlanDescription(String desc) {
    if (desc.trim().isEmpty) return const SizedBox.shrink();
    final hasHtml = RegExp(r'<[a-zA-Z][^>]*>').hasMatch(desc);
    if (hasHtml) {
      return HtmlWidget(
        desc,
        textStyle: TextStyle(fontSize: 12, color: t.textSecondary),
      );
    }
    return MarkdownBody(
      data: desc,
      shrinkWrap: true,
      styleSheet: MarkdownStyleSheet(
        p: TextStyle(fontSize: 12, color: t.textSecondary),
        strong: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: t.textPrimary),
        code: TextStyle(fontSize: 11, color: t.primary, backgroundColor: t.primary.withValues(alpha: 0.08)),
        tableHead: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: t.textPrimary),
        tableBody: TextStyle(fontSize: 11, color: t.textSecondary),
        tableBorder: TableBorder.all(color: t.textHint.withValues(alpha: 0.15), width: 0.5),
        tableCellsPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      ),
    );
  }

  /// 从 --- 上方的结构化参数中提取权益（用于弹窗）
  static List<_PlanFeatureItem> _parsePlanFeatures(String desc) {
    final structured = _extractStructuredContent(desc);
    final items = <_PlanFeatureItem>[];
    // 格式1: Markdown 列表行 - emoji **label**：`value`
    final listRe = RegExp(r'-\s*(\S+)\s*\*\*(.+?)\*\*[：:]\s*`?([^`\n]+)`?');
    for (final m in listRe.allMatches(structured)) {
      final emoji = m.group(1)?.trim() ?? '✅';
      final label = m.group(2)?.trim() ?? '';
      final value = m.group(3)?.trim() ?? '';
      if (label.isNotEmpty && value.isNotEmpty) {
        items.add(_PlanFeatureItem(emoji: emoji, label: label, value: value));
      }
    }
    if (items.isNotEmpty) return items;
    // 格式2: Markdown 表格行 | emoji **label** | `value` |
    final tableRowRe = RegExp(r'\|\s*([^\|]*?)\*\*([^\*]+)\*\*[^\|]*?\|\s*`?([^`\|]+)`?\s*\|');
    for (final m in tableRowRe.allMatches(structured)) {
      final emojiPart = m.group(1)?.trim() ?? '';
      final label = m.group(2)?.trim() ?? '';
      final value = m.group(3)?.trim() ?? '';
      if (label.isNotEmpty && value.isNotEmpty) {
        items.add(_PlanFeatureItem(
          emoji: emojiPart.isNotEmpty ? emojiPart : '✅',
          label: label,
          value: value,
        ));
      }
    }
    if (items.isNotEmpty) return items;
    // 回退：提取 HTML <p> 内容
    final pRe = RegExp(r'<p[^>]*>(.*?)</p>', dotAll: true);
    for (final m in pRe.allMatches(structured)) {
      final text = m.group(1)?.replaceAll(RegExp(r'<[^>]+>'), '').trim() ?? '';
      if (text.isNotEmpty) {
        items.add(_PlanFeatureItem(emoji: '✅', label: text, value: ''));
      }
    }
    if (items.isNotEmpty) return items;
    // 最终回退：按行分割
    for (final line in structured.split('\n')) {
      final text = line.replaceAll(RegExp(r'[\*`#\|>-]'), '').replaceAll(RegExp(r'<[^>]+>'), '').trim();
      if (text.length > 2 && !text.startsWith(':')) {
        items.add(_PlanFeatureItem(emoji: '✅', label: text, value: ''));
      }
    }
    return items;
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
              // 澶撮儴锛氬浘鏍?鍚嶇О 宸︼紝浠锋牸 鍙充笂
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
                            Flexible(child: Tooltip(
                              message: plan.name,
                              waitDuration: const Duration(milliseconds: 500),
                              child: Text(plan.name, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: t.textPrimary), overflow: TextOverflow.ellipsis),
                            )),
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
                        Text(plan.traffic, style: TextStyle(fontSize: 11, color: t.textSecondary), overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  // 浠锋牸鍦ㄥ彸涓婅
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
              // 后台配置内容全部显示
              if (plan.description != null && plan.description!.trim().isNotEmpty)
                _buildPlanDescription(plan.description!)
              else
                ...plan.features.take(4).map((f) => Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, size: 13, color: t.success),
                      const SizedBox(width: 4),
                      Flexible(child: Text(f, style: TextStyle(fontSize: 12, color: t.textSecondary), overflow: TextOverflow.ellipsis)),
                    ],
                  ),
                )),
              const SizedBox(height: 6),
              // 璐拱鎸夐挳 搴曢儴灞呬腑
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

// 鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲
//  妗岄潰绔喘涔板脊绐楋紙璁㈠崟 鈫?鏀粯 鈫?鎴愬姛锛?
// 鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲

class _PurchaseDialog extends ConsumerStatefulWidget {
  final MihomTheme theme;
  final _Plan plan;
  final VoidCallback? onPlanPurchased;
  final VoidCallback? onGoHome;
  const _PurchaseDialog({required this.theme, required this.plan, this.onPlanPurchased, this.onGoHome});

  @override
  ConsumerState<_PurchaseDialog> createState() => _PurchaseDialogState();
}

enum _Step { order, paying, success }

class _PurchaseDialogState extends ConsumerState<_PurchaseDialog> with SingleTickerProviderStateMixin {
  MihomTheme get t => widget.theme;
  _Step _step = _Step.order;
  int _selectedCycle = -1;
  int _selectedPayment = -1;
  final _couponCtrl = TextEditingController();
  bool _couponVerified = false;
  CouponModel? _couponData;
  bool _couponExpanded = false;
  bool _priceDetailExpanded = false;
  late AnimationController _loadCtrl;
  
  // Real API state
  String? _tradeNo;
  List<_Payment> _payments = [];
  bool _isCreatingOrder = false;
  String? _orderError;
  String? _orderProgress; // 流程进度提示（清理旧订单等）

  // 余额
  double _userBalance = 0;
  bool _balanceLoading = true;

  List<_Cycle> get _cycles => widget.plan.availableCycles;

  double get _totalPrice {
    if (_selectedCycle < 0 || _selectedCycle >= _cycles.length) return 0;
    return _cycles[_selectedCycle].totalPrice;
  }

  /// 优惠券折扣后的实际应付金额
  double get _effectivePrice {
    final base = _totalPrice;
    if (!_couponVerified || _couponData == null || base <= 0) return base;
    final discount = _calcCouponDiscount(base);
    return double.parse((base - discount).clamp(0, double.infinity).toStringAsFixed(2));
  }

  /// 余额可抵扣金额（基于优惠券折扣后的价格）
  double get _balanceDeduction => _effectivePrice > 0 ? (_userBalance >= _effectivePrice ? _effectivePrice : _userBalance) : 0;

  /// 需要支付的剩余金额
  double get _remainingToPay => (_effectivePrice - _balanceDeduction).clamp(0, double.infinity);

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
    _fetchBalance();
  }

  Future<void> _fetchBalance() async {
    try {
      final sdk = await ref.read(xboardSdkProvider.future);
      final user = await sdk.user.getUserInfo();
      if (!mounted) return;
      setState(() {
        _userBalance = user.balanceInYuan;
        _balanceLoading = false;
      });
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

  Future<void> _verifyCoupon() async {
    HapticFeedback.mediumImpact();
    final code = _couponCtrl.text.trim();
    if (code.isEmpty || widget.plan.planId == null) return;
    try {
      final sdk = await ref.read(xboardSdkProvider.future);
      final coupon = await sdk.order.checkCoupon(code, widget.plan.planId!);
      if (!mounted) return;
      if (coupon != null) {
        setState(() {
          _couponVerified = true;
          _couponData = coupon;
        });
        showPillToast(context, t, S.isEn ? 'Coupon applied!' : '\u4f18\u60e0\u7801\u5df2\u751f\u6548\uff01');
      } else {
        showPillToast(context, t, S.isEn ? 'Invalid coupon' : '\u65e0\u6548\u4f18\u60e0\u7801');
      }
    } catch (e) {
      if (!mounted) return;
      // 显示后端返回的具体错误信息
      final msg = (e is XBoardException)
          ? e.message
          : (S.isEn ? 'Coupon check failed' : '优惠码验证失败');
      showPillToast(context, t, msg);
    }
  }

  void _done() {
    widget.onGoHome?.call();
  }

  // 鈹€鈹€ 灞呬腑寮圭獥锛氶€夋嫨鍛ㄦ湡 鈹€鈹€
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
                ...List.generate(_cycles.length, (i) {
                  final c = _cycles[i];
                  final price = c.totalPrice;
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
                                      Flexible(child: Tooltip(
                                        message: c.name,
                                        waitDuration: const Duration(milliseconds: 500),
                                        child: Text(c.name, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: selected ? t.primary : t.textPrimary), overflow: TextOverflow.ellipsis),
                                      )),
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

  // 鈹€鈹€ 灞呬腑寮圭獥锛氭敮浠樼‘璁わ紙鎶樺彔閫夋嫨鍣?+ 宓屽寮圭獥閫夋嫨鏀粯鏂瑰紡锛夆攢鈹€
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
              final displayPrice = _remainingToPay > 0 ? _remainingToPay.toStringAsFixed(2) : _effectivePrice.toStringAsFixed(2);
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
                    // 鏍囬 + 閲戦
                    Row(
                      children: [
                        Text(S.isEn ? 'Confirm Payment' : '确认支付', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: t.textPrimary)),
                        const Spacer(),
                        if (_balanceDeduction > 0)
                          Padding(
                            padding: const EdgeInsets.only(right: 5),
                            child: Text('\u00a5${_effectivePrice.toStringAsFixed(2)}', style: TextStyle(fontSize: 11, color: t.textHint, decoration: TextDecoration.lineThrough, decorationColor: t.textHint)),
                          ),
                        Text('\u00a5$displayPrice', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: t.primary)),
                      ],
                    ),
                    const SizedBox(height: 14),
                    if (_balanceDeduction > 0) ...[
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: t.success.withValues(alpha: t.isDark ? 0.12 : 0.06),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.account_balance_wallet, size: 14, color: t.success),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                S.isEn
                                    ? 'Balance held: \u00a5${_balanceDeduction.toStringAsFixed(2)} (refundable if canceled)'
                                    : '余额暂扣 \u00a5${_balanceDeduction.toStringAsFixed(2)}（取消订单可退回）',
                                style: TextStyle(fontSize: 11, color: t.success, fontWeight: FontWeight.w500),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    // 鏀粯鏂瑰紡閫夋嫨鍣ㄨ锛堟姌鍙狅紝鐐瑰嚮寮瑰嚭宓屽寮圭獥锛?
                    Text(S.selectPaymentMethod, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: t.textSecondary)),
                    const SizedBox(height: 6),
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          // 宓屽寮圭獥锛氶€夋嫨鏀粯鏂瑰紡
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
                                      ...List.generate(_payments.length, (i) {
                                        final p = _payments[i];
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
                                hasPayment ? _payments[tempSelected].icon : Icons.payment,
                                size: 16,
                                color: hasPayment ? _payments[tempSelected].color : t.textHint,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: hasPayment
                                    ? Text(_payments[tempSelected].name, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: t.textPrimary))
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
                    // 确认支付鎸夐挳
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
                              hasPayment ? '${S.confirmPaymentWithPrice}  ¥$displayPrice' : S.pleaseSelectPayment,
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
        // Real payment flow: checkout the order
        _checkoutOrder(v);
      }
    });
  }

  /// 与 Xboard 前端一致：检测到变更订阅时弹出确认
  Future<bool> _confirmPlanChangeIfNeeded() async {
    final user = ref.read(userInfoProvider);
    if (user == null) return true;
    // 当前没有套餐 或 购买同一套餐（续费）→ 无需提醒
    if (user.planId == null || user.planId == widget.plan.planId) return true;
    // 当前套餐已过期 → 无需提醒
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
            width: 380,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: t.cardBg,
              borderRadius: BorderRadius.circular(18),
              border: t.cardBorder,
              boxShadow: [BoxShadow(color: t.primary.withValues(alpha: 0.12), blurRadius: 24)],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_rounded, size: 24, color: t.primary),
                    const SizedBox(width: 8),
                    Text(
                      S.isEn ? 'Notice' : '注意',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: t.textPrimary),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    S.isEn
                        ? 'Please note that changing the subscription will overwrite the current subscription.'
                        : '请注意，变更订阅会导致当前订阅被覆盖。',
                    style: TextStyle(fontSize: 14, color: t.textSecondary, height: 1.5),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () => Navigator.of(ctx).pop(false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          decoration: BoxDecoration(
                            border: Border.all(color: t.textHint.withValues(alpha: 0.3)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(S.isEn ? 'Cancel' : '取消', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: t.textSecondary)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () => Navigator.of(ctx).pop(true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          decoration: BoxDecoration(
                            color: t.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(S.isEn ? 'Confirm' : '确定', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.white)),
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
    return result == true;
  }

  Future<void> _createOrder() async {
    if (widget.plan.planId == null || _selectedCycle < 0) return;
    setState(() { _isCreatingOrder = true; _orderError = null; _orderProgress = null; });
    try {
      final sdk = await ref.read(xboardSdkProvider.future);
      final cycle = _cycles[_selectedCycle];
      final coupon = _couponVerified ? _couponCtrl.text.trim() : null;

      // 先清理所有未付款的旧订单
      await _cancelPendingOrders(sdk);

      String? tradeNo;
      tradeNo = await sdk.order.createOrder(
        widget.plan.planId!,
        cycle.period,
        couponCode: coupon,
      );

      if (tradeNo == null || !mounted) {
        setState(() { _isCreatingOrder = false; });
        return;
      }

      // Load payment methods for this order
      setState(() => _orderProgress = S.isEn ? 'Loading payment methods...' : '正在加载支付方式...');
      final paymentMethods = await sdk.order.getPaymentMethods(tradeNo);
      if (!mounted) return;

      // 后端在创建订单时已扣除余额，刷新全局用户状态（让"我的"页同步）
      // 但购买对话框内保持 _userBalance 不变，因为它代表"下单前的可用余额"
      ref.read(xboardUserProvider.notifier).refreshSubscriptionInfoAfterPayment();

      setState(() {
        _tradeNo = tradeNo;
        _payments = paymentMethods.map((pm) => _Payment(
          pm.id,
          pm.name,
          _paymentIcon(pm.name),
          _paymentColor(pm.name),
          method: pm.paymentMethod ?? pm.id,
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

  /// 自动取消未付款订单
  Future<void> _cancelPendingOrders(dynamic sdk) async {
    if (!mounted) return;
    setState(() => _orderProgress = S.isEn ? 'Checking pending orders...' : '正在检查未付款订单...');

    final orders = await sdk.order.getOrders(page: 1, pageSize: 50);
    final pending = (orders as List).where((o) => o.status == 0).toList();

    if (pending.isEmpty) return;

    for (int i = 0; i < pending.length; i++) {
      if (!mounted) return;
      setState(() => _orderProgress = S.isEn
          ? 'Canceling old order (${i + 1}/${pending.length})...'
          : '正在取消旧订单 (${i + 1}/${pending.length})...');
      try {
        await sdk.order.cancelOrder(pending[i].tradeNo);
      } catch (_) {
        // 忽略单个取消失败，继续处理其他订单
      }
    }

    if (!mounted) return;
    setState(() => _orderProgress = S.isEn ? 'Creating new order...' : '正在创建订单...');
  }

  /// 计算优惠券折扣金额
  double _calcCouponDiscount(double price) {
    if (_couponData == null) return 0;
    if (_couponData!.type == 1) {
      // 固定金额折扣 (value 单位为分)
      return double.parse(((_couponData!.value ?? 0) / 100.0).toStringAsFixed(2));
    } else if (_couponData!.type == 2) {
      // 百分比折扣 (value 为折扣百分比，如 10 = 10%)
      return double.parse((price * (_couponData!.value ?? 0) / 100.0).toStringAsFixed(2));
    }
    return 0;
  }

  /// 优惠券显示标签
  String _couponLabel() {
    if (_couponData == null) return '';
    if (_couponData!.type == 1) {
      final yuan = ((_couponData!.value ?? 0) / 100.0).toStringAsFixed(0);
      return S.isEn ? '¥$yuan off' : '减¥$yuan';
    } else if (_couponData!.type == 2) {
      final pct = _couponData!.value ?? 0;
      if (S.isEn) return '$pct% off';
      final zhe = (10 - pct / 10.0).toStringAsFixed(1);
      return '${zhe}折';
    }
    return '';
  }

  /// 优惠券验证后的提示文本
  String _couponHint() {
    if (_couponData == null) return '';
    final label = _couponLabel();
    return S.isEn ? 'Coupon: $label applied' : '已享 $label 优惠';
  }

  Future<void> _checkoutOrder(int paymentIdx) async {
    if (_tradeNo == null || paymentIdx >= _payments.length) return;
    try {
      final sdk = await ref.read(xboardSdkProvider.future);
      final payment = _payments[paymentIdx];
      final result = await sdk.order.checkoutOrder(_tradeNo!, payment.method ?? payment.id);
      if (!mounted) return;
      // Handle result
      result.when(
        success: (transactionId, message, extra) {
          HapticFeedback.heavyImpact();
          setState(() => _step = _Step.success);
          widget.onPlanPurchased?.call();
          // Refresh user info after purchase
          ref.read(xboardUserProvider.notifier).refreshSubscriptionInfoAfterPayment();
        },
        redirect: (url, method, headers) {
          // 打开浏览器支付 + 进入等待轮询状态
          if (url != null) {
            launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
          }
          HapticFeedback.mediumImpact();
          setState(() => _step = _Step.paying);
          // 开始轮询订单状态
          _pollOrderStatus();
        },
        failed: (message, errorCode, extra) {
          setState(() { _step = _Step.order; _orderError = message; });
          showPillToast(context, t, message ?? (S.isEn ? 'Payment failed' : '支付失败'));
        },
        canceled: (message) {
          setState(() { _step = _Step.order; });
          showPillToast(context, t, message ?? (S.isEn ? 'Payment canceled' : '支付已取消'));
        },
      );
    } catch (e) {
      if (!mounted) return;
      setState(() { _step = _Step.order; });
      showPillToast(context, t, S.isEn ? 'Payment error' : '支付错误');
    }
  }

  /// 轮询订单状态（3秒间隔，最多60次=3分钟）
  Future<void> _pollOrderStatus() async {
    if (_tradeNo == null) return;
    final sdk = await ref.read(xboardSdkProvider.future);
    for (int i = 0; i < 60; i++) {
      await Future.delayed(const Duration(seconds: 3));
      if (!mounted || _step != _Step.paying) return;
      try {
        final order = await sdk.order.getOrder(_tradeNo!);
        if (order != null && order.status != null && order.status! >= 3) {
          // status 3 = 已完成
          HapticFeedback.heavyImpact();
          setState(() => _step = _Step.success);
          widget.onPlanPurchased?.call();
          ref.read(xboardUserProvider.notifier).refreshSubscriptionInfoAfterPayment();
          return;
        }
      } catch (_) {}
    }
  }

  /// 根据流量智能生成推荐语
  String _smartSubtitle() {
    final p = widget.plan;
    final trafficNum = double.tryParse(p.traffic.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
    final isTB = p.traffic.contains('TB');
    final isEn = S.isEn;

    if (p.type == _PlanType.oneTime) {
      return isEn ? 'One-time • ${p.traffic} total' : '一次性 · ${p.traffic} 总流量';
    }
    if (isTB || trafficNum >= 1000) {
      return isEn ? '${p.traffic}/mo · For power users' : '${p.traffic}/月 · 适合重度用户';
    }
    if (trafficNum >= 300) {
      return isEn ? '${p.traffic}/mo · Recommended for daily use' : '${p.traffic}/月 · 推荐日常使用';
    }
    if (trafficNum >= 100) {
      return isEn ? '${p.traffic}/mo · Great for regular use' : '${p.traffic}/月 · 适合常规使用';
    }
    return isEn ? '${p.traffic}/mo · Ideal for light use' : '${p.traffic}/月 · 适合轻度使用';
  }

  /// 智能营销权益（最多4个，最低档不写流媒体/AI）
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
          // 鈹€鈹€ 鏍囬 + 鍏抽棴
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
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            t.primary.withValues(alpha: t.isDark ? 0.25 : 0.12),
                            t.primary.withValues(alpha: t.isDark ? 0.10 : 0.04),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(_smartSubtitle(), style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: t.primary)),
                    ),
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

          // 鈹€鈹€ 浜у搧浠嬬粛 (选择周期后自动折叠)
          AnimatedCrossFade(
            firstChild: Container(
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
                    children: _smartBenefits().map((b) => Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle, size: 12, color: t.success),
                        const SizedBox(width: 3),
                        Text(b, style: TextStyle(fontSize: 11, color: t.textPrimary)),
                      ],
                    )).toList(),
                  ),
                ],
              ),
            ),
            secondChild: const SizedBox.shrink(),
            crossFadeState: hasCycle ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
          const SizedBox(height: 14),

          // 鈹€鈹€ 閫夋嫨鍛ㄦ湡锛堢偣鍑诲脊灞呬腑寮圭獥锛?
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
                              Text(_cycles[_selectedCycle].name, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: t.textPrimary)),
                              if (_cycles[_selectedCycle].discount < 1.0) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                  decoration: BoxDecoration(color: t.danger.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(3)),
                                  child: Text(
                                    S.isEn
                                      ? '${((1 - _cycles[_selectedCycle].discount) * 100).round()}${S.discountLabel}'
                                      : '${(_cycles[_selectedCycle].discount * 10).toStringAsFixed(1)}${S.discountLabel}',
                                    style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: t.danger)),
                                ),
                              ],
                            ])
                          : Text(S.pleaseSelectCycle, style: TextStyle(fontSize: 13, color: t.textHint)),
                    ),
                    if (hasCycle) Text('\u00a5${_effectivePrice.toStringAsFixed(2)}', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: t.primary)),
                    const SizedBox(width: 4),
                    Icon(Icons.chevron_right, size: 18, color: t.textHint),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // 鈹€鈹€ 优惠鐮侊紙鎶樺彔寮忥級
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
              child: Text(_couponHint(), style: TextStyle(fontSize: 11, color: t.success, fontWeight: FontWeight.w500)),
            ),
          ],
          const SizedBox(height: 14),

          // 鈹€鈹€ 浠锋牸鏄庣粏
          if (hasCycle) ...[
            () {
              final c = _cycles[_selectedCycle];
              final originalPrice = c.months > 0 ? widget.plan.basePrice * c.months : c.totalPrice;
              final discountedPrice = c.totalPrice;
              final cycleDiscount = double.parse((originalPrice - discountedPrice).clamp(0, double.infinity).toStringAsFixed(1));
              final couponDiscount = _couponVerified ? _calcCouponDiscount(discountedPrice) : 0.0;
              final hasDiscount = cycleDiscount > 0 || _couponVerified || couponText.isNotEmpty;
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: t.isDark ? const Color(0xFF1E2140) : const Color(0xFFF5F7FA),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    // 鈹€鈹€ 搴斾粯閲戦锛堝缁堝彲瑙侊級
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
                          Text('${_effectivePrice.toStringAsFixed(2)}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: t.primary)),
                        ],
                      ),
                    ),
                    // 鈹€鈹€ 浠锋牸鏄庣粏锛堟姌鍙犲尯鍩燂級
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
                          if (_couponVerified) _priceRow('${S.couponLabel} (${_couponLabel()})', '-\u00a5$couponDiscount', t.textSecondary, t.danger),
                          if (couponText.isNotEmpty && !_couponVerified) _priceRow(S.couponLabel, S.pendingVerify, t.textSecondary, t.warning),
                        ],
                      ),
                      crossFadeState: _priceDetailExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                      duration: const Duration(milliseconds: 200),
                    ),
                    // 余额暂扣信息
                    if (!_balanceLoading && _userBalance > 0) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Divider(height: 1, color: t.textHint.withValues(alpha: 0.15)),
                      ),
                      _priceRow(
                        S.isEn ? 'Account Balance' : '账户余额',
                        '¥${_userBalance.toStringAsFixed(2)}',
                        t.textSecondary,
                        t.success,
                      ),
                      _priceRow(
                        S.isEn ? 'Balance Hold' : '余额暂扣',
                        '-¥${_balanceDeduction.toStringAsFixed(2)}',
                        t.textSecondary,
                        t.danger,
                      ),
                      if (_remainingToPay > 0)
                        _priceRow(
                          S.isEn ? 'Remaining to Pay' : '还需支付',
                          '¥${_remainingToPay.toStringAsFixed(2)}',
                          t.textSecondary,
                          t.primary,
                          bold: true,
                        ),
                      if (_remainingToPay <= 0)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Row(
                            children: [
                              Icon(Icons.check_circle, size: 13, color: t.success),
                              const SizedBox(width: 4),
                              Text(
                                S.isEn ? 'Balance covers full amount' : '余额足够，可直接支付',
                                style: TextStyle(fontSize: 11, color: t.success, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ],
                ),
              );
            }(),
            const SizedBox(height: 14),
          ],

          // 鈹€鈹€ 绔嬪嵆璐拱 鈫?鏈€夊懆鏈熻嚜鍔ㄥ脊鍑哄懆鏈熼€夋嫨锛屼紭鎯犵爜鏈牳閿€鎻愰啋锛屽凡閫夊垯寮规敮浠樻柟寮?
          if (_isCreatingOrder)
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: BoxDecoration(
                  color: t.isDark ? const Color(0xFF1E2140) : const Color(0xFFF5F7FA),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: t.primary)),
                    if (_orderProgress != null) ...[
                      const SizedBox(width: 10),
                      Text(_orderProgress!, style: TextStyle(fontSize: 12, color: t.textSecondary)),
                    ],
                  ],
                ),
              ),
            )
          else if (_orderError != null)
            Column(
              children: [
                Text(_orderError!, style: TextStyle(fontSize: 12, color: t.danger)),
                const SizedBox(height: 6),
                _actionButton(S.isEn ? 'Retry' : '\u91cd\u8bd5', () async {
                  await _createOrder();
                  if (_tradeNo != null && mounted) _showPaymentDialog();
                }),
              ],
            )
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
                if (_selectedCycle < 0) {
                  _showCyclePicker();
                  return;
                }
                final coupon = _couponCtrl.text.trim();
                if (coupon.isNotEmpty && !_couponVerified) {
                  showPillToast(context, t, S.verifyCouponFirst);
                  return;
                }
                if (_tradeNo == null) {
                  // 与 Xboard 前端一致：变更订阅前确认
                  final confirmed = await _confirmPlanChangeIfNeeded();
                  if (!confirmed || !mounted) return;
                  await _createOrder();
                  // 如果后端 plan_change_enable=0 会返回错误，_createOrder 中已处理
                  if (_tradeNo == null || !mounted) return;
                }
                // 免费订单（优惠码全额抵扣）或余额足够，直接支付
                if (_effectivePrice <= 0 || (_remainingToPay <= 0 && _userBalance > 0)) {
                  setState(() => _step = _Step.paying);
                  try {
                    final sdk = await ref.read(xboardSdkProvider.future);
                    final result = await sdk.order.checkoutOrder(_tradeNo!, 'balance');
                    if (!mounted) return;
                    result.when(
                      success: (transactionId, message, extra) {
                        HapticFeedback.heavyImpact();
                        setState(() => _step = _Step.success);
                        widget.onPlanPurchased?.call();
                        ref.read(xboardUserProvider.notifier).refreshSubscriptionInfoAfterPayment();
                      },
                      redirect: (url, method, headers) {
                        HapticFeedback.heavyImpact();
                        setState(() => _step = _Step.success);
                        widget.onPlanPurchased?.call();
                        ref.read(xboardUserProvider.notifier).refreshSubscriptionInfoAfterPayment();
                      },
                      failed: (message, errorCode, extra) {
                        setState(() { _step = _Step.order; _orderError = message; });
                        showPillToast(context, t, message ?? (S.isEn ? 'Balance payment failed' : '余额支付失败'));
                        // 余额支付失败，回退到选择其他支付方式
                        _showPaymentDialog();
                      },
                      canceled: (message) {
                        setState(() => _step = _Step.order);
                      },
                    );
                  } catch (e) {
                    if (!mounted) return;
                    setState(() { _step = _Step.order; });
                    showPillToast(context, t, S.isEn ? 'Balance payment failed, please select another method' : '余额支付失败，请选择其他方式');
                    _showPaymentDialog();
                  }
                  return;
                }
                _showPaymentDialog();
              },
            ),
        ],
      ),
    );
  }

  // 鈹€鈹€ 鏀粯涓?鈹€鈹€
  Widget _buildPayingStep() {
    final paymentName = (_selectedPayment >= 0 && _selectedPayment < _payments.length)
        ? _payments[_selectedPayment].name
        : (S.isEn ? 'payment app' : '支付应用');
    final displayAmount = _remainingToPay > 0 ? '\u00a5${_remainingToPay.toStringAsFixed(2)}' : '\u00a5${_effectivePrice.toStringAsFixed(2)}';
    return Padding(
      key: const ValueKey('paying'),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
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
          Text(S.isEn ? 'Complete payment in $paymentName' : '请在${paymentName}中完成支付',
            style: TextStyle(fontSize: 13, color: t.textSecondary)),
          const SizedBox(height: 8),
          Text(displayAmount, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: t.primary)),
          if (_balanceDeduction > 0) ...[
            const SizedBox(height: 4),
            Text(
              S.isEn ? 'Balance held: \u00a5${_balanceDeduction.toStringAsFixed(2)} (refundable if canceled)' : '余额暂扣 \u00a5${_balanceDeduction.toStringAsFixed(2)}（取消订单可退回）',
              style: TextStyle(fontSize: 11, color: t.success),
            ),
          ],
          const SizedBox(height: 20),
          // 我已支付按钮
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
                showPillToast(context, t, S.isEn ? 'Payment not confirmed yet, please wait...' : '暂未确认到付款，请稍候...');
              }
            } catch (_) {
              showPillToast(context, t, S.isEn ? 'Check failed, retrying...' : '查询失败，请稍后重试');
            }
          }),
          const SizedBox(height: 8),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () => setState(() => _step = _Step.order),
              child: Text(S.isEn ? 'Cancel' : '取消', style: TextStyle(fontSize: 12, color: t.textHint)),
            ),
          ),
        ],
      ),
    );
  }

  bool _detailsExpanded = false;

  // 鈹€鈹€ 璐拱鎴愬姛 鈹€鈹€
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
              Text('${widget.plan.name}${_selectedCycle >= 0 && _selectedCycle < _cycles.length ? ' \u00b7 ${_cycles[_selectedCycle].name}' : ''}', style: TextStyle(fontSize: 12, color: t.textSecondary)),
              const SizedBox(height: 2),
              Text('${S.paid} \u00a5${_effectivePrice.toStringAsFixed(2)}', style: TextStyle(fontSize: 12, color: t.textHint)),
              const SizedBox(height: 14),
              // 鍙姌鍙犺鍗曡鎯?
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
                      if (_selectedCycle >= 0 && _selectedCycle < _cycles.length)
                        _summaryRow(S.cycleLabel, _cycles[_selectedCycle].name),
                      _summaryRow(S.trafficLabel, '${widget.plan.traffic}${S.perMonth}'),
                      _summaryRow(S.paymentMethod,
                        (_selectedPayment >= 0 && _selectedPayment < _payments.length)
                            ? _payments[_selectedPayment].name
                            : (S.isEn ? 'Balance' : '余额支付')),
                      if (_couponVerified) _summaryRow(S.couponLabel, _couponLabel()),
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

  Widget _priceRow(String label, String value, Color labelColor, Color valueColor, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: labelColor, fontWeight: bold ? FontWeight.w600 : FontWeight.normal)),
          Text(value, style: TextStyle(fontSize: 12, fontWeight: bold ? FontWeight.bold : FontWeight.w500, color: valueColor)),
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

// 鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲
//  鐙珛灞呬腑寮圭獥锛氶€夋嫨鏀粯鏂瑰紡 + 确认支付
// 鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲



// 鈹€鈹€ 鍚搁《绛涢€夋爮 Delegate 鈹€鈹€
class _StickyFilterDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  _StickyFilterDelegate({required this.child});

  @override
  double get minExtent => 38;
  @override
  double get maxExtent => 38;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) =>
      ClipRect(child: child);

  @override
  bool shouldRebuild(covariant _StickyFilterDelegate oldDelegate) => true;
}

// 鈹€鈹€ 鏁版嵁妯″瀷 鈹€鈹€
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

  /// Build available cycles from real plan prices
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
    final transferGB = m.transferEnable; // API 返回的 plan.transfer_enable 已经是 GB
    final trafficStr = transferGB >= 1024 ? '${(transferGB / 1024).toStringAsFixed(0)} TB' : '${transferGB.toStringAsFixed(0)} GB';
    final lowestPrice = [m.monthPrice, m.quarterPrice, m.halfYearPrice, m.yearPrice, m.onetimePrice]
        .whereType<double>()
        .where((p) => p > 0)
        .fold<double>(double.infinity, (a, b) => a < b ? a : b);
    final hasOnlyOnetime = m.onetimePrice != null && m.onetimePrice! > 0 && (m.monthPrice == null || m.monthPrice! <= 0);
    final feats = <String>[];
    feats.add('$trafficStr ${S.isEn ? "traffic" : "流量"}');
    if (m.deviceLimit != null && m.deviceLimit! > 0) {
      feats.add('${m.deviceLimit} ${S.isEn ? "devices" : "台设备"}');
    }
    if (m.speedLimit != null && m.speedLimit! > 0) {
      feats.add('${m.speedLimit} Mbps');
    }
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
  final String period; // API period string
  final double totalPrice; // Real total price
  _Cycle(this.name, this.months, this.discount, this.period, this.totalPrice);
}

class _PlanFeatureItem {
  final String emoji;
  final String label;
  final String value;
  _PlanFeatureItem({required this.emoji, required this.label, required this.value});
}

class _Payment {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final String? method;
  _Payment(this.id, this.name, this.icon, this.color, {this.method});
}
