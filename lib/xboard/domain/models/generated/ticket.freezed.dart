// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../ticket.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DomainTicket {

/// 工单 ID
 int get id;/// 标题
 String get subject;/// 优先级（低=0, 中=1, 高=2）
 int get priority;/// 状态
 TicketStatus get status;/// 消息列表
 List<TicketMessage> get messages;/// 创建时间
 DateTime get createdAt;/// 更新时间
 DateTime? get updatedAt;/// 关闭时间
 DateTime? get closedAt;/// 元数据
 Map<String, dynamic> get metadata;
/// Create a copy of DomainTicket
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DomainTicketCopyWith<DomainTicket> get copyWith => _$DomainTicketCopyWithImpl<DomainTicket>(this as DomainTicket, _$identity);

  /// Serializes this DomainTicket to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DomainTicket&&(identical(other.id, id) || other.id == id)&&(identical(other.subject, subject) || other.subject == subject)&&(identical(other.priority, priority) || other.priority == priority)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other.messages, messages)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.closedAt, closedAt) || other.closedAt == closedAt)&&const DeepCollectionEquality().equals(other.metadata, metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,subject,priority,status,const DeepCollectionEquality().hash(messages),createdAt,updatedAt,closedAt,const DeepCollectionEquality().hash(metadata));

@override
String toString() {
  return 'DomainTicket(id: $id, subject: $subject, priority: $priority, status: $status, messages: $messages, createdAt: $createdAt, updatedAt: $updatedAt, closedAt: $closedAt, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class $DomainTicketCopyWith<$Res>  {
  factory $DomainTicketCopyWith(DomainTicket value, $Res Function(DomainTicket) _then) = _$DomainTicketCopyWithImpl;
@useResult
$Res call({
 int id, String subject, int priority, TicketStatus status, List<TicketMessage> messages, DateTime createdAt, DateTime? updatedAt, DateTime? closedAt, Map<String, dynamic> metadata
});




}
/// @nodoc
class _$DomainTicketCopyWithImpl<$Res>
    implements $DomainTicketCopyWith<$Res> {
  _$DomainTicketCopyWithImpl(this._self, this._then);

  final DomainTicket _self;
  final $Res Function(DomainTicket) _then;

/// Create a copy of DomainTicket
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? subject = null,Object? priority = null,Object? status = null,Object? messages = null,Object? createdAt = null,Object? updatedAt = freezed,Object? closedAt = freezed,Object? metadata = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,subject: null == subject ? _self.subject : subject // ignore: cast_nullable_to_non_nullable
as String,priority: null == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TicketStatus,messages: null == messages ? _self.messages : messages // ignore: cast_nullable_to_non_nullable
as List<TicketMessage>,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,closedAt: freezed == closedAt ? _self.closedAt : closedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,metadata: null == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}

}


/// Adds pattern-matching-related methods to [DomainTicket].
extension DomainTicketPatterns on DomainTicket {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DomainTicket value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DomainTicket() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DomainTicket value)  $default,){
final _that = this;
switch (_that) {
case _DomainTicket():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DomainTicket value)?  $default,){
final _that = this;
switch (_that) {
case _DomainTicket() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String subject,  int priority,  TicketStatus status,  List<TicketMessage> messages,  DateTime createdAt,  DateTime? updatedAt,  DateTime? closedAt,  Map<String, dynamic> metadata)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DomainTicket() when $default != null:
return $default(_that.id,_that.subject,_that.priority,_that.status,_that.messages,_that.createdAt,_that.updatedAt,_that.closedAt,_that.metadata);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String subject,  int priority,  TicketStatus status,  List<TicketMessage> messages,  DateTime createdAt,  DateTime? updatedAt,  DateTime? closedAt,  Map<String, dynamic> metadata)  $default,) {final _that = this;
switch (_that) {
case _DomainTicket():
return $default(_that.id,_that.subject,_that.priority,_that.status,_that.messages,_that.createdAt,_that.updatedAt,_that.closedAt,_that.metadata);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String subject,  int priority,  TicketStatus status,  List<TicketMessage> messages,  DateTime createdAt,  DateTime? updatedAt,  DateTime? closedAt,  Map<String, dynamic> metadata)?  $default,) {final _that = this;
switch (_that) {
case _DomainTicket() when $default != null:
return $default(_that.id,_that.subject,_that.priority,_that.status,_that.messages,_that.createdAt,_that.updatedAt,_that.closedAt,_that.metadata);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DomainTicket extends DomainTicket {
  const _DomainTicket({required this.id, required this.subject, this.priority = 1, required this.status, final  List<TicketMessage> messages = const [], required this.createdAt, this.updatedAt, this.closedAt, final  Map<String, dynamic> metadata = const {}}): _messages = messages,_metadata = metadata,super._();
  factory _DomainTicket.fromJson(Map<String, dynamic> json) => _$DomainTicketFromJson(json);

/// 工单 ID
@override final  int id;
/// 标题
@override final  String subject;
/// 优先级（低=0, 中=1, 高=2）
@override@JsonKey() final  int priority;
/// 状态
@override final  TicketStatus status;
/// 消息列表
 final  List<TicketMessage> _messages;
/// 消息列表
@override@JsonKey() List<TicketMessage> get messages {
  if (_messages is EqualUnmodifiableListView) return _messages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_messages);
}

/// 创建时间
@override final  DateTime createdAt;
/// 更新时间
@override final  DateTime? updatedAt;
/// 关闭时间
@override final  DateTime? closedAt;
/// 元数据
 final  Map<String, dynamic> _metadata;
/// 元数据
@override@JsonKey() Map<String, dynamic> get metadata {
  if (_metadata is EqualUnmodifiableMapView) return _metadata;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_metadata);
}


/// Create a copy of DomainTicket
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DomainTicketCopyWith<_DomainTicket> get copyWith => __$DomainTicketCopyWithImpl<_DomainTicket>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DomainTicketToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DomainTicket&&(identical(other.id, id) || other.id == id)&&(identical(other.subject, subject) || other.subject == subject)&&(identical(other.priority, priority) || other.priority == priority)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other._messages, _messages)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.closedAt, closedAt) || other.closedAt == closedAt)&&const DeepCollectionEquality().equals(other._metadata, _metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,subject,priority,status,const DeepCollectionEquality().hash(_messages),createdAt,updatedAt,closedAt,const DeepCollectionEquality().hash(_metadata));

