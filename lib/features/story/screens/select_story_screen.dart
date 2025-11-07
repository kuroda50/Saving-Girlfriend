import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:saving_girlfriend/app/providers/likeability_provider.dart';
import 'package:saving_girlfriend/common/constants/color.dart';
import 'package:saving_girlfriend/common/providers/current_girlfriend_provider.dart';
import 'package:saving_girlfriend/features/story/models/episode.dart';
import 'package:saving_girlfriend/features/story/models/story_model.dart';
import 'package:saving_girlfriend/features/story/repositories/story_repository.dart';
// ▼▼▼ インポートを追加 ▼▼▼
import 'package:saving_girlfriend/features/story/widgets/episode_card_item.dart';
import 'package:saving_girlfriend/features/story/widgets/story_character_header.dart';

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
        StoryCharacterHeader(character: widget.character),
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
                child: GridView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12.0,
                    mainAxisSpacing: 12.0,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: episodes.length,
                  itemBuilder: (BuildContext context, int index) {
                    final episode = episodes[index];
                    return EpisodeCardItem(
                      episode: episode,
                      onPlay: () {
                        context.push("/story", extra: episode.number);
                        print('Play episode ${episode.number}');
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
}
