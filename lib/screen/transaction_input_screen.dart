// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Project imports:
import 'package:saving_girlfriend/constants/color.dart';
import 'package:saving_girlfriend/models/transaction_state.dart';
import 'package:saving_girlfriend/providers/uuid_provider.dart';
import '../providers/transaction_history_provider.dart';

class TransactionInputScreen extends ConsumerStatefulWidget {
  const TransactionInputScreen({super.key});

  @override
  ConsumerState<TransactionInputScreen> createState() =>
      _TransactionInputScreenState();
}

class _TransactionInputScreenState
    extends ConsumerState<TransactionInputScreen> {
  bool _isExpense = true;
  final _amountController = TextEditingController();
  final List<String> _expenseCategories = [
    '食費',
    '交通費',
    '趣味・娯楽',
    '交際費',
    '日用品',
    'その他'
  ];
  final List<String> _incomeCategories = ['給与', '副業', '臨時収入', 'その他'];
  late String _selectedCategory = _expenseCategories[0];

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _saveTransaction() async {
    final amount = int.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('金額を正しく入力してください。')));
      return;
    }

    final newTransaction = TransactionState(
        id: ref.read(uuidProvider).v4(),
        type: _isExpense ? "expense" : "income",
        date: DateTime.now(),
        amount: amount,
        category: _selectedCategory);

    try {
      await ref
          .read(transactionsProvider.notifier)
          .addTransaction(newTransaction);

      // フォームをリセット
      _amountController.clear();
      setState(() {
        _isExpense = true;
        _selectedCategory = _expenseCategories[0];
      });
    } catch (error) {
      print("エラー: $error");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'データの保存に失敗しました。もう一度お試しください。',
            style: TextStyle(
              color: AppColors.error, // ここで色を指定します
            ),
          ),
          backgroundColor: AppColors.errorBackground,
        ),
      );
    }
    if (!mounted) return;
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final currentCategories =
        _isExpense ? _expenseCategories : _incomeCategories;
    return Scaffold(
      appBar: AppBar(
        title: const Text('収支の入力'),
        backgroundColor: AppColors.secondary,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: ToggleButtons(
                isSelected: [_isExpense, !_isExpense],
                onPressed: (index) {
                  setState(() {
                    _isExpense = index == 0;
                    if (_isExpense) {
                      _selectedCategory = _expenseCategories[0];
                    } else {
                      _selectedCategory = _incomeCategories[0];
                    }
                  });
                },
                borderRadius: BorderRadius.circular(8),
                selectedColor: AppColors.subText,
                fillColor: AppColors.primary,
                children: const [
                  Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      child: Text('支出')),
                  Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      child: Text('収入')),
                ],
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(7),
              ],
              decoration: const InputDecoration(
                labelText: '金額',
                prefixIcon: Icon(Icons.currency_yen),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _selectedCategory,
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
                  if (newValue != null) {
                    _selectedCategory = newValue;
                  }
                });
              },
            ),
            const SizedBox(height: 10),
            const Divider(),
            const SizedBox(height: 10),
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
      ),
    );
  }
}
