import '../models/user_profile.dart';
import '../models/update_profile_request.dart';
import 'profile_api.dart';

class ProfileRepository {
  final ProfileApi _api;

  ProfileRepository(this._api);

  Future<UserProfile> getUserProfile(String userId) async {
    final response = await _api.getUserProfile(userId);
    return UserProfile.fromJson(response);
  }

  Future<UserProfile> updateUserProfile(
    String userId,
    UpdateProfileRequest request,
  ) async {
    final response = await _api.updateUserProfile(userId, request);
    return UserProfile.fromJson(response);
  }
}
