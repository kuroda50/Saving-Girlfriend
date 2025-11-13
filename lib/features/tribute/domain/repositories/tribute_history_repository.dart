// Project imports:
import 'package:saving_girlfriend/features/tribute/models/tribute_history_state.dart';

abstract class TributeHistoryRepository {
  /// 貢ぎ履歴を保存する
  Future<void> saveTributionHistory(List<TributeState> history);

  /// 貢ぎ履歴をすべて取得する
  Future<List<TributeState>> getTributionHistory();
}
