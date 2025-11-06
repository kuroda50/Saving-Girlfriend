class Episode {
  final int number;
  final String title;
  final int requiredLikeability; // エピソードをアンロックするために必要な好感度
  bool isLocked;
  final bool showUnlockedIcon; // クリア済みの印

  Episode({
    required this.number,
    required this.title,
    this.requiredLikeability = 0, // デフォルトは0
    this.isLocked = false,
    this.showUnlockedIcon = true,
  });
}
