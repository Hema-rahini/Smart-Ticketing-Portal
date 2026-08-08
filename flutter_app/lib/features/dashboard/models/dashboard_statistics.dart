import 'package:freezed_annotation/freezed_annotation.dart';

part 'dashboard_statistics.freezed.dart';
part 'dashboard_statistics.g.dart';

@freezed
abstract class DashboardStatistics with _$DashboardStatistics {
  const factory DashboardStatistics({
    required int totalUsers,
    required int activeDepartments,
    required double productivityScore,
  }) = _DashboardStatistics;

  factory DashboardStatistics.fromJson(Map<String, dynamic> json) =>
      _$DashboardStatisticsFromJson(json);
}
