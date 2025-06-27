import 'package:go_router/go_router.dart';
import 'package:saving_girlfriend/screen/home_screen.dart';
import 'package:saving_girlfriend/screen/select_girlfriend_screen.dart';
import 'package:saving_girlfriend/screen/select_story_screen.dart';
import 'package:saving_girlfriend/screen/settings_screen.dart';
import 'package:saving_girlfriend/screen/tribute_history_screen.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => HomeScreen(),
    ),
    GoRoute(
      path: '/select_story',
      builder: (context, state) => SelectStoryScreen(),
    ),
    GoRoute(
      path: '/select_girlfriend',
      builder: (context, state) => SelectGirlfriendScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => SettingsScreen(),
    ),
    GoRoute(
      path: '/tribute_history',
      builder: (context, state) => TributeHistoryScreen(),
    ),
  ],
);
