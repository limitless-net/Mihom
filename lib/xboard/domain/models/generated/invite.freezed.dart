// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../invite.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DomainInvite {

/// 邀请码列表
 List<DomainInviteCode> get codes;/// 邀请统计
 InviteStats get stats;/// 元数据
 Map<String, dynamic> get metadata;
/// Create a copy of DomainInvite
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DomainInviteCopyWith<DomainInvite> get copyWith => _$DomainInviteCopyWithImpl<DomainInvite>(this as DomainInvite, _$identity);

  /// Serializes this DomainInvite to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DomainInvite&&const DeepCollectionEquality().equals(other.codes, codes)&&(identical(other.stats, stats) || other.stats == stats)&&const DeepCollectionEquality().equals(other.metadata, metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(codes),stats,const DeepCollectionEquality().hash(metadata));

@override
String toString() {
  return 'DomainInvite(codes: $codes, stats: $stats, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class $DomainInviteCopyWith<$Res>  {
  factory $DomainInviteCopyWith(DomainInvite value, $Res Function(DomainInvite) _then) = _$DomainInviteCopyWithImpl;
@useResult
$Res call({
 List<DomainInviteCode> codes, InviteStats stats, Map<String, dynamic> metadata
});


$InviteStatsCopyWith<$Res> get stats;

}
/// @nodoc
class _$DomainInviteCopyWithImpl<$Res>
    implements $DomainInviteCopyWith<$Res> {
  _$DomainInviteCopyWithImpl(this._self, this._then);

  final DomainInvite _self;
  final $Res Function(DomainInvite) _then;

/// Create a copy of DomainInvite
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? codes = null,Object? stats = null,Object? metadata = null,}) {
  return _then(_self.copyWith(
codes: null == codes ? _self.codes : codes // ignore: cast_nullable_to_non_nullable
as List<DomainInviteCode>,stats: null == stats ? _self.stats : stats // ignore: cast_nullable_to_non_nullable
as InviteStats,metadata: null == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}
/// Create a copy of DomainInvite
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$InviteStatsCopyWith<$Res> get stats {
  
  return $InviteStatsCopyWith<$Res>(_self.stats, (value) {
    return _then(_self.copyWith(stats: value));
  });
}
}


/// Adds pattern-matching-related methods to [DomainInvite].
extension DomainInvitePatterns on DomainInvite {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DomainInvite value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DomainInvite() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DomainInvite value)  $default,){
final _that = this;
switch (_that) {
case _DomainInvite():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DomainInvite value)?  $default,){
final _that = this;
switch (_that) {
case _DomainInvite() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<DomainInviteCode> codes,  InviteStats stats,  Map<String, dynamic> metadata)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DomainInvite() when $default != null:
return $default(_that.codes,_that.stats,_that.metadata);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<DomainInviteCode> codes,  InviteStats stats,  Map<String, dynamic> metadata)  $default,) {final _that = this;
switch (_that) {
case _DomainInvite():
return $default(_that.codes,_that.stats,_that.metadata);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<DomainInviteCode> codes,  InviteStats stats,  Map<String, dynamic> metadata)?  $default,) {final _that = this;
switch (_that) {
case _DomainInvite() when $default != null:
return $default(_that.codes,_that.stats,_that.metadata);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DomainInvite extends DomainInvite {
  const _DomainInvite({final  List<DomainInviteCode> codes = const [], required this.stats, final  Map<String, dynamic> metadata = const {}}): _codes = codes,_metadata = metadata,super._();
  factory _DomainInvite.fromJson(Map<String, dynamic> json) => _$DomainInviteFromJson(json);

/// 邀请码列表
 final  List<DomainInviteCode> _codes;
/// 邀请码列表
@override@JsonKey() List<DomainInviteCode> get codes {
  if (_codes is EqualUnmodifiableListView) return _codes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_codes);
}

/// 邀请统计
@override final  InviteStats stats;
/// 元数据
 final  Map<String, dynamic> _metadata;
/// 元数据
@override@JsonKey() Map<String, dynamic> get metadata {
  if (_metadata is EqualUnmodifiableMapView) return _metadata;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_metadata);
}


/// Create a copy of DomainInvite
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DomainInviteCopyWith<_DomainInvite> get copyWith => __$DomainInviteCopyWithImpl<_DomainInvite>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DomainInviteToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DomainInvite&&const DeepCollectionEquality().equals(other._codes, _codes)&&(identical(other.stats, stats) || other.stats == stats)&&const DeepCollectionEquality().equals(other._metadata, _metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_codes),stats,const DeepCollectionEquality().hash(_metadata));

