import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/transaction_state.dart';
import 'transaction_history_data_source.dart';

class SharedPrefTransactionHistoryDataSource
    implements TransactionHistoryDataSource {
  final SharedPreferences _prefs;

  SharedPrefTransactionHistoryDataSource(this._prefs);

  static const String _transactionHistoryKey = 'transaction_history';

  @override
  Future<List<TransactionState>> fetchAll() async {
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

  @override
  Future<void> saveAll(List<TransactionState> histories) async {
    String jsonString = jsonEncode(histories.map((e) => e.toJson()).toList());
    await _prefs.setString(_transactionHistoryKey, jsonString);
  }
}
