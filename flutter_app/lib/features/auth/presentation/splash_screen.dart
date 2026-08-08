import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (authState == AuthState.authenticated) {
        AppRouter.isAuthenticated = true;
        context.go('/dashboard');
      } else if (authState == AuthState.unauthenticated) {
        AppRouter.isAuthenticated = false;
        context.go('/login');
      }
    });

    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next == AuthState.authenticated) {
        AppRouter.isAuthenticated = true;
        context.go('/dashboard');
      } else if (next == AuthState.unauthenticated) {
        AppRouter.isAuthenticated = false;
        context.go('/login');
      }
    });

    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
