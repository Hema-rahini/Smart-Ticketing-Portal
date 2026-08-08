import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/router/app_router.dart';
import '../data/auth_api.dart';
import '../data/auth_repository.dart';
import '../models/user_model.dart';
import '../../../core/services/storage_service.dart';

final storageServiceProvider = Provider((ref) => StorageService());

final supabaseProvider = Provider((ref) => Supabase.instance.client);

final authApiProvider = Provider((ref) => AuthApi(ref.read(supabaseProvider)));

final authRepositoryProvider = Provider(
  (ref) => AuthRepository(
    ref.read(authApiProvider),
    ref.read(storageServiceProvider),
    ref.read(supabaseProvider),
  ),
);

enum AuthState { initializing, loading, authenticated, unauthenticated, error }

class AuthNotifier extends Notifier<AuthState> {
  UserModel? _currentUser;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;

  @override
  AuthState build() {
    // In Riverpod Notifier, checkSession can be kicked off immediately
    // but cannot change state synchronously in build to something async.
    // We'll return initializing and then do the check.
    Future.microtask(() => checkSession());
    return AuthState.initializing;
  }

  Future<void> checkSession() async {
    state = AuthState.initializing;
    try {
      final user = await ref.read(authRepositoryProvider).checkSession();
      if (user != null) {
        _currentUser = user;
        AppRouter.isAuthenticated = true;
        state = AuthState.authenticated;
      } else {
        AppRouter.isAuthenticated = false;
        state = AuthState.unauthenticated;
      }
    } catch (e) {
      _errorMessage = e.toString();
      AppRouter.isAuthenticated = false;
      state = AuthState.unauthenticated;
    }
  }

  String _formatError(dynamic e) {
    final msg = e.toString();
    if (msg.contains('SocketException') ||
        msg.contains('Network is unreachable') ||
        msg.contains('ClientException') ||
        msg.contains('SocketConnection failed')) {
      return 'Network is unreachable. Please check your mobile data or Wi-Fi connection.';
    }
    return msg.replaceAll('Exception: ', '').replaceAll('AuthException: ', '');
  }

  Future<void> login(String email, String password, {String? role}) async {
    state = AuthState.loading;
    try {
      final user = await ref
          .read(authRepositoryProvider)
          .login(email, password, role: role);
      _currentUser = user;
      AppRouter.isAuthenticated = true;
      AppRouter.userRole = user.role;
      state = AuthState.authenticated;
    } catch (e) {
      _errorMessage = _formatError(e);
      state = AuthState.error;
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String name,
    required String role,
    required String department,
  }) async {
    state = AuthState.loading;
    try {
      final user = await ref.read(authRepositoryProvider).signUp(
            email: email,
            password: password,
            name: name,
            role: role,
            department: department,
          );
      _currentUser = user;
      AppRouter.isAuthenticated = true;
      state = AuthState.authenticated;
    } catch (e) {
      _errorMessage = _formatError(e);
      state = AuthState.error;
    }
  }

  Future<void> logout() async {
    state = AuthState.loading;
    try {
      await ref.read(authRepositoryProvider).logout();
    } catch (_) {}

    _currentUser = null;
    _errorMessage = null;
    AppRouter.isAuthenticated = false;
    AppRouter.userRole = null;
    state = AuthState.unauthenticated;
    AppRouter.router.go('/login');
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});
