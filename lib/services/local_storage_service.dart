// Dart imports:
import 'dart:convert';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Project imports:
import 'package:saving_girlfriend/constants/settings_defaults.dart';
import 'package:saving_girlfriend/models/budget_history.dart';
import 'package:saving_girlfriend/models/message.dart';
import 'package:saving_girlfriend/models/settings_state.dart';
import 'package:saving_girlfriend/models/transaction_state.dart';
import 'package:saving_girlfriend/models/tribute_history_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  static const String _userIdKey = 'user_id';
  static const String _currentCharacterKey = 'current_character';
  static const String _likeabilityKeyPrefix = '_likeability'; // キャラごとに好感度を保存
  static const String _transactionHistoryKey = 'transaction_history';
  static const String _tributionHistoryKey = 'tribution_history';
  static const String _playedEpisode0CharactersKey =
      'played_episode_0_characters'; // 0話再生済みキャラクターのIDリスト
  // 設定関連のキー
  static const String _notificationsEnabledKey = 'notifications_enabled';
  static const String _bgmVolumeKey = 'bgm_volume';
  static const String _targetSavingAmountKey = 'target_saving_amount';
  static const String _budgetHistoryKey = 'budget_history';
  static const String _messagesKey = 'chat_messages'; // 会話履歴のキー

  // --- 保存 (Save) ---

  /// ユーザーIDを保存する
  Future<void> saveUserId(String userId) async {
    await _prefs.setString(_userIdKey, userId);
  }

  /// 会話履歴を保存する
  Future<void> saveMessages(List<Message> messages) async {
    final String encodedData =
        jsonEncode(messages.map((m) => m.toJson()).toList());
    await _prefs.setString(_messagesKey, encodedData);
  }

  /// 現在選択中のキャラクターを保存する
  Future<void> saveCurrentCharacter(String characterId) async {
    await _prefs.setString(_currentCharacterKey, characterId);
  }

  Future<void> saveTransactionHistory(List<TransactionState> history) async {
    String jsonString = jsonEncode(history);
    await _prefs.setString(_transactionHistoryKey, jsonString);
  }

  Future<void> saveTributionHistory(List<TributeState> history) async {
    String jsonString = jsonEncode(history);
    await _prefs.setString(_tributionHistoryKey, jsonString);
  }

  Future<void> saveSettings(SettingsState setting) async {
    await _prefs.setInt(_targetSavingAmountKey, setting.targetSavingAmount);
    await _prefs.setBool(
        _notificationsEnabledKey, setting.notificationsEnabled);
    await _prefs.setDouble(_bgmVolumeKey, setting.bgmVolume);
    await updateDailyBudget(setting.dailyBudget);
  }

  Future<void> updateDailyBudget(int newBudget) async {
    final history = await getBudgetHistory();
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    // 今日の履歴が既に存在するかチェック
    final index = history.indexWhere((h) =>
        h.date.year == todayDate.year &&
        h.date.month == todayDate.month &&
        h.date.day == todayDate.day);

    if (index != -1) {
      // 存在する場合：金額を上書き
      history[index] = BudgetHistory(date: todayDate, amount: newBudget);
    } else {
      // 存在しない場合：新しい履歴を追加
      history.add(BudgetHistory(date: todayDate, amount: newBudget));
    }
    final List<Map<String, dynamic>> budgetHistoryJson =
        history.map((h) => h.toJson()).toList();
    await _prefs.setString(_budgetHistoryKey, jsonEncode(budgetHistoryJson));
  }

  /// 指定されたキャラクターの0話が再生済みであることを保存する
  Future<void> setEpisode0Played(String characterId) async {
    final List<String> playedCharacters = getPlayedEpisode0Characters();
    if (!playedCharacters.contains(characterId)) {
      playedCharacters.add(characterId);
      await _prefs.setStringList(
          _playedEpisode0CharactersKey, playedCharacters);
    }
  }

  // --- 読み込み (Load) ---

  /// 指定されたキャラクターの0話が再生済みかどうかを返す
  bool hasPlayedEpisode0(String characterId) {
    final List<String> playedCharacters = getPlayedEpisode0Characters();
    return playedCharacters.contains(characterId);
  }

  /// 0話が再生済みのキャラクターIDのリストを取得する
  List<String> getPlayedEpisode0Characters() {
    return _prefs.getStringList(_playedEpisode0CharactersKey) ?? [];
  }

  /// ユーザーIDを読み込む
  Future<String?> getUserId() async {
    return _prefs.getString(_userIdKey);
  }

  /// 現在選択中のキャラクターを読み込む
  Future<String?> getCurrentCharacter() async {
    return _prefs.getString(_currentCharacterKey);
  }

  /// キャラクターの好感度を読み込む
  Future<int> getLikeability(String characterId) async {
    // ここを書き換える
    return _prefs.getInt('$characterId$_likeabilityKeyPrefix') ?? 1;
  }

  Future<List<TransactionState>> getTransactionHistory() async {
    final jsonString = _prefs.getString(_transactionHistoryKey);
    if (jsonString != null && jsonString.isNotEmpty) {
      final List<dynamic> decodedList = jsonDecode(jsonString);
      final result = decodedList
          .map((item) =>
              TransactionState.fromJson(Map<String, dynamic>.from(item)))
          .toList();
      return result;
    }
    // データがない場合は空のリストを返す
    return [];
  }

  Future<List<TributeState>> getTributionHistory() async {
    final jsonString = _prefs.getString(_tributionHistoryKey);
    if (jsonString != null && jsonString.isNotEmpty) {
      final List<dynamic> decodedList = jsonDecode(jsonString);
      final List<TributeState> result = decodedList
          .map((item) => TributeState(
              id: item["id"] as String,
              character: item["character"] as String,
              date: item["date"] as DateTime,
              amount: item["amount"] as int))
          .toList();
      return result;
    }
    // データがない場合は空のリストを返す
    return [];
  }

  Future<SettingsState> getSettings() async {
    final bool notificationsEnabled =
        _prefs.getBool(_notificationsEnabledKey) ??
            SettingsDefaults.notificationsEnabled;
    final double bgmVolume =
        _prefs.getDouble(_bgmVolumeKey) ?? SettingsDefaults.bgmVolume;
    final int targetSavingAmount = _prefs.getInt(_targetSavingAmountKey) ??
        SettingsDefaults.targetSavingAmount;

    final budgetHistory = await getBudgetHistory();
    budgetHistory.sort((a, b) => b.date.compareTo(a.date));
    final int currentDailyBudget = budgetHistory.isNotEmpty
        ? budgetHistory.first.amount // 最新の予算を取得
        : SettingsDefaults.dailyBudget;
    // final int dailyBudget =
    //     _prefs.getInt(_budgetHistoryKey) ?? SettingsDefaults.dailyBudget;

    return SettingsState(
        targetSavingAmount: targetSavingAmount,
        dailyBudget: currentDailyBudget,
        notificationsEnabled: notificationsEnabled,
        bgmVolume: bgmVolume);
  }

  Future<List<BudgetHistory>> getBudgetHistory() async {
    final String? jsonString = _prefs.getString(_budgetHistoryKey);
    if (jsonString != null) {
      final List<dynamic> decodedList = jsonDecode(jsonString);
      return decodedList.map((item) => BudgetHistory.fromJson(item)).toList();
    }
    // データがない場合は、デフォルト値を含むリストを返す
    return [
      BudgetHistory(
        date: DateTime.now(), // 過去の適当な日付
        amount: SettingsDefaults.dailyBudget,
      )
    ];
  }

  /// 会話履歴を読み込む
  Future<List<Message>> loadMessages() async {
    final String? encodedData = _prefs.getString(_messagesKey);
    if (encodedData == null) {
      return [];
    }
    final List<dynamic> decodedData = jsonDecode(encodedData);
    return decodedData.map((item) => Message.fromJson(item)).toList();
  }
}
