import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:saving_girlfriend/app/providers/likeability_provider.dart';
import 'package:saving_girlfriend/common/constants/assets.dart';
import 'package:saving_girlfriend/common/constants/color.dart';
import 'package:saving_girlfriend/common/providers/current_girlfriend_provider.dart';
import 'package:saving_girlfriend/features/story/models/episode.dart';
import 'package:saving_girlfriend/features/story/models/story_model.dart';
import 'package:saving_girlfriend/features/story/repositories/story_repository.dart';

class EpisodeScreen extends ConsumerWidget {
  const EpisodeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentGirlfriendAsync = ref.watch(currentGirlfriendProvider);

    return Scaffold(
      backgroundColor: AppColors.forthBackground,
      body: currentGirlfriendAsync.when(
        data: (characterId) {
          if (characterId == null) {
            return const Center(child: Text('彼女が選択されていません。'));
          }

          final storyRepo = ref.read(storyRepositoryProvider);
          final character = storyRepo.getCharacterById(characterId);
          final story = storyRepo.getStoryByCharacterId(characterId);

          if (character == null || story == null) {
            return const Center(child: Text('ストーリーデータが見つかりません。'));
          }

          return _StoryView(character: character, story: story);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('エラー: $err')),
      ),
    );
  }
}

class _StoryView extends ConsumerStatefulWidget {
  final StoryCharacter character;
  final Story story;

  const _StoryView({required this.character, required this.story});

  @override
  ConsumerState<_StoryView> createState() => _StoryViewState();
}

class _StoryViewState extends ConsumerState<_StoryView> {
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

    return Column(
      children: [
        _buildCharacterHeader(widget.character),
        Expanded(
          child: likeabilityAsync.when(
            data: (likeability) {
              final episodes = widget.story.episodes.map((episode) {
                final bool isLocked = likeability < episode.requiredLikeability;
                return Episode(
                  number: episode.number,
                  title: isLocked ? '？？？' : episode.title,
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
            error: (err, stack) => Center(child: Text('好感度の読み込みエラー: $err')),
          ),
        ),
      ],
    );
  }

  Widget _buildCharacterHeader(StoryCharacter character) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.mainBackground,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 4.0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Padding(
          padding: const EdgeInsets.only(top: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 100,
                height: 100,
                child: Image.asset(
                  character.assetPath,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const CircleAvatar(
                      radius: 40,
                      backgroundColor: AppColors.errorBackground,
                      child: Icon(Icons.person,
                          color: AppColors.secondary, size: 50),
                    );
                  },
                ),
              ),
              const SizedBox(width: 16),
              Text(
                character.name,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.mainLogo,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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
    final double iconSize = episode.isLocked ? 45.0 : 55.0;

    return Padding(
      padding: EdgeInsets.fromLTRB(iconSize / 2 + 6, 6.0, 16.0, 6.0),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
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
          Positioned(
            left: -(iconSize / 2),
            top: 1.0,
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
