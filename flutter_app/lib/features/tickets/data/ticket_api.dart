import 'package:dio/dio.dart';
import '../../../core/api/dio_client.dart';
import '../../../core/api/api_exception.dart';
import '../models/create_ticket_request.dart';
import '../models/update_ticket_request.dart';

class TicketApi {
  final DioClient _dioClient;

  TicketApi(this._dioClient);

  Future<List<dynamic>> getTickets() async {
    try {
      final response = await _dioClient.dio.get('/tickets');
      return response.data as List<dynamic>;
    } on DioException catch (e) {
      throw ApiException(
        e.message ?? 'Network error',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<Map<String, dynamic>> getTicket(String id) async {
    try {
      final response = await _dioClient.dio.get('/tickets/$id');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException(
        e.message ?? 'Network error',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<Map<String, dynamic>> createTicket(CreateTicketRequest request) async {
    try {
      final response = await _dioClient.dio.post(
        '/tickets',
        data: request.toJson(),
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException(
        e.message ?? 'Network error',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<Map<String, dynamic>> updateTicket(
    String id,
    UpdateTicketRequest request,
  ) async {
    try {
      final response = await _dioClient.dio.put(
        '/tickets/$id',
        data: request.toJson(),
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException(
        e.message ?? 'Network error',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<void> deleteTicket(String id) async {
    try {
      await _dioClient.dio.delete('/tickets/$id');
    } on DioException catch (e) {
      throw ApiException(
        e.message ?? 'Network error',
        statusCode: e.response?.statusCode,
      );
    }
  }
}
