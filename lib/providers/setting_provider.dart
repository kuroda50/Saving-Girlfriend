import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:saving_girlfriend/models/settings_state.dart';
import 'package:saving_girlfriend/repositories/settings_repository.dart';
import 'package:saving_girlfriend/services/local_storage_service.dart';

class SettingNotifier extends AsyncNotifier<SettingsState> {
  Future<SettingsRepository> get _settingsRepositoryFuture =>
      ref.read(settingsRepositoryProvider.future);
  @override
  Future<SettingsState> build() async {
    final settingsRepository = await _settingsRepositoryFuture;
    return settingsRepository.getSettings();
  }

  Future<void> saveSettings(SettingsState newSettings) async {
    final settingsRepository = await _settingsRepositoryFuture;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await settingsRepository.saveSettings(newSettings);
      return newSettings;
    });
  }
}

final settingsProvider = AsyncNotifierProvider<SettingNotifier, SettingsState>(
  SettingNotifier.new,
);

final settingsRepositoryProvider =
    FutureProvider<SettingsRepository>((ref) async {
  final localStorageService =
      await ref.watch(localStorageServiceProvider.future);
  return SettingsRepository(localStorageService);
});
