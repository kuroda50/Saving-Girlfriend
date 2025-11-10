// Flutter imports:
import 'package:flutter/material.dart';
// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:math' as math;
import 'package:flutter_svg/flutter_svg.dart'; // SVG対応のために追加
// Project imports:
import 'package:saving_girlfriend/common/constants/assets.dart';
import 'package:saving_girlfriend/common/constants/characters.dart';
import 'package:saving_girlfriend/common/constants/color.dart';
import 'package:saving_girlfriend/common/providers/current_girlfriend_provider.dart';
import 'package:saving_girlfriend/common/services/local_storage_service.dart';
import 'package:saving_girlfriend/features/story/services/notification_service.dart';

class SelectGirlfriendScreen extends ConsumerStatefulWidget {
  const SelectGirlfriendScreen({super.key});

  @override
  ConsumerState<SelectGirlfriendScreen> createState() =>
      _SelectGirlfriendScreenState();
}

class _SelectGirlfriendScreenState
    extends ConsumerState<SelectGirlfriendScreen> {
  late PageController _pageController; // PageViewを制御するためのPageController
  int _currentIndex = 0; // 現在表示されているキャラクターのインデックス

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // 彼女を選択し、状態を保存して次の画面へ遷移するメソッド
  void _selectGirlfriendAndSaveState() async {
    final selectedCharacterId = characters[_currentIndex].id;

    // 選択しようとしているキャラクターが「ComingSoon」ではないかチェック
    if (selectedCharacterId.startsWith('coming_soon')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ここはまだ選べません。')),
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
    // 画面サイズを取得
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // 画像の最大幅を画面幅の95%に設定
    const double maxImageWidthRatio = 0.95;
    final double maxImageWidth = screenWidth * maxImageWidthRatio;

    // ⭐画像の高さを画面の約80%に設定（五分の四に拡大）
    final double imageHeight = screenHeight * 0.50;

    return Scaffold(
      backgroundColor: AppColors.forthBackground, // 背景色
      appBar: AppBar(
        backgroundColor: AppColors.secondary,
        elevation: 0,
      ),
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 背景画像
            Positioned.fill(
              child: Image.asset(
                AppAssets.backgroundHomeScreen,
                fit: BoxFit.cover,
              ),
            ),
            // キャラクターのスライド表示を処理するためのPageView
            SizedBox(
              height: screenHeight, // 画面の高さ全体を使用
              width: screenWidth, // 全幅
              child: PageView.builder(
                controller: _pageController,
                itemCount: characters.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  final character = characters[index];

                  return GestureDetector(
                    onTap: _selectGirlfriendAndSaveState,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 10.0),
                          padding: const EdgeInsets.all(10.0),
                          constraints: BoxConstraints(
                            maxWidth: maxImageWidth + 20,
                          ),
                          decoration: BoxDecoration(
                            // 少女漫画風デザイン: グラデーション
                            gradient: const LinearGradient(
                              colors: [
                                Color.fromARGB(255, 255, 230, 240), // 非常に淡いピンク
                                Color.fromARGB(255, 255, 210, 225), // 淡いピンク
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius:
                                BorderRadius.circular(25.0), // さらに丸みを帯びさせる
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary
                                    .withOpacity(0.5), // 影の色を濃く、柔らかく
                                spreadRadius: 3,
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // 1. キャラクター画像
                              ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(20.0), // 角丸を大きく
                                child: Image.asset(
                                  character.image, // ★ キャラクター画像を表示
                                  height: imageHeight, // ⭐ここが80%の高さ
                                  width: maxImageWidth, // 画像を最大限まで拡大
                                  fit: BoxFit.fitHeight, // 高さに合わせて画像をフィットさせる
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      height: imageHeight,
                                      width: maxImageWidth,
                                      color: AppColors.border,
                                      alignment: Alignment.center,
                                      child: const Icon(Icons.broken_image,
                                          size: 50, color: AppColors.subIcon),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 15),
                              // 2. キャラクター名 (濃いピンクのハイライト)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 25, vertical: 8),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(30.0),
                                ),
                                child: Text(
                                  character.name, // ★ キャラクター名を表示
                                  style: const TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white, // 白い文字色
                                    fontFamily: 'Noto Sans JP',
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              // 3. 説明タグのコンテナ
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 40, vertical: 7),
                                decoration: BoxDecoration(
                                  color: const Color.fromARGB(255, 236, 92, 140)
                                      .withOpacity(0.8), // タグの背景色を調整
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                child: Wrap(
                                  spacing: 7.0,
                                  runSpacing: 4.0,
                                  children: character.description_tags
                                      .map((tag) => Text(
                                            tag,
                                            style: const TextStyle(
                                              color: AppColors.forthBackground,
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

            // 左矢印ボタン (SVGに置き換え + 10度回転)
            Positioned(
              top: screenHeight * 0.35, // 縦方向中央付近に配置
              left: 10,
              child: IconButton(
                onPressed: () {
                  if (_pageController.hasClients && _pageController.page! > 0) {
                    _pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeIn,
                    );
                  }
                },
                icon: Transform.rotate(
                  angle: -math.pi / 5,
                  child: SvgPicture.asset(
                    AppAssets.iconhidari,
                    width: 50,
                    height: 50,
                  ),
                ),
              ),
            ),
            // 右矢印ボタン (SVGに置き換え + 10度回転)
            Positioned(
              top: screenHeight * 0.35, // 縦方向中央付近に配置
              right: 10,
              child: IconButton(
                onPressed: () {
                  if (_pageController.hasClients &&
                      _pageController.page! < characters.length - 1) {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeIn,
                    );
                  }
                },
                icon: Transform.rotate(
                  angle: math.pi / 5, // 時計回りに10度に相当するラジアン値
                  child: SvgPicture.asset(
                    AppAssets.iconmigi, // SVG画像パス
                    width: 50,
                    height: 50,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
