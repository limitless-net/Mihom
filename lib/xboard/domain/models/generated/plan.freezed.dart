// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../plan.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DomainPlan {

/// 套餐 ID
 int get id;/// 套餐名称
 String get name;/// 分组 ID
 int get groupId;/// 流量配额（字节）
 int get transferQuota;/// 套餐说明/描述
 String? get description;/// 标签列表
 List<String> get tags;/// 速度限制（Mbps）
 int? get speedLimit;/// 设备数量限制
 int? get deviceLimit;/// 是否显示
 bool get isVisible;/// 是否可续费
 bool get renewable;/// 排序值
 int? get sort;// ========== 价格信息（单位：元） ==========
/// 一次性购买价格
 double? get onetimePrice;/// 月付价格
 double? get monthlyPrice;/// 季付价格
 double? get quarterlyPrice;/// 半年付价格
 double? get halfYearlyPrice;/// 年付价格
 double? get yearlyPrice;/// 两年付价格
 double? get twoYearPrice;/// 三年付价格
 double? get threeYearPrice;/// 重置流量价格
 double? get resetPrice;/// 创建时间
 DateTime? get createdAt;/// 更新时间
 DateTime? get updatedAt;/// 元数据
 Map<String, dynamic> get metadata;
/// Create a copy of DomainPlan
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DomainPlanCopyWith<DomainPlan> get copyWith => _$DomainPlanCopyWithImpl<DomainPlan>(this as DomainPlan, _$identity);

  /// Serializes this DomainPlan to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DomainPlan&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.groupId, groupId) || other.groupId == groupId)&&(identical(other.transferQuota, transferQuota) || other.transferQuota == transferQuota)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other.tags, tags)&&(identical(other.speedLimit, speedLimit) || other.speedLimit == speedLimit)&&(identical(other.deviceLimit, deviceLimit) || other.deviceLimit == deviceLimit)&&(identical(other.isVisible, isVisible) || other.isVisible == isVisible)&&(identical(other.renewable, renewable) || other.renewable == renewable)&&(identical(other.sort, sort) || other.sort == sort)&&(identical(other.onetimePrice, onetimePrice) || other.onetimePrice == onetimePrice)&&(identical(other.monthlyPrice, monthlyPrice) || other.monthlyPrice == monthlyPrice)&&(identical(other.quarterlyPrice, quarterlyPrice) || other.quarterlyPrice == quarterlyPrice)&&(identical(other.halfYearlyPrice, halfYearlyPrice) || other.halfYearlyPrice == halfYearlyPrice)&&(identical(other.yearlyPrice, yearlyPrice) || other.yearlyPrice == yearlyPrice)&&(identical(other.twoYearPrice, twoYearPrice) || other.twoYearPrice == twoYearPrice)&&(identical(other.threeYearPrice, threeYearPrice) || other.threeYearPrice == threeYearPrice)&&(identical(other.resetPrice, resetPrice) || other.resetPrice == resetPrice)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&const DeepCollectionEquality().equals(other.metadata, metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,name,groupId,transferQuota,description,const DeepCollectionEquality().hash(tags),speedLimit,deviceLimit,isVisible,renewable,sort,onetimePrice,monthlyPrice,quarterlyPrice,halfYearlyPrice,yearlyPrice,twoYearPrice,threeYearPrice,resetPrice,createdAt,updatedAt,const DeepCollectionEquality().hash(metadata)]);

