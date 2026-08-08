// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_ticket_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UpdateTicketRequest _$UpdateTicketRequestFromJson(Map<String, dynamic> json) =>
    _UpdateTicketRequest(
      title: json['title'] as String?,
      description: json['description'] as String?,
      status: json['status'] as String?,
      priority: json['priority'] as String?,
      assignedTo: (json['assigned_to'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      department: json['department'] as String?,
      dueDate: json['due_date'] == null
          ? null
          : DateTime.parse(json['due_date'] as String),
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
    );

Map<String, dynamic> _$UpdateTicketRequestToJson(
  _UpdateTicketRequest instance,
) => <String, dynamic>{
  'title': instance.title,
  'description': instance.description,
  'status': instance.status,
  'priority': instance.priority,
  'assigned_to': instance.assignedTo,
  'department': instance.department,
  'due_date': instance.dueDate?.toIso8601String(),
  'tags': instance.tags,
};
