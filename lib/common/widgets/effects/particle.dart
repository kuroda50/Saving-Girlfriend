import 'package:flutter/material.dart';

/// パーティクルデータクラス
class Particle {
  final double angle;
  final double distance;
  final double size;
  final Color color;
  final IconData? icon;

  Particle(this.angle, this.distance, this.size, this.color, this.icon);
}
