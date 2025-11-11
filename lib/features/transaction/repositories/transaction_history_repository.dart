abstract class TransactionHistoryRepository {
  Future<List<TransactionState>> getHistories();
  Future<void> saveHistories(List<TransactionState> histories);
}
