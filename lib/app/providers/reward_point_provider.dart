import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:saving_girlfriend/common/services/local_storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'reward_point_provider.g.dart';

@Riverpod(keepAlive: true)
class RewardPoint extends _$RewardPoint {
  late SharedPreferences _prefs;
  static const _prefsKey = 'reward_points';

  @override
  Future<int> build() async {
    _prefs = await ref.watch(sharedPreferencesProvider.future);
    // 起動時にSharedPreferencesから値を読み込む
    final savedPoints = _prefs.getInt(_prefsKey);
    if (savedPoints != null) {
      return savedPoints;
    }
    // 初回起動時
    return 0; // 初期ポイントは0
  }

  // ポイントを加算する
  Future<void> addPoints(int amount) async {
    final currentPoints = state.value ?? 0;
    final newPoints = currentPoints + amount;
    await _prefs.setInt(_prefsKey, newPoints);
    state = AsyncData(newPoints);
  }

  // ポイントを使用する (将来の拡張用)
  Future<bool> usePoints(int amount) async {
    final currentPoints = state.value ?? 0;
    if (currentPoints >= amount) {
      final newPoints = currentPoints - amount;
      await _prefs.setInt(_prefsKey, newPoints);
      state = AsyncData(newPoints);
      return true; // 成功
    }
    return false; // ポイント不足
  }
}
