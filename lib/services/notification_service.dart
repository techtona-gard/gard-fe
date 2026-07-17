import 'dart:typed_data';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:gard/main.dart';
import 'package:gard/pages/camera_page.dart';
import 'package:gard/pages/chatbot_page.dart';

class NotificationService {
  static Future<void> initializeNotification() async {
    await AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelGroupKey: 'reminders_group',
          channelKey: 'eating_reminder',
          channelName: 'Eating Reminders',
          channelDescription: 'Notification channel for eating reminders',
          defaultColor: const Color(0xFF364E4F),
          ledColor: Colors.white,
          importance: NotificationImportance.Max,
          channelShowBadge: true,
          onlyAlertOnce: false,
          criticalAlerts: true,
          playSound: true,
          defaultRingtoneType: DefaultRingtoneType.Alarm,
          enableVibration: true,
          vibrationPattern: Int64List.fromList([0, 1000, 500, 1000, 500, 1000, 500, 1000]),
          enableLights: true,
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
    debugPrint('Notification Created: ${receivedNotification.id}');
  }

  static Future<void> onNotificationDisplayedMethod(ReceivedNotification receivedNotification) async {
    debugPrint('Notification Displayed: ${receivedNotification.id}');
  }

  static Future<void> onDismissActionReceivedMethod(ReceivedAction receivedAction) async {
    debugPrint('Notification Dismissed: ${receivedAction.id}');
  }

  @pragma("vm:entry-point")
  static Future<void> onActionReceivedMethod(ReceivedAction receivedAction) async {
    final BuildContext? context = MyApp.navigatorKey.currentContext;

    if (receivedAction.buttonKeyPressed == 'FOTO_MAKANAN') {
      if (context != null && cameras.isNotEmpty) {
        Navigator.push(context, MaterialPageRoute(builder: (context) => CameraPage(camera: cameras.first)));
      }
    } else if (receivedAction.buttonKeyPressed == 'CHAT') {
      if (context != null) {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const ChatbotPage()));
      }
    } else if (receivedAction.buttonKeyPressed == 'SNOOZE_OPTIONS') {
      if (context != null) {
        _showSnoozeDialog(context);
      }
    }
  }

  static void _showSnoozeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pilih Waktu Tunda (Snooze)'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _snoozeOption(context, 10),
            _snoozeOption(context, 20),
            _snoozeOption(context, 30),
          ],
        ),
      ),
    );
  }

  static Widget _snoozeOption(BuildContext context, int mins) {
    return ListTile(
      leading: const Icon(Icons.timer_outlined, color: Colors.green),
      title: Text('$mins Menit'),
      onTap: () {
        Navigator.pop(context);
        scheduleEatingReminder(
          title: 'Eating Reminder (Snoozed)',
          body: 'Waktunya makan untuk kesehatan lambungmu!',
          secondsDelay: mins * 60,
        );
      },
    );
  }

  static Future<void> scheduleEatingReminder({
    required String title,
    required String body,
    int secondsDelay = 6,
  }) async {
    try {
      bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
      if (!isAllowed) return;

      int finalInterval = secondsDelay < 6 ? 6 : secondsDelay;

      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
          channelKey: 'eating_reminder',
          title: title,
          body: body,
          category: NotificationCategory.Alarm,
          notificationLayout: NotificationLayout.BigText,
          fullScreenIntent: true, 
          wakeUpScreen: true,
          autoDismissible: false,
          locked: true,
          backgroundColor: const Color(0xFF364E4F),
          largeIcon: 'asset://assets/images/logo_icon.png',
        ),
        actionButtons: [
          NotificationActionButton(
            key: 'FOTO_MAKANAN',
            label: 'Foto Makanan',
            color: Colors.green,
            actionType: ActionType.Default,
          ),
          NotificationActionButton(
            key: 'CHAT',
            label: 'Chat (Sudah Makan)',
            actionType: ActionType.Default,
          ),
          NotificationActionButton(
            key: 'SNOOZE_OPTIONS',
            label: 'Snooze...',
            actionType: ActionType.Default,
          ),
        ],
        schedule: NotificationInterval(
          interval: Duration(seconds: finalInterval),
          timeZone: await AwesomeNotifications().getLocalTimeZoneIdentifier(),
          preciseAlarm: true,
          repeats: false,
        ),
      );
      debugPrint('Notification Scheduled for $finalInterval seconds');
    } catch (e) {
      debugPrint('Error scheduling notification: $e');
    }
  }
}
