import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:saving_girlfriend/models/transaction_history_state.dart';
import 'package:saving_girlfriend/models/transaction_state.dart';
import 'package:saving_girlfriend/repositories/transaction_history_repository.dart';
import 'package:saving_girlfriend/services/local_storage_service.dart';

class TransactionHistoryNotifier
    extends AsyncNotifier<TransactionHistoryState> {
  Future<TransactionHistoryRepository>
      get _transactionHistoryRepositoryFuture =>
          ref.read(transactionHistoryRepositoryProvider.future);
  @override
  Future<TransactionHistoryState> build() async {
    final transactionHistoryRepository =
        await _transactionHistoryRepositoryFuture;
    final history = await transactionHistoryRepository.getTransactionHistory();

    // 初期値を設定する
    final now = DateTime.now();
    final todaysTransactions = history.where((transaction) {
      final transactionDate = transaction.date;
      return transactionDate.year == now.year &&
          transactionDate.month == now.month &&
          transactionDate.day == now.day;
    }).toList();

    return TransactionHistoryState(
      transactionHistory: history,
      currentYear: now.year,
      currentMonth: now.month,
      selectedDate: now, // ★今日のデータを初期値に
      selectedDateTransactions: todaysTransactions, // ★今日の履歴を初期値に
    );
  }

  void changeMonth(int direction) async {
    final currentState = state.value ?? await future;

    int newMonth = currentState.currentMonth + direction;
    int newYear = currentState.currentYear;

    if (newMonth > 12) {
      newMonth = 1;
      newYear++;
    } else if (newMonth < 1) {
      newMonth = 12;
      newYear--;
    }

    state = AsyncData(currentState.copyWith(
      currentYear: newYear,
      currentMonth: newMonth,
    ));
  }

  void selectDate(DateTime date) async {
    final currentState = state.value ?? await future;

    // 全履歴の中から、選択された日付と一致するものだけをフィルタリング
    final filteredTransactions =
        currentState.transactionHistory.where((transaction) {
      final transactionDate = transaction.date;
      return transactionDate.year == date.year &&
          transactionDate.month == date.month &&
          transactionDate.day == date.day;
    }).toList();

    // 状態を更新してUIに通知
    state = AsyncData(currentState.copyWith(
      selectedDate: date,
      selectedDateTransactions: filteredTransactions,
    ));
  }

  Future<void> addTransaction(final TransactionState newTransaction) async {
    // state.valueがnullの場合、futureを使って状態を初期化する
    final currentState = state.value ?? await future;

    final currentHistory =
        List<TransactionState>.from(currentState.transactionHistory);

    currentHistory.add(newTransaction);
    final transactionHistoryRepository =
        await _transactionHistoryRepositoryFuture;
    await transactionHistoryRepository.saveTransactionHistory(currentHistory);

    final newState = currentState.copyWith(
      transactionHistory: currentHistory,
    );
    state = AsyncData(newState);
    selectDate(newState.selectedDate);
  }

  Future<void> updateTransaction(
      String id, TransactionState updatedTransaction) async {
    final currentState = state.value ?? await future;
    final currentHistory =
        List<TransactionState>.from(currentState.transactionHistory);
    final index =
        currentHistory.indexWhere((transaction) => transaction.id == id);

    if (index != -1) {
      currentHistory[index] = updatedTransaction;
      final transactionHistoryRepository =
          await _transactionHistoryRepositoryFuture;
      await transactionHistoryRepository.saveTransactionHistory(currentHistory);

      final newState = currentState.copyWith(
        transactionHistory: currentHistory,
      );
      state = AsyncData(newState);
      selectDate(newState.selectedDate);
    }
  }
}

final transactionHistoryProvider =
    AsyncNotifierProvider<TransactionHistoryNotifier, TransactionHistoryState>(
        () {
  return TransactionHistoryNotifier();
});

final selectedTransactionsProvider = Provider<List<TransactionState>>((ref) {
  final transactions = ref.watch(transactionHistoryProvider.select(
    (asyncState) => asyncState.value?.selectedDateTransactions ?? [],
  ));
  return transactions;
});

final transactionHistoryRepositoryProvider =
    FutureProvider<TransactionHistoryRepository>((ref) async {
  final localStorageService =
      await ref.watch(localStorageServiceProvider.future);
  return TransactionHistoryRepository(localStorageService);
});
