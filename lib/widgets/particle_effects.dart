import 'dart:math';
import 'package:flutter/material.dart';

/// ✨ エフェクトウィジェット（古い・未使用なら削除推奨）
class _SparkleEffect extends StatefulWidget {
  final Offset position;
  const _SparkleEffect({required this.position});

  @override
  State<_SparkleEffect> createState() => _SparkleEffectState();
}

class _SparkleEffectState extends State<_SparkleEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final Random _random = Random();
  late double _sparkleSize;
  late IconData _icon;
  late Color _color;

  final _pastelColors = [
    Colors.pinkAccent.withOpacity(0.6),
    Colors.yellowAccent.withOpacity(0.5),
    Colors.white.withOpacity(0.8),
    Colors.purpleAccent.withOpacity(0.4),
  ];

  final _icons = [Icons.favorite, Icons.star_rounded];

  @override
  void initState() {
    super.initState();
    _sparkleSize = 20 + _random.nextDouble() * 10;
    _icon = _icons[_random.nextInt(_icons.length)];
    _color = _pastelColors[_random.nextInt(_pastelColors.length)];

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..forward();
  }

  @override
  void dispose() {
    _controller.stop();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ... (buildメソッドは省略) ...
    final position = widget.position;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final progress = Curves.easeOut.transform(_controller.value);
        final opacity = 1 - progress;
        final scale = 1 + progress * 0.6;
        final dy = position.dy - (progress * 30); // ふわっと上に移動

        return Positioned(
          left: position.dx - (_sparkleSize / 2),
          top: dy - (_sparkleSize / 2),
          child: IgnorePointer(
            ignoring: true,
            child: Opacity(
              opacity: opacity,
              child: Transform.scale(
                scale: scale,
                child: Icon(
                  _icon,
                  color: _color,
                  size: _sparkleSize,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// ✨ タップで散る光エフェクト (指を離した時用・大きい)
class TapSparkleBurst extends StatefulWidget {
  final Offset position;
  const TapSparkleBurst({super.key, required this.position});

  @override
  State<TapSparkleBurst> createState() => _TapSparkleBurstState();
}

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

/// パーティクルデータクラス
class Particle {
  // ← OK
  final double angle;
  final double distance;
  final double size;
  final Color color;
  final IconData? icon;

  Particle(this.angle, this.distance, this.size, this.color, this.icon); // ← OK
}

// ふわっとした軌跡パーティクル用
class TrailParticle extends StatefulWidget {
  final Offset position;
  const TrailParticle({super.key, required this.position});

  @override
  State<TrailParticle> createState() => _TrailParticleState();
}

class _TrailParticleState extends State<TrailParticle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final Random _rand = Random();
  late Color _color;

  @override
  void initState() {
    super.initState();
    _color = [
      Colors.pinkAccent,
      Colors.white,
      Colors.purpleAccent,
      Colors.yellowAccent,
    ][_rand.nextInt(4)]
        .withOpacity(0.6);

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..forward();

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (mounted) {
          _controller.stop();
        }
      }
    });
  }

  @override
  void dispose() {
    try {
      _controller.stop();
      _controller.dispose();
    } catch (_) {
      // 念のため例外は握りつぶす
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // (buildメソッドは省略) ...
    final p = widget.position;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = Curves.easeOut.transform(_controller.value);
        final opacity = 1 - t;
        final dy = p.dy - t * 10;
        return Positioned(
          left: p.dx,
          top: dy,
          child: Opacity(
            opacity: opacity,
            child: Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: _color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _color.withOpacity(0.5),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
