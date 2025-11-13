import 'dart:convert';
import 'dart:math';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:saving_girlfriend/common/services/local_storage_service.dart';
import 'package:saving_girlfriend/features/mission/date/all_missions.dart';
import 'package:saving_girlfriend/features/mission/models/mission.dart'
    as mission_model;
import 'package:shared_preferences/shared_preferences.dart';

part 'mission_provider.g.dart'; // riverpod_generator を使うため

// ミッションの進捗状況
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

// 状態管理を AsyncNotifier に変更
@Riverpod(keepAlive: true) // ★ keepAlive: true に戻す
class MissionNotifier extends _$MissionNotifier {
  late SharedPreferences _prefs;
  static const _prefsKey = 'mission_state';
  static const _lastUpdatedKey = 'mission_last_updated';

  // ★ 1. ウィークリー用の保存キーを追加
  static const _lastWeeklyUpdatedKey = 'mission_last_weekly_updated';

  @override
  Future<List<MissionProgress>> build() async {
    _prefs = await ref.watch(sharedPreferencesProvider.future);

    List<MissionProgress> initialState = [];
    final savedData = _prefs.getString(_prefsKey);
    if (savedData != null) {
      try {
        final List<dynamic> jsonList = jsonDecode(savedData);
        initialState =
            jsonList.map((json) => MissionProgress.fromJson(json)).toList();
      } catch (e) {
        print('Failed to load mission state: $e');
        initialState = [];
        await _prefs.remove(_prefsKey);
      }
    }

    final updatedState = await _updateMissionsIfNeeded(initialState);
    return updatedState;
  }

  Future<List<MissionProgress>> _updateMissionsIfNeeded(
      List<MissionProgress> currentState) async {
    final lastUpdatedString = _prefs.getString(_lastUpdatedKey);
    final now = DateTime.now();

    bool needsDailyUpdate = true;
    if (lastUpdatedString != null) {
      final lastUpdated = DateTime.parse(lastUpdatedString);
      if (lastUpdated.year == now.year &&
          lastUpdated.month == now.month &&
          lastUpdated.day == now.day) {
        needsDailyUpdate = false;
      }
    }

    // --- ★ 修正箇所 2: ウィークリー更新の判定を追加 ---
    final lastWeeklyUpdatedString = _prefs.getString(_lastWeeklyUpdatedKey);
    bool needsWeeklyUpdate = true;
    if (lastWeeklyUpdatedString != null) {
      final lastWeeklyUpdated = DateTime.parse(lastWeeklyUpdatedString);

      // 「最後に更新した日」から「次の月曜日の0時」を計算
      // (DateTime.weekday は 月曜=1, ..., 日曜=7)
      final nextMonday = DateTime(
        lastWeeklyUpdated.year,
        lastWeeklyUpdated.month,
        // (7 - 曜日番号 + 1) で次の月曜までの日数を計算
        lastWeeklyUpdated.day + (7 - lastWeeklyUpdated.weekday + 1),
      );

      // まだ次の月曜日になっていなければ、更新は不要
      if (now.isBefore(nextMonday)) {
        needsWeeklyUpdate = false;
      }
    }

    bool missionsChanged = false;
    List<MissionProgress> newState = List.from(currentState);

    if (needsDailyUpdate) {
      // 1. デイリーミッションのリセットと再抽選
      final dailyMissions = allMissions
          .where((m) => m.type == mission_model.MissionType.daily)
          .toList();

      if (dailyMissions.isNotEmpty) {
        // ★修正点: 既存のデイリーを削除 (リストをコピー)
        newState = newState
            .where((p) => p.mission.type != mission_model.MissionType.daily)
            .toList();

        // ★修正点: allMissions にある「すべて」のデイリーミッションを追加する
        for (final dailyMission in dailyMissions) {
          newState.add(MissionProgress(mission: dailyMission));
        }
        missionsChanged = true;
      }
    }

// --- ★ 修正箇所 3: ウィークリーリセット処理を追加 ---
    if (needsWeeklyUpdate) {
      print("ウィークリーミッションをリセットします");
      // 既存のウィークリーミッションを削除
      newState = newState
          .where((p) => p.mission.type != mission_model.MissionType.weekly)
          .toList();

      // allMissions からすべてのウィークリーミッションを追加
      final weeklyMissions = allMissions
          .where((m) => m.type == mission_model.MissionType.weekly)
          .toList();

      for (final weeklyMission in weeklyMissions) {
        newState.add(MissionProgress(mission: weeklyMission));
      }

      // ウィークリー更新日を保存
      await _prefs.setString(_lastWeeklyUpdatedKey, now.toIso8601String());
      missionsChanged = true;
    }

    // ... (ランダムミッションの抽選ロジック - 変更なし)
    if (Random().nextDouble() < 0.1) {
      final currentRandomIds = newState
          .where((p) => p.mission.type == mission_model.MissionType.random)
          .map((p) => p.mission.id);
      final availableRandom = allMissions
          .where((m) =>
              m.type == mission_model.MissionType.random &&
              !currentRandomIds.contains(m.id))
          .toList();

      if (availableRandom.isNotEmpty) {
        final newRandom =
            availableRandom[Random().nextInt(availableRandom.length)];
        newState.add(MissionProgress(mission: newRandom));
        missionsChanged = true;
      }
    }

// 現在のリストに含まれるメインミッションのIDをすべて取得
    final currentMainMissionIds = newState
        .where((p) => p.mission.type == mission_model.MissionType.main)
        .map((p) => p.mission.id)
        .toSet(); // Set にして高速化

    // allMissions から「メイン」ミッションを取得
    final allMainMissions = allMissions
        .where((m) => m.type == mission_model.MissionType.main)
        .toList();

    // allMissions には存在するが、現在のリスト(newState)にはまだ無いミッションを探す
    for (final mainMission in allMainMissions) {
      if (!currentMainMissionIds.contains(mainMission.id)) {
        // 新しく追加されたメインミッションをリストに追加
        // (デイリーと違い、リセットせずに追加するだけ)
        newState.add(MissionProgress(mission: mainMission));
        missionsChanged = true;
      }
    }
    // ↑↑↑ ★メインミッションのロジックここまで★ ↑↑↑

    // --- ★ 修正箇所 4: 保存処理を修正 ---
    if (missionsChanged) {
      // デイリー更新日を保存（デイリーが更新された場合のみ）
      if (needsDailyUpdate) {
        // ★ if (needsDailyUpdate) を追加
        await _prefs.setString(_lastUpdatedKey, now.toIso8601String());
      }
      await _saveState(newState);
    }

    return newState;
  }

