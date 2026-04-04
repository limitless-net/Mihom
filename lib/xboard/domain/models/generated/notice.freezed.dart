// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../notice.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DomainNotice {

/// 公告 ID
 int get id;/// 标题
 String get title;/// 内容
 String get content;/// 图片 URL列表
 List<String> get imageUrls;/// 标签列表
 List<String> get tags;/// 是否显示
 bool get isVisible;/// 创建时间
 DateTime get createdAt;/// 更新时间
 DateTime? get updatedAt;/// 元数据
 Map<String, dynamic> get metadata;
/// Create a copy of DomainNotice
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DomainNoticeCopyWith<DomainNotice> get copyWith => _$DomainNoticeCopyWithImpl<DomainNotice>(this as DomainNotice, _$identity);

  /// Serializes this DomainNotice to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DomainNotice&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.content, content) || other.content == content)&&const DeepCollectionEquality().equals(other.imageUrls, imageUrls)&&const DeepCollectionEquality().equals(other.tags, tags)&&(identical(other.isVisible, isVisible) || other.isVisible == isVisible)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&const DeepCollectionEquality().equals(other.metadata, metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,content,const DeepCollectionEquality().hash(imageUrls),const DeepCollectionEquality().hash(tags),isVisible,createdAt,updatedAt,const DeepCollectionEquality().hash(metadata));

@override
String toString() {
  return 'DomainNotice(id: $id, title: $title, content: $content, imageUrls: $imageUrls, tags: $tags, isVisible: $isVisible, createdAt: $createdAt, updatedAt: $updatedAt, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class $DomainNoticeCopyWith<$Res>  {
  factory $DomainNoticeCopyWith(DomainNotice value, $Res Function(DomainNotice) _then) = _$DomainNoticeCopyWithImpl;
@useResult
$Res call({
 int id, String title, String content, List<String> imageUrls, List<String> tags, bool isVisible, DateTime createdAt, DateTime? updatedAt, Map<String, dynamic> metadata
});




}
/// @nodoc
class _$DomainNoticeCopyWithImpl<$Res>
    implements $DomainNoticeCopyWith<$Res> {
  _$DomainNoticeCopyWithImpl(this._self, this._then);

  final DomainNotice _self;
  final $Res Function(DomainNotice) _then;

/// Create a copy of DomainNotice
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? content = null,Object? imageUrls = null,Object? tags = null,Object? isVisible = null,Object? createdAt = null,Object? updatedAt = freezed,Object? metadata = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,imageUrls: null == imageUrls ? _self.imageUrls : imageUrls // ignore: cast_nullable_to_non_nullable
as List<String>,tags: null == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,isVisible: null == isVisible ? _self.isVisible : isVisible // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,metadata: null == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}

}


