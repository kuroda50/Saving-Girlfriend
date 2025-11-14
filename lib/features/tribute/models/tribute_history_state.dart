class TributeState {
  final String id;
  final String character;
  final DateTime date;
  final int amount;

  TributeState({
    required this.id,
    required this.character,
    required this.date,
    required this.amount,
  });

  TributeState copyWith({
    String? id,
    String? character,
    DateTime? date,
    int? amount,
  }) {
    return TributeState(
      id: id ?? this.id,
      character: character ?? this.character,
      date: date ?? this.date,
      amount: amount ?? this.amount,
    );
  }

  // ★★★★★ ここから追加 ★★★★★
  factory TributeState.fromJson(Map<String, dynamic> json) {
    return TributeState(
      id: json['id'] as String,
      character: json['character'] as String,
      date: DateTime.parse(json['date'] as String),
      amount: json['amount'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'character': character,
      'date': date.toIso8601String(),
      'amount': amount,
    };
  }
  // ★★★★★ ここまで追加 ★★★★★
}
