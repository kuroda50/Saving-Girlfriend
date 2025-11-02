/* 彼女選択画面 */

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:saving_girlfriend/constants/characters.dart';
import 'package:saving_girlfriend/constants/color.dart';
import 'package:saving_girlfriend/providers/current_girlfriend_provider.dart';
import 'package:saving_girlfriend/services/local_storage_service.dart';
import 'package:saving_girlfriend/services/notification_service.dart';

class SelectGirlfriendScreen extends ConsumerStatefulWidget {
  // Change to ConsumerStatefulWidget
  const SelectGirlfriendScreen({super.key});

  @override
  ConsumerState<SelectGirlfriendScreen> createState() =>
      _SelectGirlfriendScreenState(); // Change to ConsumerState
}

class _SelectGirlfriendScreenState
    extends ConsumerState<SelectGirlfriendScreen> {
  // Change to ConsumerState

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
    final selectedCharacterId = characters[_currentIndex].id;

    // 選択しようとしているキャラクターが「ComingSoon」ではないかチェック
    if (selectedCharacterId.startsWith('coming_soon')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('この彼女はまだ選べません。')),
      );
      return;
    }

    // Riverpodのプロバイダーを使って選択された彼女を保存
    await ref
        .read(currentGirlfriendProvider.notifier)
        .selectGirlfriend(selectedCharacterId);

    // 通知サービスを取得
    final notificationService = ref.read(notificationServiceProvider);
    // 既存の通知をすべてキャンセル
    await notificationService.cancelAllNotifications();

    // 選択された彼女の通知をスケジュール (通知IDは固定値1を使用)
    await notificationService.scheduleDailyNotification(selectedCharacterId, 1);

    // LocalStorageServiceを使って、0話が再生済みかチェック
    final localStorage = await ref.read(localStorageServiceProvider.future);
    final hasPlayedEpisode0 =
        localStorage.hasPlayedEpisode0(selectedCharacterId);

    if (mounted) {
      if (hasPlayedEpisode0) {
        // 0話再生済みならホーム画面へ
        context.go('/home');
      } else {
        // 未再生なら0話を再生
        context.go('/story', extra: 0); // 0話を再生
      }
    }
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
              height: MediaQuery.of(context).size.height * 0.9, // 画面の高さの70%に調整
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
                  return GestureDetector( // ★ issue84の機能: カード全体をタップで選択
                    onTap: _selectGirlfriendAndSaveState,
                    child: Column(
                      // PageView内でカードを垂直方向中央に配置するためにColumnを使用
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 20.0),
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: AppColors.mainBackground,
                            borderRadius: BorderRadius.circular(15.0),
                            boxShadow: const [ // ★ mainのconstを採用
                              BoxShadow(
                                color: AppColors.shadow,
                                spreadRadius: 2,
                                blurRadius: 7,
                                offset: Offset(0, 3), // 影の位置
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
                                  // ★ issue84のピンク色を採用 (透明度 0xFF を追加)
                                  color: const Color(0xFFE383AB), 
                                  borderRadius: BorderRadius.circular(20.0), // 角丸
                                ),
                                child: Text(
                                  characters[index]
                                      .name, // ★ mainのデータアクセス形式を採用
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
                                // ローカルアセットのパスであるため Image.asset を使用
                                child: Image.asset(
                                  characters[index]
                                      .image, // ★ mainのデータアクセス形式を採用
                                  height: 300,
                                  width: 250,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      height: 300,
                                      width: 250,
                                      color: AppColors.border,
                                      alignment: Alignment.center,
                                      child: const Icon(Icons.broken_image,
                                          size: 50, color: AppColors.subIcon),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 15),
                              // 説明タグのコンテナ (以前解決した部分のコードを再利用)
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
                                  children: characters[index]
                                      .descriptionTags // ★ mainのデータモデルに合わせたプロパティアクセスに変更
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
                    ),
                  );
                },
              ),
            ),
                                borderRadius: BorderRadius.circular(10.0),
                                // ⚠️ ローカルアセットのパスであるため Image.network を Image.asset に変更
                                child: Image.asset(
                                  characters[index]
                                      ['image'], // PageView.builderの'index'を使用
                                  height: 400,
                                  width: 350,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      height: 400,
                                      width: 350,
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
                                  children: (characters[index]
                                          ['description_tags'] as List<
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
                    ),
                  );
                },
              ),
            ),

            // 左矢印ボタン
            Positioned(
              left: 10, // カードの外側、端に近い位置に調整
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios,
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
                icon: const Icon(Icons.arrow_forward_ios,
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
    );
  }
}
