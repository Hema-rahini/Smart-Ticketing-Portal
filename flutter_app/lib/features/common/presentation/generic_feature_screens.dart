import 'package:flutter/material.dart';
import '../../../widgets/app_drawer.dart';

class GenericFeatureScreen extends StatelessWidget {
  final String title;
  final IconData icon;
  final String description;

  const GenericFeatureScreen({
    super.key,
    required this.title,
    required this.icon,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      drawer: const AppDrawer(),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 48,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 1. Calendar Screen
class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final events = [
      {'title': 'Q3 All Hands Meeting', 'time': '10:00 AM - 11:30 AM', 'type': 'Meeting', 'color': Colors.blue},
      {'title': 'Ticket #102 Code Review', 'time': '02:00 PM - 03:00 PM', 'type': 'Code Review', 'color': Colors.purple},
      {'title': 'Scheduled DB Maintenance', 'time': '11:00 PM - 01:00 AM', 'type': 'Maintenance', 'color': Colors.orange},
      {'title': 'Sprint 24 Retrospective', 'time': 'Tomorrow, 04:00 PM', 'type': 'Scrum', 'color': Colors.green},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Calendar & Schedule')),
      drawer: const AppDrawer(),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Date Selector Header Card
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Today', style: TextStyle(color: Colors.grey, fontSize: 13)),
                      SizedBox(height: 2),
                      Text('Saturday, July 25', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('New Event'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Upcoming Schedule', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 10),
          ...events.map((e) => Card(
                margin: const EdgeInsets.only(bottom: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: (e['color'] as Color).withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.event, color: e['color'] as Color, size: 20),
                  ),
                  title: Text(e['title'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(e['time'] as String),
                  trailing: Chip(
                    label: Text(e['type'] as String, style: const TextStyle(fontSize: 10)),
                    backgroundColor: (e['color'] as Color).withValues(alpha: 0.1),
                  ),
                ),
              )),
        ],
      ),
    );
  }
}

// 2. Leave & Attendance Screen
class LeaveAttendanceScreen extends StatelessWidget {
  const LeaveAttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Leave & Attendance')),
      drawer: const AppDrawer(),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      children: const [
                        Text('Days Present', style: TextStyle(color: Colors.grey, fontSize: 12)),
                        SizedBox(height: 6),
                        Text('22 / 24', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      children: const [
                        Text('Leave Balance', style: TextStyle(color: Colors.grey, fontSize: 12)),
                        SizedBox(height: 6),
                        Text('12 Days', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Leave application form opened.')));
            },
            icon: const Icon(Icons.add_task),
            label: const Text('Apply for Leave'),
          ),
          const SizedBox(height: 20),
          const Text('Recent Leave Requests', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 10),
          const Card(
            child: ListTile(
              leading: Icon(Icons.beach_access, color: Colors.orange),
              title: Text('Annual Vacation'),
              subtitle: Text('Aug 10 - Aug 14 (5 days)'),
              trailing: Chip(label: Text('Approved'), backgroundColor: Colors.greenAccent),
            ),
          ),
          const Card(
            child: ListTile(
              leading: Icon(Icons.medical_services, color: Colors.red),
              title: Text('Sick Leave'),
              subtitle: Text('Jul 02 (1 day)'),
              trailing: Chip(label: Text('Approved'), backgroundColor: Colors.greenAccent),
            ),
          ),
        ],
      ),
    );
  }
}

// 3. Performance Reviews Screen
class PerformanceReviewsScreen extends StatelessWidget {
  const PerformanceReviewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Performance Reviews')),
      drawer: const AppDrawer(),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: const [
                  Text('Overall Performance Score', style: TextStyle(fontSize: 14)),
                  SizedBox(height: 8),
                  Text('4.8 / 5.0', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.blue)),
                  SizedBox(height: 4),
                  Text('Exceeds Expectations (Q2 Evaluation)', style: TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text('Key Metrics & KPIs', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 10),
          const ListTile(
            leading: Icon(Icons.speed, color: Colors.blue),
            title: Text('Ticket Resolution Speed'),
            subtitle: Text('Avg 2.4 hours / ticket'),
            trailing: Text('96%', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
          ),
          const ListTile(
            leading: Icon(Icons.thumb_up, color: Colors.purple),
            title: Text('Customer Satisfaction'),
            subtitle: Text('Positive rating from 45 surveys'),
            trailing: Text('98%', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
          ),
        ],
      ),
    );
  }
}

