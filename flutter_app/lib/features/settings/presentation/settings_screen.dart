import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/settings_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/utils/app_translations.dart';
import 'widgets/settings_section.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final langCode = settings.languageCode;

    return Scaffold(
      appBar: AppBar(title: Text(AppTranslations.translate('Settings', langCode))),
      body: ListView(
        children: [
          SettingsSection(
            title: AppTranslations.translate('Appearance', langCode),
            children: [
              ListTile(
                leading: const Icon(Icons.brightness_6),
                title: Text(AppTranslations.translate('Theme', langCode)),
                trailing: DropdownButton<ThemeMode>(
                  value: settings.themeMode,
                  underline: const SizedBox(),
                  onChanged: (ThemeMode? newMode) {
                    if (newMode != null) {
                      notifier.updateTheme(newMode);
                    }
                  },
                  items: [
                    DropdownMenuItem(
                      value: ThemeMode.system,
                      child: Text(AppTranslations.translate('System', langCode)),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.light,
                      child: Text(AppTranslations.translate('Light', langCode)),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.dark,
                      child: Text(AppTranslations.translate('Dark', langCode)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SettingsSection(
            title: AppTranslations.translate('Notifications', langCode),
            children: [
              SwitchListTile(
                secondary: const Icon(Icons.notifications),
                title: Text(AppTranslations.translate('Enable Notifications', langCode)),
                value: settings.notificationsEnabled,
                onChanged: notifier.toggleNotifications,
              ),
            ],
          ),
          SettingsSection(
            title: AppTranslations.translate('Language', langCode),
            children: [
              ListTile(
                leading: const Icon(Icons.language),
                title: Text(AppTranslations.translate('Language', langCode)),
                trailing: DropdownButton<String>(
                  value: settings.languageCode,
                  underline: const SizedBox(),
                  onChanged: (String? newLang) {
                    if (newLang != null) {
                      notifier.updateLanguage(newLang);
                    }
                  },
                  items: const [
                    DropdownMenuItem(value: 'en', child: Text('English')),
                    DropdownMenuItem(value: 'es', child: Text('Spanish')),
                    DropdownMenuItem(value: 'fr', child: Text('French')),
                    DropdownMenuItem(value: 'de', child: Text('German')),
                    DropdownMenuItem(value: 'hi', child: Text('Hindi (हिंदी)')),
                    DropdownMenuItem(value: 'ta', child: Text('Tamil (தமிழ்)')),
                  ],
                ),
              ),
            ],
          ),
          SettingsSection(
            title: AppTranslations.translate('About', langCode),
            children: [
              ListTile(
                leading: const Icon(Icons.info),
                title: Text(AppTranslations.translate('Version', langCode)),
                trailing: const Text('1.0.0'),
              ),
            ],
          ),
          SettingsSection(
            title: AppTranslations.translate('Account', langCode),
            children: [
              ListTile(
                leading: Icon(
                  Icons.logout,
                  color: Theme.of(context).colorScheme.error,
                ),
                title: Text(
                  AppTranslations.translate('Logout', langCode),
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
                onTap: () {
                  ref.read(authProvider.notifier).logout();
                },
              ),
            ],
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
