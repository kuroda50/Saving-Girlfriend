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
}

final settingsRepositoryProvider =
    FutureProvider<SettingsRepository>((ref) async {
  final localStorageService =
      await ref.watch(localStorageServiceProvider.future);
  return SettingsRepository(localStorageService);
});

final settingsProvider = AsyncNotifierProvider<SettingNotifier, SettingsState>(
  SettingNotifier.new,
);
