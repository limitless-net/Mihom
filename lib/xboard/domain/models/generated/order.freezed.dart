// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../order.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DomainOrder {

/// 订单号（交易号）
 String get tradeNo;/// 套餐 ID
 int get planId;/// 周期类型
 String get period;/// 订单金额（元）
 double get totalAmount;/// 订单状态
 OrderStatus get status;/// 套餐名称（可选）
 String? get planName;/// 创建时间
 DateTime get createdAt;/// 支付时间
 DateTime? get paidAt;/// 元数据
 Map<String, dynamic> get metadata;
/// Create a copy of DomainOrder
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DomainOrderCopyWith<DomainOrder> get copyWith => _$DomainOrderCopyWithImpl<DomainOrder>(this as DomainOrder, _$identity);

  /// Serializes this DomainOrder to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DomainOrder&&(identical(other.tradeNo, tradeNo) || other.tradeNo == tradeNo)&&(identical(other.planId, planId) || other.planId == planId)&&(identical(other.period, period) || other.period == period)&&(identical(other.totalAmount, totalAmount) || other.totalAmount == totalAmount)&&(identical(other.status, status) || other.status == status)&&(identical(other.planName, planName) || other.planName == planName)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.paidAt, paidAt) || other.paidAt == paidAt)&&const DeepCollectionEquality().equals(other.metadata, metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,tradeNo,planId,period,totalAmount,status,planName,createdAt,paidAt,const DeepCollectionEquality().hash(metadata));

@override
String toString() {
  return 'DomainOrder(tradeNo: $tradeNo, planId: $planId, period: $period, totalAmount: $totalAmount, status: $status, planName: $planName, createdAt: $createdAt, paidAt: $paidAt, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class $DomainOrderCopyWith<$Res>  {
  factory $DomainOrderCopyWith(DomainOrder value, $Res Function(DomainOrder) _then) = _$DomainOrderCopyWithImpl;
@useResult
$Res call({
 String tradeNo, int planId, String period, double totalAmount, OrderStatus status, String? planName, DateTime createdAt, DateTime? paidAt, Map<String, dynamic> metadata
});




}
/// @nodoc
class _$DomainOrderCopyWithImpl<$Res>
    implements $DomainOrderCopyWith<$Res> {
  _$DomainOrderCopyWithImpl(this._self, this._then);

  final DomainOrder _self;
  final $Res Function(DomainOrder) _then;

/// Create a copy of DomainOrder
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? tradeNo = null,Object? planId = null,Object? period = null,Object? totalAmount = null,Object? status = null,Object? planName = freezed,Object? createdAt = null,Object? paidAt = freezed,Object? metadata = null,}) {
  return _then(_self.copyWith(
tradeNo: null == tradeNo ? _self.tradeNo : tradeNo // ignore: cast_nullable_to_non_nullable
as String,planId: null == planId ? _self.planId : planId // ignore: cast_nullable_to_non_nullable
as int,period: null == period ? _self.period : period // ignore: cast_nullable_to_non_nullable
as String,totalAmount: null == totalAmount ? _self.totalAmount : totalAmount // ignore: cast_nullable_to_non_nullable
as double,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as OrderStatus,planName: freezed == planName ? _self.planName : planName // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,paidAt: freezed == paidAt ? _self.paidAt : paidAt // ignore: cast_nullable_to_non_nullable
as DateTime?,metadata: null == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}

}


/// Adds pattern-matching-related methods to [DomainOrder].
extension DomainOrderPatterns on DomainOrder {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DomainOrder value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DomainOrder() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DomainOrder value)  $default,){
final _that = this;
switch (_that) {
case _DomainOrder():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DomainOrder value)?  $default,){
final _that = this;
switch (_that) {
case _DomainOrder() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String tradeNo,  int planId,  String period,  double totalAmount,  OrderStatus status,  String? planName,  DateTime createdAt,  DateTime? paidAt,  Map<String, dynamic> metadata)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DomainOrder() when $default != null:
return $default(_that.tradeNo,_that.planId,_that.period,_that.totalAmount,_that.status,_that.planName,_that.createdAt,_that.paidAt,_that.metadata);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String tradeNo,  int planId,  String period,  double totalAmount,  OrderStatus status,  String? planName,  DateTime createdAt,  DateTime? paidAt,  Map<String, dynamic> metadata)  $default,) {final _that = this;
switch (_that) {
case _DomainOrder():
return $default(_that.tradeNo,_that.planId,_that.period,_that.totalAmount,_that.status,_that.planName,_that.createdAt,_that.paidAt,_that.metadata);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String tradeNo,  int planId,  String period,  double totalAmount,  OrderStatus status,  String? planName,  DateTime createdAt,  DateTime? paidAt,  Map<String, dynamic> metadata)?  $default,) {final _that = this;
switch (_that) {
case _DomainOrder() when $default != null:
return $default(_that.tradeNo,_that.planId,_that.period,_that.totalAmount,_that.status,_that.planName,_that.createdAt,_that.paidAt,_that.metadata);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DomainOrder extends DomainOrder {
  const _DomainOrder({required this.tradeNo, required this.planId, required this.period, required this.totalAmount, required this.status, this.planName, required this.createdAt, this.paidAt, final  Map<String, dynamic> metadata = const {}}): _metadata = metadata,super._();
  factory _DomainOrder.fromJson(Map<String, dynamic> json) => _$DomainOrderFromJson(json);

/// 订单号（交易号）
@override final  String tradeNo;
/// 套餐 ID
@override final  int planId;
/// 周期类型
@override final  String period;
/// 订单金额（元）
@override final  double totalAmount;
/// 订单状态
@override final  OrderStatus status;
/// 套餐名称（可选）
@override final  String? planName;
/// 创建时间
@override final  DateTime createdAt;
/// 支付时间
@override final  DateTime? paidAt;
/// 元数据
 final  Map<String, dynamic> _metadata;
/// 元数据
@override@JsonKey() Map<String, dynamic> get metadata {
  if (_metadata is EqualUnmodifiableMapView) return _metadata;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_metadata);
}


/// Create a copy of DomainOrder
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DomainOrderCopyWith<_DomainOrder> get copyWith => __$DomainOrderCopyWithImpl<_DomainOrder>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DomainOrderToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DomainOrder&&(identical(other.tradeNo, tradeNo) || other.tradeNo == tradeNo)&&(identical(other.planId, planId) || other.planId == planId)&&(identical(other.period, period) || other.period == period)&&(identical(other.totalAmount, totalAmount) || other.totalAmount == totalAmount)&&(identical(other.status, status) || other.status == status)&&(identical(other.planName, planName) || other.planName == planName)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.paidAt, paidAt) || other.paidAt == paidAt)&&const DeepCollectionEquality().equals(other._metadata, _metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,tradeNo,planId,period,totalAmount,status,planName,createdAt,paidAt,const DeepCollectionEquality().hash(_metadata));

