import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:saving_girlfriend/constants/assets.dart';
import 'package:saving_girlfriend/models/comment_model.dart';
import 'package:saving_girlfriend/widgets/super_chat_modal.dart';
import '../providers/home_screen_provider.dart';
import '../providers/likeability_provider.dart'; // ★★★ この行を追加 ★★★
import '../providers/spendable_amount_provider.dart'; // ★ 新しいProviderをインポート
import '../constants/assets.dart'; // ★★★ この行を追加 ★★★

// HomeScreen 本体
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. 背景画像
          Positioned.fill(
            child: Image.asset(AppAssets.backgroundClassroom, fit: BoxFit.cover),
          ),
          // 2. キャラクター画像
          Positioned(
            bottom: 80, // ←ここを修正
            left: 0,
            right: 0,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Image.asset(
                AppAssets.characterSuzunari,
                fit: BoxFit.contain,
                height: MediaQuery.of(context).size.height * 0.45, // ←ここを修正
              ),
            ),
          ),
          // UI要素をここから配置
          const _LiveHeader(),
          const _DialogueBubble(),
          const _CommentsList(),
          const _BottomUiBar(),
          const _BudgetDisplay(), // ★★★ この一行を追加 ★★★
        ],
      ),
    );
  }
}

// 左上のヘッダー (視聴者数やタイトル)
 class _LiveHeader extends ConsumerWidget {
  const _LiveHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 視聴者数と好感度の状態を監視
    final homeState = ref.watch(homeScreenProvider);
    final likeabilityAsync = ref.watch(likeabilityProvider);

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
            // --- 上段：チャンネル情報 ---
            Row(
              children: [
                const CircleAvatar(
                  radius: 18,
                  backgroundImage: AssetImage('assets/icons/suzunari_icon.png'),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('鈴鳴 おと', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.group, color: Colors.white70, size: 12),
                        const SizedBox(width: 4),
                        Text('${homeState.viewers}人が視聴中', style: const TextStyle(color: Colors.white70, fontSize: 10)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),

            // ★★★↓ 好感度メーター（プログレスバー＋ハート）に変更 ↓★★★
            likeabilityAsync.when(
              data: (likeability) {
                return Row(
                  children: [
                    // プログレスバー本体
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: (likeability / 100.0).clamp(0.0, 1.0),
                          backgroundColor: Colors.white.withOpacity(0.3),
                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.pinkAccent),
                          minHeight: 6,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // ★ ここをハートアイコンに変更
                    const Icon(Icons.favorite, color: Colors.pinkAccent, size: 16),
                    const SizedBox(width: 4), // アイコンとテキストの間の余白

                    // 好感度テキスト
                    Text(
                      '${likeability.round()}%', // 小数点以下を丸める
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ],
                );
              },
              loading: () {
                // ロード中はアニメーションするバーと「---%」表示
                return Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          backgroundColor: Colors.white.withOpacity(0.3),
                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.pinkAccent),
                          minHeight: 6,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.favorite_border, color: Colors.white38, size: 16), // ロード中は空のハート
                    const SizedBox(width: 4),
                    const Text(
                      '---%',
                      style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ],
                );
              },
              error: (err, stack) {
                return const Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red, size: 16),
                    SizedBox(width: 4),
                    Text('エラー', style: TextStyle(color: Colors.red, fontSize: 12)),
                  ],
                );
              },
            ),
            // ★★★↑ ここまで ↑★★★
          ],
        ),
      ),
    );
  }
}

// 下部のUI (コメント入力欄 + スパチャボタン)
class _BottomUiBar extends ConsumerWidget {
  const _BottomUiBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Positioned(
      bottom: 20,
      left: 16,
      right: 16,
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Text('コメントする...', style: TextStyle(color: Colors.white.withOpacity(0.7))),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () {
              showSuperChatModal(
                context,
                onSend: (amount, comment) {
                  ref.read(homeScreenProvider.notifier).addSuperChat(amount, comment);
                },
              );
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade600,
                shape: BoxShape.circle,
              ),
              child: const Text('¥', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}

class _DialogueBubble extends ConsumerWidget {
  const _DialogueBubble();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Providerから現在のセリフを取得
    final dialogue = ref.watch(homeScreenProvider.select((s) => s.characterDialogue));
    final screenWidth = MediaQuery.of(context).size.width;

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
          child: Text(
            dialogue,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
// コメントリスト
class _CommentsList extends ConsumerWidget {
  const _CommentsList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final comments = ref.watch(homeScreenProvider.select((s) => s.comments));

    return Positioned(
      bottom: 80,
      left: 16,
      width: MediaQuery.of(context).size.width * 0.65,
      height: 250,
      child: ListView.builder(
        reverse: true,
        itemCount: comments.length,
        itemBuilder: (context, index) {
          final comment = comments[index];
          if (comment is SuperChat) {
            return _SuperChatItem(superChat: comment);
          } else {
            return _NormalCommentItem(comment: comment);
          }
        },
      ),
    );
  }
}

// 通常コメントの表示Widget
class _NormalCommentItem extends StatelessWidget {
  final Comment comment;
  const _NormalCommentItem({super.key, required this.comment});

  @override
  Widget build(BuildContext context) {
    // ★★★↓ ここからが条件分岐のロジック ↓★★★

    // 表示するアイコンを決定するための変数
    Widget iconWidget;

    // もしiconAssetの文字列が空でなければ（=パスが設定されていれば）
    if (comment.iconAsset.isNotEmpty) {
      // 画像を使ったCircleAvatarを表示する
      iconWidget = CircleAvatar(radius: 12, backgroundImage: AssetImage(comment.iconAsset));
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
                style: const TextStyle(color: Colors.white, fontSize: 14, shadows: [Shadow(blurRadius: 2, color: Colors.black54)]),
                children: [
                  TextSpan(
                    text: '${comment.userName}  ',
                    style: TextStyle(color: Colors.white.withOpacity(0.7), fontWeight: FontWeight.bold),
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
    final String initial = userName.isNotEmpty ? userName[0].toUpperCase() : '?';

    // ユーザー名のハッシュコードを使って、Material Designの基本色から色を決定する
    // これにより、同じ名前のユーザーは常に同じ色になる
    final Color color = Colors.primaries[userName.hashCode % Colors.primaries.length];

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
                  CircleAvatar(radius: 14, backgroundImage: AssetImage(superChat.iconAsset)),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(superChat.userName, style: TextStyle(color: colorConfig.textColor, fontWeight: FontWeight.bold, fontSize: 12)),
                      Text('¥${superChat.amount}', style: TextStyle(color: colorConfig.textColor, fontWeight: FontWeight.bold, fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
            if (superChat.text.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(superChat.text, style: TextStyle(color: colorConfig.textColor, fontSize: 14)),
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