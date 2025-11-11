abstract class MessageHistoryRepository {
  Future<List<Message>> getMessages();
  Future<void> saveMessages(List<Message> messages);
}
