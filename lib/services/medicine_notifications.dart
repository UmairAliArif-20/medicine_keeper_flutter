import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

class MedicineNotifications {
  MedicineNotifications._();

  static final MedicineNotifications instance = MedicineNotifications._();

  static const String _channelId = 'medicine_alarm';
  static const String _channelName = 'Medicine Alarms';
  static const String _channelDescription = 'Daily medicine reminders.';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;
  VoidCallback? _onNotificationTap;

  Future<void> initialize({VoidCallback? onNotificationTap}) async {
    debugPrint('[MedicineNotifications] initialize() called');
    _onNotificationTap = onNotificationTap;
    if (_initialized) {
      debugPrint('[MedicineNotifications] Already initialized, skipping');
      return;
    }

    if (kIsWeb) {
      debugPrint(
        '[MedicineNotifications] Running on Web, skipping notifications',
      );
      return;
    }

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
    );

    try {
      debugPrint('[MedicineNotifications] Calling plugin.initialize()');
      await _plugin.initialize(
        settings,
        onDidReceiveNotificationResponse: (_) {
          _onNotificationTap?.call();
        },
      );
      debugPrint('[MedicineNotifications] plugin.initialize() completed');

      debugPrint('[MedicineNotifications] Requesting permissions');
      await _requestPermissions();
      debugPrint('[MedicineNotifications] Permissions requested');

      debugPrint('[MedicineNotifications] Configuring timezone');
      await _configureTimezone();
      debugPrint('[MedicineNotifications] Timezone configured');

      _initialized = true;
      debugPrint('[MedicineNotifications] Initialization complete');
    } catch (error) {
      debugPrint('[MedicineNotifications] ERROR during init: $error');
    }
  }

  Future<void> syncDailySchedules(List<Map<String, dynamic>> medicines) async {
    await _ensureInitialized();
    await _plugin.cancelAll();
    for (Map<String, dynamic> medicine in medicines) {
      await scheduleOrUpdateForMedicine(medicine);
    }
  }

  Future<void> scheduleOrUpdateForMedicine(
    Map<String, dynamic> medicine,
  ) async {
    debugPrint('[MedicineNotifications] scheduleOrUpdateForMedicine() called');
    await _ensureInitialized();
    int? id = medicine['id'] as int?;
    int? timeMinutes = medicine['timeMinutes'] as int?;
    debugPrint(
      '[MedicineNotifications] Medicine: id=$id, timeMinutes=$timeMinutes, name=${medicine['name']}',
    );

    if (id == null || timeMinutes == null) {
      debugPrint(
        '[MedicineNotifications] ERROR: id or timeMinutes is null, returning',
      );
      return;
    }

    // Cancel existing notification for this medicine
    await _plugin.cancel(id);

    DateTime scheduledTime = _nextInstanceOfTime(timeMinutes);
    debugPrint(
      '[MedicineNotifications] Scheduled time calculated: $scheduledTime',
    );

    try {
      debugPrint(
        '[MedicineNotifications] Current system time: ${DateTime.now()}',
      );
      debugPrint('[MedicineNotifications] Scheduling for: $scheduledTime');
      debugPrint(
        '[MedicineNotifications] Is in future? ${scheduledTime.isAfter(DateTime.now())}',
      );

      await _plugin.zonedSchedule(
        id,
        _titleFor(medicine),
        _bodyFor(medicine),
        tz.TZDateTime.from(scheduledTime, tz.local),
        _notificationDetails(),
        androidScheduleMode:
            AndroidScheduleMode.exactAllowWhileIdle, // Corrected parameter
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: 'medicine:$id',
      );
      debugPrint(
        '[MedicineNotifications] zonedSchedule() completed successfully for id=$id',
      );
    } catch (error) {
      debugPrint('[MedicineNotifications] ERROR in zonedSchedule: $error');
      rethrow;
    }
  }

  Future<void> cancelById(int id) async {
    await _ensureInitialized();
    await _plugin.cancel(id);
  }

  NotificationDetails _notificationDetails() {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
        );

    return const NotificationDetails(android: androidDetails);
  }

  String _titleFor(Map<String, dynamic> medicine) {
    String name = (medicine['name'] as String?)?.trim() ?? 'medicine';
    if (name.isEmpty) {
      name = 'medicine';
    }

    return 'Time to take $name';
  }

  String _bodyFor(Map<String, dynamic> medicine) {
    return 'Tap to open your medicines.';
  }

  DateTime _nextInstanceOfTime(int timeMinutes) {
    DateTime now = DateTime.now();
    int hour = timeMinutes ~/ 60;
    int minute = timeMinutes % 60;
    debugPrint(
      '[MedicineNotifications] _nextInstanceOfTime: now=$now, hour=$hour, minute=$minute',
    );

    // Create datetime for today at the target time
    DateTime todaySchedule = DateTime(
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    debugPrint('[MedicineNotifications] Today schedule: $todaySchedule');
    debugPrint(
      '[MedicineNotifications] Is todaySchedule after now? ${todaySchedule.isAfter(now)}',
    );

    // If the time hasn't passed today, use today
    if (todaySchedule.isAfter(now)) {
      debugPrint(
        '[MedicineNotifications] Time is still ahead today, using today: $todaySchedule',
      );
      return todaySchedule;
    }

    // Otherwise schedule for tomorrow at the same time
    DateTime tomorrowSchedule = todaySchedule.add(const Duration(days: 1));
    debugPrint(
      '[MedicineNotifications] Time already passed today, moved to tomorrow: $tomorrowSchedule',
    );
    return tomorrowSchedule;
  }

  Future<void> _ensureInitialized() async {
    if (_initialized) {
      return;
    }

    await initialize();
  }

  Future<void> _configureTimezone() async {
    debugPrint('[MedicineNotifications] _configureTimezone() called');
    tz_data.initializeTimeZones();
    String timezone = await FlutterTimezone.getLocalTimezone();
    debugPrint('[MedicineNotifications] Local timezone: $timezone');
    tz.setLocalLocation(tz.getLocation(timezone));
    debugPrint('[MedicineNotifications] Timezone set to: ${tz.local.name}');
  }

  Future<void> _requestPermissions() async {
    debugPrint('[MedicineNotifications] _requestPermissions() called');
    AndroidFlutterLocalNotificationsPlugin? android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android == null) {
      debugPrint(
        '[MedicineNotifications] ERROR: Could not get AndroidFlutterLocalNotificationsPlugin',
      );
      return;
    }

    debugPrint('[MedicineNotifications] Requesting notification permissions');
    await android.requestNotificationsPermission();

    debugPrint('[MedicineNotifications] Requesting exact alarm permissions');
    try {
      await android.requestExactAlarmsPermission();
    } catch (error) {
      debugPrint(
        '[MedicineNotifications] Could not request exact alarms (may not be available): $error',
      );
    }

    debugPrint('[MedicineNotifications] Notification permissions requested');
  }
}
