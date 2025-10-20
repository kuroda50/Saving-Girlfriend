// Dart imports:
import 'dart:convert';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Project imports:
import 'package:saving_girlfriend/constants/settings_defaults.dart';
import 'package:saving_girlfriend/models/budget_history.dart';
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
  // 設定関連のキー
  static const String _notificationsEnabledKey = 'notifications_enabled';
  static const String _bgmVolumeKey = 'bgm_volume';
  static const String _targetSavingAmountKey = 'target_saving_amount';
  static const String _budgetHistoryKey = 'budget_history';

  // --- 保存 (Save) ---

  /// ユーザーIDを保存する
  Future<void> saveUserId(String userId) async {
    await _prefs.setString(_userIdKey, userId);
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

  /// ストーリー再生済みフラグを保存
  Future<void> setPlayedStory() async {
    await _prefs.setBool('has_played_story', true);
  }

  // --- 読み込み (Load) ---

  //story再生
  Future<bool> hasPlayedStory() async {
    return _prefs.getBool('has_played_story') ?? false;
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
}

// <データ設計>
// current_character: "characterA" (String)
// characterA_likeability: 85(int)
// transaction_history
// [
//   {"id": "transaction_1759380715075", "type": "income", "date": "2024-06-25", "amount": 50000, "category": category},
//   {"id": "transaction_1759380715075", "type": "expense", "date": "2024-06-25", "amount": 1000, "category": category},
//   {"id": "transaction_1759380715075", "type": "expense", "date": "2024-06-26", "amount": 500, "category": category},
// ]List<String>
// tribute_history
// [
//  {"id": 0101101001..., "character": "SuzunariOto", "date": "2024-06-25", "amount": 500},
//  {"id": 0101101001..., "character": "SuzunariOto", "date": "2024-06-25", "amount": 500},
//  {"id": 0101101001..., "character": "SuzunariOto", "date": "2024-06-25", "amount": 500},
// ]

// 設定関連
// notifications_enabled: true (bool)
// bgm_volume: 75 (double)
// target_saving_amount: 100000 (int)
// daily_budget_amount: 1000 (int)
