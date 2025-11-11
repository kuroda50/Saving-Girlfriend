import '../data/message_history_data_source.dart';
import 'message_history_repository.dart';

class MessageHistoryRepositoryImpl implements MessageHistoryRepository {
  final MessageHistoryDataSource _dataSource;

  MessageHistoryRepositoryImpl(this._dataSource);

  @override
  Future<List<Message>> getMessages() {
    return _dataSource.fetchAll();
  }

  @override
  Future<void> saveMessages(List<Message> messages) {
    return _dataSource.saveAll(messages);
  }
}
