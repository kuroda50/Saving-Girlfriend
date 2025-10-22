import 'package:saving_girlfriend/models/episode.dart';

// キャラクターの基本情報を保持するクラス
class StoryCharacter {
  final String id; // キャラクターの一意なID
  final String name; // キャラクター名
  final String assetPath; // キャラクター画像のパス

  const StoryCharacter({
    required this.id,
    required this.name,
    required this.assetPath,
  });
}

// キャラクターのストーリー全体を保持するクラス
class Story {
  final String characterId; // 対応するキャラクターのID
  final List<Episode> episodes; // そのキャラクターのエピソードリスト
  final List<List<String>> dialogue; // そのキャラクターのセリフデータ

  const Story({
    required this.characterId,
    required this.episodes,
    required this.dialogue,
  });
}
