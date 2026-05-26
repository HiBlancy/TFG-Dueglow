import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Wraps [FlutterLocalNotificationsPlugin] for DueGlow scheduled alerts.
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _pluginReady = false;

  static const String _channelId = 'dueglow_reminders';
  static const String _channelName = 'DueGlow reminders';

  static const WindowsInitializationSettings _windowsSettings =
      WindowsInitializationSettings(
    appName: 'DueGlow',
    appUserModelId: 'DueGlow.App.Notifications',
    guid: '7c4e8f2a-1b3d-4e5f-9a6b-2d8c0e4f1a7b',
  );

  static const LinuxInitializationSettings _linuxSettings =
      LinuxInitializationSettings(defaultActionName: 'Open');

  bool get isReady => _pluginReady;

  Future<void> initialize() async {
    if (kIsWeb) {
      _pluginReady = false;
      return;
    }

    if (_pluginReady && _isPlatformInstanceReady()) return;

    tz_data.initializeTimeZones();
    try {
      final timeZoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (e) {
      if (kDebugMode) {
        debugPrint('NotificationService: timezone fallback UTC ($e)');
      }
      tz.setLocalLocation(tz.UTC);
    }

    try {
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const darwinSettings = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );

      final result = await _plugin.initialize(
        const InitializationSettings(
          android: androidSettings,
          iOS: darwinSettings,
          macOS: darwinSettings,
          linux: _linuxSettings,
          windows: _windowsSettings,
        ),
      );

      _pluginReady = result == true && _isPlatformInstanceReady();

      if (_pluginReady) {
        await _plugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.createNotificationChannel(
              const AndroidNotificationChannel(
                _channelId,
                _channelName,
                description: 'Caducidad, rutinas y recordatorios',
                importance: Importance.high,
              ),
            );
      } else if (kDebugMode) {
        debugPrint('NotificationService: plugin initialize returned $result');
      }
    } catch (e, st) {
      _pluginReady = false;
      if (kDebugMode) {
        debugPrint('NotificationService: initialize failed ($e)\n$st');
      }
    }
  }

  bool _isPlatformInstanceReady() {
    try {
      FlutterLocalNotificationsPlatform.instance;
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> requestPermission() async {
    await initialize();
    if (!_pluginReady) {
      // In-app preference can still be on; scheduling is a no-op until supported.
      return !kIsWeb;
    }

    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      if (await android.areNotificationsEnabled() == true) return true;

      final granted = await android.requestNotificationsPermission();
      if (granted == true) return true;

      return await android.areNotificationsEnabled() ?? false;
    }

    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    if (ios != null) {
      final granted = await ios.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }

    return true;
  }

  Future<void> showInstant({
    required int id,
    required String title,
    required String body,
  }) async {
    await initialize();
    if (!_pluginReady) return;

    try {
      await _plugin.show(id, title, body, _details());
    } catch (e) {
      if (kDebugMode) debugPrint('NotificationService.showInstant: $e');
    }
  }

  Future<void> schedule({
    required int id,
    required String title,
    required String body,
    required DateTime when,
  }) async {
    await initialize();
    if (!_pluginReady) return;
    if (!when.isAfter(DateTime.now())) return;

    try {
      final scheduled = tz.TZDateTime.from(when, tz.local);
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        scheduled,
        _details(),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    } catch (e) {
      if (kDebugMode) debugPrint('NotificationService.schedule: $e');
    }
  }

  Future<void> cancel(int id) async {
    await initialize();
    if (!_pluginReady) return;

    try {
      await _plugin.cancel(id);
    } catch (e) {
      if (kDebugMode) debugPrint('NotificationService.cancel: $e');
    }
  }

  Future<void> cancelAll() async {
    await initialize();
    if (!_pluginReady) return;

    try {
      await _plugin.cancelAll();
    } catch (e) {
      if (kDebugMode) debugPrint('NotificationService.cancelAll: $e');
    }
  }

  NotificationDetails _details() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );
  }
}
