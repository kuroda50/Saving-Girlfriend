import 'dart:async';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ★ 話題の種類を定義
enum TalkTopic {
  Greeting, // 挨拶
  Study,    // 勉強
  Game,     // ゲーム
}

// 画面の状態を定義するクラス
class HomeScreenState {
  final List<String> comments;
  final int viewers;
  final TalkTopic currentTopic; // ★ 現在の話題
  final String characterDialogue; // ★ キャラクターのセリフ

  HomeScreenState({
    this.comments = const [],
    this.viewers = 0,
    this.currentTopic = TalkTopic.Greeting,
    this.characterDialogue = 'みんな、来てくれてありがとう！',
  });

  HomeScreenState copyWith({
    List<String>? comments,
    int? viewers,
    TalkTopic? currentTopic,
    String? characterDialogue,
  }) {
    return HomeScreenState(
      comments: comments ?? this.comments,
      viewers: viewers ?? this.viewers,
      currentTopic: currentTopic ?? this.currentTopic,
      characterDialogue: characterDialogue ?? this.characterDialogue,
    );
  }
}

// 状態とロジックを管理するNotifierクラス
class HomeScreenNotifier extends Notifier<HomeScreenState> {
  // ★ 話題ごとのセリフリスト
  final Map<TalkTopic, List<String>> _dialogues = {
  TalkTopic.Greeting: [
    'みんな、来てくれてありがとう！', // ★これが最初のセリフ
    'こんにちは！',
    '今日も一日がんばろうね！'
  ],
  TalkTopic.Study: [
    'よし、勉強の時間だ！', // ★これが最初のセリフ
    'むずかしいな…',
    'この問題、わかる人いる？'
  ],
  TalkTopic.Game: [
    'これからゲーム配信するよ！', // ★これが最初のセリフ
    'やった、クリア！',
    'このボス強い…！'
  ],
};

  // ★ 話題ごとのコメントリスト
  final Map<TalkTopic, List<String>> _topicComments = {
    TalkTopic.Greeting: ['こんにちはー', '元気だよ！', 'わこつです！','初見です！', ],
    TalkTopic.Study: ['がんばれ！', 'えらい！', '俺も勉強しなきゃ…'],
    TalkTopic.Game: ['ないすー！', 'おおお！', 'うますぎw','神プレイ！'],
  };

  Timer? _eventTimer;
  int _ticksInTopic = 0; // 同じ話題が続いてからのカウント

  @override
  HomeScreenState build() {
    // 最初の話題とセリフを設定
    final initialTopic = TalkTopic.Greeting;
    final initialDialogue = _dialogues[initialTopic]![0];
    final initialState = HomeScreenState(
      viewers: Random().nextInt(50) + 10,
      currentTopic: initialTopic,
      characterDialogue: initialDialogue,
    );
    
    _scheduleNextEvent(); // ★統合されたタイマーを開始

    ref.onDispose(() {
      _eventTimer?.cancel();
    });

    return initialState;
  }

  // ★すべてのイベントを管理する統合タイマー
  void _scheduleNextEvent() {
    // 2〜5秒のランダムな間隔で次のイベントを予約
    final randomSeconds = Random().nextInt(6) + 2;
    _eventTimer = Timer(Duration(seconds: randomSeconds), () {

      _ticksInTopic++;

      // 5回に1回（約20秒ごと）の確率で話題を変える
      if (_ticksInTopic >= 5) {
        _ticksInTopic = 0; // カウントをリセット
        _changeTopic();
      } else {
        // それ以外の時は、同じ話題の中でセリフを変える
        _changeDialogue();
      }

      // コメントと視聴者数は毎回更新する
      _updateCommentsAndViewers();

      // 次のイベントを予約
      _scheduleNextEvent();
    });
  }

  void _changeTopic() {
  // 1. 現在の話題を取得
  final currentTopic = state.currentTopic;

  // 2. 現在の話題を除いた、選択肢のリストを作成
  final availableTopics = TalkTopic.values.where((topic) => topic != currentTopic).toList();

  // 3. 選択肢の中からランダムに次の話題を選ぶ
  final newTopic = availableTopics[Random().nextInt(availableTopics.length)];

  // 4. 新しい話題の最初のセリフを設定
  final initialDialogue = _dialogues[newTopic]![0];
  state = state.copyWith(currentTopic: newTopic, characterDialogue: initialDialogue);
  }

  void _changeDialogue() {
    final dialogueOptions = _dialogues[state.currentTopic]!;
    final newDialogue = dialogueOptions[Random().nextInt(dialogueOptions.length)];
    state = state.copyWith(characterDialogue: newDialogue);
  }

  void _updateCommentsAndViewers() {
    final currentCommentsList = _topicComments[state.currentTopic]!;
    final randomComment = currentCommentsList[Random().nextInt(currentCommentsList.length)];
    _addComment(randomComment);

    final currentViewers = state.viewers;
    final change = Random().nextInt(5) - 2;
    state = state.copyWith(viewers: (currentViewers + change).clamp(5, 100));
  }

  void _addComment(String newComment) {
    final currentComments = List<String>.from(state.comments);
    currentComments.insert(0, newComment);
    if (currentComments.length > 8) {
      currentComments.removeLast();
    }
    state = state.copyWith(comments: currentComments);
  }
}

// Providerの定義
final homeScreenProvider =
    NotifierProvider<HomeScreenNotifier, HomeScreenState>(() {
  return HomeScreenNotifier();
});