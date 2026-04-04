import 'package:fl_clash/xboard/features/subscription/pages/xboard_home_page.dart';
import 'package:fl_clash/xboard/features/subscription/pages/subscription_page.dart';
import 'package:fl_clash/xboard/features/payment/pages/plans.dart';
import 'package:fl_clash/xboard/features/payment/pages/plan_purchase_page.dart';
import 'package:fl_clash/xboard/features/payment/pages/payment_gateway_page.dart';
import 'package:fl_clash/xboard/features/online_support/pages/online_support_page.dart';
import 'package:fl_clash/xboard/features/invite/pages/invite_page.dart';
import 'package:fl_clash/xboard/features/auth/pages/login_page.dart';
import 'package:fl_clash/xboard/features/initialization/initialization.dart';
import 'package:fl_clash/xboard/domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'shell_layout.dart';

/// XBoard 路由定义
/// 使用 go_router 实现类型安全的声明式路由

// 路由列表
final List<RouteBase> routes = [
    // StatefulShellRoute - 包含侧边栏的主框架，保持各分支状态
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return AdaptiveShellLayout(child: navigationShell);
      },
      branches: [
        // 首页分支
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/',
              name: 'home',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: XBoardHomePage(),
              ),
            ),
          ],
        ),
        
        // 套餐列表分支
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/plans',
              name: 'plans',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: PlansView(),
              ),
            ),
          ],
        ),
        
        // 在线客服分支
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/support',
              name: 'support',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: OnlineSupportPage(),
              ),
            ),
          ],
        ),
        
        // 邀请页面分支
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/invite',
              name: 'invite',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: InvitePage(),
              ),
            ),
          ],
        ),
      ],
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
    
    // 登录页面
    GoRoute(
      path: '/login',
      name: 'login',
      pageBuilder: (context, state) => const MaterialPage(
        child: LoginPage(),
      ),
    ),
    
    // 加载页面（带初始化失败提示）
    GoRoute(
      path: '/loading',
      name: 'loading',
      pageBuilder: (context, state) => const MaterialPage(
        child: _InitLoadingPage(),
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

/// 加载页面：监听初始化状态，失败时展示错误信息和重试按钮
class _InitLoadingPage extends ConsumerWidget {
  const _InitLoadingPage();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final initState = ref.watch(initializationProvider);
    final colorScheme = Theme.of(context).colorScheme;

    if (initState.isFailed) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.cloud_off, size: 64, color: colorScheme.error),
                const SizedBox(height: 16),
                Text(
                  '服务初始化失败',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  initState.errorMessage ?? '未知错误',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: colorScheme.onSurfaceVariant),
                ),
                if (initState.currentStepDescription != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    initState.currentStepDescription!,
                    style: TextStyle(fontSize: 12, color: colorScheme.outline),
                  ),
                ],
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () {
                    ref.read(initializationProvider.notifier).refresh();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('重试'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // 正在加载
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            if (initState.currentStepDescription != null) ...[
              const SizedBox(height: 16),
              Text(
                initState.currentStepDescription!,
                style: TextStyle(color: colorScheme.onSurfaceVariant),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

