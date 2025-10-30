import 'dart:math';
import 'package:flutter/material.dart';

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
