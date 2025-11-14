// lib/features/transaction/providers/chat_history_provider.dart

// ▼▼▼ 以下の4行を追加 ▼▼▼
import 'package:intl/intl.dart';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:saving_girlfriend/app/providers/today_savings_provider.dart';
import 'package:saving_girlfriend/common/models/message.dart';
import 'package:saving_girlfriend/common/providers/uuid_provider.dart';
import 'package:saving_girlfriend/common/services/local_storage_service.dart';
import 'package:saving_girlfriend/features/transaction/models/transaction_state.dart';

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
    // state.value! がnull許容なので、?? [] でフォールバック
    final currentMessages = state.value ?? [];
    state = AsyncValue.data([...currentMessages, message]);
    await _localStorageService.saveMessages(state.value!);
  }

  // 最後のメッセージを更新する（タイピングインジケーターから実際のメッセージへ）
  Future<void> updateLastMessage(Message newMessage) async {
    if (state.value != null && state.value!.isNotEmpty) {
      final updatedList = List<Message>.from(state.value!);
      updatedList[updatedList.length - 1] = newMessage;
      state = AsyncValue.data(updatedList);
      await _localStorageService.saveMessages(state.value!);
    }
  }

  // 最後のメッセージを削除する（タイピングインジケーターの削除など）
  Future<void> removeLastMessage() async {
    if (state.value != null && state.value!.isNotEmpty) {
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

  // ▼▼▼ 以下のメソッドを丸ごと追加 ▼▼▼
  /// 支出編集の報告メッセージをチャットに自動追加する
  Future<void> addEditReportMessage(
    TransactionState oldTx,
    TransactionState newTx,
  ) async {
    final categoryName = newTx.category;
    final newAmountStr =
        NumberFormat.currency(locale: 'ja_JP', symbol: '').format(newTx.amount);

    final todayAmount = await ref.read(todaySavingsProvider.future);
    final String messageText;
    if (todayAmount > 0) {
      // (A) 残額がプラスの場合
      final remainingAmountStr =
          NumberFormat.currency(locale: 'ja_JP', symbol: '¥')
              .format(todayAmount);
      messageText =
          'あ、さっきの$categoryName、$newAmountStr円に直しといたよ！ 今日の残りは$remainingAmountStrになったね！';
    } else {
      // (B) 残額が0円以下（マイナス）の場合
      messageText =
          'あ、さっきの支出$categoryName、$newAmountStr円に直しといたよ！ あ、でも今日使えるお金超えちゃってるから気をつけてね…！';
    }

    // 3. 新しいMessageオブジェクトを作成
    final newMessage = Message(
      id: ref.read(uuidProvider).v4(), // UUIDでユニークなIDを生成
      type: MessageType.girlfriend,
      text: messageText,
      time: ChatHistoryNotifier.nowText(), // 既存のstaticメソッドを利用
    );

    // 4. 既存の addMessage メソッドを呼び出して、状態更新と保存を行う
    await addMessage(newMessage);
  }

  Future<void> addDeleteReportMessage(
    TransactionState deletedTx,
  ) async {
    // 1. メッセージ文言を生成
    final categoryName = deletedTx.category;

    // 2. 残り利用可能額を取得 (削除 *後* の金額)
    final todayAmount = await ref.read(todaySavingsProvider.future);

    // ▼▼▼▼ ここから変更 ▼▼▼▼
    // 3. 残額に応じてメッセージを分岐
    final String messageText;
    if (todayAmount > 0) {
      // (A) 残額がプラスの場合
      final remainingAmountStr =
          NumberFormat.currency(locale: 'ja_JP', symbol: '¥')
              .format(todayAmount);
      messageText =
          'あ、さっきの$categoryName、消しといたよ！ 今日の残りは$remainingAmountStrになったね！';
    } else {
      // (B) 残額が0円以下（マイナス）の場合
      messageText = 'あ、さっきの$categoryName、消しといたよ！ でも、まだ今日使えるお金超えちゃってるみたい…！';
    }
    // ▲▲▲▲ ここまで変更 ▲▲▲▲

    // 3. 新しいMessageオブジェクトを作成
    final newMessage = Message(
      id: ref.read(uuidProvider).v4(), // UUIDでユニークなIDを生成
      type: MessageType.girlfriend,
      text: messageText,
      time: ChatHistoryNotifier.nowText(), // 既存のstaticメソッドを利用
    );

    // 4. 既存の addMessage メソッドを呼び出して、状態更新と保存を行う
    await addMessage(newMessage);
  }
  // ▲▲▲ -------------------------- ▲▲▲
}
