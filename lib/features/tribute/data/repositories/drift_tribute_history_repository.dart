// Package imports:
import 'package:drift/drift.dart';

// Project imports:
import 'package:saving_girlfriend/features/tribute/data/local/database.dart'
    as db;
import 'package:saving_girlfriend/features/tribute/domain/repositories/tribute_history_repository.dart';
import 'package:saving_girlfriend/features/tribute/models/tribute_history_state.dart';

class DriftTributeHistoryRepository implements TributeHistoryRepository {
  final db.TributeAppDatabase _db;

  DriftTributeHistoryRepository(this._db);

  @override
  Future<List<TributeState>> getTributionHistory() async {
    final historyFromDb = await (_db.select(_db.tributeHistories)
          ..orderBy([(t) => OrderingTerm(expression: t.date)]))
        .get();

    return historyFromDb
        .map((h) => TributeState(
              id: h.id,
              character: h.character,
              date: h.date,
              amount: h.amount,
            ))
        .toList();
  }

  @override
  Future<void> saveTributionHistory(List<TributeState> history) async {
    final entries = history.map((h) {
      return db.TributeHistoriesCompanion.insert(
        id: h.id,
        character: h.character,
        date: h.date,
        amount: h.amount,
      );
    }).toList();

    // Replace all existing data with the new history
    await _db.batch((batch) {
      batch.deleteAll(_db.tributeHistories);
      batch.insertAll(_db.tributeHistories, entries);
    });
  }
}
