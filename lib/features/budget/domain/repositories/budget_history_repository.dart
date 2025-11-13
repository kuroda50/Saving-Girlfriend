// Project imports:
import 'package:saving_girlfriend/features/budget/models/budget_history.dart';

abstract class BudgetHistoryRepository {
  /// 履歴をすべて取得する
  Future<List<BudgetHistory>> getBudgetHistory();

  /// 今日の日付に対応する予算を更新または新規作成する
  Future<void> updateDailyBudget(int newBudget);

  /// 最新の（現在の）日次予算額を取得する
  Future<int> getCurrentDailyBudget();
}
