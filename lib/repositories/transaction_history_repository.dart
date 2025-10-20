// Project imports:
import 'package:saving_girlfriend/models/transaction_state.dart';
import '../services/local_storage_service.dart';

class TransactionHistoryRepository {
  final LocalStorageService _localStorageService;
  TransactionHistoryRepository(this._localStorageService);

  Future<void> saveTransactionHistory(List<TransactionState> history) async {
    await _localStorageService.saveTransactionHistory(history);
  }

  Future<List<TransactionState>> getTransactionHistory() async {
    return _localStorageService.getTransactionHistory();
  }
}
