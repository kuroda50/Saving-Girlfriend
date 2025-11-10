// lib/common/providers/particle_provider.dart (修正後のコード)

// Package imports:
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

// 1. 管理するパーティクルのデータ構造
class Particle {
  final String id;
  final Offset position;

  Particle({required this.position}) : id = const Uuid().v4();
}

// 2. パーティクルの状態を定義
@immutable
class ParticleState {
  final List<Particle> sparkles;
  final List<Particle> trailParticles;
  final List<Particle> swipeSparkles;
  final List<Particle> tapRipples; // ← ★ 1. 新しいリストを追加

  const ParticleState({
    this.sparkles = const [],
    this.trailParticles = const [],
    this.swipeSparkles = const [],
    this.tapRipples = const [], // ← ★ 1. 初期値を追加
  });

  ParticleState copyWith({
    List<Particle>? sparkles,
    List<Particle>? trailParticles,
    List<Particle>? swipeSparkles,
    List<Particle>? tapRipples, // ← ★ 1. copyWith に追加
  }) {
    return ParticleState(
      sparkles: sparkles ?? this.sparkles,
      trailParticles: trailParticles ?? this.trailParticles,
      swipeSparkles: swipeSparkles ?? this.swipeSparkles,
      tapRipples: tapRipples ?? this.tapRipples, // ← ★ 1. copyWith に追加
    );
  }
}

// 3. StateNotifier（専属マネージャー）を定義
class ParticleNotifier extends StateNotifier<ParticleState> {
  ParticleNotifier() : super(const ParticleState());

  DateTime? _lastSparkleTime;
  DateTime? _lastTrailTime;
  DateTime? _lastRippleTime; // ← ★ 2. 波紋用のスロットル時間を追加
  final Random _random = Random();

  // ▼▼▼▼ 【新設】タップ時の「波紋」専用メソッド ▼▼▼▼
  void addTapRipple(Offset position) {
    // スロットル（間引き）処理
    const interval = Duration(milliseconds: 50); // 50ms間隔
    final now = DateTime.now();
    if (_lastRippleTime != null &&
        now.difference(_lastRippleTime!) < interval) {
      return;
    }
    _lastRippleTime = now;

    final ripple = Particle(position: position);

    state = state.copyWith(
      tapRipples: [...state.tapRipples, ripple],
    );

    // 波紋の削除 (600ms後。TapRippleEffectのアニメーション時間と合わせる)
    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      state = state.copyWith(
        tapRipples: state.tapRipples.where((p) => p.id != ripple.id).toList(),
      );
    });
  }
  // ▲▲▲▲ 【新設】ここまで ▲▲▲▲

  // スワイプ中の「軌跡」専用メソッド (変更なし)
  void addTrail(Offset position) {
    const interval = Duration(milliseconds: 30);
    final now = DateTime.now();
    if (_lastTrailTime != null && now.difference(_lastTrailTime!) < interval) {
      return;
    }
    _lastTrailTime = now;

    final trail = Particle(position: position);
    state = state.copyWith(
      trailParticles: [...state.trailParticles, trail],
    );

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      state = state.copyWith(
        trailParticles:
            state.trailParticles.where((p) => p.id != trail.id).toList(),
      );
    });
  }

  // （ボタン用）「小さい破裂」専用メソッド (変更なし)
  void addSparkle(Offset position) {
    const interval = Duration(milliseconds: 20);
    final now = DateTime.now();
    if (_lastSparkleTime != null &&
        now.difference(_lastSparkleTime!) < interval) {
      return;
    }
    _lastSparkleTime = now;

    final swipeSparkle = Particle(position: position);
    state = state.copyWith(
      swipeSparkles: [...state.swipeSparkles, swipeSparkle],
    );

    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      state = state.copyWith(
        swipeSparkles:
            state.swipeSparkles.where((p) => p.id != swipeSparkle.id).toList(),
      );
    });
  }

  // （ボタン用）「大きい破裂」専用メソッド (変更なし)
  void addSwipeTrail(Offset pos) {
    // ... (変更なし) ...
    for (int i = 0; i < 3; i++) {
      Future.delayed(Duration(milliseconds: i * 60), () {
        if (!mounted) return;
        final offset = pos +
            Offset(
              (_random.nextDouble() - 0.5) * 25,
              (_random.nextDouble() - 0.5) * 25,
            );
        final sparkle = Particle(position: offset);
        state = state.copyWith(sparkles: [...state.sparkles, sparkle]);
        Future.delayed(const Duration(milliseconds: 1000), () {
          if (!mounted) return;
          state = state.copyWith(
            sparkles: state.sparkles.where((p) => p.id != sparkle.id).toList(),
          );
        });
      });
    }
    final burstSparkle = Particle(position: pos);
    state = state.copyWith(sparkles: [...state.sparkles, burstSparkle]);
    Future.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      state = state.copyWith(
        sparkles: state.sparkles.where((p) => p.id != burstSparkle.id).toList(),
      );
    });
  }
}

// 4. Providerを定義
final particleProvider = StateNotifierProvider<ParticleNotifier, ParticleState>(
  (ref) => ParticleNotifier(),
);
