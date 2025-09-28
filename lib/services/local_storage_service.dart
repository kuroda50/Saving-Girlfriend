import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:saving_girlfriend/models/settings_state.dart';
import 'package:saving_girlfriend/models/tribute_history_state.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

final sharedPreferencesProvider =
    FutureProvider<SharedPreferences>((ref) async {
  return SharedPreferences.getInstance();
});
final localStorageServiceProvider =
    FutureProvider<LocalStorageService>((ref) async {
  final sharedPreferences = await ref.watch(sharedPreferencesProvider.future);
  return LocalStorageService(sharedPreferences);
});

class LocalStorageService {
  final SharedPreferences _prefs;
  LocalStorageService(this._prefs);

  // static const String _userIdKey = 'user_id';
  static const String _currentCharacterKey = 'current_character';
  static const String _likeabilityKeyPrefix = '_likeability'; // キャラごとに好感度を保存
  static const String _transactionHistoryKey = 'transaction_history';
  static const String _tributionHistoryKey = 'tribution_history';
  static const String _targetSavingAmountKey = 'target_saving_amount';
  static const String _defaultContributionAmountKey =
      'default_contribution_amount';
  static const String _notificationsEnabledKey = 'notifications_enabled';
  static const String _bgmVolumeKey = 'bgm_volume';

  // --- 保存 (Save) ---

  Future<void> saveCurrentCharacter(String characterId) async {
    await _prefs.setString(_currentCharacterKey, characterId);
  }

  Future<void> saveTransactionHistory(
      List<Map<String, dynamic>> history) async {
    String jsonString = jsonEncode(history);
    await _prefs.setString(_transactionHistoryKey, jsonString);
  }

  Future<void> saveTributionHistory(List<TributeHistoryState> history) async {
    String jsonString = jsonEncode(history);
    await _prefs.setString(_tributionHistoryKey, jsonString);
  }

  Future<void> saveSettings(SettingsState setting) async {
    await _prefs.setInt(_targetSavingAmountKey, setting.targetSavingAmount);
    await _prefs.setInt(
        _defaultContributionAmountKey, setting.defaultContributionAmount);
    await _prefs.setBool(
        _notificationsEnabledKey, setting.notificationsEnabled);
    await _prefs.setDouble(_bgmVolumeKey, setting.bgmVolume);
  }

  // --- 読み込み (Load) ---

  Future<String?> getCurrentCharacter() async {
    return _prefs.getString(_currentCharacterKey);
  }

  Future<int> getLikeability(String characterId) async {
    // ここを書き換える
    return _prefs.getInt('$characterId$_likeabilityKeyPrefix') ?? 1;
  }

  Future<List<Map<String, dynamic>>> getTransactionHistory() async {
    final jsonString = _prefs.getString(_transactionHistoryKey);
    if (jsonString != null && jsonString.isNotEmpty) {
      final List<dynamic> decodedList = jsonDecode(jsonString);
      final result =
          decodedList.map((item) => Map<String, dynamic>.from(item)).toList();
      print(result);
      return result;
    }
    // データがない場合は空のリストを返す
    return [];
  }

  Future<List<TributeHistoryState>> getTributionHistory() async {
    final jsonString = _prefs.getString(_tributionHistoryKey);
    if (jsonString != null && jsonString.isNotEmpty) {
      final List<dynamic> decodedList = jsonDecode(jsonString);
      final List<TributeHistoryState> result = decodedList
          .map((item) => TributeHistoryState(
              id: item["id"] as Uuid,
              character: item["character"] as String,
              date: item["date"] as DateTime,
              amount: item["amount"] as int))
          .toList();
      print(result);
      return result;
    }
    // データがない場合は空のリストを返す
    return [];
  }

  Future<SettingsState> getSettings() async {
    final int targetSavingAmount =
        _prefs.getInt(_targetSavingAmountKey) ?? 100000;
    final int defaultContributionAmount =
        _prefs.getInt(_defaultContributionAmountKey) ?? 500;
    final bool notificationsEnabled =
        _prefs.getBool(_notificationsEnabledKey) ?? true;
    final double bgmVolume = _prefs.getDouble(_bgmVolumeKey) ?? 0.75;
    return SettingsState(
        targetSavingAmount: targetSavingAmount,
        defaultContributionAmount: defaultContributionAmount,
        notificationsEnabled: notificationsEnabled,
        bgmVolume: bgmVolume);
  }
}

// <データ設計>
// current_character: "characterA" (String)
// characterA_likeability: 85(int)
// transaction_history
// [
//   {"type": "income", "date": "2024-06-25", "amount": 50000, "category": category},
//   {"type": "expense", "date": "2024-06-25", "amount": 1000, "category": category},
//   {"type": "expense", "date": "2024-06-26", "amount": 500, "category": category},
// ]List<String>
// tribute_history
// [
//  {"id": 0101101001..., "character": "SuzunariOto", "date": "2024-06-25", "amount": 500},
//  {"id": 0101101001..., "character": "SuzunariOto", "date": "2024-06-25", "amount": 500},
//  {"id": 0101101001..., "character": "SuzunariOto", "date": "2024-06-25", "amount": 500},
// ]

// target_saving_amount: 100000 (int)
// default_contribution_amount: 500 (int)
// added_saging_amount: 20000 (int)

// notifications_enabled: true (bool)
// bgm_volume: 0.75 (double)
