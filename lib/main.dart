// Flutter imports:
// Package imports:

import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Project imports:
import 'package:saving_girlfriend/app/route/go_router.dart';
import 'package:saving_girlfriend/common/providers/particle_provider.dart';
import "package:saving_girlfriend/common/widgets/effects/particle_renderer.dart";
import 'package:saving_girlfriend/features/story/services/notification_service.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // タイムゾーンデータベースを初期化
  tz.initializeTimeZones();
  // デバイスのローカルタイムゾーンを設定（ここでは例として 'Asia/Tokyo'）
  // 通常はデバイスから取得しますが、ここでは例示
  tz.setLocalLocation(tz.getLocation('Asia/Tokyo'));

  runApp(
    kIsWeb
        ? DevicePreview(
            enabled: !kReleaseMode,
            builder: (context) => const ProviderScope(
              child: MyApp(),
            ),
          )
        : const ProviderScope(child: MyApp()),
  );
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
      // ignore: deprecated_member_use
      useInheritedMediaQuery: true,
      locale: DevicePreview.locale(context),
      builder: (context, child) {
        return DevicePreview.appBuilder(
          context,
          Builder(
            builder: (localContext) => Stack(
              fit: StackFit.expand,
              children: [
                // ★★★ 1. 各画面（story_screen など）を一番背後に配置
                child ?? const SizedBox.shrink(),

                // ★★★ 2. タップ検出用 Listener を中間に配置
                Listener(
                  behavior: HitTestBehavior.translucent, // ★ 背後(child)の操作を妨害しない
                  onPointerDown: (details) {
                    final renderBox =
                        localContext.findRenderObject() as RenderBox?;
                    if (renderBox == null) return;
                    final pos = renderBox.globalToLocal(details.position);
                    // タップした瞬間の「波紋」を呼ぶ
                    ref.read(particleProvider.notifier).addTapRipple(pos);
                  },
                  onPointerMove: (details) {
                    final renderBox =
                        localContext.findRenderObject() as RenderBox?;
                    if (renderBox == null) return;
                    final pos = renderBox.globalToLocal(details.position);
                    // スワイプ中の「軌跡」を呼ぶ
                    ref.read(particleProvider.notifier).addTrail(pos);
                  },
                  onPointerUp: (details) {
                    // (処理なし)
                  },
                  child: const SizedBox.expand(),
                ),

                // ★★★ 3. エフェクト描画（最前面、タップ操作は無視）
                const IgnorePointer(
                  ignoring: true, // ★ タップイベントを完全に無視させる
                  child: ParticleRenderer(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
