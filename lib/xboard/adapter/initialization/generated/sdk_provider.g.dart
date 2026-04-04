// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../sdk_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// XBoard SDK Provider
///
/// 负责SDK的初始化和生命周期管理
/// - 等待 InitializationProvider 完成域名检查
/// - 使用已缓存的域名竞速结果
/// - 自动加载HTTP配置
/// - 缓存SDK实例
///
/// 注意：不要直接调用此 Provider，应该通过 InitializationProvider.initialize() 触发初始化

@ProviderFor(xboardSdk)
const xboardSdkProvider = XboardSdkProvider._();

/// XBoard SDK Provider
///
/// 负责SDK的初始化和生命周期管理
/// - 等待 InitializationProvider 完成域名检查
/// - 使用已缓存的域名竞速结果
/// - 自动加载HTTP配置
/// - 缓存SDK实例
///
/// 注意：不要直接调用此 Provider，应该通过 InitializationProvider.initialize() 触发初始化

final class XboardSdkProvider
    extends
        $FunctionalProvider<
          AsyncValue<XBoardSDK>,
          XBoardSDK,
          FutureOr<XBoardSDK>
        >
    with $FutureModifier<XBoardSDK>, $FutureProvider<XBoardSDK> {
  /// XBoard SDK Provider
  ///
  /// 负责SDK的初始化和生命周期管理
  /// - 等待 InitializationProvider 完成域名检查
  /// - 使用已缓存的域名竞速结果
  /// - 自动加载HTTP配置
  /// - 缓存SDK实例
  ///
  /// 注意：不要直接调用此 Provider，应该通过 InitializationProvider.initialize() 触发初始化
  const XboardSdkProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'xboardSdkProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$xboardSdkHash();

  @$internal
  @override
  $FutureProviderElement<XBoardSDK> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<XBoardSDK> create(Ref ref) {
    return xboardSdk(ref);
  }
}

String _$xboardSdkHash() => r'f2337447d3abfce16c44be03fb56a4b9c0056933';
