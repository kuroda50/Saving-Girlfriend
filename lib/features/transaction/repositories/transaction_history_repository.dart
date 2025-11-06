// Project imports:
import 'package:saving_girlfriend/common/services/local_storage_service.dart';
import 'package:saving_girlfriend/features/transaction/models/transaction_state.dart';

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
