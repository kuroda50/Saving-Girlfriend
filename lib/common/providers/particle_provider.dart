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
  final List<Particle> sparkles; // 指を離した時の「大きい」破裂
  final List<Particle> trailParticles;
  final List<Particle> swipeSparkles; // スワイプ中の「小さい」破裂

  const ParticleState({
    this.sparkles = const [],
    this.trailParticles = const [],
    this.swipeSparkles = const [], // ←★追加
  });

  ParticleState copyWith({
    List<Particle>? sparkles,
    List<Particle>? trailParticles,
    List<Particle>? swipeSparkles, // ←★追加
  }) {
    return ParticleState(
      sparkles: sparkles ?? this.sparkles,
      trailParticles: trailParticles ?? this.trailParticles,
      swipeSparkles: swipeSparkles ?? this.swipeSparkles, // ←★追加
    );
  }
}

// 3. StateNotifier（専属マネージャー）を定義
class ParticleNotifier extends StateNotifier<ParticleState> {
  ParticleNotifier() : super(const ParticleState());

  // MyAppにあった _lastSparkleTime をこちらに移動
  DateTime? _lastSparkleTime;
  final Random _random = Random();

  // MyAppにあった _addSparkle のロジックを移植
  void addSparkle(Offset position) {
    // スロットル（間引き）処理
    const interval = Duration(milliseconds: 20); // ←★ ぱやぱやし過ぎなら 30 や 40 に増やす
    final now = DateTime.now();
    if (_lastSparkleTime != null &&
        now.difference(_lastSparkleTime!) < interval) {
      return;
    }
    _lastSparkleTime = now;

    // ID付きのParticleオブジェクトを作成
    final swipeSparkle = Particle(position: position); // ←★ 小さい破裂用
    final trail = Particle(position: position); // ← 軌跡用

    // Stateを更新してリストに追加
    state = state.copyWith(
      // sparkles: ... ←★ ここは触らない（大きい破裂は addSwipeTrail でしか出ない）
      trailParticles: [...state.trailParticles, trail],
      swipeSparkles: [...state.swipeSparkles, swipeSparkle], // ←★ 小さい破裂を追加
    );

    // ★ 小さい破裂を削除する (600ms後。SwipeSparkleのアニメーション時間と合わせる)
    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      state = state.copyWith(
        swipeSparkles:
            state.swipeSparkles.where((p) => p.id != swipeSparkle.id).toList(),
      );
    });

    Future.delayed(const Duration(milliseconds: 1500), () {
      // ← 軌跡の削除 (そのまま)
      if (!mounted) return;
      state = state.copyWith(
        trailParticles:
            state.trailParticles.where((p) => p.id != trail.id).toList(),
      );
    });
  }

  // MyAppにあった _addSwipeTrail のロジックを移植
  void addSwipeTrail(Offset pos) {
    // 5回のループ (Sparkles)
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

    // 10回のループ (TrailParticles)
    for (int i = 0; i < 6; i++) {
      Future.delayed(Duration(milliseconds: 100 + i * 80), () {
        if (!mounted) return;
        final offset = pos +
            Offset(
              (_random.nextDouble() - 0.5) * 50,
              (_random.nextDouble() - 0.5) * 50,
            );

        final trail = Particle(position: offset);
        state =
            state.copyWith(trailParticles: [...state.trailParticles, trail]);

        Future.delayed(const Duration(milliseconds: 1800), () {
          if (!mounted) return;
          state = state.copyWith(
            trailParticles:
                state.trailParticles.where((p) => p.id != trail.id).toList(),
          );
        });
      });
    }

    // 最後のタップバースト (Sparkle)
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
