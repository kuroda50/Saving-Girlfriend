// Flutter imports:
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:saving_girlfriend/common/constants/assets.dart';
import 'package:saving_girlfriend/common/providers/current_girlfriend_provider.dart';
import 'package:saving_girlfriend/common/services/local_storage_service.dart';

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
                  child: _TitleSection(
                    glowController: _glowController,
                    size: size,
                  ),
                ),
              ),

              // 下部：ボタンセクション
              Expanded(
                flex: 2,
                child: Center(
                  child: _StartButton(
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

// タイトルセクションウィジェット
class _TitleSection extends StatelessWidget {
  final AnimationController glowController;
  final Size size;

  const _TitleSection({
    required this.glowController,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: glowController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFFF5E6).withOpacity(
                  0.5 + (glowController.value * 0.3),
                ),
                blurRadius: 10 + (glowController.value * 10),
                spreadRadius: 2,
              ),
            ],
          ),
          child: child,
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // メインタイトル
          Stack(
            children: [
              // タイトルの影
              Text(
                '貯金彼女',
                style: TextStyle(
                  fontSize: size.width * 0.15,
                  fontWeight: FontWeight.bold,
                  foreground: Paint()
                    ..style = PaintingStyle.stroke
                    ..strokeWidth = 4
                    ..color = const Color(0xFF8B6F47),
                  letterSpacing: size.width * 0.01,
                ),
              ),
              // タイトル本体
              Text(
                '貯金彼女',
                style: TextStyle(
                  fontSize: size.width * 0.15,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFFFF5E6),
                  letterSpacing: size.width * 0.01,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // サブタイトル
          Stack(
            children: [
              Text(
                '〜彼女と送る貯金生活〜',
                style: TextStyle(
                  fontSize: size.width * 0.045,
                  foreground: Paint()
                    ..style = PaintingStyle.stroke
                    ..strokeWidth = 2
                    ..color = const Color(0xFF8B6F47),
                  letterSpacing: size.width * 0.003,
                ),
              ),
              Text(
                '〜彼女と送る貯金生活〜',
                style: TextStyle(
                  fontSize: size.width * 0.045,
                  color: const Color(0xFFFFF5E6),
                  letterSpacing: size.width * 0.003,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// スタートボタンウィジェット
class _StartButton extends StatefulWidget {
  final AnimationController floatController;
  final Size size;
  final VoidCallback onTap;

  const _StartButton({
    required this.floatController,
    required this.size,
    required this.onTap,
  });

  @override
  State<_StartButton> createState() => _StartButtonState();
}

class _StartButtonState extends State<_StartButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.floatController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, -8 * widget.floatController.value),
          child: child,
        );
      },
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) {
          setState(() => _isPressed = false);
          widget.onTap();
        },
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          transform: Matrix4.translationValues(
            0,
            _isPressed ? 4 : 0,
            0,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: _isPressed
                  ? [
                      const Color(0xFFE6D4A8),
                      const Color(0xFFD4C296),
                      const Color(0xFFC4B086),
                    ]
                  : [
                      const Color(0xFFFFF9E6),
                      const Color(0xFFF5E6C8),
                      const Color(0xFFE6D4A8),
                    ],
            ),
            border: Border.all(
              color: const Color(0xFF8B6F47),
              width: 4,
            ),
            boxShadow: _isPressed
                ? [
                    const BoxShadow(
                      color: Color(0xFF6B5A3D),
                      offset: Offset(0, 2),
                      blurRadius: 0,
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      offset: const Offset(0, 4),
                      blurRadius: 10,
                    ),
                  ]
                : [
                    const BoxShadow(
                      color: Color(0xFF6B5A3D),
                      offset: Offset(0, 6),
                      blurRadius: 0,
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      offset: const Offset(0, 10),
                      blurRadius: 20,
                    ),
                    BoxShadow(
                      color: Colors.white.withOpacity(0.5),
                      offset: const Offset(0, 2),
                      blurRadius: 0,
                      spreadRadius: -2,
                    ),
                  ],
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: widget.size.width * 0.12,
              vertical: widget.size.height * 0.02,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'TAP TO START',
                  style: TextStyle(
                    fontSize: widget.size.width * 0.055,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF5C4B3A),
                    shadows: [
                      Shadow(
                        color: Colors.white.withOpacity(0.5),
                        offset: const Offset(1, 1),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'はじめる',
                  style: TextStyle(
                    fontSize: widget.size.width * 0.03,
                    color: const Color(0xFF5C4B3A).withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// スパークルパーティクルデータクラス
class SparkleParticle {
  final double x;
  final double y;
  final double delay;

  SparkleParticle({
    required this.x,
    required this.y,
    required this.delay,
  });
}

// スパークルウィジェット
class SparkleWidget extends StatefulWidget {
  final SparkleParticle sparkle;
  final Size size;

  const SparkleWidget({
    super.key,
    required this.sparkle,
    required this.size,
  });

  @override
  State<SparkleWidget> createState() => _SparkleWidgetState();
}

class _SparkleWidgetState extends State<SparkleWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget.sparkle.x * widget.size.width,
      top: widget.sparkle.y * widget.size.height,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final value = (_controller.value + widget.sparkle.delay) % 1.0;
          final opacity = value < 0.5 ? value * 2 : (1 - value) * 2;
          final scale = value < 0.5 ? value * 2 : (1 - value) * 2;

          return Opacity(
            opacity: opacity,
            child: Transform.scale(
              scale: scale,
              child: Container(
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
