import 'package:saving_girlfriend/widgets/transaction_modal.dart'; // ★これを追加
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:saving_girlfriend/constants/assets.dart';
import '../constants/color.dart';
import 'package:go_router/go_router.dart';
import '../services/local_storage_service.dart';
import '../providers/home_screen_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ref.watchでProviderの状態を監視
    final homeState = ref.watch(homeScreenProvider);
    final girlfriendText = homeState.girlfriendText;

    // aiChatメソッドはNotifier経由で呼び出す
    void handleSendMessage(String message, int amount) {
      ref.read(homeScreenProvider.notifier).aiChat(message, amount);
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.secondary,
      ),
      body: Column(

        children: [
          Expanded(
            child: Stack(
              children: [
                // 1. 背景画像 (教室)
                Positioned.fill(
                  child: Image.asset(
                    AppAssets.backgroundClassroom, // 教室の画像のパス
                    fit: BoxFit.cover,
                    // エラー表示を避けるためのエラーハンドリング
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: AppColors.errorBackground,
                        child: const Center(
                          child: Text(
                            '背景画像をロードできませんでした。\nパス: ${AppAssets.backgroundClassroom}',
                            textAlign: TextAlign.center,
                            style:
                                TextStyle(color: AppColors.error, fontSize: 16),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // 2. キャラクター画像 (画面下部中央に調整)
                Positioned(
                  bottom: 0, // 画面の最下部に配置
                  left: 0,
                  right: 0,
                  child: Align(
                    alignment: Alignment.bottomCenter, // 水平方向は中央、垂直方向は下揃え
                    child: Image.asset(
                      AppAssets.characterSuzunari, // キャラクターの画像のパス
                      fit: BoxFit.contain,
                      // 画面の高さの約75%に設定し、画面に収まるように調整
                      height: MediaQuery.of(context).size.height * 0.5,
                      // エラー表示を避けるためのエラーハンドリング
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: AppColors.errorBackground, // 背景は透明
                          child: const Center(
                            child: Text(
                              'キャラクター画像をロードできませんでした。\nパス: ${AppAssets.characterSuzunari}',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: AppColors.error, fontSize: 16),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                // 3. 上部の情報バー
                Positioned(
                  top: 20, // 適宜調整
                  left: 20,
                  right: 20,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.mainBackground.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.settings,
                              color: AppColors.subIcon),
                          onPressed: () {
                            context.push('/home/settings');
                          },
                        ),
                        const Text(
                          '5回目継続中!!',
                          style: TextStyle(
                              color: AppColors.mainText, fontSize: 12),
                        ),
                        const Expanded(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8.0),
                            child: LinearProgressIndicator(
                              value: 0.5, // プログレスの現在値（例: 0.5で50%）
                              backgroundColor: AppColors.nonActive,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.primary),
                            ),
                          ),
                        ),
                        const Icon(Icons.favorite,
                            color: AppColors.primary, size: 18),
                        const Text('50',
                            style: TextStyle(
                                color: AppColors.mainText, fontSize: 14)),
                        const Text('/100',
                            style: TextStyle(
                                color: AppColors.mainText, fontSize: 12)),
                      ],
                    ),
                  ),
                ),
                // 4. 吹き出し
                Positioned(
                  // キャラクターの頭の位置に合わせて調整
                  top: MediaQuery.of(context).size.height * 0.15,
                  left: MediaQuery.of(context).size.width * 0.2,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    width: MediaQuery.of(context).size.width * 0.7,
                    decoration: BoxDecoration(
                      color: AppColors.mainBackground,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: const [
                        BoxShadow(
                          color: AppColors.shadow,
                          blurRadius: 5,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      girlfriendText,
                      style: const TextStyle(
                          fontSize: 14, color: AppColors.mainText),
                    ),
                  ),
                ),
                // 5. アイコンとチャット入力欄
                Positioned(
                  bottom:
                      MediaQuery.of(context).size.height * 0.02, // 画面下部からの位置を調整
                  right: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () => showTransactionModal(
                              context,
                              onSave: (newTributeData) {
                                // ★ AIへの通知（handleSendMessage）だけを呼び出す
                                final category = newTributeData['category'] as String;
                                final amount = newTributeData['amount'] as int;
                                handleSendMessage(category, amount);
                              },
                            ),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.8),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.currency_yen,
                              color: AppColors.mainIcon, size: 45), // 円マークのアイコン
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      SizedBox(
                        height: 70,
                        width: MediaQuery.of(context).size.width * 0.9,
                        child: ChatInputWidget(
                          onSendMessage: (message) {
                            handleSendMessage(message, 0);
                            print('送信されたメッセージ: $message');
                          },
                          hintText: '彼女と会話しましょう！',
                          backgroundColor: AppColors.secondary,
                          sendButtonColor: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ChatInputWidget extends StatefulWidget {
  final Function(String) onSendMessage;
  final String? hintText;
  final Color? backgroundColor;
  final Color? sendButtonColor;
  final IconData? sendIcon;
  final int maxLines;
  final bool enabled;

  const ChatInputWidget({
    Key? key,
    required this.onSendMessage,
    this.hintText = 'メッセージを入力...',
    this.backgroundColor,
    this.sendButtonColor,
    this.sendIcon = Icons.send,
    this.maxLines = 5,
    this.enabled = true,
  }) : super(key: key);

  @override
  State<ChatInputWidget> createState() => _ChatInputWidgetState();
}

class _ChatInputWidgetState extends State<ChatInputWidget> {
  final TextEditingController _textController = TextEditingController();
  bool _isComposing = false;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _handleSubmitted(String text) {
    if (text.trim().isEmpty) return;

    widget.onSendMessage(text.trim());
    _textController.clear();
    setState(() {
      _isComposing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        color: widget.backgroundColor ?? theme.colorScheme.surface,
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 4,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: theme.colorScheme.outline.withOpacity(0.3),
                    ),
                    borderRadius: BorderRadius.circular(24.0),
                    color: theme.colorScheme.background,
                  ),
                  child: TextField(
                    controller: _textController,
                    maxLines: null,
                    minLines: 1,
                    textInputAction: TextInputAction.newline,
                    decoration: InputDecoration(
                      hintText: widget.hintText,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 12.0,
                      ),
                    ),
                    onChanged: (text) {
                      setState(() {
                        _isComposing = text.trim().isNotEmpty;
                      });
                    },
                    onSubmitted: _handleSubmitted,
                  ),
                ),
              ),
              const SizedBox(width: 8.0),
              Container(
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: _isComposing
                      ? () => _handleSubmitted(_textController.text)
                      : null,
                  icon: Icon(
                    widget.sendIcon,
                    color: AppColors.mainIcon,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 支出、収入を入力するモーダルウィンドウを表示する関数
void _showTransactionModal(
  BuildContext context, {
  required Function(Map<String, dynamic>) onSave,
  Map<String, dynamic>? initialTribute,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (BuildContext context) {
      return Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: TransactionInputModal(
          onSave: onSave,
          initialTribute: initialTribute,
        ),
      );
    },
  );
}

// 収支入力モーダルのUIを定義するStatefulWidget
class TransactionInputModal extends StatefulWidget {
  final Function(Map<String, dynamic>) onSave; // ★引数の型を変更
  final Map<String, dynamic>? initialTribute;   // ★追加

  const TransactionInputModal({
    required this.onSave,
    this.initialTribute, // ★追加
    super.key
  });

  @override
  State<TransactionInputModal> createState() => _TransactionInputModalState();
}

class _TransactionInputModalState extends State<TransactionInputModal> {
  bool _isExpense = true; // true: 支出, false: 収入
  final _amountController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  final LocalStorageService _localStorageService = LocalStorageService();

  String? _selectedCategory;
  // 支出カテゴリのリスト
  final List<String> _expenseCategories = [
    '食費',
    '交通費',
    '趣味・娯楽',
    '交際費',
    '日用品',
    'その他'
  ];
  // 収入カテゴリのリスト
  final List<String> _incomeCategories = ['給与', '副業', '臨時収入', 'その他'];

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

   // ★★★↓ このinitStateメソッドをまるごと追加 ↓★★★
  @override
  void initState() {
    super.initState();
    // もし編集データが渡されたら、入力欄にその値を設定する
    if (widget.initialTribute != null) {
      final tribute = widget.initialTribute!;
      final amount = tribute['amount'] as int;

      _isExpense = amount < 0;
      _amountController.text = amount.abs().toString();
      _selectedDate = DateTime.parse(tribute['date']);
      _selectedCategory = tribute['category'];
    }
  }

  // 日付選択ダイアログを表示する関数
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)), // 1年先まで選択可能
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // 保存ボタンが押されたときの処理
    // ★★★↓ _saveTransactionメソッドをこの内容に置き換え ↓★★★
  void _saveTransaction() {
  final amount = int.tryParse(_amountController.text);

  // バリデーション
  if (amount == null || amount <= 0 || _selectedCategory == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('金額とカテゴリを正しく入力してください。')),
    );
    return;
  }

  // ★ 親に渡すためのデータを作成する
  Map<String, dynamic> tributeData = {
    // もし編集モードなら、元のIDを維持。新規なら、新しいIDを作成。
    'id': widget.initialTribute?['id'] ?? 'tribute_${DateTime.now().millisecondsSinceEpoch}',
    'character': "A", // この値は既存のロジックに合わせています
    'date': _selectedDate.toIso8601String(),
    'amount': _isExpense ? -amount : amount,
    'category': _selectedCategory!
  };

  // ★ コールバックでMap全体を渡し、後の処理はすべて親に任せる
  widget.onSave(tributeData);
  Navigator.of(context).pop();
}

  @override
  Widget build(BuildContext context) {
    final currentCategories =
        _isExpense ? _expenseCategories : _incomeCategories;
    return SingleChildScrollView(
      // キーボード表示時にUIが隠れないようにPaddingを調整
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 24,
          right: 24,
          top: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '収支の入力',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 24),

          // 支出/収入の切り替え
          Center(
            child: ToggleButtons(
              isSelected: [_isExpense, !_isExpense],
              onPressed: (index) {
                setState(() {
                  _isExpense = index == 0;
                  _selectedCategory = null;
                });
              },
              borderRadius: BorderRadius.circular(8),
              selectedColor: AppColors.subText,
              fillColor: _isExpense ? AppColors.primary : AppColors.secondary,
              children: const [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Text('支出'),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Text('収入'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 金額入力
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: '金額',
              prefixIcon: Icon(Icons.currency_yen),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),

          // カテゴリ選択のドロップダウン
          DropdownButtonFormField<String>(
            value: _selectedCategory,
            hint: const Text('カテゴリを選択'),
            decoration: const InputDecoration(
              labelText: 'カテゴリ',
              prefixIcon: Icon(Icons.category_outlined),
              border: OutlineInputBorder(),
            ),
            items: currentCategories.map((String category) {
              return DropdownMenuItem<String>(
                value: category,
                child: Text(category),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _selectedCategory = newValue;
              });
            },
          ),
          const SizedBox(height: 24),

          // 日付選択
          InkWell(
            onTap: () => _selectDate(context),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today_outlined,
                      color: AppColors.subIcon),
                  const SizedBox(width: 12),
                  Text(
                    '日付: ${MaterialLocalizations.of(context).formatShortDate(_selectedDate)}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const Spacer(),
                  const Icon(Icons.edit_outlined,
                      color: AppColors.subIcon, size: 20),
                ],
              ),
            ),
          ),
          const Divider(),
          const SizedBox(height: 10),

          // 保存ボタン
          ElevatedButton(
            onPressed: _saveTransaction,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.mainIcon,
              padding: const EdgeInsets.symmetric(vertical: 16),
              textStyle:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            child: const Text('保存する'),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
