// Dart imports:
import 'dart:convert';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:saving_girlfriend/common/constants/settings_defaults.dart';
// Drift related imports
import 'package:saving_girlfriend/common/services/drift_service.dart';
import 'package:saving_girlfriend/features/budget/models/budget_history.dart';
import 'package:saving_girlfriend/features/settings/models/settings_state.dart';
import 'package:saving_girlfriend/features/transaction/data/drift_message_history_data_source.dart';
import 'package:saving_girlfriend/features/transaction/data/drift_transaction_history_data_source.dart';
import 'package:saving_girlfriend/features/transaction/data/message_history_data_source.dart';
import 'package:saving_girlfriend/features/transaction/data/transaction_history_data_source.dart';
import 'package:saving_girlfriend/features/transaction/repositories/message_history_repository.dart';
import 'package:saving_girlfriend/features/transaction/repositories/message_history_repository_impl.dart';
import 'package:saving_girlfriend/features/transaction/repositories/transaction_history_repository.dart';
import 'package:saving_girlfriend/features/transaction/repositories/transaction_history_repository_impl.dart';
import 'package:saving_girlfriend/features/tribute/models/tribute_history_state.dart';
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

  static const String _currentCharacterKey = 'current_character';
  static const String _playedEpisode0CharactersKey =
      'played_episode_0_characters'; // 0話再生済みキャラクターのIDリスト
  static const String _notificationsEnabledKey = 'notifications_enabled';
  static const String _targetSavingAmountKey = 'target_saving_amount';
  static const String _bgmVolumeKey = 'bgm_volume';

  // 履歴関連のキー
  // static const String _transactionHistoryKey = 'transaction_history';
  // static const String _messagesKey = 'chat_messages';
  static const String _tributionHistoryKey = 'tribution_history';
  static const String _budgetHistoryKey = 'budget_history';

  // --- 保存 (Save) ---

  /// 現在選択中のキャラクターを保存する
  Future<void> saveCurrentCharacter(String characterId) async {
    await _prefs.setString(_currentCharacterKey, characterId);
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

  void addPlayedReactionIdForRule(String ruleId, String phraseId) {
    final key = 'played_reaction_ids_rule_$ruleId';
    final ids = _prefs.getStringList(key) ?? [];
    if (!ids.contains(phraseId)) {
      ids.add(phraseId);
      _prefs.setStringList(key, ids);
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

  /// 現在選択中のキャラクターを読み込む
  Future<String> getCurrentCharacter() async {
    return _prefs.getString(_currentCharacterKey) ?? '';
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

  List<String> getPlayedReactionIdsForRule(String ruleId) {
    final key = 'played_reaction_ids_rule_$ruleId';
    return _prefs.getStringList(key) ?? [];
  }

  // --- 消去 (Remove) ---

  void clearPlayedReactionIdsForRule(String ruleId) {
    final key = 'played_reaction_ids_rule_$ruleId';
    _prefs.remove(key);
  }
}

// --- Transaction History Providers ---

final transactionHistoryDataSourceProvider =
    Provider<TransactionHistoryDataSource>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return DriftTransactionHistoryDataSource(db);
});

final transactionHistoryRepositoryProvider =
    Provider<TransactionHistoryRepository>((ref) {
  final dataSource = ref.watch(transactionHistoryDataSourceProvider);
  return TransactionHistoryRepositoryImpl(dataSource);
});

// --- Message History Providers ---

final messageHistoryDataSourceProvider =
    Provider<MessageHistoryDataSource>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return DriftMessageHistoryDataSource(db);
});

final messageHistoryRepositoryProvider =
    Provider<MessageHistoryRepository>((ref) {
  final dataSource = ref.watch(messageHistoryDataSourceProvider);
  return MessageHistoryRepositoryImpl(dataSource);
});
