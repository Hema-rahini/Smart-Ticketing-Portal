import 'package:dio/dio.dart';
import '../../../core/api/dio_client.dart';
import '../../../core/api/api_exception.dart';
import '../models/update_profile_request.dart';

class ProfileApi {
  final DioClient _dioClient;

  ProfileApi(this._dioClient);

  Future<Map<String, dynamic>> getUserProfile(String userId) async {
    try {
      final response = await _dioClient.dio.get('/users/$userId');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
        throw ApiException('Unauthorized', statusCode: e.response?.statusCode);
      }
      throw ApiException(
        e.message ?? 'Network error',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<Map<String, dynamic>> updateUserProfile(
    String userId,
    UpdateProfileRequest request,
  ) async {
    try {
      final response = await _dioClient.dio.put(
        '/users/$userId',
        data: request.toJson(),
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
        throw ApiException('Unauthorized', statusCode: e.response?.statusCode);
      }
      // If validation error from backend, try to extract message
      if (e.response?.statusCode == 400 || e.response?.statusCode == 422) {
        final message = e.response?.data['detail'] ?? 'Validation error';
        throw ApiException(
          message.toString(),
          statusCode: e.response?.statusCode,
        );
      }
      throw ApiException(
        e.message ?? 'Network error',
        statusCode: e.response?.statusCode,
      );
    }
  }
}
