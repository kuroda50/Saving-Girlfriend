import 'dart:async';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 画面の状態を定義するクラス
class HomeScreenState {
  final List<String> comments;
  final int viewers;

  HomeScreenState({
    this.comments = const [],
    this.viewers = 0,
  });

  // ★ カンマを修正
  HomeScreenState copyWith({List<String>? comments, int? viewers}) {
    return HomeScreenState(
      comments: comments ?? this.comments,
      viewers: viewers ?? this.viewers,
    );
  }
}

// 状態とロジックを管理するNotifierクラス
class HomeScreenNotifier extends Notifier<HomeScreenState> {
  final _presetComments = [
    'かわいい！', '草', 'www', 'すごい！', '888888',
    'なるほど', '初見です', 'すき', '天才か？',
    '尊い', '最高', 'いいね！', 'がんばれー', 'ファイト！',
    'ワイは応援してるで', 'ナイス！','wwwwww', 'かわいすぎる', '天使', '癒される',
    'あ','めっちゃすげ～','ワイは明日も残業やで','!?','さすがやねw','すずなりちゃん大好き',
    'あつ～','うますぎ','いいねいいね','すごいなぁ','ええやん！',
  ];
  Timer? _timer;

  @override
  HomeScreenState build() {
    // ★ 2つあったbuildメソッドを1つに統合
    // 最初にランダムな視聴者数を設定
    final initialState = HomeScreenState(viewers: Random().nextInt(50) + 10);

    // 最初のコメントを予約する
    _scheduleNextComment();

    // 画面が閉じられたときにタイマーを止める
    ref.onDispose(() {
      _timer?.cancel();
    });

    return initialState;
  }

  // ランダムな時間で次のコメントを予約するメソッド
  void _scheduleNextComment() {
    // 1秒から5秒までのランダムな秒数を生成
    final randomSeconds = Random().nextInt(5) + 1;

    _timer = Timer(Duration(seconds: randomSeconds), () {
      // コメントを追加
      final randomComment = _presetComments[Random().nextInt(_presetComments.length)];
      _addComment(randomComment);

      // 視聴者数を変動させる
      final currentViewers = state.viewers;
      final change = Random().nextInt(5) - 2; // -2人 〜 +2人
      state = state.copyWith(viewers: (currentViewers + change).clamp(5, 100));
      
      // 次のコメントを予約
      _scheduleNextComment();
    });
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