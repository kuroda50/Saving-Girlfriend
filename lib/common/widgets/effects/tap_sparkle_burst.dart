import 'dart:math';
import 'package:flutter/material.dart';
import 'particle.dart'; // ←★ さっき作った Particle を import

/// ✨ タップで散る光エフェクト (指を離した時用・大きい)
class TapSparkleBurst extends StatefulWidget {
  final Offset position;
  const TapSparkleBurst({super.key, required this.position});

  @override
  State<TapSparkleBurst> createState() => _TapSparkleBurstState();
}

// --- 「大きい」エフェクトの中身 ---
class _TapSparkleBurstState extends State<TapSparkleBurst>
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

  final _icons = [Icons.star_rounded, Icons.favorite, null]; // nullなら丸

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..forward();

    _particles = List.generate(4 + _random.nextInt(2), (_) {
      final angle = _random.nextDouble() * 2 * pi;
      final distance = 25 + _random.nextDouble() * 40;
      final size = 3 + _random.nextDouble() * 7;
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
