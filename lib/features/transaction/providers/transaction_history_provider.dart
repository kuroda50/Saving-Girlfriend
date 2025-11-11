// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:saving_girlfriend/common/services/local_storage_service.dart';
import 'package:saving_girlfriend/features/transaction/models/transaction_state.dart';
import 'package:saving_girlfriend/features/transaction/repositories/transaction_history_repository.dart';

final transactionsProvider =
    AsyncNotifierProvider<TransactionsNotifier, List<TransactionState>>(() {
  return TransactionsNotifier();
});

class TransactionsNotifier extends AsyncNotifier<List<TransactionState>> {
  // The repository is now provided synchronously, so we can read it directly.
  TransactionHistoryRepository get _repository =>
      ref.read(transactionHistoryRepositoryProvider);

  @override
  Future<List<TransactionState>> build() async {
    // Fetch initial history from the repository.
    return _repository.getHistories();
  }

  Future<void> addTransaction(final TransactionState newTransaction) async {
    // Get the current state from the notifier.
    final currentHistory = state.valueOrNull ?? [];
    final newHistory = [...currentHistory, newTransaction];

    // Optimistically update the UI.
    state = AsyncData(newHistory);

    // Persist the new state using the repository.
    await _repository.saveHistories(newHistory);
  }

  Future<void> updateTransaction(
      String id, TransactionState updatedTransaction) async {
    final currentHistory = state.valueOrNull ?? [];
    final index =
        currentHistory.indexWhere((transaction) => transaction.id == id);

    if (index != -1) {
      final newHistory = List<TransactionState>.from(currentHistory);
      newHistory[index] = updatedTransaction;

      state = AsyncData(newHistory);
      await _repository.saveHistories(newHistory);
    }
  }

  Future<void> removeTransaction(String id) async {
    final currentHistory = state.valueOrNull ?? [];
    final newHistory = currentHistory.where((tx) => tx.id != id).toList();

    state = AsyncData(newHistory);
    await _repository.saveHistories(newHistory);
  }
}
