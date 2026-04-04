// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../initialization_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$InitializationState {

/// 当前状态
 InitializationStatus get status;/// 当前使用的域名
 String? get currentDomain;/// 错误信息
 String? get errorMessage;/// 域名延迟（毫秒）
 int? get latency;/// 最后检查时间
 DateTime? get lastChecked;/// 当前步骤描述
 String? get currentStepDescription;
/// Create a copy of InitializationState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InitializationStateCopyWith<InitializationState> get copyWith => _$InitializationStateCopyWithImpl<InitializationState>(this as InitializationState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InitializationState&&(identical(other.status, status) || other.status == status)&&(identical(other.currentDomain, currentDomain) || other.currentDomain == currentDomain)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.latency, latency) || other.latency == latency)&&(identical(other.lastChecked, lastChecked) || other.lastChecked == lastChecked)&&(identical(other.currentStepDescription, currentStepDescription) || other.currentStepDescription == currentStepDescription));
}


@override
int get hashCode => Object.hash(runtimeType,status,currentDomain,errorMessage,latency,lastChecked,currentStepDescription);

@override
String toString() {
  return 'InitializationState(status: $status, currentDomain: $currentDomain, errorMessage: $errorMessage, latency: $latency, lastChecked: $lastChecked, currentStepDescription: $currentStepDescription)';
}


}

/// @nodoc
abstract mixin class $InitializationStateCopyWith<$Res>  {
  factory $InitializationStateCopyWith(InitializationState value, $Res Function(InitializationState) _then) = _$InitializationStateCopyWithImpl;
@useResult
$Res call({
 InitializationStatus status, String? currentDomain, String? errorMessage, int? latency, DateTime? lastChecked, String? currentStepDescription
});




}
/// @nodoc
class _$InitializationStateCopyWithImpl<$Res>
    implements $InitializationStateCopyWith<$Res> {
  _$InitializationStateCopyWithImpl(this._self, this._then);

  final InitializationState _self;
  final $Res Function(InitializationState) _then;

/// Create a copy of InitializationState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? currentDomain = freezed,Object? errorMessage = freezed,Object? latency = freezed,Object? lastChecked = freezed,Object? currentStepDescription = freezed,}) {
  return _then(_self.copyWith(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as InitializationStatus,currentDomain: freezed == currentDomain ? _self.currentDomain : currentDomain // ignore: cast_nullable_to_non_nullable
as String?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,latency: freezed == latency ? _self.latency : latency // ignore: cast_nullable_to_non_nullable
as int?,lastChecked: freezed == lastChecked ? _self.lastChecked : lastChecked // ignore: cast_nullable_to_non_nullable
as DateTime?,currentStepDescription: freezed == currentStepDescription ? _self.currentStepDescription : currentStepDescription // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [InitializationState].
extension InitializationStatePatterns on InitializationState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _InitializationState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InitializationState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _InitializationState value)  $default,){
final _that = this;
switch (_that) {
case _InitializationState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _InitializationState value)?  $default,){
final _that = this;
switch (_that) {
case _InitializationState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( InitializationStatus status,  String? currentDomain,  String? errorMessage,  int? latency,  DateTime? lastChecked,  String? currentStepDescription)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InitializationState() when $default != null:
return $default(_that.status,_that.currentDomain,_that.errorMessage,_that.latency,_that.lastChecked,_that.currentStepDescription);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( InitializationStatus status,  String? currentDomain,  String? errorMessage,  int? latency,  DateTime? lastChecked,  String? currentStepDescription)  $default,) {final _that = this;
switch (_that) {
case _InitializationState():
return $default(_that.status,_that.currentDomain,_that.errorMessage,_that.latency,_that.lastChecked,_that.currentStepDescription);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( InitializationStatus status,  String? currentDomain,  String? errorMessage,  int? latency,  DateTime? lastChecked,  String? currentStepDescription)?  $default,) {final _that = this;
switch (_that) {
case _InitializationState() when $default != null:
return $default(_that.status,_that.currentDomain,_that.errorMessage,_that.latency,_that.lastChecked,_that.currentStepDescription);case _:
  return null;

}
}

}

/// @nodoc


class _InitializationState extends InitializationState {
  const _InitializationState({this.status = InitializationStatus.idle, this.currentDomain, this.errorMessage, this.latency, this.lastChecked, this.currentStepDescription}): super._();
  

/// 当前状态
@override@JsonKey() final  InitializationStatus status;
/// 当前使用的域名
@override final  String? currentDomain;
/// 错误信息
@override final  String? errorMessage;
/// 域名延迟（毫秒）
@override final  int? latency;
/// 最后检查时间
@override final  DateTime? lastChecked;
/// 当前步骤描述
@override final  String? currentStepDescription;

/// Create a copy of InitializationState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InitializationStateCopyWith<_InitializationState> get copyWith => __$InitializationStateCopyWithImpl<_InitializationState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _InitializationState&&(identical(other.status, status) || other.status == status)&&(identical(other.currentDomain, currentDomain) || other.currentDomain == currentDomain)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.latency, latency) || other.latency == latency)&&(identical(other.lastChecked, lastChecked) || other.lastChecked == lastChecked)&&(identical(other.currentStepDescription, currentStepDescription) || other.currentStepDescription == currentStepDescription));
}


@override
int get hashCode => Object.hash(runtimeType,status,currentDomain,errorMessage,latency,lastChecked,currentStepDescription);

@override
String toString() {
  return 'InitializationState(status: $status, currentDomain: $currentDomain, errorMessage: $errorMessage, latency: $latency, lastChecked: $lastChecked, currentStepDescription: $currentStepDescription)';
}


}

/// @nodoc
abstract mixin class _$InitializationStateCopyWith<$Res> implements $InitializationStateCopyWith<$Res> {
  factory _$InitializationStateCopyWith(_InitializationState value, $Res Function(_InitializationState) _then) = __$InitializationStateCopyWithImpl;
@override @useResult
$Res call({
 InitializationStatus status, String? currentDomain, String? errorMessage, int? latency, DateTime? lastChecked, String? currentStepDescription
});




}
/// @nodoc
class __$InitializationStateCopyWithImpl<$Res>
    implements _$InitializationStateCopyWith<$Res> {
  __$InitializationStateCopyWithImpl(this._self, this._then);

  final _InitializationState _self;
  final $Res Function(_InitializationState) _then;

/// Create a copy of InitializationState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? currentDomain = freezed,Object? errorMessage = freezed,Object? latency = freezed,Object? lastChecked = freezed,Object? currentStepDescription = freezed,}) {
  return _then(_InitializationState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as InitializationStatus,currentDomain: freezed == currentDomain ? _self.currentDomain : currentDomain // ignore: cast_nullable_to_non_nullable
as String?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,latency: freezed == latency ? _self.latency : latency // ignore: cast_nullable_to_non_nullable
as int?,lastChecked: freezed == lastChecked ? _self.lastChecked : lastChecked // ignore: cast_nullable_to_non_nullable
as DateTime?,currentStepDescription: freezed == currentStepDescription ? _self.currentStepDescription : currentStepDescription // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
