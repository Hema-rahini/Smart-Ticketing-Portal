import 'package:dio/dio.dart';
import '../../../core/api/dio_client.dart';
import '../../../core/api/api_exception.dart';

class AnnouncementApi {
  final DioClient _dioClient;

  AnnouncementApi(this._dioClient);

  Future<List<dynamic>> getAnnouncements() async {
    try {
      final response = await _dioClient.dio.get('/announcements/');
      return response.data as List<dynamic>;
    } on DioException catch (e) {
      throw ApiException(
        e.message ?? 'Network error',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<Map<String, dynamic>> getAnnouncement(String id) async {
    try {
      final response = await _dioClient.dio.get('/announcements/$id');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException(
        e.message ?? 'Network error',
        statusCode: e.response?.statusCode,
      );
    }
  }
}
