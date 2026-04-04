// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../plan_state.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 套餐状态管理
/// 获取套餐列表

@ProviderFor(getPlans)
const getPlansProvider = GetPlansProvider._();

/// 套餐状态管理
/// 获取套餐列表

final class GetPlansProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<PlanModel>>,
          List<PlanModel>,
          FutureOr<List<PlanModel>>
        >
    with $FutureModifier<List<PlanModel>>, $FutureProvider<List<PlanModel>> {
  /// 套餐状态管理
  /// 获取套餐列表
  const GetPlansProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getPlansProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getPlansHash();

  @$internal
  @override
  $FutureProviderElement<List<PlanModel>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<PlanModel>> create(Ref ref) {
    return getPlans(ref);
  }
}

String _$getPlansHash() => r'fa708ce102b2591f31f294a416a97ecc19f2ab6d';

/// 获取单个套餐

@ProviderFor(getPlan)
const getPlanProvider = GetPlanFamily._();

/// 获取单个套餐

final class GetPlanProvider
    extends
        $FunctionalProvider<
          AsyncValue<PlanModel?>,
          PlanModel?,
          FutureOr<PlanModel?>
        >
    with $FutureModifier<PlanModel?>, $FutureProvider<PlanModel?> {
  /// 获取单个套餐
  const GetPlanProvider._({
    required GetPlanFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'getPlanProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$getPlanHash();

  @override
  String toString() {
    return r'getPlanProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<PlanModel?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<PlanModel?> create(Ref ref) {
    final argument = this.argument as int;
    return getPlan(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is GetPlanProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$getPlanHash() => r'8b839686c467cf4fea1a6a75b0370d84a8166105';

/// 获取单个套餐

final class GetPlanFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<PlanModel?>, int> {
  const GetPlanFamily._()
    : super(
        retry: null,
        name: r'getPlanProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 获取单个套餐

  GetPlanProvider call(int id) => GetPlanProvider._(argument: id, from: this);

  @override
  String toString() => r'getPlanProvider';
}
