import 'package:flutter/material.dart';

// タイトルセクションウィジェット
class TitleSection extends StatelessWidget {
  final AnimationController glowController;
  final Size size;

  const TitleSection({
    super.key,
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
