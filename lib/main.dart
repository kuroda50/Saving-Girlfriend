import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:saving_girlfriend/services/local_storage_service.dart';
import 'package:saving_girlfriend/route/go_router.dart';
import 'package:saving_girlfriend/screen/title_screen.dart';

// ... 他のimport
void main() async {
  // Flutterエンジンのバインディングを保証
  WidgetsFlutterBinding.ensureInitialized();

  // LocalStorageServiceのstaticなinit()メソッドを呼び出して初期化を待つ
  await LocalStorageService.init();

  // LocalStorageServiceのインスタンスを作成
  final localStorageService = LocalStorageService();

  // ユーザーIDが保存されているかをチェックして、初回起動かどうかを判定
  final userId = await localStorageService.getUserId();
  final isFirstLaunch = userId == null;

  runApp(
    ProviderScope(
      child: MyApp(isFirstLaunch: isFirstLaunch),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool isFirstLaunch;

  const MyApp({super.key, required this.isFirstLaunch});

  @override
  Widget build(BuildContext context) {
    if (isFirstLaunch) {
      // 初回起動の場合
      return MaterialApp(
        home: TitleScreen(),
        theme: ThemeData.light(),
        darkTheme: ThemeData.dark(),
      );
    } else {
      // 2回目以降の起動の場合
      return MaterialApp.router(
        routerConfig: router,
        theme: ThemeData.light(),
        darkTheme: ThemeData.dark(),
      );
    }
  }
}
