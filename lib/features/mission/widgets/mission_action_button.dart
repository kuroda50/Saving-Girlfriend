import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:saving_girlfriend/features/mission/models/mission.dart'
    as mission_model;
import 'package:saving_girlfriend/features/mission/providers/mission_provider.dart';

// ★★★ アクションボタン (遷移ロジックを修正) ★★★
class MissionActionButton extends ConsumerWidget {
  // ★ _ を削除
  final bool isCompleted;
  final bool isClaimed;
  final String missionId;
  // ★ 1. condition を受け取る変数を追加
  final mission_model.MissionCondition condition;

  const MissionActionButton({
    // ★ _ を削除
    super.key, // ★ key を追加
    required this.isCompleted,
    required this.isClaimed,
    required this.missionId,
    required this.condition, // ★ 2. コンストラクタに追加
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String text;
    final Color color;
    final VoidCallback? onPressed;
    Color? disabledColor;

    if (isClaimed) {
      // 1. 受取済み (変更なし)
      text = '受取済み';
      color = Colors.grey[500]!;
      onPressed = null;
      disabledColor = Colors.grey[500]!;
    } else if (isCompleted) {
      // 2. 未受取 (変更なし)
      text = '受け取る';
      color = Colors.pinkAccent;
      onPressed = () {
        ref.read(missionNotifierProvider.notifier).claimMission(missionId);
        print('Claim button pressed for $missionId');
      };
      disabledColor = Colors.grey[600];
    } else {
      // 3. 未達成 (onPressed ロジックを修正)
      text = '挑戦する';
      color = Colors.blue.shade600;
      disabledColor = Colors.grey[600]; // (使われないが念のため)

      // ★ 3. 遷移ロジックを修正 (go_router.dart に合わせる)
      onPressed = () {
        print('Challenge button pressed for $missionId');

        // condition に応じて画面遷移
        switch (condition) {
          case mission_model.MissionCondition.inputTransaction:
            GoRouter.of(context).go('/transaction_input');
            break;

          case mission_model.MissionCondition.sendTribute:
          case mission_model.MissionCondition.sendTributeAmount:
            GoRouter.of(context).go('/home');
            break;

          case mission_model.MissionCondition.watchStory:
            GoRouter.of(context).go('/select_story');
            break;

          case mission_model.MissionCondition.login:
            GoRouter.of(context).go('/home');
            break;
        }
      };
    }

    return Container(
      width: 90,
      height: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          disabledBackgroundColor: disabledColor,
          foregroundColor: Colors.white,
          disabledForegroundColor: Colors.white.withOpacity(0.85),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: EdgeInsets.zero,
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                  offset: Offset(0.5, 0.5),
                  blurRadius: 1,
                  color: Colors.black38)
            ],
          ),
        ),
        child: Text(text),
      ),
    );
  }
}
