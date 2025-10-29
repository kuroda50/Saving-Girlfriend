import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:saving_girlfriend/constants/characters.dart';
import 'package:saving_girlfriend/constants/color.dart';
import 'package:saving_girlfriend/models/message.dart';
import 'package:saving_girlfriend/models/transaction_state.dart';
import 'package:saving_girlfriend/providers/chat_history_provider.dart';
import 'package:saving_girlfriend/providers/current_girlfriend_provider.dart';
import 'package:saving_girlfriend/providers/setting_provider.dart';
import 'package:saving_girlfriend/providers/transaction_history_provider.dart';
import 'package:saving_girlfriend/providers/uuid_provider.dart';

class Category {
  final String id;
  final String name;

  Category({required this.id, required this.name});
}

class GirlfriendChatScreen extends ConsumerStatefulWidget {
  const GirlfriendChatScreen({super.key});

  @override
  ConsumerState<GirlfriendChatScreen> createState() =>
      GirlfriendChatScreenState();
}

class GirlfriendChatScreenState extends ConsumerState<GirlfriendChatScreen> {
  final List<Category> _categories = [
    Category(id: 'food', name: '食費'),
    Category(id: 'transport', name: '交通費'),
    Category(id: 'entertainment', name: '趣味・娯楽'),
    Category(id: 'social', name: '交際費'),
    Category(id: 'daily', name: '日用品'),
    Category(id: 'other', name: 'その他'),
  ];

  Category _selectedCategory = Category(id: 'food', name: '食費');
  String _amountText = '';
  bool _isGirlfriendResponding = false; // 彼女が返信中かどうかを示す状態

  final ScrollController _scrollController = ScrollController();

