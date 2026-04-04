// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../payment_method.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DomainPaymentMethod {

/// 支付方式 ID
 int get id;/// 支付方式名称
 String get name;/// 图标 URL
 String? get iconUrl;/// 手续费百分比（0-100）
 double get feePercentage;/// 是否可用
 bool get isAvailable;/// 描述
 String? get description;/// 最小金额（元）
 double? get minAmount;/// 最大金额（元）
 double? get maxAmount;/// 配置信息
 Map<String, dynamic> get config;/// 元数据
 Map<String, dynamic> get metadata;
/// Create a copy of DomainPaymentMethod
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DomainPaymentMethodCopyWith<DomainPaymentMethod> get copyWith => _$DomainPaymentMethodCopyWithImpl<DomainPaymentMethod>(this as DomainPaymentMethod, _$identity);

  /// Serializes this DomainPaymentMethod to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DomainPaymentMethod&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.iconUrl, iconUrl) || other.iconUrl == iconUrl)&&(identical(other.feePercentage, feePercentage) || other.feePercentage == feePercentage)&&(identical(other.isAvailable, isAvailable) || other.isAvailable == isAvailable)&&(identical(other.description, description) || other.description == description)&&(identical(other.minAmount, minAmount) || other.minAmount == minAmount)&&(identical(other.maxAmount, maxAmount) || other.maxAmount == maxAmount)&&const DeepCollectionEquality().equals(other.config, config)&&const DeepCollectionEquality().equals(other.metadata, metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,iconUrl,feePercentage,isAvailable,description,minAmount,maxAmount,const DeepCollectionEquality().hash(config),const DeepCollectionEquality().hash(metadata));

@override
String toString() {
  return 'DomainPaymentMethod(id: $id, name: $name, iconUrl: $iconUrl, feePercentage: $feePercentage, isAvailable: $isAvailable, description: $description, minAmount: $minAmount, maxAmount: $maxAmount, config: $config, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class $DomainPaymentMethodCopyWith<$Res>  {
  factory $DomainPaymentMethodCopyWith(DomainPaymentMethod value, $Res Function(DomainPaymentMethod) _then) = _$DomainPaymentMethodCopyWithImpl;
@useResult
$Res call({
 int id, String name, String? iconUrl, double feePercentage, bool isAvailable, String? description, double? minAmount, double? maxAmount, Map<String, dynamic> config, Map<String, dynamic> metadata
});




}
/// @nodoc
class _$DomainPaymentMethodCopyWithImpl<$Res>
    implements $DomainPaymentMethodCopyWith<$Res> {
  _$DomainPaymentMethodCopyWithImpl(this._self, this._then);

  final DomainPaymentMethod _self;
  final $Res Function(DomainPaymentMethod) _then;

/// Create a copy of DomainPaymentMethod
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? iconUrl = freezed,Object? feePercentage = null,Object? isAvailable = null,Object? description = freezed,Object? minAmount = freezed,Object? maxAmount = freezed,Object? config = null,Object? metadata = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,iconUrl: freezed == iconUrl ? _self.iconUrl : iconUrl // ignore: cast_nullable_to_non_nullable
as String?,feePercentage: null == feePercentage ? _self.feePercentage : feePercentage // ignore: cast_nullable_to_non_nullable
as double,isAvailable: null == isAvailable ? _self.isAvailable : isAvailable // ignore: cast_nullable_to_non_nullable
as bool,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,minAmount: freezed == minAmount ? _self.minAmount : minAmount // ignore: cast_nullable_to_non_nullable
as double?,maxAmount: freezed == maxAmount ? _self.maxAmount : maxAmount // ignore: cast_nullable_to_non_nullable
as double?,config: null == config ? _self.config : config // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,metadata: null == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}

}