  Future<void> updateProgress(mission_model.MissionCondition condition,
      [int amount = 1]) async {
    final currentState = state.valueOrNull ?? [];
    if (currentState.isEmpty) return;

    bool missionUpdated = false;
    List<MissionProgress> newState = List.from(currentState);

    for (final progress in newState) {
      // ★ 完了していても、進捗は更新する (例: 1回 -> 2回)
      // ただし、既に受け取り済みのミッションは更新しない
      if (progress.mission.condition == condition && !progress.isClaimed) {
        if (!progress.isCompleted) {
          // まだゴールに達していなければ
          progress.currentProgress += amount;
        }
        missionUpdated = true;
      }
    }

    if (missionUpdated) {
      // ★ 2. 完了チェックを `updateProgress` から削除
      // final completedMissions = newState.where((p) => p.isCompleted).toList();
      // ... (削除) ...

      await _saveState(newState);
      state = AsyncData(newState);
    }
  }

  // ★ 3. `claimMission` 関数を追加
  Future<void> claimMission(String missionId) async {
    final currentState = state.valueOrNull ?? [];
    if (currentState.isEmpty) return;

    List<MissionProgress> newState = List.from(currentState);
    bool missionClaimed = false;

    for (final progress in newState) {
      if (progress.mission.id == missionId) {
        if (progress.isCompleted && !progress.isClaimed) {
          progress.isClaimed = true;
          missionClaimed = true;
          print('報酬ゲット: ${progress.mission.reward} P');
          // TODO: 実際の報酬（好感度など）を別Provider（likeability_provider.dartなど）に反映
          // ref.read(likeabilityProvider.notifier).add(progress.mission.reward);
        }
        break;
      }
    }

    if (missionClaimed) {
      await _saveState(newState);
      state = AsyncData(newState);
    }
  }

  // ★ 4. `claimAllCompletedMissions` 関数を追加
  Future<void> claimAllCompletedMissions() async {
    final currentState = state.valueOrNull ?? [];
    if (currentState.isEmpty) return;

    List<MissionProgress> newState = List.from(currentState);
    bool anyMissionClaimed = false;
    int totalReward = 0;

    for (final progress in newState) {
      if (progress.isCompleted && !progress.isClaimed) {
        progress.isClaimed = true;
        anyMissionClaimed = true;
        totalReward += progress.mission.reward;
      }
    }

    if (anyMissionClaimed) {
      print('一括受取 報酬ゲット: $totalReward P');
      // TODO: 実際の報酬（好感度など）を別Provider（likeability_provider.dartなど）に反映
      // ref.read(likeabilityProvider.notifier).add(totalReward);

      await _saveState(newState);
      state = AsyncData(newState);
    }
  }

  // 状態を永続化（privateヘルパー）
  Future<void> _saveState(List<MissionProgress> stateToSave) async {
    final List<Map<String, dynamic>> jsonList =
        stateToSave.map((p) => p.toJson()).toList();
    await _prefs.setString(_prefsKey, jsonEncode(jsonList));
  }
}
