import 'dart:async';
import 'dart:collection'; // 差分検出のために追加
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:saving_girlfriend/app/providers/likeability_provider.dart';
import 'package:saving_girlfriend/app/providers/spendable_amount_provider.dart';
import 'package:saving_girlfriend/common/constants/assets.dart';
import 'package:saving_girlfriend/features/live_stream/models/comment_model.dart';
import 'package:saving_girlfriend/features/live_stream/providers/live_stream_provider.dart';
import 'package:saving_girlfriend/features/story/data/scenario_data.dart';
import 'package:saving_girlfriend/features/tribute/widgets/super_chat_modal.dart';

// HomeScreen 本体
// HomeScreen 本体 (StatefulWidgetに変更)
// HomeScreen 本体 (StatefulWidgetに変更)
// HomeScreen 本体 (StatefulWidgetに変更)
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  Timer? _breathTimer; // 息遣いをランダムに制御するタイマー
  final Random _random = Random();

  @override
  void initState() {
    super.initState();

    // 0.2秒間で上下運動を完了させるアニメーションコントローラを設定
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200), // 素早く動かす (0.2秒)
    );

    // 3ピクセル上下させるためのTweenを設定
    _animation = Tween<double>(begin: 0, end: 3).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut, // 滑らかに動かす
      ),
    );

    // ★ 最初の息遣いタイマーをスケジュール
    _scheduleNextBreath();
  }

  @override
  void dispose() {
    _controller.dispose();
    _breathTimer?.cancel(); // タイマーを確実に停止
    super.dispose();
  }

  // ★ ランダムな間隔で次の「息遣い」をスケジュールする
  void _scheduleNextBreath() {
    // ★★★ 変更: 3000ms (3秒) から 7000ms (7秒) の間でランダムな遅延時間を設定 ★★★
    final delayMilliseconds =
        _random.nextInt(4001) + 3000; // 4001 + 3000 = 7001ms (約7秒)

    _breathTimer = Timer(Duration(milliseconds: delayMilliseconds), () {
      // 一度だけ再生するアニメーション (上下して戻ってくる)
      _controller.forward().then((_) {
        _controller.reverse();
      });

      // 次の息遣いをスケジュール
      _scheduleNextBreath();
    });
  }

  @override
  Widget build(BuildContext context) {
    final safeAreaBottom = MediaQuery.of(context).padding.bottom;
    final widgetBottom = safeAreaBottom + 60.0;

    return Scaffold(
      body: Stack(
        children: [
          // 1. 背景画像
          Positioned.fill(
            child:
                Image.asset(AppAssets.backgroundHomeScreen, fit: BoxFit.cover),
          ),

          // 2. キャラクター画像 (AnimatedBuilderでアニメーションを適用)
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              // Positionedのbottomにアニメーション値を適用
              return Positioned(
                bottom: widgetBottom + _animation.value, // ← アニメーション値を適用
                left: 0,
                right: 0,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Image.asset(
                    AppAssets.characterSuzunari,
                    fit: BoxFit.contain,
                    height: MediaQuery.of(context).size.height * 0.60,
                  ),
                ),
              );
            },
          ),

          // UI要素をここから配置 (変更なし)
          const _LiveHeader(),
          const _DialogueBubble(),
          const _CommentsList(),
          const _BottomUiBar(),
          const _BudgetDisplay(),
        ],
      ),
    );
  }
}

// 左上のヘッダー (視聴者数やタイトル)
// 左上のヘッダー (視聴者数やタイトル)
class _LiveHeader extends ConsumerWidget {
  const _LiveHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 視聴者数と好感度の状態を監視
    final homeState = ref.watch(liveStreamProvider);
    final likeabilityAsync = ref.watch(likeabilityProvider);

    // ★★★ 配信タイトルを取得するための処理を追加（HomeScreenStateに currentLikeabilityLevel がないため likeabilityProvider の値から決定） ★★★
    final title = likeabilityAsync.when(
      data: (likeability) {
        // 0-100% を複数レベルに分割（例: 5段階）
        final level =
            min(kScenarioTitles.length - 1, max(0, (likeability / 20).floor()));
        return kScenarioTitles[level] ?? 'Now Loading...';
      },
      loading: () => 'Now Loading...',
      error: (err, stack) => 'Now Loading...',
    );

