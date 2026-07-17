import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Service untuk berkomunikasi dengan AI Agent API
/// Base: https://gard-agent.up.railway.app (via backend proxy)
class AgentService {
  static final AgentService instance = AgentService._init();
  AgentService._init();

  // Ganti dengan base URL backend production Anda
  static const String _baseUrl = 'https://gard-agent.up.railway.app/api/v1';

  static const Duration _timeout = Duration(seconds: 60);

  // ── Thread ID persistence ────────────────────────────────────────────────
  static const String _threadKey = 'agent_thread_id';

  Future<String> getThreadId() async {
    final prefs = await SharedPreferences.getInstance();
    String? threadId = prefs.getString(_threadKey);
    if (threadId == null || threadId.isEmpty) {
      threadId = 'thread_${DateTime.now().millisecondsSinceEpoch}';
      await prefs.setString(_threadKey, threadId);
    }
    return threadId;
  }

  Future<void> saveThreadId(String threadId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_threadKey, threadId);
  }

  Future<void> clearThreadId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_threadKey);
  }

  // ── Helper: build sensor_data from health summary ────────────────────────
  Map<String, dynamic> buildSensorData({
    Map<String, dynamic>? healthSummary,
    List<Map<String, String>>? eventSchedule,
  }) {
    final sleepMinutes = (healthSummary?['sleepMinutes'] as num?)?.toDouble() ?? 0;
    final sleepHours = sleepMinutes / 60.0;
    // Rough split: 25% deep, 75% light (tidak ada data detail dari Health Connect)
    final deepSleep = double.parse((sleepHours * 0.25).toStringAsFixed(1));
    final lightSleep = double.parse((sleepHours * 0.75).toStringAsFixed(1));

    return {
      'step_count': (healthSummary?['steps'] as num?)?.toInt() ?? 0,
      'heart_rate_bpm': (healthSummary?['heartRate'] as num?)?.toInt() ?? 0,
      'hrv_status': 'Normal', // placeholder
      'sleep': {
        'total_hours': double.parse(sleepHours.toStringAsFixed(1)),
        'deep_sleep_hours': deepSleep,
        'light_sleep_hours': lightSleep,
      },
      'event_schedule': eventSchedule ?? [],
    };
  }

  // ── Helper: build baseline_gerd_q from profile data ─────────────────────
  Map<String, dynamic> buildGerdQBaseline(Map<String, dynamic>? profileData) {
    final status = profileData?['gerd_status'];
    int score = 0;
    String statusStr = 'rendah';
    
    if (status != null && status != 'Belum Dites') {
      statusStr = status.toString().toLowerCase();
      switch (statusStr) {
        case 'rendah':
          score = 4;
          break;
        case 'tinggi':
          score = 10;
          break;
      }
    }
    return {'score': score, 'status': statusStr};
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 1. POST /api/v1/chat  — Chatbot conversation
  // ─────────────────────────────────────────────────────────────────────────
  Future<AgentChatResult> sendChat({
    required String userId,
    required String chatInput,
    Map<String, dynamic>? healthSummary,
    Map<String, dynamic>? profileData,
    List<Map<String, String>>? eventSchedule,
  }) async {
    final threadId = await getThreadId();
    final validUserId = (userId.isEmpty || userId == 'anonymous') 
        ? '00000000-0000-0000-0000-000000000000' 
        : userId;

    final body = <String, dynamic>{
      'user_id': validUserId,
      'chat_input': chatInput,
      'thread_id': threadId,
      'baseline_gerd_q': buildGerdQBaseline(profileData),
      'sensor_data': buildSensorData(
          healthSummary: healthSummary, eventSchedule: eventSchedule),
    };

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/chat'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      ).timeout(_timeout);

      debugPrint('Agent /chat response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final newThreadId = data['thread_id']?.toString() ??
            data['data']?['thread_id']?.toString();
        if (newThreadId != null) await saveThreadId(newThreadId);

        final reply = data['ai_message']?.toString() ??
            data['output']?.toString() ??
            data['data']?['output']?.toString() ??
            data['message']?.toString() ??
            'Tidak ada respons dari AI.';

        return AgentChatResult(success: true, message: reply);
      } else {
        debugPrint('Agent /chat error body: ${response.body}');
        return AgentChatResult(
          success: false,
          message: 'Server error (${response.statusCode}). Coba lagi nanti.',
        );
      }
    } catch (e) {
      debugPrint('Agent /chat exception: $e');
      return AgentChatResult(
        success: false,
        message: 'Tidak dapat terhubung ke AI. Periksa koneksi internet Anda.',
      );
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 2. POST /api/v1/scan-food  — Scan makanan via base64
  // ─────────────────────────────────────────────────────────────────────────
  Future<AgentScanResult> scanFood({
    required String userId,
    required String imageBase64,
    String chatInput = 'Apakah makanan ini aman untuk penderita GERD?',
  }) async {
    final threadId = await getThreadId();
    final validUserId = (userId.isEmpty || userId == 'anonymous') 
        ? '00000000-0000-0000-0000-000000000000' 
        : userId;

    final body = <String, dynamic>{
      'user_id': validUserId,
      'image_base64': imageBase64,
      'chat_input': chatInput,
      'thread_id': threadId,
    };

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/scan-food'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      ).timeout(_timeout);

      debugPrint('Agent /scan-food response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final newThreadId = data['thread_id']?.toString() ??
            data['data']?['thread_id']?.toString();
        if (newThreadId != null) await saveThreadId(newThreadId);

        final reply = data['ai_message']?.toString() ??
            data['output']?.toString() ??
            data['data']?['output']?.toString() ??
            data['message']?.toString() ??
            'Analisis selesai.';

        return AgentScanResult(success: true, analysisText: reply);
      } else {
        debugPrint('Agent /scan-food error body: ${response.body}');
        return AgentScanResult(
          success: false,
          analysisText:
              'Gagal menganalisis gambar (${response.statusCode}). Coba lagi.',
        );
      }
    } catch (e) {
      debugPrint('Agent /scan-food exception: $e');
      return AgentScanResult(
        success: false,
        analysisText:
            'Tidak dapat terhubung ke server analisis. Periksa koneksi Anda.',
      );
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 3. POST /api/v1/schedule  — AI Meal & Daily Schedule Reminders
  // ─────────────────────────────────────────────────────────────────────────
  Future<AgentScheduleResult> generateSchedule({
    required String userId,
    required DateTime date,
    Map<String, dynamic>? healthSummary,
    Map<String, dynamic>? profileData,
    List<Map<String, String>>? existingEvents,
  }) async {
    final threadId = await getThreadId();
    final dateStr =
        '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final validUserId = (userId.isEmpty || userId == 'anonymous') 
        ? '00000000-0000-0000-0000-000000000000' 
        : userId;

    final body = <String, dynamic>{
      'user_id': validUserId,
      'date': dateStr,
      'thread_id': threadId,
      'baseline_gerd_q': buildGerdQBaseline(profileData),
      'sensor_data': buildSensorData(
          healthSummary: healthSummary, eventSchedule: existingEvents),
    };

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/schedule'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      ).timeout(_timeout);

      debugPrint('Agent /schedule response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final newThreadId = data['thread_id']?.toString() ??
            data['data']?['thread_id']?.toString();
        if (newThreadId != null) await saveThreadId(newThreadId);

        final scheduleText = data['ai_message']?.toString() ??
            data['output']?.toString() ??
            data['data']?['output']?.toString() ??
            data['message']?.toString() ??
            'Jadwal berhasil dibuat.';

        final List<dynamic> eventsList = data['events'] ?? [];
        final List<Map<String, dynamic>> events = eventsList
            .map((e) => Map<String, dynamic>.from(e))
            .toList();

        return AgentScheduleResult(
          success: true,
          scheduleText: scheduleText,
          events: events,
        );
      } else {
        debugPrint('Agent /schedule error body: ${response.body}');
        return AgentScheduleResult(
          success: false,
          scheduleText:
              'Gagal membuat jadwal (${response.statusCode}). Coba lagi nanti.',
        );
      }
    } catch (e) {
      debugPrint('Agent /schedule exception: $e');
      return AgentScheduleResult(
        success: false,
        scheduleText:
            'Tidak dapat terhubung ke server jadwal. Periksa koneksi Anda.',
      );
    }
  }
}

// ── Result Models ─────────────────────────────────────────────────────────

class AgentChatResult {
  final bool success;
  final String message;
  const AgentChatResult({required this.success, required this.message});
}

class AgentScanResult {
  final bool success;
  final String analysisText;
  const AgentScanResult({required this.success, required this.analysisText});
}

class AgentScheduleResult {
  final bool success;
  final String scheduleText;
  final List<Map<String, dynamic>> events;
  const AgentScheduleResult({
    required this.success,
    required this.scheduleText,
    this.events = const [],
  });
}
