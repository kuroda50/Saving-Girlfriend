import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:saving_girlfriend/constants/assets.dart';
import 'package:saving_girlfriend/models/episode.dart';
import 'package:saving_girlfriend/models/story_model.dart';
import 'package:saving_girlfriend/stories/suzunari_oto.dart';

/// --- キャラクター定義 ---
const suzunariOtoCharacter = StoryCharacter(
  id: 'suzunari_oto',
  name: '鈴鳴 音',
  assetPath: AppAssets.characterSuzunari,
);

/// --- ストーリー定義 ---
final suzunariOtoStory = Story(
  characterId: suzunariOtoCharacter.id,
  episodes: [
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
  ],
  dialogue: suzunariOtoDialogue,
);

/// --- リポジトリ ---
class StoryRepository {
  // すべてのキャラクターのリスト
  final List<StoryCharacter> allCharacters = [
    suzunariOtoCharacter,
    // 新しいキャラクターはここに追加
  ];

  // すべてのストーリーのリスト
  final List<Story> allStories = [
    suzunariOtoStory,
    // 新しいストーリーはここに追加
  ];

  // IDからキャラクターを取得する
  StoryCharacter? getCharacterById(String id) {
    try {
      return allCharacters.firstWhere((character) => character.id == id);
    } catch (e) {
      return null;
    }
  }

  // キャラクターIDからストーリーを取得する
  Story? getStoryByCharacterId(String characterId) {
    try {
      return allStories.firstWhere((story) => story.characterId == characterId);
    } catch (e) {
      return null;
    }
  }
}

/// --- プロバイダー ---

// StoryRepositoryのインスタンスを提供するプロバイダー
final storyRepositoryProvider = Provider<StoryRepository>((ref) {
  return StoryRepository();
});
