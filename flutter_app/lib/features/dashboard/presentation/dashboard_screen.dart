import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth/providers/auth_provider.dart';
import '../models/dashboard_summary.dart';
import '../models/dashboard_statistics.dart';
import '../models/recent_activity.dart';
import '../providers/dashboard_provider.dart';
import '../../settings/providers/settings_provider.dart';
import '../../../core/utils/app_translations.dart';
import 'widgets/dashboard_header.dart';
import 'widgets/statistics_card.dart';
import 'widgets/quick_action_card.dart';
import 'widgets/recent_activity_list.dart';
import 'widgets/ticket_status_chart.dart';
import 'widgets/ticket_priority_chart.dart';
import '../../../widgets/app_drawer.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(dashboardProvider.notifier).loadDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(dashboardProvider);
    final dashboardNotifier = ref.read(dashboardProvider.notifier);
    final user = ref.watch(authProvider.notifier).currentUser;
    final langCode = ref.watch(settingsProvider).languageCode;

    final summary = dashboardNotifier.data?.summary ??
        const DashboardSummary(
          totalTickets: 20,
          openTickets: 3,
          inProgressTickets: 7,
          completedTickets: 7,
        );

    final stats = dashboardNotifier.data?.statistics ??
        const DashboardStatistics(
          totalUsers: 9,
          activeDepartments: 5,
          productivityScore: 85.0,
        );

    final activities = dashboardNotifier.data?.recentActivity ??
        [
          RecentActivity(
            id: 'demo-1',
            type: 'ticket',
            title: 'Fix Navigation Router Redirects',
            description: 'Ticket completed',
            author: 'Engineering',
            timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
          ),
          RecentActivity(
            id: 'demo-2',
            type: 'announcement',
            title: 'Welcome to Smart Ticketing Portal',
            description: 'System-wide portal is live!',
            author: 'Admin',
            timestamp: DateTime.now().subtract(const Duration(hours: 2)),
          ),
          RecentActivity(
            id: 'demo-3',
            type: 'ticket',
            title: 'Supabase DB Sync Setup',
            description: 'Ticket in-progress',
            author: 'Product',
            timestamp: DateTime.now().subtract(const Duration(hours: 5)),
          ),
        ];

    return Scaffold(
      appBar: AppBar(
        title: Text(AppTranslations.translate('Dashboard', langCode)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => dashboardNotifier.refreshDashboard(),
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: RefreshIndicator(
        onRefresh: () => dashboardNotifier.refreshDashboard(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DashboardHeader(user: user),
                const SizedBox(height: 20),

                // Statistics Grid (Matching website exact 4 cards per role)
                LayoutBuilder(
                  builder: (context, constraints) {
                    int crossAxisCount = constraints.maxWidth > 600 ? 4 : 2;
                    final role = (user?.role ?? 'admin').toLowerCase();
                    final pendingReview = dashboardNotifier.data?.statusCounts['pending-review'] ?? 4;

                    List<Widget> cards = [];

                    if (role == 'admin') {
                      cards = [
                        StatisticsCard(
                          title: AppTranslations.translate('Total Tickets', langCode),
                          value: '${summary.totalTickets}',
                          icon: Icons.confirmation_number_outlined,
                          color: const Color(0xFF3B82F6),
                          trendText: 'from last month',
                          isPositiveTrend: true,
                        ),
                        StatisticsCard(
                          title: AppTranslations.translate('Open Tickets', langCode),
                          value: '${summary.openTickets}',
                          icon: Icons.error_outline,
                          color: const Color(0xFF3B82F6),
                          trendText: 'needs attention',
                          isPositiveTrend: false,
                        ),
                        StatisticsCard(
                          title: AppTranslations.translate('Completed', langCode),
                          value: '${summary.completedTickets}',
                          icon: Icons.check_circle_outline,
                          color: const Color(0xFF3B82F6),
                          trendText: 'this month',
                          isPositiveTrend: true,
                        ),
                        StatisticsCard(
                          title: AppTranslations.translate('Total Users', langCode),
                          value: '${stats.totalUsers}',
                          icon: Icons.people_outline,
                          color: const Color(0xFF3B82F6),
                          trendText: 'active members',
                        ),
                      ];
                    } else if (role == 'manager') {
                      cards = [
                        StatisticsCard(
                          title: AppTranslations.translate('Team Tickets', langCode),
                          value: '${summary.totalTickets}',
                          icon: Icons.confirmation_number_outlined,
                          color: const Color(0xFF3B82F6),
                          trendText: 'from last week',
                          isPositiveTrend: true,
                        ),
                        StatisticsCard(
                          title: AppTranslations.translate('In Progress', langCode),
                          value: '${summary.inProgressTickets}',
                          icon: Icons.access_time_outlined,
                          color: const Color(0xFF3B82F6),
                          trendText: 'being worked on',
                        ),
                        StatisticsCard(
                          title: AppTranslations.translate('Pending Review', langCode),
                          value: '$pendingReview',
                          icon: Icons.error_outline,
                          color: const Color(0xFF3B82F6),
                          trendText: 'awaiting review',
                        ),
                        StatisticsCard(
                          title: AppTranslations.translate('Completed', langCode),
                          value: '${summary.completedTickets}',
                          icon: Icons.check_circle_outline,
                          color: const Color(0xFF3B82F6),
                          trendText: 'this week',
                          isPositiveTrend: true,
                        ),
                      ];
                    } else if (role == 'employee') {
                      cards = [
                        StatisticsCard(
                          title: AppTranslations.translate('My Tickets', langCode),
                          value: '${summary.totalTickets}',
                          icon: Icons.confirmation_number_outlined,
                          color: const Color(0xFF3B82F6),
                          trendText: 'total assigned',
                        ),
                        StatisticsCard(
                          title: AppTranslations.translate('Open', langCode),
                          value: '${summary.openTickets}',
                          icon: Icons.error_outline,
                          color: const Color(0xFF3B82F6),
                          trendText: 'needs action',
                          isPositiveTrend: false,
                        ),
                        StatisticsCard(
                          title: AppTranslations.translate('In Progress', langCode),
                          value: '${summary.inProgressTickets}',
                          icon: Icons.access_time_outlined,
                          color: const Color(0xFF3B82F6),
                          trendText: 'currently working',
                        ),
                        StatisticsCard(
                          title: AppTranslations.translate('Completed', langCode),
                          value: '${summary.completedTickets}',
                          icon: Icons.check_circle_outline,
                          color: const Color(0xFF3B82F6),
                          trendText: 'this week',
                          isPositiveTrend: true,
                        ),
                      ];
                    } else {
                      // Intern
                      cards = [
                        StatisticsCard(
                          title: AppTranslations.translate('Assigned Tasks', langCode),
                          value: '${summary.totalTickets}',
                          icon: Icons.confirmation_number_outlined,
                          color: const Color(0xFF3B82F6),
                          trendText: 'total tasks',
                        ),
                        StatisticsCard(
                          title: AppTranslations.translate('Pending', langCode),
                          value: '${summary.openTickets + summary.inProgressTickets}',
                          icon: Icons.access_time_outlined,
                          color: const Color(0xFF3B82F6),
                          trendText: 'in queue',
                        ),
                        StatisticsCard(
                          title: AppTranslations.translate('Pending Review', langCode),
                          value: '$pendingReview',
                          icon: Icons.error_outline,
                          color: const Color(0xFF3B82F6),
                          trendText: 'awaiting feedback',
                        ),
                        StatisticsCard(
                          title: AppTranslations.translate('Completed', langCode),
                          value: '${summary.completedTickets}',
                          icon: Icons.check_circle_outline,
                          color: const Color(0xFF3B82F6),
                          trendText: 'great progress!',
                          isPositiveTrend: true,
                        ),
                      ];
                    }

                    return GridView.count(
                      crossAxisCount: crossAxisCount,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.05,
                      children: cards,
                    );
                  },
                ),

                const SizedBox(height: 20),

                // Dashboard Charts (Status Donut & Priority Bar)
                const TicketStatusChart(),
                const SizedBox(height: 16),
                const TicketPriorityChart(),
                const SizedBox(height: 20),

                // Quick Actions & Recent Activity
                _buildQuickActions(context, langCode, user?.role == 'admin'),
                const SizedBox(height: 20),
                RecentActivityList(activities: activities),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, String langCode, bool isAdmin) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppTranslations.translate('Quick Actions', langCode),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                if (!isAdmin) ...[
                  Expanded(
                    child: QuickActionCard(
                      title: AppTranslations.translate('Create Ticket', langCode),
                      icon: Icons.add,
                      onTap: () {
                        context.push('/tickets/create-ticket');
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
                Expanded(
                  child: QuickActionCard(
                    title: AppTranslations.translate('View Team', langCode),
                    icon: Icons.group,
                    onTap: () {
                      context.push('/team');
                    },
                  ),
                ),
                if (isAdmin) ...[
                  const SizedBox(width: 10),
                  Expanded(
                    child: QuickActionCard(
                      title: AppTranslations.translate('Announcements', langCode),
                      icon: Icons.campaign,
                      onTap: () {
                        context.push('/announcements');
                      },
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