@override
String toString() {
  return 'DomainOrder(tradeNo: $tradeNo, planId: $planId, period: $period, totalAmount: $totalAmount, status: $status, planName: $planName, createdAt: $createdAt, paidAt: $paidAt, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class _$DomainOrderCopyWith<$Res> implements $DomainOrderCopyWith<$Res> {
  factory _$DomainOrderCopyWith(_DomainOrder value, $Res Function(_DomainOrder) _then) = __$DomainOrderCopyWithImpl;
@override @useResult
$Res call({
 String tradeNo, int planId, String period, double totalAmount, OrderStatus status, String? planName, DateTime createdAt, DateTime? paidAt, Map<String, dynamic> metadata
});




}
/// @nodoc
class __$DomainOrderCopyWithImpl<$Res>
    implements _$DomainOrderCopyWith<$Res> {
  __$DomainOrderCopyWithImpl(this._self, this._then);

  final _DomainOrder _self;
  final $Res Function(_DomainOrder) _then;

/// Create a copy of DomainOrder
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? tradeNo = null,Object? planId = null,Object? period = null,Object? totalAmount = null,Object? status = null,Object? planName = freezed,Object? createdAt = null,Object? paidAt = freezed,Object? metadata = null,}) {
  return _then(_DomainOrder(
tradeNo: null == tradeNo ? _self.tradeNo : tradeNo // ignore: cast_nullable_to_non_nullable
as String,planId: null == planId ? _self.planId : planId // ignore: cast_nullable_to_non_nullable
as int,period: null == period ? _self.period : period // ignore: cast_nullable_to_non_nullable
as String,totalAmount: null == totalAmount ? _self.totalAmount : totalAmount // ignore: cast_nullable_to_non_nullable
as double,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as OrderStatus,planName: freezed == planName ? _self.planName : planName // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,paidAt: freezed == paidAt ? _self.paidAt : paidAt // ignore: cast_nullable_to_non_nullable
as DateTime?,metadata: null == metadata ? _self._metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}


}

// dart format on