    return Positioned(
      top: 40,
      left: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.6),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ★★★ 変更点1: 配信タイトルを追加 ★★★
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
                shadows: [Shadow(blurRadius: 2, color: Colors.black)],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8), // タイトルとチャンネル情報の間にスペース

            // --- 上段：チャンネル情報 ---
            Row(
              children: [
                const CircleAvatar(
                  radius: 18,
                  backgroundImage: AssetImage(AppAssets.characterSuzunari),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('鈴鳴 おと',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14)),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.group,
                            color: Colors.white70, size: 12),
                        const SizedBox(width: 4),
                        Text('${homeState.viewers}人が視聴中',
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 10)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),

            // ★★★↓ 好感度メーター ↓★★★
            likeabilityAsync.when(
              data: (likeability) {
                return Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: (likeability / 100.0).clamp(0.0, 1.0),
                          backgroundColor: Colors.white.withOpacity(0.3),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              Colors.pinkAccent),
                          minHeight: 6,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.favorite,
                        color: Colors.pinkAccent, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '${likeability.round()}%',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                );
              },
              loading: () {
                // ( ... loading時のコード ... )
                return Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          backgroundColor: Colors.white.withOpacity(0.3),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              Colors.pinkAccent),
                          minHeight: 6,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.favorite_border,
                        color: Colors.white38, size: 16),
                    const SizedBox(width: 4),
                    const Text(
                      '---%',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                );
              },
              error: (err, stack) {
                // ( ... error時のコード ... )
                return const Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red, size: 16),
                    SizedBox(width: 4),
                    Text('エラー',
                        style: TextStyle(color: Colors.red, fontSize: 12)),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// 下部のUI (コメント入力欄 + スパチャボタン)
// 下部のUI (コメント入力欄 + スパチャボタン)
class _BottomUiBar extends ConsumerWidget {
  const _BottomUiBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 画面下のセーフエリア（ホームバーなど）のサイズを取得
    final safeAreaBottom = MediaQuery.of(context).padding.bottom;

    return Positioned(
      // セーフエリアを考慮した位置に
      bottom: safeAreaBottom + 10.0,
      left: 16,
      right: 16,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          GestureDetector(
            onTap: () {
              showSuperChatModal(
                context,
                onSend: (amount, comment) {
                  ref
                      .read(liveStreamProvider.notifier)
                      .addSuperChat(amount, comment);
                },
              );
            },
            child: Container(
              padding: const EdgeInsets.all(18), //ボタンの大きさ
              decoration: BoxDecoration(
                color: Colors.blue.shade600,
                shape: BoxShape.circle,
              ),
              child: const Text('¥',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 26, //ボタン内のマークの大きさ
                      fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}

// ConsumerStatefulWidgetに変更
class _DialogueBubble extends ConsumerStatefulWidget {
  const _DialogueBubble();

  @override
  ConsumerState<_DialogueBubble> createState() => _DialogueBubbleState();
}

// Stateクラスを作成 (アニメーションを管理するため)
class _DialogueBubbleState extends ConsumerState<_DialogueBubble>
    with SingleTickerProviderStateMixin {
  // アニメーションのためにMixinを追加

  late AnimationController _controller;
  late Animation<int> _textAnimation;
  String _currentDialogue = '';

  // 1文字あたりに表示にかかる時間 (ミリ秒)
  final int _millisecondsPerChar = 50;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1), // 初期値はほぼゼロ
    );

    // 0から現在のセリフの長さまでをアニメーションするTween
    _textAnimation = IntTween(begin: 0, end: 0).animate(_controller);

    // 最初のセリフをセットアップ
    _setupAnimation(
      ref.read(liveStreamProvider.select((s) => s.characterDialogue)),
    );
  }

  @override
  void dispose() {
    _controller.dispose(); // 必ず破棄する
    super.dispose();
  }

  // 新しいセリフがProviderから渡されたときに呼ばれる
  void _setupAnimation(String newDialogue) {
    if (newDialogue.isEmpty) {
      _controller.reset();
      setState(() {
        _currentDialogue = '';
        _textAnimation = IntTween(begin: 0, end: 0).animate(_controller);
      });
      return;
    }

    // 新しいセリフとアニメーションを設定
    final newDuration = _millisecondsPerChar * newDialogue.length;
    _controller.duration = Duration(milliseconds: newDuration);
    setState(() {
      _currentDialogue = newDialogue;
      _textAnimation =
          IntTween(begin: 0, end: _currentDialogue.length).animate(_controller);
    });

    // アニメーションを最初から再生
    _controller.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    // Providerから現在のセリフを取得
    final fullDialogue =
        ref.watch(liveStreamProvider.select((s) => s.characterDialogue));
    final screenWidth = MediaQuery.of(context).size.width;

    // もしProviderのセリフが内部のセリフと異なれば、新しいセリフとしてアニメーションを開始
    if (fullDialogue != _currentDialogue) {
      // build中にStateを更新しないよう、次のフレームで実行する
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _setupAnimation(fullDialogue);
      });
    }

