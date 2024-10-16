import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import '../model/room.dart';

class NotificationManager {
  static final NotificationManager _instance = NotificationManager._internal();

  factory NotificationManager() {
    return _instance;
  }

  NotificationManager._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  initializeNotifications() async {
    const androidSettings =
        AndroidInitializationSettings("@mipmap/ic_launcher");
    const iosSettings = DarwinInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
    );
    const settings =
        InitializationSettings(android: androidSettings, iOS: iosSettings);
    await _flutterLocalNotificationsPlugin.initialize(settings);
  }

  Future<void> scheduleNotification(Room room) async {
    final DateTime now = DateTime.now();
    final notificationTime =
        room.startTime.subtract(const Duration(minutes: 1));
    final scheduledDateTime = tz.TZDateTime.from(notificationTime, tz.local);

    if (scheduledDateTime.isAfter(now)) {
      await _flutterLocalNotificationsPlugin.zonedSchedule(
        room.roomId,
        '방 예약 알림',
        '[${room.roomName}]방이 1분 뒤에 시작합니다!\n서둘러주세요 :)',
        scheduledDateTime,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            '방 예약 알림 채널',
            '방 예약 알림',
            channelDescription: '방 예약 알림을 위한 채널',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exact,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  Future<void> cancelNotification(Room room) async {
    int notificationId = room.roomId;
    await _flutterLocalNotificationsPlugin.cancel(notificationId);
  }
}
