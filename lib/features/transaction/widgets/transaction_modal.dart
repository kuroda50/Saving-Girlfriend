// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Project imports:
import 'package:saving_girlfriend/common/constants/color.dart';
import 'package:saving_girlfriend/common/providers/uuid_provider.dart';
// [修正] 2つの enum ファイルをインポート
import 'package:saving_girlfriend/features/transaction/models/transaction_category.dart';
import 'package:saving_girlfriend/features/transaction/models/transaction_state.dart';
import 'package:saving_girlfriend/features/transaction/models/transaction_type.dart';

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

  // [修正] List<String> から List<TransactionCategory> (enum) に変更
  final List<TransactionCategory> _expenseCategories = [
    TransactionCategory.food,
    TransactionCategory.transport,
    TransactionCategory.entertainment,
    TransactionCategory.social,
    TransactionCategory.daily,
    TransactionCategory.other,
  ];
  final List<TransactionCategory> _incomeCategories = [
    TransactionCategory.salary,
    TransactionCategory.sideJob,
    TransactionCategory.extraIncome,
    TransactionCategory.other,
  ];
  // [修正] String から enum に変更
  late TransactionCategory _selectedCategory;

  @override
  void initState() {
    super.initState();
    if (widget.initialTransaction != null) {
      final transaction = widget.initialTransaction!;

      // [修正] String 比較から enum 比較に変更
      _isExpense = transaction.type == TransactionType.expense;
      _amountController.text = transaction.amount.toString();
      _selectedDate = transaction.date;
      _selectedCategory = transaction.category; // [修正] enum を代入
    } else {
      // [修正] 初期値を設定
      _selectedCategory = _expenseCategories[0];
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
      // [修正] String から enum に変更
      type: _isExpense ? TransactionType.expense : TransactionType.income,
      date: _selectedDate,
      amount: amount,
      // [修正] _selectedCategory (enum) をそのまま渡す
      category: _selectedCategory,
    );
    widget.onSave(transactionData);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final currentCategories =
        _isExpense ? _expenseCategories : _incomeCategories;

    // [修正] 収入/支出を切り替えたときに、選択中のカテゴリがリストに含まれない場合、先頭のカテゴリを再選択する
    if (!currentCategories.contains(_selectedCategory)) {
      _selectedCategory = currentCategories[0];
    }

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
                  // [修正] リスト切り替えと同時に、選択中のカテゴリも更新
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
          // [修正] DropdownButtonFormField<String> から <TransactionCategory> に変更
          DropdownButtonFormField<TransactionCategory>(
            initialValue: _selectedCategory, // [修正] value を使用
            hint: const Text('カテゴリを選択'),
            decoration: const InputDecoration(
              labelText: 'カテゴリ',
              prefixIcon: Icon(Icons.category_outlined),
              border: OutlineInputBorder(),
            ),
            // [修正] enum のリストから DropdownMenuItem を作成
            items: currentCategories.map((TransactionCategory category) {
              return DropdownMenuItem<TransactionCategory>(
                value: category,
                // [修正] 表示名 (displayName) を Text に表示
                child: Text(category.displayName),
              );
            }).toList(),
            // [修正] onChanged の型を <TransactionCategory?> に変更
            onChanged: (TransactionCategory? newValue) {
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
