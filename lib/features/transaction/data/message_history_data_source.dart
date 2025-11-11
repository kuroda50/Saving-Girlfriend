abstract class MessageHistoryDataSource {
  Future<List<Message>> fetchAll();
  Future<void> saveAll(List<Message> messages);
}
