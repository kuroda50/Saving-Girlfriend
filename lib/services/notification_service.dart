import 'dart:math'; // For random message selection

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // For Ref
import 'package:saving_girlfriend/features/story/models/story_model.dart'; // For StoryCharacter
import 'package:saving_girlfriend/features/story/repositories/story_repository.dart'; // For StoryCharacter
import 'package:saving_girlfriend/providers/likeability_provider.dart'; // For likeabilityProvider
import 'package:timezone/timezone.dart' as tz;

// Provider for NotificationService
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService(ref);
});

class NotificationService {
  final Ref _ref; // Riverpod Ref to access other providers
  NotificationService(this._ref);

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'channel_id',
    'channel_name',
    description: 'Channel description',
    importance: Importance.max,
  );

  Future<void> initializeNotifications() async {
    if (kIsWeb) {
      // Webでは通知を初期化しない
      return;
    }

    // 1. 初期化設定 (Android)
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
    if (kIsWeb) {
      // Webでは通知権限をリクエストしない
      return;
    }
    final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
        _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.requestNotificationsPermission();
    await androidPlugin?.requestExactAlarmsPermission(); // 必要に応じて
  }

  /// 毎日19時に通知をスケジュールする
  Future<void> scheduleDailyNotification(
      String characterId, int notificationId) async {
    if (kIsWeb) return;
    final storyRepo = _ref.read(storyRepositoryProvider);
    final character = storyRepo.getCharacterById(characterId);
    if (character == null) return;

    // 好感度プロバイダーから現在の好感度を取得
    final likeability = await _ref.read(likeabilityProvider.future);

    final String message =
        _generateAffectionBasedMessage(character, likeability);

    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      15, // 19:00
      59,
      0,
    );

    // もしスケジュール時刻が現在時刻より前なら、翌日に設定
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await scheduleNotification(
      id: notificationId, // Unique ID for this character's notification
      title: '${character.name}からのメッセージ',
      body: message,
      scheduledDate: scheduledDate,
      repeatDaily: true,
    );
  }

  /// すべての通知をキャンセルする
  Future<void> cancelAllNotifications() async {
    if (kIsWeb) return;
    await _plugin.cancelAll();
  }

  /// 指定された通知IDの通知をキャンセルする
  Future<void> cancelNotification(int id) async {
    if (kIsWeb) return;
    await _plugin.cancel(id);
  }

  /// 好感度に基づいて通知メッセージを生成する
  String _generateAffectionBasedMessage(
      StoryCharacter character, int likeability) {
    final messages = character.notificationMessages;
    if (messages.isEmpty) return 'メッセージがありません。';

    // 好感度に基づいて適切なメッセージリストを選択
    // キーは好感度の閾値 (例: 0, 10, 30, 50, 80)
    final sortedKeys = messages.keys.toList()..sort();
    List<String> candidateMessages = [];

    for (final threshold in sortedKeys.reversed) {
      if (likeability >= threshold) {
        candidateMessages = messages[threshold]!;
        break;
      }
    }

    if (candidateMessages.isEmpty) {
      // どの閾値にも合致しない場合、最も低い閾値のメッセージを使用
      if (messages.isNotEmpty) {
        candidateMessages = messages[sortedKeys.first]!;
      } else {
        return 'メッセージがありません。';
      }
    }

    // ランダムにメッセージを選択
    return candidateMessages[Random().nextInt(candidateMessages.length)];
  }

  // 6. スケジュール通知 (既存のメソッド)
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    bool repeatDaily = false,
  }) async {
    if (kIsWeb) return;
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

  // 10. 即時通知のテスト用 (既存のメソッド)
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    if (kIsWeb) return;
    // scheduleNotification からチャンネル定義をコピー
    NotificationDetails notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        NotificationService.channel.id,
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
}
