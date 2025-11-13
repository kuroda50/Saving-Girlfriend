// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:saving_girlfriend/common/services/local_storage_service.dart';
import 'package:saving_girlfriend/features/budget/providers/budget_history_provider.dart';
import 'package:saving_girlfriend/features/settings/models/settings_state.dart';
import 'package:saving_girlfriend/features/settings/repositories/settings_repository.dart';

class SettingNotifier extends AsyncNotifier<SettingsState> {
  Future<SettingsRepository> get _settingsRepositoryFuture =>
      ref.read(settingsRepositoryProvider.future);

  @override
  Future<SettingsState> build() async {
    // Fetch non-budget settings and budget concurrently
    final settingsRepository = await _settingsRepositoryFuture;
    final nonBudgetSettingsFuture = settingsRepository.getSettings();
    final dailyBudgetFuture = ref.watch(currentDailyBudgetProvider.future);

    final results =
        await Future.wait([nonBudgetSettingsFuture, dailyBudgetFuture]);

    final nonBudgetSettings = results[0] as SettingsState;
    final dailyBudget = results[1] as int;

    return nonBudgetSettings.copyWith(dailyBudget: dailyBudget);
  }

  Future<void> saveSettings(SettingsState newSettings) async {
    final settingsRepository = await _settingsRepositoryFuture;
    final budgetRepository = ref.read(budgetHistoryRepositoryProvider);

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      // Save budget and other settings concurrently
      final saveBudgetFuture =
          budgetRepository.updateDailyBudget(newSettings.dailyBudget);
      final saveOtherSettingsFuture =
          settingsRepository.saveSettings(newSettings);

      await Future.wait([saveBudgetFuture, saveOtherSettingsFuture]);

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
