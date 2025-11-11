abstract class TransactionHistoryDataSource {
  Future<List<TransactionState>> fetchAll();
  Future<void> saveAll(List<TransactionState> histories);
}
