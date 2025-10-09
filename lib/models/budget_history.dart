class BudgetHistory {
  final DateTime date; // この予算が適用され始めた日
  final int amount; // 予算額
  BudgetHistory({required this.date, required this.amount});

  factory BudgetHistory.fromJson(Map<String, dynamic> json) {
    return BudgetHistory(
      date: DateTime.parse(json['date']),
      amount: json['amount'],
    );
  }

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'amount': amount,
      };
}