/// Adds pattern-matching-related methods to [DomainPaymentMethod].
extension DomainPaymentMethodPatterns on DomainPaymentMethod {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DomainPaymentMethod value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DomainPaymentMethod() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DomainPaymentMethod value)  $default,){
final _that = this;
switch (_that) {
case _DomainPaymentMethod():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DomainPaymentMethod value)?  $default,){
final _that = this;
switch (_that) {
case _DomainPaymentMethod() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String name,  String? iconUrl,  double feePercentage,  bool isAvailable,  String? description,  double? minAmount,  double? maxAmount,  Map<String, dynamic> config,  Map<String, dynamic> metadata)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DomainPaymentMethod() when $default != null:
return $default(_that.id,_that.name,_that.iconUrl,_that.feePercentage,_that.isAvailable,_that.description,_that.minAmount,_that.maxAmount,_that.config,_that.metadata);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String name,  String? iconUrl,  double feePercentage,  bool isAvailable,  String? description,  double? minAmount,  double? maxAmount,  Map<String, dynamic> config,  Map<String, dynamic> metadata)  $default,) {final _that = this;
switch (_that) {
case _DomainPaymentMethod():
return $default(_that.id,_that.name,_that.iconUrl,_that.feePercentage,_that.isAvailable,_that.description,_that.minAmount,_that.maxAmount,_that.config,_that.metadata);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String name,  String? iconUrl,  double feePercentage,  bool isAvailable,  String? description,  double? minAmount,  double? maxAmount,  Map<String, dynamic> config,  Map<String, dynamic> metadata)?  $default,) {final _that = this;
switch (_that) {
case _DomainPaymentMethod() when $default != null:
return $default(_that.id,_that.name,_that.iconUrl,_that.feePercentage,_that.isAvailable,_that.description,_that.minAmount,_that.maxAmount,_that.config,_that.metadata);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DomainPaymentMethod extends DomainPaymentMethod {
  const _DomainPaymentMethod({required this.id, required this.name, this.iconUrl, this.feePercentage = 0.0, this.isAvailable = true, this.description, this.minAmount, this.maxAmount, final  Map<String, dynamic> config = const {}, final  Map<String, dynamic> metadata = const {}}): _config = config,_metadata = metadata,super._();
  factory _DomainPaymentMethod.fromJson(Map<String, dynamic> json) => _$DomainPaymentMethodFromJson(json);

/// 支付方式 ID
@override final  int id;
/// 支付方式名称
@override final  String name;
/// 图标 URL
@override final  String? iconUrl;
/// 手续费百分比（0-100）
@override@JsonKey() final  double feePercentage;
/// 是否可用
@override@JsonKey() final  bool isAvailable;
/// 描述
@override final  String? description;
/// 最小金额（元）
@override final  double? minAmount;
/// 最大金额（元）
@override final  double? maxAmount;
/// 配置信息
 final  Map<String, dynamic> _config;
/// 配置信息
@override@JsonKey() Map<String, dynamic> get config {
  if (_config is EqualUnmodifiableMapView) return _config;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_config);
}

/// 元数据
 final  Map<String, dynamic> _metadata;
/// 元数据
@override@JsonKey() Map<String, dynamic> get metadata {
  if (_metadata is EqualUnmodifiableMapView) return _metadata;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_metadata);
}


/// Create a copy of DomainPaymentMethod
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DomainPaymentMethodCopyWith<_DomainPaymentMethod> get copyWith => __$DomainPaymentMethodCopyWithImpl<_DomainPaymentMethod>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DomainPaymentMethodToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DomainPaymentMethod&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.iconUrl, iconUrl) || other.iconUrl == iconUrl)&&(identical(other.feePercentage, feePercentage) || other.feePercentage == feePercentage)&&(identical(other.isAvailable, isAvailable) || other.isAvailable == isAvailable)&&(identical(other.description, description) || other.description == description)&&(identical(other.minAmount, minAmount) || other.minAmount == minAmount)&&(identical(other.maxAmount, maxAmount) || other.maxAmount == maxAmount)&&const DeepCollectionEquality().equals(other._config, _config)&&const DeepCollectionEquality().equals(other._metadata, _metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,iconUrl,feePercentage,isAvailable,description,minAmount,maxAmount,const DeepCollectionEquality().hash(_config),const DeepCollectionEquality().hash(_metadata));

@override
String toString() {
  return 'DomainPaymentMethod(id: $id, name: $name, iconUrl: $iconUrl, feePercentage: $feePercentage, isAvailable: $isAvailable, description: $description, minAmount: $minAmount, maxAmount: $maxAmount, config: $config, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class _$DomainPaymentMethodCopyWith<$Res> implements $DomainPaymentMethodCopyWith<$Res> {
  factory _$DomainPaymentMethodCopyWith(_DomainPaymentMethod value, $Res Function(_DomainPaymentMethod) _then) = __$DomainPaymentMethodCopyWithImpl;
@override @useResult
$Res call({
 int id, String name, String? iconUrl, double feePercentage, bool isAvailable, String? description, double? minAmount, double? maxAmount, Map<String, dynamic> config, Map<String, dynamic> metadata
});




}
/// @nodoc
class __$DomainPaymentMethodCopyWithImpl<$Res>
    implements _$DomainPaymentMethodCopyWith<$Res> {
  __$DomainPaymentMethodCopyWithImpl(this._self, this._then);

  final _DomainPaymentMethod _self;
  final $Res Function(_DomainPaymentMethod) _then;

/// Create a copy of DomainPaymentMethod
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? iconUrl = freezed,Object? feePercentage = null,Object? isAvailable = null,Object? description = freezed,Object? minAmount = freezed,Object? maxAmount = freezed,Object? config = null,Object? metadata = null,}) {
  return _then(_DomainPaymentMethod(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,iconUrl: freezed == iconUrl ? _self.iconUrl : iconUrl // ignore: cast_nullable_to_non_nullable
as String?,feePercentage: null == feePercentage ? _self.feePercentage : feePercentage // ignore: cast_nullable_to_non_nullable
as double,isAvailable: null == isAvailable ? _self.isAvailable : isAvailable // ignore: cast_nullable_to_non_nullable
as bool,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,minAmount: freezed == minAmount ? _self.minAmount : minAmount // ignore: cast_nullable_to_non_nullable
as double?,maxAmount: freezed == maxAmount ? _self.maxAmount : maxAmount // ignore: cast_nullable_to_non_nullable
as double?,config: null == config ? _self._config : config // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,metadata: null == metadata ? _self._metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}


}

// dart format on
