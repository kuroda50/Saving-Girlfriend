import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:saving_girlfriend/constants/color.dart';
import 'package:saving_girlfriend/widgets/transaction_modal.dart';
import '../providers/transaction_history_provider.dart';

class TransactionHistoryScreen extends ConsumerWidget {
  const TransactionHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionHistoryAsync = ref.watch(transactionHistoryProvider);
    final selectedTransactions = ref.watch(selectedTransactionsProvider);

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
      body: transactionHistoryAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('エラー: $err')),
        data: (state) {
          Map<String, int> calculateDailyTransactions() {
            final dailyTransaction = <String, int>{};
            for (var transaction in state.transactionHistory) {
              final date = transaction.date;
              final amount = transaction.amount;
              if (date.month == state.currentMonth &&
                  date.year == state.currentYear) {
                final formattedDate = DateFormat('yyyy-MM-dd').format(date);
                dailyTransaction[formattedDate] =
                    (dailyTransaction[formattedDate] ?? 0) +
                        (transaction.type == "income" ? amount : -amount);
              }
            }
            return dailyTransaction;
          }

          int getDaysInMonth() =>
              DateTime(state.currentYear, state.currentMonth + 1, 0).day;

          int getStartDayOfMonth() {
            final weekday =
                DateTime(state.currentYear, state.currentMonth, 1).weekday;
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
                          onPressed: () => ref
                              .read(transactionHistoryProvider.notifier)
                              .changeMonth(-1),
                        ),
                        Text(
                          '${state.currentYear}年 ${state.currentMonth}月',
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_right,
                              color: AppColors.primary),
                          onPressed: () => ref
                              .read(transactionHistoryProvider.notifier)
                              .changeMonth(1),
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
                              final date = DateTime(
                                  state.currentYear, state.currentMonth, day);
                              ref
                                  .read(transactionHistoryProvider.notifier)
                                  .selectDate(date);
                            }
                          },
                          child: Container(
                            margin: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: isCurrentMonthDay &&
                                        DateUtils.isSameDay(
                                            state.selectedDate,
                                            DateTime(state.currentYear,
                                                state.currentMonth, day))
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
                                              DateTime(state.currentYear,
                                                  state.currentMonth, day))))
                                        Text(
                                          formatAmount(dailyTransaction[
                                              DateFormat('yyyy-MM-dd').format(
                                                  DateTime(
                                                      state.currentYear,
                                                      state.currentMonth,
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
                    '${DateFormat('yyyy年MM月dd日').format(state.selectedDate)}の履歴',
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
                                  const SizedBox(width: 8),
                                  IconButton(
                                    icon: const Icon(Icons.edit,
                                        size: 20, color: Colors.grey),
                                    onPressed: () {
                                      showTransactionModal(
                                        context,
                                        onSave: (updatedData) {
                                          final transactionId = updatedData.id;
                                          ref
                                              .read(transactionHistoryProvider
                                                  .notifier)
                                              .updateTransaction(
                                                  transactionId, updatedData);
                                        },
                                        initialTransaction: transaction,
                                      );
                                    },
                                  ),
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
