import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:saving_girlfriend/constants/color.dart';
import 'package:saving_girlfriend/models/transaction_state.dart';
import 'package:saving_girlfriend/providers/uuid_provider.dart';

// モーダルを呼び出すためのグローバル関数
void showTransactionModal(
  BuildContext context, {
  required Function(TransactionState) onSave,
  TransactionState? initialTransaction,
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
class TransactionInputModal extends ConsumerStatefulWidget {
  final Function(TransactionState) onSave;
  final TransactionState? initialTransaction;

  const TransactionInputModal(
      {required this.onSave, this.initialTransaction, super.key});

  @override
  ConsumerState<TransactionInputModal> createState() =>
      _TransactionInputModalState();
}

class _TransactionInputModalState extends ConsumerState<TransactionInputModal> {
  bool _isExpense = true;
  final _amountController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  final List<String> _expenseCategories = [
    '食費',
    '交通費',
    '趣味・娯楽',
    '交際費',
    '日用品',
    'その他'
  ];
  final List<String> _incomeCategories = ['給与', '副業', '臨時収入', 'その他'];
  late String _selectedCategory;

  @override
  void initState() {
    super.initState();
    if (widget.initialTransaction != null) {
      final transaction = widget.initialTransaction!;

      _isExpense = transaction.type == "expense";
      _amountController.text = transaction.amount.toString();
      _selectedDate = transaction.date;
      _selectedCategory = transaction.category;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _saveTransaction() {
    final amount = int.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('金額を正しく入力してください。')),
      );
      return;
    }
    TransactionState transactionData = TransactionState(
        id: widget.initialTransaction?.id ?? ref.read(uuidProvider).v4(),
        type: _isExpense ? "expense" : "income",
        date: _selectedDate,
        amount: _isExpense ? -amount : amount,
        category: _selectedCategory);
    widget.onSave(transactionData);
    Navigator.of(context).pop();
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
    );
  }
}