// 4. Onboarding Screen
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final List<Map<String, dynamic>> _checklist = [
    {'title': 'Complete HR & Tax Information Forms', 'done': true},
    {'title': 'Setup Supabase Account Credentials', 'done': true},
    {'title': 'Enable Multi-Factor Authentication (MFA)', 'done': true},
    {'title': 'Review Team Codebase Guidelines', 'done': false},
    {'title': 'Submit First Resolved Ticket', 'done': false},
  ];

  @override
  Widget build(BuildContext context) {
    final completed = _checklist.where((c) => c['done'] as bool).length;

    return Scaffold(
      appBar: AppBar(title: const Text('Employee Onboarding')),
      drawer: const AppDrawer(),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          LinearProgressIndicator(value: completed / _checklist.length, minHeight: 8),
          const SizedBox(height: 8),
          Text('$completed of ${_checklist.length} Onboarding Tasks Completed', style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 20),
          const Text('Onboarding Checklist', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 10),
          ..._checklist.map((item) => CheckboxListTile(
                title: Text(item['title'] as String),
                value: item['done'] as bool,
                onChanged: (val) {
                  setState(() => item['done'] = val);
                },
              )),
        ],
      ),
    );
  }
}

// 5. Analytics Screen
class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Analytics & Insights')),
      drawer: const AppDrawer(),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: const [
                        Text('SLA Compliance', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        SizedBox(height: 6),
                        Text('98.5%', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: const [
                        Text('Avg Response', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        SizedBox(height: 6),
                        Text('14 mins', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blue)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text('Department Breakdown', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          const ListTile(
            title: Text('Engineering'),
            subtitle: LinearProgressIndicator(value: 0.65),
            trailing: Text('65 Tickets'),
          ),
          const ListTile(
            title: Text('Support & Operations'),
            subtitle: LinearProgressIndicator(value: 0.25),
            trailing: Text('25 Tickets'),
          ),
        ],
      ),
    );
  }
}

// 6. Knowledge Base Screen
class KnowledgeBaseScreen extends StatelessWidget {
  const KnowledgeBaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final articles = [
      {'title': 'How to setup Supabase Auth & RLS', 'time': '5 min read'},
      {'title': 'Flutter Navigation Drawer Configuration Guide', 'time': '8 min read'},
      {'title': 'FastAPI Endpoint Schema & OpenAPI Docs', 'time': '4 min read'},
      {'title': 'Role Permissions & Access Control Overview', 'time': '6 min read'},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Knowledge Base')),
      drawer: const AppDrawer(),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: 'Search documentation articles...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 20),
          const Text('Popular Articles', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 10),
          ...articles.map((a) => Card(
                child: ListTile(
                  leading: const Icon(Icons.article_outlined, color: Colors.blue),
                  title: Text(a['title']!),
                  subtitle: Text(a['time']!),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                ),
              )),
        ],
      ),
    );
  }
}

// 7. Help & Support Screen
class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Help & Support')),
      drawer: const AppDrawer(),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: const ListTile(
              leading: Icon(Icons.headset_mic, size: 32, color: Colors.blue),
              title: Text('Need Immediate Assistance?'),
              subtitle: Text('Contact support team 24/7 or check system status.'),
            ),
          ),
          const SizedBox(height: 20),
          const Text('Frequently Asked Questions (FAQ)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 10),
          const ExpansionTile(
            title: Text('How do I submit a high-priority ticket?'),
            children: [Padding(padding: EdgeInsets.all(12), child: Text('Go to Tickets -> Create Ticket and set Priority to High.'))],
          ),
          const ExpansionTile(
            title: Text('Where can I change my notification preferences?'),
            children: [Padding(padding: EdgeInsets.all(12), child: Text('Navigate to Settings in the drawer and toggle Notifications.'))],
          ),
        ],
      ),
    );
  }
}

// 8. Reports Screen
class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('System Reports')),
      drawer: const AppDrawer(),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
              title: const Text('Monthly Ticket Resolution Report'),
              subtitle: const Text('Generated on Jul 25, 2026'),
              trailing: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Downloading PDF Report...')));
                },
                child: const Text('Export PDF'),
              ),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.table_chart, color: Colors.green),
              title: const Text('User Security Audit Log'),
              subtitle: const Text('Generated on Jul 24, 2026'),
              trailing: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Exporting CSV Audit Log...')));
                },
                child: const Text('Export CSV'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 9. Projects Screen
class ProjectsScreen extends StatelessWidget {
  const ProjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Projects')),
      drawer: const AppDrawer(),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          Card(
            child: ListTile(
              leading: Icon(Icons.folder, color: Colors.amber),
              title: Text('Smart Ticketing Mobile 2.0'),
              subtitle: Text('Progress: 85% • Lead: Alice Admin'),
              trailing: Chip(label: Text('In Progress'), backgroundColor: Colors.blueAccent),
            ),
          ),
          Card(
            child: ListTile(
              leading: Icon(Icons.folder, color: Colors.purple),
              title: Text('Supabase Backend Sync & Security Audit'),
              subtitle: Text('Progress: 100% • Lead: Bob Manager'),
              trailing: Chip(label: Text('Completed'), backgroundColor: Colors.greenAccent),
            ),
          ),
        ],
      ),
    );
  }
}

