import 'package:freezed_annotation/freezed_annotation.dart';

part 'recent_activity.freezed.dart';
part 'recent_activity.g.dart';

@freezed
abstract class RecentActivity with _$RecentActivity {
  const factory RecentActivity({
    required String id,
    required String type, // 'ticket', 'announcement', 'user'
    required String title,
    required String description,
    required String author,
    required DateTime timestamp,
  }) = _RecentActivity;

  factory RecentActivity.fromJson(Map<String, dynamic> json) =>
      _$RecentActivityFromJson(json);
}
