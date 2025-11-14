import 'package:flutter/material.dart';
import 'package:saving_girlfriend/features/mission/models/mission_progress.dart';

// ★ 1. 分割した MissionListItem を import
import 'package:saving_girlfriend/features/mission/widgets/mission_list_item.dart';

// ★★★ ミッションリスト (変更なし) ★★★
class MissionListView extends StatelessWidget {
  final List<MissionProgress> missions;
  const MissionListView({super.key, required this.missions}); // ★ key を追加

  @override
  Widget build(BuildContext context) {
    if (missions.isEmpty) {
      return const Center(
        child: Text(
          'ミッションはありません',
          style: TextStyle(color: Colors.white70, fontSize: 16),
        ),
      );
    }

    // ソート (変更なし)
    final sortedMissions = List<MissionProgress>.from(missions);
    sortedMissions.sort((a, b) {
      if (a.isClaimed && !b.isClaimed) return 1;
      if (!a.isClaimed && b.isClaimed) return -1;
      if (a.isCompleted && !b.isCompleted) return -1;
      if (!a.isCompleted && b.isCompleted) return 1;
      return 0;
    });

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(12.0, 0, 12.0, 12.0),
      itemCount: sortedMissions.length,
      itemBuilder: (context, index) {
        // ★ 2. _MissionListItem -> MissionListItem に変更
        return MissionListItem(progress: sortedMissions[index]);
      },
    );
  }
}
