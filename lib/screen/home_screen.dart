import 'package:flutter/material.dart';


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('無題', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.black, // または濃い灰色
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () {
            // メニューアイコンの処理
          },
        ),
        actions: const [
          // AppBarの右側に何か追加するならここに
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                // 1. 背景画像 (教室)
                Positioned.fill(
                  child: Image.asset(
                    'assets/images/classroom.png', // 教室の画像のパス
                    fit: BoxFit.cover,
                  ),
                ),
                // 2. キャラクター画像
                Positioned(
                  bottom: 0, // 必要に応じて調整
                  left: 0, // 必要に応じて調整
                  right: 0, // 必要に応じて調整
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Image.asset(
                      'assets/images/suzunari.png', // キャラクターの画像のパス
                      fit: BoxFit.contain,
                      height: MediaQuery.of(context).size.height * 0.6, // 画面の高さに応じて調整
                    ),
                  ),
                ),
                // 3. 上部の情報バー
                Positioned(
                  top: 20, // 適宜調整
                  left: 20,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.settings, color: Colors.grey),
                          onPressed: () {
                            // 設定アイコンの処理
                          },
                        ),
                        Text(
                          '5回目継続中!!',
                          style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: LinearProgressIndicator(
                              value: 0.5, // プログレスの現在値（例: 0.5で50%）
                              backgroundColor: Colors.grey.shade300,
                              valueColor: const AlwaysStoppedAnimation<Color>(Colors.pink),
                            ),
                          ),
                        ),
                        const Icon(Icons.favorite, color: Colors.pink, size: 18),
                        const Text('50', style: TextStyle(color: Colors.black, fontSize: 14)),
                        const Text('/100', style: TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                  ),
                ),
                // 4. 吹き出し
                Positioned(
                  top: MediaQuery.of(context).size.height * 0.2, // キャラクターの位置と合わせて調整
                  left: MediaQuery.of(context).size.width * 0.2, // キャラクターの位置と合わせて調整
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Text(
                      'いつもありがとうございます先輩！\n大好きです…',
                      style: TextStyle(fontSize: 14, color: Colors.black87),
                    ),
                  ),
                ),
                // 5. 下部のハートと円のアイコン（画像から推測）
                Positioned(
                  bottom: MediaQuery.of(context).size.height * 0.05, // 画面下部からの位置を調整
                  right: 20,
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.pink.withOpacity(0.8),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.pink.withOpacity(0.4),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.favorite, color: Colors.white, size: 30),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.pink.withOpacity(0.8),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.pink.withOpacity(0.4),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.currency_yen, color: Colors.white, size: 30), // 円マークのアイコン
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}