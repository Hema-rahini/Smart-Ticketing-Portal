import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/auth/presentation/splash_screen.dart';
import '../../features/auth/presentation/login_screen.dart';

import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/tickets/presentation/ticket_list_screen.dart';
import '../../features/tickets/presentation/ticket_detail_screen.dart';
import '../../features/tickets/presentation/create_ticket_screen.dart';
import '../../features/announcements/presentation/announcement_list_screen.dart';
import '../../features/announcements/presentation/announcement_detail_screen.dart';
import '../../features/messages/presentation/messages_screen.dart';
import '../../features/users/presentation/user_management_screen.dart';
import '../../features/team/presentation/team_screen.dart';
import '../../features/tasks/presentation/my_tasks_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/profile/presentation/edit_profile_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/common/presentation/generic_feature_screens.dart';

class AppRouter {
  static bool isAuthenticated = false;
  static String? userRole;

  static final router = GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/tickets',
        builder: (context, state) => const TicketListScreen(),
        routes: [
          GoRoute(
            path: 'create-ticket',
            builder: (context, state) => const CreateTicketScreen(),
          ),
          GoRoute(
            path: ':id',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return TicketDetailScreen(ticketId: id);
            },
          ),
        ],
      ),
      GoRoute(
        path: '/announcements',
        builder: (context, state) => const AnnouncementListScreen(),
        routes: [
          GoRoute(
            path: ':id',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return AnnouncementDetailScreen(announcementId: id);
            },
          ),
        ],
      ),
      GoRoute(
        path: '/messages',
        builder: (context, state) => const MessagesScreen(),
      ),
      GoRoute(
        path: '/users',
        builder: (context, state) => const UserManagementScreen(),
      ),
      GoRoute(
        path: '/team',
        builder: (context, state) => const TeamScreen(),
      ),
      GoRoute(
        path: '/tasks',
        builder: (context, state) => const MyTasksScreen(),
      ),
      GoRoute(
        path: '/calendar',
        builder: (context, state) => const CalendarScreen(),
      ),
      GoRoute(
        path: '/leave',
        builder: (context, state) => const LeaveAttendanceScreen(),
      ),
      GoRoute(
        path: '/collaboration',
        builder: (context, state) => const CollaborationScreen(),
      ),
      GoRoute(
        path: '/performance',
        builder: (context, state) => const PerformanceReviewsScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/analytics',
        builder: (context, state) => const AnalyticsScreen(),
      ),
      GoRoute(
        path: '/knowledge-base',
        builder: (context, state) => const KnowledgeBaseScreen(),
      ),
      GoRoute(
        path: '/support',
        builder: (context, state) => const HelpSupportScreen(),
      ),
      GoRoute(
        path: '/reports',
        builder: (context, state) => const ReportsScreen(),
      ),
      GoRoute(
        path: '/projects',
        builder: (context, state) => const ProjectsScreen(),
      ),
      GoRoute(
        path: '/leaderboard',
        builder: (context, state) => const LeaderboardScreen(),
      ),
      GoRoute(
        path: '/surveys',
        builder: (context, state) => const SurveysScreen(),
      ),
      GoRoute(
        path: '/departments',
        builder: (context, state) => const DepartmentsScreen(),
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
        routes: [
          GoRoute(
            path: 'edit',
            builder: (context, state) => const EditProfileScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
    redirect: (context, state) {
      final loc = state.matchedLocation;
      final isLoggingIn = loc == '/login';
      final isSplash = loc == '/splash';

      if (isSplash) return null;

      bool isAuth = isAuthenticated;
      String? role = userRole;

      try {
        final session = Supabase.instance.client.auth.currentSession;
        if (session != null && !session.isExpired) {
          isAuth = true;
          final userMeta = session.user.userMetadata;
          if (userMeta != null && userMeta['role'] != null) {
            role = userMeta['role'].toString().toLowerCase();
          }
        }
      } catch (_) {}

      if (!isAuth && !isLoggingIn) {
        return '/login';
      }

      if (isAuth && isLoggingIn) {
        return '/dashboard';
      }

      // Role-Based Access Control Guards (page navigation enabled for all 4 roles)
      if (isAuth && role != null) {
        if (loc == '/users' && role != 'admin' && role != 'manager') {
          return '/dashboard';
        }
      }

      return null;
    },
  );
}
