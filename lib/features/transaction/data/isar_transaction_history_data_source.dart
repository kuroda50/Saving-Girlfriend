import 'package:isar/isar.dart';
import 'transaction_history_data_source.dart';

class IsarTransactionHistoryDataSource implements TransactionHistoryDataSource {
  final Isar _isar;
  IsarTransactionHistoryDataSource(this._isar);

  @override
  Future<List<TransactionState>> fetchAll() async {
    return await _isar.transactionStates.where().findAll();
  }

  @override
  Future<void> saveAll(List<TransactionState> histories) async {
    await _isar.writeTxn(() async {
      // Isar's putAll will insert new items or update existing ones based on the Id.
      // To match the previous logic of replacing the entire list, we clear it first.
      await _isar.transactionStates.clear();
      await _isar.transactionStates.putAll(histories);
    });
  }
}
