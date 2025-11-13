// Dart imports:
import 'dart:math';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
// Project imports:
import 'package:saving_girlfriend/features/budget/models/budget_history.dart';
import 'package:saving_girlfriend/features/budget/providers/budget_history_provider.dart';
import 'package:saving_girlfriend/features/transaction/models/transaction_state.dart';
import 'package:saving_girlfriend/features/transaction/providers/transaction_history_provider.dart';
import 'package:saving_girlfriend/features/tribute/models/tribute_history_state.dart';
import 'package:saving_girlfriend/features/tribute/providers/tribute_history_provider.dart';

part 'spendable_amount_provider.g.dart';

@riverpod
Future<int> spendableAmount(Ref ref) async {
  final budgetHistory = await ref.watch(budgetHistoryProvider.future);
  final transactionHistory = await ref.watch(transactionsProvider.future);
  final tributes = await ref.watch(tributeHistoryProvider.future);

  // 予算が一度も設定されていない、または取引が一度もなければ計算不可
  if (budgetHistory.isEmpty || transactionHistory.isEmpty) {
    return 0;
  }

  // 1. 予算履歴を日付の昇順にソート
  final sortedBudgetHistory = List<BudgetHistory>.from(budgetHistory)
    ..sort((a, b) => a.date.compareTo(b.date));

  // 2. 計算の開始日を最初の取引日に設定
  final firstTransactionDate = transactionHistory
      .map((t) => t.date)
      .reduce((a, b) => a.isBefore(b) ? a : b);
  final startDate = DateTime(firstTransactionDate.year,
      firstTransactionDate.month, firstTransactionDate.day);

  // 3. 貯金額を累積計算する
  final cumulativeAmount = _calculateCumulativeSpendableAmount(
    startDate: startDate,
    endOfToday: DateTime.now(),
    sortedBudgetHistory: sortedBudgetHistory,
    transactions: transactionHistory,
  );

  // 4. 貢ぎ物の合計金額を計算する
  final totalTributes = _calculateTotalTributes(tributes);

  // 5. 最終的な利用可能額を計算して返す
  final finalSpendableAmount = cumulativeAmount - totalTributes;
  return max(finalSpendableAmount, 0);
}

/// 日々の利用可能額を startDate から endOfToday まで累積計算します。
int _calculateCumulativeSpendableAmount({
  required DateTime startDate,
  required DateTime endOfToday,
  required List<BudgetHistory> sortedBudgetHistory,
  required List<TransactionState> transactions, // 型をTransactionのリストと仮定
}) {
  int cumulativeAmount = 0;
  final endDate = DateTime(endOfToday.year, endOfToday.month, endOfToday.day);

  for (var date = startDate;
      date.isBefore(endDate);
      date = date.add(const Duration(days: 1))) {
    // ① その日に適用されるべき予算額を取得
    final applicableBudget =
        _getApplicableBudgetForDate(date, sortedBudgetHistory);

    // その日の取引履歴があるかどうかを確認
    final hasTransactionsToday = transactions.any((t) {
      final tDate = t.date;
      return tDate.year == date.year &&
          tDate.month == date.month &&
          tDate.day == date.day;
    });

    int dailyExpense;
    if (hasTransactionsToday) {
      // ② その日の純粋な支出額を計算
      dailyExpense = _calculateDailyNetExpense(date, transactions);
    } else {
      // 支出履歴がない日は、その日の予算をすべて使った（貯金0）とみなす
      dailyExpense = applicableBudget;
    }

    // ③ その日の繰越可能額を計算し、合計に加える
    final dailyAvailable = applicableBudget - dailyExpense;
    cumulativeAmount += dailyAvailable.clamp(0, applicableBudget);
  }
  return cumulativeAmount;
}

/// 指定された日に適用される予算額を取得します。
int _getApplicableBudgetForDate(
  DateTime date,
  List<BudgetHistory> sortedBudgetHistory,
) {
  // date以前で最も新しい予算設定を探す
  return sortedBudgetHistory
      .lastWhere(
        (b) => !b.date.isAfter(date),
        orElse: () => sortedBudgetHistory.first, // 見つからない場合は最初の予算（理論上起こらないはず）
      )
      .amount;
}

/// 指定された日の純粋な支出額（支出 - 収入）を計算します。
int _calculateDailyNetExpense(
  DateTime date,
  List<TransactionState> transactions,
) {
  return transactions
      .where((t) {
        final tDate = t.date;
        return tDate.year == date.year &&
            tDate.month == date.month &&
            tDate.day == date.day;
      })
      .map((t) => t.type == "expense" ? t.amount : -t.amount)
      .fold(0, (prev, amount) => prev + amount);
}

/// 貢ぎ物の合計金額を計算します。
int _calculateTotalTributes(List<TributeState> tributes) {
  // 型をTributeのリストと仮定
  return tributes
      .map((tribute) => tribute.amount)
      .fold(0, (prev, amount) => prev + amount);
}
