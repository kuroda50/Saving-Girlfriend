enum TransactionType {
  expense, // 支出
  income; // 収入

  /// 文字列から TransactionType enum に変換します。
  /// 不明な文字列の場合は expense をデフォルトとします。
  static TransactionType fromString(String type) {
    return TransactionType.values.firstWhere(
      (e) => e.name == type,
      orElse: () => TransactionType.expense,
    );
  }

  /// 画面表示用の文字列（必要に応じて）
  String get displayName {
    switch (this) {
      case TransactionType.expense:
        return '支出';
      case TransactionType.income:
        return '収入';
    }
  }
}
