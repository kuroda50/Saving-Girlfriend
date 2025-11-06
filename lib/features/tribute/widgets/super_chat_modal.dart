// Flutter imports:
import 'package:flutter/material.dart';

import 'package:saving_girlfriend/features/live_stream/models/comment_model.dart'; // ★ 色情報を取得するためにインポート

// ★ この関数はそのまま残しますが、中身は新しいモーダルを呼び出すようにします
void showSuperChatModal(BuildContext context,
    {required Function(int, String) onSend}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true, // キーボード表示時にモーダルが隠れないようにする
    backgroundColor: Colors.transparent, // 背景を透明にして、自前のContainerで角丸を表現
    builder: (context) {
      return SuperChatInputView(onSend: onSend);
    },
  );
}

// ★ 金額のプリセットを定義
class SuperChatTier {
  final int amount;
  final Color color;
  SuperChatTier({required this.amount, required this.color});
}

// ★ 新しいモーダルの本体
class SuperChatInputView extends StatefulWidget {
  final Function(int, String) onSend;
  const SuperChatInputView({super.key, required this.onSend});

  @override
  State<SuperChatInputView> createState() => _SuperChatInputViewState();
}

class _SuperChatInputViewState extends State<SuperChatInputView> {
  // 金額プリセットのリスト
  final List<SuperChatTier> _tiers = [
    SuperChatTier(amount: 200, color: Colors.blue.shade600),
    SuperChatTier(amount: 500, color: Colors.cyan.shade400),
    SuperChatTier(amount: 1000, color: Colors.yellow.shade700),
    SuperChatTier(amount: 5000, color: Colors.orange.shade700),
    SuperChatTier(amount: 10000, color: Colors.red.shade700),
  ];

  late final TextEditingController _commentController;
  int _selectedAmount = 0;
  Color _currentColor = Colors.grey.shade800;
  Color _currentTextColor = Colors.white;

  @override
  void initState() {
    super.initState();
    _commentController = TextEditingController();
    // 最初のプリセットをデフォルトとして選択
    _updateSelection(200);
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  // ★★★↓ 送信処理をこのメソッドにまとめる ↓★★★
  void _sendSuperChat() {
    // 完了したらコールバックを呼び出してモーダルを閉じる
    widget.onSend(_selectedAmount, _commentController.text);
    Navigator.pop(context);
  }

  // 金額が選択されたときに、色やテキストの状態を更新するメソッド
  void _updateSelection(int amount) {
    setState(() {
      _selectedAmount = amount;
      // comment_model.dart にあるSuperChatクラスのロジックを再利用して色を取得
      final config =
          SuperChat(amount: amount, userName: '', iconAsset: '', text: '')
              .colorConfig;
      _currentColor = config.backgroundColor;
      _currentTextColor = config.textColor;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      // キーボードの分だけUIを上に持ち上げる
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF282828), // YouTubeのダークモード風の背景色
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ★ 金額と色が表示されるヘッダー
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: _currentColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('スーパーチャットを送信',
                      style: TextStyle(
                          color: _currentTextColor,
                          fontWeight: FontWeight.bold)),
                  Text('¥$_selectedAmount',
                      style: TextStyle(
                          color: _currentTextColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 18)),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ★ 金額プリセットの横スクロールリスト
            SizedBox(
              height: 40,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: _tiers.length,
                separatorBuilder: (context, index) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final tier = _tiers[index];
                  final isSelected = _selectedAmount == tier.amount;
                  return GestureDetector(
                    onTap: () => _updateSelection(tier.amount),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: tier.color,
                        borderRadius: BorderRadius.circular(20),
                        border: isSelected
                            ? Border.all(color: Colors.white, width: 2.5)
                            : null,
                      ),
                      alignment: Alignment.center,
                      child: Text('¥${tier.amount}',
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // ★ コメント入力欄
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _commentController,
                maxLength: 150,
                style: const TextStyle(color: Colors.white),
                // ★★★↓ この行を追加してください ↓★★★
                onSubmitted: (String text) {
                  // 送信ボタンが押された時と同じ処理を呼び出す
                  _sendSuperChat();
                },
                decoration: InputDecoration(
                  hintText: 'メッセージを入力',
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  filled: true,
                  fillColor: Colors.black.withOpacity(0.2),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none),
                  counterStyle: const TextStyle(color: Colors.white70),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // ★ 送信ボタン
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24)),
                  ),
                  onPressed: () {
                    // 完了したらコールバックを呼び出してモーダルを閉じる
                    widget.onSend(_selectedAmount, _commentController.text);
                    Navigator.pop(context);
                  },
                  child: const Text('送信',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
