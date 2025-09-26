import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:saving_girlfriend/constants/color.dart';

// モーダルを呼び出すためのグローバル関数
void showTransactionModal(
  BuildContext context, {
  required Function(Map<String, dynamic>) onSave,
  Map<String, dynamic>? initialTransaction,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (BuildContext context) {
      return Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: TransactionInputModal(
          onSave: onSave,
          initialTransaction: initialTransaction,
        ),
      );
    },
  );
}

// 収支入力モーダルのUIを定義するStatefulWidget
class TransactionInputModal extends StatefulWidget {
  final Function(Map<String, dynamic>) onSave;
  final Map<String, dynamic>? initialTransaction;

  const TransactionInputModal(
      {required this.onSave, this.initialTransaction, super.key});

  @override
  State<TransactionInputModal> createState() => _TransactionInputModalState();
}

class _TransactionInputModalState extends State<TransactionInputModal> {
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
  void initState() {
    super.initState();
    if (widget.initialTransaction != null) {
      final transaction = widget.initialTransaction!;
      final amount = transaction['amount'] as int;

      _isExpense = amount < 0;
      _amountController.text = amount.abs().toString();
      _selectedDate = DateTime.parse(transaction['date']);
      _selectedCategory = transaction['category'];
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _saveTransaction() {
    final amount = int.tryParse(_amountController.text);
    if (amount == null || amount <= 0 || _selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('金額とカテゴリを正しく入力してください。')),
      );
      return;
    }
    Map<String, dynamic> transactionData = {
      'id': widget.initialTransaction?['id'] ??
          'transaction_${DateTime.now().millisecondsSinceEpoch}',
      'date': _selectedDate.toIso8601String(),
      'amount': _isExpense ? -amount : amount,
      'category': _selectedCategory!
    };
    widget.onSave(transactionData);
    Navigator.of(context).pop();
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

  @override
  Widget build(BuildContext context) {
    final currentCategories =
        _isExpense ? _expenseCategories : _incomeCategories;
    return SingleChildScrollView(
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
            widget.initialTransaction == null ? '収支の入力' : '履歴の編集',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 24),
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
                    '日付: ${DateFormat('yyyy-MM-dd').format(_selectedDate)}',
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
