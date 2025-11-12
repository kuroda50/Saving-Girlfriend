// select_girlfriend_screen.dart

// Flutter imports:
import 'package:flutter/material.dart';
// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:math' as math;
import 'package:flutter_svg/flutter_svg.dart';

// Project imports:
import 'package:saving_girlfriend/common/constants/assets.dart';
import 'package:saving_girlfriend/common/constants/characters.dart';
import 'package:saving_girlfriend/common/constants/color.dart';
import 'package:saving_girlfriend/common/providers/current_girlfriend_provider.dart';
import 'package:saving_girlfriend/common/services/local_storage_service.dart';
import 'package:saving_girlfriend/features/story/services/notification_service.dart';
// 切り出したウィジェットのインポート
import 'package:saving_girlfriend/features/select_girlfriend/widgets/girlfriend_card.dart';

class SelectGirlfriendScreen extends ConsumerStatefulWidget {
  const SelectGirlfriendScreen({super.key});

  @override
  ConsumerState<SelectGirlfriendScreen> createState() =>
      _SelectGirlfriendScreenState();
}

class _SelectGirlfriendScreenState
    extends ConsumerState<SelectGirlfriendScreen> {
  late PageController _pageController;
  int _currentIndex = 0; // ロジックでのみ使用されるインデックス

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

  // Coming Soonキャラクターが選択されたときに表示するダイアログ (ロジック変更なし)
  void _showComingSoonDialog() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color.fromARGB(255, 255, 230, 240),
                  Color.fromARGB(255, 255, 210, 225),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20.0),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.5),
                  spreadRadius: 3,
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  '💖 Coming Soon 💖',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primary,
                    fontFamily: 'Noto Sans JP',
                  ),
                ),
                const SizedBox(height: 15),
                const Text(
                  'この彼女は準備中です。\nもうちょっと待っててね！',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.secondary,
                    fontFamily: 'Noto Sans JP',
                  ),
                ),
                const SizedBox(height: 25),
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                  ),
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text(
                    'OK',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 彼女を選択し、状態を保存して次の画面へ遷移するメソッド (ロジック変更なし)
  void _selectGirlfriendAndSaveState() async {
    // 💡 currentIndex は常に最新の値が保持されている
    final selectedCharacter = characters[_currentIndex];
    final selectedCharacterId = selectedCharacter.id;

    if (selectedCharacterId.startsWith('coming_soon')) {
      if (mounted) {
        _showComingSoonDialog();
      }
      return;
    }

    final bool? shouldSelect = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color.fromARGB(255, 255, 230, 240),
                  Color.fromARGB(255, 255, 210, 225),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20.0),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.5),
                  spreadRadius: 3,
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  '${selectedCharacter.name} を運命の彼女に決定しますか？',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                    fontFamily: 'Noto Sans JP',
                  ),
                ),
                const SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor:
                            AppColors.thirdBackground.withOpacity(0.5),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                      ),
                      onPressed: () => Navigator.of(dialogContext).pop(false),
                      child: const Text(
                        'キャンセル',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16),
                      ),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                      ),
                      onPressed: () => Navigator.of(dialogContext).pop(true),
                      child: const Text(
                        '決定！',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (shouldSelect != true) {
      return;
    }

    await ref
        .read(currentGirlfriendProvider.notifier)
        .selectGirlfriend(selectedCharacterId);

    final notificationService = ref.read(notificationServiceProvider);
    await notificationService.cancelAllNotifications();

    await notificationService.scheduleDailyNotification(selectedCharacterId, 1);

    final localStorage = await ref.read(localStorageServiceProvider.future);
    final hasPlayedEpisode0 =
        localStorage.hasPlayedEpisode0(selectedCharacterId);

    if (mounted) {
      if (hasPlayedEpisode0) {
        context.go('/home');
      } else {
        context.go('/story', extra: 0);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    const double maxImageWidthRatio = 0.95;
    final double maxImageWidth = screenWidth * maxImageWidthRatio;

    return Scaffold(
      backgroundColor: AppColors.forthBackground,
      appBar: AppBar(
        backgroundColor: AppColors.secondary,
        elevation: 0,
      ),
      // LayoutBuilderでbodyをラップ
      body: LayoutBuilder(
        builder: (context, constraints) {
          // AppBarを除いた利用可能なボディの高さを取得
          final bodyHeight = constraints.maxHeight;

          // 画像の高さをbodyHeightの50%に設定
          final double imageHeight = bodyHeight * 0.50;

          return Center(
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
                  height: bodyHeight, // bodyHeightを使用
                  width: screenWidth,
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: characters.length,
                    onPageChanged: (index) {
                      // 修正点:setStateを削除し、currentIndexを直接更新
                      _currentIndex = index;
                    },
                    itemBuilder: (context, index) {
                      final character = characters[index];
                      return CharacterCard(
                        character: character,
                        maxImageWidth: maxImageWidth,
                        imageHeight: imageHeight, // bodyHeight基準の高さを使用
                        onTap: _selectGirlfriendAndSaveState,
                      );
                    },
                  ),
                ),

                // 左矢印ボタン (SVGに置き換え + 10度回転)
                Positioned(
                  top: bodyHeight * 0.35, // bodyHeightを基準に配置
                  left: 10,
                  child: IconButton(
                    onPressed: () {
                      if (_pageController.hasClients &&
                          _pageController.page! > 0) {
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
                  top: bodyHeight * 0.35, // bodyHeightを基準に配置
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
                      angle: math.pi / 5,
                      child: SvgPicture.asset(
                        AppAssets.iconmigi,
                        width: 50,
                        height: 50,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
