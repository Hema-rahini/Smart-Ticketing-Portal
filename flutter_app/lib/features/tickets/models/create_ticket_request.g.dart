// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_ticket_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CreateTicketRequest _$CreateTicketRequestFromJson(Map<String, dynamic> json) =>
    _CreateTicketRequest(
      title: json['title'] as String,
      description: json['description'] as String?,
      status: json['status'] as String? ?? 'open',
      priority: json['priority'] as String? ?? 'medium',
      createdBy: json['created_by'] as String,
      assignedTo: (json['assigned_to'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      department: json['department'] as String?,
      dueDate: json['due_date'] == null
          ? null
          : DateTime.parse(json['due_date'] as String),
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
    );

Map<String, dynamic> _$CreateTicketRequestToJson(
  _CreateTicketRequest instance,
) => <String, dynamic>{
  'title': instance.title,
  'description': instance.description,
  'status': instance.status,
  'priority': instance.priority,
  'created_by': instance.createdBy,
  'assigned_to': instance.assignedTo,
  'department': instance.department,
  'due_date': instance.dueDate?.toIso8601String(),
  'tags': instance.tags,
};
