import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart'; // 追加
import '../constants/color.dart';

// StatelessWidget から StatefulWidget に変更
class TitleScreen extends StatefulWidget {
  const TitleScreen({super.key});

  @override
  State<TitleScreen> createState() => _TitleScreenState();
}

class _TitleScreenState extends State<TitleScreen> {
  // 画面遷移ロジック
  void _navigateToNextScreen() async {
    // SharedPreferencesのインスタンスを取得
    final prefs = await SharedPreferences.getInstance();

    // 'has_selected_girlfriend' のキーで保存された値を取得。
    // 値がなければ（初めて起動したときなど）falseとする。
    final hasSelected = prefs.getBool('has_selected_girlfriend') ?? false;

    // 遷移先のパスを決定
    final String nextPath = hasSelected
        ? '/home' // 選択済みならホーム画面など（あなたのアプリに合わせてパスを変更してください）
        : '/select_girlfriend'; // 未選択なら彼女選択画面

    // 画面遷移を実行
    context.go(nextPath);
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
            // 垂直位置の調整: screenHeight * 0.4 の値を変更して上下に動かす
            padding: EdgeInsets.only(top: screenHeight * 0.3),

            // 🔽🔽🔽 追加: Center でボタンを水平方向の中央に配置 🔽🔽🔽
            child: Center(
              child: SizedBox(
                // ボタン自体の高さを画面の約10%に設定 (元のコードを維持)
                height: screenHeight * 0.1,
                child: ElevatedButton(
                  // 遷移ロジック
                  onPressed: _navigateToNextScreen,
                  style: ElevatedButton.styleFrom(
                    // ボタンのパディングは元のコードと同じ
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
