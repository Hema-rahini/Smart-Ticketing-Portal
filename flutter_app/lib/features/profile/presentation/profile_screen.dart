import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/profile_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../tickets/providers/ticket_provider.dart';
import '../../settings/providers/settings_provider.dart';
import '../../../core/utils/app_translations.dart';
import 'widgets/profile_header.dart';
import 'widgets/profile_details_card.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _newPassController = TextEditingController();
  final _confirmPassController = TextEditingController();
  bool _isUpdatingPass = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(profileProvider.notifier).loadProfile());
  }

  @override
  void dispose() {
    _newPassController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  Future<void> _updatePassword() async {
    final newPass = _newPassController.text.trim();
    final confirmPass = _confirmPassController.text.trim();

    if (newPass.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password must be at least 6 characters.')),
      );
      return;
    }
    if (newPass != confirmPass) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match.')),
      );
      return;
    }

    setState(() => _isUpdatingPass = true);
    try {
      final supabase = Supabase.instance.client;
      await supabase.auth.updateUser(UserAttributes(password: newPass));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password updated successfully!')),
        );
        _newPassController.clear();
        _confirmPassController.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update password: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isUpdatingPass = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileProvider);
    final notifier = ref.read(profileProvider.notifier);
    final langCode = ref.watch(settingsProvider).languageCode;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppTranslations.translate('My Profile', langCode)),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: state == ProfileState.loaded && notifier.profile != null
                ? () => context.go('/profile/edit')
                : null,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(authProvider.notifier).logout();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: notifier.refreshProfile,
        child: _buildBody(state, notifier, langCode),
      ),
    );
  }

  Widget _buildBody(ProfileState state, ProfileNotifier notifier, String langCode) {
    final profile = notifier.profile;

    if (state == ProfileState.loading && profile == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (profile == null) {
      // Trigger load again if profile is null
      Future.microtask(() => notifier.loadProfile());
      return const Center(child: CircularProgressIndicator());
    }

    ref.watch(ticketProvider);
    final ticketData = ref.read(ticketProvider.notifier).data;
    final allTickets = ticketData?.allTickets ?? [];
    final userId = profile.id;
    final userTickets = allTickets.where((t) => t.createdBy == userId || (t.assignedTo?.contains(userId) ?? false)).toList();

    final createdCount = allTickets.where((t) => t.createdBy == userId).length;
    final assignedCount = userTickets.length;
    final completedCount = userTickets.where((t) => t.status == 'completed').length;
    final inProgressCount = userTickets.where((t) => t.status == 'in-progress').length;

    final isAdmin = profile.role.toLowerCase() == 'admin';

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        ProfileHeader(profile: profile),
        const SizedBox(height: 16),

        // Admin Special Permissions Card
        if (isAdmin) ...[
          Card(
            elevation: 0,
            color: Colors.red.shade50,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.red.shade200),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.admin_panel_settings, color: Colors.red.shade700),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Admin Password & Security Controls',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.red.shade900,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'As an Admin, you have full permission to reset/change passwords for any user in the organization from User Management.',
                    style: TextStyle(fontSize: 12, color: Colors.red.shade800),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => context.go('/users'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade700,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: const Icon(Icons.people_alt_outlined, size: 18),
                      label: const Text(
                        'Manage & Change User Passwords',
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Profile Stats Grid
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.35,
          children: [
            _buildStatCard('Tickets Created', '$createdCount', Icons.confirmation_number, Colors.blue),
            _buildStatCard('Assigned to Me', '$assignedCount', Icons.person_outline, Colors.purple),
            _buildStatCard('Completed', '$completedCount', Icons.check_circle_outline, Colors.green),
            _buildStatCard('In Progress', '$inProgressCount', Icons.timelapse, Colors.amber),
          ],
        ),
        const SizedBox(height: 20),

        ProfileDetailsCard(profile: profile),
        const SizedBox(height: 20),

        // Change Password Card (Own Password)
        Card(
          elevation: 0,
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.lock_reset, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      'Change Password',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _newPassController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'New Password',
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _confirmPassController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Confirm New Password',
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isUpdatingPass ? null : _updatePassword,
                    icon: _isUpdatingPass
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.save),
                    label: Text(_isUpdatingPass ? 'Updating...' : 'Save New Password'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: Colors.grey),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

}
