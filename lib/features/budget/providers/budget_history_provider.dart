// Package imports:
import 'package:riverpod_annotation/riverpod_annotation.dart';

// Project imports:
import 'package:saving_girlfriend/features/budget/data/local/database.dart'
    hide BudgetHistory;
import 'package:saving_girlfriend/features/budget/data/repositories/drift_budget_history_repository.dart';
import 'package:saving_girlfriend/features/budget/domain/repositories/budget_history_repository.dart';
import 'package:saving_girlfriend/features/budget/models/budget_history.dart';

part 'budget_history_provider.g.dart';

@Riverpod(keepAlive: true)
AppDatabase appDatabase(AppDatabaseRef ref) {
  return AppDatabase();
}

@Riverpod(keepAlive: true)
BudgetHistoryRepository budgetHistoryRepository(
    BudgetHistoryRepositoryRef ref) {
  return DriftBudgetHistoryRepository(ref.watch(appDatabaseProvider));
}

@riverpod
Future<List<BudgetHistory>> budgetHistory(BudgetHistoryRef ref) {
  return ref.watch(budgetHistoryRepositoryProvider).getBudgetHistory();
}

@riverpod
Future<int> currentDailyBudget(CurrentDailyBudgetRef ref) {
  return ref.watch(budgetHistoryRepositoryProvider).getCurrentDailyBudget();
}
