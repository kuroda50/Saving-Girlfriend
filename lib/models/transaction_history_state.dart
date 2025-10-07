import 'package:saving_girlfriend/models/transaction_state.dart';

class TransactionHistoryState {
  final List<TransactionState> transactionHistory;
  final int currentYear;
  final int currentMonth;
  final DateTime selectedDate; // ★追加: タップされた日付
  final List<TransactionState> selectedDateTransactions; // ★追加: タップされた日付の履歴

  TransactionHistoryState({
    this.transactionHistory = const [],
    required this.currentYear,
    required this.currentMonth,
    required this.selectedDate,
    required this.selectedDateTransactions,
  });

  TransactionHistoryState copyWith({
    List<TransactionState>? transactionHistory,
    int? currentYear,
    int? currentMonth,
    DateTime? selectedDate,
    List<TransactionState>? selectedDateTransactions,
  }) {
    return TransactionHistoryState(
      transactionHistory: transactionHistory ?? this.transactionHistory,
      currentYear: currentYear ?? this.currentYear,
      currentMonth: currentMonth ?? this.currentMonth,
      selectedDate: selectedDate ?? this.selectedDate,
      selectedDateTransactions:
          selectedDateTransactions ?? this.selectedDateTransactions,
    );
  }
}
