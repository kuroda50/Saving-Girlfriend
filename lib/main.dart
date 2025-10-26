// Flutter imports:
// Package imports:
import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Project imports:
import 'package:saving_girlfriend/route/go_router.dart';
import 'package:saving_girlfriend/services/notification_service.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // タイムゾーンデータベースを初期化
  tz.initializeTimeZones();
  // デバイスのローカルタイムゾーンを設定（ここでは例として 'Asia/Tokyo'）
  // 通常はデバイスから取得しますが、ここでは例示
  tz.setLocalLocation(tz.getLocation('Asia/Tokyo'));

  // Device Previewを有効にしたいときはコメントアウトを外してください
  // runApp(
  //   DevicePreview(
  //     enabled: !kReleaseMode,
  //     builder: (context) => const ProviderScope(
  //       child: MyApp(),
  //     ),
  //   ),
  // );

  // 通常のアプリ起動
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    final notificationService = ref.read(notificationServiceProvider);
    await notificationService.initializeNotifications();
    await notificationService.requestPermissions();
  }

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
