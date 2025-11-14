import 'dart:convert';
import 'dart:math';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:saving_girlfriend/app/providers/reward_point_provider.dart';
import 'package:saving_girlfriend/common/models/message.dart';
import 'package:saving_girlfriend/common/services/local_storage_service.dart'; // ★ 1. 修正
import 'package:saving_girlfriend/features/mission/data/all_missions.dart';
import 'package:saving_girlfriend/features/mission/models/mission.dart'
    as mission_model;
// ★ 2. `MissionProgress` の定義ファイルをインポート
import 'package:saving_girlfriend/features/mission/models/mission_progress.dart';
import 'package:saving_girlfriend/features/transaction/providers/chat_history_provider.dart';
import 'package:saving_girlfriend/features/transaction/providers/transaction_history_provider.dart';
// ★ 3. 'shared_preferences' の import を削除
// import 'package:shared_preferences/shared_preferences.dart';

part 'mission_provider.g.dart'; // riverpod_generator を使うため

// (MissionProgress クラスの定義はここから削除されている)

// 状態管理を AsyncNotifier に変更
@Riverpod(keepAlive: true) // ★ keepAlive: true に修正
class MissionNotifier extends _$MissionNotifier {
  // ★ 4. `_prefs` を `_localStorageService` に変更
  late LocalStorageService _localStorageService;
  // (キーの定義は LocalStorageService に移動)

  @override
  Future<List<MissionProgress>> build() async {
    // ★ 5. `localStorageServiceProvider` を watch するように変更
    _localStorageService = await ref.watch(localStorageServiceProvider.future);

    // --- 監視ロジック 1: (チャット画面からの入力) ---
    ref.listen(chatHistoryNotifierProvider, (previousState, nextState) {
      if (previousState?.value == null || nextState.value == null) return;
      final prevList = previousState!.value!;
      final nextList = nextState.value!;

      if (nextList.length > prevList.length) {
        final lastMessage = nextList.last;
        if (lastMessage.type == MessageType.expense ||
            lastMessage.type == MessageType.income) {
          print('MissionNotifier (from Chat) が家計簿入力を検知！');
          updateProgress(mission_model.MissionCondition.inputTransaction);
        }
      }
    });

    // --- 監視ロジック 2: (履歴画面からの入力) ---
    ref.listen(transactionsProvider, (previousState, nextState) {
      if (previousState?.value == null || nextState.value == null) return;
      final prevList = previousState!.value!;
      final nextList = nextState.value!;
      if (nextList.length > prevList.length) {
        print('MissionNotifier (from History) が家計簿入力を検知！');
        updateProgress(mission_model.MissionCondition.inputTransaction);
      }
    });

    // --- 初期データの読み込み ---
    List<MissionProgress> initialState = [];
    // ★ 6. `_localStorageService.loadMissions` に変更
    final savedData = await _localStorageService.loadMissions();
    if (savedData != null) {
      try {
        final List<dynamic> jsonList = jsonDecode(savedData);
        initialState = jsonList
            .map((json) =>
                MissionProgress.fromJson(Map<String, dynamic>.from(json)))
            .toList();
      } catch (e) {
        print('Failed to load mission state: $e');
        initialState = [];
        // ★ 7. `_localStorageService.removeMissions` に変更
        await _localStorageService.removeMissions();
      }
    }

    // ★ リファクタリングされた関数を呼び出す
    final updatedState = await _updateMissionsIfNeeded(initialState);
    return updatedState;
  }

  // ★★★ リファクタリング 1: メインの関数 ★★★
  Future<List<MissionProgress>> _updateMissionsIfNeeded(
      List<MissionProgress> currentState) async {
    final now = DateTime.now();
    List<MissionProgress> newState = List.from(currentState);
    bool missionsChanged = false;

    // --- デイリー更新 ---
    final (dailyUpdated, dailyState) =
        await _updateDailyMissions(newState, now);
    newState = dailyState;
    if (dailyUpdated) missionsChanged = true;

    // --- ウィークリー更新 ---
    final (weeklyUpdated, weeklyState) =
        await _updateWeeklyMissions(newState, now);
    newState = weeklyState;
    if (weeklyUpdated) missionsChanged = true;

    // --- ランダム更新 ---
    final (randomUpdated, randomState) = _updateRandomMissions(newState);
    newState = randomState;
    if (randomUpdated) missionsChanged = true;

    // --- メイン更新 ---
    final (mainUpdated, mainState) = _updateMainMissions(newState);
    newState = mainState;
    if (mainUpdated) missionsChanged = true;

    // --- 変更があれば保存 ---
    if (missionsChanged) {
      await _saveState(newState);
    }

    return newState;
  }

