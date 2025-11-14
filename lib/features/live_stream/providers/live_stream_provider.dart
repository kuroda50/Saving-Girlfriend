// Dart imports:
import 'dart:async';
import 'dart:math'; // 視聴者数変動のために使用

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:saving_girlfriend/app/providers/likeability_provider.dart';
import 'package:saving_girlfriend/common/constants/assets.dart';
import 'package:saving_girlfriend/features/live_stream/data/scenario_data.dart';
// Project imports:
import 'package:saving_girlfriend/features/live_stream/models/comment_model.dart';

import 'package:saving_girlfriend/features/mission/models/mission.dart'
    as mission_model;
import 'package:saving_girlfriend/features/mission/providers/mission_provider.dart';

// ★★★ ScenarioEventType と ScenarioEvent は scenario_data.dart に移動 ★★★

// 画面の状態を定義するクラス
class LiveStreamState {
  // ( ... 変更なし ... )
  final List<Comment> comments;
  final int viewers;
  final String characterDialogue;

  LiveStreamState({
    this.comments = const [],
    this.viewers = 118, // 初期値（buildメソッドで上書きされます）
    this.characterDialogue = '...',
  });

  LiveStreamState copyWith({
    List<Comment>? comments,
    int? viewers,
    String? characterDialogue,
  }) {
    return LiveStreamState(
      comments: comments ?? this.comments,
      viewers: viewers ?? this.viewers,
      characterDialogue: characterDialogue ?? this.characterDialogue,
    );
  }
}

// 状態とロジックを管理するNotifierクラス
class LiveStreamNotifier extends Notifier<LiveStreamState> {
  // ( ... スパチャ関連の定義は変更なし ... )
  final Map<String, String> _predefinedSuperChatResponses = {
    '髪カット代': '普通の女性は美容院代は1000円じゃ足りないんだよ？',
    'thanks2': 'え、いいの！？ありがとう！大切に使うね！',
    'happy': '応援ありがとう！もっと頑張れるよ！',
    'love': 'スパチャだ！本当にありがとう！大好き！',
  };

  // ★★★ _viewerProfiles と _allScenarios の巨大な定義を削除 ★★★

  // ( ... タイマー関連の変数は変更なし ... )
  Timer? _scenarioTimer;
  Timer? _superChatDialogueTimer;
  int _currentSecond = 0;
  int _currentLikeabilityLevel = 1;

  // ★★★ addSuperChatメソッド（変更なし） ★★★
  void addSuperChat(int amount, String comment) {
    final newSuperChat = SuperChat(
      userName: 'あなた',
      iconAsset: AppAssets.iconPlayer,
      text: comment,
      amount: amount,
    );
    _addComment(newSuperChat);
    _showPredefinedResponse(comment);

    // スパチャをしたら、ミッションの進捗を更新する
    try {
      // ★ 修正点: 2回呼び出すように変更

      // 1. 「回数」ミッションの進捗を更新 (amount はデフォルトの 1)
      ref
          .read(missionNotifierProvider.notifier)
          .updateProgress(mission_model.MissionCondition.sendTribute);

      // 2. 「金額」ミッションの進捗を更新 (amount にスパチャ額を渡す)
      ref.read(missionNotifierProvider.notifier).updateProgress(
          mission_model.MissionCondition.sendTributeAmount, amount);
    } catch (e) {
      print('ミッション(sendTribute or sendTributeAmount)の更新に失敗: $e');
    }
  }

  // ★★★ _showPredefinedResponseメソッド（変更なし） ★★★
  void _showPredefinedResponse(String keyword) {
    if (_predefinedSuperChatResponses.containsKey(keyword)) {
      final response = _predefinedSuperChatResponses[keyword]!;
      _scenarioTimer?.cancel();
      _superChatDialogueTimer?.cancel();
      state = state.copyWith(characterDialogue: response);
      _superChatDialogueTimer = Timer(const Duration(seconds: 30), () {
        _startScenarioTimer();
      });
    }
  }

  // ★★★ Notifier の初期化処理（buildメソッド） ★★★
  @override
  LiveStreamState build() {
    // ★★★ _initializeAllScenarios() の呼び出しを削除 ★★★

    // ★ 好感度リスナー（変更なし）
    ref.listen(likeabilityProvider, (previous, next) {
      next.when(
        data: (likeability) {
          final newLevel = _calculateLevel(likeability as double);
          if (newLevel != _currentLikeabilityLevel) {
            _currentLikeabilityLevel = newLevel;
          }
        },
        loading: () {},
        error: (err, stack) {},
      );
    });

    // ★ マイクロタスク（変更なし）
    Future.microtask(() {
      final initialLikeability = ref.read(likeabilityProvider);
      _currentLikeabilityLevel = initialLikeability.when(
        data: (likeability) => _calculateLevel(likeability as double),
        loading: () => 1,
        error: (err, stack) => 1,
      );

      _startScenarioTimer();

      ref.onDispose(() {
        _scenarioTimer?.cancel();
        _superChatDialogueTimer?.cancel();
      });
    });

    // ★ 視聴者数のランダム変動（変更なし）
    final initialViewers = 110 + Random().nextInt(21);
    return LiveStreamState(viewers: initialViewers);
  }

  // ★★★ _calculateLevelメソッド（変更なし） ★★★
  int _calculateLevel(double likeability) {
    if (likeability < 20) return 1;
    if (likeability < 40) return 2;
    if (likeability < 60) return 3;
    return 3;
  }

  // ★★★ _initializeAllScenarios メソッドは削除 ★★★

  // ★★★ _startScenarioTimerメソッド（変更なし） ★★★
  void _startScenarioTimer() {
    _scenarioTimer?.cancel();
    _scenarioTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _processScenarioTick();
      _currentSecond++;
    });
  }

  // ★★★ _processScenarioTickメソッド（変更あり） ★★★
  void _processScenarioTick() {
    // ★★★ データを kAllScenarios から参照 ★★★
    final currentScript =
        kAllScenarios[_currentLikeabilityLevel] ?? kAllScenarios[1]!;

    if (currentScript.containsKey(_currentSecond)) {
      final events = currentScript[_currentSecond]!;
      for (final event in events) {
        if (event.type == ScenarioEventType.dialogue) {
          state = state.copyWith(characterDialogue: event.text);
        } else if (event.type == ScenarioEventType.comment) {
          final newComment = NormalComment(
            userName: event.userName ?? '名無し',
            iconAsset: event.iconAsset ?? '',
            text: event.text,
          );
          _addComment(newComment);
        }
      }

      // ★ 視聴者数の変動ロジック（変更なし）
      final currentViewers = state.viewers;
      final change = Random().nextInt(5) - 2;
      state =
          state.copyWith(viewers: (currentViewers + change).clamp(100, 150));
    }

    // ★ ループ処理（変更なし）
    final loopPoint = currentScript.keys.last;
    if (_currentSecond >= loopPoint) {
      _currentSecond = -1;
    }
  }

  // ★★★ _addCommentメソッド（変更なし） ★★★
  void _addComment(Comment newComment) {
    final currentComments = List<Comment>.from(state.comments);
    currentComments.insert(0, newComment);
    if (currentComments.length > 5) {
      currentComments.removeLast();
    }
    state = state.copyWith(comments: currentComments);
  }
}

// Providerの定義（変更なし）
final liveStreamProvider =
    NotifierProvider<LiveStreamNotifier, LiveStreamState>(
        LiveStreamNotifier.new);
