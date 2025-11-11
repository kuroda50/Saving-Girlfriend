import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../common/models/message.dart';
import 'message_history_data_source.dart';

class SharedPrefMessageHistoryDataSource implements MessageHistoryDataSource {
  final SharedPreferences _prefs;

  SharedPrefMessageHistoryDataSource(this._prefs);

  static const String _messagesKey = 'chat_messages';

  @override
  Future<List<Message>> fetchAll() async {
    final String? encodedData = _prefs.getString(_messagesKey);
    if (encodedData == null) {
      return [];
    }
    final List<dynamic> decodedData = jsonDecode(encodedData);
    return decodedData.map((item) => Message.fromJson(item)).toList();
  }

  @override
  Future<void> saveAll(List<Message> messages) async {
    final String encodedData =
        jsonEncode(messages.map((m) => m.toJson()).toList());
    await _prefs.setString(_messagesKey, encodedData);
  }
}
