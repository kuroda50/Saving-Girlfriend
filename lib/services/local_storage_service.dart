import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  // 各データのキーを定数として定義しておくとタイプミスを防げます
  static const String _currentCharacterKey = 'current_character';
  static const String _likeabilityKeyPrefix = '_likeability'; // キャラごとに好感度を保存
  static const String _tributeHistoryKey = 'tribute_history';
  static const String _targetSavingAmountKey = 'target_saving_amount';
  static const String _defaultContributionAmountKey = 'default_contribution_amount';
  static const String _notificationsEnabledKey = 'notifications_enabled';
  static const String _bgmVolumeKey = 'bgm_volume';

  // --- 保存 (Save) ---

  Future<void> saveCurrentCharacter(String characterId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currentCharacterKey, characterId);
  }

  Future<void> saveLikeability(String characterId, int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('$characterId$_likeabilityKeyPrefix', value);
  }

  Future<void> saveTributeHistory(List<Map<String, dynamic>> history) async {
    final prefs = await SharedPreferences.getInstance();
    String jsonString = jsonEncode(history);
    await prefs.setString(_tributeHistoryKey, jsonString);
  }

  Future<void> saveSettings({
    required int targetSavingAmount,
    required int defaultContributionAmount,
    required bool notificationsEnabled,
    required double bgmVolume,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_targetSavingAmountKey, targetSavingAmount);
    await prefs.setInt(_defaultContributionAmountKey, defaultContributionAmount);
    await prefs.setBool(_notificationsEnabledKey, notificationsEnabled);
    await prefs.setDouble(_bgmVolumeKey, bgmVolume);
  }


  // --- 読み込み (Load) ---

  Future<String?> getCurrentCharacter() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_currentCharacterKey);
  }

  Future<int> getLikeability(String characterId) async {
    final prefs = await SharedPreferences.getInstance();
    // 保存されていない場合の初期値は 50 などに設定
    return prefs.getInt('$characterId$_likeabilityKeyPrefix') ?? 50;
  }

  Future<List<Map<String, dynamic>>> getTributeHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_tributeHistoryKey);
    if (jsonString != null && jsonString.isNotEmpty) {
      // JSON文字列をデコードして List<Map> に変換
      final List<dynamic> decodedList = jsonDecode(jsonString);
      return decodedList.map((item) => Map<String, dynamic>.from(item)).toList();
    }
    // データがない場合は空のリストを返す
    return [];
  }

  Future<int?> getTargetSavingAmount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_targetSavingAmountKey);
  }

  Future<int?> getDefaultContributionAmount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_defaultContributionAmountKey);
  }

  Future<bool> getNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_notificationsEnabledKey) ?? true; // Default to true
  }

  Future<double> getBgmVolume() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_bgmVolumeKey) ?? 0.75; // Default to 0.75
  }
}

// <データ設計>
// current_character: "characterA" (String)
// characterA_likeability: 85(int)
// [
//   {"character": "A", "date": "2024-06-25", "amount": 1000},
//   {"character": "B", "date": "2024-06-26", "amount": 500}
// ]List<String>
// target_saving_amount: 100000 (int)
// default_contribution_amount: 500 (int)
// notifications_enabled: true (bool)
// bgm_volume: 0.75 (double)