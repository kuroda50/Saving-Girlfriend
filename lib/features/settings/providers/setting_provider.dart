// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:saving_girlfriend/common/services/local_storage_service.dart';
// Project imports:
import 'package:saving_girlfriend/features/settings/models/settings_state.dart';
import 'package:saving_girlfriend/features/settings/repositories/settings_repository.dart';

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

  Future<void> updateNotification(final bool isEnabled) async {
    final currentState = state.value ?? await future;
    final newSettings = currentState.copyWith(notificationsEnabled: isEnabled);
    await saveSettings(newSettings);
  }

  Future<void> updateBgmVolume(final double volume) async {
    final currentState = state.value ?? await future;
    final newSettings = currentState.copyWith(bgmVolume: volume);
    await saveSettings(newSettings);
  }

  Future<void> updateSavingGoals({
    required int targetSavingAmount,
    required int dailyBudget,
  }) async {
    final currentState = state.value ?? await future;
    final newSettings = currentState.copyWith(
        targetSavingAmount: targetSavingAmount, dailyBudget: dailyBudget);
    await saveSettings(newSettings);
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

final hasSettingsChangesProvider = StateProvider<bool>((ref) => false);

// 2. 外部からリセットを命令するための Provider
final settingsResetTriggerProvider = StateProvider<int>((ref) => 0);
