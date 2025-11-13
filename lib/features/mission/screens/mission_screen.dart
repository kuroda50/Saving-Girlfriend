import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:saving_girlfriend/common/constants/assets.dart'; // ★ 背景画像を使うために import
import 'package:saving_girlfriend/features/mission/models/mission.dart'
    as mission_model;
import 'package:saving_girlfriend/features/mission/providers/mission_provider.dart';

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
            child: const _CustomMissionHeader(),
          ),

          // 3. ★ カスタムタブボタン (カウントを渡すように修正)
          Positioned(
            top: safeArea.top + kToolbarHeight,
            left: 0,
            right: 0,
            child: _CustomMissionTabs(
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
                return _MissionListView(missions: missions);
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
            child: _BulkClaimButton(),
          ),
        ],
      ),
    );
  }
}

// ★★★ カスタムヘッダーウィジェット (背景色を修正) ★★★
class _CustomMissionHeader extends StatelessWidget {
  const _CustomMissionHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      // ★ 背景色を透明にし、下のボーダーで区切りをつける
      decoration: BoxDecoration(
        color: Colors.transparent, // ★ 透明に
        border: Border(
          bottom: BorderSide(color: Colors.white.withOpacity(0.2), width: 1),
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 戻るボタン
          Positioned(
            left: 4,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => context.pop(),
            ),
          ),
          // タイトル
          const Text(
            'ミッション',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
              shadows: [
                Shadow(
                    offset: Offset(1, 1), blurRadius: 2, color: Colors.black54)
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ★★★ カスタムタブウィジェット (バッジ表示対応) ★★★
class _CustomMissionTabs extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;
  // ★ 1. カウントを受け取る変数を追加
  final int dailyCount;
  final int weeklyCount;
  final int mainCount;
  final int randomCount;

  const _CustomMissionTabs({
    required this.selectedIndex,
    required this.onTabSelected,
    // ★ 2. コンストラクタに追加 (デフォルト値 0)
    this.dailyCount = 0,
    this.weeklyCount = 0,
    this.mainCount = 0,
    this.randomCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // ★ 背景色を透明に
      color: Colors.transparent,
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // ★ 3. _buildTabButton に対応するカウントを渡す
          _buildTabButton(context, 'デイリー', 0, dailyCount),
          const SizedBox(width: 8),
          _buildTabButton(context, 'ウィークリー', 1, weeklyCount),
          const SizedBox(width: 8),
          _buildTabButton(context, 'メイン', 2, mainCount),
          const SizedBox(width: 8),
          _buildTabButton(context, 'ランダム', 3, randomCount),
        ],
      ),
    );
  }

  // ★ 4. _buildTabButton メソッドを修正 (count 引数を追加)
  Widget _buildTabButton(
      BuildContext context, String text, int index, int count) {
    final bool isSelected = (selectedIndex == index);

    return Expanded(
      child: GestureDetector(
        onTap: () => onTabSelected(index),
        child: Container(
          height: 44,
          decoration: BoxDecoration(
            // ★ 選択中のタブの色をピンクに
            color: isSelected
                ? Colors.pinkAccent.withOpacity(0.8) // ★ ピンクに変更
                : Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(22), // 完全に丸い角
            border: Border.all(
              color: isSelected
                  ? Colors.white.withOpacity(0.8)
                  : Colors.white.withOpacity(0.4),
              width: 1.5,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.pinkAccent.withOpacity(0.5), // ★ ピンクに変更
                      blurRadius: 8,
                      spreadRadius: 2,
                    )
                  ]
                : [],
          ),
          // ★ 5. Center を Stack に変更してバッジを重ねる
          child: Stack(
            clipBehavior: Clip.none, // Stack の外にはみ出すのを許可
            alignment: Alignment.center,
            children: [
              // 1. タブのテキスト
              Text(
                text,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 13, // ★ 4タブでも収まるように 13 に
                ),
              ),

              // 2. ★ 達成ミッション数のバッジ (count > 0 の時だけ表示)
              if (count > 0)
                Positioned(
                  top: -4, // ボタンの上にはみ出す
                  right: 4, // ボタンの右端に合わせる
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.redAccent, // バッジの色
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Center(
                      child: Text(
                        '$count', // カウント数を表示
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ★★★ ミッションリスト (変更なし) ★★★
class _MissionListView extends StatelessWidget {
  final List<MissionProgress> missions;
  const _MissionListView({required this.missions});

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
        return _MissionListItem(progress: sortedMissions[index]);
      },
    );
  }
}

// ★★★ ミッションアイテム (デザイン修正) ★★★
class _MissionListItem extends ConsumerWidget {
  final MissionProgress progress;
  const _MissionListItem({required this.progress});

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
                _MissionActionButton(
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

// ★★★ アクションボタン (遷移ロジックを修正) ★★★
class _MissionActionButton extends ConsumerWidget {
  final bool isCompleted;
  final bool isClaimed;
  final String missionId;
  // ★ 1. condition を受け取る変数を追加
  final mission_model.MissionCondition condition;

  const _MissionActionButton({
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

      // ★ 3. 遷移ロジックを修正 (push -> go, パスを /transaction に)
      onPressed = () {
        print('Challenge button pressed for $missionId');

        // condition に応じて画面遷移
        switch (condition) {
          case mission_model.MissionCondition.inputTransaction:
            // ★ 家計簿画面（チャット画面）へ遷移
            // ★ /chat から /transaction に変更
            // ★ push (重ねる) から go (タブ切替) に変更
            GoRouter.of(context).go('/transaction_input');
            break;

          case mission_model.MissionCondition.sendTribute:
          case mission_model.MissionCondition.sendTributeAmount:
            // ★ ホーム画面( / )のタブに切り替え
            GoRouter.of(context).go('/home');
            break;

          case mission_model.MissionCondition.watchStory:
            // ★ ストーリー選択画面のタブに切り替え
            GoRouter.of(context).go('/select_story');
            break;

          case mission_model.MissionCondition.login:
            // ★ ホーム画面( / )のタブに切り替え
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

// ★★★ 一括受取ボタン (色を修正) ★★★
class _BulkClaimButton extends ConsumerWidget {
  const _BulkClaimButton();

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