@override
String toString() {
  return 'DomainInvite(codes: $codes, stats: $stats, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class _$DomainInviteCopyWith<$Res> implements $DomainInviteCopyWith<$Res> {
  factory _$DomainInviteCopyWith(_DomainInvite value, $Res Function(_DomainInvite) _then) = __$DomainInviteCopyWithImpl;
@override @useResult
$Res call({
 List<DomainInviteCode> codes, InviteStats stats, Map<String, dynamic> metadata
});


@override $InviteStatsCopyWith<$Res> get stats;

}
/// @nodoc
class __$DomainInviteCopyWithImpl<$Res>
    implements _$DomainInviteCopyWith<$Res> {
  __$DomainInviteCopyWithImpl(this._self, this._then);

  final _DomainInvite _self;
  final $Res Function(_DomainInvite) _then;

/// Create a copy of DomainInvite
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? codes = null,Object? stats = null,Object? metadata = null,}) {
  return _then(_DomainInvite(
codes: null == codes ? _self._codes : codes // ignore: cast_nullable_to_non_nullable
as List<DomainInviteCode>,stats: null == stats ? _self.stats : stats // ignore: cast_nullable_to_non_nullable
as InviteStats,metadata: null == metadata ? _self._metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}

/// Create a copy of DomainInvite
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$InviteStatsCopyWith<$Res> get stats {
  
  return $InviteStatsCopyWith<$Res>(_self.stats, (value) {
    return _then(_self.copyWith(stats: value));
  });
}
}


/// @nodoc
mixin _$DomainInviteCode {

/// 邀请码
 String get code;/// 状态（0=未使用, 1=已使用）
 int get status;/// 创建时间
 DateTime? get createdAt;/// 使用时间
 DateTime? get usedAt;/// 元数据
 Map<String, dynamic> get metadata;
/// Create a copy of DomainInviteCode
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DomainInviteCodeCopyWith<DomainInviteCode> get copyWith => _$DomainInviteCodeCopyWithImpl<DomainInviteCode>(this as DomainInviteCode, _$identity);

  /// Serializes this DomainInviteCode to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DomainInviteCode&&(identical(other.code, code) || other.code == code)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.usedAt, usedAt) || other.usedAt == usedAt)&&const DeepCollectionEquality().equals(other.metadata, metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,code,status,createdAt,usedAt,const DeepCollectionEquality().hash(metadata));

@override
String toString() {
  return 'DomainInviteCode(code: $code, status: $status, createdAt: $createdAt, usedAt: $usedAt, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class $DomainInviteCodeCopyWith<$Res>  {
  factory $DomainInviteCodeCopyWith(DomainInviteCode value, $Res Function(DomainInviteCode) _then) = _$DomainInviteCodeCopyWithImpl;
@useResult
$Res call({
 String code, int status, DateTime? createdAt, DateTime? usedAt, Map<String, dynamic> metadata
});




}
/// @nodoc
class _$DomainInviteCodeCopyWithImpl<$Res>
    implements $DomainInviteCodeCopyWith<$Res> {
  _$DomainInviteCodeCopyWithImpl(this._self, this._then);

  final DomainInviteCode _self;
  final $Res Function(DomainInviteCode) _then;

/// Create a copy of DomainInviteCode
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? code = null,Object? status = null,Object? createdAt = freezed,Object? usedAt = freezed,Object? metadata = null,}) {
  return _then(_self.copyWith(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as int,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,usedAt: freezed == usedAt ? _self.usedAt : usedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,metadata: null == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}

}


/// Adds pattern-matching-related methods to [DomainInviteCode].
extension DomainInviteCodePatterns on DomainInviteCode {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DomainInviteCode value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DomainInviteCode() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DomainInviteCode value)  $default,){
final _that = this;
switch (_that) {
case _DomainInviteCode():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DomainInviteCode value)?  $default,){
final _that = this;
switch (_that) {
case _DomainInviteCode() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String code,  int status,  DateTime? createdAt,  DateTime? usedAt,  Map<String, dynamic> metadata)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DomainInviteCode() when $default != null:
return $default(_that.code,_that.status,_that.createdAt,_that.usedAt,_that.metadata);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String code,  int status,  DateTime? createdAt,  DateTime? usedAt,  Map<String, dynamic> metadata)  $default,) {final _that = this;
switch (_that) {
case _DomainInviteCode():
return $default(_that.code,_that.status,_that.createdAt,_that.usedAt,_that.metadata);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String code,  int status,  DateTime? createdAt,  DateTime? usedAt,  Map<String, dynamic> metadata)?  $default,) {final _that = this;
switch (_that) {
case _DomainInviteCode() when $default != null:
return $default(_that.code,_that.status,_that.createdAt,_that.usedAt,_that.metadata);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DomainInviteCode extends DomainInviteCode {
  const _DomainInviteCode({required this.code, this.status = 0, this.createdAt, this.usedAt, final  Map<String, dynamic> metadata = const {}}): _metadata = metadata,super._();
  factory _DomainInviteCode.fromJson(Map<String, dynamic> json) => _$DomainInviteCodeFromJson(json);

/// 邀请码
@override final  String code;
/// 状态（0=未使用, 1=已使用）
@override@JsonKey() final  int status;
/// 创建时间
@override final  DateTime? createdAt;
/// 使用时间
@override final  DateTime? usedAt;
/// 元数据
 final  Map<String, dynamic> _metadata;
/// 元数据
@override@JsonKey() Map<String, dynamic> get metadata {
  if (_metadata is EqualUnmodifiableMapView) return _metadata;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_metadata);
}


/// Create a copy of DomainInviteCode
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DomainInviteCodeCopyWith<_DomainInviteCode> get copyWith => __$DomainInviteCodeCopyWithImpl<_DomainInviteCode>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DomainInviteCodeToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DomainInviteCode&&(identical(other.code, code) || other.code == code)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.usedAt, usedAt) || other.usedAt == usedAt)&&const DeepCollectionEquality().equals(other._metadata, _metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,code,status,createdAt,usedAt,const DeepCollectionEquality().hash(_metadata));

