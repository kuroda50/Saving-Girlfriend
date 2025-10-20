/* 彼女選択画面 */

import 'package:flutter/material.dart';
import 'package:saving_girlfriend/constants/assets.dart';
import 'package:saving_girlfriend/constants/color.dart';
import 'package:saving_girlfriend/screen/select_story_screen.dart';
import 'package:saving_girlfriend/screen/story_screen.dart';
import 'package:shared_preferences/shared_preferences.dart'; // 👈 1. 状態保存のためのパッケージをインポート
import 'package:go_router/go_router.dart';

class SelectGirlfriendScreen extends StatefulWidget {
  const SelectGirlfriendScreen({super.key});

  @override
  State<SelectGirlfriendScreen> createState() => _SelectGirlfriendScreenState();
}

class _SelectGirlfriendScreenState extends State<SelectGirlfriendScreen> {
  // 表示するキャラクターのリスト
  final List<Map<String, dynamic>> characters = [
    {
      'name': '鈴鳴 音', // キャラクター名
      'image': 'assets/images/character/suzunari.png', // 鈴鳴音の画像URL (ローカルアセット)
      'description_tags': [
        '#あざとい',
        '#高校の後輩',
        '#甘え上手',
        '#小悪魔系',
        '#からかい上手'
      ], // 説明タグ
    },
    {
      'name': 'ComingSoon',
      'image': AppAssets.characterComingsoon,
      'description_tags': ['ComingSoon'],
    },
    {
      'name': 'ComingSoon',
      'image': AppAssets.characterComingsoon,
      'description_tags': ['ComingSoon'],
    },
  ];

  late PageController _pageController; // PageViewを制御するためのPageController
  int _currentIndex = 0; // 現在表示されているキャラクターのインデックス（PageViewによって更新される）

  @override
  void initState() {
    super.initState();
    // PageControllerを初期化し、初期ページを設定
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    // PageControllerを破棄
    _pageController.dispose();
    super.dispose();
  }

  // 👈 2. 彼女を選択し、状態を保存して次の画面へ遷移するメソッド
  void _selectGirlfriendAndSaveState() async {
    // 選択しようとしているキャラクターが「ComingSoon」ではないかチェック
    if (characters[_currentIndex]['name'] == 'ComingSoon') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('この彼女はまだ選べません。')),
      );
      return;
    }

    // 1. SharedPreferencesのインスタンスを取得
    final prefs = await SharedPreferences.getInstance();

    // 4. 次の画面へ遷移
    final hasPlayed = prefs.getBool('has_played_story') ?? false;
    final String nextPath = hasPlayed
        ? '/home' // 再生済みならホーム画面
        : '/story'; // (到達しないはず)

    if (mounted) {
      context.go(nextPath);
    }
    // 2. 「彼女が選択された」という状態を永続的に保存 (TitleScreenでチェックするフラグ)
    await prefs.setBool('has_selected_girlfriend', true);

    // 3. 選択した彼女のインデックスや名前も保存しておくと、後で利用できる
    final selectedGirlfriendName = characters[_currentIndex]['name'] as String;
    await prefs.setString('selected_girlfriend_name', selectedGirlfriendName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.secondary,
      ),
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // キャラクターのスライド表示を処理するためのPageView
            // PageViewがStack内で適切なサイズを持つようにSizedBoxを使用
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.7, // 画面の高さの70%に調整
              width: MediaQuery.of(context).size.width, // 全幅
              child: PageView.builder(
                controller: _pageController, // PageControllerをPageViewにアタッチ
                itemCount: characters.length, // キャラクターの総数
                onPageChanged: (index) {
                  // ページが変更されたときに現在のインデックスを更新
                  setState(() {
                    _currentIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  // スライドする個々のキャラクターカード
                  return Column(
                    // PageView内でカードを垂直方向中央に配置するためにColumnを使用
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20.0),
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: AppColors.mainBackground,
                          borderRadius: BorderRadius.circular(15.0),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.shadow,
                              spreadRadius: 2,
                              blurRadius: 7,
                              offset: const Offset(0, 3), // 影の位置
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // キャラクター名
                            Container(
                              // ピンクの背景と角丸のためにContainerを追加
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              decoration: BoxDecoration(
                                color: const Color(0xE383AB), // ピンクの背景色
                                borderRadius: BorderRadius.circular(20.0), // 角丸
                              ),
                              child: Text(
                                characters[index]
                                    ['name'], // PageView.builderの'index'を使用
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.mainText, // 白い文字色
                                  fontFamily:
                                      'Noto Sans JP', // 日本語文字用にNoto Sans JPを使用
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            // キャラクター画像
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10.0),
                              // ⚠️ ローカルアセットのパスであるため Image.network を Image.asset に変更
                              child: Image.asset(
                                characters[index]
                                    ['image'], // PageView.builderの'index'を使用
                                height: 300,
                                width: 250,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    height: 300,
                                    width: 250,
                                    color: AppColors.border,
                                    child: const Icon(Icons.broken_image,
                                        size: 50, color: AppColors.subIcon),
                                    alignment: Alignment.center,
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 15),
                            // 説明タグのコンテナ
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppColors.secondary,
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: Wrap(
                                spacing: 8.0,
                                runSpacing: 4.0,
                                children: (characters[index]['description_tags']
                                        as List<
                                            String>) // PageView.builderの'index'を使用
                                    .map((tag) => Text(
                                          tag,
                                          style: const TextStyle(
                                            color: AppColors.primary,
                                            fontSize: 16,
                                            fontFamily: 'Noto Sans JP',
                                          ),
                                        ))
                                    .toList(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            // 左矢印ボタン
            Positioned(
              left: 10, // カードの外側、端に近い位置に調整
              child: IconButton(
                icon: Icon(Icons.arrow_back_ios,
                    size: 40, color: AppColors.primary),
                onPressed: () {
                  // コントローラーがアタッチされており、最初のページではない場合のみ実行
                  if (_pageController.hasClients && _pageController.page! > 0) {
                    _pageController.previousPage(
                      duration: const Duration(milliseconds: 300), // アニメーション時間
                      curve: Curves.easeIn, // アニメーションカーブ
                    );
                  }
                },
              ),
            ),
            // 右矢印ボタン
            Positioned(
              right: 10, // 位置を調整
              child: IconButton(
                icon: Icon(Icons.arrow_forward_ios,
                    size: 40, color: AppColors.primary),
                onPressed: () {
                  // コントローラーがアタッチされており、最後のページではない場合のみ実行
                  if (_pageController.hasClients &&
                      _pageController.page! < characters.length - 1) {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300), // アニメーション時間
                      curve: Curves.easeIn, // アニメーションカーブ
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
      // 👈 3. 画面下部に「彼女を選ぶ」ボタンを追加
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary, // ボタンの背景色
            minimumSize: const Size(double.infinity, 50), // ボタンのサイズ
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: _selectGirlfriendAndSaveState, // 選択処理を呼び出す
          child: const Text(
            'この彼女を選ぶ',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.subText, // 文字色
            ),
          ),
        ),
      ),
    );
  }
}
