// lib/features/transaction/widgets/girlfriend_edit_modal.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // inputFormatters のため
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:saving_girlfriend/features/transaction/models/transaction_category.dart';
import 'package:saving_girlfriend/features/transaction/models/transaction_state.dart';

// TODO: カテゴリリストは本来 Provider 経由で取得してください。
// ここでは仮の「支出用」カテゴリリストを定義します。
final List<TransactionCategory> _expenseCategories = [
  TransactionCategory(id: '1', name: '食費'),
  TransactionCategory(id: '2', name: '交通費'),
  TransactionCategory(id: '3', name: '趣味'),
  TransactionCategory(id: '4', name: '交際費'),
  TransactionCategory(id: '5', name: '日用品'),
  TransactionCategory(id: '6', name: 'その他'),
];

class GirlfriendEditModal extends ConsumerStatefulWidget {
  const GirlfriendEditModal({super.key, required this.transaction});

  final TransactionState transaction;

  @override
  ConsumerState<GirlfriendEditModal> createState() =>
      _GirlfriendEditModalState();
}

class _GirlfriendEditModalState extends ConsumerState<GirlfriendEditModal> {
  late final TextEditingController _amountController;
  late String _selectedCategory;

  @override
  void initState() {
    super.initState();
    final tx = widget.transaction;
    // .toInt() して小数点を切り捨ててから文字列にする
    _amountController =
        TextEditingController(text: tx.amount.toInt().toString());
    _selectedCategory = tx.category;
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  // ▼▼▼ 【ここを修正】 int型で処理する ▼▼▼
  // 「OK！」ボタンが押されたときの処理
  void _onSubmit() {
    // 1. テキストを int に変換してみる
    final parsedAmount = int.tryParse(_amountController.text);

    // 2. デフォルト（無効な入力の場合）は、元の金額を使用する (amount は int)
    int finalAmount = widget.transaction.amount;

    // 3. もしパースに成功し、かつ0より大きい数値だったら
    if (parsedAmount != null && parsedAmount > 0) {
      finalAmount = parsedAmount; // 新しい金額を採用する
    }
    // (それ以外の場合、finalAmount は元の金額のまま)

    // 4. 編集後のデータを作成
    final updatedTransaction = widget.transaction.copyWith(
      amount: finalAmount, // 決定した int 型の金額
      category: _selectedCategory,
    );

    // 5. データを返しながらモーダルを閉じる
    Navigator.of(context).pop(updatedTransaction);
  }
  // ▲▲▲ -------------------------------- ▲▲▲

  // --- 共通のデコレーション ---
  InputDecoration _modalInputDecoration({
    required String labelText,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: labelText,
      labelStyle: const TextStyle(
        fontFamily: 'Klee One',
        color: Color(0xFFFF69B4),
      ),
      prefixIcon: Icon(icon, color: const Color(0xFFFFB6C1)),
      filled: true,
      fillColor: Colors.white.withOpacity(0.7),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFFFE4E1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFFF69B4), width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFFFE4E1)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFF9F0), Color(0xFFFFF0F5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFFFB6C1), width: 2),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF69B4).withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- 彼女風のタイトル ---
              const Text(
                'これ、直すの？',
                style: TextStyle(
                  fontFamily: 'Klee One',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFF1493),
                ),
              ),
              const SizedBox(height: 20),

              // --- 金額入力 ---
              TextField(
                controller: _amountController,
                // ▼▼▼ 【ここを修正】 小数点なしのキーボードに変更 ▼▼▼
                keyboardType: TextInputType.number,
                // ▲▲▲ --------------------------------------- ▲▲▲
                textInputAction: TextInputAction.done,
                onEditingComplete: _onSubmit, // エンターキーで送信

                // ▼▼▼ 【ここを修正】 数字(digits)のみ許可 ▼▼▼
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                // ▲▲▲ ----------------------------------- ▲▲▲

                style: const TextStyle(
                  fontFamily: 'Klee One',
                  fontSize: 18,
                  color: Color(0xFF333333),
                ),
                decoration: _modalInputDecoration(
                  labelText: '金額',
                  icon: Icons.paid,
                ),
              ),

              const SizedBox(height: 12),

              // --- カテゴリ選択 ---
              DropdownButtonFormField<String>(
                initialValue:
                    _expenseCategories.any((c) => c.name == _selectedCategory)
                        ? _selectedCategory
                        : _expenseCategories.first.name,
                items: _expenseCategories.map((category) {
                  return DropdownMenuItem<String>(
                    value: category.name,
                    child: Text(
                      category.name,
                      style: const TextStyle(
                        fontFamily: 'Klee One',
                        fontSize: 16,
                        color: Color(0xFF333333),
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedCategory = newValue;
                    });
                  }
                },
                decoration: _modalInputDecoration(
                  labelText: 'カテゴリ',
                  icon: Icons.category,
                ),
                dropdownColor: const Color(0xFFFFF9F0),
              ),

              const SizedBox(height: 24),

              // --- ボタン ---
              Row(
                children: [
                  // キャンセルボタン
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text(
                      'やめる',
                      style: TextStyle(
                        fontFamily: 'Klee One',
                        color: Color(0xFF999999),
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const Spacer(),
                  // OKボタン
                  ElevatedButton(
                    onPressed: _onSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF69B4),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      elevation: 4,
                    ),
                    child: const Text(
                      'OK！',
                      style: TextStyle(
                        fontFamily: 'Klee One',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
