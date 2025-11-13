// lib/app/providers/today_savings_provider.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:saving_girlfriend/common/constants/settings_defaults.dart';

// 依存する他のプロバイダーをインポート
import 'package:saving_girlfriend/features/budget/providers/budget_history_provider.dart';
import 'package:saving_girlfriend/features/transaction/providers/transaction_history_provider.dart';

part 'today_savings_provider.g.dart';

@riverpod
Future<int> todaySavings(TodaySavingsRef ref) async {
  // 1. 依存するプロバイダーを監視
  final budgetHistory = await ref.watch(budgetHistoryProvider.future);
  final transactions = await ref.watch(transactionsProvider.future);

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  // 2. 今日の予算額を取得
  final applicableBudget = budgetHistory
          .where((b) => !b.date.isAfter(today)) // 今日以前の予算設定に絞る
          .lastOrNull // 最も新しいものを取得
          ?.amount ??
      SettingsDefaults.dailyBudget;

  // 3. 今日の純粋な支出額を計算
  final todayNetExpense = transactions
      .where((tx) {
        final txDate = tx.date;
        return txDate.year == today.year &&
            txDate.month == today.month &&
            txDate.day == today.day;
      })
      .map((tx) => tx.type == 'expense' ? tx.amount : -tx.amount) // 支出は正、収入は負
      .fold(0, (sum, amount) => sum + amount.toInt());

  // 4. 今日の貯金額を計算して返す
  return applicableBudget - todayNetExpense;
}
