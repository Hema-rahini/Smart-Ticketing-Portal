import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_router.dart';
import '../providers/ticket_provider.dart';
import '../../auth/providers/auth_provider.dart';
import 'widgets/ticket_card.dart';
import 'widgets/empty_ticket_view.dart';
import 'widgets/loading_ticket_card.dart';
import 'widgets/ticket_filter_sheet.dart';

class TicketListScreen extends ConsumerStatefulWidget {
  const TicketListScreen({super.key});

  @override
  ConsumerState<TicketListScreen> createState() => _TicketListScreenState();
}

class _TicketListScreenState extends ConsumerState<TicketListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(ticketProvider.notifier).loadTickets();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        // We'd ideally pull current filters from state, but for simplicity they're managed in the notifier.
        // We could expose them as public getters in the Notifier.
        return TicketFilterSheet(
          onApply: (status, priority) {
            ref
                .read(ticketProvider.notifier)
                .filterTickets(status: status, priority: priority);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final ticketState = ref.watch(ticketProvider);
    final notifier = ref.read(ticketProvider.notifier);
    final data = notifier.data;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tickets'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterSheet,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search tickets...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          notifier.searchTickets('');
                          FocusScope.of(context).unfocus();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: (value) => notifier.searchTickets(value),
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => notifier.refreshTickets(),
        child: _buildBody(ticketState, data, notifier),
      ),
      floatingActionButton: (ref.read(authProvider.notifier).currentUser?.role ?? AppRouter.userRole) != 'admin'
          ? FloatingActionButton(
              onPressed: () {
                context.go('/tickets/create-ticket');
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildBody(
    TicketState state,
    TicketData? data,
    TicketNotifier notifier,
  ) {
    if (state == TicketState.initial || state == TicketState.loading) {
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 5,
        itemBuilder: (context, index) => const LoadingTicketCard(),
      );
    }

    if (state == TicketState.error) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(
              'Failed to load tickets',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Text(notifier.errorMessage ?? ''),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => notifier.reload(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state == TicketState.empty ||
        data == null ||
        data.filteredTickets.isEmpty) {
      return EmptyTicketView(onRefresh: () => notifier.refreshTickets());
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: data.filteredTickets.length,
      itemBuilder: (context, index) {
        final ticket = data.filteredTickets[index];
        return TicketCard(ticket: ticket);
      },
    );
  }
}
