class AppTransactionState {
  int dbId;
  final String id;

  final String type; // "expense" または "income"
  final DateTime date;
  final int amount;
  final String category;

  AppTransactionState({
    this.dbId = 0,
    required this.id,
    required this.type,
    required this.date,
    required this.amount,
    required this.category,
  });

  factory AppTransactionState.fromJson(Map<String, dynamic> json) {
    return AppTransactionState(
      id: json['id'] as String,
      type: json['type'] as String,
      date: DateTime.parse(json['date'] as String),
      amount: json['amount'] as int,
      category: json['category'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id.toString(),
      'type': type,
      'date': date.toIso8601String(),
      'amount': amount,
      'category': category,
    };
  }

  AppTransactionState copyWith({
    int? dbId,
    String? id,
    String? type,
    DateTime? date,
    int? amount,
    String? category,
  }) {
    return AppTransactionState(
      dbId: dbId ?? this.dbId,
      id: id ?? this.id,
      type: type ?? this.type,
      date: date ?? this.date,
      amount: amount ?? this.amount,
      category: category ?? this.category,
    );
  }
}
