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
    print("ここまで実行できたよ");

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
          Center(
            child: SizedBox(
              // ボタンの配置を画面の高さの約40%下げる
              height: screenHeight * 0.4,
              child: ElevatedButton(
                // 修正: 遷移ロジックを外部メソッドに切り出し
                onPressed: _navigateToNextScreen,
                style: ElevatedButton.styleFrom(
                  // ボタンのパディングを画面幅に合わせて調整
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
        ],
      ),
    );
  }
}
