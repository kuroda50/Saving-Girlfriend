// title.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // 💡 go_routerをインポート

class TitleScreen extends StatelessWidget {
  const TitleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          // 背景画像
          Positioned.fill(
            child: Image.asset(
              "assets/images/character/titleicon.png",
              fit: BoxFit.cover,
            ),
          ),
          // アプリスタートボタン
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.only(top: 80.0),
              child: ElevatedButton(
                onPressed: () {
                  // ボタンが押されたらホーム画面へ遷移
                  context.go('/home'); // 💡 /home は go_router.dartで設定したパス
                },
                child: const Text(
                  'アプリスタート',
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}