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

  /// Memeriksa dan membuat jadwal makan rekomendasi AI untuk besok secara otomatis
  /// jika waktu saat ini sudah jam 23.59 (atau di atas 23.50) dan belum pernah dibuat sebelumnya.
  Future<void> checkAndGenerateTomorrowSchedule() async {
    final now = DateTime.now();
    
    // Cek apakah sekarang sudah pukul 23:50 ke atas
    if (now.hour == 23 && now.minute >= 50) {
      final tomorrow = now.add(const Duration(days: 1));
      final tomorrowStr =
          '${tomorrow.year}-${tomorrow.month.toString().padLeft(2, '0')}-${tomorrow.day.toString().padLeft(2, '0')}';

      final prefs = await SharedPreferences.getInstance();
      final alreadyGenerated = prefs.getString('ai_schedule_$tomorrowStr') != null;

      if (alreadyGenerated) {
        debugPrint("AutoScheduleService: Jadwal makan besok ($tomorrowStr) sudah ada.");
        return;
      }

      debugPrint("AutoScheduleService: Memulai auto-generate jadwal makan untuk besok ($tomorrowStr).");
      try {
        final profile = await SupabaseService.instance.getProfileData();
        final email = profile?['email'] ?? 'anonymous';

        final result = await AgentService.instance.generateSchedule(
          userId: email,
          date: tomorrow,
          profileData: profile,
        );

        if (result.success && result.events.isNotEmpty) {
          // 1. Simpan secara lokal (versi full baru dengan ai_message)
          final Map<String, dynamic> fullData = {
            'events': result.events,
            'ai_message': result.scheduleText,
          };
          await prefs.setString('ai_schedule_full_$tomorrowStr', jsonEncode(fullData));
          
          // Tetap simpan legacy key agar kompatibel
          await prefs.setString('ai_schedule_$tomorrowStr', jsonEncode(result.events));
          debugPrint("AutoScheduleService: Jadwal makan berhasil disimpan di preferences.");

          // 2. Tambahkan ke Google Calendar jika terhubung
          final googleCalendarService = GoogleCalendarService.instance;
          final hasAccess = await googleCalendarService.getStoredToken() != null;
          if (hasAccess) {
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
              } catch (calErr) {
                debugPrint('AutoScheduleService (Google Calendar) Error: $calErr');
              }
            }
            debugPrint("AutoScheduleService: Jadwal makan dimasukkan ke Google Calendar.");
          }

          // 3. Daftarkan notifikasi alarm
          for (final event in result.events) {
            try {
              final start = DateTime.parse(event['start_time']).toLocal();
              await NotificationService.scheduleEatingReminderAt(
                title: 'GARD: ${event['summary']} 🥣',
                body: event['description'] ?? 'Waktunya makan rekomendasi AI.',
                scheduledTime: start,
              );
            } catch (notifErr) {
              debugPrint('AutoScheduleService (Notification) Error: $notifErr');
            }
          }
        }
      } catch (e) {
        debugPrint("AutoScheduleService error: $e");
      }
    }
  }
}
