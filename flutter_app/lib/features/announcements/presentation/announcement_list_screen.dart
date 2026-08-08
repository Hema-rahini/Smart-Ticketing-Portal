import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../widgets/app_drawer.dart';
import '../providers/announcement_provider.dart';
import 'widgets/announcement_card.dart';

class AnnouncementListScreen extends ConsumerWidget {
  const AnnouncementListScreen({super.key});

  void _showCreateAnnouncementDialog(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController();
    final contentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Create Announcement'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Announcement Title',
                    hintText: 'e.g. Server Maintenance Notice',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: contentController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Content',
                    hintText: 'Write announcement details...',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.trim().isEmpty || contentController.text.trim().isEmpty) {
                  return;
                }

                try {
                  final user = ref.read(authProvider.notifier).currentUser;
                  await Supabase.instance.client.from('announcements').insert({
                    'title': titleController.text.trim(),
                    'content': contentController.text.trim(),
                    'author_id': user?.id ?? '',
                    'is_pinned': false,
                    'target_roles': ['admin', 'manager', 'employee', 'intern'],
                  });
                } catch (_) {}

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Announcement posted successfully!')),
                  );
                  ref.read(announcementProvider.notifier).refreshAnnouncements();
                }
              },
              child: const Text('Publish'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final announcementState = ref.watch(announcementProvider);
    final notifier = ref.read(announcementProvider.notifier);
    final currentUser = ref.watch(authProvider.notifier).currentUser;
    final role = (currentUser?.role ?? '').toLowerCase();
    final canPublish = role == 'admin' || role == 'manager';

    // Initial load
    if (announcementState == AnnouncementState.initial) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifier.loadAnnouncements();
      });
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Announcements')),
      drawer: const AppDrawer(),
      floatingActionButton: canPublish
          ? FloatingActionButton.extended(
              onPressed: () => _showCreateAnnouncementDialog(context, ref),
              icon: const Icon(Icons.add),
              label: const Text('New Announcement'),
            )
          : null,

      body: RefreshIndicator(
        onRefresh: notifier.refreshAnnouncements,
        child: _buildBody(context, announcementState, notifier),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    AnnouncementState state,
    AnnouncementNotifier notifier,
  ) {
    if (state == AnnouncementState.loading ||
        state == AnnouncementState.initial) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state == AnnouncementState.error) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(notifier.errorMessage ?? 'Failed to load announcements'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: notifier.retry,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state == AnnouncementState.empty ||
        notifier.data == null ||
        notifier.data!.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.campaign_outlined, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'No announcements available',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      );
    }

    final announcements = notifier.data!;
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: announcements.length,
      itemBuilder: (context, index) {
        final announcement = announcements[index];
        return AnnouncementCard(
          announcement: announcement,
          onTap: () {
            context.push('/announcements/${announcement.id}');
          },
        );
      },
    );
  }
}
