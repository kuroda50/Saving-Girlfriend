class BudgetHistory {
  final int? id;
  final DateTime date; // この予算が適用され始めた日
  final int amount; // 予算額
  final DateTime? createdAt;

  BudgetHistory({
    this.id,
    required this.date,
    required this.amount,
    this.createdAt,
  });

  factory BudgetHistory.fromJson(Map<String, dynamic> json) {
    return BudgetHistory(
      id: json['id'],
      date: DateTime.parse(json['date']),
      amount: json['amount'],
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'amount': amount,
        'createdAt': createdAt?.toIso8601String(),
      };
}
