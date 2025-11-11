// widgets/character_card.dart (または該当するパスのファイル)

// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
// Characterクラスが定義されているファイルをインポート
import 'package:saving_girlfriend/common/models/character.dart'; // AppColorsが定義されているファイルをインポート
import 'package:saving_girlfriend/common/constants/color.dart';

class CharacterCard extends StatelessWidget {
  // 表示するキャラクターデータ
  final Character character;
  // 画面の寸法（_SelectGirlfriendScreenStateから渡す）
  final double maxImageWidth;
  final double imageHeight;
  // タップ時のコールバック（_selectGirlfriendAndSaveStateを呼び出す）
  final VoidCallback onTap;

  const CharacterCard({
    required this.character,
    required this.maxImageWidth,
    required this.imageHeight,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 10.0),
            padding: const EdgeInsets.all(10.0),
            constraints: BoxConstraints(
              maxWidth: maxImageWidth + 20,
            ),
            decoration: BoxDecoration(
              // 少女漫画風デザイン: グラデーション
              gradient: const LinearGradient(
                colors: [
                  Color.fromARGB(255, 255, 230, 240), // 非常に淡いピンク
                  Color.fromARGB(255, 255, 210, 225), // 淡いピンク
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(25.0), // さらに丸みを帯びさせる
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.5), // 影の色を濃く、柔らかく
                  spreadRadius: 3,
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 1. キャラクター画像
                ClipRRect(
                  borderRadius: BorderRadius.circular(20.0), // 角丸を大きく
                  child: Image.asset(
                    character.image, // ★ キャラクター画像を表示
                    height: imageHeight, // ⭐高さ
                    width: maxImageWidth, // 画像を最大限まで拡大
                    fit: BoxFit.fitHeight, // 高さに合わせて画像をフィットさせる
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: imageHeight,
                        width: maxImageWidth,
                        color: AppColors.border,
                        alignment: Alignment.center,
                        child: const Icon(Icons.broken_image,
                            size: 50, color: AppColors.subIcon),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 15),
                // 2. キャラクター名 (濃いピンクのハイライト)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 25, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  child: Text(
                    character.name, // ★ キャラクター名を表示
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      color: Colors.white, // 白い文字色
                      fontFamily: 'Noto Sans JP',
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // 3. 説明タグのコンテナ
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 7),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 236, 92, 140)
                        .withOpacity(0.8), // タグの背景色を調整
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Wrap(
                    spacing: 7.0,
                    runSpacing: 4.0,
                    children: character.description_tags
                        .map((tag) => Text(
                              tag,
                              style: const TextStyle(
                                color: AppColors.forthBackground,
                                fontSize: 16,
                                fontFamily: 'Noto Sans JP',
                              ),
                            ))
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
