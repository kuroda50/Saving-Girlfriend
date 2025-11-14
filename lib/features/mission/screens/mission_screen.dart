import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:saving_girlfriend/common/constants/assets.dart'; // ★ 背景画像を使うために import
import 'package:saving_girlfriend/features/mission/models/mission.dart'
    as mission_model;
import 'package:saving_girlfriend/features/mission/models/mission_progress.dart';
import 'package:saving_girlfriend/features/mission/providers/mission_provider.dart';
import 'package:saving_girlfriend/features/mission/widgets/bulk_claim_button.dart';
import 'package:saving_girlfriend/features/mission/widgets/mission_header.dart';
import 'package:saving_girlfriend/features/mission/widgets/mission_list_view.dart';
import 'package:saving_girlfriend/features/mission/widgets/mission_tabs.dart';

// ConsumerStatefulWidget に変更 (タブの状態を管理するため)
class MissionScreen extends ConsumerStatefulWidget {
  const MissionScreen({super.key});

  @override
  ConsumerState<MissionScreen> createState() => _MissionScreenState();
}

class _MissionScreenState extends ConsumerState<MissionScreen> {
  // タブの状態 (0 = デイリー, 1 = ウィークリー, 2 = メイン, 3 = ランダム)
  int _selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final missionState = ref.watch(missionNotifierProvider);
    final safeArea = MediaQuery.of(context).padding;

    // ★ 1. 達成可能ミッション数を計算するための変数を追加
    int dailyCount = 0;
    int weeklyCount = 0;
    int mainCount = 0;
    int randomCount = 0;

    // ミッションリストをタブの状態でフィルタリング
    final List<MissionProgress> missions = missionState.maybeWhen(
      data: (missions) {
        // ★ 2. カウントを計算するロジックを追加
        for (final p in missions) {
          // 「達成済み」かつ「未受取」のミッションをカウント
          if (p.isCompleted && !p.isClaimed) {
            switch (p.mission.type) {
              case mission_model.MissionType.daily:
                dailyCount++;
                break;
              case mission_model.MissionType.weekly:
                weeklyCount++;
                break;
              case mission_model.MissionType.main:
                mainCount++;
                break;
              case mission_model.MissionType.random:
                randomCount++;
                break;
            }
          }
        }

        // 4タブ用のロジック (変更なし)
        final mission_model.MissionType missionType;
        if (_selectedTabIndex == 0) {
          missionType = mission_model.MissionType.daily;
        } else if (_selectedTabIndex == 1) {
          missionType = mission_model.MissionType.weekly;
        } else if (_selectedTabIndex == 2) {
          missionType = mission_model.MissionType.main;
        } else {
          missionType = mission_model.MissionType.random;
        }
        return missions.where((p) => p.mission.type == missionType).toList();
      },
      orElse: () => [], // ローディング中やエラー時は空リスト
    );

    return Scaffold(
      body: Stack(
        children: [
          // 1. ★ 背景 (ホーム画面と同じ背景画像)
          Positioned.fill(
            child: Image.asset(
              AppAssets.backgroundHomeScreen,
              fit: BoxFit.cover,
            ),
          ),
          // ★ 背景の上に少しだけ暗いフィルターをかけて、文字を見やすくする
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.15),
            ),
          ),

          // 2. ★ カスタムヘッダー (戻るボタンとタイトル)
          Positioned(
            top: safeArea.top,
            left: 0,
            right: 0,
            height: kToolbarHeight, // AppBarの標準的な高さ
            child: const CustomMissionHeader(),
          ),

          // 3. ★ カスタムタブボタン (カウントを渡すように修正)
          Positioned(
            top: safeArea.top + kToolbarHeight,
            left: 0,
            right: 0,
            child: CustomMissionTabs(
              selectedIndex: _selectedTabIndex,
              onTabSelected: (index) {
                setState(() {
                  _selectedTabIndex = index;
                });
              },
              // ★ 3. カウントを各タブに渡す
              dailyCount: dailyCount,
              weeklyCount: weeklyCount,
              mainCount: mainCount,
              randomCount: randomCount,
            ),
          ),

          // 4. ミッションリスト本体
          Padding(
            // ヘッダーとタブと「一括受取」ボタンの領域を避ける
            padding: EdgeInsets.only(
              top: safeArea.top + kToolbarHeight + 60, // ヘッダー + タブ
              bottom: safeArea.bottom + 80, // 一括受取ボタン + 余白
            ),
            child: missionState.when(
              data: (allMissions) {
                // _MissionListView にフィルタリング済みのリストを渡す
                return MissionListView(missions: missions);
              },
              loading: () => const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
              error: (err, stack) => Center(
                child: Text('エラー: $err',
                    style: const TextStyle(color: Colors.red)),
              ),
            ),
          ),

          // 5. ★ 一括受取ボタン
          const Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: BulkClaimButton(),
          ),
        ],
      ),
    );
  }
}
