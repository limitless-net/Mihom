
import 'package:fl_clash/xboard/features/subscription/pages/xboard_home_page.dart';
import 'package:fl_clash/xboard/features/subscription/pages/subscription_page.dart';
import 'package:fl_clash/xboard/features/payment/pages/plans.dart';
import 'package:fl_clash/xboard/features/payment/pages/plan_purchase_page.dart';
import 'package:fl_clash/xboard/features/payment/pages/payment_gateway_page.dart';
import 'package:fl_clash/xboard/features/online_support/pages/online_support_page.dart';
import 'package:fl_clash/xboard/features/invite/pages/invite_page.dart';
import 'package:fl_clash/xboard/domain/domain.dart';
import 'package:fl_clash/mihom/shell/mihom_shell.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// XBoard 路由定义
/// 使用 go_router 实现类型安全的声明式路由

// 路由列表
final List<RouteBase> routes = [
    // Mihom 自定义 UI Shell — 替换原有 StatefulShellRoute
    GoRoute(
      path: '/',
      name: 'home',
      pageBuilder: (context, state) => const NoTransitionPage(
        child: MihomShell(),
      ),
    ),
    
    // 套餐购买页面（全屏，不在 Shell 内）
    GoRoute(
      path: '/plans/purchase',
      name: 'plan_purchase',
      pageBuilder: (context, state) {
        final plan = state.extra as DomainPlan;
        return MaterialPage(
          child: PlanPurchasePage(plan: plan),
        );
      },
    ),
    
    // 支付网关页面
    GoRoute(
      path: '/payment/gateway',
      name: 'payment_gateway',
      pageBuilder: (context, state) {
        final params = state.extra as Map<String, dynamic>?;
        return MaterialPage(
          child: PaymentGatewayPage(
            paymentUrl: params?['paymentUrl'] as String? ?? '',
            tradeNo: params?['tradeNo'] as String? ?? '',
          ),
        );
      },
    ),
    
    // 订阅详情页面
    GoRoute(
      path: '/subscription',
      name: 'subscription',
      pageBuilder: (context, state) => const MaterialPage(
        child: SubscriptionPage(),
      ),
    ),
];

/// 不带过渡动画的 Page
class NoTransitionPage<T> extends Page<T> {
  const NoTransitionPage({
    required this.child,
    super.key,
    super.name,
  });

  final Widget child;

  @override
  Route<T> createRoute(BuildContext context) {
    return PageRouteBuilder<T>(
      settings: this,
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionDuration: Duration.zero,
      reverseTransitionDuration: Duration.zero,
    );
  }
}

