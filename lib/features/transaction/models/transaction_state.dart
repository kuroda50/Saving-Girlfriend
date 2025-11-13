// [修正] 2つの enum ファイルをインポート
import 'package:saving_girlfriend/features/transaction/models/transaction_category.dart';
import 'package:saving_girlfriend/features/transaction/models/transaction_type.dart';

class TransactionState {
  final String id;
  // [修正] String -> enum
  final TransactionType type;
  final DateTime date;
  final int amount;
  // [修正] String -> enum
  final TransactionCategory category;

  TransactionState({
    required this.id,
    required this.type, // [修正]
    required this.date,
    required this.amount,
    required this.category, // [修正]
  });

  factory TransactionState.fromJson(Map<String, dynamic> json) {
    return TransactionState(
      id: json['id'] as String,
      // [修正] fromString を使用
      type: TransactionType.fromString(json['type'] as String),
      date: DateTime.parse(json['date'] as String),
      amount: json['amount'] as int,
      // [修正] fromString を使用
      category: TransactionCategory.fromString(json['category'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id.toString(),
      // [修正] .name で String に変換
      'type': type.name,
      'date': date.toIso8601String(),
      'amount': amount,
      // [修正] .name で String に変換
      'category': category.name,
    };
  }

  TransactionState copyWith({
    String? id,
    TransactionType? type, // [修正]
    DateTime? date,
    int? amount,
    TransactionCategory? category, // [修正]
  }) {
    return TransactionState(
      id: id ?? this.id,
      type: type ?? this.type,
      date: date ?? this.date,
      amount: amount ?? this.amount,
      category: category ?? this.category,
    );
  }
}
