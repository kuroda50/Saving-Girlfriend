class TransactionHistoryState {
  final List<Map<String, dynamic>> transactionHistory;
  final int targetSavingAmount;
  final int currentYear;
  final int currentMonth;
  final DateTime selectedDate; // ★追加: タップされた日付
  final List<Map<String, dynamic>> selectedDateTransactions; // ★追加: タップされた日付の履歴

  TransactionHistoryState({
    this.transactionHistory = const [],
    this.targetSavingAmount = 0,
    required this.currentYear,
    required this.currentMonth,
    required this.selectedDate,
    required this.selectedDateTransactions,
  });

  TransactionHistoryState copyWith({
    List<Map<String, dynamic>>? transactionHistory,
    int? targetSavingAmount,
    int? currentYear,
    int? currentMonth,
    DateTime? selectedDate,
    List<Map<String, dynamic>>? selectedDateTransactions,
  }) {
    return TransactionHistoryState(
      transactionHistory: transactionHistory ?? this.transactionHistory,
      targetSavingAmount: targetSavingAmount ?? this.targetSavingAmount,
      currentYear: currentYear ?? this.currentYear,
      currentMonth: currentMonth ?? this.currentMonth,
      selectedDate: selectedDate ?? this.selectedDate,
      selectedDateTransactions:
          selectedDateTransactions ?? this.selectedDateTransactions,
    );
  }
}
