// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../user.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DomainUser {

/// 用户邮箱（唯一标识）
 String get email;/// UUID（通用唯一标识符）
 String get uuid;/// 头像 URL
 String get avatarUrl;/// 套餐 ID（可能为空，新注册用户尚未购买套餐时为 null）
 int? get planId;/// 总流量限制（字节）
 int get transferLimit;/// 已用上传流量（字节）
 int get uploadedBytes;/// 已用下载流量（字节）
 int get downloadedBytes;/// 账户余额（分）
 int get balanceInCents;/// 佣金余额（分）
 int get commissionBalanceInCents;/// 过期时间
 DateTime? get expiredAt;/// 上次登录时间
 DateTime? get lastLoginAt;/// 创建时间
 DateTime? get createdAt;/// 是否被封禁
 bool get banned;/// 到期提醒
 bool get remindExpire;/// 流量提醒
 bool get remindTraffic;/// 折扣率（0-1）
 double? get discount;/// 佣金比例（0-1）
 double? get commissionRate;/// Telegram ID
 String? get telegramId;/// 元数据（存储 SDK 特有字段）
 Map<String, dynamic> get metadata;
/// Create a copy of DomainUser
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DomainUserCopyWith<DomainUser> get copyWith => _$DomainUserCopyWithImpl<DomainUser>(this as DomainUser, _$identity);

  /// Serializes this DomainUser to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DomainUser&&(identical(other.email, email) || other.email == email)&&(identical(other.uuid, uuid) || other.uuid == uuid)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.planId, planId) || other.planId == planId)&&(identical(other.transferLimit, transferLimit) || other.transferLimit == transferLimit)&&(identical(other.uploadedBytes, uploadedBytes) || other.uploadedBytes == uploadedBytes)&&(identical(other.downloadedBytes, downloadedBytes) || other.downloadedBytes == downloadedBytes)&&(identical(other.balanceInCents, balanceInCents) || other.balanceInCents == balanceInCents)&&(identical(other.commissionBalanceInCents, commissionBalanceInCents) || other.commissionBalanceInCents == commissionBalanceInCents)&&(identical(other.expiredAt, expiredAt) || other.expiredAt == expiredAt)&&(identical(other.lastLoginAt, lastLoginAt) || other.lastLoginAt == lastLoginAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.banned, banned) || other.banned == banned)&&(identical(other.remindExpire, remindExpire) || other.remindExpire == remindExpire)&&(identical(other.remindTraffic, remindTraffic) || other.remindTraffic == remindTraffic)&&(identical(other.discount, discount) || other.discount == discount)&&(identical(other.commissionRate, commissionRate) || other.commissionRate == commissionRate)&&(identical(other.telegramId, telegramId) || other.telegramId == telegramId)&&const DeepCollectionEquality().equals(other.metadata, metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,email,uuid,avatarUrl,planId,transferLimit,uploadedBytes,downloadedBytes,balanceInCents,commissionBalanceInCents,expiredAt,lastLoginAt,createdAt,banned,remindExpire,remindTraffic,discount,commissionRate,telegramId,const DeepCollectionEquality().hash(metadata)]);

