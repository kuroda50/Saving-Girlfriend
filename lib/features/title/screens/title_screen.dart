// Flutter imports:
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:saving_girlfriend/common/constants/assets.dart';
import 'package:saving_girlfriend/common/providers/current_girlfriend_provider.dart';
import 'package:saving_girlfriend/common/services/local_storage_service.dart';
import 'package:saving_girlfriend/features/title/widgets/sparkle_widget.dart';
import 'package:saving_girlfriend/features/title/widgets/start_button.dart';
import 'package:saving_girlfriend/features/title/widgets/title_section.dart';

class TitleScreen extends ConsumerStatefulWidget {
  const TitleScreen({super.key});

  @override
  ConsumerState<TitleScreen> createState() => _TitleScreenState();
}

class _TitleScreenState extends ConsumerState<TitleScreen>
    with TickerProviderStateMixin {
  late AnimationController _glowController;
  late AnimationController _floatController;
  final List<SparkleParticle> _sparkles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();

    // タイトルグローアニメーション
    _glowController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    // ボタンフロートアニメーション
    _floatController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    // スパークルエフェクトの生成
    _generateSparkles();
  }

  void _generateSparkles() {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _sparkles.add(SparkleParticle(
            x: _random.nextDouble(),
            y: _random.nextDouble(),
            delay: _random.nextDouble() * 2,
          ));
          if (_sparkles.length > 20) {
            _sparkles.removeAt(0);
          }
        });
        _generateSparkles();
      }
    });
  }

  @override
  void dispose() {
    _glowController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  void _navigateToNextScreen() async {
    // 選択している彼女と、0話を再生したか確認
    final localStorage = await ref.read(localStorageServiceProvider.future);
    final currentGirlfriendId =
        await ref.read(currentGirlfriendProvider.future);
    final hasPlayedEpisode0 =
        localStorage.hasPlayedEpisode0(currentGirlfriendId!);

    if (mounted) {
      if (currentGirlfriendId == '') {
        // 彼女が選択されていなければキャラ選択画面へ
        context.go('/select_girlfriend');
      } else if (hasPlayedEpisode0) {
        // 0話再生済みならホーム画面へ
        context.go('/home');
      } else {
        // 未再生なら0話を再生
        context.go('/story', extra: 0);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // 背景画像
          Positioned.fill(
            child: Image.asset(
              AppAssets.backgroundTitle,
              fit: BoxFit.cover,
            ),
          ),

          // グラデーションオーバーレイ
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.1),
                  ],
                ),
              ),
            ),
          ),

          // スパークルエフェクト
          ..._sparkles.map((sparkle) => SparkleWidget(
                sparkle: sparkle,
                size: size,
              )),

          // メインコンテンツ
          Column(
            children: [
              // 上部：タイトルセクション
              Expanded(
                flex: 3,
                child: Center(
                  child: TitleSection(
                    glowController: _glowController,
                    size: size,
                  ),
                ),
              ),

              // 下部：ボタンセクション
              Expanded(
                flex: 2,
                child: Center(
                  child: StartButton(
                    floatController: _floatController,
                    size: size,
                    onTap: _navigateToNextScreen,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
