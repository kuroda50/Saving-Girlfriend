import 'dart:math';
import 'package:flutter/material.dart';
import 'particle.dart'; // ←★ さっき作った Particle を import

/// ✨「スワイプ中」の小さい光エフェクト
class SwipeSparkle extends StatefulWidget {
  final Offset position;
  const SwipeSparkle({super.key, required this.position});

  @override
  State<SwipeSparkle> createState() => _SwipeSparkleState();
}

// --- 「小さい」エフェクトの中身 ---
class _SwipeSparkleState extends State<SwipeSparkle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final Random _random = Random();
  late List<Particle> _particles; // ←★修正！ (_Particle -> Particle)

  final _colors = [
    Colors.pinkAccent.withOpacity(0.4),
    Colors.white.withOpacity(0.6),
    Colors.purpleAccent.withOpacity(0.3),
    Colors.yellowAccent.withOpacity(0.4),
  ];
  final _icons = [Icons.star_rounded, null]; // nullなら丸 (Favoriteを減らす)

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();

    _particles = List.generate(2 + _random.nextInt(2), (_) {
      final angle = _random.nextDouble() * 2 * pi;
      final distance = 10 + _random.nextDouble() * 15;
      final size = 2 + _random.nextDouble() * 4;
      final color = _colors[_random.nextInt(_colors.length)];
      final icon = _icons[_random.nextInt(_icons.length)];
      return Particle(
          angle, distance, size, color, icon); // ←★修正！ (_Particle -> Particle)
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // (buildメソッドは省略) ...
    final pos = widget.position;
    return Positioned.fill(
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final t = _controller.value;
            final opacity = 1 - t;
            return Stack(
              children: _particles.map((p) {
                final dx = pos.dx + cos(p.angle) * p.distance * t;
                final dy = pos.dy + sin(p.angle) * p.distance * t;

                return Positioned(
                  left: dx,
                  top: dy,
                  child: Opacity(
                    opacity: opacity,
                    child: Transform.scale(
                      scale: 0.8 + t,
                      child: p.icon != null
                          ? Icon(
                              p.icon,
                              color: p.color,
                              size: p.size * 2,
                            )
                          : Container(
                              width: p.size,
                              height: p.size,
                              decoration: BoxDecoration(
                                color: p.color,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: p.color.withOpacity(0.5),
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ),
    );
  }
}
