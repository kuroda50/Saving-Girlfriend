import 'package:go_router/go_router.dart';
/* ストーリー選択画面 */

import 'package:flutter/material.dart';
import 'package:saving_girlfriend/constants/assets.dart';
import 'package:saving_girlfriend/constants/color.dart';
import 'package:saving_girlfriend/services/local_storage_service.dart';

// --- データモデル ---
// 各エピソードのデータを保持するクラス
class Episode {
  final int number;
  final String title;
  final bool isLocked;
  final bool showUnlockedIcon; // クリア済みの印

  Episode({
    required this.number,
    required this.title,
    this.isLocked = false,
    this.showUnlockedIcon = false, // デフォルト値
  });
}

class EpisodeScreen extends StatefulWidget {
  const EpisodeScreen({super.key});

  @override
  State<EpisodeScreen> createState() => _EpisodeScreenState();
}

class _EpisodeScreenState extends State<EpisodeScreen> {
  // --- UIの色の定義 ---
  static const Color lightPink = Color(0xFFFEDDE4);
  static const Color darkPinkText = Color(0xFFE5749A);
  static const Color playButtonColor = Color(0xFFF882A3);
  static const Color backgroundColor = Color(0xFFE6F0F5);

  final LocalStorageService _localStorageService = LocalStorageService();

  Future<int> _loadLikeability(String characterId) async {
    return await _localStorageService.getLikeability(characterId);
  }

  // --- エピソードデータのリスト ---
  final List<Episode> episodes = [
    Episode(number: 0, title: '出会い', isLocked: false, showUnlockedIcon: true),
    Episode(number: 1, title: '？？？', isLocked: true),
    Episode(number: 2, title: '？？？', isLocked: true),
    Episode(number: 3, title: '？？？', isLocked: true),
    Episode(number: 4, title: '？？？', isLocked: true),
    Episode(number: 5, title: '？？？', isLocked: true),
    Episode(number: 6, title: '？？？', isLocked: true),
    Episode(number: 7, title: '？？？', isLocked: true),
    Episode(number: 8, title: '？？？', isLocked: true),
    Episode(number: 9, title: '？？？', isLocked: true),
    Episode(number: 10, title: '？？？', isLocked: true),
  ];

  // ScrollControllerの準備
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    final likeability = _loadLikeability("a");
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(20.0),
        child: AppBar(
          backgroundColor: AppColors.secondary,
          elevation: 0,
        ),
      ),
      body: Column(
        children: [
          // ★★★ ヘッダーをContainerで囲み、影を付けます ★★★
          Container(
            decoration: const BoxDecoration(
              // ヘッダー部分の背景色を白に変更
              color: AppColors.mainBackground,
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 4.0,
                  offset: const Offset(0, 2), // 下方向に影を伸ばす
                ),
              ],
            ),
            // 元のPaddingはContainerの子にします
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: _buildCharacterHeader(),
            ),
          ),
          Expanded(
            child: Scrollbar(
              controller: _scrollController,
              thumbVisibility: true,
              thickness: 8.0,
              radius: const Radius.circular(10),
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.only(
                    left: 16.0, right: 16.0, top: 10.0, bottom: 10.0),
                itemCount: episodes.length,
                itemBuilder: (BuildContext context, int index) {
                  final episode = episodes[index];
                  return EpisodeListItem(
                    episode: episode,
                    onPlay: () {
                      context.push("/select_story/story");
                      print('Play episode ${episode.number}');
                    },
                    onInfo: () {
                      print('Info for episode ${episode.number}');
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCharacterHeader() {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 100,
            height: 100,
            child: Image.asset(
              AppAssets.characterSuzunari,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const CircleAvatar(
                  radius: 40,
                  backgroundColor: lightPink,
                  child:
                      Icon(Icons.person, color: AppColors.secondary, size: 50),
                );
              },
            ),
          ),
          const SizedBox(width: 16),
          const Text(
            '鈴鳴 音',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: darkPinkText,
            ),
          ),
        ],
      ),
    );
  }
}

// --- 再利用可能なエピソード行ウィジェット（微調整版） ---
class EpisodeListItem extends StatelessWidget {
  final Episode episode;
  final VoidCallback onPlay;
  final VoidCallback onInfo;
  static const Color playButtonColor = Color(0xFFF882A3);
  static const Color listItemColor = Color(0xFFFFFBEA);

  const EpisodeListItem({
    super.key,
    required this.episode,
    required this.onPlay,
    required this.onInfo,
  });

  @override
  Widget build(BuildContext context) {
    // isLockedの状態によって、アイコンの大きさを変える
    final double iconSize = episode.isLocked ? 45.0 : 55.0;

    return Padding(
      // アイコンがはみ出す分を考慮して、リストアイテム全体の左側に余白を作る
      padding: EdgeInsets.fromLTRB(iconSize / 2 + 6, 6.0, 16.0, 6.0),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // --- 1. 背景のカード ---
          Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
                color: listItemColor,
                borderRadius: BorderRadius.circular(30.0),
                border: Border.all(color: AppColors.border, width: 1.5),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.shadow,
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: Offset(0, 2),
                  )
                ]),
            child: Row(
              children: [
                // アイコンが重なる分のスペースを確保
                SizedBox(width: iconSize / 2 + 4),
                Text(
                  '${episode.number}話',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    episode.title,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.start,
                  ),
                ),
                const SizedBox(width: 16),
                GestureDetector(
                  onTap: onPlay,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      color: playButtonColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.play_arrow,
                        color: AppColors.mainIcon, size: 24),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: onInfo,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: playButtonColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.info_outline,
                        color: AppColors.mainIcon, size: 20),
                  ),
                ),
              ],
            ),
          ),

          // --- 2. アイコン ---
          if (episode.isLocked || episode.showUnlockedIcon)
            Positioned(
              left: -(iconSize / 2),
              top: 1.0, // ← ここを調整しました
              child: SizedBox(
                width: iconSize,
                height: iconSize,
                child: Image.asset(
                  episode.isLocked
                      ? AppAssets.iconLockClosed
                      : AppAssets.iconLockOpen,
                  fit: BoxFit.contain,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
