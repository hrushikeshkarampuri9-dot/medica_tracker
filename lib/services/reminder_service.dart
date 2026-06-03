import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:workmanager/workmanager.dart';
import 'package:timezone/timezone.dart' as tz;
import '../database/database_helper.dart';
import '../config/app_config.dart';

class ReminderService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  /// Initialize reminder service
  static Future<void> initialize() async {
    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
    DarwinInitializationSettings();

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(initSettings);

    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: AppConfig.debugMode,
    );
  }

  /// Start daily reminder checks
  static Future<void> startDailyReminderChecks() async {
    try {
      await Workmanager().registerPeriodicTask(
        'medication_reminder_check',
        'checkMedicationReminders',
        frequency: const Duration(days: 1),
        initialDelay: const Duration(minutes: 10),
        backoffPolicy: BackoffPolicy.exponential,
        backoffPolicyDelay: const Duration(minutes: 15),
      );

      print('✅ Daily reminder checks started');
    } catch (e) {
      print('❌ Error starting daily reminders: $e');
    }
  }

  /// Stop daily reminder checks
  static Future<void> stopDailyReminderChecks() async {
    try {
      await Workmanager().cancelByTag('medication_reminder_check');
      print('✅ Daily reminder checks stopped');
    } catch (e) {
      print('❌ Error stopping daily reminders: $e');
    }
  }

  /// Check for pending reminders and trigger notifications
  static Future<void> checkAndNotifyReminders() async {
    try {
      final dbHelper = DatabaseHelper();
      final pendingReminders = await dbHelper.getPurchasesPendingReminders();

      print('📋 Found ${pendingReminders.length} pending reminders');

      for (final reminder in pendingReminders) {
        await showReminderNotification(
          title: 'Medication Reminder',
          body: '${reminder.customerName} - ${reminder.medicineName} finishes in 3 days',
          purchaseId: reminder.id!,
        );

        await dbHelper.markReminderAsSent(reminder.id!);
      }
    } catch (e) {
      print('❌ Error checking reminders: $e');
    }
  }

  /// Show local notification
  static Future<void> showReminderNotification({
    required String title,
    required String body,
    required int purchaseId,
  }) async {
    try {
      const AndroidNotificationDetails androidDetails =
      AndroidNotificationDetails(
        AppConfig.notificationChannelId,
        AppConfig.notificationChannelName,
        channelDescription: AppConfig.notificationChannelDescription,
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
      );

      const DarwinNotificationDetails iosDetails =
      DarwinNotificationDetails();

      const NotificationDetails details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notificationsPlugin.show(
        purchaseId,
        title,
        body,
        details,
      );

      print('🔔 Notification shown for purchase $purchaseId');
    } catch (e) {
      print('❌ Error showing notification: $e');
    }
  }

  /// Dismiss notification
  static Future<void> dismissNotification(int id) async {
    try {
      await _notificationsPlugin.cancel(id);
    } catch (e) {
      print('❌ Error dismissing notification: $e');
    }
  }

  /// Dismiss all notifications
  static Future<void> dismissAllNotifications() async {
    try {
      await _notificationsPlugin.cancelAll();
    } catch (e) {
      print('❌ Error dismissing all notifications: $e');
    }
  }

  /// Get active notifications count
  static Future<int> getActiveNotificationsCount() async {
    try {
      final notifications = await _notificationsPlugin.getActiveNotifications();
      return notifications.length;
    } catch (e) {
      print('❌ Error getting active notifications: $e');
      return 0;
    }
  }

  /// Test reminder notification
  static Future<void> testNotification() async {
    try {
      await showReminderNotification(
        title: 'Test Notification',
        body: 'This is a test medication reminder notification',
        purchaseId: 0,
      );
      print('✅ Test notification sent');
    } catch (e) {
      print('❌ Error sending test notification: $e');
    }
  }

  /// Get reminder summary
  static Future<Map<String, int>> getReminderSummary() async {
    try {
      final dbHelper = DatabaseHelper();

      final dueToday = await dbHelper.getPurchasesDueToday();
      final dueThisWeek = await dbHelper.getPurchasesDueThisWeek();
      final pending = await dbHelper.getPurchasesPendingReminders();

      return {
        'dueToday': dueToday.length,
        'dueThisWeek': dueThisWeek.length,
        'pending': pending.length,
      };
    } catch (e) {
      print('❌ Error getting reminder summary: $e');
      return {'dueToday': 0, 'dueThisWeek': 0, 'pending': 0};
    }
  }

  /// Schedule one-time reminder
  static Future<void> scheduleOneTimeReminder({
    required String title,
    required String body,
    required Duration delay,
    required int reminderId,
  }) async {
    try {
      const AndroidNotificationDetails androidDetails =
      AndroidNotificationDetails(
        AppConfig.notificationChannelId,
        AppConfig.notificationChannelName,
        channelDescription: AppConfig.notificationChannelDescription,
      );

      const NotificationDetails details = NotificationDetails(
        android: androidDetails,
      );

      final scheduledDate = tz.TZDateTime.now(tz.local).add(delay);

      await _notificationsPlugin.zonedSchedule(
        reminderId,
        title,
        body,
        scheduledDate,
        details,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
      );

      print('✅ One-time reminder scheduled');
    } catch (e) {
      print('❌ Error scheduling one-time reminder: $e');
    }
  }

  /// Cancel scheduled reminder
  static Future<void> cancelScheduledReminder(int reminderId) async {
    try {
      await _notificationsPlugin.cancel(reminderId);
      print('✅ Scheduled reminder cancelled');
    } catch (e) {
      print('❌ Error cancelling reminder: $e');
    }
  }
}

/// Background callback for WorkManager
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      if (task == 'checkMedicationReminders') {
        print('⏰ Running background medication reminder check...');
        await ReminderService.checkAndNotifyReminders();
        return true;
      }
      return false;
    } catch (e) {
      print('❌ Background task error: $e');
      return false;
    }
  });
}
