import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/settings_repository.dart';
import '../models/settings_model.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository();
});

class SettingsNotifier extends Notifier<SettingsModel> {
  @override
  SettingsModel build() {
    // Initial state before loading
    return const SettingsModel();
  }

  Future<void> loadSettings() async {
    final repository = ref.read(settingsRepositoryProvider);
    state = await repository.loadSettings();
  }

  Future<void> updateTheme(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    await _save();
  }

  Future<void> toggleNotifications(bool value) async {
    state = state.copyWith(notificationsEnabled: value);
    await _save();
  }

  Future<void> updateLanguage(String code) async {
    state = state.copyWith(languageCode: code);
    await _save();
  }

  Future<void> _save() async {
    final repository = ref.read(settingsRepositoryProvider);
    await repository.saveSettings(state);
  }
}

final settingsProvider = NotifierProvider<SettingsNotifier, SettingsModel>(() {
  return SettingsNotifier();
});
