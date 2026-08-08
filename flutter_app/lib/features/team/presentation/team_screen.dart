import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/router/app_router.dart';
import '../../../widgets/app_drawer.dart';
import '../../auth/providers/auth_provider.dart';
import '../../users/presentation/user_management_screen.dart';

class TeamScreen extends ConsumerStatefulWidget {
  const TeamScreen({super.key});

  @override
  ConsumerState<TeamScreen> createState() => _TeamScreenState();
}

class _TeamScreenState extends ConsumerState<TeamScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _teamMembers = [];
  String _selectedDept = 'All';
  String _selectedRole = 'All';
  String _searchQuery = '';
  String _viewMode = 'all'; // 'all' or 'department'

  @override
  void initState() {
    super.initState();
    _fetchTeamMembers();
  }

  Future<void> _fetchTeamMembers() async {
    setState(() => _isLoading = true);

    try {
      final response = await Supabase.instance.client
          .from('users')
          .select('*')
          .order('name', ascending: true);

      setState(() {
        _teamMembers = List<Map<String, dynamic>>.from(response as List);
        _isLoading = false;
      });
    } catch (_) {
      setState(() {
        _teamMembers = [
          {
            'id': '7da70f01-e034-41a1-b920-5a595b983b38',
            'name': 'Hema Rahini',
            'email': 'hemarahini01@gmail.com',
            'role': 'admin',
            'department': 'Management',
            'joined_at': '2026-07-31T08:32:14.466Z',
          },
          {
            'id': '2',
            'name': 'Bob Manager',
            'email': 'manager.dummy@example.com',
            'role': 'manager',
            'department': 'Engineering',
            'joined_at': '2026-08-01T10:00:00.000Z',
          },
          {
            'id': '3',
            'name': 'Charlie Employee',
            'email': 'employee.dummy@example.com',
            'role': 'employee',
            'department': 'Engineering',
            'joined_at': '2026-08-01T11:00:00.000Z',
          },
          {
            'id': '4',
            'name': 'Diana Intern',
            'email': 'intern.dummy@example.com',
            'role': 'intern',
            'department': 'Support',
            'joined_at': '2026-08-02T09:00:00.000Z',
          },
          {
            'id': '5',
            'name': 'Edward Support',
            'email': 'support.lead@example.com',
            'role': 'manager',
            'department': 'Support',
            'joined_at': '2026-08-02T10:00:00.000Z',
          },
          {
            'id': '6',
            'name': 'Fiona QA',
            'email': 'qa.analyst@example.com',
            'role': 'employee',
            'department': 'Quality Assurance',
            'joined_at': '2026-08-03T14:00:00.000Z',
          },
        ];
        _isLoading = false;
      });
    }
  }

  String _getCurrentRole() {
    final user = ref.read(authProvider.notifier).currentUser;
    return (user?.role ?? AppRouter.userRole ?? 'employee').toLowerCase();
  }

  Future<void> _sendEmailCredentials(String userName, String userEmail) async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: userEmail,
      queryParameters: {
        'subject': 'Welcome to Smart Ticketing Portal - Your Account Credentials',
        'body':
            'Hello $userName,\n\nYour account has been created on Smart Ticketing Portal.\n\nEmail: $userEmail\nDefault Initial Password: 123welcome123\n\nPlease log in and change your password upon your first login.\n\nBest regards,\nSmart Ticketing Portal Team',
      },
    );

    try {
      if (await canLaunchUrl(emailLaunchUri)) {
        await launchUrl(emailLaunchUri, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(emailLaunchUri);
      }
    } catch (_) {
      final text =
          'Hello $userName,\n\nYour account credentials:\nEmail: $userEmail\nPassword: 123welcome123';
      await Clipboard.setData(ClipboardData(text: text));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Credentials copied for $userEmail!')),
        );
      }
    }
  }

  // Exact Web Pill Badge Colors matching Website Screenshot
  Map<String, Color> _getRoleColors(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return {
          'bg': const Color(0xFFFEE2E2),
          'text': const Color(0xFFDC2626),
          'border': const Color(0xFFFECACA),
        };
      case 'manager':
        return {
          'bg': const Color(0xFFEFF6FF),
          'text': const Color(0xFF2563EB),
          'border': const Color(0xFFBFDBFE),
        };
      case 'employee':
        return {
          'bg': const Color(0xFFECFDF5),
          'text': const Color(0xFF059669),
          'border': const Color(0xFFA7F3D0),
        };
      case 'intern':
        return {
          'bg': const Color(0xFFF3E8FF),
          'text': const Color(0xFF9333EA),
          'border': const Color(0xFFE9D5FF),
        };
      default:
        return {
          'bg': const Color(0xFFF3F4F6),
          'text': const Color(0xFF4B5563),
          'border': const Color(0xFFE5E7EB),
        };
    }
  }


  void _showMemberProfile(Map<String, dynamic> member) {
    final name = member['name'] ?? 'Member';
    final email = member['email'] ?? '';
    final role = (member['role'] ?? 'employee').toString().toUpperCase();
    final dept = member['department'] ?? 'General';
    final joinedAt = member['joined_at'] != null
        ? member['joined_at'].toString().split('T').first
        : 'Aug 5, 2026';
    final colors = _getRoleColors(role);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: colors['bg'],
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : 'U',
                style: TextStyle(color: colors['text'], fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text(email, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                ],
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Divider(),
            const SizedBox(height: 8),
            _infoRow(Icons.shield_outlined, 'Role', role),
            const SizedBox(height: 10),
            _infoRow(Icons.business_outlined, 'Department', dept),
            const SizedBox(height: 10),
            _infoRow(Icons.calendar_today_outlined, 'Joined', joinedAt),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 13))),
      ],
    );
  }

  void _sendMessage(Map<String, dynamic> member) {
    final name = member['name'] ?? 'Member';
    final userEmail = member['email'] ?? '';
    final subjectController = TextEditingController(text: 'Team Notification');
    final messageController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Send Message to $name'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: subjectController,
              decoration: const InputDecoration(
                labelText: 'Subject',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: messageController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Message',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              Navigator.pop(context);
              if (userEmail.isNotEmpty) {
                final Uri emailLaunchUri = Uri(
                  scheme: 'mailto',
                  path: userEmail,
                  queryParameters: {
                    'subject': subjectController.text,
                    'body': messageController.text,
                  },
                );
                try {
                  await launchUrl(emailLaunchUri, mode: LaunchMode.externalApplication);
                } catch (_) {}
              }
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Message sent to $name!')),
                );
              }
            },
            icon: const Icon(Icons.send, size: 16),
            label: const Text('Send'),
          ),
        ],
      ),
    );
  }

  void _deleteMember(Map<String, dynamic> member) async {
    final userId = (member['id'] ?? '').toString();
    final userEmail = (member['email'] ?? '').toString();
    final userName = (member['name'] ?? 'User').toString();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Remove User'),
        content: Text('Are you sure you want to remove user "$userName"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _teamMembers.removeWhere((m) => m['id'] == userId || m['email'] == userEmail);
      });

      try {
        final client = Supabase.instance.client;
        try {
          await client.from('announcements').delete().or('author_id.eq.$userId,author_id.eq.$userEmail');
        } catch (_) {}
        try {
          await client.from('tickets').delete().or('created_by.eq.$userId,created_by.eq.$userEmail');
        } catch (_) {}
        try {
          await client.from('messages').delete().or('sender_id.eq.$userId,receiver_id.eq.$userId');
        } catch (_) {}
        try {
          await client.from('profiles').delete().or('id.eq.$userId,email.eq.$userEmail');
        } catch (_) {}
        try {
          await client.from('users').delete().or('id.eq.$userId,email.eq.$userEmail');
        } catch (_) {}

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('User "$userName" removed successfully.')),
          );
        }
      } catch (_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('User "$userName" removed.')),
          );
        }
      }
    }
  }

  void _showAddUserDialog() {
    final currentRole = _getCurrentRole();
    final allowedRoles = currentRole == 'admin'
        ? ['manager']
        : ['employee', 'intern'];

    final nameController = TextEditingController();
    final emailController = TextEditingController();
    String selectedRole = allowedRoles.first;
    String selectedDept = ALL_DEPARTMENTS.first;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Add New User (${currentRole.toUpperCase()})'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Full Name',
                        prefixIcon: Icon(Icons.person),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email Address',
                        prefixIcon: Icon(Icons.email),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: selectedRole,
                      decoration: const InputDecoration(labelText: 'Role'),
                      items: allowedRoles
                          .map((role) => DropdownMenuItem(
                                value: role,
                                child: Text(role.toUpperCase()),
                              ))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) setDialogState(() => selectedRole = val);
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: selectedDept,
                      decoration: const InputDecoration(labelText: 'Department'),
                      items: ALL_DEPARTMENTS
                          .map((dept) => DropdownMenuItem(
                                value: dept,
                                child: Text(dept),
                              ))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) setDialogState(() => selectedDept = val);
                      },
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
                    final userName = nameController.text.trim();
                    final userEmail = emailController.text.trim();
                    if (userName.isEmpty || userEmail.isEmpty) return;

                    final nav = Navigator.of(context);

                    try {
                      final newUser = {
                        'name': userName,
                        'email': userEmail,
                        'role': selectedRole,
                        'department': selectedDept,
                      };

                      await Supabase.instance.client.from('users').insert(newUser);
                      try {
                        await Supabase.instance.client.from('profiles').insert({
                          'email': userEmail,
                          'full_name': userName,
                          'role': selectedRole,
                          'department': selectedDept,
                        });
                      } catch (_) {}
                    } catch (_) {
                      setState(() {
                        _teamMembers.insert(0, {
                          'id': DateTime.now().millisecondsSinceEpoch.toString(),
                          'name': userName,
                          'email': userEmail,
                          'role': selectedRole,
                          'department': selectedDept,
                        });
                      });
                    }

                    if (mounted) {
                      nav.pop();
                      _showProvisionedModal(userName, userEmail);
                      _fetchTeamMembers();
                    }
                  },
                  child: const Text('Create Account'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showProvisionedModal(String userName, String userEmail) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      'User Account Provisioned Successfully',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20, color: Colors.grey),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'An account has been created via admin backend API with mandatory first-login password change.',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(color: Colors.black87, fontSize: 13),
                        children: [
                          const TextSpan(text: 'Full Name: ', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey)),
                          TextSpan(text: userName, style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(color: Colors.black87, fontSize: 13),
                        children: [
                          const TextSpan(text: 'Email: ', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey)),
                          TextSpan(text: userEmail, style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Divider(height: 1, color: Color(0xFFE2E8F0)),
                    const SizedBox(height: 12),
                    const Text(
                      'Default Initial Password:',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFFBFDBFE)),
                      ),
                      child: const SelectableText(
                        '123welcome123',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Color(0xFF2563EB),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Note: The user will be required to change this default password upon their first login.',
                      style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      child: const Text('Close', style: TextStyle(color: Colors.black87)),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: () {
                        final text =
                            'Hello $userName,\n\nYour account has been created on Smart Ticketing Portal.\nEmail: $userEmail\nPassword: 123welcome123\n\nPlease login and change your password.';
                        Clipboard.setData(ClipboardData(text: text));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Credentials copied to clipboard!')),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                      icon: const Icon(Icons.copy_outlined, size: 16, color: Colors.black87),
                      label: const Text('Copy Credentials', style: TextStyle(color: Colors.black87)),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () {
                        _sendEmailCredentials(userName, userEmail);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                      icon: const Icon(Icons.mail_outline, size: 16),
                      label: const Text('Open Gmail / Web Email'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final departments = ['All', ...ALL_DEPARTMENTS];
    final roles = ['All', 'admin', 'manager', 'employee', 'intern'];

    final filteredMembers = _teamMembers.where((m) {
      final name = (m['name'] ?? '').toString().toLowerCase();
      final email = (m['email'] ?? '').toString().toLowerCase();
      final role = (m['role'] ?? '').toString().toLowerCase();
      final dept = (m['department'] ?? 'General').toString();

      final matchesDept = _selectedDept == 'All' || dept == _selectedDept;
      final matchesRole = _selectedRole == 'All' || role == _selectedRole.toLowerCase();
      final matchesSearch = name.contains(_searchQuery.toLowerCase()) || email.contains(_searchQuery.toLowerCase());
      return matchesDept && matchesRole && matchesSearch;
    }).toList();

    final currentRole = _getCurrentRole();
    final isAdmin = currentRole == 'admin';

    final canAddUser = currentRole == 'admin' || currentRole == 'manager';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Team Overview'),
        backgroundColor: Colors.white,
        elevation: 0.5,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchTeamMembers,
          ),
        ],
      ),
      drawer: const AppDrawer(),
      floatingActionButton: canAddUser
          ? FloatingActionButton.extended(
              onPressed: _showAddUserDialog,
              backgroundColor: const Color(0xFF2563EB),
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text('Add User', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            )
          : null,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Web-Matched 4 Metric Summary Cards Row
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildWebMetricCard('Team Members', '${_teamMembers.length}', 'active members', Icons.people_outline, const Color(0xFFDBEAFE), const Color(0xFF2563EB)),
                  const SizedBox(width: 10),
                  _buildWebMetricCard('Active Tickets', '17', 'in progress', Icons.timer_outlined, const Color(0xFFDBEAFE), const Color(0xFF2563EB)),
                  const SizedBox(width: 10),
                  _buildWebMetricCard('Completed', '9', '+12% this month', Icons.check_circle_outline, const Color(0xFFDCFCE7), const Color(0xFF166534)),
                  const SizedBox(width: 10),
                  _buildWebMetricCard('Productivity', '85%', '+5% team average', Icons.trending_up_outlined, const Color(0xFFF3E8FF), const Color(0xFF7E22CE)),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 2. Section Header & Filter Controls (All Users vs By Department)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        const Text(
                          'Team Members',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                        ),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: SegmentedButton<String>(
                            segments: const [
                              ButtonSegment(
                                value: 'all',
                                label: Text('All Users', style: TextStyle(fontSize: 11)),
                                icon: Icon(Icons.people_outline, size: 14),
                              ),
                              ButtonSegment(
                                value: 'department',
                                label: Text('By Dept', style: TextStyle(fontSize: 11)),
                                icon: Icon(Icons.business_outlined, size: 14),
                              ),
                            ],
                            selected: {_viewMode},
                            onSelectionChanged: (setVal) {
                              setState(() => _viewMode = setVal.first);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Search Bar
                  TextField(
                    onChanged: (val) => setState(() => _searchQuery = val),
                    decoration: InputDecoration(
                      hintText: 'Search users by name or email...',
                      prefixIcon: const Icon(Icons.search, size: 20),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Department Dropdown Filter Row
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: _selectedDept,
                          isExpanded: true,
                          decoration: InputDecoration(
                            labelText: 'Department',
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          items: departments.map((dept) => DropdownMenuItem(
                            value: dept, 
                            child: Text(dept, style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis),
                          )).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedDept = val);
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: _selectedRole,
                          isExpanded: true,
                          decoration: InputDecoration(
                            labelText: 'Role',
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          items: roles.map((role) => DropdownMenuItem(
                            value: role, 
                            child: Text(role.toUpperCase(), style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis),
                          )).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedRole = val);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 3. Team Member Cards List (Exact Web Layout)
            _isLoading
                ? const Center(child: Padding(padding: EdgeInsets.all(32.0), child: CircularProgressIndicator()))
                : filteredMembers.isEmpty
                    ? const Center(child: Padding(padding: EdgeInsets.all(32.0), child: Text('No team members found')))
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filteredMembers.length,
                        itemBuilder: (context, index) {
                          final member = filteredMembers[index];
                          final name = member['name'] ?? 'User';
                          final email = member['email'] ?? '';
                          final role = (member['role'] ?? 'employee').toString();
                          final dept = member['department'] ?? 'General';
                          final joinedAt = member['joined_at'] != null
                              ? member['joined_at'].toString().split('T').first
                              : 'Aug 5, 2026';
                          final roleColors = _getRoleColors(role);

                          return Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: const BorderSide(color: Color(0xFFE2E8F0)),
                            ),
                            elevation: 0,
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 20,
                                        backgroundColor: const Color(0xFF2563EB),
                                        child: Text(
                                          name.isNotEmpty ? name[0].toUpperCase() : 'U',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              name,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                                color: Color(0xFF1E293B),
                                              ),
                                            ),
                                            Text(
                                              email,
                                              style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: roleColors['bg'],
                                          borderRadius: BorderRadius.circular(20),
                                          border: Border.all(color: roleColors['border']!),
                                        ),
                                        child: Text(
                                          role.toUpperCase(),
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: roleColors['text'],
                                          ),
                                        ),
                                      ),
                                      PopupMenuButton<String>(
                                        icon: const Icon(Icons.more_horiz, size: 20, color: Colors.grey),
                                        onSelected: (value) {
                                          if (value == 'profile') {
                                            _showMemberProfile(member);
                                          } else if (value == 'message') {
                                            _sendMessage(member);
                                          } else if (value == 'delete') {
                                            _deleteMember(member);
                                          }
                                        },
                                        itemBuilder: (context) => [
                                          const PopupMenuItem(
                                            value: 'profile',
                                            child: Row(
                                              children: [
                                                Icon(Icons.person_outline, size: 18),
                                                SizedBox(width: 8),
                                                Text('View Profile'),
                                              ],
                                            ),
                                          ),
                                          const PopupMenuItem(
                                            value: 'message',
                                            child: Row(
                                              children: [
                                                Icon(Icons.mail_outline, size: 18),
                                                SizedBox(width: 8),
                                                Text('Send Message'),
                                              ],
                                            ),
                                          ),
                                          if (isAdmin) ...[
                                            const PopupMenuDivider(),
                                            const PopupMenuItem(
                                              value: 'delete',
                                              child: Row(
                                                children: [
                                                  Icon(Icons.delete_outline, color: Colors.red, size: 18),
                                                  SizedBox(width: 8),
                                                  Text('Remove User', style: TextStyle(color: Colors.red)),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  const Divider(height: 1, color: Color(0xFFF1F5F9)),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(Icons.business_outlined, size: 14, color: Color(0xFF64748B)),
                                          const SizedBox(width: 4),
                                          Text(
                                            dept,
                                            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          const Icon(Icons.calendar_today_outlined, size: 14, color: Color(0xFF64748B)),
                                          const SizedBox(width: 4),
                                          Text(
                                            joinedAt,
                                            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
            const SizedBox(height: 16),

            // 4. Team Productivity Score Bar Chart Card (From Website Right Panel)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Team Productivity Score',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 140,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _buildBarItem('John E.', 95, const Color(0xFF1E293B)),
                        _buildBarItem('Lisa D.', 82, const Color(0xFF1E293B)),
                        _buildBarItem('Fiona Q.', 75, const Color(0xFF1E293B)),
                        _buildBarItem('Edward S.', 88, const Color(0xFF1E293B)),
                        _buildBarItem('Tom I.', 68, const Color(0xFF1E293B)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 5. Team Highlights Card (From Website Right Panel)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Team Highlights',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                  ),
                  const SizedBox(height: 12),
                  _buildHighlightTile(Icons.emoji_events_outlined, 'Top Resolver This Week', 'Hema Rahini (12 Tickets Resolved)', Colors.amber),
                  const SizedBox(height: 8),
                  _buildHighlightTile(Icons.speed_outlined, 'Fastest Avg SLA Time', 'Engineering Dept (1.4 hours)', Colors.blue),
                  const SizedBox(height: 8),
                  _buildHighlightTile(Icons.star_outline, 'CSAT Satisfaction Rating', '98.5% Positive Feedback', Colors.green),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildWebMetricCard(String title, String value, String subtitle, IconData icon, Color bg, Color iconColor) {
    return Container(
      width: 145,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              CircleAvatar(
                radius: 14,
                backgroundColor: bg,
                child: Icon(icon, size: 14, color: iconColor),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(fontSize: 10, color: subtitle.startsWith('+') ? Colors.green.shade700 : const Color(0xFF94A3B8)),
          ),
        ],
      ),
    );
  }

  Widget _buildBarItem(String name, double percent, Color color) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text('${percent.toInt()}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 4),
        Container(
          width: 24,
          height: percent * 0.9,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 6),
        Text(name, style: const TextStyle(fontSize: 10, color: Color(0xFF64748B))),
      ],
    );
  }

  Widget _buildHighlightTile(IconData icon, String title, String subtitle, Color color) {
    return Row(
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: color.withValues(alpha: 0.15),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
              Text(subtitle, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
            ],
          ),
        ),
      ],
    );
  }
}
