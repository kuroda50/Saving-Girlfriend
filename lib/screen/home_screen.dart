import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:saving_girlfriend/constants/assets.dart';
import 'dart:convert';
import '../constants/color.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.secondary,
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                // 1. 背景画像 (教室)
                Positioned.fill(
                  child: Image.asset(
                    AppAssets.backgroundClassroom, // 教室の画像のパス
                    fit: BoxFit.cover,
                    // エラー表示を避けるためのエラーハンドリング
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: AppColors.errorBackground,
                        child: const Center(
                          child: Text(
                            '背景画像をロードできませんでした。\nパス: ${AppAssets.backgroundClassroom}',
                            textAlign: TextAlign.center,
                            style:
                                TextStyle(color: AppColors.error, fontSize: 16),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // 2. キャラクター画像 (画面下部中央に調整)
                Positioned(
                  bottom: 0, // 画面の最下部に配置
                  left: 0,
                  right: 0,
                  child: Align(
                    alignment: Alignment.bottomCenter, // 水平方向は中央、垂直方向は下揃え
                    child: Image.asset(
                      AppAssets.characterSuzunari, // キャラクターの画像のパス
                      fit: BoxFit.contain,
                      // 画面の高さの約75%に設定し、画面に収まるように調整
                      height: MediaQuery.of(context).size.height * 0.5,
                      // エラー表示を避けるためのエラーハンドリング
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: AppColors.errorBackground, // 背景は透明
                          child: const Center(
                            child: Text(
                              'キャラクター画像をロードできませんでした。\nパス: ${AppAssets.characterSuzunari}',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: AppColors.error, fontSize: 16),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                // 3. 上部の情報バー
                Positioned(
                  top: 20, // 適宜調整
                  left: 20,
                  right: 20,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.mainBackground.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.settings,
                              color: AppColors.subIcon),
                          onPressed: () {
                            context.push('/home/settings');
                          },
                        ),
                        const Text(
                          '5回目継続中!!',
                          style: TextStyle(
                              color: AppColors.mainText, fontSize: 12),
                        ),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8.0),
                            child: LinearProgressIndicator(
                              value: 0.5, // プログレスの現在値（例: 0.5で50%）
                              backgroundColor: AppColors.nonActive,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.pink),
                            ),
                          ),
                        ),
                        const Icon(Icons.favorite,
                            color: Colors.pink, size: 18),
                        const Text('50',
                            style: TextStyle(
                                color: AppColors.mainText, fontSize: 14)),
                        Text('/100',
                            style: TextStyle(
                                color: AppColors.mainText, fontSize: 12)),
                      ],
                    ),
                  ),
                ),
                // 4. 吹き出し
                Positioned(
                  // キャラクターの頭の位置に合わせて調整
                  top: MediaQuery.of(context).size.height * 0.15,
                  left: MediaQuery.of(context).size.width * 0.2,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.mainBackground,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: const [
                        BoxShadow(
                          color: AppColors.shadow,
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Text(
                      'いつもありがとうございます先輩！\n大好きです…',
                      style: TextStyle(fontSize: 14, color: AppColors.mainText),
                    ),
                  ),
                ),
                // 5. 下部の円のアイコン（画像から推測）
                Positioned(
                  bottom:
                      MediaQuery.of(context).size.height * 0.02, // 画面下部からの位置を調整
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
                        child: const Icon(Icons.currency_yen,
                            color: AppColors.mainIcon, size: 45), // 円マークのアイコン
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // ナビゲーションバー (もしあればここに追加)
        ],
      ),
    );
  }
}
