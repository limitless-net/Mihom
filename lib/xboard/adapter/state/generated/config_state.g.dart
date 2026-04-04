// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../config_state.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 配置状态管理
/// 获取配置

@ProviderFor(getConfig)
const getConfigProvider = GetConfigProvider._();

/// 配置状态管理
/// 获取配置

final class GetConfigProvider
    extends
        $FunctionalProvider<
          AsyncValue<ConfigModel>,
          ConfigModel,
          FutureOr<ConfigModel>
        >
    with $FutureModifier<ConfigModel>, $FutureProvider<ConfigModel> {
  /// 配置状态管理
  /// 获取配置
  const GetConfigProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getConfigProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getConfigHash();

  @$internal
  @override
  $FutureProviderElement<ConfigModel> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ConfigModel> create(Ref ref) {
    return getConfig(ref);
  }
}

String _$getConfigHash() => r'2aec82194052903c04d301e756524c0f47652eb3';
