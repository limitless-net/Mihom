/// Mihom UI → XBoard SDK 桥接层
/// 
/// 将 Riverpod 状态转换为 UI 层需要的简单数据格式
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_clash/xboard/features/auth/auth.dart';
import 'package:fl_clash/xboard/adapter/state/plan_state.dart';
import 'package:fl_clash/xboard/adapter/state/subscription_state.dart';
import 'package:fl_clash/xboard/adapter/state/user_state.dart';
import 'package:fl_clash/providers/config.dart';

// ═══════════════════════════════════════════════════
//  Auth Bridge — 认证状态桥接
// ═══════════════════════════════════════════════════

/// 是否已登录（从 xboardUserProvider 读取）
final mihomIsAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(xboardUserProvider);
  return authState.isAuthenticated;
});

/// 是否已初始化完成
final mihomIsInitializedProvider = Provider<bool>((ref) {
  final authState = ref.watch(xboardUserProvider);
  return authState.isInitialized;
});

/// 用户邮箱
final mihomUserEmailProvider = Provider<String>((ref) {
  final authState = ref.watch(xboardUserProvider);
  return authState.email ?? '';
});

/// 认证加载状态
final mihomAuthLoadingProvider = Provider<bool>((ref) {
  final authState = ref.watch(xboardUserProvider);
  return authState.isLoading;
});

// ═══════════════════════════════════════════════════
//  VPN Connection Bridge — VPN 连接状态桥接
// ═══════════════════════════════════════════════════

/// VPN 是否已连接
final mihomVpnConnectedProvider = Provider<bool>((ref) {
  final vpnProps = ref.watch(vpnSettingProvider);
  return vpnProps.enable;
});

// ═══════════════════════════════════════════════════
//  Re-exports — 直接复用的 SDK providers
// ═══════════════════════════════════════════════════

// 套餐列表: ref.watch(getPlansProvider)
// 订阅信息: ref.watch(getSubscriptionProvider)
// 用户信息: ref.watch(getUserInfoProvider)
// 认证操作: ref.read(xboardUserProvider.notifier).login(email, password)
// 退出登录: ref.read(xboardUserProvider.notifier).logout()
