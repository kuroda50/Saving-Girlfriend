// [修正] class TransactionCategory { ... } だった部分を
// 以下のように enum で上書きします。

enum TransactionCategory {
  // 支出カテゴリ (modal.dart のリストより)
  food('食費'),
  transport('交通費'),
  entertainment('趣味・娯楽'),
  social('交際費'),
  daily('日用品'),

  // 収入カテゴリ (modal.dart のリストより)
  salary('給与'),
  sideJob('副業'),
  extraIncome('臨時収入'),

  // 共通カテゴリ
  other('その他');

  // --- ここから下は enum の定義 ---

  const TransactionCategory(this.displayName);
  final String displayName;

  /// 文字列から TransactionCategory enum に変換します。
  /// (古いデータやDBからの読み込みに対応するため)
  static TransactionCategory fromString(String category) {
    // 1. .name ('food', 'salary' など) に一致するかチェック
    for (final value in TransactionCategory.values) {
      if (value.name == category) {
        return value;
      }
    }
    // 2. .displayName ('食費', '給与' など) に一致するかチェック
    for (final value in TransactionCategory.values) {
      if (value.displayName == category) {
        return value;
      }
    }
    // 3. それでも見つからなければ 'other'
    return TransactionCategory.other;
  }
}
