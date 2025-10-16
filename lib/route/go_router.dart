import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:saving_girlfriend/route/app_navigation_bar.dart';
import 'package:saving_girlfriend/screen/home_screen.dart';
import 'package:saving_girlfriend/screen/select_girlfriend_screen.dart';
import 'package:saving_girlfriend/screen/select_story_screen.dart';
import 'package:saving_girlfriend/screen/settings_screen.dart';
import 'package:saving_girlfriend/screen/story_screen.dart';
import 'package:saving_girlfriend/screen/title_screen.dart';
import 'package:saving_girlfriend/screen/transaction_history_screen.dart';
import 'package:saving_girlfriend/screen/transaction_input_screen.dart';

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
        // 4. 貢ぎ履歴ブランチ
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

        // 5. 収支入力ブランチ
        StatefulShellBranch(
          navigatorKey: transactionInputNavigatorKey,
          routes: [
            GoRoute(
              path: '/transaction_input',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: TransactionInputScreen(),
              ),
            ),
          ],
        ),
        // 3. ストーリー選択ブランチ
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
        // 2. 設定ブランチ
        StatefulShellBranch(navigatorKey: settingsNavigatorKey, routes: [
          GoRoute(
            path: '/setting',
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const SettingsScreen(),
            ),
          ),
        ]),
      ],
    ),
    GoRoute(
      path: '/story',
      parentNavigatorKey: rootNavigatorKey,
      pageBuilder: (context, state) {
        final storyIndex = state.extra is int ? state.extra as int : 0;
        return MaterialPage(child: StoryScreen(story_index: storyIndex));
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
  ],
);