    // 吹き出しの位置を調整
    return Positioned(
      top: 180,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          width: screenWidth * 0.8, // 画面幅の80%
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          // AnimatedBuilderでアニメーションの値（_textAnimation.value）を監視
          child: AnimatedBuilder(
            animation: _textAnimation,
            builder: (context, child) {
              // アニメーションの現在値までセリフを切り出して表示
              final displayText =
                  _currentDialogue.substring(0, _textAnimation.value);

              return Text(
                displayText,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

// コメントリスト
// ConsumerStatefulWidgetに変更
class _CommentsList extends ConsumerStatefulWidget {
  const _CommentsList();

  @override
  ConsumerState<_CommentsList> createState() => _CommentsListState();
}

// Stateクラスを作成 (アニメーションとリストの差分を管理するため)
// Stateクラスを作成 (アニメーションとリストの差分を管理するため)
class _CommentsListState extends ConsumerState<_CommentsList> {
  // AnimatedListを操作するためのキー
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  // 現在リストに表示されているコメントを保持する
  // ★ List ではなく ListQueue を使うと、末尾の削除が効率的
  final ListQueue<Comment> _comments = ListQueue<Comment>();

  // アニメーション付きでアイテムを削除するためのビルダー
  Widget _buildRemovedItem(
      Comment comment, BuildContext context, Animation<double> animation) {
    // 削除アニメーション（フェードアウト）
    return FadeTransition(
      opacity: animation,
      child: SizeTransition(
        sizeFactor: animation,
        child: comment is SuperChat
            ? _SuperChatItem(superChat: comment)
            : _NormalCommentItem(comment: comment),
      ),
    );
  }

  // スライドアニメーション付きでアイテムを追加するためのビルダー
  Widget _buildInsertedItem(
      Comment comment, BuildContext context, Animation<double> animation) {
    // スライド＆フェードイン
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 1), // 下から
        end: Offset.zero, // 本来の位置へ
      ).animate(animation),
      child: FadeTransition(
        opacity: animation,
        child: comment is SuperChat
            ? _SuperChatItem(superChat: comment)
            : _NormalCommentItem(comment: comment),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ref.watch ではなく ref.listen を使い、コメントリストの「変化」を監視
    ref.listen(
      liveStreamProvider.select((s) => s.comments),
      (previousList, newList) {
        // --- 1. 初回ロード時の処理 ---
        if (previousList == null) {
          _comments.addAll(newList);
          return;
        }

        // --- 2. 削除の検出 (Provider側で5個制限がかかった場合) ---
        if (previousList.length == 5 &&
            newList.length == 5 &&
            !newList.contains(previousList.last)) {
          // ローカルリストの最後のアイテムを特定
          if (_comments.isNotEmpty) {
            final removedItem = _comments.removeLast(); // ローカルリストから削除
            _listKey.currentState?.removeItem(
              _comments.length, // 削除されたアイテムのインデックス (削除後の長さ)
              (context, animation) =>
                  _buildRemovedItem(removedItem, context, animation),
              duration: const Duration(milliseconds: 200), // 削除アニメーションの時間
            );
          }
        }

        // --- 3. 追加の検出 (新しいコメントが来た場合) ---
        if (newList.isNotEmpty &&
            (previousList.isEmpty || previousList[0] != newList[0])) {
          _comments.addFirst(newList[0]); // ローカルリストに追加
          _listKey.currentState?.insertItem(
            0, // 0番目に追加
            duration: const Duration(milliseconds: 300), // 追加アニメーションの時間
          );
        }
      },
    );

    return Positioned(
      bottom: (MediaQuery.of(context).padding.bottom + 10.0),
      left: 16,
      width: MediaQuery.of(context).size.width * 0.65,
      height: 250,
      // ★★★ ShaderMaskで囲んで、上部をフェードアウトさせる ★★★
      child: ShaderMask(
        shaderCallback: (Rect bounds) {
          // 上から下へのグラデーション
          return const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent, // 上（古いコメント）を透明に
              Colors.black, // 途中から
              Colors.black, // 下（新しいコメント）は不透明
            ],
            // 0%地点で透明、15%地点から不透明になり、下端まで不透明
            stops: [0.0, 0.15, 1.0],
          ).createShader(bounds);
        },
        blendMode: BlendMode.dstIn, // このブレンドモードが重要
        child: AnimatedList(
          key: _listKey,
          reverse: true, // reverse: true が重要 (0番目が一番下に来る)
          initialItemCount: _comments.length,
          itemBuilder: (context, index, animation) {
            // ★ アニメーションビルドを _buildInsertedItem に任せる
            return _buildInsertedItem(
                _comments.elementAt(index), context, animation);
          },
        ),
      ),
    );
  }
}

// 通常コメントの表示Widget
class _NormalCommentItem extends StatelessWidget {
  final Comment comment;
  const _NormalCommentItem({required this.comment});

  @override
  Widget build(BuildContext context) {
    // ★★★↓ ここからが条件分岐のロジック ↓★★★

    // 表示するアイコンを決定するための変数
    Widget iconWidget;

    // もしiconAssetの文字列が空でなければ（=パスが設定されていれば）
    if (comment.iconAsset.isNotEmpty) {
      // 画像を使ったCircleAvatarを表示する
      iconWidget = CircleAvatar(
          radius: 12, backgroundImage: AssetImage(comment.iconAsset));
    } else {
      // 文字列が空なら、InitialIconを表示する
      iconWidget = InitialIcon(userName: comment.userName);
    }

    // ★★★↑ ここまでがロジック ↑★★★

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          iconWidget, // ← 上で決定したアイコンウィジェットをここに配置
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    shadows: [Shadow(blurRadius: 2, color: Colors.black54)]),
                children: [
                  TextSpan(
                    text: '${comment.userName}  ',
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: comment.text),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class InitialIcon extends StatelessWidget {
  final String userName;
  const InitialIcon({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
    // ユーザー名の最初の文字を取得（空の場合は'?'にする）
    final String initial =
        userName.isNotEmpty ? userName[0].toUpperCase() : '?';

    // ユーザー名のハッシュコードを使って、Material Designの基本色から色を決定する
    // これにより、同じ名前のユーザーは常に同じ色になる
    final Color color =
        Colors.primaries[userName.hashCode % Colors.primaries.length];

    return CircleAvatar(
      radius: 12, // アイコンのサイズ
      backgroundColor: color,
      child: Text(
        initial,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}

// スパチャの表示Widget
class _SuperChatItem extends StatelessWidget {
  final SuperChat superChat;
  const _SuperChatItem({required this.superChat});

  @override
  Widget build(BuildContext context) {
    final colorConfig = superChat.colorConfig;

    return Card(
      elevation: 0,
      color: Colors.transparent,
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: Container(
        decoration: BoxDecoration(
          color: colorConfig.backgroundColor,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              color: colorConfig.backgroundColor.withOpacity(0.8),
              child: Row(
                children: [
                  CircleAvatar(
                      radius: 14,
                      backgroundImage: AssetImage(superChat.iconAsset)),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(superChat.userName,
                          style: TextStyle(
                              color: colorConfig.textColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12)),
                      Text('¥${superChat.amount}',
                          style: TextStyle(
                              color: colorConfig.textColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
            if (superChat.text.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(superChat.text,
                    style:
                        TextStyle(color: colorConfig.textColor, fontSize: 14)),
              ),
          ],
        ),
      ),
    );
  }
}

// ★★★↓ 右上に予算を表示するための、新しいウィジェット ↓★★★
class _BudgetDisplay extends ConsumerWidget {
  const _BudgetDisplay();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // spendableAmountProviderを監視
    final spendableAmountAsync = ref.watch(spendableAmountProvider);

    return Positioned(
      top: 40,
      right: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.6),
          borderRadius: BorderRadius.circular(20),
        ),
        // Providerの状態に応じて表示を切り替え
        child: spendableAmountAsync.when(
          data: (amount) => Row(
            children: [
              const Icon(Icons.wallet_outlined, color: Colors.yellow, size: 16),
              const SizedBox(width: 6),
              Text(
                '¥$amount',
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          loading: () => const SizedBox(
            height: 20, // Containerの高さに合わせる
            width: 20,
            child:
                CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
          ),
          error: (err, stack) =>
              const Icon(Icons.error_outline, color: Colors.red, size: 20),
        ),
      ),
    );
  }
}
