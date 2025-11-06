import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:saving_girlfriend/common/constants/assets.dart';
import 'package:saving_girlfriend/features/story/data/suzunari_oto.dart';
import 'package:saving_girlfriend/features/story/models/episode.dart';
import 'package:saving_girlfriend/features/story/models/story_model.dart';

/// --- キャラクター定義 ---
const suzunariOtoCharacter = StoryCharacter(
  id: 'suzunari_oto',
  name: '鈴鳴 音',
  assetPath: AppAssets.characterSuzunari,
  notificationMessages: {
    0: [
      // 好感度0-9
      'おと「今何してますか？」',
      'おと「図書館で待ってます」',
      'おと「もしかして私のこと避けてます？」',
      'おと「先輩？元気ですか？」',
      'おと「返事くれないと怒りますよ」',
    ],
    10: [
      // 好感度10-19
      'おと「今日の授業、難しかったですね」',
      'おと「先輩に会いたいです」',
      'おと「今暇ですか？」',
      'おと「せんぱーい、何してます？」',
      'おと「未読スルーとかしてませんよね？」',
    ],
    30: [
      // 好感度30-49
      'おと「今度、一緒に映画見に行きませんか？」',
      'おと「先輩の声聞くと落ち着きます」',
      'おと「先輩に会いたいです」',
      'おと「連絡ください」',
    ],
    50: [
      // 好感度50-79
      'おと「先輩のこと、もっと知りたいです」',
      'おと「先輩といると、時間があっという間です」',
      'おと「先輩のこと、考えちゃいます」',
      'おと「先輩のこと、考えるとドキドキします」',
    ],
    80: [
      // 好感度80-100
      'おと「先輩、大好きです」',
      'おと「ずっと一緒にいましょうね」',
      'おと「先輩のこと、考えると胸がいっぱいになります」',
    ],
  },
);

final List<Episode> SuzunariOtoEpisodes = [
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

final suzunariOtoStory = Story(
  characterId: suzunariOtoCharacter.id,
  episodes: SuzunariOtoEpisodes, // 上で定義した変数を使用
  dialogue: suzunariOtoDialogue, // suzunari_oto.dart からインポートしたデータを使用
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
