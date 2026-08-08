import 'package:dio/dio.dart';
import '../../../core/api/dio_client.dart';
import '../../../core/api/api_exception.dart';

class DashboardApi {
  final DioClient _dioClient;

  DashboardApi(this._dioClient);

  Future<List<dynamic>> fetchTickets() async {
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

  Future<List<dynamic>> fetchUsers() async {
    try {
      final response = await _dioClient.dio.get('/users');
      return response.data as List<dynamic>;
    } on DioException catch (e) {
      throw ApiException(
        e.message ?? 'Network error',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<List<dynamic>> fetchAnnouncements() async {
    try {
      final response = await _dioClient.dio.get('/announcements');
      return response.data as List<dynamic>;
    } on DioException catch (e) {
      throw ApiException(
        e.message ?? 'Network error',
        statusCode: e.response?.statusCode,
      );
    }
  }
}
