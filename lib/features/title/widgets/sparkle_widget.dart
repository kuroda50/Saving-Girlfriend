import 'package:flutter/material.dart';

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
