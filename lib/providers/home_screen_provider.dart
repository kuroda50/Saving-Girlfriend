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
    'わ！たくさん来てくれてる！ありがとう！',
    'みんなのコメント、ちゃんと見てるからねー！',
  ],
  TalkTopic.Study: [
    'よし、勉強の時間だ！', // ★これが最初のセリフ
    'むずかしいな…',
    'この問題、わかる人いる？'
    '集中、集中…！',
    'やった、1ページ終わった!えらい？',
  ],
  TalkTopic.Game: [
    'これからゲーム配信するよ！', // ★これが最初のセリフ
    'やった、クリア！',
    'このボス強い…！',
    'みんなの応援のおかげでクリアできた！ありがとう！',
    '次はなんのゲームやろうかな？',
  ],
};

  // ★ 話題ごとのコメントリスト
  final Map<TalkTopic, List<String>> _topicComments = {
    TalkTopic.Greeting: ['こんにちはー', '元気だよ！', 'わこつです！','初見です！',
     'おお！', 'かわいい', 'えいえいおー！', '見てるよー'],
    TalkTopic.Study: ['がんばれ！', 'えらい！', '俺も勉強しなきゃ…',
    'どこが分からない？','集中えらい', '終わったら休憩しなよ', 'えらい！！！', 'よしよし','一緒にがんばろう！'],
    TalkTopic.Game: ['ないすー！', 'おおお！', 'うますぎw','神プレイ！','がんばれー', '次のゲームも楽しみ',
    '応援してるよ！', 'すごい！', '天才かよ！'
    ],
  };

  Timer? _commentTimer;
  Timer? _topicTimer;
  Timer? _dialogueTimer;

  @override
  HomeScreenState build() {
    final initialState = HomeScreenState(viewers: Random().nextInt(50) + 10);
    // _startTimers();
    // ref.onDispose(() {
    //   _commentTimer?.cancel();
    //   _topicTimer?.cancel();
    //   _dialogueTimer?.cancel();
    // });
    // 副作用はbuild後に遅延実行
    Future.microtask(() {
      _startTimers();
      ref.onDispose(() {
        _commentTimer?.cancel();
        _topicTimer?.cancel();
        _dialogueTimer?.cancel();
      });
    });
    return initialState;
  }

  void _startTimers() {
    // ★ 話題転換タイマー (固定周期)
    _topicTimer = Timer.periodic(const Duration(seconds: 20), (timer) => _changeTopic());

    // ★ セリフ変更タイマー (固定周期)
    _startDialogueTimer();

    // ★ コメント専用タイマーを開始（可変周期）
    _scheduleNextComment();
  }

  // ★ セリフタイマーを開始する部分を独立させる
  void _startDialogueTimer() {
    _dialogueTimer?.cancel(); // 既存のタイマーがあれば止める
    _dialogueTimer = Timer.periodic(const Duration(seconds: 8), (timer) => _changeDialogue());
  }

  void _changeTopic() {
    final currentTopic = state.currentTopic;
    final availableTopics = TalkTopic.values.where((topic) => topic != currentTopic).toList();
    final newTopic = availableTopics[Random().nextInt(availableTopics.length)];
    final initialDialogue = _dialogues[newTopic]![0];
    state = state.copyWith(currentTopic: newTopic, characterDialogue: initialDialogue);

    // ★★★ 話題が変わったら、セリフタイマーをリセットして仕切り直す ★★★
    _startDialogueTimer();
  }

  void _changeDialogue() {
    final dialogueOptions = _dialogues[state.currentTopic]!;
    if (dialogueOptions.length > 1) {
      final newDialogue = dialogueOptions[Random().nextInt(dialogueOptions.length - 1) + 1];
      state = state.copyWith(characterDialogue: newDialogue);
    }
  }

  // ★ コメントと視聴者数を更新するタイマー（速度が可変）
  void _scheduleNextComment() {
    final viewers = state.viewers;
    // ... (視聴者数に応じた速度計算はそのまま)
    double baseDelay = 8.0 - (viewers / 100.0) * 7.0;
    // ...
    int delayMilliseconds = ((baseDelay).clamp(1.0, 8.0) * 1000).toInt();

    _commentTimer = Timer(Duration(milliseconds: delayMilliseconds), () {
      _updateCommentsAndViewers();
      _scheduleNextComment(); // 次のコメントを予約
    });
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

final homeScreenProvider =
    NotifierProvider<HomeScreenNotifier, HomeScreenState>(HomeScreenNotifier.new);