import 'package:calisync/model/daily_streak_goal.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class StreakNotificationService {
  StreakNotificationService._();

  static final StreakNotificationService instance =
      StreakNotificationService._();

  static const int _notificationId = 42042;
  static const String _channelId = 'daily_streak_reminders';

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    tz.initializeTimeZones();
    try {
      final timezoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timezoneName));
    } catch (_) {
      tz.setLocalLocation(tz.local);
    }

    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
      macOS: DarwinInitializationSettings(),
    );

    await _notifications.initialize(settings);
    _initialized = true;
  }

  Future<void> requestPermissions() async {
    await _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();

    await _notifications
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    await _notifications
        .resolvePlatformSpecificImplementation<
          MacOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  Future<void> syncReminder(DailyStreakGoal? goal) async {
    await initialize();

    if (goal == null) {
      await _notifications.cancel(_notificationId);
      return;
    }

    final now = DateTime.now();
    final remaining = goal.remainingToday(now);
    final streakLabel = goal.currentStreak <= 0
        ? 'your streak'
        : '${goal.currentStreak}-day streak';
    final body = goal.completedToday(now)
        ? 'Tomorrow\'s target is ${goal.targetCount} ${goal.title}. Keep $streakLabel going.'
        : remaining == 0
        ? 'Finish ${goal.title} today to protect $streakLabel.'
        : '$remaining ${goal.title} left today to protect $streakLabel.';

    await _notifications.zonedSchedule(
      _notificationId,
      'Daily streak reminder',
      body,
      _nextReminder(goal, now),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          'Daily streak reminders',
          channelDescription: 'Reminds you to complete your daily streak goal.',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
        macOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  tz.TZDateTime _nextReminder(DailyStreakGoal goal, DateTime now) {
    var scheduled = DateTime(
      now.year,
      now.month,
      now.day,
      goal.reminderHour,
      goal.reminderMinute,
    );

    if (goal.completedToday(now) || !scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    return tz.TZDateTime.from(scheduled, tz.local);
  }
}