  // ★★★ リファクタリング 2: デイリーミッション関数 ★★★
  Future<(bool, List<MissionProgress>)> _updateDailyMissions(
      List<MissionProgress> currentState, DateTime now) async {
    // ★ 8. `_localStorageService.loadMissionLastUpdated` に変更
    final lastUpdatedString =
        await _localStorageService.loadMissionLastUpdated('daily');
    bool needsDailyUpdate = true;
    if (lastUpdatedString != null) {
      final lastUpdated = DateTime.parse(lastUpdatedString);
      if (lastUpdated.year == now.year &&
          lastUpdated.month == now.month &&
          lastUpdated.day == now.day) {
        needsDailyUpdate = false;
      }
    }

    if (!needsDailyUpdate) return (false, currentState);

    print("デイリーミッションをリセットします");
    List<MissionProgress> newState = List.from(currentState);
    final dailyMissions = allMissions
        .where((m) => m.type == mission_model.MissionType.daily)
        .toList();

    if (dailyMissions.isNotEmpty) {
      newState = newState
          .where((p) => p.mission.type != mission_model.MissionType.daily)
          .toList();
      for (final dailyMission in dailyMissions) {
        newState.add(MissionProgress(mission: dailyMission));
      }
      // ★ 9. `_localStorageService.saveMissionLastUpdated` に変更
      await _localStorageService.saveMissionLastUpdated(
          'daily', now.toIso8601String());
      return (true, newState);
    }

    return (false, currentState);
  }

  // ★★★ リファクタリング 3: ウィークリーミッション関数 ★★★
  Future<(bool, List<MissionProgress>)> _updateWeeklyMissions(
      List<MissionProgress> currentState, DateTime now) async {
    // ★ 10. `_localStorageService.loadMissionLastUpdated` に変更
    final lastWeeklyUpdatedString =
        await _localStorageService.loadMissionLastUpdated('weekly');
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

    if (!needsWeeklyUpdate) return (false, currentState);

    print("ウィークリーミッションをリセットします");
    List<MissionProgress> newState = List.from(currentState);
    newState = newState
        .where((p) => p.mission.type != mission_model.MissionType.weekly)
        .toList();
    final weeklyMissions = allMissions
        .where((m) => m.type == mission_model.MissionType.weekly)
        .toList();
    for (final weeklyMission in weeklyMissions) {
      newState.add(MissionProgress(mission: weeklyMission));
    }
    // ★ 11. `_localStorageService.saveMissionLastUpdated` に変更
    await _localStorageService.saveMissionLastUpdated(
        'weekly', now.toIso8601String());
    return (true, newState);
  }

  // ★★★ リファクタリング 4: ランダムミッション関数 ★★★
  (bool, List<MissionProgress>) _updateRandomMissions(
      List<MissionProgress> currentState) {
    if (Random().nextDouble() < 0.1) {
      // 10%の確率で抽選
      List<MissionProgress> newState = List.from(currentState);
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
        print("ランダムミッションを追加しました: ${newRandom.title}");
        return (true, newState);
      }
    }
    return (false, currentState);
  }

  // ★★★ リファクタリング 5: メインミッション関数 ★★★
  (bool, List<MissionProgress>) _updateMainMissions(
      List<MissionProgress> currentState) {
    bool missionsChanged = false;
    List<MissionProgress> newState = List.from(currentState);

    final currentMainMissionIds = newState
        .where((p) => p.mission.type == mission_model.MissionType.main)
        .map((p) => p.mission.id)
        .toSet();
    final allMainMissions = allMissions
        .where((m) => m.type == mission_model.MissionType.main)
        .toList();

    // allMissions には存在するが、現在のリスト(newState)にはまだ無いミッションを探す
    for (final mainMission in allMainMissions) {
      if (!currentMainMissionIds.contains(mainMission.id)) {
        // 新しく追加されたメインミッションをリストに追加
        // (デイリーと違い、リセットせずに追加するだけ)
        newState.add(MissionProgress(mission: mainMission));
        print("新しいメインミッションを追加しました: ${mainMission.title}");
        missionsChanged = true;
      }
    }
    return (missionsChanged, newState);
  }

  // --- 以下のメソッドは変更なし ---

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
  // ★ 3. `claimMission` 関数を修正
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

          // ★ 2. TODO を実際の報酬反映処理に変更
          // (エラー回避のため `await` はつけずに呼び出す)
          ref
              .read(rewardPointProvider.notifier)
              .addPoints(progress.mission.reward);
        }
        break;
      }
    }

    if (missionClaimed) {
      await _saveState(newState);
      state = AsyncData(newState);
    }
  }

  // ★ 4. `claimAllCompletedMissions` 関数を修正
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

      // ★ 3. TODO を実際の報酬反映処理に変更
      // (エラー回避のため `await` はつけずに呼び出す)
      ref.read(rewardPointProvider.notifier).addPoints(totalReward);

      await _saveState(newState);
      state = AsyncData(newState);
    }
  }

  // 状態を永続化（privateヘルパー）
  Future<void> _saveState(List<MissionProgress> stateToSave) async {
    final List<Map<String, dynamic>> jsonList =
        stateToSave.map((p) => p.toJson()).toList();
    // ★ 12. `_localStorageService.saveMissions` に変更
    await _localStorageService.saveMissions(jsonEncode(jsonList));
  }
}
