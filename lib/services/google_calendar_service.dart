import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

/// Model for a Google Calendar event
class CalendarEvent {
  final String id;
  final String title;
  final String? description;
  final DateTime startTime;
  final DateTime endTime;

  CalendarEvent({
    required this.id,
    required this.title,
    this.description,
    required this.startTime,
    required this.endTime,
  });

  factory CalendarEvent.fromJson(Map<String, dynamic> json) {
    DateTime parseDateTime(Map<String, dynamic> timeMap) {
      if (timeMap.containsKey('dateTime')) {
        return DateTime.parse(timeMap['dateTime']).toLocal();
      }
      // All-day event — treat as start of day in local timezone
      return DateTime.parse(timeMap['date']).toLocal();
    }

    return CalendarEvent(
      id: json['id'] ?? '',
      title: json['summary'] ?? '(Tanpa Judul)',
      description: json['description'],
      startTime: parseDateTime(
          json['start'] ?? {'dateTime': DateTime.now().toIso8601String()}),
      endTime: parseDateTime(
          json['end'] ?? {'dateTime': DateTime.now().toIso8601String()}),
    );
  }
}

/// Service to interact with Google Calendar API v3.
///
/// Uses the Google OAuth providerToken from the active Supabase session.
/// Since Supabase only keeps providerToken in memory (not persisted between
/// app restarts), we also persist it in SharedPreferences so it survives
/// Hot Restarts and full app relaunches.
class GoogleCalendarService {
  static final GoogleCalendarService instance = GoogleCalendarService._init();
  GoogleCalendarService._init();

  static const String _calendarId = 'primary';
  static const String _baseUrl = 'https://www.googleapis.com/calendar/v3';
  static const String _prefKey = 'google_provider_token';

  SupabaseClient get _client => Supabase.instance.client;

  /// Persist Google OAuth token from auth listener
  Future<void> persistProviderToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, token);
  }

  /// Clear persisted token on logout
  Future<void> clearPersistedToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefKey);
  }

  /// Returns true if we have any valid Google token
  bool get isSignedIn {
    final session = _client.auth.currentSession;
    return session != null &&
        (session.providerToken?.isNotEmpty ?? false);
  }

  /// Returns live session token, falls back to persisted SharedPreferences token
  Future<String?> getStoredToken() async {
    final liveToken = _client.auth.currentSession?.providerToken;
    if (liveToken != null && liveToken.isNotEmpty) {
      await persistProviderToken(liveToken);
      return liveToken;
    }
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_prefKey);
    if (stored != null && stored.isNotEmpty) return stored;
    return null;
  }

  Future<Map<String, String>?> _getAuthHeaders() async {
    final token = await getStoredToken();
    if (token == null) return null;
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  /// Fetch events for a given month
  Future<List<CalendarEvent>> getEventsForMonth(DateTime month) async {
    final headers = await _getAuthHeaders();
    if (headers == null) {
      throw Exception('auth_error');
    }

    final timeMin =
        DateTime(month.year, month.month, 1).toUtc().toIso8601String();
    final timeMax = DateTime(month.year, month.month + 1, 0, 23, 59, 59)
        .toUtc()
        .toIso8601String();

    final uri = Uri.parse(
      '$_baseUrl/calendars/$_calendarId/events'
      '?timeMin=${Uri.encodeComponent(timeMin)}'
      '&timeMax=${Uri.encodeComponent(timeMax)}'
      '&singleEvents=true'
      '&orderBy=startTime'
      '&maxResults=100',
    );

    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final items = (data['items'] as List?) ?? [];
      return items.map((e) => CalendarEvent.fromJson(e)).toList();
    } else if (response.statusCode == 401) {
      await clearPersistedToken();
      throw Exception('auth_error');
    } else {
      throw Exception('API Error ${response.statusCode}: ${response.body}');
    }
  }

  /// Fetch events for a specific day
  Future<List<CalendarEvent>> getEventsForDay(DateTime day) async {
    final headers = await _getAuthHeaders();
    if (headers == null) {
      throw Exception('auth_error');
    }

    final timeMin =
        DateTime(day.year, day.month, day.day).toUtc().toIso8601String();
    final timeMax =
        DateTime(day.year, day.month, day.day, 23, 59, 59).toUtc().toIso8601String();

    final uri = Uri.parse(
      '$_baseUrl/calendars/$_calendarId/events'
      '?timeMin=${Uri.encodeComponent(timeMin)}'
      '&timeMax=${Uri.encodeComponent(timeMax)}'
      '&singleEvents=true'
      '&orderBy=startTime',
    );

    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final items = (data['items'] as List?) ?? [];
      return items.map((e) => CalendarEvent.fromJson(e)).toList();
    } else if (response.statusCode == 401) {
      await clearPersistedToken();
      throw Exception('auth_error');
    } else {
      throw Exception('API Error ${response.statusCode}: ${response.body}');
    }
  }

  /// Create a new event in Google Calendar
  Future<CalendarEvent?> createEvent({
    required String title,
    String? description,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    final headers = await _getAuthHeaders();
    if (headers == null) return null;

    final uri = Uri.parse('$_baseUrl/calendars/$_calendarId/events');
    final body = jsonEncode({
      'summary': title,
      'description': description ?? '',
      'start': {
        'dateTime': startTime.toUtc().toIso8601String(),
      },
      'end': {
        'dateTime': endTime.toUtc().toIso8601String(),
      },
    });

    final response = await http.post(uri, headers: headers, body: body);
    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return CalendarEvent.fromJson(data);
    } else {
      throw Exception('Gagal membuat event: API Error ${response.statusCode}: ${response.body}');
    }
  }

  /// Update an existing event in Google Calendar
  Future<CalendarEvent?> updateEvent({
    required String eventId,
    required String title,
    String? description,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    final headers = await _getAuthHeaders();
    if (headers == null) return null;

    final uri =
        Uri.parse('$_baseUrl/calendars/$_calendarId/events/$eventId');
    final body = jsonEncode({
      'summary': title,
      'description': description ?? '',
      'start': {
        'dateTime': startTime.toUtc().toIso8601String(),
      },
      'end': {
        'dateTime': endTime.toUtc().toIso8601String(),
      },
    });

    final response = await http.put(uri, headers: headers, body: body);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return CalendarEvent.fromJson(data);
    } else {
      debugPrint('Update event error ${response.statusCode}: ${response.body}');
      return null;
    }
  }

  /// Delete an event from Google Calendar
  Future<bool> deleteEvent(String eventId) async {
    final headers = await _getAuthHeaders();
    if (headers == null) return false;

    final uri =
        Uri.parse('$_baseUrl/calendars/$_calendarId/events/$eventId');

    final response = await http.delete(uri, headers: headers);
    return response.statusCode == 204;
  }
}