@override
String toString() {
  return 'DomainUser(email: $email, uuid: $uuid, avatarUrl: $avatarUrl, planId: $planId, transferLimit: $transferLimit, uploadedBytes: $uploadedBytes, downloadedBytes: $downloadedBytes, balanceInCents: $balanceInCents, commissionBalanceInCents: $commissionBalanceInCents, expiredAt: $expiredAt, lastLoginAt: $lastLoginAt, createdAt: $createdAt, banned: $banned, remindExpire: $remindExpire, remindTraffic: $remindTraffic, discount: $discount, commissionRate: $commissionRate, telegramId: $telegramId, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class $DomainUserCopyWith<$Res>  {
  factory $DomainUserCopyWith(DomainUser value, $Res Function(DomainUser) _then) = _$DomainUserCopyWithImpl;
@useResult
$Res call({
 String email, String uuid, String avatarUrl, int? planId, int transferLimit, int uploadedBytes, int downloadedBytes, int balanceInCents, int commissionBalanceInCents, DateTime? expiredAt, DateTime? lastLoginAt, DateTime? createdAt, bool banned, bool remindExpire, bool remindTraffic, double? discount, double? commissionRate, String? telegramId, Map<String, dynamic> metadata
});




}
/// @nodoc
class _$DomainUserCopyWithImpl<$Res>
    implements $DomainUserCopyWith<$Res> {
  _$DomainUserCopyWithImpl(this._self, this._then);

  final DomainUser _self;
  final $Res Function(DomainUser) _then;

/// Create a copy of DomainUser
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? email = null,Object? uuid = null,Object? avatarUrl = null,Object? planId = freezed,Object? transferLimit = null,Object? uploadedBytes = null,Object? downloadedBytes = null,Object? balanceInCents = null,Object? commissionBalanceInCents = null,Object? expiredAt = freezed,Object? lastLoginAt = freezed,Object? createdAt = freezed,Object? banned = null,Object? remindExpire = null,Object? remindTraffic = null,Object? discount = freezed,Object? commissionRate = freezed,Object? telegramId = freezed,Object? metadata = null,}) {
  return _then(_self.copyWith(
email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,uuid: null == uuid ? _self.uuid : uuid // ignore: cast_nullable_to_non_nullable
as String,avatarUrl: null == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String,planId: freezed == planId ? _self.planId : planId // ignore: cast_nullable_to_non_nullable
as int?,transferLimit: null == transferLimit ? _self.transferLimit : transferLimit // ignore: cast_nullable_to_non_nullable
as int,uploadedBytes: null == uploadedBytes ? _self.uploadedBytes : uploadedBytes // ignore: cast_nullable_to_non_nullable
as int,downloadedBytes: null == downloadedBytes ? _self.downloadedBytes : downloadedBytes // ignore: cast_nullable_to_non_nullable
as int,balanceInCents: null == balanceInCents ? _self.balanceInCents : balanceInCents // ignore: cast_nullable_to_non_nullable
as int,commissionBalanceInCents: null == commissionBalanceInCents ? _self.commissionBalanceInCents : commissionBalanceInCents // ignore: cast_nullable_to_non_nullable
as int,expiredAt: freezed == expiredAt ? _self.expiredAt : expiredAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lastLoginAt: freezed == lastLoginAt ? _self.lastLoginAt : lastLoginAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,banned: null == banned ? _self.banned : banned // ignore: cast_nullable_to_non_nullable
as bool,remindExpire: null == remindExpire ? _self.remindExpire : remindExpire // ignore: cast_nullable_to_non_nullable
as bool,remindTraffic: null == remindTraffic ? _self.remindTraffic : remindTraffic // ignore: cast_nullable_to_non_nullable
as bool,discount: freezed == discount ? _self.discount : discount // ignore: cast_nullable_to_non_nullable
as double?,commissionRate: freezed == commissionRate ? _self.commissionRate : commissionRate // ignore: cast_nullable_to_non_nullable
as double?,telegramId: freezed == telegramId ? _self.telegramId : telegramId // ignore: cast_nullable_to_non_nullable
as String?,metadata: null == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}

}


/// Adds pattern-matching-related methods to [DomainUser].
extension DomainUserPatterns on DomainUser {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DomainUser value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DomainUser() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DomainUser value)  $default,){
final _that = this;
switch (_that) {
case _DomainUser():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DomainUser value)?  $default,){
final _that = this;
switch (_that) {
case _DomainUser() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String email,  String uuid,  String avatarUrl,  int? planId,  int transferLimit,  int uploadedBytes,  int downloadedBytes,  int balanceInCents,  int commissionBalanceInCents,  DateTime? expiredAt,  DateTime? lastLoginAt,  DateTime? createdAt,  bool banned,  bool remindExpire,  bool remindTraffic,  double? discount,  double? commissionRate,  String? telegramId,  Map<String, dynamic> metadata)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DomainUser() when $default != null:
return $default(_that.email,_that.uuid,_that.avatarUrl,_that.planId,_that.transferLimit,_that.uploadedBytes,_that.downloadedBytes,_that.balanceInCents,_that.commissionBalanceInCents,_that.expiredAt,_that.lastLoginAt,_that.createdAt,_that.banned,_that.remindExpire,_that.remindTraffic,_that.discount,_that.commissionRate,_that.telegramId,_that.metadata);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String email,  String uuid,  String avatarUrl,  int? planId,  int transferLimit,  int uploadedBytes,  int downloadedBytes,  int balanceInCents,  int commissionBalanceInCents,  DateTime? expiredAt,  DateTime? lastLoginAt,  DateTime? createdAt,  bool banned,  bool remindExpire,  bool remindTraffic,  double? discount,  double? commissionRate,  String? telegramId,  Map<String, dynamic> metadata)  $default,) {final _that = this;
switch (_that) {
case _DomainUser():
return $default(_that.email,_that.uuid,_that.avatarUrl,_that.planId,_that.transferLimit,_that.uploadedBytes,_that.downloadedBytes,_that.balanceInCents,_that.commissionBalanceInCents,_that.expiredAt,_that.lastLoginAt,_that.createdAt,_that.banned,_that.remindExpire,_that.remindTraffic,_that.discount,_that.commissionRate,_that.telegramId,_that.metadata);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String email,  String uuid,  String avatarUrl,  int? planId,  int transferLimit,  int uploadedBytes,  int downloadedBytes,  int balanceInCents,  int commissionBalanceInCents,  DateTime? expiredAt,  DateTime? lastLoginAt,  DateTime? createdAt,  bool banned,  bool remindExpire,  bool remindTraffic,  double? discount,  double? commissionRate,  String? telegramId,  Map<String, dynamic> metadata)?  $default,) {final _that = this;
switch (_that) {
case _DomainUser() when $default != null:
return $default(_that.email,_that.uuid,_that.avatarUrl,_that.planId,_that.transferLimit,_that.uploadedBytes,_that.downloadedBytes,_that.balanceInCents,_that.commissionBalanceInCents,_that.expiredAt,_that.lastLoginAt,_that.createdAt,_that.banned,_that.remindExpire,_that.remindTraffic,_that.discount,_that.commissionRate,_that.telegramId,_that.metadata);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DomainUser extends DomainUser {
  const _DomainUser({required this.email, required this.uuid, required this.avatarUrl, this.planId, required this.transferLimit, required this.uploadedBytes, required this.downloadedBytes, required this.balanceInCents, required this.commissionBalanceInCents, this.expiredAt, this.lastLoginAt, this.createdAt, this.banned = false, this.remindExpire = true, this.remindTraffic = true, this.discount, this.commissionRate, this.telegramId, final  Map<String, dynamic> metadata = const {}}): _metadata = metadata,super._();
  factory _DomainUser.fromJson(Map<String, dynamic> json) => _$DomainUserFromJson(json);

/// 用户邮箱（唯一标识）
@override final  String email;
/// UUID（通用唯一标识符）
@override final  String uuid;
/// 头像 URL
@override final  String avatarUrl;
/// 套餐 ID（可能为空，新注册用户尚未购买套餐时为 null）
@override final  int? planId;
/// 总流量限制（字节）
@override final  int transferLimit;
/// 已用上传流量（字节）
@override final  int uploadedBytes;
/// 已用下载流量（字节）
@override final  int downloadedBytes;
/// 账户余额（分）
@override final  int balanceInCents;
/// 佣金余额（分）
@override final  int commissionBalanceInCents;
/// 过期时间
@override final  DateTime? expiredAt;
/// 上次登录时间
@override final  DateTime? lastLoginAt;
/// 创建时间
@override final  DateTime? createdAt;
/// 是否被封禁
@override@JsonKey() final  bool banned;
/// 到期提醒
@override@JsonKey() final  bool remindExpire;
/// 流量提醒
@override@JsonKey() final  bool remindTraffic;
/// 折扣率（0-1）
@override final  double? discount;
/// 佣金比例（0-1）
@override final  double? commissionRate;
/// Telegram ID
@override final  String? telegramId;
/// 元数据（存储 SDK 特有字段）
 final  Map<String, dynamic> _metadata;
/// 元数据（存储 SDK 特有字段）
@override@JsonKey() Map<String, dynamic> get metadata {
  if (_metadata is EqualUnmodifiableMapView) return _metadata;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_metadata);
}


/// Create a copy of DomainUser
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DomainUserCopyWith<_DomainUser> get copyWith => __$DomainUserCopyWithImpl<_DomainUser>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DomainUserToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DomainUser&&(identical(other.email, email) || other.email == email)&&(identical(other.uuid, uuid) || other.uuid == uuid)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.planId, planId) || other.planId == planId)&&(identical(other.transferLimit, transferLimit) || other.transferLimit == transferLimit)&&(identical(other.uploadedBytes, uploadedBytes) || other.uploadedBytes == uploadedBytes)&&(identical(other.downloadedBytes, downloadedBytes) || other.downloadedBytes == downloadedBytes)&&(identical(other.balanceInCents, balanceInCents) || other.balanceInCents == balanceInCents)&&(identical(other.commissionBalanceInCents, commissionBalanceInCents) || other.commissionBalanceInCents == commissionBalanceInCents)&&(identical(other.expiredAt, expiredAt) || other.expiredAt == expiredAt)&&(identical(other.lastLoginAt, lastLoginAt) || other.lastLoginAt == lastLoginAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.banned, banned) || other.banned == banned)&&(identical(other.remindExpire, remindExpire) || other.remindExpire == remindExpire)&&(identical(other.remindTraffic, remindTraffic) || other.remindTraffic == remindTraffic)&&(identical(other.discount, discount) || other.discount == discount)&&(identical(other.commissionRate, commissionRate) || other.commissionRate == commissionRate)&&(identical(other.telegramId, telegramId) || other.telegramId == telegramId)&&const DeepCollectionEquality().equals(other._metadata, _metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,email,uuid,avatarUrl,planId,transferLimit,uploadedBytes,downloadedBytes,balanceInCents,commissionBalanceInCents,expiredAt,lastLoginAt,createdAt,banned,remindExpire,remindTraffic,discount,commissionRate,telegramId,const DeepCollectionEquality().hash(_metadata)]);

