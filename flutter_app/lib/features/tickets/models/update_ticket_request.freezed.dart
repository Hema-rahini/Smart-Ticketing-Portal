// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'update_ticket_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UpdateTicketRequest {

 String? get title; String? get description; String? get status; String? get priority;@JsonKey(name: 'assigned_to') List<String>? get assignedTo; String? get department;@JsonKey(name: 'due_date') DateTime? get dueDate; List<String>? get tags;
/// Create a copy of UpdateTicketRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UpdateTicketRequestCopyWith<UpdateTicketRequest> get copyWith => _$UpdateTicketRequestCopyWithImpl<UpdateTicketRequest>(this as UpdateTicketRequest, _$identity);

  /// Serializes this UpdateTicketRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdateTicketRequest&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.status, status) || other.status == status)&&(identical(other.priority, priority) || other.priority == priority)&&const DeepCollectionEquality().equals(other.assignedTo, assignedTo)&&(identical(other.department, department) || other.department == department)&&(identical(other.dueDate, dueDate) || other.dueDate == dueDate)&&const DeepCollectionEquality().equals(other.tags, tags));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,title,description,status,priority,const DeepCollectionEquality().hash(assignedTo),department,dueDate,const DeepCollectionEquality().hash(tags));

@override
String toString() {
  return 'UpdateTicketRequest(title: $title, description: $description, status: $status, priority: $priority, assignedTo: $assignedTo, department: $department, dueDate: $dueDate, tags: $tags)';
}


}

/// @nodoc
abstract mixin class $UpdateTicketRequestCopyWith<$Res>  {
  factory $UpdateTicketRequestCopyWith(UpdateTicketRequest value, $Res Function(UpdateTicketRequest) _then) = _$UpdateTicketRequestCopyWithImpl;
@useResult
$Res call({
 String? title, String? description, String? status, String? priority,@JsonKey(name: 'assigned_to') List<String>? assignedTo, String? department,@JsonKey(name: 'due_date') DateTime? dueDate, List<String>? tags
});




}
/// @nodoc
class _$UpdateTicketRequestCopyWithImpl<$Res>
    implements $UpdateTicketRequestCopyWith<$Res> {
  _$UpdateTicketRequestCopyWithImpl(this._self, this._then);

  final UpdateTicketRequest _self;
  final $Res Function(UpdateTicketRequest) _then;

/// Create a copy of UpdateTicketRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? title = freezed,Object? description = freezed,Object? status = freezed,Object? priority = freezed,Object? assignedTo = freezed,Object? department = freezed,Object? dueDate = freezed,Object? tags = freezed,}) {
  return _then(_self.copyWith(
title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String?,priority: freezed == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as String?,assignedTo: freezed == assignedTo ? _self.assignedTo : assignedTo // ignore: cast_nullable_to_non_nullable
as List<String>?,department: freezed == department ? _self.department : department // ignore: cast_nullable_to_non_nullable
as String?,dueDate: freezed == dueDate ? _self.dueDate : dueDate // ignore: cast_nullable_to_non_nullable
as DateTime?,tags: freezed == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>?,
  ));
}

}


