// Package imports:
import 'package:drift/drift.dart';

// Project imports:
import 'package:saving_girlfriend/common/constants/settings_defaults.dart';
import 'package:saving_girlfriend/features/budget/data/local/database.dart'
    as db;
import 'package:saving_girlfriend/features/budget/domain/repositories/budget_history_repository.dart';
import 'package:saving_girlfriend/features/budget/models/budget_history.dart';

class DriftBudgetHistoryRepository implements BudgetHistoryRepository {
  final db.AppDatabase _db;

  DriftBudgetHistoryRepository(this._db);

  @override
  Future<List<BudgetHistory>> getBudgetHistory() async {
    final historyFromDb = await (_db.select(_db.budgetHistories)
          ..orderBy([(t) => OrderingTerm(expression: t.date)]))
        .get();

    return historyFromDb
        .map((h) => BudgetHistory(date: h.date, amount: h.amount))
        .toList();
  }

  @override
  Future<void> updateDailyBudget(int newBudget) async {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    final entry = db.BudgetHistoriesCompanion(
      date: Value(todayDate),
      amount: Value(newBudget),
    );

    await _db.into(_db.budgetHistories).insert(
          entry,
          onConflict: DoUpdate(
            (old) => entry,
            target: [_db.budgetHistories.date],
          ),
        );
  }

  @override
  Future<int> getCurrentDailyBudget() async {
    final result = await (_db.select(_db.budgetHistories)
          ..orderBy([
            (t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc)
          ])
          ..limit(1))
        .getSingleOrNull();

    return result?.amount ?? SettingsDefaults.dailyBudget;
  }
}
