import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:saving_girlfriend/features/mission/providers/mission_provider.dart';

// ★★★ 一括受取ボタン (色を修正) ★★★
class BulkClaimButton extends ConsumerWidget {
  const BulkClaimButton({super.key}); // ★ key を追加

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final missionState = ref.watch(missionNotifierProvider);
    final bool hasClaimableMissions = missionState.maybeWhen(
      data: (missions) => missions.any((p) => p.isCompleted && !p.isClaimed),
      orElse: () => false,
    );
    final safeAreaBottom = MediaQuery.of(context).padding.bottom;

    return Container(
      margin: EdgeInsets.only(
          bottom: safeAreaBottom > 0 ? safeAreaBottom : 12,
          left: 12,
          right: 12,
          top: 8),
      height: 60,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25), // ★ 影を薄く
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: hasClaimableMissions
            ? () {
                ref
                    .read(missionNotifierProvider.notifier)
                    .claimAllCompletedMissions();
                print('Bulk claim button pressed');
              }
            : null,
        style: ElevatedButton.styleFrom(
          // ★ 押せる時の色をピンクに
          backgroundColor: Colors.pinkAccent,
          foregroundColor: Colors.white,
          // 押せない時のスタイル (修正済み)
          disabledBackgroundColor: Colors.grey[600],
          disabledForegroundColor: Colors.white.withOpacity(0.85),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          textStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(offset: Offset(1, 1), blurRadius: 2, color: Colors.black38)
            ],
          ),
        ),
        child: const Text('一括受取'),
      ),
    );
  }
}
