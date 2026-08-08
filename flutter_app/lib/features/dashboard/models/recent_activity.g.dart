// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recent_activity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RecentActivity _$RecentActivityFromJson(Map<String, dynamic> json) =>
    _RecentActivity(
      id: json['id'] as String,
      type: json['type'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      author: json['author'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );

Map<String, dynamic> _$RecentActivityToJson(_RecentActivity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'title': instance.title,
      'description': instance.description,
      'author': instance.author,
      'timestamp': instance.timestamp.toIso8601String(),
    };
