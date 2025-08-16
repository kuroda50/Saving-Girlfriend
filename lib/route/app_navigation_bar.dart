import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:saving_girlfriend/constants/assets.dart';

class AppNavigationBar extends StatelessWidget {
  const AppNavigationBar({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _calculateSelectedIndex(context),
        destinations: [
          const NavigationDestination(icon: Icon(Icons.home), label: 'ホーム'),
          const NavigationDestination(icon: Icon(Icons.person), label: '彼女'),
          const NavigationDestination(
              icon: Icon(Icons.menu_book), label: '思い出'),
          NavigationDestination(
            icon: Image.asset(AppAssets.iconKiroku,
                width: 24, height: 24), // 画像のパスとサイズを指定
            label: '記録',
          ),
        ],
        onDestinationSelected: (index) {
          _onItemTapped(index, context);
        },
      ),
    );
  }

  static int _calculateSelectedIndex(BuildContext context) {
    // GoRouterの状態から現在のロケーション（パス）を取得
    final String location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/home')) {
      return 0;
    }
    if (location.startsWith('/select_girlfriend')) {
      return 1;
    }
    if (location.startsWith('/select_story')) {
      return 2;
    }
    if (location.startsWith('/tribute_history')) {
      return 3;
    }
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/select_girlfriend');
        break;
      case 2:
        context.go('/select_story');
        break;
      case 3:
        context.go('/tribute_history');
        break;
    }
  }
}