@override
String toString() {
  return 'DomainPlan(id: $id, name: $name, groupId: $groupId, transferQuota: $transferQuota, description: $description, tags: $tags, speedLimit: $speedLimit, deviceLimit: $deviceLimit, isVisible: $isVisible, renewable: $renewable, sort: $sort, onetimePrice: $onetimePrice, monthlyPrice: $monthlyPrice, quarterlyPrice: $quarterlyPrice, halfYearlyPrice: $halfYearlyPrice, yearlyPrice: $yearlyPrice, twoYearPrice: $twoYearPrice, threeYearPrice: $threeYearPrice, resetPrice: $resetPrice, createdAt: $createdAt, updatedAt: $updatedAt, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class $DomainPlanCopyWith<$Res>  {
  factory $DomainPlanCopyWith(DomainPlan value, $Res Function(DomainPlan) _then) = _$DomainPlanCopyWithImpl;
@useResult
$Res call({
 int id, String name, int groupId, int transferQuota, String? description, List<String> tags, int? speedLimit, int? deviceLimit, bool isVisible, bool renewable, int? sort, double? onetimePrice, double? monthlyPrice, double? quarterlyPrice, double? halfYearlyPrice, double? yearlyPrice, double? twoYearPrice, double? threeYearPrice, double? resetPrice, DateTime? createdAt, DateTime? updatedAt, Map<String, dynamic> metadata
});




}
/// @nodoc
class _$DomainPlanCopyWithImpl<$Res>
    implements $DomainPlanCopyWith<$Res> {
  _$DomainPlanCopyWithImpl(this._self, this._then);

  final DomainPlan _self;
  final $Res Function(DomainPlan) _then;

/// Create a copy of DomainPlan
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? groupId = null,Object? transferQuota = null,Object? description = freezed,Object? tags = null,Object? speedLimit = freezed,Object? deviceLimit = freezed,Object? isVisible = null,Object? renewable = null,Object? sort = freezed,Object? onetimePrice = freezed,Object? monthlyPrice = freezed,Object? quarterlyPrice = freezed,Object? halfYearlyPrice = freezed,Object? yearlyPrice = freezed,Object? twoYearPrice = freezed,Object? threeYearPrice = freezed,Object? resetPrice = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,Object? metadata = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,groupId: null == groupId ? _self.groupId : groupId // ignore: cast_nullable_to_non_nullable
as int,transferQuota: null == transferQuota ? _self.transferQuota : transferQuota // ignore: cast_nullable_to_non_nullable
as int,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,tags: null == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,speedLimit: freezed == speedLimit ? _self.speedLimit : speedLimit // ignore: cast_nullable_to_non_nullable
as int?,deviceLimit: freezed == deviceLimit ? _self.deviceLimit : deviceLimit // ignore: cast_nullable_to_non_nullable
as int?,isVisible: null == isVisible ? _self.isVisible : isVisible // ignore: cast_nullable_to_non_nullable
as bool,renewable: null == renewable ? _self.renewable : renewable // ignore: cast_nullable_to_non_nullable
as bool,sort: freezed == sort ? _self.sort : sort // ignore: cast_nullable_to_non_nullable
as int?,onetimePrice: freezed == onetimePrice ? _self.onetimePrice : onetimePrice // ignore: cast_nullable_to_non_nullable
as double?,monthlyPrice: freezed == monthlyPrice ? _self.monthlyPrice : monthlyPrice // ignore: cast_nullable_to_non_nullable
as double?,quarterlyPrice: freezed == quarterlyPrice ? _self.quarterlyPrice : quarterlyPrice // ignore: cast_nullable_to_non_nullable
as double?,halfYearlyPrice: freezed == halfYearlyPrice ? _self.halfYearlyPrice : halfYearlyPrice // ignore: cast_nullable_to_non_nullable
as double?,yearlyPrice: freezed == yearlyPrice ? _self.yearlyPrice : yearlyPrice // ignore: cast_nullable_to_non_nullable
as double?,twoYearPrice: freezed == twoYearPrice ? _self.twoYearPrice : twoYearPrice // ignore: cast_nullable_to_non_nullable
as double?,threeYearPrice: freezed == threeYearPrice ? _self.threeYearPrice : threeYearPrice // ignore: cast_nullable_to_non_nullable
as double?,resetPrice: freezed == resetPrice ? _self.resetPrice : resetPrice // ignore: cast_nullable_to_non_nullable
as double?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,metadata: null == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}

}


