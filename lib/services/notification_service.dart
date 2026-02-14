import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import '../models/hydration_schedule.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  /// Initialize notification service
  Future<void> initialize() async {
    if (_initialized) return;

    // Initialize timezone
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));

    // Android settings
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS settings
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(initSettings);

    // Request permissions (Android 13+)
    await requestPermissions();

    _initialized = true;
  }

  /// Request notification permissions
  Future<void> requestPermissions() async {
    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  /// Schedule daily hydration reminders
  Future<void> scheduleHydrationReminders(HydrationSchedule schedule) async {
    await initialize();

    // Cancel existing notifications first
    await cancelAllNotifications();

    // Schedule for each hour
    for (int i = 0; i < schedule.hours.length; i++) {
      final hour = schedule.hours[i];

      await _scheduleDailyNotification(
        id: i,
        hour: hour,
        minute: 0,
      );
    }
  }

  /// Schedule single daily notification
  Future<void> _scheduleDailyNotification({
    required int id,
    required int hour,
    required int minute,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // If time has passed today, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _notifications.zonedSchedule(
      id,
      '💧 Waktunya Minum Air',
      _getRandomMessage(),
      scheduledDate,
      _notificationDetails(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // Daily repeat
    );
  }

  /// Test notification (immediate)
  Future<void> sendTestNotification() async {
    await initialize();

    await _notifications.show(
      999, // Test ID
      '💧 Time To Drink Water',
      'Jangan Lupa Mengonsumsi Air Putih! 👍',
      _notificationDetails(),
    );
  }

  /// Notification details
  NotificationDetails _notificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'hydration_reminder',
        'Pengingat Minum Air',
        channelDescription:
            'Notifikasi untuk mengingatkan minum air secara teratur',
        importance: Importance.high,
        priority: Priority.high,
        enableVibration: true,
        playSound: true,
        icon: '@mipmap/ic_launcher',
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );
  }

  /// Random motivational messages
  String _getRandomMessage() {
    final messages = [
      'Jangan lupa minum air ya! Tubuhmu butuh hidrasi 😊',
      'Yuk minum air! Tetap terhidrasi, tetap sehat 💪',
      'Waktunya minum air! Segerkan tubuh dan pikiranmu 🌊',
      'Hey! Sudah minum air hari ini? Ayo minum sekarang 💧',
      'Tubuh 70% air lho! Jaga keseimbangan cairanmu ✨',
      'Minum air = kulit sehat + otak fokus! Ayo minum 🥤',
      'Jangan sampai dehidrasi ya! Minum air sekarang 💙',
    ];
    return messages[DateTime.now().millisecond % messages.length];
  }

  /// Update notification messages to include target
  Future<void> updateNotificationMessages(double targetLiters) async {
    // This could be used to customize messages based on target
    // For now, keep existing messages
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  /// Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    if (!_initialized) await initialize();

    final result = await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.areNotificationsEnabled();

    return result ?? false;
  }
}
