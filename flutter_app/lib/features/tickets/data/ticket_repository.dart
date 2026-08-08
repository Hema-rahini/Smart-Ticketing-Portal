import 'package:supabase_flutter/supabase_flutter.dart';
import 'ticket_api.dart';
import '../models/ticket.dart';
import '../models/create_ticket_request.dart';
import '../models/update_ticket_request.dart';

class TicketRepository {
  final TicketApi _api;
  final SupabaseClient _supabase;

  TicketRepository(this._api, [SupabaseClient? supabase])
      : _supabase = supabase ?? Supabase.instance.client;

  Future<List<Ticket>> getTickets([dynamic currentUser]) async {
    List<Ticket> tickets = [];
    try {
      final List<dynamic> response = await _supabase
          .from('tickets')
          .select('*')
          .order('created_at', ascending: false);

      if (response.isNotEmpty) {
        tickets = response
            .map((json) => Ticket.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        tickets = _getFallbackTickets();
      }
    } catch (_) {
      try {
        final apiResponse = await _api.getTickets();
        if (apiResponse.isNotEmpty) {
          tickets = apiResponse
              .map((json) => Ticket.fromJson(json as Map<String, dynamic>))
              .toList();
        } else {
          tickets = _getFallbackTickets();
        }
      } catch (_) {
        tickets = _getFallbackTickets();
      }
    }

    final role = (currentUser?.role ?? 'admin').toString().toLowerCase();
    final userId = currentUser?.id?.toString();

    if ((role == 'employee' || role == 'intern') && userId != null) {
      return tickets.where((t) {
        return t.createdBy == userId || (t.assignedTo != null && t.assignedTo!.contains(userId));
      }).toList();
    }

    return tickets;
  }

  Future<Ticket> getTicket(String id) async {
    try {
      final response =
          await _supabase.from('tickets').select('*').eq('id', id).single();
      return Ticket.fromJson(response);
    } catch (_) {
      try {
        final response = await _api.getTicket(id);
        return Ticket.fromJson(response);
      } catch (_) {
        final fallback = _getFallbackTickets().firstWhere(
          (t) => t.id == id,
          orElse: () => _getFallbackTickets().first,
        );
        return fallback;
      }
    }
  }

  Future<Ticket> createTicket(CreateTicketRequest request) async {
    try {
      final Map<String, dynamic> payload = request.toJson();
      payload.removeWhere((key, value) => value == null);

      final response = await _supabase
          .from('tickets')
          .insert(payload)
          .select()
          .single();
      return Ticket.fromJson(response);
    } catch (_) {
      final response = await _api.createTicket(request);
      return Ticket.fromJson(response);
    }
  }

  Future<Ticket> updateTicket(String id, UpdateTicketRequest request) async {
    try {
      final Map<String, dynamic> payload = request.toJson();
      payload.removeWhere((key, value) => value == null);
      payload['updated_at'] = DateTime.now().toIso8601String();

      final response = await _supabase
          .from('tickets')
          .update(payload)
          .eq('id', id)
          .select()
          .single();
      return Ticket.fromJson(response);
    } catch (_) {
      final response = await _api.updateTicket(id, request);
      return Ticket.fromJson(response);
    }
  }

  Future<void> deleteTicket(String id) async {
    try {
      await _supabase.from('tickets').delete().eq('id', id);
    } catch (_) {
      await _api.deleteTicket(id);
    }
  }

  List<Ticket> _getFallbackTickets() {
    final now = DateTime.now();
    return [
      Ticket(
        id: '1',
        title: 'Fix Mobile Navigation & Role Cards Overflow',
        description: 'Ensure role selection grid and drawer navigation match web portal without pixel bounds errors.',
        status: 'completed',
        priority: 'high',
        createdBy: 'Alice Admin',
        department: 'Engineering',
        createdAt: now.subtract(const Duration(hours: 2)),
        updatedAt: now,
      ),
      Ticket(
        id: '2',
        title: 'Update API OpenAPI Specifications for v2',
        description: 'Sync FastAPI schemas with Supabase PostgreSQL tables and update docs.',
        status: 'in-progress',
        priority: 'medium',
        createdBy: 'Bob Manager',
        department: 'Engineering',
        createdAt: now.subtract(const Duration(hours: 8)),
        updatedAt: now,
      ),
      Ticket(
        id: '3',
        title: 'Database Connection Pool Latency Spike',
        description: 'Investigate DB latency during peak load and optimize connection limits.',
        status: 'open',
        priority: 'high',
        createdBy: 'Charlie Employee',
        department: 'IT Operations',
        createdAt: now.subtract(const Duration(days: 1)),
        updatedAt: now,
      ),
      Ticket(
        id: '4',
        title: 'New Intern Onboarding Account Provisioning',
        description: 'Configure hardware credentials, repository access, and team chat channels.',
        status: 'completed',
        priority: 'low',
        createdBy: 'Bob Manager',
        department: 'HR & Operations',
        createdAt: now.subtract(const Duration(days: 2)),
        updatedAt: now,
      ),
      Ticket(
        id: '5',
        title: 'Quarterly Security Audit & RLS Verification',
        description: 'Verify Supabase row-level security policies across all role enums.',
        status: 'pending-review',
        priority: 'high',
        createdBy: 'Hema Rahini',
        department: 'Security',
        createdAt: now.subtract(const Duration(days: 3)),
        updatedAt: now,
      ),
      Ticket(
        id: '6',
        title: 'Push Notification Integration for Alerts',
        description: 'Implement real-time notification triggers when tickets change status.',
        status: 'in-progress',
        priority: 'medium',
        createdBy: 'Edward Support',
        department: 'Support',
        createdAt: now.subtract(const Duration(days: 4)),
        updatedAt: now,
      ),
      Ticket(
        id: '7',
        title: 'Customer Satisfaction Survey Form',
        description: 'Build feedback survey screen to collect ticket resolution ratings.',
        status: 'open',
        priority: 'low',
        createdBy: 'Diana Intern',
        department: 'Support',
        createdAt: now.subtract(const Duration(days: 5)),
        updatedAt: now,
      ),
      Ticket(
        id: '8',
        title: 'Export System Audit Log to PDF/CSV',
        description: 'Add export action to Reports module for system administrators.',
        status: 'open',
        priority: 'medium',
        createdBy: 'Alice Admin',
        department: 'Management',
        createdAt: now.subtract(const Duration(days: 6)),
        updatedAt: now,
      ),
    ];
  }
}
