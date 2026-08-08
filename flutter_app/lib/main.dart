import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'features/settings/providers/settings_provider.dart';

const String kDefaultSupabaseUrl = 'https://cppqgkzogzxywwabtmnz.supabase.co';
const String kDefaultSupabaseAnonKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNwcHFna3pvZ3p4eXd3YWJ0bW56Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODExMjE1MjEsImV4cCI6MjA5NjY5NzUyMX0.ac00bdM_oFw2M8BSuiN7rV0sAZOa0Cz9GDgV6nbxrns';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: ".env");
  } catch (_) {}

  final String supabaseUrl = (dotenv.env['SUPABASE_URL'] != null &&
          dotenv.env['SUPABASE_URL']!.isNotEmpty)
      ? dotenv.env['SUPABASE_URL']!
      : kDefaultSupabaseUrl;

  final String supabaseAnonKey = (dotenv.env['SUPABASE_ANON_KEY'] != null &&
          dotenv.env['SUPABASE_ANON_KEY']!.isNotEmpty)
      ? dotenv.env['SUPABASE_ANON_KEY']!
      : kDefaultSupabaseAnonKey;

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  final container = ProviderContainer();
  await container.read(settingsProvider.notifier).loadSettings();

  runApp(UncontrolledProviderScope(container: container, child: const MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return MaterialApp.router(
      title: 'Smart Ticketing',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: settings.themeMode,
      routerConfig: AppRouter.router,
    );
  }
}
