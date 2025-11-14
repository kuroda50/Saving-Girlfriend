// reward_point_provider.dart の修正版

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:saving_girlfriend/common/services/local_storage_service.dart';
// import 'package:shared_preferences/shared_preferences.dart'; // ★ 削除

part 'reward_point_provider.g.dart';

@Riverpod(keepAlive: true)
class RewardPoint extends _$RewardPoint {
  // late SharedPreferences _prefs; // ★ 削除
  // static const _prefsKey = 'reward_points'; // ★ 削除

  // ★ LocalStorageService を保持するように変更
  late LocalStorageService _localStorageService;

  @override
  Future<int> build() async {
    // ★ localStorageServiceProvider を watch するように変更
    _localStorageService = await ref.watch(localStorageServiceProvider.future);

    // ★ LocalStorageService 経由で読み込む
    final savedPoints = await _localStorageService.loadRewardPoints();
    return savedPoints;
  }

  // ポイントを加算する
  Future<void> addPoints(int amount) async {
    final currentPoints = state.value ?? 0;
    final newPoints = currentPoints + amount;

    // ★ LocalStorageService 経由で保存
    await _localStorageService.saveRewardPoints(newPoints);
    state = AsyncData(newPoints);
  }

  // ポイントを使用する (将来の拡張用)
  Future<bool> usePoints(int amount) async {
    final currentPoints = state.value ?? 0;
    if (currentPoints >= amount) {
      final newPoints = currentPoints - amount;

      // ★ LocalStorageService 経由で保存
      await _localStorageService.saveRewardPoints(newPoints);
      state = AsyncData(newPoints);
      return true; // 成功
    }
    return false; // ポイント不足
  }
}
