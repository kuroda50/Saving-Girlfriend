import 'package:flutter/material.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:saving_girlfriend/route/go_router.dart';
import 'services/local_storage_service.dart';

void main() async {
  // Flutterの初期化を保証する（おまじない）
  WidgetsFlutterBinding.ensureInitialized();
  
  // LocalStorageの準備
  await LocalStorageService.init();

  runApp(
    DevicePreview(
      enabled: !kReleaseMode,
      // ★★★↓ ProviderScopeでアプリ全体を囲む ↓★★★
      builder: (context) => ProviderScope(child: MyApp()),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: router,
      useInheritedMediaQuery: true,
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
    );
  }
}