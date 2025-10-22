import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  // シングルトン（インスタンスを一つだけ作成する）
  static final NotificationService _notificationService =
      NotificationService._internal();
  factory NotificationService() {
    return _notificationService;
  }
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  // scheduleNotification で使用するチャンネルと「同じ情報」を定義する
  static const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'channel_id', // ID (scheduleNotification と同じ)
    'channel_name', // 名前 (scheduleNotification と同じ)
    description: 'Channel description', // 説明
    importance: Importance.max, // 重要度 (scheduleNotification と同じ)
  );

  Future<void> initialize() async {
    // 1. 初期化設定 (Android)
    // 'app_icon' は android/app/src/main/res/drawable/ に配置したアイコン名
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('app_icon');

    // 2. 初期化設定 (iOS)
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // 3. 初期化設定 (全体)
    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    // 4. Androidプラグインのインスタンスを取得
    final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
        _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    // 5. [重要] Android 8.0 以降の場合、チャンネルをOSに登録する
    await androidPlugin?.createNotificationChannel(channel);

    // 6. プラグインの初期化
    await _plugin.initialize(initializationSettings);
  }

  // 5. [重要] 通知権限のリクエスト (Android 13以降)
  Future<void> requestPermissions() async {
    final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
        _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.requestNotificationsPermission();
    await androidPlugin?.requestExactAlarmsPermission(); // 必要に応じて
  }

  // 6. スケジュール通知
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    bool repeatDaily = false,
  }) async {
    // 7. 通知の詳細設定
    final NotificationDetails notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        channel.id,
        channel.name,
        channelDescription: channel.description,
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: const DarwinNotificationDetails(),
    );

    // 8. [重要] スケジュール時刻を TZDateTime に変換
    final tz.TZDateTime scheduledTZDate = tz.TZDateTime.from(
      scheduledDate,
      tz.local, // デバイスのローカルタイムゾーンを使用
    );

    // 9. zonedSchedule を使って通知を予約
    await _plugin.zonedSchedule(
      id,
      title,
      body,
      scheduledTZDate,
      notificationDetails,
      // Androidでの時刻指定の扱い
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      // 毎日同じ時刻に繰り返す場合
      matchDateTimeComponents: repeatDaily ? DateTimeComponents.time : null,
    );
  }

  // 10. 即時通知のテスト用
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    // scheduleNotification からチャンネル定義をコピー
    NotificationDetails notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        NotificationService.channel.id, // 以前定義した channel を使う
        NotificationService.channel.name,
        channelDescription: NotificationService.channel.description,
        importance: NotificationService.channel.importance,
        priority: Priority.high,
      ),
      iOS: const DarwinNotificationDetails(),
    );

    // .zonedSchedule の代わりに .show() を使う
    await _plugin.show(
      id,
      title,
      body,
      notificationDetails,
    );
  }

  // 通知をキャンセルする（おまけ）
  Future<void> cancelNotification(int id) async {
    await _plugin.cancel(id);
  }
}
