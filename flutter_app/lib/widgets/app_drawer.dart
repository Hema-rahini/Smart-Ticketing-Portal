import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/providers/auth_provider.dart';
import '../features/settings/providers/settings_provider.dart';
import '../core/utils/app_translations.dart';

class DrawerNavItem {
  final String title;
  final IconData icon;
  final String route;
  final List<String> roles;

  const DrawerNavItem({
    required this.title,
    required this.icon,
    required this.route,
    required this.roles,
  });
}

const List<DrawerNavItem> _allNavItems = [
  DrawerNavItem(
    title: 'Dashboard',
    icon: Icons.dashboard_outlined,
    route: '/dashboard',
    roles: ['admin', 'manager', 'employee', 'intern'],
  ),
  DrawerNavItem(
    title: 'Tickets',
    icon: Icons.confirmation_number_outlined,
    route: '/tickets',
    roles: ['admin', 'manager', 'employee', 'intern'],
  ),
  DrawerNavItem(
    title: 'Calendar',
    icon: Icons.calendar_today_outlined,
    route: '/calendar',
    roles: ['admin', 'manager', 'employee', 'intern'],
  ),
  DrawerNavItem(
    title: 'My Tasks',
    icon: Icons.check_box_outlined,
    route: '/tasks',
    roles: ['admin', 'manager', 'employee', 'intern'],
  ),
  DrawerNavItem(
    title: 'Leave & Attendance',
    icon: Icons.calendar_month_outlined,
    route: '/leave',
    roles: ['admin', 'manager', 'employee', 'intern'],
  ),
  DrawerNavItem(
    title: 'Team',
    icon: Icons.people_alt_outlined,
    route: '/team',
    roles: ['admin', 'manager', 'employee', 'intern'],
  ),
  DrawerNavItem(
    title: 'Collaboration',
    icon: Icons.folder_shared_outlined,
    route: '/collaboration',
    roles: ['admin', 'manager', 'employee', 'intern'],
  ),
  DrawerNavItem(
    title: 'Performance Reviews',
    icon: Icons.emoji_events_outlined,
    route: '/performance',
    roles: ['admin', 'manager', 'employee', 'intern'],
  ),
  DrawerNavItem(
    title: 'Onboarding',
    icon: Icons.assignment_turned_in_outlined,
    route: '/onboarding',
    roles: ['admin', 'manager', 'employee', 'intern'],
  ),
  DrawerNavItem(
    title: 'Chat',
    icon: Icons.chat_bubble_outline,
    route: '/messages',
    roles: ['admin', 'manager', 'employee', 'intern'],
  ),
  DrawerNavItem(
    title: 'Analytics',
    icon: Icons.bar_chart_outlined,
    route: '/analytics',
    roles: ['admin', 'manager'],
  ),
  DrawerNavItem(
    title: 'Announcements',
    icon: Icons.campaign_outlined,
    route: '/announcements',
    roles: ['admin', 'manager', 'employee', 'intern'],
  ),
  DrawerNavItem(
    title: 'Knowledge Base',
    icon: Icons.menu_book_outlined,
    route: '/knowledge-base',
    roles: ['admin', 'manager', 'employee', 'intern'],
  ),
  DrawerNavItem(
    title: 'Help & Support',
    icon: Icons.help_outline,
    route: '/support',
    roles: ['admin', 'manager', 'employee', 'intern'],
  ),
  DrawerNavItem(
    title: 'Reports',
    icon: Icons.insert_chart_outlined,
    route: '/reports',
    roles: ['admin', 'manager'],
  ),
  DrawerNavItem(
    title: 'Projects',
    icon: Icons.work_outline,
    route: '/projects',
    roles: ['admin', 'manager', 'employee', 'intern'],
  ),
  DrawerNavItem(
    title: 'Leaderboard',
    icon: Icons.workspace_premium_outlined,
    route: '/leaderboard',
    roles: ['admin', 'manager', 'employee', 'intern'],
  ),
  DrawerNavItem(
    title: 'Surveys',
    icon: Icons.fact_check_outlined,
    route: '/surveys',
    roles: ['admin', 'manager', 'employee', 'intern'],
  ),
  DrawerNavItem(
    title: 'Departments',
    icon: Icons.business_outlined,
    route: '/departments',
    roles: ['admin', 'manager'],
  ),
  DrawerNavItem(
    title: 'User Management',
    icon: Icons.manage_accounts_outlined,
    route: '/users',
    roles: ['admin', 'manager'],
  ),
];

