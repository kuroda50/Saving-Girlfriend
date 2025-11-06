// Flutter imports:
// Package imports:

import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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

  // ↓↓↓↓ _sparkles, _trailParticles, _lastSparkleTime はすべて削除 ↓↓↓↓
  // final List<Offset> _sparkles = [];
  // final List<Offset> _trailParticles = [];
  // DateTime? _lastSparkleTime;

  // ↓↓↓↓ _addSparkle, _addSwipeTrail のロジックは Notifier に移植したので削除 ↓↓↓↓
  // void _addSparkle(PointerEvent details, BuildContext context) { ... }
  // void _addSwipeTrail(Offset pos) { ... }

  // ★ _addSwipeTrail で使っていた Random を Provider に移植し忘れていた場合、
  //    Provider 側 (ParticleNotifier) に `final Random _random = Random();` を追加してください。
  //    （もし main.dart の _addSwipeTrail で使っていなかったら不要です）
  //    ※ 前の回答 (ID: 21) のコードには移植済みです。

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
                child ?? const SizedBox.shrink(),

                // ★ ステップ3で作った描画専用ウィジェットをここに配置
                const ParticleRenderer(),

                // タップ・スワイプ検出用 Listener
                Listener(
                  behavior: HitTestBehavior.translucent,

                  // ★ setState() の代わりに Notifier のメソッドを呼ぶ
                  onPointerDown: (details) {
                    final renderBox =
                        localContext.findRenderObject() as RenderBox?;
                    if (renderBox == null) return;
                    final pos = renderBox.globalToLocal(details.position);
                    ref.read(particleProvider.notifier).addSparkle(pos);
                  },
                  onPointerMove: (details) {
                    final renderBox =
                        localContext.findRenderObject() as RenderBox?;
                    if (renderBox == null) return;
                    final pos = renderBox.globalToLocal(details.position);
                    ref.read(particleProvider.notifier).addSparkle(pos);
                  },
                  onPointerUp: (details) {
                    final renderBox =
                        localContext.findRenderObject() as RenderBox?;
                    if (renderBox == null) return;
                    // ★ 元のコードの onPointerUp は local への変換をしていなかったので、
                    //    もし 'details.position' をそのまま使いたい場合は
                    //    `ref.read(particleProvider.notifier).addSwipeTrail(details.position);`
                    //    としてください。
                    //    ただし、 localContext に合わせるため local 座標を渡すことを推奨します。
                    final pos = renderBox.globalToLocal(details.position);
                    ref.read(particleProvider.notifier).addSwipeTrail(pos);
                  },
                  child: const IgnorePointer(
                    ignoring: true,
                    child: SizedBox.expand(),
                  ),
                ),

                // ↓↓↓↓ ここにあった for ループは ParticleRenderer に移動したので削除 ↓↓↓↓
                // for (final pos in _trailParticles) TrailParticle(position: pos),
                // for (final pos in _sparkles) TapSparkleBurst(position: pos),
              ],
            ),
          ),
        );
      },
    );
  }
}
