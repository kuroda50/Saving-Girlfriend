import 'package:isar/isar.dart';
import 'message_history_data_source.dart';

class IsarMessageHistoryDataSource implements MessageHistoryDataSource {
  final Isar _isar;
  IsarMessageHistoryDataSource(this._isar);

  @override
  Future<List<Message>> fetchAll() async {
    return await _isar.messages.where().findAll();
  }

  @override
  Future<void> saveAll(List<Message> messages) async {
    await _isar.writeTxn(() async {
      // To match the previous logic of replacing the entire list, we clear it first.
      await _isar.messages.clear();
      await _isar.messages.putAll(messages);
    });
  }
}
