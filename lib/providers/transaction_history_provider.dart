import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:saving_girlfriend/models/transaction_state.dart';
import 'package:saving_girlfriend/repositories/transaction_history_repository.dart';
import 'package:saving_girlfriend/services/local_storage_service.dart';

final transactionsProvider =
    AsyncNotifierProvider<TransactionsNotifier, List<TransactionState>>(() {
  return TransactionsNotifier();
});

class TransactionsNotifier extends AsyncNotifier<List<TransactionState>> {
  Future<TransactionHistoryRepository>
      get _transactionHistoryRepositoryFuture =>
          ref.read(transactionHistoryRepositoryProvider.future);

  @override
  Future<List<TransactionState>> build() async {
    final transactionHistoryRepository =
        await _transactionHistoryRepositoryFuture;
    final history = await transactionHistoryRepository.getTransactionHistory();
    return history;
  }

  Future<void> addTransaction(final TransactionState newTransaction) async {
    final currentHistory = await future;
    final newHistory = [...currentHistory, newTransaction];

    state = AsyncData(newHistory);

    final transactionHistoryRepository =
        await _transactionHistoryRepositoryFuture;
    await transactionHistoryRepository.saveTransactionHistory(newHistory);
  }

  Future<void> updateTransaction(
      String id, TransactionState updatedTransaction) async {
    final currentHistory = await future;
    final index =
        currentHistory.indexWhere((transaction) => transaction.id == id);

    if (index != -1) {
      final newHistory = List<TransactionState>.from(currentHistory);
      newHistory[index] = updatedTransaction;

      state = AsyncData(newHistory);

      final transactionHistoryRepository =
          await _transactionHistoryRepositoryFuture;
      await transactionHistoryRepository.saveTransactionHistory(newHistory);
    }
  }
}

final transactionHistoryRepositoryProvider =
    FutureProvider<TransactionHistoryRepository>((ref) async {
  final localStorageService =
      await ref.watch(localStorageServiceProvider.future);
  return TransactionHistoryRepository(localStorageService);
});
