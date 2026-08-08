import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../widgets/app_drawer.dart';

class MessagesScreen extends ConsumerStatefulWidget {
  const MessagesScreen({super.key});

  @override
  ConsumerState<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends ConsumerState<MessagesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> _channels = [
    {
      'name': 'general',
      'unread': 3,
      'lastMsg': 'Welcome to Smart Ticketing team chat! Please check pinned announcements.',
      'time': '10:15 AM'
    },
    {
      'name': 'engineering',
      'unread': 1,
      'lastMsg': 'API endpoints updated and sync tested with Supabase backend.',
      'time': '09:45 AM'
    },
    {
      'name': 'support-tickets',
      'unread': 5,
      'lastMsg': 'High priority ticket #105 assigned to support lead.',
      'time': '08:30 AM'
    },
    {
      'name': 'announcements',
      'unread': 0,
      'lastMsg': 'Q3 System Maintenance window scheduled for Saturday.',
      'time': 'Yesterday'
    },
    {
      'name': 'q3-release',
      'unread': 2,
      'lastMsg': 'All mobile drawer navigation routes verified for v2.0.',
      'time': 'Jul 24'
    },
    {
      'name': 'random',
      'unread': 0,
      'lastMsg': 'Happy Friday team! Have a great weekend.',
      'time': 'Jul 23'
    },
  ];

  final List<Map<String, dynamic>> _directMessages = [
    {
      'name': 'Hema Rahini',
      'role': 'Admin',
      'online': true,
      'lastMsg': 'Please verify user permissions and role guards on staging.',
      'time': '11:00 AM'
    },
    {
      'name': 'Bob Manager',
      'role': 'Manager',
      'online': true,
      'lastMsg': 'Sprint retrospective is set for Friday 10 AM.',
      'time': '10:30 AM'
    },
    {
      'name': 'Charlie Employee',
      'role': 'Employee',
      'online': false,
      'lastMsg': 'Completed unit test coverage for ticketing module.',
      'time': 'Yesterday'
    },
    {
      'name': 'Diana Intern',
      'role': 'Intern',
      'online': true,
      'lastMsg': 'Submitted the API documentation draft for review.',
      'time': 'Jul 24'
    },
    {
      'name': 'Edward Support',
      'role': 'Manager',
      'online': false,
      'lastMsg': 'Updated SLA metrics for support ticket responses.',
      'time': 'Jul 23'
    },
    {
      'name': 'Fiona QA',
      'role': 'Employee',
      'online': true,
      'lastMsg': 'Ran automated integration test suite successfully.',
      'time': 'Jul 22'
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages & Chat'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.tag), text: 'Channels'),
            Tab(icon: Icon(Icons.person_outline), text: 'Direct Messages'),
          ],
        ),
      ),
      drawer: const AppDrawer(),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Channels List
          ListView.separated(
            padding: const EdgeInsets.all(8),
            itemCount: _channels.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final ch = _channels[index];
              final unread = ch['unread'] as int;

              return ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.tag,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                title: Text(
                  '#${ch['name']}',
                  style: TextStyle(
                    fontWeight: unread > 0 ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                subtitle: Text(
                  ch['lastMsg'],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      ch['time'],
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                    if (unread > 0) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '$unread',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Opening #${ch['name']} channel...')),
                  );
                },
              );
            },
          ),
          // Direct Messages List
          ListView.separated(
            padding: const EdgeInsets.all(8),
            itemCount: _directMessages.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final dm = _directMessages[index];
              final isOnline = dm['online'] as bool;

              return ListTile(
                leading: Stack(
                  children: [
                    CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                      child: Text(
                        dm['name'][0].toUpperCase(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                    if (isOnline)
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                        ),
                      ),
                  ],
                ),
                title: Row(
                  children: [
                    Text(
                      dm['name'],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        dm['role'],
                        style: const TextStyle(fontSize: 9),
                      ),
                    ),
                  ],
                ),
                subtitle: Text(
                  dm['lastMsg'],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Text(
                  dm['time'],
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Opening chat with ${dm['name']}...')),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
