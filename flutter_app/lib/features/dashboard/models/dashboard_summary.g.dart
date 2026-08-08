// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_summary.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DashboardSummary _$DashboardSummaryFromJson(Map<String, dynamic> json) =>
    _DashboardSummary(
      totalTickets: (json['totalTickets'] as num).toInt(),
      openTickets: (json['openTickets'] as num).toInt(),
      inProgressTickets: (json['inProgressTickets'] as num).toInt(),
      completedTickets: (json['completedTickets'] as num).toInt(),
    );

Map<String, dynamic> _$DashboardSummaryToJson(_DashboardSummary instance) =>
    <String, dynamic>{
      'totalTickets': instance.totalTickets,
      'openTickets': instance.openTickets,
      'inProgressTickets': instance.inProgressTickets,
      'completedTickets': instance.completedTickets,
    };
