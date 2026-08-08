import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../dashboard/providers/dashboard_provider.dart'
    show dioClientProvider;
import '../data/ticket_api.dart';
import '../data/ticket_repository.dart';
import '../models/ticket.dart';
import '../models/create_ticket_request.dart';
import '../models/update_ticket_request.dart';
import '../../auth/providers/auth_provider.dart';

final ticketApiProvider = Provider<TicketApi>((ref) {
  return TicketApi(ref.read(dioClientProvider));
});

final ticketRepositoryProvider = Provider<TicketRepository>((ref) {
  return TicketRepository(ref.read(ticketApiProvider));
});

enum TicketState { initial, loading, loaded, empty, error }

class TicketData {
  final List<Ticket> allTickets;
  final List<Ticket> filteredTickets;

  TicketData({required this.allTickets, required this.filteredTickets});
}

class TicketNotifier extends Notifier<TicketState> {
  TicketData? _data;
  String? _errorMessage;

  String _searchQuery = '';
  String? _statusFilter;
  String? _priorityFilter;

  TicketData? get data => _data;
  String? get errorMessage => _errorMessage;

  @override
  TicketState build() {
    return TicketState.initial;
  }

  Future<void> loadTickets() async {
    state = TicketState.loading;
    try {
      final user = ref.read(authProvider.notifier).currentUser;
      final tickets = await ref.read(ticketRepositoryProvider).getTickets(user);
      _data = TicketData(allTickets: tickets, filteredTickets: tickets);

      _applyFilters();

      if (_data!.filteredTickets.isEmpty) {
        state = TicketState.empty;
      } else {
        state = TicketState.loaded;
      }
    } catch (e) {
      _errorMessage = e.toString();
      state = TicketState.error;
    }
  }

  void searchTickets(String query) {
    _searchQuery = query.toLowerCase();
    _applyFilters();
  }

  void filterTickets({String? status, String? priority}) {
    _statusFilter = status;
    _priorityFilter = priority;
    _applyFilters();
  }

  void _applyFilters() {
    if (_data == null) return;

    var filtered = _data!.allTickets;

    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where(
            (t) =>
                t.title.toLowerCase().contains(_searchQuery) ||
                (t.description?.toLowerCase().contains(_searchQuery) ?? false),
          )
          .toList();
    }

    if (_statusFilter != null && _statusFilter!.isNotEmpty) {
      filtered = filtered.where((t) => t.status == _statusFilter).toList();
    }

    if (_priorityFilter != null && _priorityFilter!.isNotEmpty) {
      filtered = filtered.where((t) => t.priority == _priorityFilter).toList();
    }

    _data = TicketData(
      allTickets: _data!.allTickets,
      filteredTickets: filtered,
    );

    if (filtered.isEmpty) {
      state = TicketState.empty;
    } else {
      state = TicketState.loaded;
    }
  }

  Future<void> refreshTickets() async {
    await loadTickets();
  }

  Future<void> reload() async {
    await loadTickets();
  }

  Future<bool> createTicket(CreateTicketRequest request) async {
    try {
      await ref.read(ticketRepositoryProvider).createTicket(request);
      await refreshTickets();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    }
  }

  Future<bool> updateTicket(String id, UpdateTicketRequest request) async {
    try {
      await ref.read(ticketRepositoryProvider).updateTicket(id, request);
      await refreshTickets();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    }
  }
}

final ticketProvider = NotifierProvider<TicketNotifier, TicketState>(() {
  return TicketNotifier();
});

final ticketDetailProvider = FutureProvider.family<Ticket, String>((
  ref,
  id,
) async {
  return ref.read(ticketRepositoryProvider).getTicket(id);
});
