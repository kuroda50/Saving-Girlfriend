import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:saving_girlfriend/constants/color.dart';
import 'package:saving_girlfriend/widgets/transaction_modal.dart';

import '../providers/transaction_history_provider.dart';

// allTransactionをttansactionHistoryとして再命名してもいいかも
class TransactionHistoryScreen extends ConsumerStatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  ConsumerState<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState
    extends ConsumerState<TransactionHistoryScreen> {
  late DateTime _selectedDate;
  late DateTime _currentMonthDate;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = now;
    _currentMonthDate = DateTime(now.year, now.month, 1);
  }

  void _changeMonth(int direction) {
    setState(() {
      _currentMonthDate = DateTime(
        _currentMonthDate.year,
        _currentMonthDate.month + direction,
        1,
      );
    });
  }

  void _selectDate(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
  }

  @override
  Widget build(BuildContext context) {
    final transactionsAsync = ref.watch(transactionsProvider);

    // --- 金額フォーマット関数 ---
    String formatAmount(final int amount) {
      String formatted;

      if (amount >= 1000000) {
        formatted = '${(amount / 1000000).toStringAsFixed(1)}m';
      } else if (amount >= 10000) {
        formatted = '${(amount / 1000).toStringAsFixed(1)}k';
      } else {
        formatted = '$amount円';
      }
      return amount < 0 ? '-$formatted' : formatted;
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.secondary,
      ),
      body: transactionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('エラー: $err')),
        data: (allTransactions) {
          final selectedTransactions = allTransactions.where((t) {
            return DateUtils.isSameDay(t.date, _selectedDate);
          }).toList();

          Map<String, int> calculateDailyTransactions() {
            final dailyTransaction = <String, int>{};
            for (var transaction in allTransactions) {
              final date = transaction.date;
              final amount = transaction.amount;
              if (date.month == _currentMonthDate.month &&
                  date.year == _currentMonthDate.year) {
                final formattedDate = DateFormat('yyyy-MM-dd').format(date);
                dailyTransaction[formattedDate] =
                    (dailyTransaction[formattedDate] ?? 0) +
                        (transaction.type == "income" ? amount : -amount);
              }
            }
            return dailyTransaction;
          }

          int getDaysInMonth() =>
              DateTime(_currentMonthDate.year, _currentMonthDate.month + 1, 0)
                  .day;

          int getStartDayOfMonth() {
            final weekday =
                DateTime(_currentMonthDate.year, _currentMonthDate.month, 1)
                    .weekday;
            return weekday == 7 ? 0 : weekday;
          }

          final dailyTransaction = calculateDailyTransactions();

          return Column(
            children: [
              // --- カレンダー部分 ---
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.mainBackground,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.border.withOpacity(0.5),
                      spreadRadius: 1,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left,
                              color: AppColors.primary),
                          onPressed: () => _changeMonth(-1),
                        ),
                        Text(
                          '${_currentMonthDate.year}年 ${_currentMonthDate.month}月',
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_right,
                              color: AppColors.primary),
                          onPressed: () => _changeMonth(1),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: ['日', '月', '火', '水', '木', '金', '土']
                            .map((day) => Expanded(
                                  child: Center(
                                    child: Text(
                                      day,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                          color: AppColors.subText),
                                    ),
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 7),
                      itemCount: getDaysInMonth() + getStartDayOfMonth(),
                      itemBuilder: (context, index) {
                        final startDay = getStartDayOfMonth();
                        final day = index - startDay + 1;
                        final isCurrentMonthDay =
                            day > 0 && day <= getDaysInMonth();

                        return GestureDetector(
                          onTap: () {
                            if (isCurrentMonthDay) {
                              final date = DateTime(_currentMonthDate.year,
                                  _currentMonthDate.month, day);
                              _selectDate(date);
                            }
                          },
                          child: Container(
                            margin: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: isCurrentMonthDay &&
                                        DateUtils.isSameDay(
                                            _selectedDate,
                                            DateTime(_currentMonthDate.year,
                                                _currentMonthDate.month, day))
                                    ? AppColors.primary
                                    : Colors.transparent,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: isCurrentMonthDay
                                ? Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(day.toString(),
                                          style: const TextStyle(fontSize: 12)),
                                      if (dailyTransaction.containsKey(
                                          DateFormat('yyyy-MM-dd').format(
                                              DateTime(
                                                  _currentMonthDate.year,
                                                  _currentMonthDate.month,
                                                  day))))
                                        Text(
                                          formatAmount(dailyTransaction[
                                              DateFormat('yyyy-MM-dd').format(
                                                  DateTime(
                                                      _currentMonthDate.year,
                                                      _currentMonthDate.month,
                                                      day))]!),
                                          style: const TextStyle(
                                              fontSize: 10,
                                              color: AppColors.primary),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                    ],
                                  )
                                : null,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              // --- 選択された日付の履歴リスト ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '${DateFormat('yyyy年MM月dd日').format(_selectedDate)}の履歴',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Expanded(
                child: selectedTransactions.isEmpty
                    ? const Center(child: Text('この日の履歴はありません。'))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        itemCount: selectedTransactions.length,
                        itemBuilder: (context, index) {
                          final transaction = selectedTransactions[index];
                          final isToday = DateUtils.isSameDay(
                              transaction.date, DateTime.now());
                          final type = transaction.type;
                          final amount = transaction.amount;
                          final category =
                              transaction.category as String? ?? 'カテゴリなし';
                          return Card(
                            elevation: 1,
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            child: ListTile(
                              leading: Icon(
                                type == "income"
                                    ? Icons.arrow_upward
                                    : Icons.arrow_downward,
                                color: type == "income"
                                    ? Colors.green
                                    : Colors.red,
                              ),
                              title: Text(category),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    formatAmount(amount), // k/m表記に変換
                                    style: TextStyle(
                                      color: type == "income"
                                          ? Colors.green
                                          : Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (isToday) ...[
                                    const SizedBox(width: 8),
                                    IconButton(
                                      icon: const Icon(Icons.edit,
                                          size: 20, color: Colors.grey),
                                      onPressed: () {
                                        showTransactionModal(
                                          context,
                                          onSave: (updatedData) {
                                            final transactionId =
                                                updatedData.id;
                                            ref
                                                .read(transactionsProvider
                                                    .notifier)
                                                .updateTransaction(
                                                    transactionId, updatedData);
                                          },
                                          initialTransaction: transaction,
                                        );
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete,
                                          size: 20, color: Colors.grey),
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder:
                                              (BuildContext dialogContext) {
                                            return AlertDialog(
                                              backgroundColor:
                                                  AppColors.mainBackground,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12.0),
                                              ),
                                              title: const Text(
                                                "確認",
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              content:
                                                  const Text('この履歴を削除するのね？'),
                                              actions: [
                                                SizedBox(
                                                  width: 100,
                                                  child: TextButton(
                                                    onPressed: () =>
                                                        Navigator.of(
                                                                dialogContext)
                                                            .pop(),
                                                    child: const Text("キャンセル"),
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 130,
                                                  child: ElevatedButton(
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      backgroundColor:
                                                          AppColors.primary,
                                                      foregroundColor:
                                                          AppColors.subText,
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                      ),
                                                    ),
                                                    onPressed: () {
                                                      Navigator.of(
                                                              dialogContext)
                                                          .pop();
                                                      ref
                                                          .read(
                                                              transactionsProvider
                                                                  .notifier)
                                                          .removeTransaction(
                                                              transaction.id);
                                                    },
                                                    child: const Text("削除"),
                                                  ),
                                                ),
                                              ],
                                              actionsPadding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 16.0,
                                                      vertical: 12.0),
                                            );
                                          },
                                        );
                                      },
                                    ),
                                  ]
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
