import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  // インスタンスは最初に取得する
  static late SharedPreferences prefs;

  // 各データのキーを定数として定義しておくとタイプミスを防げます
  static const String _userIdKey = 'user_id';
  static const String _currentCharacterKey = 'current_character';
  static const String _likeabilityKeyPrefix = '_likeability'; // キャラごとに好感度を保存
  static const String _tributeHistoryKey = 'tribute_history';
  static const String _targetSavingAmountKey = 'target_saving_amount';
  static const String _defaultContributionAmountKey =
      'default_contribution_amount';
  static const String _notificationsEnabledKey = 'notifications_enabled';
  static const String _bgmVolumeKey = 'bgm_volume';

  // --- 初期化 (Initialization) ---

  /// SharedPreferencesを初期化し、アプリ起動時に一度だけ呼び出す
  static Future<void> init() async {
    prefs = await SharedPreferences.getInstance();
  }

  // --- 保存 (Save) ---

  /// ユーザーIDを保存する
  Future<void> saveUserId(String userId) async {
    await prefs.setString(_userIdKey, userId);
  }

  /// 現在選択中のキャラクターを保存する
  Future<void> saveCurrentCharacter(String characterId) async {
    await prefs.setString(_currentCharacterKey, characterId);
  }

  /// キャラクターの好感度を保存する
  Future<void> saveLikeability(String characterId, int value) async {
    await prefs.setInt('$characterId$_likeabilityKeyPrefix', value);
  }

  /// 貢ぎ物の履歴を保存する
  Future<void> saveTributeHistory(List<Map<String, dynamic>> history) async {
    String jsonString = jsonEncode(history);
    await prefs.setString(_tributeHistoryKey, jsonString);
  }

  /// アプリの設定をまとめて保存する
  Future<void> saveSettings({
    required int targetSavingAmount,
    required int defaultContributionAmount,
    required bool notificationsEnabled,
    required double bgmVolume,
  }) async {
    await prefs.setInt(_targetSavingAmountKey, targetSavingAmount);
    await prefs.setInt(
        _defaultContributionAmountKey, defaultContributionAmount);
    await prefs.setBool(_notificationsEnabledKey, notificationsEnabled);
    await prefs.setDouble(_bgmVolumeKey, bgmVolume);
  }

  // --- 読み込み (Load) ---

  /// ユーザーIDを読み込む
  Future<String?> getUserId() async {
    return prefs.getString(_userIdKey);
  }

  /// 現在選択中のキャラクターを読み込む
  Future<String?> getCurrentCharacter() async {
    return prefs.getString(_currentCharacterKey);
  }

  /// キャラクターの好感度を読み込む
  Future<int> getLikeability(String characterId) async {
    // 保存されていない場合は初期値50を返す
    return prefs.getInt('$characterId$_likeabilityKeyPrefix') ?? 50;
  }

  /// 貢ぎ物の履歴を読み込む
  Future<List<Map<String, dynamic>>> getTributeHistory() async {
    final jsonString = prefs.getString(_tributeHistoryKey);
    if (jsonString != null && jsonString.isNotEmpty) {
      final List<dynamic> decodedList = jsonDecode(jsonString);
      return decodedList
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }
    // データがない場合は空のリストを返す
    return [];
  }

  /// 目標貯金額を読み込む
  Future<int?> getTargetSavingAmount() async {
    return prefs.getInt(_targetSavingAmountKey);
  }

  /// デフォルトの貢ぎ額を読み込む
  Future<int?> getDefaultContributionAmount() async {
    return prefs.getInt(_defaultContributionAmountKey);
  }

  /// 通知が有効かどうかを読み込む
  Future<bool> getNotificationsEnabled() async {
    // 保存されていない場合はデフォルトでtrueを返す
    return prefs.getBool(_notificationsEnabledKey) ?? true;
  }

  /// BGMの音量を読み込む
  Future<double> getBgmVolume() async {
    // 保存されていない場合はデフォルトで0.75を返す
    return prefs.getDouble(_bgmVolumeKey) ?? 0.75;
  }
}
