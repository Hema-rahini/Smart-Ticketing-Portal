import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  static String get baseUrl {
    final envUrl = dotenv.env['API_BASE_URL'];
    if (envUrl != null && envUrl.isNotEmpty) {
      return envUrl;
    }
    return 'http://10.0.2.2:8000';
  }

  static String getChangePasswordUrl(String userId) {
    return '$baseUrl/users/$userId/change-password';
  }
}
