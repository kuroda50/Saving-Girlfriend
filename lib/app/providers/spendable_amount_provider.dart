// Dart imports:

// Package imports:
import 'package:riverpod_annotation/riverpod_annotation.dart';
// Project imports:
import 'package:saving_girlfriend/features/budget/models/budget_history.dart';
import 'package:saving_girlfriend/features/budget/providers/budget_history_provider.dart';
import 'package:saving_girlfriend/features/transaction/models/transaction_state.dart';
import 'package:saving_girlfriend/features/transaction/providers/transaction_history_provider.dart';
import 'package:saving_girlfriend/features/tribute/models/tribute_history_state.dart';

part 'spendable_amount_provider.g.dart';

@riverpod
// ▼▼▼ 戻り値の型を Future<double> から Future<int> に変更 ▼▼▼
Future<int> spendableAmount(SpendableAmountRef ref) async {
  // 1. 予算履歴を取得
  final budgetHistory = await ref.watch(budgetHistoryProvider.future);
  // 2. 支出履歴を取得
  final transactions = await ref.watch(transactionsProvider.future);

  // 3. 最新の予算額を取得
  final latestBudget = budgetHistory.isNotEmpty ? budgetHistory.last : null;

  // 今日の日付
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  // 今日の支出合計を計算
  final todayExpenses = transactions
      .where((tx) =>
          tx.type == 'expense' &&
          tx.date.year == today.year &&
          tx.date.month == today.month &&
          tx.date.day == today.day)
      // ▼▼▼ double (0.0) から int (0) で計算するように変更 ▼▼▼
      .fold(0, (sum, tx) => sum + tx.amount); // .toInt() を追加 (intで加算)

  // 4. 利用可能額を計算して返す
  // ▼▼▼ double (0.0) から int (0) で計算するように変更 ▼▼▼
  return (latestBudget?.amount ?? 0) - todayExpenses;
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
