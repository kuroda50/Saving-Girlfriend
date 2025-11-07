import 'package:flutter/material.dart';
import 'package:saving_girlfriend/common/constants/assets.dart';
import 'package:saving_girlfriend/common/constants/color.dart';
import 'package:saving_girlfriend/features/story/models/episode.dart';

/// エピソードをグリッド表示するための可愛いカード型ウィジェット
class EpisodeCardItem extends StatelessWidget {
  final Episode episode;
  final VoidCallback onPlay;

  static const Color playButtonColor = Color(0xFFF882A3);
  static const Color listItemColor = Color(0xFFFFFBEA);
  // ★ グラデーションの開始色
  static final Color gradientStart = playButtonColor.withOpacity(0.1);
  // ★ グラデーションの終了色
  static final Color gradientEnd = playButtonColor.withOpacity(0.4);
  // ★ 星のいろ
  static const Color starColor = Colors.amber;

  const EpisodeCardItem({
    super.key,
    required this.episode,
    required this.onPlay,
  });

  @override
  Widget build(BuildContext context) {
    // ★ 角丸を少し大きく
    const double cardBorderRadius = 24.0;

    return GestureDetector(
      onTap: episode.isLocked ? null : onPlay,
      child: Opacity(
        opacity: episode.isLocked ? 0.6 : 1.0,
        child: Container(
          decoration: BoxDecoration(
            color: listItemColor,
            borderRadius: BorderRadius.circular(cardBorderRadius),
            border: Border.all(color: AppColors.border, width: 1.5),
            boxShadow: const [
              BoxShadow(
                color: AppColors.shadow,
                spreadRadius: 1,
                blurRadius: 3,
                offset: Offset(0, 2),
              )
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(cardBorderRadius),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // --- 1. サムネイル画像エリア ---
                _buildThumbnailSection(context),
                // --- 2. テキストエリア ---
                _buildTextSection(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 1. サムネイル画像エリア（カード上部）
  Widget _buildThumbnailSection(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.2,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // --- ★ サムネイル背景 (グラデーションに変更) ---
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: episode.isLocked
                    ? [
                        AppColors.shadow.withOpacity(0.3),
                        AppColors.shadow.withOpacity(0.5)
                      ]
                    : [gradientStart, gradientEnd],
              ),
            ),
          ),

          // --- ★ キラキラ星（アンロック時のみ）---
          if (!episode.isLocked) ...[
            const Positioned(
              top: 15,
              right: 20,
              child: Icon(Icons.star, color: starColor, size: 16),
            ),
            const Positioned(
              bottom: 30,
              left: 15,
              child: Icon(Icons.star, color: starColor, size: 20),
            ),
            const Positioned(
              bottom: 50,
              right: 15,
              child: Icon(Icons.star_border, color: starColor, size: 18),
            ),
          ],

          // 中央のアイコン
          Center(
            child: Image.asset(
              episode.isLocked
                  ? AppAssets.iconLockClosed
                  : AppAssets.iconLockOpen,
              width: 55, // 少し小さく
              height: 55,
              color: episode.isLocked
                  ? AppColors.mainIcon.withOpacity(0.7)
                  : playButtonColor.withOpacity(0.9),
            ),
          ),

          // エピソード番号 (リボン風)
          Positioned(
            top: 0,
            left: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: playButtonColor.withOpacity(0.9),
                borderRadius: const BorderRadius.only(
                  bottomRight: Radius.circular(12.0),
                ),
              ),
              child: Text(
                '${episode.number}話',
                style: const TextStyle(
                  color: AppColors.mainIcon,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // --- ★ 再生ボタン (ハートに変更) ---
          if (!episode.isLocked)
            Positioned(
              bottom: -18,
              right: 12,
              child: Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                    color: playButtonColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadow,
                        blurRadius: 4.0,
                        offset: Offset(0, 2),
                      ),
                    ]),
                child: const Icon(
                  Icons.favorite, // ★ ハートアイコンに変更
                  color: AppColors.mainIcon,
                  size: 24, // アイコンサイズ調整
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// 2. テキストエリア（カード下部）
  Widget _buildTextSection(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10.0, 16.0, 10.0, 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // 再生ボタンがはみ出す分のスペース
            if (!episode.isLocked) const SizedBox(height: 8),

            // --- ★ タイトル (可愛い枠を追加) ---
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5), // 半透明の白
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(
                  color: playButtonColor.withOpacity(0.5), // ピンクの枠線
                  width: 1.5,
                ),
              ),
              child: Text(
                episode.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.mainLogo,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center, // 中央揃え
              ),
            ),
          ],
        ),
      ),
    );
  }
}