@override
String toString() {
  return 'DomainUser(email: $email, uuid: $uuid, avatarUrl: $avatarUrl, planId: $planId, transferLimit: $transferLimit, uploadedBytes: $uploadedBytes, downloadedBytes: $downloadedBytes, balanceInCents: $balanceInCents, commissionBalanceInCents: $commissionBalanceInCents, expiredAt: $expiredAt, lastLoginAt: $lastLoginAt, createdAt: $createdAt, banned: $banned, remindExpire: $remindExpire, remindTraffic: $remindTraffic, discount: $discount, commissionRate: $commissionRate, telegramId: $telegramId, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class _$DomainUserCopyWith<$Res> implements $DomainUserCopyWith<$Res> {
  factory _$DomainUserCopyWith(_DomainUser value, $Res Function(_DomainUser) _then) = __$DomainUserCopyWithImpl;
@override @useResult
$Res call({
 String email, String uuid, String avatarUrl, int? planId, int transferLimit, int uploadedBytes, int downloadedBytes, int balanceInCents, int commissionBalanceInCents, DateTime? expiredAt, DateTime? lastLoginAt, DateTime? createdAt, bool banned, bool remindExpire, bool remindTraffic, double? discount, double? commissionRate, String? telegramId, Map<String, dynamic> metadata
});




}
/// @nodoc
class __$DomainUserCopyWithImpl<$Res>
    implements _$DomainUserCopyWith<$Res> {
  __$DomainUserCopyWithImpl(this._self, this._then);

  final _DomainUser _self;
  final $Res Function(_DomainUser) _then;

/// Create a copy of DomainUser
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? email = null,Object? uuid = null,Object? avatarUrl = null,Object? planId = freezed,Object? transferLimit = null,Object? uploadedBytes = null,Object? downloadedBytes = null,Object? balanceInCents = null,Object? commissionBalanceInCents = null,Object? expiredAt = freezed,Object? lastLoginAt = freezed,Object? createdAt = freezed,Object? banned = null,Object? remindExpire = null,Object? remindTraffic = null,Object? discount = freezed,Object? commissionRate = freezed,Object? telegramId = freezed,Object? metadata = null,}) {
  return _then(_DomainUser(
email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,uuid: null == uuid ? _self.uuid : uuid // ignore: cast_nullable_to_non_nullable
as String,avatarUrl: null == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String,planId: freezed == planId ? _self.planId : planId // ignore: cast_nullable_to_non_nullable
as int?,transferLimit: null == transferLimit ? _self.transferLimit : transferLimit // ignore: cast_nullable_to_non_nullable
as int,uploadedBytes: null == uploadedBytes ? _self.uploadedBytes : uploadedBytes // ignore: cast_nullable_to_non_nullable
as int,downloadedBytes: null == downloadedBytes ? _self.downloadedBytes : downloadedBytes // ignore: cast_nullable_to_non_nullable
as int,balanceInCents: null == balanceInCents ? _self.balanceInCents : balanceInCents // ignore: cast_nullable_to_non_nullable
as int,commissionBalanceInCents: null == commissionBalanceInCents ? _self.commissionBalanceInCents : commissionBalanceInCents // ignore: cast_nullable_to_non_nullable
as int,expiredAt: freezed == expiredAt ? _self.expiredAt : expiredAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lastLoginAt: freezed == lastLoginAt ? _self.lastLoginAt : lastLoginAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,banned: null == banned ? _self.banned : banned // ignore: cast_nullable_to_non_nullable
as bool,remindExpire: null == remindExpire ? _self.remindExpire : remindExpire // ignore: cast_nullable_to_non_nullable
as bool,remindTraffic: null == remindTraffic ? _self.remindTraffic : remindTraffic // ignore: cast_nullable_to_non_nullable
as bool,discount: freezed == discount ? _self.discount : discount // ignore: cast_nullable_to_non_nullable
as double?,commissionRate: freezed == commissionRate ? _self.commissionRate : commissionRate // ignore: cast_nullable_to_non_nullable
as double?,telegramId: freezed == telegramId ? _self.telegramId : telegramId // ignore: cast_nullable_to_non_nullable
as String?,metadata: null == metadata ? _self._metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}


}

// dart format on
