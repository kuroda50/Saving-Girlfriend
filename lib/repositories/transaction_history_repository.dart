import '../services/local_storage_service.dart';

class TransactionHistoryRepository {
  final LocalStorageService _localStorageService;
  TransactionHistoryRepository(this._localStorageService);

  Future<void> saveTransactionHistory(
      List<Map<String, dynamic>> history) async {
    await _localStorageService.saveTransactionHistory(history);
  }

  Future<List<Map<String, dynamic>>> getTransactionHistory() async {
    return _localStorageService.getTransactionHistory();
  }
}