/// Adds pattern-matching-related methods to [UpdateTicketRequest].
extension UpdateTicketRequestPatterns on UpdateTicketRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UpdateTicketRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UpdateTicketRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UpdateTicketRequest value)  $default,){
final _that = this;
switch (_that) {
case _UpdateTicketRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UpdateTicketRequest value)?  $default,){
final _that = this;
switch (_that) {
case _UpdateTicketRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? title,  String? description,  String? status,  String? priority, @JsonKey(name: 'assigned_to')  List<String>? assignedTo,  String? department, @JsonKey(name: 'due_date')  DateTime? dueDate,  List<String>? tags)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UpdateTicketRequest() when $default != null:
return $default(_that.title,_that.description,_that.status,_that.priority,_that.assignedTo,_that.department,_that.dueDate,_that.tags);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? title,  String? description,  String? status,  String? priority, @JsonKey(name: 'assigned_to')  List<String>? assignedTo,  String? department, @JsonKey(name: 'due_date')  DateTime? dueDate,  List<String>? tags)  $default,) {final _that = this;
switch (_that) {
case _UpdateTicketRequest():
return $default(_that.title,_that.description,_that.status,_that.priority,_that.assignedTo,_that.department,_that.dueDate,_that.tags);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? title,  String? description,  String? status,  String? priority, @JsonKey(name: 'assigned_to')  List<String>? assignedTo,  String? department, @JsonKey(name: 'due_date')  DateTime? dueDate,  List<String>? tags)?  $default,) {final _that = this;
switch (_that) {
case _UpdateTicketRequest() when $default != null:
return $default(_that.title,_that.description,_that.status,_that.priority,_that.assignedTo,_that.department,_that.dueDate,_that.tags);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UpdateTicketRequest implements UpdateTicketRequest {
  const _UpdateTicketRequest({this.title, this.description, this.status, this.priority, @JsonKey(name: 'assigned_to') final  List<String>? assignedTo, this.department, @JsonKey(name: 'due_date') this.dueDate, final  List<String>? tags}): _assignedTo = assignedTo,_tags = tags;
  factory _UpdateTicketRequest.fromJson(Map<String, dynamic> json) => _$UpdateTicketRequestFromJson(json);

@override final  String? title;
@override final  String? description;
@override final  String? status;
@override final  String? priority;
 final  List<String>? _assignedTo;
@override@JsonKey(name: 'assigned_to') List<String>? get assignedTo {
  final value = _assignedTo;
  if (value == null) return null;
  if (_assignedTo is EqualUnmodifiableListView) return _assignedTo;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override final  String? department;
@override@JsonKey(name: 'due_date') final  DateTime? dueDate;
 final  List<String>? _tags;
@override List<String>? get tags {
  final value = _tags;
  if (value == null) return null;
  if (_tags is EqualUnmodifiableListView) return _tags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of UpdateTicketRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UpdateTicketRequestCopyWith<_UpdateTicketRequest> get copyWith => __$UpdateTicketRequestCopyWithImpl<_UpdateTicketRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UpdateTicketRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpdateTicketRequest&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.status, status) || other.status == status)&&(identical(other.priority, priority) || other.priority == priority)&&const DeepCollectionEquality().equals(other._assignedTo, _assignedTo)&&(identical(other.department, department) || other.department == department)&&(identical(other.dueDate, dueDate) || other.dueDate == dueDate)&&const DeepCollectionEquality().equals(other._tags, _tags));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,title,description,status,priority,const DeepCollectionEquality().hash(_assignedTo),department,dueDate,const DeepCollectionEquality().hash(_tags));

@override
String toString() {
  return 'UpdateTicketRequest(title: $title, description: $description, status: $status, priority: $priority, assignedTo: $assignedTo, department: $department, dueDate: $dueDate, tags: $tags)';
}


}

/// @nodoc
abstract mixin class _$UpdateTicketRequestCopyWith<$Res> implements $UpdateTicketRequestCopyWith<$Res> {
  factory _$UpdateTicketRequestCopyWith(_UpdateTicketRequest value, $Res Function(_UpdateTicketRequest) _then) = __$UpdateTicketRequestCopyWithImpl;
@override @useResult
$Res call({
 String? title, String? description, String? status, String? priority,@JsonKey(name: 'assigned_to') List<String>? assignedTo, String? department,@JsonKey(name: 'due_date') DateTime? dueDate, List<String>? tags
});




}
/// @nodoc
class __$UpdateTicketRequestCopyWithImpl<$Res>
    implements _$UpdateTicketRequestCopyWith<$Res> {
  __$UpdateTicketRequestCopyWithImpl(this._self, this._then);

  final _UpdateTicketRequest _self;
  final $Res Function(_UpdateTicketRequest) _then;

/// Create a copy of UpdateTicketRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? title = freezed,Object? description = freezed,Object? status = freezed,Object? priority = freezed,Object? assignedTo = freezed,Object? department = freezed,Object? dueDate = freezed,Object? tags = freezed,}) {
  return _then(_UpdateTicketRequest(
title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String?,priority: freezed == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as String?,assignedTo: freezed == assignedTo ? _self._assignedTo : assignedTo // ignore: cast_nullable_to_non_nullable
as List<String>?,department: freezed == department ? _self.department : department // ignore: cast_nullable_to_non_nullable
as String?,dueDate: freezed == dueDate ? _self.dueDate : dueDate // ignore: cast_nullable_to_non_nullable
as DateTime?,tags: freezed == tags ? _self._tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>?,
  ));
}


}

// dart format on
