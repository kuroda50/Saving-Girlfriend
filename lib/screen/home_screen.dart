import 'package:flutter/material.dart';
import 'package:saving_girlfriend/constants/assets.dart';
import '../constants/color.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var girlfriendText = 'いつもありがとうございます先輩！\n大好きです…';

  Future<void> aiChat(message) async {
    //デプロイするときは、URLを本番環境に変える
    final url = Uri.parse('http://172.20.21.213:5000/girlfriend_reaction');
    //デプロイするときは、URLを本番環境に変える
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'user_input': message}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('AIリアクション: ${data['reaction']} / 感情: ${data['emotion']}');
        setState(() {
          girlfriendText = data['reaction'];
          // ここに表情差分
        });
      } else {
        print('APIエラー: ${response.body}');
      }
    } catch (error) {
      print('通信エラー: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
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
                        onTap: () => _showTransactionModal(context),
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
                            aiChat(message);
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
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
void _showTransactionModal(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true, // キーボード表示時にUIが隠れないようにする
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (BuildContext context) {
      // キーボードの表示に合わせてpaddingを調整
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: const TransactionInputModal(),
      );
    },
  );
}

// 収支入力モーダルのUIを定義するStatefulWidget
class TransactionInputModal extends StatefulWidget {
  const TransactionInputModal({super.key});

  @override
  State<TransactionInputModal> createState() => _TransactionInputModalState();
}

class _TransactionInputModalState extends State<TransactionInputModal> {
  // 状態管理用の変数
  // 支出or収入、金額、日付、カテゴリ、メモがあっても良いかも
  bool _isExpense = true; // true: 支出, false: 収入
  final _amountController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  // ダミーのカテゴリリスト（実際のアプリでは外部から取得・管理してください）
  final List<String> _expenseCategories = ['食費', '交通費', '趣味', '交際費', 'その他'];
  final List<String> _incomeCategories = ['給与', 'お小遣い', '副業', 'その他'];

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
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
  void _saveTransaction() {
    final amount = int.tryParse(_amountController.text);

    // バリデーション
    if (amount == null || amount <= 0) {
      // エラーメッセージを表示するなどの処理
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('金額とカテゴリを正しく入力してください。')),
      );
      return;
    }

    // ここで入力データをデータベースに保存したり、APIに送信したりする
    print('【保存データ】');
    print('種類: ${_isExpense ? "支出" : "収入"}');
    print('金額: $amount');
    print('日付: $_selectedDate');

    // モーダルを閉じる
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    // 支出/収入に応じて表示するカテゴリリストを切り替え
    final currentCategories = _isExpense ? _expenseCategories : _incomeCategories;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
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
                });
              },
              borderRadius: BorderRadius.circular(8),
              selectedColor: Colors.white,
              fillColor: _isExpense ? AppColors.primary : Colors.blueAccent,
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
          
          // 日付選択
          InkWell(
            onTap: () => _selectDate(context),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today_outlined, color: Colors.grey),
                  const SizedBox(width: 12),
                  Text(
                    '日付: ${MaterialLocalizations.of(context).formatShortDate(_selectedDate)}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const Spacer(),
                  const Icon(Icons.edit_outlined, color: Colors.grey, size: 20),
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
              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            child: const Text('保存する'),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}