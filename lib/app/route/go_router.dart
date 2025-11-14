import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:saving_girlfriend/app/route/app_navigation_bar.dart';
import 'package:saving_girlfriend/app/screens/home_screen.dart';
import 'package:saving_girlfriend/common/utils/dialog_utils.dart';
import 'package:saving_girlfriend/features/mission/screens/mission_screen.dart'; // ★ 新しく追加
import 'package:saving_girlfriend/features/select_girlfriend/screen/select_girlfriend_screen.dart';
import 'package:saving_girlfriend/features/settings/providers/setting_provider.dart';
import 'package:saving_girlfriend/features/settings/screens/settings_screen.dart';
import 'package:saving_girlfriend/features/story/screens/select_story_screen.dart';
import 'package:saving_girlfriend/features/story/screens/story_screen.dart';
import 'package:saving_girlfriend/features/title/screens/title_screen.dart';
import 'package:saving_girlfriend/features/transaction/screens/chat_screen.dart';
import 'package:saving_girlfriend/features/transaction/screens/transaction_history_screen.dart';

// 各ブランチのナビゲーションスタックを管理するためのGlobalKey
final rootNavigatorKey = GlobalKey<NavigatorState>();
final homeNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'home');
final selectStoryNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'select_story');
final settingsNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'settings');
final transactionHistoryNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'transaction_history');
// 新しい画面用のGlobalKeyを追加
final transactionInputNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'transaction_input');

final router = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: '/title',
  routes: [
    StatefulShellRoute.indexedStack(
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state, navigationShell) {
        return AppNavigationBar(navigationShell: navigationShell);
      },
      branches: [
        // 1. ホームブランチ
        StatefulShellBranch(navigatorKey: homeNavigatorKey, routes: [
          GoRoute(
            path: '/home',
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const HomeScreen(),
            ),
          ),
        ]),
        // 2. 支出履歴
        StatefulShellBranch(
            navigatorKey: transactionHistoryNavigatorKey,
            routes: [
              GoRoute(
                path: '/transaction_history',
                pageBuilder: (context, state) => NoTransitionPage(
                  key: state.pageKey,
                  child: const TransactionHistoryScreen(),
                ),
              ),
            ]),

        // 3. 収支入力ブランチ
        StatefulShellBranch(
          navigatorKey: transactionInputNavigatorKey,
          routes: [
            GoRoute(
              path: '/transaction_input',
              pageBuilder: (context, state) => const NoTransitionPage(
                // child: TransactionInputScreen(),
                child: GirlfriendChatScreen(),
              ),
            ),
          ],
        ),
        // 4. ストーリー選択ブランチ
        StatefulShellBranch(navigatorKey: selectStoryNavigatorKey, routes: [
          GoRoute(
            path: '/select_story',
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              // `EpisodeScreen`に修正
              child: const EpisodeScreen(),
            ),
          ),
        ]),
        // 5. 設定ブランチ
        StatefulShellBranch(navigatorKey: settingsNavigatorKey, routes: [
          GoRoute(
            path: '/setting',
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const SettingsScreen(),
            ),
            onExit: (context, state) async {
              // Provider にアクセスするために Container を取得
              final container = ProviderScope.containerOf(context);
              final hasChanges = container.read(hasSettingsChangesProvider);

              if (!hasChanges) {
                return true; // 変更なし -> 遷移を許可
              }

              // 変更あり -> ダイアログを表示
              final result = await showUnsavedChangesDialog(context);

              if (result == true) {
                // 「変更を破棄」が選ばれた
                // リセット命令を Provider に送る
                container
                    .read(settingsResetTriggerProvider.notifier)
                    .update((n) => n + 1);
                return true; // 遷移を許可
              } else {
                // 「キャンセル」が選ばれた
                return false; // 遷移をブロック
              }
            },
          ),
        ]),
      ],
    ),
    GoRoute(
      path: '/story',
      parentNavigatorKey: rootNavigatorKey,
      pageBuilder: (context, state) {
        final storyIndex = state.extra is int ? state.extra as int : 0;
        return MaterialPage(child: StoryScreen(storyIndex: storyIndex));
      },
    ),
    GoRoute(
      path: '/title',
      parentNavigatorKey: rootNavigatorKey,
      pageBuilder: (context, state) {
        return const MaterialPage(child: TitleScreen());
      },
    ),
    GoRoute(
      path: '/select_girlfriend',
      parentNavigatorKey: rootNavigatorKey,
      pageBuilder: (context, state) {
        return const MaterialPage(child: SelectGirlfriendScreen());
      },
    ),

    // ↓↓↓ ★ ここにミッション画面のルートを追加 ★ ↓↓↓
    GoRoute(
      path: '/missions',
      parentNavigatorKey: rootNavigatorKey, // ボトムバーの上に全画面表示
      pageBuilder: (context, state) {
        return const MaterialPage(
          child: MissionScreen(),
          fullscreenDialog: true, // 下からスライドアップするモーダル風
        );
      },
    ),
    // ↑↑↑ ★ ここにミッション画面のルートを追加 ★
  ],
);