/// Adds pattern-matching-related methods to [DomainPlan].
extension DomainPlanPatterns on DomainPlan {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DomainPlan value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DomainPlan() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DomainPlan value)  $default,){
final _that = this;
switch (_that) {
case _DomainPlan():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DomainPlan value)?  $default,){
final _that = this;
switch (_that) {
case _DomainPlan() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String name,  int groupId,  int transferQuota,  String? description,  List<String> tags,  int? speedLimit,  int? deviceLimit,  bool isVisible,  bool renewable,  int? sort,  double? onetimePrice,  double? monthlyPrice,  double? quarterlyPrice,  double? halfYearlyPrice,  double? yearlyPrice,  double? twoYearPrice,  double? threeYearPrice,  double? resetPrice,  DateTime? createdAt,  DateTime? updatedAt,  Map<String, dynamic> metadata)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DomainPlan() when $default != null:
return $default(_that.id,_that.name,_that.groupId,_that.transferQuota,_that.description,_that.tags,_that.speedLimit,_that.deviceLimit,_that.isVisible,_that.renewable,_that.sort,_that.onetimePrice,_that.monthlyPrice,_that.quarterlyPrice,_that.halfYearlyPrice,_that.yearlyPrice,_that.twoYearPrice,_that.threeYearPrice,_that.resetPrice,_that.createdAt,_that.updatedAt,_that.metadata);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String name,  int groupId,  int transferQuota,  String? description,  List<String> tags,  int? speedLimit,  int? deviceLimit,  bool isVisible,  bool renewable,  int? sort,  double? onetimePrice,  double? monthlyPrice,  double? quarterlyPrice,  double? halfYearlyPrice,  double? yearlyPrice,  double? twoYearPrice,  double? threeYearPrice,  double? resetPrice,  DateTime? createdAt,  DateTime? updatedAt,  Map<String, dynamic> metadata)  $default,) {final _that = this;
switch (_that) {
case _DomainPlan():
return $default(_that.id,_that.name,_that.groupId,_that.transferQuota,_that.description,_that.tags,_that.speedLimit,_that.deviceLimit,_that.isVisible,_that.renewable,_that.sort,_that.onetimePrice,_that.monthlyPrice,_that.quarterlyPrice,_that.halfYearlyPrice,_that.yearlyPrice,_that.twoYearPrice,_that.threeYearPrice,_that.resetPrice,_that.createdAt,_that.updatedAt,_that.metadata);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String name,  int groupId,  int transferQuota,  String? description,  List<String> tags,  int? speedLimit,  int? deviceLimit,  bool isVisible,  bool renewable,  int? sort,  double? onetimePrice,  double? monthlyPrice,  double? quarterlyPrice,  double? halfYearlyPrice,  double? yearlyPrice,  double? twoYearPrice,  double? threeYearPrice,  double? resetPrice,  DateTime? createdAt,  DateTime? updatedAt,  Map<String, dynamic> metadata)?  $default,) {final _that = this;
switch (_that) {
case _DomainPlan() when $default != null:
return $default(_that.id,_that.name,_that.groupId,_that.transferQuota,_that.description,_that.tags,_that.speedLimit,_that.deviceLimit,_that.isVisible,_that.renewable,_that.sort,_that.onetimePrice,_that.monthlyPrice,_that.quarterlyPrice,_that.halfYearlyPrice,_that.yearlyPrice,_that.twoYearPrice,_that.threeYearPrice,_that.resetPrice,_that.createdAt,_that.updatedAt,_that.metadata);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DomainPlan extends DomainPlan {
  const _DomainPlan({required this.id, required this.name, required this.groupId, required this.transferQuota, this.description, final  List<String> tags = const [], this.speedLimit, this.deviceLimit, this.isVisible = true, this.renewable = true, this.sort, this.onetimePrice, this.monthlyPrice, this.quarterlyPrice, this.halfYearlyPrice, this.yearlyPrice, this.twoYearPrice, this.threeYearPrice, this.resetPrice, this.createdAt, this.updatedAt, final  Map<String, dynamic> metadata = const {}}): _tags = tags,_metadata = metadata,super._();
  factory _DomainPlan.fromJson(Map<String, dynamic> json) => _$DomainPlanFromJson(json);

/// 套餐 ID
@override final  int id;
/// 套餐名称
@override final  String name;
/// 分组 ID
@override final  int groupId;
/// 流量配额（字节）
@override final  int transferQuota;
/// 套餐说明/描述
@override final  String? description;
/// 标签列表
 final  List<String> _tags;
/// 标签列表
@override@JsonKey() List<String> get tags {
  if (_tags is EqualUnmodifiableListView) return _tags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tags);
}

/// 速度限制（Mbps）
@override final  int? speedLimit;
/// 设备数量限制
@override final  int? deviceLimit;
/// 是否显示
@override@JsonKey() final  bool isVisible;
/// 是否可续费
@override@JsonKey() final  bool renewable;
/// 排序值
@override final  int? sort;
// ========== 价格信息（单位：元） ==========
/// 一次性购买价格
@override final  double? onetimePrice;
/// 月付价格
@override final  double? monthlyPrice;
/// 季付价格
@override final  double? quarterlyPrice;
/// 半年付价格
@override final  double? halfYearlyPrice;
/// 年付价格
@override final  double? yearlyPrice;
/// 两年付价格
@override final  double? twoYearPrice;
/// 三年付价格
@override final  double? threeYearPrice;
/// 重置流量价格
@override final  double? resetPrice;
/// 创建时间
@override final  DateTime? createdAt;
/// 更新时间
@override final  DateTime? updatedAt;
/// 元数据
 final  Map<String, dynamic> _metadata;
/// 元数据
@override@JsonKey() Map<String, dynamic> get metadata {
  if (_metadata is EqualUnmodifiableMapView) return _metadata;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_metadata);
}


/// Create a copy of DomainPlan
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DomainPlanCopyWith<_DomainPlan> get copyWith => __$DomainPlanCopyWithImpl<_DomainPlan>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DomainPlanToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DomainPlan&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.groupId, groupId) || other.groupId == groupId)&&(identical(other.transferQuota, transferQuota) || other.transferQuota == transferQuota)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other._tags, _tags)&&(identical(other.speedLimit, speedLimit) || other.speedLimit == speedLimit)&&(identical(other.deviceLimit, deviceLimit) || other.deviceLimit == deviceLimit)&&(identical(other.isVisible, isVisible) || other.isVisible == isVisible)&&(identical(other.renewable, renewable) || other.renewable == renewable)&&(identical(other.sort, sort) || other.sort == sort)&&(identical(other.onetimePrice, onetimePrice) || other.onetimePrice == onetimePrice)&&(identical(other.monthlyPrice, monthlyPrice) || other.monthlyPrice == monthlyPrice)&&(identical(other.quarterlyPrice, quarterlyPrice) || other.quarterlyPrice == quarterlyPrice)&&(identical(other.halfYearlyPrice, halfYearlyPrice) || other.halfYearlyPrice == halfYearlyPrice)&&(identical(other.yearlyPrice, yearlyPrice) || other.yearlyPrice == yearlyPrice)&&(identical(other.twoYearPrice, twoYearPrice) || other.twoYearPrice == twoYearPrice)&&(identical(other.threeYearPrice, threeYearPrice) || other.threeYearPrice == threeYearPrice)&&(identical(other.resetPrice, resetPrice) || other.resetPrice == resetPrice)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&const DeepCollectionEquality().equals(other._metadata, _metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,name,groupId,transferQuota,description,const DeepCollectionEquality().hash(_tags),speedLimit,deviceLimit,isVisible,renewable,sort,onetimePrice,monthlyPrice,quarterlyPrice,halfYearlyPrice,yearlyPrice,twoYearPrice,threeYearPrice,resetPrice,createdAt,updatedAt,const DeepCollectionEquality().hash(_metadata)]);

