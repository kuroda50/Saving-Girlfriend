import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:saving_girlfriend/features/mission/models/mission_progress.dart';

// ★ 1. import パスを修正 (isaving_girlfriend -> saving_girlfriend)
import 'package:saving_girlfriend/features/mission/widgets/mission_action_button.dart';

// ★★★ ミッションアイテム (デザイン修正) ★★★
class MissionListItem extends ConsumerWidget {
  final MissionProgress progress;
  const MissionListItem({super.key, required this.progress});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isCompleted = progress.isCompleted;
    final bool isClaimed = progress.isClaimed;

    final Widget missionItemContent = Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        // ★ 背景を半透明の白に変更
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withOpacity(0.5), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15), // ★ 影を薄く
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // 1. 報酬アイコン
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.amber[600], // ★ コインの色
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 3,
                    offset: const Offset(1, 1),
                  ),
                ],
              ),
              child: const Icon(
                Icons.paid_outlined, // ★ コインのアイコンに変更
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),

            // 2. 説明文と進捗バー
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    progress.mission.description, // 説明文を表示
                    style: const TextStyle(
                      color: Colors.black87, // ★ 文字色を黒に
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8), // 間隔
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: (progress.currentProgress /
                                    progress.mission.goal)
                                .clamp(0.0, 1.0),
                            backgroundColor: Colors.grey[300], // ★ 背景を明るく
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                Colors.pinkAccent), // ★ ピンクに変更
                            minHeight: 10,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${progress.currentProgress} / ${progress.mission.goal}',
                        style: const TextStyle(
                          color: Colors.black54, // ★ 文字色を濃いグレーに
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),

            // 3. ボタンと報酬テキスト
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                MissionActionButton(
                  isCompleted: isCompleted,
                  isClaimed: isClaimed,
                  missionId: progress.mission.id,
                  // ★ 修正点: mission.condition を渡す
                  condition: progress.mission.condition,
                ),
                const SizedBox(height: 6),
                Text(
                  '報酬: ${progress.mission.reward} P',
                  style: TextStyle(
                    color: Colors.amber[800], // ★ 報酬の色を濃いオレンジに
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    // 2. 「CLEAR」スタンプ (変更なし)
    return Stack(
      children: [
        missionItemContent,
        if (isClaimed)
          Positioned.fill(
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                // ★ 受取済みのオーバーレイ (少し薄く)
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Transform.rotate(
                  angle: -0.2,
                  child: Text(
                    'CLEAR',
                    style: TextStyle(
                      color: Colors.yellow.withOpacity(0.9),
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 4,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 5,
                          offset: const Offset(2, 3),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
