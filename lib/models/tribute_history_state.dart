import 'package:uuid/uuid.dart';

class TributeHistoryState {
  final Uuid id;
  final String character;
  final DateTime date;
  final int amount;

  TributeHistoryState({
    required this.id,
    required this.character,
    required this.date,
    required this.amount,
  });

  TributeHistoryState copyWith({
    Uuid? id,
    String? character,
    DateTime? date,
    int? amount,
  }) {
    return TributeHistoryState(
      id: id ?? this.id,
      character: character ?? this.character,
      date: date ?? this.date,
      amount: amount ?? this.amount,
    );
  }
}
