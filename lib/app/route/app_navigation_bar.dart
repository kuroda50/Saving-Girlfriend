// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:go_router/go_router.dart';

// Project imports:
import 'package:saving_girlfriend/common/constants/assets.dart';

class AppNavigationBar extends StatelessWidget {
  const AppNavigationBar({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        height: 60,
        destinations: [
          const NavigationDestination(icon: Icon(Icons.home), label: 'ホーム'),
          NavigationDestination(
            icon: Image.asset(AppAssets.iconKiroku,
                width: 24, height: 24), // 画像のパスとサイズを指定
            label: '記録',
          ),
          const NavigationDestination(
            icon: Icon(
              Icons.currency_yen,
            ),
            label: '支出入',
          ),
          const NavigationDestination(
              icon: Icon(Icons.menu_book), label: '思い出'),
          const NavigationDestination(
              icon: Icon(
                Icons.settings,
              ),
              label: '設定'),
        ],
        onDestinationSelected: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
      ),
    );
  }
}
