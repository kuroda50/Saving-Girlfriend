import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:saving_girlfriend/providers/setting_provider.dart';
import 'package:saving_girlfriend/providers/tribute_history_provider.dart';

final likeabilityProvider = Provider<AsyncValue<double>>((ref) {
  final settingsAsync = ref.watch(settingsProvider);
  final tributeHistoryAsync = ref.watch(tributeHistoryProvider);

  // 依存先のどちらかがロード中またはエラーの場合、それをそのまま伝える
  if (settingsAsync.isLoading || tributeHistoryAsync.isLoading) {
    return const AsyncValue.loading();
  }
  if (settingsAsync.hasError) {
    return AsyncValue.error(settingsAsync.error!, settingsAsync.stackTrace!);
  }
  if (tributeHistoryAsync.hasError) {
    return AsyncValue.error(
        tributeHistoryAsync.error!, tributeHistoryAsync.stackTrace!);
  }

  // 依存先のデータが両方とも利用可能な場合、計算を実行する
  final settings = settingsAsync.value!;
  final history = tributeHistoryAsync.value!;

  final int totalTribute = history.fold(0, (sum, item) => sum + item.amount);
  final int targetAmount = settings.targetSavingAmount;
  final int initialAmount = settings.defaultContributionAmount;

  // 計算式に基づいて好感度を算出する
  final int goalToSave = targetAmount - initialAmount;

  // もう達成している場合は、達成率を100%として扱う
  if (goalToSave <= 0) {
    return const AsyncValue.data(100.0);
  }

  // 達成率を計算
  final double progressRatio = totalTribute / goalToSave;

  // 達成率がマイナスにならないように0で下限を設定
  final double clampedRatio = max(0.0, progressRatio);

  // --- 好感度の計算 ---
  final double likeability = 100 * sqrt(clampedRatio);

  return AsyncValue.data(likeability);
});
