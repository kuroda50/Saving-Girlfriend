import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:saving_girlfriend/route/go_router.dart';
import 'package:saving_girlfriend/services/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // タイムゾーンデータベースを初期化
  tz.initializeTimeZones();
  // デバイスのローカルタイムゾーンを設定（ここでは例として 'Asia/Tokyo'）
  // 通常はデバイスから取得しますが、ここでは例示
  tz.setLocalLocation(tz.getLocation('Asia/Tokyo'));

  await NotificationService().initialize();
  await NotificationService().requestPermissions(); // Android 13以降のために

  final prefs = await SharedPreferences.getInstance();
  const String firstLaunchKey = 'isFirstLaunch';
  bool isFirstLaunch = prefs.getBool(firstLaunchKey) ?? true;

  if (isFirstLaunch) {
    // 初回起動時に毎日19時に通知をスケジュール
    final now = DateTime.now();
    DateTime scheduledDate = DateTime(now.year, now.month, now.day, 19, 0, 0);
    // もし現在時刻が19時を過ぎていたら、翌日の19時に設定
    if (now.hour >= 19) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await NotificationService().scheduleNotification(
      id: 0, // 通知ID
      title: '今日の振り返り',
      body: '今日の出来事を記録しましょう！',
      scheduledDate: scheduledDate,
      repeatDaily: true,
    );

    await prefs.setBool(firstLaunchKey, false);
  }

  runApp(
    DevicePreview(
      enabled: !kReleaseMode,
      builder: (context) => const ProviderScope(
        child: MyApp(),
        // huskyでも動作するか確認.
      ),
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
