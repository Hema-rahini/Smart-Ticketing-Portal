// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_statistics.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DashboardStatistics _$DashboardStatisticsFromJson(Map<String, dynamic> json) =>
    _DashboardStatistics(
      totalUsers: (json['totalUsers'] as num).toInt(),
      activeDepartments: (json['activeDepartments'] as num).toInt(),
      productivityScore: (json['productivityScore'] as num).toDouble(),
    );

Map<String, dynamic> _$DashboardStatisticsToJson(
  _DashboardStatistics instance,
) => <String, dynamic>{
  'totalUsers': instance.totalUsers,
  'activeDepartments': instance.activeDepartments,
  'productivityScore': instance.productivityScore,
};
