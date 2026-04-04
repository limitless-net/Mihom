// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../subscription.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DomainSubscription {

/// 订阅 URL
 String get subscribeUrl;/// 用户邮箱
 String get email;/// UUID
 String get uuid;/// 套餐 ID
 int get planId;/// 套餐名称
 String? get planName;/// Token
 String? get token;/// 总流量限制（字节）
 int get transferLimit;/// 已用上传（字节）
 int get uploadedBytes;/// 已用下载（字节）
 int get downloadedBytes;/// 速度限制（Mbps）
 int? get speedLimit;/// 设备数量限制
 int? get deviceLimit;/// 过期时间
 DateTime? get expiredAt;/// 下次重置时间
 DateTime? get nextResetAt;/// 元数据
 Map<String, dynamic> get metadata;
/// Create a copy of DomainSubscription
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DomainSubscriptionCopyWith<DomainSubscription> get copyWith => _$DomainSubscriptionCopyWithImpl<DomainSubscription>(this as DomainSubscription, _$identity);

  /// Serializes this DomainSubscription to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DomainSubscription&&(identical(other.subscribeUrl, subscribeUrl) || other.subscribeUrl == subscribeUrl)&&(identical(other.email, email) || other.email == email)&&(identical(other.uuid, uuid) || other.uuid == uuid)&&(identical(other.planId, planId) || other.planId == planId)&&(identical(other.planName, planName) || other.planName == planName)&&(identical(other.token, token) || other.token == token)&&(identical(other.transferLimit, transferLimit) || other.transferLimit == transferLimit)&&(identical(other.uploadedBytes, uploadedBytes) || other.uploadedBytes == uploadedBytes)&&(identical(other.downloadedBytes, downloadedBytes) || other.downloadedBytes == downloadedBytes)&&(identical(other.speedLimit, speedLimit) || other.speedLimit == speedLimit)&&(identical(other.deviceLimit, deviceLimit) || other.deviceLimit == deviceLimit)&&(identical(other.expiredAt, expiredAt) || other.expiredAt == expiredAt)&&(identical(other.nextResetAt, nextResetAt) || other.nextResetAt == nextResetAt)&&const DeepCollectionEquality().equals(other.metadata, metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,subscribeUrl,email,uuid,planId,planName,token,transferLimit,uploadedBytes,downloadedBytes,speedLimit,deviceLimit,expiredAt,nextResetAt,const DeepCollectionEquality().hash(metadata));

