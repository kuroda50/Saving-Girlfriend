import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
        destinations: [
          const NavigationDestination(icon: Icon(Icons.home), label: 'ホーム'),
          const NavigationDestination(icon: Icon(Icons.person), label: '彼女'),
          // NavigationDestination(
          //   icon: Image.asset('images/Gemini_Generated_Image_9pzle39pzle39pzl.png',
          //       width: 24, height: 24), // 画像のパスとサイズを指定
          //   label: '思い出',
          // ),
          const NavigationDestination(icon: Icon(Icons.menu_book), label: '思い出'),
          NavigationDestination(
            icon: Image.asset('images/kiroku.png',
                width: 24, height: 24), // 画像のパスとサイズを指定
            label: '記録',
          ),
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
