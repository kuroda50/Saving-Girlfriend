import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:saving_girlfriend/services/notification_service.dart';
import '../constants/color.dart';
import 'package:saving_girlfriend/services/local_storage_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/select_girlfriend_provider.dart';
// -----------------------------------------------------------

// StatelessWidget から ConsumerStatefulWidget に変更
class TitleScreen extends ConsumerStatefulWidget {
  // 👈 修正: ConsumerStatefulWidget
  const TitleScreen({super.key});

  @override
  // State を ConsumerState に変更
  ConsumerState<TitleScreen> createState() =>
      _TitleScreenState(); // 👈 修正: ConsumerState
}

// State を ConsumerState に変更
class _TitleScreenState extends ConsumerState<TitleScreen> {
  // 👈 修正: ConsumerState

  // 画面遷移ロジック
  void _navigateToNextScreen() async {
    // 1. Riverpod の FutureProvider から選択状態を非同期で読み取る
    final selectionStatusAsync =
        ref.read(selectionStatusProvider.future); // 👈 エラー2解消: refを使用

    // ロードが完了している場合のみ処理を継続
    // 2. 彼女選択済みフラグを取得（データがなければ false）
    final hasplayedstory = await ref.read(localStorageServiceProvider.future);
    final hasPlayed = await hasplayedstory.hasPlayedStory();

    final String nextPath = hasPlayed
        ? '/home' // 再生済みならホーム画
        : '/select_girlfriend'; // (到達しないはず)

    // 画面遷移を実行
    if (mounted) {
      context.go(nextPath);
    }
  }

  @override
  Widget build(BuildContext context) {
    // 画面のサイズを取得
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: <Widget>[
          // 背景画像
          Positioned.fill(
            child: Image.asset(
              "assets/images/background/9-16title.jpg",
              fit: BoxFit.cover,
            ),
          ),
          // アプリスタートボタンを画面中央下部に配置
          // 変更点: Padding の中に Center を追加して水平方向の中央寄せを復活

          Padding(
            padding: EdgeInsets.only(top: screenHeight * 0.3),
            child: Center(
              child: SizedBox(
                height: screenHeight * 0.1,
                child: ElevatedButton(
                  onPressed: _navigateToNextScreen,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width * 0.1,
                      vertical: 20,
                    ),
                  ),
                  child: const Text(
                    'Live Start!',
                    style: TextStyle(fontSize: 25, color: AppColors.mainLogo),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
