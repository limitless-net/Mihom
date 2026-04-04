// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../payment_state.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 支付状态管理
/// 获取支付方式列表

@ProviderFor(getPaymentMethods)
const getPaymentMethodsProvider = GetPaymentMethodsProvider._();

/// 支付状态管理
/// 获取支付方式列表

final class GetPaymentMethodsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<PaymentMethodModel>>,
          List<PaymentMethodModel>,
          FutureOr<List<PaymentMethodModel>>
        >
    with
        $FutureModifier<List<PaymentMethodModel>>,
        $FutureProvider<List<PaymentMethodModel>> {
  /// 支付状态管理
  /// 获取支付方式列表
  const GetPaymentMethodsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getPaymentMethodsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getPaymentMethodsHash();

  @$internal
  @override
  $FutureProviderElement<List<PaymentMethodModel>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<PaymentMethodModel>> create(Ref ref) {
    return getPaymentMethods(ref);
  }
}

String _$getPaymentMethodsHash() => r'4041b697796dfd399ba4b6ff28f467cf9ef5aeac';
