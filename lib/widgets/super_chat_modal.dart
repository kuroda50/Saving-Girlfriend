import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:saving_girlfriend/constants/color.dart';

// モーダルを呼び出すためのグローバル関数
void showSuperChatModal(
  BuildContext context, {
  required Function(int amount, String comment) onSend,
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
        child: SuperChatInputModal(onSend: onSend),
      );
    },
  );
}

// スパチャ入力モーダルのUI
class SuperChatInputModal extends StatefulWidget {
  final Function(int amount, String comment) onSend;
  const SuperChatInputModal({required this.onSend, super.key});

  @override
  State<SuperChatInputModal> createState() => _SuperChatInputModalState();
}

class _SuperChatInputModalState extends State<SuperChatInputModal> {
  final _amountController = TextEditingController();
  final _commentController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  void _handleSend() {
    final amount = int.tryParse(_amountController.text);
    final comment = _commentController.text;

    if (amount == null || amount <= 0) {
      // 金額が未入力の場合は何もしない
      return;
    }
    widget.onSend(amount, comment);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('スーパーチャットを送信', textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 24),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              labelText: '金額 (クレジット)',
              prefixIcon: Icon(Icons.monetization_on),
              border: OutlineInputBorder(),
            ),
            onSubmitted: (_) => _handleSend(), // ←追加
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _commentController,
            decoration: const InputDecoration(
              labelText: 'コメント (任意)',
              prefixIcon: Icon(Icons.comment),
              border: OutlineInputBorder(),
            ),
           onSubmitted: (_) => _handleSend(), // ←追加
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _handleSend,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('送信する'),
          ),
        ],
      ),
    );
  }
}