@override
String toString() {
  return 'DomainSubscription(subscribeUrl: $subscribeUrl, email: $email, uuid: $uuid, planId: $planId, planName: $planName, token: $token, transferLimit: $transferLimit, uploadedBytes: $uploadedBytes, downloadedBytes: $downloadedBytes, speedLimit: $speedLimit, deviceLimit: $deviceLimit, expiredAt: $expiredAt, nextResetAt: $nextResetAt, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class $DomainSubscriptionCopyWith<$Res>  {
  factory $DomainSubscriptionCopyWith(DomainSubscription value, $Res Function(DomainSubscription) _then) = _$DomainSubscriptionCopyWithImpl;
@useResult
$Res call({
 String subscribeUrl, String email, String uuid, int planId, String? planName, String? token, int transferLimit, int uploadedBytes, int downloadedBytes, int? speedLimit, int? deviceLimit, DateTime? expiredAt, DateTime? nextResetAt, Map<String, dynamic> metadata
});




}
/// @nodoc
class _$DomainSubscriptionCopyWithImpl<$Res>
    implements $DomainSubscriptionCopyWith<$Res> {
  _$DomainSubscriptionCopyWithImpl(this._self, this._then);

  final DomainSubscription _self;
  final $Res Function(DomainSubscription) _then;

/// Create a copy of DomainSubscription
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? subscribeUrl = null,Object? email = null,Object? uuid = null,Object? planId = null,Object? planName = freezed,Object? token = freezed,Object? transferLimit = null,Object? uploadedBytes = null,Object? downloadedBytes = null,Object? speedLimit = freezed,Object? deviceLimit = freezed,Object? expiredAt = freezed,Object? nextResetAt = freezed,Object? metadata = null,}) {
  return _then(_self.copyWith(
subscribeUrl: null == subscribeUrl ? _self.subscribeUrl : subscribeUrl // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,uuid: null == uuid ? _self.uuid : uuid // ignore: cast_nullable_to_non_nullable
as String,planId: null == planId ? _self.planId : planId // ignore: cast_nullable_to_non_nullable
as int,planName: freezed == planName ? _self.planName : planName // ignore: cast_nullable_to_non_nullable
as String?,token: freezed == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String?,transferLimit: null == transferLimit ? _self.transferLimit : transferLimit // ignore: cast_nullable_to_non_nullable
as int,uploadedBytes: null == uploadedBytes ? _self.uploadedBytes : uploadedBytes // ignore: cast_nullable_to_non_nullable
as int,downloadedBytes: null == downloadedBytes ? _self.downloadedBytes : downloadedBytes // ignore: cast_nullable_to_non_nullable
as int,speedLimit: freezed == speedLimit ? _self.speedLimit : speedLimit // ignore: cast_nullable_to_non_nullable
as int?,deviceLimit: freezed == deviceLimit ? _self.deviceLimit : deviceLimit // ignore: cast_nullable_to_non_nullable
as int?,expiredAt: freezed == expiredAt ? _self.expiredAt : expiredAt // ignore: cast_nullable_to_non_nullable
as DateTime?,nextResetAt: freezed == nextResetAt ? _self.nextResetAt : nextResetAt // ignore: cast_nullable_to_non_nullable
as DateTime?,metadata: null == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}

}


/// Adds pattern-matching-related methods to [DomainSubscription].
extension DomainSubscriptionPatterns on DomainSubscription {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DomainSubscription value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DomainSubscription() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DomainSubscription value)  $default,){
final _that = this;
switch (_that) {
case _DomainSubscription():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DomainSubscription value)?  $default,){
final _that = this;
switch (_that) {
case _DomainSubscription() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String subscribeUrl,  String email,  String uuid,  int planId,  String? planName,  String? token,  int transferLimit,  int uploadedBytes,  int downloadedBytes,  int? speedLimit,  int? deviceLimit,  DateTime? expiredAt,  DateTime? nextResetAt,  Map<String, dynamic> metadata)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DomainSubscription() when $default != null:
return $default(_that.subscribeUrl,_that.email,_that.uuid,_that.planId,_that.planName,_that.token,_that.transferLimit,_that.uploadedBytes,_that.downloadedBytes,_that.speedLimit,_that.deviceLimit,_that.expiredAt,_that.nextResetAt,_that.metadata);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String subscribeUrl,  String email,  String uuid,  int planId,  String? planName,  String? token,  int transferLimit,  int uploadedBytes,  int downloadedBytes,  int? speedLimit,  int? deviceLimit,  DateTime? expiredAt,  DateTime? nextResetAt,  Map<String, dynamic> metadata)  $default,) {final _that = this;
switch (_that) {
case _DomainSubscription():
return $default(_that.subscribeUrl,_that.email,_that.uuid,_that.planId,_that.planName,_that.token,_that.transferLimit,_that.uploadedBytes,_that.downloadedBytes,_that.speedLimit,_that.deviceLimit,_that.expiredAt,_that.nextResetAt,_that.metadata);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String subscribeUrl,  String email,  String uuid,  int planId,  String? planName,  String? token,  int transferLimit,  int uploadedBytes,  int downloadedBytes,  int? speedLimit,  int? deviceLimit,  DateTime? expiredAt,  DateTime? nextResetAt,  Map<String, dynamic> metadata)?  $default,) {final _that = this;
switch (_that) {
case _DomainSubscription() when $default != null:
return $default(_that.subscribeUrl,_that.email,_that.uuid,_that.planId,_that.planName,_that.token,_that.transferLimit,_that.uploadedBytes,_that.downloadedBytes,_that.speedLimit,_that.deviceLimit,_that.expiredAt,_that.nextResetAt,_that.metadata);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DomainSubscription extends DomainSubscription {
  const _DomainSubscription({required this.subscribeUrl, required this.email, required this.uuid, required this.planId, this.planName, this.token, required this.transferLimit, required this.uploadedBytes, required this.downloadedBytes, this.speedLimit, this.deviceLimit, this.expiredAt, this.nextResetAt, final  Map<String, dynamic> metadata = const {}}): _metadata = metadata,super._();
  factory _DomainSubscription.fromJson(Map<String, dynamic> json) => _$DomainSubscriptionFromJson(json);

/// 订阅 URL
@override final  String subscribeUrl;
/// 用户邮箱
@override final  String email;
/// UUID
@override final  String uuid;
/// 套餐 ID
@override final  int planId;
/// 套餐名称
@override final  String? planName;
/// Token
@override final  String? token;
/// 总流量限制（字节）
@override final  int transferLimit;
/// 已用上传（字节）
@override final  int uploadedBytes;
/// 已用下载（字节）
@override final  int downloadedBytes;
/// 速度限制（Mbps）
@override final  int? speedLimit;
/// 设备数量限制
@override final  int? deviceLimit;
/// 过期时间
@override final  DateTime? expiredAt;
/// 下次重置时间
@override final  DateTime? nextResetAt;
/// 元数据
 final  Map<String, dynamic> _metadata;
/// 元数据
@override@JsonKey() Map<String, dynamic> get metadata {
  if (_metadata is EqualUnmodifiableMapView) return _metadata;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_metadata);
}


/// Create a copy of DomainSubscription
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DomainSubscriptionCopyWith<_DomainSubscription> get copyWith => __$DomainSubscriptionCopyWithImpl<_DomainSubscription>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DomainSubscriptionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DomainSubscription&&(identical(other.subscribeUrl, subscribeUrl) || other.subscribeUrl == subscribeUrl)&&(identical(other.email, email) || other.email == email)&&(identical(other.uuid, uuid) || other.uuid == uuid)&&(identical(other.planId, planId) || other.planId == planId)&&(identical(other.planName, planName) || other.planName == planName)&&(identical(other.token, token) || other.token == token)&&(identical(other.transferLimit, transferLimit) || other.transferLimit == transferLimit)&&(identical(other.uploadedBytes, uploadedBytes) || other.uploadedBytes == uploadedBytes)&&(identical(other.downloadedBytes, downloadedBytes) || other.downloadedBytes == downloadedBytes)&&(identical(other.speedLimit, speedLimit) || other.speedLimit == speedLimit)&&(identical(other.deviceLimit, deviceLimit) || other.deviceLimit == deviceLimit)&&(identical(other.expiredAt, expiredAt) || other.expiredAt == expiredAt)&&(identical(other.nextResetAt, nextResetAt) || other.nextResetAt == nextResetAt)&&const DeepCollectionEquality().equals(other._metadata, _metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,subscribeUrl,email,uuid,planId,planName,token,transferLimit,uploadedBytes,downloadedBytes,speedLimit,deviceLimit,expiredAt,nextResetAt,const DeepCollectionEquality().hash(_metadata));

@override
String toString() {
  return 'DomainSubscription(subscribeUrl: $subscribeUrl, email: $email, uuid: $uuid, planId: $planId, planName: $planName, token: $token, transferLimit: $transferLimit, uploadedBytes: $uploadedBytes, downloadedBytes: $downloadedBytes, speedLimit: $speedLimit, deviceLimit: $deviceLimit, expiredAt: $expiredAt, nextResetAt: $nextResetAt, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class _$DomainSubscriptionCopyWith<$Res> implements $DomainSubscriptionCopyWith<$Res> {
  factory _$DomainSubscriptionCopyWith(_DomainSubscription value, $Res Function(_DomainSubscription) _then) = __$DomainSubscriptionCopyWithImpl;
@override @useResult
$Res call({
 String subscribeUrl, String email, String uuid, int planId, String? planName, String? token, int transferLimit, int uploadedBytes, int downloadedBytes, int? speedLimit, int? deviceLimit, DateTime? expiredAt, DateTime? nextResetAt, Map<String, dynamic> metadata
});




}
/// @nodoc
class __$DomainSubscriptionCopyWithImpl<$Res>
    implements _$DomainSubscriptionCopyWith<$Res> {
  __$DomainSubscriptionCopyWithImpl(this._self, this._then);

  final _DomainSubscription _self;
  final $Res Function(_DomainSubscription) _then;

/// Create a copy of DomainSubscription
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? subscribeUrl = null,Object? email = null,Object? uuid = null,Object? planId = null,Object? planName = freezed,Object? token = freezed,Object? transferLimit = null,Object? uploadedBytes = null,Object? downloadedBytes = null,Object? speedLimit = freezed,Object? deviceLimit = freezed,Object? expiredAt = freezed,Object? nextResetAt = freezed,Object? metadata = null,}) {
  return _then(_DomainSubscription(
subscribeUrl: null == subscribeUrl ? _self.subscribeUrl : subscribeUrl // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,uuid: null == uuid ? _self.uuid : uuid // ignore: cast_nullable_to_non_nullable
as String,planId: null == planId ? _self.planId : planId // ignore: cast_nullable_to_non_nullable
as int,planName: freezed == planName ? _self.planName : planName // ignore: cast_nullable_to_non_nullable
as String?,token: freezed == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String?,transferLimit: null == transferLimit ? _self.transferLimit : transferLimit // ignore: cast_nullable_to_non_nullable
as int,uploadedBytes: null == uploadedBytes ? _self.uploadedBytes : uploadedBytes // ignore: cast_nullable_to_non_nullable
as int,downloadedBytes: null == downloadedBytes ? _self.downloadedBytes : downloadedBytes // ignore: cast_nullable_to_non_nullable
as int,speedLimit: freezed == speedLimit ? _self.speedLimit : speedLimit // ignore: cast_nullable_to_non_nullable
as int?,deviceLimit: freezed == deviceLimit ? _self.deviceLimit : deviceLimit // ignore: cast_nullable_to_non_nullable
as int?,expiredAt: freezed == expiredAt ? _self.expiredAt : expiredAt // ignore: cast_nullable_to_non_nullable
as DateTime?,nextResetAt: freezed == nextResetAt ? _self.nextResetAt : nextResetAt // ignore: cast_nullable_to_non_nullable
as DateTime?,metadata: null == metadata ? _self._metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}


}

// dart format on
