import 'dart:async';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:saving_girlfriend/models/comment_model.dart';
import 'package:saving_girlfriend/constants/assets.dart'; // ★★★ この行を追加 ★★★

// ダミーの視聴者情報を管理するためのシンプルなクラス
class _FakeViewer {
  final String name;
  final String iconAsset;
  _FakeViewer({required this.name, required this.iconAsset});
}

// 話題の種類を定義
enum TalkTopic {
  Greeting, // 挨拶
  Study,    // 勉強
  DailyLife,      // 今日の出来事
  SchoolLife,     // 学校の話
  Questions,      // みんなへの質問
}

// 画面の状態を定義するクラス
class HomeScreenState {
  final List<Comment> comments;
  final int viewers;
  final TalkTopic currentTopic;
  final String characterDialogue;

  HomeScreenState({
    this.comments = const [],
    this.viewers = 0,
    this.currentTopic = TalkTopic.Greeting,
    this.characterDialogue = 'みんな、来てくれてありがとう！',
  });

  HomeScreenState copyWith({
    List<Comment>? comments,
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
  // ★★★↓ キーワードと定型文の対応リストを新しく作成 ↓★★★
  final Map<String, String> _predefinedSuperChatResponses = {
    '髪カット代': '普通の女性は美容院代は1000円じゃ足りないんだよ？',
    'thanks2': 'え、いいの！？ありがとう！大切に使うね！',
    'happy': '応援ありがとう！もっと頑張れるよ！',
    'love': 'スパチャだ！本当にありがとう！大好き！',
    // ここにテストしたいキーワードとセリフを自由に追加できます
  };

  // ★★★↓ ダミーの視聴者リストを修正 ↓★★★
  final List<_FakeViewer> _fakeViewers = [
    // --- 画像アイコンの人 ---
    _FakeViewer(name: 'ドラえもん', iconAsset: AppAssets.iconUser2),
    _FakeViewer(name: '出木杉', iconAsset:  AppAssets.iconUser3),
    _FakeViewer(name: 'たけし', iconAsset:  AppAssets.iconUser4),
    _FakeViewer(name: 'のびた', iconAsset:  AppAssets.iconUser5),
    _FakeViewer(name: 'スネ夫', iconAsset:  AppAssets.iconUser6),
    _FakeViewer(name: 'しずか', iconAsset:  AppAssets.iconUser7),
    // --- 頭文字アイコンの人 ---
    _FakeViewer(name: 'たらちゃん', iconAsset: ''), // ← 画像パスを空にする
    _FakeViewer(name: 'カツオ', iconAsset: ''), // ← 画像パスを空にする
    _FakeViewer(name: '波平', iconAsset: ''),
    _FakeViewer(name: 'サザエ', iconAsset: ''),
    _FakeViewer(name: 'ふぐた', iconAsset: ''),
  ];

  final Map<TalkTopic, List<String>> _dialogues = {
    TalkTopic.Greeting: ['みんな、来てくれてありがとう！', 'こんにちは！', '今日も一日がんばろうね！', 'わ！たくさん来てくれてる！ありがとう！', 'みんなのコメント、ちゃんと見てるからねー！'],
    TalkTopic.Study: [
      'よし、勉強の時間だ！',
      'むずかしいな…',
      'この問題、わかる人いる？', '集中、集中…！', 'やった、1ページ終わった!えらい？'
    ],
    TalkTopic.DailyLife: [
      'そういえば今日ね、面白いことがあって！',
      '帰りにクレープ食べたんだ、すごく美味しかった～',
      '最近、新しい曲をよく聴いてるんだよね。',
      '昨日見た夢の話、していい？（笑）',
    ],
    TalkTopic.SchoolLife: [
      '明日のテスト、全然勉強してないや…どうしよう…',
      '今日の体育、めっちゃ疲れた～！でも楽しかったな。',
      'クラスの〇〇くんがね、すごく面白いの！',
      '放課後、友達とカフェでおしゃべりしてきたよ。',
    ],
    TalkTopic.Questions: [
      'みんなは週末なにして過ごすのー？',
      'おすすめのアニメとか映画があったら教えてほしいな！',
      'みんなは甘いものとしょっぱいもの、どっちが好き？',
      'もし一日だけ魔法が使えたら、何してみたい？',
    ],
  };
  final Map<TalkTopic, List<String>> _topicComments = {
    TalkTopic.Greeting: ['こんにちはー', '元気だよ！', 'わこつです！', '初見です！', 'おお！', 'かわいい', 'えいえいおー！', '見てるよー'],
    TalkTopic.Study: ['がんばれ！', 'えらい！', '俺も勉強しなきゃ…', 'どこが分からない？', '集中えらい', '終わったら休憩しなよ', 'えらい！！！', 'よしよし', '一緒にがんばろう！'],
    TalkTopic.DailyLife: ['なになに？', 'クレープいいなー！', '詳しく！', 'どんな曲？', '夢の話wkwk'],
    TalkTopic.SchoolLife: ['テスト勉強ファイト！', 'おつかれー！', '青春だねぇ', 'わかる', '徹夜だ！'],
    TalkTopic.Questions: ['今週末はゲームかな', '今期は〇〇が面白いよ！', '断然しょっぱい派！', '空を飛びたい！', '宿題を終わらせるw'],
  };
  Timer? _commentTimer;
  Timer? _topicTimer;
  Timer? _dialogueTimer;
  Timer? _superChatDialogueTimer;

  // ★★★ addSuperChatメソッドを修正 ★★★
  void addSuperChat(int amount, String comment) {
    final newSuperChat = SuperChat(
      userName: 'あなた',
      iconAsset: AppAssets.iconPlayer,
      text: comment,
      amount: amount,
    );
    _addComment(newSuperChat);

    // ★ 入力されたキーワードで、定型文を返すメソッドを呼び出す
    _showPredefinedResponse(comment);
  }

  // ★★★↓ 定型文を返すためのメソッドを新しく追加 ↓★★★
  void _showPredefinedResponse(String keyword) {
    // 1. 入力されたキーワードが、定型文リストのキーに存在するかチェック
    if (_predefinedSuperChatResponses.containsKey(keyword)) {
      // 2. もし存在すれば、対応するセリフを取得
      final response = _predefinedSuperChatResponses[keyword]!;

      // 3. 通常のセリフ更新を一時停止
      _dialogueTimer?.cancel();
      _superChatDialogueTimer?.cancel();

      // 4. 対応するセリフを表示
      state = state.copyWith(characterDialogue: response);

      // 5. 30秒後に通常のセリフ更新を再開する
      _superChatDialogueTimer = Timer(const Duration(seconds: 30), () {
        _startDialogueTimer();
      });
    }
    // ★ キーワードが存在しない場合は、何もしない
  }

  @override
  HomeScreenState build() {
    final initialState = HomeScreenState(viewers: Random().nextInt(50) + 10);
    Future.microtask(() {
      _startTimers();
      ref.onDispose(() {
        _commentTimer?.cancel();
        _topicTimer?.cancel();
        _dialogueTimer?.cancel();
        _superChatDialogueTimer?.cancel();
      });
    });
    return initialState;
  }

  void _updateCommentsAndViewers() {
    final currentCommentsList = _topicComments[state.currentTopic]!;
    final randomCommentText = currentCommentsList[Random().nextInt(currentCommentsList.length)];
    final randomViewer = _fakeViewers[Random().nextInt(_fakeViewers.length)];
    final newComment = NormalComment(
      userName: randomViewer.name,
      iconAsset: randomViewer.iconAsset,
      text: randomCommentText,
    );
    _addComment(newComment);

    final currentViewers = state.viewers;
    final change = Random().nextInt(5) - 2;
    state = state.copyWith(viewers: (currentViewers + change).clamp(5, 100));
  }

  void _addComment(Comment newComment) {
    final currentComments = List<Comment>.from(state.comments);
    currentComments.insert(0, newComment);
    if (currentComments.length > 8) {
      currentComments.removeLast();
    }
    state = state.copyWith(comments: currentComments);
  }

  void _startTimers() {
    _topicTimer = Timer.periodic(const Duration(seconds: 20), (timer) => _changeTopic());
    _startDialogueTimer();
    _scheduleNextComment();
  }

  void _startDialogueTimer() {
    _dialogueTimer?.cancel();
    _dialogueTimer = Timer.periodic(const Duration(seconds: 8), (timer) => _changeDialogue());
  }

  // ★★★ _changeTopicメソッドを修正 ★★★
  void _changeTopic() {
    // 話題が変わったら、感謝セリフのタイマーも止める
    _superChatDialogueTimer?.cancel();

    final currentTopic = state.currentTopic;
    final availableTopics = TalkTopic.values.where((topic) => topic != currentTopic).toList();
    final newTopic = availableTopics[Random().nextInt(availableTopics.length)];
    final initialDialogue = _dialogues[newTopic]![0];
    state = state.copyWith(currentTopic: newTopic, characterDialogue: initialDialogue);

    _startDialogueTimer();
  }

  void _changeDialogue() {
    final dialogueOptions = _dialogues[state.currentTopic]!;
    if (dialogueOptions.length > 1) {
      final newDialogue = dialogueOptions[Random().nextInt(dialogueOptions.length - 1) + 1];
      state = state.copyWith(characterDialogue: newDialogue);
    }
  }

  void _scheduleNextComment() {
    final viewers = state.viewers;
    double baseDelay = 8.0 - (viewers / 100.0) * 7.0;
    int delayMilliseconds = ((baseDelay).clamp(1.0, 8.0) * 1000).toInt();
    _commentTimer = Timer(Duration(milliseconds: delayMilliseconds), () {
      _updateCommentsAndViewers();
      _scheduleNextComment();
    });
  }
}

final homeScreenProvider = NotifierProvider<HomeScreenNotifier, HomeScreenState>(HomeScreenNotifier.new);