// 10. Leaderboard Screen
class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Leaderboard')),
      drawer: const AppDrawer(),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          ListTile(
            leading: CircleAvatar(backgroundColor: Colors.amber, child: Text('1', style: TextStyle(fontWeight: FontWeight.bold))),
            title: Text('Alice Admin'),
            subtitle: Text('42 Tickets Solved'),
            trailing: Icon(Icons.emoji_events, color: Colors.amber),
          ),
          ListTile(
            leading: CircleAvatar(backgroundColor: Colors.grey, child: Text('2', style: TextStyle(fontWeight: FontWeight.bold))),
            title: Text('Bob Manager'),
            subtitle: Text('35 Tickets Solved'),
            trailing: Icon(Icons.emoji_events, color: Colors.grey),
          ),
          ListTile(
            leading: CircleAvatar(backgroundColor: Colors.brown, child: Text('3', style: TextStyle(fontWeight: FontWeight.bold))),
            title: Text('Charlie Employee'),
            subtitle: Text('28 Tickets Solved'),
            trailing: Icon(Icons.emoji_events, color: Colors.brown),
          ),
        ],
      ),
    );
  }
}

// 11. Surveys Screen
class SurveysScreen extends StatelessWidget {
  const SurveysScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Surveys & Feedback')),
      drawer: const AppDrawer(),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.star, color: Colors.amber),
              title: const Text('Q3 Customer Support Feedback'),
              subtitle: const Text('Share your experience with ticket response time.'),
              trailing: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Opening Survey Form...')));
                },
                child: const Text('Take Survey'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 12. Collaboration Screen
class CollaborationScreen extends StatelessWidget {
  const CollaborationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Collaboration Boards')),
      drawer: const AppDrawer(),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          Card(
            child: ListTile(
              leading: Icon(Icons.dashboard_customize, color: Colors.teal),
              title: Text('Engineering Kanban Board'),
              subtitle: Text('12 Active Tasks • 4 Columns'),
              trailing: Icon(Icons.arrow_forward_ios, size: 14),
            ),
          ),
        ],
      ),
    );
  }
}

// 13. Departments Screen
class DepartmentsScreen extends StatelessWidget {
  const DepartmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Departments Management')),
      drawer: const AppDrawer(),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          Card(
            child: ListTile(
              leading: Icon(Icons.business, color: Colors.indigo),
              title: Text('Engineering'),
              subtitle: Text('Manager: Bob Manager • 14 Members'),
            ),
          ),
          Card(
            child: ListTile(
              leading: Icon(Icons.support_agent, color: Colors.green),
              title: Text('Customer Support'),
              subtitle: Text('Manager: Edward Support • 8 Members'),
            ),
          ),
        ],
      ),
    );
  }
}

// 14. Notifications Screen
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final List<Map<String, dynamic>> _notifications = [
    {
      'id': '1',
      'title': 'Ticket #102 Status Updated',
      'body': 'Alice Admin marked "Fix Mobile Navigation Overflow" as Completed.',
      'time': '10 mins ago',
      'isRead': false,
      'type': 'ticket',
      'icon': Icons.check_circle_outline,
      'color': Colors.green,
    },
    {
      'id': '2',
      'title': 'New Announcement Broadcast',
      'body': 'Bob Manager posted "Q3 All Hands & Product Roadmap Meeting".',
      'time': '1 hour ago',
      'isRead': false,
      'type': 'announcement',
      'icon': Icons.campaign_outlined,
      'color': Colors.blue,
    },
    {
      'id': '3',
      'title': 'High Priority Ticket Assigned',
      'body': 'You have been assigned to "Database Connection Pool Latency Spike".',
      'time': '3 hours ago',
      'isRead': true,
      'type': 'ticket',
      'icon': Icons.error_outline,
      'color': Colors.redAccent,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final unreadCount = _notifications.where((n) => !(n['isRead'] as bool)).length;

    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications ${unreadCount > 0 ? "($unreadCount)" : ""}'),
        actions: [
          if (unreadCount > 0)
            TextButton(
              onPressed: () {
                setState(() {
                  for (final n in _notifications) {
                    n['isRead'] = true;
                  }
                });
              },
              child: const Text('Mark all as read'),
            ),
        ],
      ),
      drawer: const AppDrawer(),
      body: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: _notifications.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final notif = _notifications[index];
          final isRead = notif['isRead'] as bool;

          return ListTile(
            leading: Icon(notif['icon'] as IconData, color: notif['color'] as Color),
            title: Text(notif['title'] as String, style: TextStyle(fontWeight: isRead ? FontWeight.normal : FontWeight.bold)),
            subtitle: Text(notif['body'] as String),
            trailing: Text(notif['time'] as String, style: const TextStyle(fontSize: 11, color: Colors.grey)),
            onTap: () {
              setState(() => notif['isRead'] = true);
            },
          );
        },
      ),
    );
  }
}
