// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:saving_girlfriend/providers/current_girlfriend_provider.dart';
import 'package:saving_girlfriend/services/local_storage_service.dart';
import '../constants/color.dart';

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
    // プロバイダーを読み込み、彼女が選択されているか確認
    final currentGirlfriendId =
        await ref.read(currentGirlfriendProvider.future);

    if (mounted) {
      if (currentGirlfriendId != null) {
        // 彼女が選択されている場合
        final localStorage = await ref.read(localStorageServiceProvider.future);
        final hasPlayedEpisode0 =
            localStorage.hasPlayedEpisode0(currentGirlfriendId);

        if (hasPlayedEpisode0) {
          // 0話再生済みならホーム画面へ
          context.go('/home');
        } else {
          // 未再生なら0話を再生
          // ここではsetPlayedStoryは呼ばない。ストーリー画面で再生完了時に呼ぶ
          context.go('/story', extra: 0);
        }
      } else {
        // 彼女が選択されていない場合、選択画面へ
        context.go('/select_girlfriend');
      }
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
