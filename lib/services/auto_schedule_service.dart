import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gard/services/agent_service.dart';
import 'package:gard/services/supabase_service.dart';
import 'package:gard/services/google_calendar_service.dart';
import 'package:gard/services/notification_service.dart';

class AutoScheduleService {
  static final AutoScheduleService instance = AutoScheduleService._init();
  AutoScheduleService._init();

  /// Auto-generates tomorrow's AI meal schedule at 23:50–23:59 if not yet generated.
  /// Saves to SharedPreferences, Google Calendar, and schedules notifications.
  Future<void> checkAndGenerateTomorrowSchedule() async {
    final now = DateTime.now();
    if (now.hour != 23 || now.minute < 50) return;

    final tomorrow = now.add(const Duration(days: 1));
    final tomorrowStr =
        '${tomorrow.year}-${tomorrow.month.toString().padLeft(2, '0')}-${tomorrow.day.toString().padLeft(2, '0')}';

    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString('ai_schedule_$tomorrowStr') != null) return;

    try {
      final profile = await SupabaseService.instance.getProfileData();
      final email = profile?['email'] ?? 'anonymous';

      final result = await AgentService.instance.generateSchedule(
        userId: email,
        date: tomorrow,
        profileData: profile,
      );

      if (result.success && result.events.isNotEmpty) {
        // Save full payload (events + AI message)
        final fullData = {
          'events': result.events,
          'ai_message': result.scheduleText,
        };
        await prefs.setString('ai_schedule_full_$tomorrowStr', jsonEncode(fullData));
        await prefs.setString('ai_schedule_$tomorrowStr', jsonEncode(result.events));

        // Add events to Google Calendar if connected
        final googleCalendarService = GoogleCalendarService.instance;
        if (await googleCalendarService.getStoredToken() != null) {
          for (final event in result.events) {
            try {
              final start = DateTime.parse(event['start_time']).toLocal();
              final end = DateTime.parse(event['end_time']).toLocal();
              await googleCalendarService.createEvent(
                title: event['summary'] ?? 'Jadwal Makan AI',
                description: event['description'],
                startTime: start,
                endTime: end,
              );
            } catch (_) {}
          }
        }

        // Schedule meal reminder notifications
        for (final event in result.events) {
          try {
            final start = DateTime.parse(event['start_time']).toLocal();
            await NotificationService.scheduleEatingReminderAt(
              title: 'GARD: ${event['summary']} 🥣',
              body: event['description'] ?? 'Waktunya makan rekomendasi AI.',
              scheduledTime: start,
            );
          } catch (_) {}
        }
      }
    } catch (e) {
      debugPrint('AutoScheduleService error: $e');
    }
  }
}
