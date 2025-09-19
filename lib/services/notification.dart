import 'dart:math' as math;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  NotificationService._internal();
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;

  final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  int id_notification = 0;

  bool get isInitialized => _isInitialized;

  // init
  Future<void> initNotification() async {
    if (_isInitialized) return;

    // init timezone handling
    tz.initializeTimeZones();
    final String currentTimeZone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(currentTimeZone));

    const AndroidInitializationSettings initSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings = InitializationSettings(
      android: initSettingsAndroid,
    );

    await notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        if (response.payload != null) {
          final prefs = await SharedPreferences.getInstance();
          List<String>? ids = prefs.getStringList('notify_ids');
          if (ids != null) {
            ids.any((id) => id == response.payload);
            ids.removeWhere((element) => element == response.payload);
            prefs.setStringList('notify_ids', ids);
          }
        }
      },
    );

    _isInitialized = true;
  }

  // Notification details setup
  NotificationDetails notificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'lol_schedule_channel',
        'Match Notifications',
        channelDescription: 'Channel',
        importance: Importance.max,
        priority: Priority.high,
      ),
    );
  }

  // Show an immediate Notification
  Future<void> showNotification({
    int id = 0,
    String? title,
    String? body,
    String? payload,
  }) async {
    return notificationsPlugin.show(
      id_notification++,
      title,
      body,
      notificationDetails(),
    );
  }

  Future<void> scheduleNotification({
    int id = 0,
    required String title,
    required String body,
    required DateTime datetime,
    required int matchId,
  }) async {
    final scheduledDate = tz.TZDateTime.from(datetime, tz.local);
    try {
      int id = math.Random().nextInt(10000);
      await notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        notificationDetails(),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: matchId.toString(),
      );
    } catch (e) {
      print("Error at zonedScheduleNotification----------------------------$e");
    }
  }

  Future<void> cancelNotification(int matchId) async {
  final prefs = await SharedPreferences.getInstance();
  List<String>? ids = prefs.getStringList('notify_ids') ?? [];

  String matchIdStr = matchId.toString();
  if (ids.contains(matchIdStr)) {
    int? notificationId = int.tryParse(matchIdStr);
    if (notificationId != null) {
      await notificationsPlugin.cancel(notificationId);
    }
    ids.remove(matchIdStr);
    await prefs.setStringList('notify_ids', ids);
  }
}

}
