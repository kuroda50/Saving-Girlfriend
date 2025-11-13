// Flutter imports:
import 'package:flutter/material.dart';
// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../providers/particle_provider.dart';
import 'swipe_sparkle.dart';
import 'tap_ripple_effect.dart'; // ← ★ 1. 新しいウィジェットをインポート
import 'tap_sparkle_burst.dart';
import 'trail_particle.dart';

class ParticleRenderer extends ConsumerWidget {
  const ParticleRenderer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // particleProvider を watch する
    final particleState = ref.watch(particleProvider);

    return Stack(
      fit: StackFit.expand,
      children: [
        // スワイプ中の「軌跡」
        for (final particle in particleState.trailParticles)
          TrailParticle(
            key: ValueKey(particle.id),
            position: particle.position,
          ),

        // (ボタン用) 小さい破裂
        for (final particle in particleState.swipeSparkles)
          SwipeSparkle(
            key: ValueKey(particle.id),
            position: particle.position,
          ),

        // (ボタン用) 大きい破裂
        for (final particle in particleState.sparkles)
          TapSparkleBurst(
            key: ValueKey(particle.id),
            position: particle.position,
          ),

        // ▼▼▼▼ ここから追加 ▼▼▼▼
        // タップ時の「波紋」
        for (final particle in particleState.tapRipples) // ← ★ 2. 新しいリストを監視
          TapRippleEffect(
            key: ValueKey(particle.id),
            position: particle.position,
          ),
        // ▲▲▲▲ ここまで追加 ▲▲▲▲
      ],
    );
  }
}
