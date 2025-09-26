import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:saving_girlfriend/constants/assets.dart';
import 'package:saving_girlfriend/constants/color.dart';
import 'package:saving_girlfriend/models/episode.dart';
import 'package:saving_girlfriend/providers/likeability_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EpisodeScreen extends ConsumerStatefulWidget {
  const EpisodeScreen({super.key});

  @override
  ConsumerState<EpisodeScreen> createState() => _EpisodeScreenState();
}

class _EpisodeScreenState extends ConsumerState<EpisodeScreen> {
  // --- エピソードデータのリスト ---
  final List<Episode> _baseEpisodes = [
    Episode(number: 0, title: '出会い', requiredLikeability: 0),
    Episode(number: 1, title: '初めての会話', requiredLikeability: 10),
    Episode(number: 2, title: '公園の散歩', requiredLikeability: 20),
    Episode(number: 3, title: '好きな食べ物', requiredLikeability: 30),
    Episode(number: 4, title: '休日の過ごし方', requiredLikeability: 40),
    Episode(number: 5, title: '趣味の話', requiredLikeability: 50),
    Episode(number: 6, title: '小さなプレゼント', requiredLikeability: 60),
    Episode(number: 7, title: '雨の日の思い出', requiredLikeability: 70),
    Episode(number: 8, title: '喧嘩と仲直り', requiredLikeability: 80),
    Episode(number: 9, title: '伝えたい言葉', requiredLikeability: 90),
    Episode(number: 10, title: 'そして未来へ', requiredLikeability: 100),
  ];

  // ScrollControllerの準備
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final likeabilityAsync = ref.watch(likeabilityProvider);
    return Scaffold(
      backgroundColor: AppColors.forthBackground,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(20.0),
        child: AppBar(
          backgroundColor: AppColors.secondary,
          elevation: 0,
        ),
      ),
      body: Column(
        children: [
          Container(
            decoration: const BoxDecoration(
              color: AppColors.mainBackground,
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 4.0,
                  offset: Offset(0, 2), // 下方向に影を伸ばす
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
              child: likeabilityAsync.when(
            data: (likeability) {
              final episodes = _baseEpisodes.map((episode) {
                final bool isLocked = likeability < episode.requiredLikeability;
                return Episode(
                  number: episode.number,
                  title: isLocked ? '？？？' : episode.title, // ロック中はタイトルを隠す
                  requiredLikeability: episode.requiredLikeability,
                  isLocked: isLocked,
                );
              }).toList();
              return Scrollbar(
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
                        context.push("/story", extra: episode.number);
                        print('Play episode ${episode.number}');
                      },
                      onInfo: () {
                        print('Info for episode ${episode.number}');
                      },
                    );
                  },
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                    vertical: 12.0, horizontal: 20.0),
                margin: const EdgeInsets.symmetric(horizontal: 24.0),
                decoration: BoxDecoration(
                  color: AppColors.errorBackground, // 背景色を指定
                  borderRadius: BorderRadius.circular(12.0), // 角を丸くする
                ),
                child: Text(
                  'エラーが発生しました:\n$err',
                  style: const TextStyle(
                    color: AppColors.error, // テキストの色を指定
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center, // 文字を中央揃えに
                ),
              ),
            ),
          )),
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
                  backgroundColor: AppColors.errorBackground,
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
              color: AppColors.mainLogo,
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
                !episode.isLocked
                    ? GestureDetector(
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
                      )
                    : const SizedBox.shrink(),
                const SizedBox(width: 8),
                !episode.isLocked
                    ? GestureDetector(
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
                      )
                    : const SizedBox.shrink(),
              ],
            ),
          ),

          // --- 2. アイコン ---
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
