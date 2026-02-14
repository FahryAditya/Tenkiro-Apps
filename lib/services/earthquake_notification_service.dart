import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/earthquake.dart';
import '../models/earthquake_settings.dart';

class EarthquakeNotificationService {
  static final EarthquakeNotificationService _instance =
      EarthquakeNotificationService._internal();
  factory EarthquakeNotificationService() => _instance;
  EarthquakeNotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(settings);
  }

  Future<void> showEarthquakeNotification(
    Earthquake earthquake,
    EarthquakeSettings settings,
  ) async {
    if (!settings.notificationsEnabled) return;
    
    if (earthquake.magnitude < settings.minimumMagnitude) return;
    
    if (settings.tsunamiAlertsOnly && earthquake.tsunami == TsunamiStatus.none) {
      return;
    }
    
    if (earthquake.distanceFromUser != null &&
        earthquake.distanceFromUser! > settings.maxDistanceKm) {
      return;
    }

    final androidDetails = AndroidNotificationDetails(
      'earthquake_alerts',
      'Peringatan Gempa',
      channelDescription: 'Notifikasi gempa bumi terkini',
      importance: Importance.max,
      priority: Priority.high,
      enableVibration: settings.vibrate,
      playSound: settings.sound,
      color: earthquake.alertColor,
      icon: '@mipmap/ic_launcher',
      styleInformation: _buildNotificationStyle(earthquake),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      interruptionLevel: InterruptionLevel.critical,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      earthquake.id.hashCode,
      _buildTitle(earthquake),
      _buildBody(earthquake),
      details,
      payload: earthquake.id,
    );
  }

  BigTextStyleInformation _buildNotificationStyle(Earthquake earthquake) {
    final lines = <String>[
      'Magnitudo: ${earthquake.magnitude.toStringAsFixed(1)} Mw',
      'Lokasi: ${earthquake.region}',
      'Kedalaman: ${earthquake.depth.toStringAsFixed(0)} km',
      if (earthquake.distanceFromUser != null)
        'Jarak: ${earthquake.distanceFromUser!.toStringAsFixed(0)} km dari Anda',
      if (earthquake.tsunami != TsunamiStatus.none)
        '⚠️ ${earthquake.tsunami.label}',
    ];

    return BigTextStyleInformation(
      lines.join('\n'),
      contentTitle: _buildTitle(earthquake),
      summaryText: earthquake.timeAgo,
    );
  }

  String _buildTitle(Earthquake earthquake) {
    final emoji = _getMagnitudeEmoji(earthquake.magnitude);
    final tsunamiEmoji = earthquake.tsunami != TsunamiStatus.none ? '🌊 ' : '';
    return '$tsunamiEmoji$emoji Gempa ${earthquake.alertLevel}';
  }

  String _buildBody(Earthquake earthquake) {
    return 'M${earthquake.magnitude.toStringAsFixed(1)} • ${earthquake.region}';
  }

  String _getMagnitudeEmoji(double magnitude) {
    if (magnitude >= 7.0) return '🔴';
    if (magnitude >= 6.0) return '🟠';
    if (magnitude >= 5.0) return '🟡';
    return '🟢';
  }

  Future<void> requestPermissions() async {
    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.requestNotificationsPermission();

    final iosPlugin = _notifications.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    await iosPlugin?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
      critical: true,
    );
  }

  Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }

  Future<void> cancel(int id) async {
    await _notifications.cancel(id);
  }
}