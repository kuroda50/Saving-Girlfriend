import 'package:go_router/go_router.dart';
import 'package:saving_girlfriend/screen/home_screen.dart';
import 'package:saving_girlfriend/screen/select_girlfriend_screen.dart';
import 'package:saving_girlfriend/screen/select_story_screen.dart';
import 'package:saving_girlfriend/screen/story_screen.dart';
import 'package:saving_girlfriend/screen/settings_screen.dart';
import 'package:saving_girlfriend/screen/tribute_history_screen.dart';
import 'app_navigation_bar.dart';
import 'package:flutter/material.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();
final homeNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'home');
final selectStoryNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'select_story');
final selectGirlfriendNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'select_girlfriend');
final tributeHistoryNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'tribute_history');

final router = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: '/home',
  routes: [
    StatefulShellRoute.indexedStack(
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state, navigationShell) {
          return AppNavigationBar(navigationShell: navigationShell);
        },
        branches: [
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
          StatefulShellBranch(navigatorKey: selectStoryNavigatorKey, routes: [
            GoRoute(
              path: '/select_story',
              pageBuilder: (context, state) => NoTransitionPage(
                key: state.pageKey,
                child: const EpisodeScreen(),
              ),
              routes: [
                GoRoute(
                  path: 'story',
                  parentNavigatorKey: rootNavigatorKey,
                  pageBuilder: (context, state) {
                    return const MaterialPage(child: StoryScreen());
                  },
                )
              ],
            ),
          ]),
          StatefulShellBranch(
              navigatorKey: tributeHistoryNavigatorKey,
              routes: [
                GoRoute(
                  path: '/tribute_history',
                  pageBuilder: (context, state) => NoTransitionPage(
                    key: state.pageKey,
                    child: const TributeHistoryScreen(),
                  ),
                ),
              ]),
        ]),
  ],
);