const List<DrawerNavItem> _bottomNavItems = [
  DrawerNavItem(
    title: 'Notifications',
    icon: Icons.notifications_outlined,
    route: '/notifications',
    roles: ['admin', 'manager', 'employee', 'intern'],
  ),
  DrawerNavItem(
    title: 'Profile',
    icon: Icons.account_circle_outlined,
    route: '/profile',
    roles: ['admin', 'manager', 'employee', 'intern'],
  ),
  DrawerNavItem(
    title: 'Settings',
    icon: Icons.settings_outlined,
    route: '/settings',
    roles: ['admin', 'manager', 'employee', 'intern'],
  ),
];

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  static const Color darkNavy = Color(0xFF0F172A);
  static const Color activeBlue = Color(0xFF2563EB);
  static const Color textMuted = Color(0xFF94A3B8);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authNotifier = ref.watch(authProvider.notifier);
    final user = authNotifier.currentUser;
    final role = (user?.role ?? 'employee').toLowerCase();
    final currentRoute = GoRouterState.of(context).matchedLocation;
    final langCode = ref.watch(settingsProvider).languageCode;

    final visibleMainItems = _allNavItems.where((item) => item.roles.contains(role)).toList();
    final visibleBottomItems = _bottomNavItems.where((item) => item.roles.contains(role)).toList();

    return Drawer(
      child: Container(
        color: darkNavy,
        child: Column(
          children: [
            // Top Branding Header
            SafeArea(
              bottom: false,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Color(0xFF1E293B), width: 1),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: activeBlue,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.confirmation_number,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'SmartTicket',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Profile Card Header
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: activeBlue,
                    child: Text(
                      (user?.name ?? 'U')[0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.name ?? 'User',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: activeBlue.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            role.toUpperCase(),
                            style: const TextStyle(
                              color: Color(0xFF60A5FA),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Navigation List
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                children: [
                  ...visibleMainItems.map((item) => _buildNavItem(context, item, currentRoute, langCode)),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Divider(color: Color(0xFF1E293B), height: 1),
                  ),
                  ...visibleBottomItems.map((item) => _buildNavItem(context, item, currentRoute, langCode)),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Divider(color: Color(0xFF1E293B), height: 1),
                  ),
                  // Logout Button
                  InkWell(
                    onTap: () {
                      context.pop();
                      authNotifier.logout();
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      child: Row(
                        children: [
                          const Icon(Icons.logout, color: Colors.redAccent, size: 20),
                          const SizedBox(width: 14),
                          Text(
                            AppTranslations.translate('Logout', langCode),
                            style: const TextStyle(
                              color: Colors.redAccent,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, DrawerNavItem item, String currentRoute, String langCode) {
    final isSelected = currentRoute == item.route || currentRoute.startsWith('${item.route}/');
    final translatedTitle = AppTranslations.translate(item.title, langCode);

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: InkWell(
        onTap: () {
          context.pop(); // close drawer
          if (!isSelected) {
            if (item.route == '/dashboard') {
              context.go('/dashboard');
            } else {
              context.push(item.route);
            }
          }
        },
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? activeBlue : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(
                item.icon,
                color: isSelected ? Colors.white : textMuted,
                size: 20,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  translatedTitle,
                  style: TextStyle(
                    color: isSelected ? Colors.white : textMuted,
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
