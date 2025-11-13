// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:saving_girlfriend/common/services/local_storage_service.dart';
import 'package:saving_girlfriend/features/mission/models/mission.dart'
    as mission_model;
import 'package:saving_girlfriend/features/mission/providers/mission_provider.dart';
// Project imports:
import 'package:saving_girlfriend/features/transaction/models/transaction_state.dart';
import 'package:saving_girlfriend/features/transaction/repositories/transaction_history_repository.dart';

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

    // ↓↓↓ ★ここから追記★ ↓↓↓
    // 収支入力をしたら、ミッションの進捗を更新する
    try {
      ref
          .read(missionNotifierProvider.notifier)
          .updateProgress(mission_model.MissionCondition.inputTransaction);
    } catch (e) {
      print('ミッション(inputTransaction)の更新に失敗: $e');
    }
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

  Future<void> removeTransaction(String id) async {
    final currentHistory = await future;
    final newHistory = currentHistory.where((tx) => tx.id != id).toList();

    state = AsyncData(newHistory);

    final transactionHistoryRepository =
        await _transactionHistoryRepositoryFuture;
    await transactionHistoryRepository.saveTransactionHistory(newHistory);
  }
}

final transactionHistoryRepositoryProvider =
    FutureProvider<TransactionHistoryRepository>((ref) async {
  final localStorageService =
      await ref.watch(localStorageServiceProvider.future);
  return TransactionHistoryRepository(localStorageService);
});
