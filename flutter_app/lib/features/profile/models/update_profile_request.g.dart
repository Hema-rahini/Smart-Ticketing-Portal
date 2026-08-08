// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_profile_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UpdateProfileRequest _$UpdateProfileRequestFromJson(
  Map<String, dynamic> json,
) => _UpdateProfileRequest(
  name: json['name'] as String?,
  email: json['email'] as String?,
  role: json['role'] as String?,
  avatar: json['avatar'] as String?,
  department: json['department'] as String?,
  managerId: json['manager_id'] as String?,
);

Map<String, dynamic> _$UpdateProfileRequestToJson(
  _UpdateProfileRequest instance,
) => <String, dynamic>{
  'name': instance.name,
  'email': instance.email,
  'role': instance.role,
  'avatar': instance.avatar,
  'department': instance.department,
  'manager_id': instance.managerId,
};
