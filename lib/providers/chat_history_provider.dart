import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:saving_girlfriend/models/message.dart';
import 'package:saving_girlfriend/services/local_storage_service.dart';

part 'chat_history_provider.g.dart';

@riverpod
class ChatHistoryNotifier extends _$ChatHistoryNotifier {
  late final LocalStorageService _localStorageService;

  @override
  FutureOr<List<Message>> build() async {
    _localStorageService = await ref.watch(localStorageServiceProvider.future);
    final savedMessages = await _localStorageService.loadMessages();
    if (savedMessages.isNotEmpty) {
      return savedMessages;
    } else {
      // 初期メッセージを設定（初回起動時など）
      return [
        Message(
            id: '1',
            type: MessageType.girlfriend,
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
    state = AsyncValue.data([...state.value!, message]);
    await _localStorageService.saveMessages(state.value!);
  }

  // 最後のメッセージを更新する（タイピングインジケーターから実際のメッセージへ）
  Future<void> updateLastMessage(Message newMessage) async {
    if (state.value!.isNotEmpty) {
      final updatedList = List<Message>.from(state.value!);
      updatedList[updatedList.length - 1] = newMessage;
      state = AsyncValue.data(updatedList);
      await _localStorageService.saveMessages(state.value!);
    }
  }

  // 最後のメッセージを削除する（タイピングインジケーターの削除など）
  Future<void> removeLastMessage() async {
    if (state.value!.isNotEmpty) {
      final updatedList = List<Message>.from(state.value!)..removeLast();
      state = AsyncValue.data(updatedList);
      await _localStorageService.saveMessages(state.value!);
    }
  }

  // メッセージリストをクリアする（必要であれば）
  Future<void> clearMessages() async {
    state = const AsyncValue.data([]);
    await _localStorageService.saveMessages(state.value!);
  }
}
