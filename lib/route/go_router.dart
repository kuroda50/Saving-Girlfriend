import 'package:go_router/go_router.dart';
import 'package:saving_girlfriend/screen/home_screen.dart';
import 'package:saving_girlfriend/screen/select_girlfriend_screen.dart';
import 'package:saving_girlfriend/screen/select_story_screen.dart';
import 'package:saving_girlfriend/screen/story_screen.dart';
import 'package:saving_girlfriend/screen/settings_screen.dart';
import 'package:saving_girlfriend/screen/tribute_history_screen.dart';
import 'package:saving_girlfriend/screen/transaction_input_screen.dart';
import 'package:saving_girlfriend/screen/title_screen.dart';
import 'package:saving_girlfriend/route/app_navigation_bar.dart';
import 'package:flutter/material.dart';

// 各ブランチのナビゲーションスタックを管理するためのGlobalKey
final rootNavigatorKey = GlobalKey<NavigatorState>();
final homeNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'home');
final selectStoryNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'select_story');
final selectGirlfriendNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'select_girlfriend');
final tributeHistoryNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'tribute_history');
// 新しい画面用のGlobalKeyを追加
final transactionInputNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'transaction_input');

final router = GoRouter(
  navigatorKey: rootNavigatorKey,
  // initialLocationを削除
  initialLocation: '/',
  // リダイレクトロジックを追加
  redirect: (context, state) {
    // 常にTitleScreenにリダイレクトする
    // ただし、既に'/title'にいる場合はリダイレクトしない
    if (state == '/') {
      return '/title';
    }
    return null;
  },
  routes: [
    // タイトル画面のルートを定義
    GoRoute(
      path: '/title',
      pageBuilder: (context, state) => const NoTransitionPage(
        child: TitleScreen(),
      ),
    ),
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
            routes: [
              GoRoute(
                path: 'settings',
                parentNavigatorKey: rootNavigatorKey,
                pageBuilder: (context, state) {
                  return const MaterialPage(child: SettingsScreen());
                },
              )
            ],
          ),
        ]),
        // 2. 彼女選択ブランチ
        StatefulShellBranch(
            navigatorKey: selectGirlfriendNavigatorKey,
            routes: [
              GoRoute(
                path: '/select_girlfriend',
                pageBuilder: (context, state) => NoTransitionPage(
                  key: state.pageKey,
                  child: const SelectGirlfriendScreen(),
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
        // 4. 貢ぎ履歴ブランチ
        StatefulShellBranch(navigatorKey: tributeHistoryNavigatorKey, routes: [
          GoRoute(
            path: '/tribute_history',
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const TributeHistoryScreen(),
            ),
          ),
        ]),
      ],
    ),
    GoRoute(
      path: '/story',
      parentNavigatorKey: rootNavigatorKey,
      pageBuilder: (context, state) {
        final story_index = state.extra is int ? state.extra as int : 0;
        return MaterialPage(child: StoryScreen(story_index: story_index));
      },
    ),
  ],
);
