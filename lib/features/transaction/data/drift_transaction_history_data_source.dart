import 'package:saving_girlfriend/common/services/drift_service.dart';
import 'package:saving_girlfriend/features/transaction/data/transaction_history_data_source.dart';
import 'package:saving_girlfriend/features/transaction/models/transaction_state.dart';

class DriftTransactionHistoryDataSource
    implements TransactionHistoryDataSource {
  final AppDatabase _db;

  DriftTransactionHistoryDataSource(this._db);

  @override
  Future<List<AppTransactionState>> fetchAll() async {
    final states = await _db.select(_db.transactionStates).get();
    return states
        .map((s) => AppTransactionState(
              dbId: s.dbId,
              id: s.id,
              type: s.type,
              date: s.date,
              amount: s.amount,
              category: s.category,
            ))
        .toList();
  }

  @override
  Future<void> saveAll(List<AppTransactionState> histories) async {
    await _db.batch((batch) {
      batch.deleteAll(_db.transactionStates);
      batch.insertAll(
          _db.transactionStates,
          histories
              .map((h) => AppTransactionState(
                    dbId: h.dbId,
                    id: h.id,
                    type: h.type,
                    date: h.date,
                    amount: h.amount,
                    category: h.category,
                  ))
              .toList());
    });
  }
}