@override
String toString() {
  return 'DomainTicket(id: $id, subject: $subject, priority: $priority, status: $status, messages: $messages, createdAt: $createdAt, updatedAt: $updatedAt, closedAt: $closedAt, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class _$DomainTicketCopyWith<$Res> implements $DomainTicketCopyWith<$Res> {
  factory _$DomainTicketCopyWith(_DomainTicket value, $Res Function(_DomainTicket) _then) = __$DomainTicketCopyWithImpl;
@override @useResult
$Res call({
 int id, String subject, int priority, TicketStatus status, List<TicketMessage> messages, DateTime createdAt, DateTime? updatedAt, DateTime? closedAt, Map<String, dynamic> metadata
});




}
/// @nodoc
class __$DomainTicketCopyWithImpl<$Res>
    implements _$DomainTicketCopyWith<$Res> {
  __$DomainTicketCopyWithImpl(this._self, this._then);

  final _DomainTicket _self;
  final $Res Function(_DomainTicket) _then;

/// Create a copy of DomainTicket
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? subject = null,Object? priority = null,Object? status = null,Object? messages = null,Object? createdAt = null,Object? updatedAt = freezed,Object? closedAt = freezed,Object? metadata = null,}) {
  return _then(_DomainTicket(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,subject: null == subject ? _self.subject : subject // ignore: cast_nullable_to_non_nullable
as String,priority: null == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TicketStatus,messages: null == messages ? _self._messages : messages // ignore: cast_nullable_to_non_nullable
as List<TicketMessage>,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,closedAt: freezed == closedAt ? _self.closedAt : closedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,metadata: null == metadata ? _self._metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}


}


/// @nodoc
mixin _$TicketMessage {

/// 消息 ID
 int get id;/// 消息内容
 String get content;/// 是否来自用户
 bool get isFromUser;/// 是否已读
 bool get isRead;/// 附件列表
 List<String> get attachments;/// 创建时间
 DateTime get createdAt;/// 元数据
 Map<String, dynamic> get metadata;
/// Create a copy of TicketMessage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TicketMessageCopyWith<TicketMessage> get copyWith => _$TicketMessageCopyWithImpl<TicketMessage>(this as TicketMessage, _$identity);

  /// Serializes this TicketMessage to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TicketMessage&&(identical(other.id, id) || other.id == id)&&(identical(other.content, content) || other.content == content)&&(identical(other.isFromUser, isFromUser) || other.isFromUser == isFromUser)&&(identical(other.isRead, isRead) || other.isRead == isRead)&&const DeepCollectionEquality().equals(other.attachments, attachments)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&const DeepCollectionEquality().equals(other.metadata, metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,content,isFromUser,isRead,const DeepCollectionEquality().hash(attachments),createdAt,const DeepCollectionEquality().hash(metadata));

@override
String toString() {
  return 'TicketMessage(id: $id, content: $content, isFromUser: $isFromUser, isRead: $isRead, attachments: $attachments, createdAt: $createdAt, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class $TicketMessageCopyWith<$Res>  {
  factory $TicketMessageCopyWith(TicketMessage value, $Res Function(TicketMessage) _then) = _$TicketMessageCopyWithImpl;
@useResult
$Res call({
 int id, String content, bool isFromUser, bool isRead, List<String> attachments, DateTime createdAt, Map<String, dynamic> metadata
});




}
/// @nodoc
class _$TicketMessageCopyWithImpl<$Res>
    implements $TicketMessageCopyWith<$Res> {
  _$TicketMessageCopyWithImpl(this._self, this._then);

  final TicketMessage _self;
  final $Res Function(TicketMessage) _then;

/// Create a copy of TicketMessage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? content = null,Object? isFromUser = null,Object? isRead = null,Object? attachments = null,Object? createdAt = null,Object? metadata = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,isFromUser: null == isFromUser ? _self.isFromUser : isFromUser // ignore: cast_nullable_to_non_nullable
as bool,isRead: null == isRead ? _self.isRead : isRead // ignore: cast_nullable_to_non_nullable
as bool,attachments: null == attachments ? _self.attachments : attachments // ignore: cast_nullable_to_non_nullable
as List<String>,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,metadata: null == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}

}


/// Adds pattern-matching-related methods to [TicketMessage].
extension TicketMessagePatterns on TicketMessage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TicketMessage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TicketMessage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TicketMessage value)  $default,){
final _that = this;
switch (_that) {
case _TicketMessage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TicketMessage value)?  $default,){
final _that = this;
switch (_that) {
case _TicketMessage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String content,  bool isFromUser,  bool isRead,  List<String> attachments,  DateTime createdAt,  Map<String, dynamic> metadata)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TicketMessage() when $default != null:
return $default(_that.id,_that.content,_that.isFromUser,_that.isRead,_that.attachments,_that.createdAt,_that.metadata);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String content,  bool isFromUser,  bool isRead,  List<String> attachments,  DateTime createdAt,  Map<String, dynamic> metadata)  $default,) {final _that = this;
switch (_that) {
case _TicketMessage():
return $default(_that.id,_that.content,_that.isFromUser,_that.isRead,_that.attachments,_that.createdAt,_that.metadata);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String content,  bool isFromUser,  bool isRead,  List<String> attachments,  DateTime createdAt,  Map<String, dynamic> metadata)?  $default,) {final _that = this;
switch (_that) {
case _TicketMessage() when $default != null:
return $default(_that.id,_that.content,_that.isFromUser,_that.isRead,_that.attachments,_that.createdAt,_that.metadata);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TicketMessage extends TicketMessage {
  const _TicketMessage({required this.id, required this.content, this.isFromUser = true, this.isRead = false, final  List<String> attachments = const [], required this.createdAt, final  Map<String, dynamic> metadata = const {}}): _attachments = attachments,_metadata = metadata,super._();
  factory _TicketMessage.fromJson(Map<String, dynamic> json) => _$TicketMessageFromJson(json);

/// 消息 ID
@override final  int id;
/// 消息内容
@override final  String content;
/// 是否来自用户
@override@JsonKey() final  bool isFromUser;
/// 是否已读
@override@JsonKey() final  bool isRead;
/// 附件列表
 final  List<String> _attachments;
/// 附件列表
@override@JsonKey() List<String> get attachments {
  if (_attachments is EqualUnmodifiableListView) return _attachments;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_attachments);
}

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


/// Create a copy of TicketMessage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TicketMessageCopyWith<_TicketMessage> get copyWith => __$TicketMessageCopyWithImpl<_TicketMessage>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TicketMessageToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TicketMessage&&(identical(other.id, id) || other.id == id)&&(identical(other.content, content) || other.content == content)&&(identical(other.isFromUser, isFromUser) || other.isFromUser == isFromUser)&&(identical(other.isRead, isRead) || other.isRead == isRead)&&const DeepCollectionEquality().equals(other._attachments, _attachments)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&const DeepCollectionEquality().equals(other._metadata, _metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,content,isFromUser,isRead,const DeepCollectionEquality().hash(_attachments),createdAt,const DeepCollectionEquality().hash(_metadata));

@override
String toString() {
  return 'TicketMessage(id: $id, content: $content, isFromUser: $isFromUser, isRead: $isRead, attachments: $attachments, createdAt: $createdAt, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class _$TicketMessageCopyWith<$Res> implements $TicketMessageCopyWith<$Res> {
  factory _$TicketMessageCopyWith(_TicketMessage value, $Res Function(_TicketMessage) _then) = __$TicketMessageCopyWithImpl;
@override @useResult
$Res call({
 int id, String content, bool isFromUser, bool isRead, List<String> attachments, DateTime createdAt, Map<String, dynamic> metadata
});




}
/// @nodoc
class __$TicketMessageCopyWithImpl<$Res>
    implements _$TicketMessageCopyWith<$Res> {
  __$TicketMessageCopyWithImpl(this._self, this._then);

  final _TicketMessage _self;
  final $Res Function(_TicketMessage) _then;

/// Create a copy of TicketMessage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? content = null,Object? isFromUser = null,Object? isRead = null,Object? attachments = null,Object? createdAt = null,Object? metadata = null,}) {
  return _then(_TicketMessage(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,isFromUser: null == isFromUser ? _self.isFromUser : isFromUser // ignore: cast_nullable_to_non_nullable
as bool,isRead: null == isRead ? _self.isRead : isRead // ignore: cast_nullable_to_non_nullable
as bool,attachments: null == attachments ? _self._attachments : attachments // ignore: cast_nullable_to_non_nullable
as List<String>,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,metadata: null == metadata ? _self._metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}


}

// dart format on
