import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:saving_girlfriend/common/models/message.dart';
import 'package:saving_girlfriend/common/services/local_storage_service.dart';
import 'package:saving_girlfriend/features/transaction/repositories/message_history_repository.dart';

part 'chat_history_provider.g.dart';

@riverpod
class ChatHistoryNotifier extends _$ChatHistoryNotifier {
  // Get the repository from the provider.
  MessageHistoryRepository get _repository =>
      ref.read(messageHistoryRepositoryProvider);

  @override
  FutureOr<List<Message>> build() async {
    final savedMessages = await _repository.getMessages();
    if (savedMessages.isNotEmpty) {
      return savedMessages;
    } else {
      // 初期メッセージを設定（初回起動時など）
      return [
        Message(
            id: '1',
            type: MessageType.girlfriend.index,
            text: 'おかえり。今日の支出を教えて。',
            time: nowText()),
      ];
    }
  }

  static String nowText() {
    final now = DateTime.now();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(now.hour)}:${two(now.minute)}';
  }

  // メッセージを追加し、ローカルストレージに保存する
  Future<void> addMessage(Message message) async {
    final currentMessages = state.valueOrNull ?? [];
    final newMessages = [...currentMessages, message];
    state = AsyncValue.data(newMessages);
    await _repository.saveMessages(newMessages);
  }

  // 最後のメッセージを更新する（タイピングインジケーターから実際のメッセージへ）
  Future<void> updateLastMessage(Message newMessage) async {
    final currentMessages = state.valueOrNull ?? [];
    if (currentMessages.isNotEmpty) {
      final updatedList = List<Message>.from(currentMessages);
      updatedList[updatedList.length - 1] = newMessage;
      state = AsyncValue.data(updatedList);
      await _repository.saveMessages(updatedList);
    }
  }

  // 最後のメッセージを削除する（タイピングインジケーターの削除など）
  Future<void> removeLastMessage() async {
    final currentMessages = state.valueOrNull ?? [];
    if (currentMessages.isNotEmpty) {
      final updatedList = List<Message>.from(currentMessages)..removeLast();
      state = AsyncValue.data(updatedList);
      await _repository.saveMessages(updatedList);
    }
  }

  // メッセージリストをクリアする（必要であれば）
  Future<void> clearMessages() async {
    state = const AsyncValue.data([]);
    await _repository.saveMessages([]);
  }
}
