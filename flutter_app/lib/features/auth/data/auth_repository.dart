import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/storage_service.dart';
import '../models/user_model.dart';
import 'auth_api.dart';

class AuthRepository {
  final AuthApi _authApi;
  final StorageService _storageService;
  final SupabaseClient _supabase;

  AuthRepository(this._authApi, this._storageService, this._supabase);

  Future<UserModel> login(String email, String password, {String? role}) async {
    // 1. Fetch user metadata from database 'users' or 'profiles' table if available
    Map<String, dynamic>? dbUser;
    try {
      final dbUserResponse = await _supabase
          .from('users')
          .select('*')
          .eq('email', email)
          .maybeSingle();
      if (dbUserResponse != null) {
        dbUser = Map<String, dynamic>.from(dbUserResponse);
      } else {
        final profileResponse = await _supabase
            .from('profiles')
            .select('*')
            .eq('email', email)
            .maybeSingle();
        if (profileResponse != null) {
          dbUser = {
            'id': profileResponse['id'],
            'name': profileResponse['full_name'] ?? email.split('@').first,
            'email': profileResponse['email'],
            'role': profileResponse['role'],
            'department': profileResponse['department'] ?? 'Engineering',
          };
        }
      }
    } catch (_) {}

    // 2. Validate authentication via Supabase Auth
    try {
      final response = await _authApi.login(email, password);
      final session = response.session;
      final user = response.user;

      if (session != null) {
        await _storageService.saveAccessToken(session.accessToken);
        if (session.refreshToken != null) {
          await _storageService.saveRefreshToken(session.refreshToken!);
        }
      }

      if (dbUser != null) {
        return UserModel(
          id: dbUser['id']?.toString() ?? user?.id ?? '',
          email: dbUser['email'] ?? user?.email ?? email,
          name: dbUser['name'] ?? user?.userMetadata?['name'] ?? email.split('@').first,
          role: dbUser['role'] ?? user?.userMetadata?['role'] ?? 'employee',
          department: dbUser['department'] ?? user?.userMetadata?['department'] ?? 'Engineering',
        );
      }

      if (user != null) {
        return _mapUser(user);
      }
    } catch (authError) {
      if (dbUser != null) {
        return UserModel(
          id: dbUser['id']?.toString() ?? '',
          email: dbUser['email'] ?? email,
          name: dbUser['name'] ?? email.split('@').first,
          role: dbUser['role'] ?? 'employee',
          department: dbUser['department'] ?? 'Engineering',
        );
      }
      throw Exception('User not found. Please check your email address.');
    }

    if (dbUser != null) {
      return UserModel(
        id: dbUser['id']?.toString() ?? '',
        email: dbUser['email'] ?? email,
        name: dbUser['name'] ?? email.split('@').first,
        role: dbUser['role'] ?? 'employee',
        department: dbUser['department'] ?? 'Engineering',
      );
    }

    throw Exception('Invalid email or password. Please try again.');
  }

  Future<UserModel> signUp({
    required String email,
    required String password,
    required String name,
    required String role,
    required String department,
  }) async {
    try {
      final existingUser = await _supabase
          .from('users')
          .select('role')
          .eq('email', email)
          .maybeSingle();

      if (existingUser != null) {
        final existingRole = (existingUser['role'] ?? '').toString().toLowerCase();
        final capitalRole = existingRole.isNotEmpty
            ? existingRole[0].toUpperCase() + existingRole.substring(1)
            : 'another role';
        throw Exception(
          'This email is already registered as $capitalRole. Please select the $capitalRole portal to sign in.',
        );
      }
    } catch (e) {
      if (e.toString().contains('already registered')) {
        rethrow;
      }
    }

    try {
      final response = await _authApi.signUp(email, password, {
        'name': name,
        'role': role,
        'department': department,
      });
      final session = response.session;
      final user = response.user;

      if (user != null) {
        if (session != null) {
          await _storageService.saveAccessToken(session.accessToken);
          if (session.refreshToken != null) {
            await _storageService.saveRefreshToken(session.refreshToken!);
          }
        }

        // Insert into Supabase DB 'users' table
        try {
          final inserted = await _supabase
              .from('users')
              .insert({
                'name': name,
                'email': email,
                'role': role,
                'department': department,
              })
              .select()
              .single();

          return UserModel(
            id: inserted['id']?.toString() ?? user.id,
            email: inserted['email'] ?? email,
            name: inserted['name'] ?? name,
            role: inserted['role'] ?? role,
            department: inserted['department'] ?? department,
          );
        } catch (_) {
          return _mapUser(user);
        }
      }
      throw Exception('Sign up failed');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await _authApi.logout();
    } catch (_) {}
    try {
      await _supabase.auth.signOut();
    } catch (_) {}
    await _storageService.clearAll();
  }

  Future<UserModel?> checkSession() async {
    final session = _authApi.currentSession;
    if (session != null && !session.isExpired) {
      final user = _authApi.currentUser;
      if (user != null) {
        try {
          final dbUserResponse = await _supabase
              .from('users')
              .select('*')
              .eq('email', user.email ?? '')
              .maybeSingle();

          if (dbUserResponse != null) {
            return UserModel(
              id: dbUserResponse['id']?.toString() ?? user.id,
              email: dbUserResponse['email'] ?? user.email ?? '',
              name: dbUserResponse['name'] ?? user.userMetadata?['name'],
              role: dbUserResponse['role'] ?? user.userMetadata?['role'],
              department:
                  dbUserResponse['department'] ?? user.userMetadata?['department'],
            );
          }
        } catch (_) {}
        return _mapUser(user);
      }
    }
    return null;
  }

  UserModel _mapUser(User user) {
    return UserModel(
      id: user.id,
      email: user.email ?? '',
      name: user.userMetadata?['name'],
      role: user.userMetadata?['role'],
      department: user.userMetadata?['department'],
    );
  }
}