@override
String toString() {
  return 'DomainPlan(id: $id, name: $name, groupId: $groupId, transferQuota: $transferQuota, description: $description, tags: $tags, speedLimit: $speedLimit, deviceLimit: $deviceLimit, isVisible: $isVisible, renewable: $renewable, sort: $sort, onetimePrice: $onetimePrice, monthlyPrice: $monthlyPrice, quarterlyPrice: $quarterlyPrice, halfYearlyPrice: $halfYearlyPrice, yearlyPrice: $yearlyPrice, twoYearPrice: $twoYearPrice, threeYearPrice: $threeYearPrice, resetPrice: $resetPrice, createdAt: $createdAt, updatedAt: $updatedAt, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class _$DomainPlanCopyWith<$Res> implements $DomainPlanCopyWith<$Res> {
  factory _$DomainPlanCopyWith(_DomainPlan value, $Res Function(_DomainPlan) _then) = __$DomainPlanCopyWithImpl;
@override @useResult
$Res call({
 int id, String name, int groupId, int transferQuota, String? description, List<String> tags, int? speedLimit, int? deviceLimit, bool isVisible, bool renewable, int? sort, double? onetimePrice, double? monthlyPrice, double? quarterlyPrice, double? halfYearlyPrice, double? yearlyPrice, double? twoYearPrice, double? threeYearPrice, double? resetPrice, DateTime? createdAt, DateTime? updatedAt, Map<String, dynamic> metadata
});




}
/// @nodoc
class __$DomainPlanCopyWithImpl<$Res>
    implements _$DomainPlanCopyWith<$Res> {
  __$DomainPlanCopyWithImpl(this._self, this._then);

  final _DomainPlan _self;
  final $Res Function(_DomainPlan) _then;

/// Create a copy of DomainPlan
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? groupId = null,Object? transferQuota = null,Object? description = freezed,Object? tags = null,Object? speedLimit = freezed,Object? deviceLimit = freezed,Object? isVisible = null,Object? renewable = null,Object? sort = freezed,Object? onetimePrice = freezed,Object? monthlyPrice = freezed,Object? quarterlyPrice = freezed,Object? halfYearlyPrice = freezed,Object? yearlyPrice = freezed,Object? twoYearPrice = freezed,Object? threeYearPrice = freezed,Object? resetPrice = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,Object? metadata = null,}) {
  return _then(_DomainPlan(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,groupId: null == groupId ? _self.groupId : groupId // ignore: cast_nullable_to_non_nullable
as int,transferQuota: null == transferQuota ? _self.transferQuota : transferQuota // ignore: cast_nullable_to_non_nullable
as int,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,tags: null == tags ? _self._tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,speedLimit: freezed == speedLimit ? _self.speedLimit : speedLimit // ignore: cast_nullable_to_non_nullable
as int?,deviceLimit: freezed == deviceLimit ? _self.deviceLimit : deviceLimit // ignore: cast_nullable_to_non_nullable
as int?,isVisible: null == isVisible ? _self.isVisible : isVisible // ignore: cast_nullable_to_non_nullable
as bool,renewable: null == renewable ? _self.renewable : renewable // ignore: cast_nullable_to_non_nullable
as bool,sort: freezed == sort ? _self.sort : sort // ignore: cast_nullable_to_non_nullable
as int?,onetimePrice: freezed == onetimePrice ? _self.onetimePrice : onetimePrice // ignore: cast_nullable_to_non_nullable
as double?,monthlyPrice: freezed == monthlyPrice ? _self.monthlyPrice : monthlyPrice // ignore: cast_nullable_to_non_nullable
as double?,quarterlyPrice: freezed == quarterlyPrice ? _self.quarterlyPrice : quarterlyPrice // ignore: cast_nullable_to_non_nullable
as double?,halfYearlyPrice: freezed == halfYearlyPrice ? _self.halfYearlyPrice : halfYearlyPrice // ignore: cast_nullable_to_non_nullable
as double?,yearlyPrice: freezed == yearlyPrice ? _self.yearlyPrice : yearlyPrice // ignore: cast_nullable_to_non_nullable
as double?,twoYearPrice: freezed == twoYearPrice ? _self.twoYearPrice : twoYearPrice // ignore: cast_nullable_to_non_nullable
as double?,threeYearPrice: freezed == threeYearPrice ? _self.threeYearPrice : threeYearPrice // ignore: cast_nullable_to_non_nullable
as double?,resetPrice: freezed == resetPrice ? _self.resetPrice : resetPrice // ignore: cast_nullable_to_non_nullable
as double?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,metadata: null == metadata ? _self._metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}


}

// dart format on
