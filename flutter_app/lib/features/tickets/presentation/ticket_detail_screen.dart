import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../providers/ticket_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/router/app_router.dart';
import '../models/update_ticket_request.dart';
import 'widgets/priority_chip.dart';
import 'widgets/status_chip.dart';

class TicketDetailScreen extends ConsumerWidget {
  final String ticketId;

  const TicketDetailScreen({super.key, required this.ticketId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ticketAsync = ref.watch(ticketDetailProvider(ticketId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ticket Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: ticketAsync.when(
        data: (ticket) {
          final isClosed = ticket.status == 'closed';
          final currentUser = ref.read(authProvider.notifier).currentUser;
          final userRole = currentUser?.role ?? AppRouter.userRole ?? 'employee';
          final isManagerOrAdmin = userRole == 'manager' || userRole == 'admin';
          final isAssigned = ticket.assignedTo?.contains(currentUser?.id ?? '') ?? false;
          final canEdit = !isClosed && (isManagerOrAdmin || isAssigned);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isClosed) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFE4E6),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFFDA4AF)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.lock, color: Color(0xFFBE123C), size: 20),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'This ticket is closed and locked. Closed tickets cannot be updated or reopened.',
                            style: TextStyle(color: Color(0xFF9F1239), fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else if (!canEdit) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFFDE68A)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline, color: Color(0xFFB45309), size: 20),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Read-only: Only the assigned user or a manager can edit this ticket.',
                            style: TextStyle(color: Color(0xFF92400E), fontSize: 13, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Ticket #${ticket.id.length >= 8 ? ticket.id.substring(0, 8) : ticket.id}',
                      style: Theme.of(
                        context,
                      ).textTheme.titleSmall?.copyWith(color: Colors.grey[600]),
                    ),
                    StatusChip(status: ticket.status),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  ticket.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                _buildSectionHeader(context, 'Description'),
                const SizedBox(height: 8),
                Text(
                  ticket.description ?? 'No description provided.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 24),
                _buildSectionHeader(context, 'Details & Actions'),
                const SizedBox(height: 16),
                _buildDetailRow(
                  'Status Update',
                  DropdownButtonFormField<String>(
                    initialValue: ticket.status,
                    decoration: const InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'open', child: Text('Open')),
                      DropdownMenuItem(value: 'in-progress', child: Text('In Progress')),
                      DropdownMenuItem(value: 'pending-review', child: Text('Pending Review')),
                      DropdownMenuItem(value: 'completed', child: Text('Completed')),
                      DropdownMenuItem(value: 'closed', child: Text('Closed')),
                    ],
                    onChanged: canEdit
                        ? (newStatus) async {
                            if (newStatus != null && newStatus != ticket.status) {
                              final req = UpdateTicketRequest(status: newStatus);
                              final success = await ref
                                  .read(ticketProvider.notifier)
                                  .updateTicket(ticket.id, req);
                              if (success && context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Ticket status updated to ${newStatus.toUpperCase()}')),
                                );
                                ref.invalidate(ticketDetailProvider(ticketId));
                              }
                            }
                          }
                        : null,
                  ),
                ),
                const SizedBox(height: 12),
                _buildDetailRow(
                  'Priority',
                  PriorityChip(priority: ticket.priority),
                ),
                if (ticket.department != null) ...[
                  const SizedBox(height: 12),
                  _buildDetailRow('Department', Text(ticket.department!)),
                ],
                const SizedBox(height: 12),
                _buildDetailRow('Created By', Text(ticket.createdBy)),
                const SizedBox(height: 12),
                _buildDetailRow(
                  'Created At',
                  Text(DateFormat.yMMMd().add_jm().format(ticket.createdAt)),
                ),
                const SizedBox(height: 12),
                _buildDetailRow(
                  'Updated At',
                  Text(DateFormat.yMMMd().add_jm().format(ticket.updatedAt)),
                ),
                if (ticket.dueDate != null) ...[
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    'Due Date',
                    Text(DateFormat.yMMMd().format(ticket.dueDate!)),
                  ),
                ],
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(
                'Error loading ticket',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Text(err.toString()),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(ticketDetailProvider(ticketId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const Divider(),
      ],
    );
  }

  Widget _buildDetailRow(String label, Widget child) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Align(alignment: Alignment.centerLeft, child: child),
        ),
      ],
    );
  }
}
