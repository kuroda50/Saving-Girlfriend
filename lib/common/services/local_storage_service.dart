// Dart imports:
import 'dart:convert';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Project imports:
import 'package:saving_girlfriend/common/constants/settings_defaults.dart';
import 'package:saving_girlfriend/common/models/message.dart';
import 'package:saving_girlfriend/features/budget/models/budget_history.dart';
import 'package:saving_girlfriend/features/settings/models/settings_state.dart';
import 'package:saving_girlfriend/features/transaction/models/transaction_state.dart';
import 'package:saving_girlfriend/features/tribute/models/tribute_history_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ★ 1. `sharedPreferencesProvider` -> `_sharedPreferencesProvider` にリネーム
final _sharedPreferencesProvider =
    FutureProvider<SharedPreferences>((ref) async {
  return SharedPreferences.getInstance();
});

final localStorageServiceProvider =
    FutureProvider<LocalStorageService>((ref) async {
  // ★ 2. `_sharedPreferencesProvider` を watch するように修正
  final sharedPreferences = await ref.watch(_sharedPreferencesProvider.future);
  return LocalStorageService(sharedPreferences);
});

class LocalStorageService {
  final SharedPreferences _prefs;
  LocalStorageService(this._prefs);

  static const String _currentCharacterKey = 'current_character';
  static const String _playedEpisode0CharactersKey =
      'played_episode_0_characters'; // 0話再生済みキャラクターのIDリスト
  static const String _notificationsEnabledKey = 'notifications_enabled';
  static const String _targetSavingAmountKey = 'target_saving_amount';
  static const String _bgmVolumeKey = 'bgm_volume';

  // 履歴関連のキー
  static const String _transactionHistoryKey = 'transaction_history';
  static const String _tributionHistoryKey = 'tribution_history';
  static const String _budgetHistoryKey = 'budget_history';
  static const String _messagesKey = 'chat_messages';

  // ★★★ 3. ここからミッション用のキーを追加 ★★★
  static const String _missionStateKey = 'mission_state';
  static const String _missionDailyUpdatedKey = 'mission_last_updated';
  static const String _missionWeeklyUpdatedKey = 'mission_last_weekly_updated';

  // ★★★ 1. リワードポイント用のキーを追加 ★★★
  static const String _rewardPointsKey = 'reward_points';

  // --- 保存 (Save) ---

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
    String jsonString = jsonEncode(
        history.map((tx) => tx.toJson()).toList()); // ★ .toJson() を追加
    await _prefs.setString(_transactionHistoryKey, jsonString);
  }

  Future<void> saveTributionHistory(List<TributeState> history) async {
    String jsonString =
        jsonEncode(history.map((t) => t.toJson()).toList()); // ★ .toJson() を追加
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

  void addPlayedReactionIdForRule(String ruleId, String phraseId) {
    final key = 'played_reaction_ids_rule_$ruleId';
    final ids = _prefs.getStringList(key) ?? [];
    if (!ids.contains(phraseId)) {
      ids.add(phraseId);
      _prefs.setStringList(key, ids);
    }
  }

  // ★★★ 4. ここからミッション用のセーブメソッドを追加 ★★★

  // --- ミッション進捗のセーブ ---
  Future<void> saveMissions(String missionsJson) async {
    await _prefs.setString(_missionStateKey, missionsJson);
  }

  // --- 更新日のセーブ (キーを動的に指定) ---
  Future<void> saveMissionLastUpdated(String keyType, String value) async {
    final key = (keyType == 'daily')
        ? _missionDailyUpdatedKey
        : _missionWeeklyUpdatedKey;
    await _prefs.setString(key, value);
  }

  // ★★★ 2. リワードポイント用の保存メソッドを追加 ★★★
  Future<void> saveRewardPoints(int points) async {
    await _prefs.setInt(_rewardPointsKey, points);
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

  /// 現在選択中のキャラクターを読み込む
  Future<String> getCurrentCharacter() async {
    return _prefs.getString(_currentCharacterKey) ?? '';
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
          .map((item) => TributeState.fromJson(
              Map<String, dynamic>.from(item))) // ★ .fromJson() を使用
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

  List<String> getPlayedReactionIdsForRule(String ruleId) {
    final key = 'played_reaction_ids_rule_$ruleId';
    return _prefs.getStringList(key) ?? [];
  }

  // ★★★ 5. ここからミッション用のロード/削除メソッドを追加 ★★★

  // --- ミッション進捗のロード ---
  Future<String?> loadMissions() async {
    return _prefs.getString(_missionStateKey);
  }

  // --- 更新日のロード (キーを動的に指定) ---
  Future<String?> loadMissionLastUpdated(String keyType) async {
    final key = (keyType == 'daily')
        ? _missionDailyUpdatedKey
        : _missionWeeklyUpdatedKey;
    return _prefs.getString(key);
  }

  // ★★★ 3. リワードポイント用の読み込みメソッドを追加 ★★★
  Future<int> loadRewardPoints() async {
    // デフォルト値の 0 を返すロジックもここに含める
    return _prefs.getInt(_rewardPointsKey) ?? 0;
  }

  // --- 消去 (Remove) ---

  void clearPlayedReactionIdsForRule(String ruleId) {
    final key = 'played_reaction_ids_rule_$ruleId';
    _prefs.remove(key);
  }

  // --- ミッション進捗の削除 (エラー時) ---
  Future<void> removeMissions() async {
    await _prefs.remove(_missionStateKey);
  }
}
