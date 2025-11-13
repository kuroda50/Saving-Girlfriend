// Dart imports:
import 'dart:convert';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Project imports:
import 'package:saving_girlfriend/common/constants/settings_defaults.dart';
import 'package:saving_girlfriend/common/models/message.dart';

import 'package:saving_girlfriend/features/settings/models/settings_state.dart';
import 'package:saving_girlfriend/features/transaction/models/transaction_state.dart';
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
  static const String _transactionHistoryKey = 'transaction_history';
  static const String _messagesKey = 'chat_messages';
  static const String _tributionHistoryKey = 'tribution_history';

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

    // The dailyBudget is now managed by BudgetHistoryRepository
    return SettingsState(
        targetSavingAmount: targetSavingAmount,
        dailyBudget: SettingsDefaults.dailyBudget, // Return a default value
        notificationsEnabled: notificationsEnabled,
        bgmVolume: bgmVolume);
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

  // --- 消去 (Remove) ---

  void clearPlayedReactionIdsForRule(String ruleId) {
    final key = 'played_reaction_ids_rule_$ruleId';
    _prefs.remove(key);
  }
}