  String _formatCurrency(int value) {
    final s = value.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final pos = s.length - i;
      buffer.write(s[i]);
      if (pos > 1 && pos % 3 == 1) buffer.write(',');
    }
    return buffer.toString();
  }

  void _addMessage(MessageType type, String text) {
    final m = Message(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: type,
        text: text,
        time:
            ChatHistoryNotifier.nowText()); // ChatHistoryNotifier.nowText() を使用
    ref
        .read(chatHistoryNotifierProvider.notifier)
        .addMessage(m); // プロバイダー経由でメッセージを追加
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  // 仮のリアクションを配置
  List<String> _calcReactionLines(Category cat, int amt) {
    // 10 simple reaction rules (no emojis). The order matters.
    if (cat.id == 'food' && amt < 800) {
      return ['ごはんは安く済んだんだね。', '節約できてていいと思う。'];
    }
    if (cat.id == 'food' && amt >= 2000) {
      return ['ちょっと高めだね。', 'たまにはいいけど、次は気をつけよう。'];
    }
    if (cat.id == 'entertainment') {
      return ['趣味に使ったんだ。', '楽しめたならいいけど、使いすぎ注意ね。'];
    }
    if (cat.id == 'social') {
      return ['交際費か。', 'ちゃんと楽しめたなら問題ないよ。'];
    }
    if (amt < 300) {
      return ['控えめだね。', 'その調子でいこう。'];
    }
    if (amt > 3000) {
      return ['かなり使ったね。', '少しペースを落とそうか。'];
    }
    if (cat.id == 'transport') {
      return ['交通費だね。', 'どこに行ってたの？'];
    }
    if (cat.id == 'daily') {
      return ['日用品の出費か。', '必要なものなら仕方ないね。'];
    }
    if (cat.id == 'other') {
      return ['その他の出費か。', '何に使ったのか気になるよ。'];
    }
    // default
    return ['わかった。', 'ありがと。'];
  }

  Future<void> _girlfriendRespond(Category cat, int amt, int todaySpent) async {
    ref.read(chatHistoryNotifierProvider.notifier).addMessage(Message(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: MessageType.girlfriend,
        text: '…',
        time: ChatHistoryNotifier.nowText()));
    _scrollToBottom();

    final lines = _calcReactionLines(cat, amt);

    for (int i = 0; i < lines.length; i++) {
      // wait a bit (human-like)
      await Future.delayed(
          Duration(milliseconds: 700 + (200 * i) + (100 * (i % 3))));

      // replace the typing indicator with actual line
      final currentMessages = ref.read(chatHistoryNotifierProvider).value!;
      if (currentMessages.isNotEmpty &&
          currentMessages.last.type == MessageType.girlfriend &&
          currentMessages.last.text == '…') {
        ref.read(chatHistoryNotifierProvider.notifier).updateLastMessage(
            Message(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                type: MessageType.girlfriend,
                text: lines[i],
                time: ChatHistoryNotifier.nowText()));
      } else {
        ref.read(chatHistoryNotifierProvider.notifier).addMessage(Message(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            type: MessageType.girlfriend,
            text: lines[i],
            time: ChatHistoryNotifier.nowText()));
      }

      _scrollToBottom();

      // if more lines to come, insert typing indicator before next
      if (i < lines.length - 1) {
        ref.read(chatHistoryNotifierProvider.notifier).addMessage(Message(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            type: MessageType.girlfriend,
            text: '…',
            time: ChatHistoryNotifier.nowText()));
        _scrollToBottom();
      }
    }

    final dailyBudget = await ref
        .read(settingsProvider.future)
        .then((value) => value.dailyBudget);

    // summary after reactions
    await Future.delayed(const Duration(milliseconds: 800));
    if (todaySpent >= dailyBudget) {
      _addMessage(MessageType.girlfriend,
          '今日は${_formatCurrency(todaySpent)}円使ってる。予算オーバーだね。');
    } else {
      _addMessage(MessageType.girlfriend,
          '今日の残りは${_formatCurrency(dailyBudget - todaySpent)}円。節約がんばろう。');
    }
  }

  Future<void> _handleSubmit(int todaySpent) async {
    if (_amountText.isEmpty || _isGirlfriendResponding) {
      return; // 彼女が返信中の場合は処理しない
    }
    final amt = int.tryParse(_amountText);
    if (amt == null || amt <= 0) return;

    _addMessage(MessageType.user,
        '${_selectedCategory.name}: ${_formatCurrency(amt)}円');

    final newTransaction = TransactionState(
      id: ref.read(uuidProvider).v4(),
      type: 'expense',
      date: DateTime.now(),
      amount: amt,
      category: _selectedCategory.name,
    );
    setState(() {
      _amountText = '';
      _selectedCategory = _categories[0];
      _isGirlfriendResponding = true; // 彼女の返信開始
    });
    await ref
        .read(transactionsProvider.notifier)
        .addTransaction(newTransaction);

    await _girlfriendRespond(_selectedCategory, amt, todaySpent + amt);

    setState(() {
      _isGirlfriendResponding = false; // 彼女の返信終了
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildMessageTile(Message m) {
    final bool isUser = m.type == MessageType.user;
    final characterId = ref.watch(currentGirlfriendProvider);
    final character = characters.firstWhere(
      (c) => c.id == characterId.asData?.value,
      orElse: () => characters.first,
    );
    final characterImage = character.image;

    return Row(
      mainAxisAlignment:
          isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        if (!isUser)
          CircleAvatar(
            radius: 18,
            backgroundImage: AssetImage(characterImage),
          ),
        const SizedBox(width: 8),
        Flexible(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            margin: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              color: isUser ? AppColors.primary : AppColors.mainBackground,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(isUser ? 16 : 4),
                bottomRight: Radius.circular(isUser ? 4 : 16),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                m.text == '…'
                    ? const TypingIndicator()
                    : Text(m.text,
                        style: TextStyle(
                            color: isUser
                                ? AppColors.mainIcon
                                : AppColors.mainText,
                            fontSize: 14)),
                const SizedBox(height: 6),
                Text(m.time,
                    style: TextStyle(
                        color: isUser ? AppColors.subText : AppColors.subIcon,
                        fontSize: 10)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final dailyBudgetAsync = ref.watch(settingsProvider);
    final transactionsAsync = ref.watch(transactionsProvider);

    return dailyBudgetAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const Scaffold(
        body: Center(
          child: Text('設定の読み込み中にエラーが発生しました。',
              style: TextStyle(color: AppColors.error)),
        ),
      ),
      data: (data) {
        return transactionsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const Scaffold(
            body: Center(
              child: Text('取引履歴の読み込み中にエラーが発生しました。',
                  style: TextStyle(color: AppColors.error)),
            ),
          ),
          data: (transactions) {
            final today = DateTime.now();
            final todaySpent = transactions
                .where((tx) =>
                    tx.date.year == today.year &&
                    tx.date.month == today.month &&
                    tx.date.day == today.day)
                .fold<int>(0, (sum, tx) => sum + tx.amount);

            return Scaffold(
              backgroundColor: AppColors.forthBackground,
              appBar: PreferredSize(
                preferredSize: const Size.fromHeight(80.0), // 高さを増やす
                child: AppBar(
                  elevation: 2,
                  backgroundColor: AppColors.secondary,
                  automaticallyImplyLeading: false, // 戻るボタンを非表示
                  flexibleSpace: SafeArea(
                    child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20.0, vertical: 10.0),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text("使った金額",
                                  style: TextStyle(
                                      fontSize: 12, color: AppColors.subText)),
                              const SizedBox(height: 4),
                              Text(
                                  '使った金額 ￥${_formatCurrency(todaySpent)}/${_formatCurrency(data.dailyBudget)}',
                                  style: TextStyle(
                                      fontSize: 19,
                                      fontWeight: FontWeight.bold,
                                      color: todaySpent > data.dailyBudget
                                          ? AppColors.error
                                          : AppColors.mainIcon)),
                            ],
                          ),
                        )),
                  ),
                ),
              ),
              body: SafeArea(
                child: Column(
                  children: [
                    Expanded(
                      child: ref.watch(chatHistoryNotifierProvider).when(
                            loading: () => const Center(
                                child: CircularProgressIndicator()),
                            error: (err, stack) =>
                                Center(child: Text('Error: $err')),
                            data: (messages) {
                              return ListView.builder(
                                controller: _scrollController,
                                reverse: true,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                itemCount: messages.length,
                                itemBuilder: (context, index) {
                                  final m =
                                      messages[messages.length - 1 - index];
                                  return _buildMessageTile(m);
                                },
                              );
                            },
                          ),
                    ),
                    // input area (compact)
                    Container(
                      decoration: BoxDecoration(
                          color: AppColors.mainBackground,
                          border:
                              Border(top: BorderSide(color: AppColors.border))),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            height: 36,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: _categories.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(width: 8),
                              itemBuilder: (context, i) {
                                final c = _categories[i];
                                final selected = c.id == _selectedCategory.id;
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedCategory = c;
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: selected
                                          ? AppColors.primary
                                          : AppColors.secondary
                                              .withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(18),
                                      border: Border.all(
                                          color: selected
                                              ? Colors.transparent
                                              : AppColors.secondary
                                                  .withOpacity(0.5)),
                                    ),
                                    child: Center(
                                      child: Text(c.name,
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: selected
                                                  ? AppColors.mainIcon
                                                  : AppColors.primary,
                                              fontWeight: FontWeight.w600)),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    hintText: '金額を入力',
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 12),
                                    filled: true,
                                    fillColor:
                                        AppColors.secondary.withOpacity(0.3),
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                            color: AppColors.secondary
                                                .withOpacity(0.5))),
                                  ),
                                  onSubmitted: (String _) {
                                    _handleSubmit(todaySpent);
                                  },
                                  onChanged: (v) {
                                    final filtered =
                                        v.replaceAll(RegExp('[^0-9]'), '');
                                    setState(() {
                                      _amountText = filtered.length > 7
                                          ? filtered.substring(0, 7)
                                          : filtered;
                                    });
                                  },
                                  controller: TextEditingController(
                                      text: _amountText)
                                    ..selection = TextSelection.fromPosition(
                                        TextPosition(
                                            offset: _amountText.length)),
                                ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: (_amountText.isEmpty ||
                                        int.tryParse(_amountText) == null ||
                                        _isGirlfriendResponding)
                                    ? null // ボタンを非活性化
                                    : () => _handleSubmit(todaySpent),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.all(12),
                                  backgroundColor: AppColors.primary,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                ),
                                child: const Icon(Icons.send,
                                    color: AppColors.mainIcon),
                              )
                            ],
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class TypingIndicator extends StatefulWidget {
  const TypingIndicator({super.key});

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat();
    _animation = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(3, (index) {
          return AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              final double opacity = (index / 3.0) <= _animation.value
                  ? _animation.value - (index / 3.0)
                  : 0.0;
              return Opacity(
                opacity: opacity.clamp(0.0, 1.0),
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.subIcon,
                    shape: BoxShape.circle,
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
