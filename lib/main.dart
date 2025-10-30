// Flutter imports:
// Package imports:
import 'dart:math';

import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:saving_girlfriend/providers/particle_provider.dart';
// Project imports:
import 'package:saving_girlfriend/route/go_router.dart';
import 'package:saving_girlfriend/services/notification_service.dart';
import 'package:saving_girlfriend/widgets/particle_renderer.dart';
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
    DevicePreview(
      enabled: !kReleaseMode,
      builder: (context) => const ProviderScope(
        child: MyApp(),
        // huskyでも動作するか確認.
      ),
    ),
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

/// ✨ エフェクトウィジェット
class _SparkleEffect extends StatefulWidget {
  final Offset position;
  const _SparkleEffect({required this.position});

  @override
  State<_SparkleEffect> createState() => _SparkleEffectState();
}

class _SparkleEffectState extends State<_SparkleEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final Random _random = Random();
  late double _sparkleSize;
  late IconData _icon;
  late Color _color;

  final _pastelColors = [
    Colors.pinkAccent.withOpacity(0.6),
    Colors.yellowAccent.withOpacity(0.5),
    Colors.white.withOpacity(0.8),
    Colors.purpleAccent.withOpacity(0.4),
  ];

  final _icons = [Icons.favorite, Icons.star_rounded];

  @override
  void initState() {
    super.initState();
    _sparkleSize = 20 + _random.nextDouble() * 10;
    _icon = _icons[_random.nextInt(_icons.length)];
    _color = _pastelColors[_random.nextInt(_pastelColors.length)];

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..forward();
  }

  @override
  void dispose() {
    _controller.stop(); // ← これを追加！
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final position = widget.position;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final progress = Curves.easeOut.transform(_controller.value);
        final opacity = 1 - progress;
        final scale = 1 + progress * 0.6;
        final dy = position.dy - (progress * 30); // ふわっと上に移動

        return Positioned(
          left: position.dx - (_sparkleSize / 2),
          top: dy - (_sparkleSize / 2),
          child: IgnorePointer(
            ignoring: true,
            child: Opacity(
              opacity: opacity,
              child: Transform.scale(
                scale: scale,
                child: Icon(
                  _icon,
                  color: _color,
                  size: _sparkleSize,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// ✨ タップで散る光エフェクト (指を離した時用・大きい)
class TapSparkleBurst extends StatefulWidget {
  final Offset position;
  const TapSparkleBurst({super.key, required this.position});

  @override
  State<TapSparkleBurst> createState() => _TapSparkleBurstState();
}

/// ✨「スワイプ中」の小さい光エフェクト
class SwipeSparkle extends StatefulWidget {
  final Offset position;
  const SwipeSparkle({super.key, required this.position});

  @override
  State<SwipeSparkle> createState() => _SwipeSparkleState(); // ←★ 修正
}

// --- 「小さい」エフェクトの中身 ---
class _SwipeSparkleState extends State<SwipeSparkle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final Random _random = Random();
  late List<_Particle> _particles; // _Particleクラスは共用

  final _colors = [
    Colors.pinkAccent.withOpacity(0.4),
    Colors.white.withOpacity(0.6),
    Colors.purpleAccent.withOpacity(0.3),
    Colors.yellowAccent.withOpacity(0.4),
  ];
  final _icons = [Icons.star_rounded, null]; // nullなら丸 (Favoriteを減らす)

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600), // ←★アニメーション時間を短く
    )..forward();

    // ランダムな粒を生成
    _particles = List.generate(2 + _random.nextInt(2), (_) {
      // ←★粒の数を減らす (2-3個)
      final angle = _random.nextDouble() * 2 * pi;
      final distance = 10 + _random.nextDouble() * 15; // ←★飛ぶ距離を短く
      final size = 2 + _random.nextDouble() * 4; // ←★粒のサイズを小さく
      final color = _colors[_random.nextInt(_colors.length)];
      final icon = _icons[_random.nextInt(_icons.length)];
      return _Particle(angle, distance, size, color, icon);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // (TapSparkleBurstのbuildメソッドと全く同じでOK)
    final pos = widget.position;
    return Positioned.fill(
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final t = _controller.value;
            final opacity = 1 - t;
            return Stack(
              children: _particles.map((p) {
                final dx = pos.dx + cos(p.angle) * p.distance * t;
                final dy = pos.dy + sin(p.angle) * p.distance * t;

                return Positioned(
                  left: dx,
                  top: dy,
                  child: Opacity(
                    opacity: opacity,
                    child: Transform.scale(
                      scale: 0.8 + t,
                      child: p.icon != null
                          ? Icon(
                              p.icon,
                              color: p.color,
                              size: p.size * 2,
                            )
                          : Container(
                              width: p.size,
                              height: p.size,
                              decoration: BoxDecoration(
                                color: p.color,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: p.color.withOpacity(0.5),
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ),
    );
  }
}

// --- 「大きい」エフェクトの中身 ---
class _TapSparkleBurstState extends State<TapSparkleBurst>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final Random _random = Random();
  late List<_Particle> _particles;

  final _colors = [
    Colors.pinkAccent.withOpacity(0.4),
    Colors.white.withOpacity(0.6),
    Colors.purpleAccent.withOpacity(0.3),
    Colors.yellowAccent.withOpacity(0.4),
  ];

  final _icons = [Icons.star_rounded, Icons.favorite, null]; // nullなら丸

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000), // ←★アニメーション時間 (そのまま)
    )..forward();

    // ランダムな粒を生成
    _particles = List.generate(4 + _random.nextInt(2), (_) {
      // ←★粒の数 (4-5個)
      final angle = _random.nextDouble() * 2 * pi;
      final distance = 25 + _random.nextDouble() * 40; // ←★飛ぶ距離 (そのまま)
      final size = 3 + _random.nextDouble() * 7; // ←★粒のサイズ (そのまま)
      final color = _colors[_random.nextInt(_colors.length)];
      final icon = _icons[_random.nextInt(_icons.length)];
      return _Particle(angle, distance, size, color, icon);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // (buildメソッドはSwipeSparkleとほぼ同じ)
    final pos = widget.position;
    return Positioned.fill(
      // ... (中身は同じなので省略) ...
      // ... (貼り付ける際は元のコードの build をそのまま使ってください) ...
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final t = _controller.value;
            final opacity = 1 - t;
            return Stack(
              children: _particles.map((p) {
                final dx = pos.dx + cos(p.angle) * p.distance * t;
                final dy = pos.dy + sin(p.angle) * p.distance * t;

                return Positioned(
                  left: dx,
                  top: dy,
                  child: Opacity(
                    opacity: opacity,
                    child: Transform.scale(
                      scale: 0.8 + t,
                      child: p.icon != null
                          ? Icon(
                              p.icon,
                              color: p.color,
                              size: p.size * 2,
                            )
                          : Container(
                              width: p.size,
                              height: p.size,
                              decoration: BoxDecoration(
                                color: p.color,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: p.color.withOpacity(0.5),
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ),
    );
  }
}

/// パーティクルデータクラス
class _Particle {
  final double angle;
  final double distance;
  final double size;
  final Color color;
  final IconData? icon; // ← アイコン追加！

  _Particle(this.angle, this.distance, this.size, this.color, this.icon);
}

// ふわっとした軌跡パーティクル用
class TrailParticle extends StatefulWidget {
  final Offset position;
  const TrailParticle({super.key, required this.position}); // <-- 修正

  @override
  State<TrailParticle> createState() => _TrailParticleState();
}

class _TrailParticleState extends State<TrailParticle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final Random _rand = Random();
  late Color _color;

  @override
  void initState() {
    super.initState();
    _color = [
      Colors.pinkAccent,
      Colors.white,
      Colors.purpleAccent,
      Colors.yellowAccent,
    ][_rand.nextInt(4)]
        .withOpacity(0.6);

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..forward();

    // ✅ アニメーションが終わったら自動で安全に破棄されるように
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (mounted) {
          _controller.stop();
        }
      }
    });
  }

  @override
  void dispose() {
    try {
      _controller.stop();
      _controller.dispose();
    } catch (_) {
      // 念のため例外は握りつぶす（リリースビルドでも落ちないように）
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.position;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = Curves.easeOut.transform(_controller.value);
        final opacity = 1 - t;
        final dy = p.dy - t * 10;
        return Positioned(
          left: p.dx,
          top: dy,
          child: Opacity(
            opacity: opacity,
            child: Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: _color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _color.withOpacity(0.5),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
