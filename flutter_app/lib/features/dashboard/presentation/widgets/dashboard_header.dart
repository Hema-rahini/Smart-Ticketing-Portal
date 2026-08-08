import 'package:flutter/material.dart';
import '../../../auth/models/user_model.dart';

class DashboardHeader extends StatelessWidget {
  final UserModel? user;

  const DashboardHeader({super.key, this.user});

  @override
  Widget build(BuildContext context) {
    final name = user?.name ?? 'User';
    final role = user?.role ?? 'employee';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome back, ${name.split(' ').first}!',
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          'Here\'s what\'s happening with your ${role == 'admin'
              ? 'organization'
              : role == 'manager'
              ? 'team'
              : 'tasks'} today.',
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
        ),
      ],
    );
  }
}
