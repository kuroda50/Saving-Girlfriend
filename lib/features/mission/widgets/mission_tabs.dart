import 'package:flutter/material.dart';

// ★★★ カスタムタブウィジェット (バッジ表示対応) ★★★
class CustomMissionTabs extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;
  // ★ 1. カウントを受け取る変数を追加
  final int dailyCount;
  final int weeklyCount;
  final int mainCount;
  final int randomCount;

  const CustomMissionTabs({
    super.key, // ★ key を追加
    required this.selectedIndex,
    required this.onTabSelected,
    // ★ 2. コンストラクタに追加 (デフォルト値 0)
    this.dailyCount = 0,
    this.weeklyCount = 0,
    this.mainCount = 0,
    this.randomCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // ★ 背景色を透明に
      color: Colors.transparent,
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // ★ 3. _buildTabButton に対応するカウントを渡す
          _buildTabButton(context, 'デイリー', 0, dailyCount),
          const SizedBox(width: 8),
          _buildTabButton(context, 'ウィークリー', 1, weeklyCount),
          const SizedBox(width: 8),
          _buildTabButton(context, 'メイン', 2, mainCount),
          const SizedBox(width: 8),
          _buildTabButton(context, 'ランダム', 3, randomCount),
        ],
      ),
    );
  }

  // ★ 4. _buildTabButton メソッドを修正 (count 引数を追加)
  // (このクラス内でのみ使うため、プライベート `_` のままでOK)
  Widget _buildTabButton(
      BuildContext context, String text, int index, int count) {
    final bool isSelected = (selectedIndex == index);

    return Expanded(
      child: GestureDetector(
        onTap: () => onTabSelected(index),
        child: Container(
          height: 44,
          decoration: BoxDecoration(
            // ★ 選択中のタブの色をピンクに
            color: isSelected
                ? Colors.pinkAccent.withOpacity(0.8) // ★ ピンクに変更
                : Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(22), // 完全に丸い角
            border: Border.all(
              color: isSelected
                  ? Colors.white.withOpacity(0.8)
                  : Colors.white.withOpacity(0.4),
              width: 1.5,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.pinkAccent.withOpacity(0.5), // ★ ピンクに変更
                      blurRadius: 8,
                      spreadRadius: 2,
                    )
                  ]
                : [],
          ),
          // ★ 5. Center を Stack に変更してバッジを重ねる
          child: Stack(
            clipBehavior: Clip.none, // Stack の外にはみ出すのを許可
            alignment: Alignment.center,
            children: [
              // 1. タブのテキスト
              Text(
                text,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 13, // ★ 4タブでも収まるように 13 に
                ),
              ),

              // 2. ★ 達成ミッション数のバッジ (count > 0 の時だけ表示)
              if (count > 0)
                Positioned(
                  top: -4, // ボタンの上にはみ出す
                  right: 4, // ボタンの右端に合わせる
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.redAccent, // バッジの色
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Center(
                      child: Text(
                        '$count', // カウント数を表示
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
