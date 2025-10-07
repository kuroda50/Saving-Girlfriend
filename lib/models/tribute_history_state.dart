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
}
