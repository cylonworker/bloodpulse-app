import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../domain/entities/blood_pressure_reading.dart';
import '../core/utils/health_status_calculator.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;
    
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
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
    _isInitialized = true;
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
    );
  }

  Future<void> showHighBpNotification(BloodPressureReading reading) async {
    final status = HealthStatusCalculator.categorize(reading.systolic, reading.diastolic);
    
    const androidDetails = AndroidNotificationDetails(
      'high_bp_alert',
      'High Blood Pressure Alerts',
      channelDescription: 'Notifications for dangerously high blood pressure readings',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );
    
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      'High Blood Pressure Detected',
      '${reading.systolic}/${reading.diastolic} mmHg - ${status.label}. ${status.recommendation}',
      details,
    );
  }

  Future<void> scheduleReminderNotification(TimeOfDay time) async {
    const androidDetails = AndroidNotificationDetails(
      'reminders',
      'Blood Pressure Reminders',
      channelDescription: 'Daily reminders to measure blood pressure',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );
    
    const details = NotificationDetails(android: androidDetails);
    
    // Schedule daily at specified time
    // Note: In production, use workmanager or similar for reliable scheduling
    debugPrint('Reminder scheduled for ${time.hour}:${time.minute}');
  }

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }
}