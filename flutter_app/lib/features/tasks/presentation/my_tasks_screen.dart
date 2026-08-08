import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../widgets/app_drawer.dart';

class TaskItem {
  final String id;
  final String title;
  final String description;
  final String priority;
  bool isCompleted;
  final DateTime dueDate;
  final String category;

  TaskItem({
    required this.id,
    required this.title,
    required this.description,
    required this.priority,
    this.isCompleted = false,
    required this.dueDate,
    this.category = 'General',
  });
}

class MyTasksScreen extends ConsumerStatefulWidget {
  const MyTasksScreen({super.key});

  @override
  ConsumerState<MyTasksScreen> createState() => _MyTasksScreenState();
}

class _MyTasksScreenState extends ConsumerState<MyTasksScreen> {
  String _filter = 'all'; // 'all', 'pending', 'completed'

  final List<TaskItem> _tasks = [
    TaskItem(
      id: '1',
      title: 'Review Ticket #102 Client Log Files',
      description: 'Check backend server logs and match timestamp error for authentication.',
      priority: 'high',
      isCompleted: false,
      dueDate: DateTime.now().add(const Duration(hours: 4)),
      category: 'Debugging',
    ),
    TaskItem(
      id: '2',
      title: 'Update Mobile Flutter UI Layout',
      description: 'Ensure role cards and drawer navigation render without pixel overflow.',
      priority: 'medium',
      isCompleted: true,
      dueDate: DateTime.now().subtract(const Duration(days: 1)),
      category: 'UI/UX',
    ),
    TaskItem(
      id: '3',
      title: 'Submit Weekly Progress Report',
      description: 'Summarize completed ticketing issues and code commits for team lead.',
      priority: 'low',
      isCompleted: false,
      dueDate: DateTime.now().add(const Duration(days: 2)),
      category: 'Documentation',
    ),
    TaskItem(
      id: '4',
      title: 'Test Supabase Role Permissions (RLS)',
      description: 'Verify RLS rules match Next.js website definitions for admin, manager, employee, intern.',
      priority: 'high',
      isCompleted: false,
      dueDate: DateTime.now().add(const Duration(days: 1)),
      category: 'Security',
    ),
    TaskItem(
      id: '5',
      title: 'Review Open API Specifications v2',
      description: 'Verify OpenAPI JSON endpoint schemas against FastAPI route handlers.',
      priority: 'medium',
      isCompleted: true,
      dueDate: DateTime.now().subtract(const Duration(hours: 12)),
      category: 'API Docs',
    ),
    TaskItem(
      id: '6',
      title: 'Verify Customer Feedback Responses',
      description: 'Filter ticket satisfaction scores from recent survey submissions.',
      priority: 'low',
      isCompleted: false,
      dueDate: DateTime.now().add(const Duration(days: 3)),
      category: 'Support',
    ),
    TaskItem(
      id: '7',
      title: 'Setup Push Notification Handlers',
      description: 'Configure FCM push notification triggers for ticket status updates.',
      priority: 'high',
      isCompleted: false,
      dueDate: DateTime.now().add(const Duration(days: 4)),
      category: 'Engineering',
    ),
    TaskItem(
      id: '8',
      title: 'Complete New Employee Onboarding Module',
      description: 'Review company security policies and verify MFA setup.',
      priority: 'low',
      isCompleted: true,
      dueDate: DateTime.now().subtract(const Duration(days: 2)),
      category: 'Onboarding',
    ),
  ];

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return Colors.redAccent;
      case 'medium':
        return Colors.orangeAccent;
      case 'low':
        return Colors.green;
      default:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredTasks = _tasks.where((t) {
      if (_filter == 'pending') return !t.isCompleted;
      if (_filter == 'completed') return t.isCompleted;
      return true;
    }).toList();

    final completedCount = _tasks.where((t) => t.isCompleted).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tasks'),
      ),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          // Progress Summary Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primaryContainer,
                  Theme.of(context).colorScheme.surface,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: _tasks.isEmpty ? 0 : completedCount / _tasks.length,
                      strokeWidth: 6,
                      backgroundColor: Colors.grey.withValues(alpha: 0.2),
                    ),
                    Text(
                      '${_tasks.isEmpty ? 0 : ((completedCount / _tasks.length) * 100).toInt()}%',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Daily Task Completion',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$completedCount of ${_tasks.length} tasks completed',
                        style: const TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Filter Tabs
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                ChoiceChip(
                  label: Text('All (${_tasks.length})'),
                  selected: _filter == 'all',
                  onSelected: (val) {
                    if (val) setState(() => _filter = 'all');
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: Text('Pending (${_tasks.length - completedCount})'),
                  selected: _filter == 'pending',
                  onSelected: (val) {
                    if (val) setState(() => _filter = 'pending');
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: Text('Completed ($completedCount)'),
                  selected: _filter == 'completed',
                  onSelected: (val) {
                    if (val) setState(() => _filter = 'completed');
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Divider(height: 1),
          // Task List
          Expanded(
            child: filteredTasks.isEmpty
                ? const Center(
                    child: Text(
                      'No tasks found for this filter',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: filteredTasks.length,
                    itemBuilder: (context, index) {
                      final task = filteredTasks[index];
                      final pColor = _getPriorityColor(task.priority);

                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: CheckboxListTile(
                          value: task.isCompleted,
                          activeColor: Theme.of(context).colorScheme.primary,
                          onChanged: (bool? val) {
                            setState(() {
                              task.isCompleted = val ?? false;
                            });
                          },
                          title: Text(
                            task.title,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              decoration: task.isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                              color: task.isCompleted ? Colors.grey : null,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                task.description,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: pColor.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      task.priority.toUpperCase(),
                                      style: TextStyle(
                                        color: pColor,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      task.category,
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Icon(Icons.schedule, size: 12, color: Colors.grey[600]),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Due ${task.dueDate.day}/${task.dueDate.month}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