/// Adds pattern-matching-related methods to [DomainNotice].
extension DomainNoticePatterns on DomainNotice {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DomainNotice value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DomainNotice() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DomainNotice value)  $default,){
final _that = this;
switch (_that) {
case _DomainNotice():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DomainNotice value)?  $default,){
final _that = this;
switch (_that) {
case _DomainNotice() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String title,  String content,  List<String> imageUrls,  List<String> tags,  bool isVisible,  DateTime createdAt,  DateTime? updatedAt,  Map<String, dynamic> metadata)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DomainNotice() when $default != null:
return $default(_that.id,_that.title,_that.content,_that.imageUrls,_that.tags,_that.isVisible,_that.createdAt,_that.updatedAt,_that.metadata);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String title,  String content,  List<String> imageUrls,  List<String> tags,  bool isVisible,  DateTime createdAt,  DateTime? updatedAt,  Map<String, dynamic> metadata)  $default,) {final _that = this;
switch (_that) {
case _DomainNotice():
return $default(_that.id,_that.title,_that.content,_that.imageUrls,_that.tags,_that.isVisible,_that.createdAt,_that.updatedAt,_that.metadata);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String title,  String content,  List<String> imageUrls,  List<String> tags,  bool isVisible,  DateTime createdAt,  DateTime? updatedAt,  Map<String, dynamic> metadata)?  $default,) {final _that = this;
switch (_that) {
case _DomainNotice() when $default != null:
return $default(_that.id,_that.title,_that.content,_that.imageUrls,_that.tags,_that.isVisible,_that.createdAt,_that.updatedAt,_that.metadata);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DomainNotice extends DomainNotice {
  const _DomainNotice({required this.id, required this.title, required this.content, final  List<String> imageUrls = const [], final  List<String> tags = const [], this.isVisible = true, required this.createdAt, this.updatedAt, final  Map<String, dynamic> metadata = const {}}): _imageUrls = imageUrls,_tags = tags,_metadata = metadata,super._();
  factory _DomainNotice.fromJson(Map<String, dynamic> json) => _$DomainNoticeFromJson(json);

/// 公告 ID
@override final  int id;
/// 标题
@override final  String title;
/// 内容
@override final  String content;
/// 图片 URL列表
 final  List<String> _imageUrls;
/// 图片 URL列表
@override@JsonKey() List<String> get imageUrls {
  if (_imageUrls is EqualUnmodifiableListView) return _imageUrls;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_imageUrls);
}

/// 标签列表
 final  List<String> _tags;
/// 标签列表
@override@JsonKey() List<String> get tags {
  if (_tags is EqualUnmodifiableListView) return _tags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tags);
}

/// 是否显示
@override@JsonKey() final  bool isVisible;
/// 创建时间
@override final  DateTime createdAt;
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


/// Create a copy of DomainNotice
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DomainNoticeCopyWith<_DomainNotice> get copyWith => __$DomainNoticeCopyWithImpl<_DomainNotice>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DomainNoticeToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DomainNotice&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.content, content) || other.content == content)&&const DeepCollectionEquality().equals(other._imageUrls, _imageUrls)&&const DeepCollectionEquality().equals(other._tags, _tags)&&(identical(other.isVisible, isVisible) || other.isVisible == isVisible)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&const DeepCollectionEquality().equals(other._metadata, _metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,content,const DeepCollectionEquality().hash(_imageUrls),const DeepCollectionEquality().hash(_tags),isVisible,createdAt,updatedAt,const DeepCollectionEquality().hash(_metadata));

@override
String toString() {
  return 'DomainNotice(id: $id, title: $title, content: $content, imageUrls: $imageUrls, tags: $tags, isVisible: $isVisible, createdAt: $createdAt, updatedAt: $updatedAt, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class _$DomainNoticeCopyWith<$Res> implements $DomainNoticeCopyWith<$Res> {
  factory _$DomainNoticeCopyWith(_DomainNotice value, $Res Function(_DomainNotice) _then) = __$DomainNoticeCopyWithImpl;
@override @useResult
$Res call({
 int id, String title, String content, List<String> imageUrls, List<String> tags, bool isVisible, DateTime createdAt, DateTime? updatedAt, Map<String, dynamic> metadata
});




}
/// @nodoc
class __$DomainNoticeCopyWithImpl<$Res>
    implements _$DomainNoticeCopyWith<$Res> {
  __$DomainNoticeCopyWithImpl(this._self, this._then);

  final _DomainNotice _self;
  final $Res Function(_DomainNotice) _then;

/// Create a copy of DomainNotice
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? content = null,Object? imageUrls = null,Object? tags = null,Object? isVisible = null,Object? createdAt = null,Object? updatedAt = freezed,Object? metadata = null,}) {
  return _then(_DomainNotice(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,imageUrls: null == imageUrls ? _self._imageUrls : imageUrls // ignore: cast_nullable_to_non_nullable
as List<String>,tags: null == tags ? _self._tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,isVisible: null == isVisible ? _self.isVisible : isVisible // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,metadata: null == metadata ? _self._metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}


}

// dart format on
