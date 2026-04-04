// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../ticket_state.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 工单状态管理
/// 获取工单列表

@ProviderFor(getTickets)
const getTicketsProvider = GetTicketsProvider._();

/// 工单状态管理
/// 获取工单列表

final class GetTicketsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<TicketModel>>,
          List<TicketModel>,
          FutureOr<List<TicketModel>>
        >
    with
        $FutureModifier<List<TicketModel>>,
        $FutureProvider<List<TicketModel>> {
  /// 工单状态管理
  /// 获取工单列表
  const GetTicketsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getTicketsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getTicketsHash();

  @$internal
  @override
  $FutureProviderElement<List<TicketModel>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<TicketModel>> create(Ref ref) {
    return getTickets(ref);
  }
}

String _$getTicketsHash() => r'bd1393823d8a9f11d9f583b90549dba1016912e9';

/// 获取单个工单

@ProviderFor(getTicket)
const getTicketProvider = GetTicketFamily._();

/// 获取单个工单

final class GetTicketProvider
    extends
        $FunctionalProvider<
          AsyncValue<TicketDetailModel>,
          TicketDetailModel,
          FutureOr<TicketDetailModel>
        >
    with
        $FutureModifier<TicketDetailModel>,
        $FutureProvider<TicketDetailModel> {
  /// 获取单个工单
  const GetTicketProvider._({
    required GetTicketFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'getTicketProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$getTicketHash();

  @override
  String toString() {
    return r'getTicketProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<TicketDetailModel> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<TicketDetailModel> create(Ref ref) {
    final argument = this.argument as int;
    return getTicket(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is GetTicketProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$getTicketHash() => r'dec5bf7896fd9c8d10bd3a39d6b6e099dc19fe3a';

/// 获取单个工单

final class GetTicketFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<TicketDetailModel>, int> {
  const GetTicketFamily._()
    : super(
        retry: null,
        name: r'getTicketProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 获取单个工单

  GetTicketProvider call(int id) =>
      GetTicketProvider._(argument: id, from: this);

  @override
  String toString() => r'getTicketProvider';
}