@override
String toString() {
  return 'DomainInviteCode(code: $code, status: $status, createdAt: $createdAt, usedAt: $usedAt, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class _$DomainInviteCodeCopyWith<$Res> implements $DomainInviteCodeCopyWith<$Res> {
  factory _$DomainInviteCodeCopyWith(_DomainInviteCode value, $Res Function(_DomainInviteCode) _then) = __$DomainInviteCodeCopyWithImpl;
@override @useResult
$Res call({
 String code, int status, DateTime? createdAt, DateTime? usedAt, Map<String, dynamic> metadata
});




}
/// @nodoc
class __$DomainInviteCodeCopyWithImpl<$Res>
    implements _$DomainInviteCodeCopyWith<$Res> {
  __$DomainInviteCodeCopyWithImpl(this._self, this._then);

  final _DomainInviteCode _self;
  final $Res Function(_DomainInviteCode) _then;

/// Create a copy of DomainInviteCode
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? code = null,Object? status = null,Object? createdAt = freezed,Object? usedAt = freezed,Object? metadata = null,}) {
  return _then(_DomainInviteCode(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as int,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,usedAt: freezed == usedAt ? _self.usedAt : usedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,metadata: null == metadata ? _self._metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}


}


/// @nodoc
mixin _$InviteStats {

/// 邀请人数
 int get invitedCount;/// 佣金比例（0-1）
 double get commissionRate;/// 待确认佣金（元）
 double get pendingCommission;/// 可用佣金（元）
 double get availableCommission;/// 总佣金（元）
 double get totalCommission;/// 元数据
 Map<String, dynamic> get metadata;
/// Create a copy of InviteStats
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InviteStatsCopyWith<InviteStats> get copyWith => _$InviteStatsCopyWithImpl<InviteStats>(this as InviteStats, _$identity);

  /// Serializes this InviteStats to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InviteStats&&(identical(other.invitedCount, invitedCount) || other.invitedCount == invitedCount)&&(identical(other.commissionRate, commissionRate) || other.commissionRate == commissionRate)&&(identical(other.pendingCommission, pendingCommission) || other.pendingCommission == pendingCommission)&&(identical(other.availableCommission, availableCommission) || other.availableCommission == availableCommission)&&(identical(other.totalCommission, totalCommission) || other.totalCommission == totalCommission)&&const DeepCollectionEquality().equals(other.metadata, metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,invitedCount,commissionRate,pendingCommission,availableCommission,totalCommission,const DeepCollectionEquality().hash(metadata));

@override
String toString() {
  return 'InviteStats(invitedCount: $invitedCount, commissionRate: $commissionRate, pendingCommission: $pendingCommission, availableCommission: $availableCommission, totalCommission: $totalCommission, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class $InviteStatsCopyWith<$Res>  {
  factory $InviteStatsCopyWith(InviteStats value, $Res Function(InviteStats) _then) = _$InviteStatsCopyWithImpl;
@useResult
$Res call({
 int invitedCount, double commissionRate, double pendingCommission, double availableCommission, double totalCommission, Map<String, dynamic> metadata
});




}
/// @nodoc
class _$InviteStatsCopyWithImpl<$Res>
    implements $InviteStatsCopyWith<$Res> {
  _$InviteStatsCopyWithImpl(this._self, this._then);

  final InviteStats _self;
  final $Res Function(InviteStats) _then;

/// Create a copy of InviteStats
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? invitedCount = null,Object? commissionRate = null,Object? pendingCommission = null,Object? availableCommission = null,Object? totalCommission = null,Object? metadata = null,}) {
  return _then(_self.copyWith(
invitedCount: null == invitedCount ? _self.invitedCount : invitedCount // ignore: cast_nullable_to_non_nullable
as int,commissionRate: null == commissionRate ? _self.commissionRate : commissionRate // ignore: cast_nullable_to_non_nullable
as double,pendingCommission: null == pendingCommission ? _self.pendingCommission : pendingCommission // ignore: cast_nullable_to_non_nullable
as double,availableCommission: null == availableCommission ? _self.availableCommission : availableCommission // ignore: cast_nullable_to_non_nullable
as double,totalCommission: null == totalCommission ? _self.totalCommission : totalCommission // ignore: cast_nullable_to_non_nullable
as double,metadata: null == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}

}


/// Adds pattern-matching-related methods to [InviteStats].
extension InviteStatsPatterns on InviteStats {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _InviteStats value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InviteStats() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _InviteStats value)  $default,){
final _that = this;
switch (_that) {
case _InviteStats():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _InviteStats value)?  $default,){
final _that = this;
switch (_that) {
case _InviteStats() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int invitedCount,  double commissionRate,  double pendingCommission,  double availableCommission,  double totalCommission,  Map<String, dynamic> metadata)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InviteStats() when $default != null:
return $default(_that.invitedCount,_that.commissionRate,_that.pendingCommission,_that.availableCommission,_that.totalCommission,_that.metadata);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int invitedCount,  double commissionRate,  double pendingCommission,  double availableCommission,  double totalCommission,  Map<String, dynamic> metadata)  $default,) {final _that = this;
switch (_that) {
case _InviteStats():
return $default(_that.invitedCount,_that.commissionRate,_that.pendingCommission,_that.availableCommission,_that.totalCommission,_that.metadata);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int invitedCount,  double commissionRate,  double pendingCommission,  double availableCommission,  double totalCommission,  Map<String, dynamic> metadata)?  $default,) {final _that = this;
switch (_that) {
case _InviteStats() when $default != null:
return $default(_that.invitedCount,_that.commissionRate,_that.pendingCommission,_that.availableCommission,_that.totalCommission,_that.metadata);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _InviteStats extends InviteStats {
  const _InviteStats({this.invitedCount = 0, this.commissionRate = 0.0, this.pendingCommission = 0.0, this.availableCommission = 0.0, this.totalCommission = 0.0, final  Map<String, dynamic> metadata = const {}}): _metadata = metadata,super._();
  factory _InviteStats.fromJson(Map<String, dynamic> json) => _$InviteStatsFromJson(json);

/// 邀请人数
@override@JsonKey() final  int invitedCount;
/// 佣金比例（0-1）
@override@JsonKey() final  double commissionRate;
/// 待确认佣金（元）
@override@JsonKey() final  double pendingCommission;
/// 可用佣金（元）
@override@JsonKey() final  double availableCommission;
/// 总佣金（元）
@override@JsonKey() final  double totalCommission;
/// 元数据
 final  Map<String, dynamic> _metadata;
/// 元数据
@override@JsonKey() Map<String, dynamic> get metadata {
  if (_metadata is EqualUnmodifiableMapView) return _metadata;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_metadata);
}


/// Create a copy of InviteStats
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InviteStatsCopyWith<_InviteStats> get copyWith => __$InviteStatsCopyWithImpl<_InviteStats>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$InviteStatsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _InviteStats&&(identical(other.invitedCount, invitedCount) || other.invitedCount == invitedCount)&&(identical(other.commissionRate, commissionRate) || other.commissionRate == commissionRate)&&(identical(other.pendingCommission, pendingCommission) || other.pendingCommission == pendingCommission)&&(identical(other.availableCommission, availableCommission) || other.availableCommission == availableCommission)&&(identical(other.totalCommission, totalCommission) || other.totalCommission == totalCommission)&&const DeepCollectionEquality().equals(other._metadata, _metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,invitedCount,commissionRate,pendingCommission,availableCommission,totalCommission,const DeepCollectionEquality().hash(_metadata));

@override
String toString() {
  return 'InviteStats(invitedCount: $invitedCount, commissionRate: $commissionRate, pendingCommission: $pendingCommission, availableCommission: $availableCommission, totalCommission: $totalCommission, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class _$InviteStatsCopyWith<$Res> implements $InviteStatsCopyWith<$Res> {
  factory _$InviteStatsCopyWith(_InviteStats value, $Res Function(_InviteStats) _then) = __$InviteStatsCopyWithImpl;
@override @useResult
$Res call({
 int invitedCount, double commissionRate, double pendingCommission, double availableCommission, double totalCommission, Map<String, dynamic> metadata
});




}
/// @nodoc
class __$InviteStatsCopyWithImpl<$Res>
    implements _$InviteStatsCopyWith<$Res> {
  __$InviteStatsCopyWithImpl(this._self, this._then);

  final _InviteStats _self;
  final $Res Function(_InviteStats) _then;

/// Create a copy of InviteStats
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? invitedCount = null,Object? commissionRate = null,Object? pendingCommission = null,Object? availableCommission = null,Object? totalCommission = null,Object? metadata = null,}) {
  return _then(_InviteStats(
invitedCount: null == invitedCount ? _self.invitedCount : invitedCount // ignore: cast_nullable_to_non_nullable
as int,commissionRate: null == commissionRate ? _self.commissionRate : commissionRate // ignore: cast_nullable_to_non_nullable
as double,pendingCommission: null == pendingCommission ? _self.pendingCommission : pendingCommission // ignore: cast_nullable_to_non_nullable
as double,availableCommission: null == availableCommission ? _self.availableCommission : availableCommission // ignore: cast_nullable_to_non_nullable
as double,totalCommission: null == totalCommission ? _self.totalCommission : totalCommission // ignore: cast_nullable_to_non_nullable
as double,metadata: null == metadata ? _self._metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}


}


/// @nodoc
mixin _$DomainCommission {

/// ID
 int get id;/// 订单号
 String get tradeNo;/// 佣金金额（元）
 double get amount;/// 创建时间
 DateTime get createdAt;/// 元数据
 Map<String, dynamic> get metadata;
/// Create a copy of DomainCommission
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DomainCommissionCopyWith<DomainCommission> get copyWith => _$DomainCommissionCopyWithImpl<DomainCommission>(this as DomainCommission, _$identity);

  /// Serializes this DomainCommission to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DomainCommission&&(identical(other.id, id) || other.id == id)&&(identical(other.tradeNo, tradeNo) || other.tradeNo == tradeNo)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&const DeepCollectionEquality().equals(other.metadata, metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,tradeNo,amount,createdAt,const DeepCollectionEquality().hash(metadata));

@override
String toString() {
  return 'DomainCommission(id: $id, tradeNo: $tradeNo, amount: $amount, createdAt: $createdAt, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class $DomainCommissionCopyWith<$Res>  {
  factory $DomainCommissionCopyWith(DomainCommission value, $Res Function(DomainCommission) _then) = _$DomainCommissionCopyWithImpl;
@useResult
$Res call({
 int id, String tradeNo, double amount, DateTime createdAt, Map<String, dynamic> metadata
});




}
/// @nodoc
class _$DomainCommissionCopyWithImpl<$Res>
    implements $DomainCommissionCopyWith<$Res> {
  _$DomainCommissionCopyWithImpl(this._self, this._then);

  final DomainCommission _self;
  final $Res Function(DomainCommission) _then;

/// Create a copy of DomainCommission
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? tradeNo = null,Object? amount = null,Object? createdAt = null,Object? metadata = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,tradeNo: null == tradeNo ? _self.tradeNo : tradeNo // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,metadata: null == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}

}


/// Adds pattern-matching-related methods to [DomainCommission].
extension DomainCommissionPatterns on DomainCommission {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DomainCommission value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DomainCommission() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DomainCommission value)  $default,){
final _that = this;
switch (_that) {
case _DomainCommission():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DomainCommission value)?  $default,){
final _that = this;
switch (_that) {
case _DomainCommission() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String tradeNo,  double amount,  DateTime createdAt,  Map<String, dynamic> metadata)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DomainCommission() when $default != null:
return $default(_that.id,_that.tradeNo,_that.amount,_that.createdAt,_that.metadata);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String tradeNo,  double amount,  DateTime createdAt,  Map<String, dynamic> metadata)  $default,) {final _that = this;
switch (_that) {
case _DomainCommission():
return $default(_that.id,_that.tradeNo,_that.amount,_that.createdAt,_that.metadata);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String tradeNo,  double amount,  DateTime createdAt,  Map<String, dynamic> metadata)?  $default,) {final _that = this;
switch (_that) {
case _DomainCommission() when $default != null:
return $default(_that.id,_that.tradeNo,_that.amount,_that.createdAt,_that.metadata);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DomainCommission extends DomainCommission {
  const _DomainCommission({required this.id, required this.tradeNo, required this.amount, required this.createdAt, final  Map<String, dynamic> metadata = const {}}): _metadata = metadata,super._();
  factory _DomainCommission.fromJson(Map<String, dynamic> json) => _$DomainCommissionFromJson(json);

/// ID
@override final  int id;
/// 订单号
@override final  String tradeNo;
/// 佣金金额（元）
@override final  double amount;
/// 创建时间
@override final  DateTime createdAt;
/// 元数据
 final  Map<String, dynamic> _metadata;
/// 元数据
@override@JsonKey() Map<String, dynamic> get metadata {
  if (_metadata is EqualUnmodifiableMapView) return _metadata;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_metadata);
}


/// Create a copy of DomainCommission
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DomainCommissionCopyWith<_DomainCommission> get copyWith => __$DomainCommissionCopyWithImpl<_DomainCommission>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DomainCommissionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DomainCommission&&(identical(other.id, id) || other.id == id)&&(identical(other.tradeNo, tradeNo) || other.tradeNo == tradeNo)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&const DeepCollectionEquality().equals(other._metadata, _metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,tradeNo,amount,createdAt,const DeepCollectionEquality().hash(_metadata));

@override
String toString() {
  return 'DomainCommission(id: $id, tradeNo: $tradeNo, amount: $amount, createdAt: $createdAt, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class _$DomainCommissionCopyWith<$Res> implements $DomainCommissionCopyWith<$Res> {
  factory _$DomainCommissionCopyWith(_DomainCommission value, $Res Function(_DomainCommission) _then) = __$DomainCommissionCopyWithImpl;
@override @useResult
$Res call({
 int id, String tradeNo, double amount, DateTime createdAt, Map<String, dynamic> metadata
});




}
/// @nodoc
class __$DomainCommissionCopyWithImpl<$Res>
    implements _$DomainCommissionCopyWith<$Res> {
  __$DomainCommissionCopyWithImpl(this._self, this._then);

  final _DomainCommission _self;
  final $Res Function(_DomainCommission) _then;

/// Create a copy of DomainCommission
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? tradeNo = null,Object? amount = null,Object? createdAt = null,Object? metadata = null,}) {
  return _then(_DomainCommission(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,tradeNo: null == tradeNo ? _self.tradeNo : tradeNo // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,metadata: null == metadata ? _self._metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}


}

// dart format on
