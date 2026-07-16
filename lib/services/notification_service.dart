import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:gard_fe/main.dart';
import 'package:gard_fe/pages/camera_page.dart';

class NotificationService {
  static Future<void> initializeNotification() async {
    await AwesomeNotifications().initialize(
      null, // null for default icon
      [
        NotificationChannel(
          channelGroupKey: 'reminders_group',
          channelKey: 'eating_reminder',
          channelName: 'Eating Reminders',
          channelDescription: 'Notification channel for eating reminders',
          defaultColor: const Color(0xFF4CAF50),
          ledColor: Colors.white,
          importance: NotificationImportance.Max,
          channelShowBadge: true,
          onlyAlertOnce: true,
          criticalAlerts: true,
          playSound: true,
        )
      ],
      channelGroups: [
        NotificationChannelGroup(
          channelGroupKey: 'reminders_group',
          channelGroupName: 'Reminders Group',
        )
      ],
      debug: true,
    );

    // Request permission explicitly
    await AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });

    AwesomeNotifications().setListeners(
      onActionReceivedMethod: onActionReceivedMethod,
      onNotificationCreatedMethod: onNotificationCreatedMethod,
      onNotificationDisplayedMethod: onNotificationDisplayedMethod,
      onDismissActionReceivedMethod: onDismissActionReceivedMethod,
    );
  }

  static Future<void> onNotificationCreatedMethod(ReceivedNotification receivedNotification) async {
    debugPrint('Notification created');
  }

  static Future<void> onNotificationDisplayedMethod(ReceivedNotification receivedNotification) async {
    debugPrint('Notification displayed');
  }

  static Future<void> onDismissActionReceivedMethod(ReceivedAction receivedAction) async {
    debugPrint('Notification dismissed');
  }

  static Future<void> onActionReceivedMethod(ReceivedAction receivedAction) async {
    final BuildContext? context = MyApp.navigatorKey.currentContext;

    if (receivedAction.buttonKeyPressed == 'FOTO_MAKANAN') {
      if (context != null && cameras.isNotEmpty) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CameraPage(camera: cameras.first),
          ),
        );
      }
    } else if (receivedAction.buttonKeyPressed == 'SNOOZE') {
      scheduleEatingReminder(
        title: 'Snoozed Reminder',
        body: 'Waktunya makan untuk kesehatan lambungmu!',
        secondsDelay: 15 * 60,
      );
    }
  }

  static Future<void> scheduleEatingReminder({
    required String title,
    required String body,
    int secondsDelay = 5,
  }) async {
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) {
      isAllowed = await AwesomeNotifications().requestPermissionToSendNotifications();
    }

    if (isAllowed) {
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
          channelKey: 'eating_reminder',
          title: title,
          body: body,
          category: NotificationCategory.Alarm,
          notificationLayout: NotificationLayout.Default,
          fullScreenIntent: true,
          wakeUpScreen: true,
          // criticalAlert is not a direct parameter in 0.12.1 for NotificationContent
        ),
        actionButtons: [
          NotificationActionButton(
            key: 'FOTO_MAKANAN',
            label: 'Foto Makanan',
            color: Colors.green,
            actionType: ActionType.Default,
          ),
          NotificationActionButton(
            key: 'SNOOZE',
            label: 'Snooze (15m)',
            actionType: ActionType.Default,
          ),
        ],
        schedule: NotificationInterval(
          interval: Duration(seconds: secondsDelay),
          timeZone: await AwesomeNotifications().getLocalTimeZoneIdentifier(),
          preciseAlarm: true,
          repeats: false,
        ),
      );
    }
  }
}
