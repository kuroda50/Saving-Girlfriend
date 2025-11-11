import '../data/transaction_history_data_source.dart';
import 'transaction_history_repository.dart';

class TransactionHistoryRepositoryImpl implements TransactionHistoryRepository {
  final TransactionHistoryDataSource _dataSource;

  TransactionHistoryRepositoryImpl(this._dataSource);

  @override
  Future<List<TransactionState>> getHistories() {
    return _dataSource.fetchAll();
  }

  @override
  Future<void> saveHistories(List<TransactionState> histories) {
    return _dataSource.saveAll(histories);
  }
}
