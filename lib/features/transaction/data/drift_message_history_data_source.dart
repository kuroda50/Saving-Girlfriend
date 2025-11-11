import 'package:saving_girlfriend/common/models/message.dart';
import 'package:saving_girlfriend/common/services/drift_service.dart';
import 'package:saving_girlfriend/features/transaction/data/message_history_data_source.dart';

class DriftMessageHistoryDataSource implements MessageHistoryDataSource {
  final AppDatabase _db;

  DriftMessageHistoryDataSource(this._db);

  @override
  Future<List<AppMessage>> fetchAll() async {
    final messages = await _db.select(_db.messages).get();
    return messages
        .map((m) => AppMessage(
              dbId: m.dbId,
              id: m.id,
              type: MessageType.values
                  .byName(m.type)
                  .index, // Convert String to int
              text: m.text,
              time: m.time,
            ))
        .toList();
  }

  @override
  Future<void> saveAll(List<AppMessage> messages) async {
    await _db.batch((batch) {
      batch.deleteAll(_db.messages);
      batch.insertAll(
          _db.messages,
          messages
              .map((m) => Message(
                    dbId: m.dbId,
                    id: m.id,
                    type: MessageType
                        .values[m.type].name, // Convert int to String
                    text: m.text,
                    time: m.time,
                  ))
              .toList());
    });
  }
}
