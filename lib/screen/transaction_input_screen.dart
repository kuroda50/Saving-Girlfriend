import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:saving_girlfriend/constants/color.dart';
import '../providers/home_screen_provider.dart';
import '../providers/transaction_history_provider.dart';
import 'package:flutter/services.dart';

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
  DateTime _selectedDate = DateTime.now();
  String? _selectedCategory;
  final List<String> _expenseCategories = [
    '食費',
    '交通費',
    '趣味・娯楽',
    '交際費',
    '日用品',
    'その他'
  ];
  final List<String> _incomeCategories = ['給与', '副業', '臨時収入', 'その他'];

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _saveTransaction() async {
    final amount = int.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('金額を正しく入力してください。')));
      return;
    }
    if (_selectedCategory == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('カテゴリを選択してください。')));
      return;
    }

    // ここを修正する
    final newTransaction = {
      "type": _isExpense ? "expense" : "income",
      "date": _selectedDate.toIso8601String(),
      "amount": amount,
      "category": _selectedCategory!,
    };

    try {
      await ref
          .read(transactionHistoryProvider.notifier)
          .addTransaction(newTransaction);

      ref
          .read(homeScreenProvider.notifier)
          .aiChat(_selectedCategory!, _isExpense ? -amount : amount);

      // フォームをリセット
      _amountController.clear();
      setState(() {
        _isExpense = true;
        _selectedCategory = null;
        _selectedDate = DateTime.now();
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
                    _selectedCategory = null;
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
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: '金額',
                prefixIcon: Icon(Icons.currency_yen),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                final num = int.tryParse(value);
                if (num != null && num > 99999) {
                  _amountController.text = '99999';
                  _amountController.selection = TextSelection.fromPosition(
                    TextPosition(offset: _amountController.text.length),
                  );
                }
              },
            ),
            const SizedBox(height: 16),
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
                        style: const TextStyle(fontSize: 16)),
                    const Spacer(),
                    const Icon(Icons.edit_outlined,
                        color: AppColors.subIcon, size: 20),
                  ],
                ),
              ),
            ),
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
