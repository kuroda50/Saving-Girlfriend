import 'dart:math';
import 'package:flutter/material.dart';

/// タップした瞬間に「波紋」が広がるエフェクト
class TapRippleEffect extends StatefulWidget {
  final Offset position;
  const TapRippleEffect({super.key, required this.position});

  @override
  State<TapRippleEffect> createState() => _TapRippleEffectState();
}

class _TapRippleEffectState extends State<TapRippleEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Color _color;
  final Random _rand = Random();

  @override
  void initState() {
    super.initState();
    _color = [
      Colors.pinkAccent,
      Colors.white,
      Colors.purpleAccent,
      Colors.yellowAccent,
    ][_rand.nextInt(4)]
        .withOpacity(0.7); // 少し濃いめの透明度

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600), // 0.6秒でアニメーション
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.position;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = Curves.easeOut.transform(_controller.value);
        final opacity = 1 - t; // だんだん消える (1 -> 0)
        final scale = t; // だんだん広がる (0 -> 1)
        const size = 60.0; // 波紋の最大サイズ

        return Positioned(
          // ★ 中心に来るように (size / 2) だけオフセット
          left: p.dx - (size / 2),
          top: p.dy - (size / 2),
          child: Opacity(
            opacity: opacity,
            child: Transform.scale(
              scale: scale,
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  // ★ 枠線だけの円（中身は透明）
                  border: Border.all(
                    color: _color,
                    width: 2.5, // 枠線の太さ
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: _color.withOpacity(0.5),
                      blurRadius: 10,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
