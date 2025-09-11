import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:saving_girlfriend/constants/assets.dart';
import '../constants/color.dart';
import 'package:go_router/go_router.dart';
import '../providers/home_screen_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeScreenProvider);
    final comments = homeState.comments;

    // handleSendMessage と girlfriendText は不要なので削除

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.secondary,
      ),
      body: Stack( // bodyを直接Stackに変更
        children: [
          // 1. 背景画像
          Positioned.fill(
            child: Image.asset(
              AppAssets.backgroundClassroom,
              fit: BoxFit.cover,
            ),
          ),
          // 2. キャラクター画像
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Image.asset(
                AppAssets.characterSuzunari,
                fit: BoxFit.contain,
                height: MediaQuery.of(context).size.height * 0.5,
              ),
            ),
          ),

          // ★★★↓ LIVEバッジと視聴者数を追加 ↓★★★
          Positioned(
            top: 80,
            right: 20,
            child: Row(
              children: [
                // LIVEバッジ
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'LIVE',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // 視聴者数
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.visibility, color: Colors.white, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '${homeState.viewers}', // ★Providerから視聴者数を取得
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // ★★★↑↑↑ 追加はここまで ↑↑↑★★★
          // 3. 上部の情報バー（元のまま）
          Positioned(
            top: 20,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.mainBackground.withOpacity(0.8),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.settings, color: AppColors.subIcon),
                    onPressed: () => context.push('/home/settings'),
                  ),
                  const Text('5回目継続中!!', style: TextStyle(color: AppColors.mainText, fontSize: 12)),
                  const Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: LinearProgressIndicator(
                        value: 0.5,
                        backgroundColor: AppColors.nonActive,
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                      ),
                    ),
                  ),
                  const Icon(Icons.favorite, color: AppColors.primary, size: 18),
                  const Text('50', style: TextStyle(color: AppColors.mainText, fontSize: 14)),
                  const Text('/100', style: TextStyle(color: AppColors.mainText, fontSize: 12)),
                ],
              ),
            ),
          ),
          // 4. 吹き出し（元のまま）
          Positioned(
            top: MediaQuery.of(context).size.height * 0.15,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(10),
                width: MediaQuery.of(context).size.width * 0.7,
                decoration: BoxDecoration(
                  color: AppColors.mainBackground,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.shadow,
                      blurRadius: 5,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: const Text(
                  "見に来てくれてありがとう！", // ★固定テキストに変更
                  style: TextStyle(fontSize: 14, color: AppColors.mainText),
                ),
              ),
            ),
          ),

          // ★★★↓ コメント表示エリアを追加 ↓★★★
          // ★★★ コメント表示エリア ★★★
          Positioned(
            bottom: 20,
            left: 20,
            child: Container( // ★Containerを追加
              width: MediaQuery.of(context).size.width * 0.4,
              height: 250,
              padding: const EdgeInsets.all(8.0), // ★内側の余白を追加
              decoration: BoxDecoration( // ★背景の装飾を設定
                color: Colors.black.withOpacity(0.4), // ★黒で透明度40%
                borderRadius: BorderRadius.circular(10), // ★角を丸くする
              ),
              child: ListView.builder(
                reverse: true,
                itemCount: comments.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Text(
                      comments[index],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            blurRadius: 5.0,
                            color: Colors.black,
                            offset: Offset(2.0, 2.0),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}