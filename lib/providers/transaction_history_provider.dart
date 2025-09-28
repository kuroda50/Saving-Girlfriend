import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:saving_girlfriend/models/settings_state.dart';
import 'package:saving_girlfriend/models/transaction_history_state.dart';
import 'package:saving_girlfriend/providers/setting_provider.dart';
import 'package:saving_girlfriend/repositories/settings_repository.dart';
import 'package:saving_girlfriend/repositories/transaction_history_repository.dart';
import 'package:saving_girlfriend/services/local_storage_service.dart';

class TransactionHistoryNotifier
    extends AsyncNotifier<TransactionHistoryState> {
  Future<TransactionHistoryRepository>
      get _transactionHistoryRepositoryFuture =>
          ref.read(transactionHistoryRepositoryProvider.future);
  Future<SettingsRepository> get _settingsRepositoryFuture =>
      ref.read(settingsRepositoryProvider.future);
  @override
  Future<TransactionHistoryState> build() async {
    final transactionHistoryRepository =
        await _transactionHistoryRepositoryFuture;
    final history = await transactionHistoryRepository.getTransactionHistory();
    final settingsRepository = await _settingsRepositoryFuture;
    SettingsState settingsState = await settingsRepository.getSettings();
    final int target = settingsState.targetSavingAmount;

    // 初期値を設定する
    final now = DateTime.now();
    final todaysTransactions = history.where((transaction) {
      final transactionDate = DateTime.parse(transaction['date']);
      return transactionDate.year == now.year &&
          transactionDate.month == now.month &&
          transactionDate.day == now.day;
    }).toList();

    return TransactionHistoryState(
      transactionHistory: history,
      targetSavingAmount: target,
      currentYear: now.year,
      currentMonth: now.month,
      selectedDate: now, // ★今日のデータを初期値に
      selectedDateTransactions: todaysTransactions, // ★今日の履歴を初期値に
    );
  }

  void changeMonth(int direction) {
    final currentState = state.value!;

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

  void selectDate(DateTime date) {
    final currentState = state.value;
    if (currentState == null) return;

    // 全履歴の中から、選択された日付と一致するものだけをフィルタリング
    final filteredTransactions =
        currentState.transactionHistory.where((transaction) {
      final transactionDate = DateTime.parse(transaction['date']);
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

  Future<void> addTransaction(Map<String, dynamic> newTransaction) async {
    final currentState = state.value;
    if (currentState == null) return;

    final currentHistory =
        List<Map<String, dynamic>>.from(currentState.transactionHistory);
    // ★ idがなければ付与する
    final transactionWithId = {
      ...newTransaction,
      'id': newTransaction['id'] ??
          'transaction_${DateTime.now().millisecondsSinceEpoch}',
    };

    currentHistory.add(transactionWithId);
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
      String id, Map<String, dynamic> updatedTransaction) async {
    final currentState = state.value;
    if (currentState == null) return;
    final currentHistory =
        List<Map<String, dynamic>>.from(currentState.transactionHistory);
    final index =
        currentHistory.indexWhere((transaction) => transaction['id'] == id);

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

final selectedTransactionsProvider =
    Provider<List<Map<String, dynamic>>>((ref) {
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
