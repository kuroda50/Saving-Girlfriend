// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:saving_girlfriend/main.dart'; // TapSparkleBurst, TrailParticle が定義されているファイル
import '../providers/particle_provider.dart'; // particleProvider が定義されているファイル

class ParticleRenderer extends ConsumerWidget {
  const ParticleRenderer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // particleProvider を watch する
    final particleState = ref.watch(particleProvider);

    return Stack(
      fit: StackFit.expand,
      children: [
        // Notifierが持つリストを描画する
        for (final particle in particleState.trailParticles)
          TrailParticle(
            // ★最重要：必ず ValueKey を指定する
            key: ValueKey(particle.id),
            position: particle.position,
          ),

        // ▼▼▼▼ ここから追加 ▼▼▼▼
        for (final particle in particleState.swipeSparkles) // ← 小さい破裂
          SwipeSparkle(
            // ←★ 新しいウィジェットを呼ぶ
            key: ValueKey(particle.id),
            position: particle.position,
          ),
        // ▲▲▲▲ ここまで追加 ▲▲▲▲

        for (final particle in particleState.sparkles)
          TapSparkleBurst(
            // ★最重要：必ず ValueKey を指定する
            key: ValueKey(particle.id),
            position: particle.position,
          ),
      ],
    );
  }
}
