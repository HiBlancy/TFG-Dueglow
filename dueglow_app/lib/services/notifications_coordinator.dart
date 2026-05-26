import 'package:flutter/foundation.dart';
import 'notification_scheduler.dart';

/// Entry point to refresh scheduled notifications after data changes.
class NotificationsCoordinator {
  NotificationsCoordinator._();

  static Future<void> refresh() async {
    try {
      await NotificationScheduler.instance.syncAll();
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('NotificationsCoordinator.refresh: $e\n$st');
      }
    }
  }
}
