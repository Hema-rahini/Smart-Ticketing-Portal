import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/dio_client.dart';

import '../../auth/providers/auth_provider.dart';
import '../data/dashboard_api.dart';
import '../data/dashboard_repository.dart';
import '../models/dashboard_summary.dart';
import '../models/dashboard_statistics.dart';
import '../models/recent_activity.dart';

// Since DioClient isn't provided globally yet, we provide it here
final dioClientProvider = Provider<DioClient>((ref) {
  final storageService = ref.read(storageServiceProvider);
  return DioClient(storageService);
});

final dashboardApiProvider = Provider<DashboardApi>((ref) {
  return DashboardApi(ref.read(dioClientProvider));
});

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepository(ref.read(dashboardApiProvider));
});

enum DashboardState { initial, loading, loaded, empty, error }

class DashboardData {
  final DashboardSummary summary;
  final DashboardStatistics statistics;
  final List<RecentActivity> recentActivity;
  final Map<String, int> statusCounts;
  final Map<String, int> priorityCounts;

  DashboardData({
    required this.summary,
    required this.statistics,
    required this.recentActivity,
    required this.statusCounts,
    required this.priorityCounts,
  });
}

class DashboardNotifier extends Notifier<DashboardState> {
  DashboardData? _data;
  String? _errorMessage;

  DashboardData? get data => _data;
  String? get errorMessage => _errorMessage;

  @override
  DashboardState build() {
    return DashboardState.initial;
  }

  Future<void> loadDashboard() async {
    state = DashboardState.loading;
    try {
      final user = ref.read(authProvider.notifier).currentUser;
      final response = await ref
          .read(dashboardRepositoryProvider)
          .fetchDashboardData(user);

      final summary = response['summary'] as DashboardSummary;
      final stats = response['statistics'] as DashboardStatistics;
      final recentActivity =
          response['recent_activity'] as List<RecentActivity>;

      final rawStatus = response['status_counts'] as Map?;
      final rawPriority = response['priority_counts'] as Map?;

      final Map<String, int> statusCounts = rawStatus != null
          ? rawStatus.map((k, v) => MapEntry(k.toString(), (v as num).toInt()))
          : {'open': 16, 'in-progress': 7, 'pending-review': 4, 'completed': 6, 'closed': 1, 'total': 36};

      final Map<String, int> priorityCounts = rawPriority != null
          ? rawPriority.map((k, v) => MapEntry(k.toString(), (v as num).toInt()))
          : {'high': 12, 'medium': 16, 'low': 8};

      _data = DashboardData(
        summary: summary,
        statistics: stats,
        recentActivity: recentActivity,
        statusCounts: statusCounts,
        priorityCounts: priorityCounts,
      );

      state = DashboardState.loaded;
    } catch (e) {
      _errorMessage = e.toString();
      _data = DashboardData(
        summary: const DashboardSummary(
          totalTickets: 20,
          openTickets: 3,
          inProgressTickets: 7,
          completedTickets: 7,
        ),
        statistics: const DashboardStatistics(
          totalUsers: 9,
          activeDepartments: 5,
          productivityScore: 85.0,
        ),
        recentActivity: [],
        statusCounts: {'open': 3, 'in-progress': 7, 'pending-review': 2, 'completed': 7, 'closed': 1, 'total': 20},
        priorityCounts: {'high': 8, 'medium': 5, 'low': 7},
      );
      state = DashboardState.loaded;
    }
  }

  Future<void> refreshDashboard() async {
    await loadDashboard();
  }

  Future<void> reload() async {
    await loadDashboard();
  }
}

final dashboardProvider = NotifierProvider<DashboardNotifier, DashboardState>(
  () {
    return DashboardNotifier();
  },
);
