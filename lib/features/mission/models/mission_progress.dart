import 'package:saving_girlfriend/features/mission/data/all_missions.dart';
import 'package:saving_girlfriend/features/mission/models/mission.dart'
    as mission_model;

class MissionProgress {
  MissionProgress({
    required this.mission,
    this.currentProgress = 0,
    this.isClaimed = false, // ★ 1. isClaimed を追加
  });

  final mission_model.Mission mission;
  int currentProgress;
  bool isClaimed; // ★ 1. isClaimed を追加

  bool get isCompleted => currentProgress >= mission.goal;

  // JSONシリアライズ/デシリアライズ（shared_preferences用）
  Map<String, dynamic> toJson() => {
        'id': mission.id,
        'progress': currentProgress,
        'isClaimed': isClaimed, // ★ 1. isClaimed を追加
      };

  factory MissionProgress.fromJson(Map<String, dynamic> json) {
    final mission = allMissions.firstWhere((m) => m.id == json['id'],
        orElse: () => allMissions.first);

    return MissionProgress(
      mission: mission,
      currentProgress: json['progress'] as int,
      // ★ 1. isClaimed を読み込む (存在しない場合は false)
      isClaimed: json['isClaimed'] as bool? ?? false,
    );
  }
}
