import 'package:flutter/material.dart';
import '../../models/recent_activity.dart';
import 'package:intl/intl.dart';

class RecentActivityList extends StatelessWidget {
  final List<RecentActivity> activities;

  const RecentActivityList({super.key, required this.activities});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.history, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Recent Activity',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (activities.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24.0),
                child: Center(child: Text('No recent activity')),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: activities.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final activity = activities[index];
                  final isTicket = activity.type == 'ticket';
                  final icon = isTicket
                      ? Icons.confirmation_number
                      : Icons.campaign;
                  final color = isTicket ? Colors.blue : Colors.orange;

                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: color.withAlpha(25),
                      child: Icon(icon, color: color, size: 20),
                    ),
                    title: Text(
                      '${activity.author} ${activity.description}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Text(
                      '${activity.title} • ${DateFormat.yMd().add_jm().format(activity.timestamp)}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
