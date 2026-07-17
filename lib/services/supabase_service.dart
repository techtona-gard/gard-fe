import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gard/services/google_calendar_service.dart';

class SupabaseService {
  static final SupabaseService instance = SupabaseService._init();
  SupabaseService._init();

  SupabaseClient get _client => Supabase.instance.client;

  bool get isConfigured {
    try {
      final url = Supabase.instance.client.rest.url;
      return !url.contains('placeholder.supabase.co');
    } catch (_) {
      return false;
    }
  }

  /// Initiates Google Sign-In with Supabase OAuth
  /// Returns true if launched successfully (real OAuth opens browser and waits for deep link)
  Future<void> signInWithGoogle() async {
    if (!isConfigured) {
      debugPrint("Supabase not configured. Simulating successful Google OAuth Sign-in.");
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('mock_logged_in', true);
      return;
    }

    try {
      await _client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'gardapp://login-callback',
        authScreenLaunchMode: LaunchMode.externalApplication,
        scopes: 'https://www.googleapis.com/auth/calendar',
        queryParams: {
          'prompt': 'consent',
        },
      );
    } catch (e) {
      debugPrint("Google OAuth Error: $e");
      rethrow;
    }
  }

  /// Get the current session's user, null if not logged in
  User? get currentUser => _client.auth.currentUser;

  /// Checks if the currently logged in user has a completed profile (height, weight, birth_date filled)
  Future<bool> checkProfileExists() async {
    if (!isConfigured) {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool('mock_profile_completed') ?? false;
    }

    try {
      final user = _client.auth.currentUser;
      if (user == null) return false;

      final response = await _client
          .from('users')
          .select('height, weight, birth_date')
          .eq('user_id', user.id)
          .maybeSingle();

      if (response == null) return false;

      return response['height'] != null &&
          response['weight'] != null &&
          response['birth_date'] != null;
    } catch (e) {
      debugPrint("Error checking profile: $e");
      return false;
    }
  }

  /// Saves the user's physical profile details to the database
  Future<void> saveProfile({
    required String name,
    required num height,
    required num weight,
    required String birthDate,
    required String emergencyWa,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('mock_profile_completed', true);
    await prefs.setString('profile_name', name);
    await prefs.setString('profile_height', height.toString());
    await prefs.setString('profile_weight', weight.toString());
    await prefs.setString('profile_birth_date', birthDate);
    await prefs.setString('profile_emergency_wa', emergencyWa);

    if (!isConfigured) {
      debugPrint("Saved profile to mock storage.");
      return;
    }

    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception("No authenticated user found.");

      // Update auth user metadata for 'full_name'
      await _client.auth.updateUser(UserAttributes(data: {'full_name': name}));

      await _client.from('users').upsert({
        'user_id': user.id,
        'height': height,
        'weight': weight,
        'birth_date': birthDate,
        'emergency_wa': emergencyWa,
        'created_at': DateTime.now().toIso8601String(),
      });
      debugPrint("Profile saved to Supabase.");
    } catch (e) {
      debugPrint("Error saving profile to Supabase: $e");
      rethrow;
    }
  }

  /// Saves the GERD status/risk after completing the GerdQ questionnaire
  Future<void> saveGerdStatus(String statusGerd) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_gerd_status', statusGerd);

    if (!isConfigured) {
      debugPrint("Saved gerd status to mock storage: $statusGerd");
      return;
    }

    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception("No authenticated user found.");

      await _client.from('users').upsert({
        'user_id': user.id,
        'status_gerd': statusGerd,
      });
      debugPrint("Gerd status saved to Supabase: $statusGerd");
    } catch (e) {
      debugPrint("Error saving gerd status: $e");
      rethrow;
    }
  }

  /// Logs out the user
  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('mock_logged_in');
    await prefs.remove('mock_profile_completed');
    await prefs.remove('profile_gerd_status');
    await GoogleCalendarService.instance.clearPersistedToken();
    if (isConfigured) {
      try {
        await _client.auth.signOut();
      } catch (e) {
        debugPrint("Sign out error: $e");
      }
    }
  }

  /// Fetches profile data from Supabase or SharedPreferences (for mock mode)
  Future<Map<String, dynamic>?> getProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    if (!isConfigured) {
      return {
        'name': prefs.getString('profile_name') ?? 'Pengguna',
        'email': prefs.getString('profile_email') ?? '',
        'height': prefs.getString('profile_height') ?? '',
        'weight': prefs.getString('profile_weight') ?? '',
        'birth_date': prefs.getString('profile_birth_date') ?? '',
        'emergency_wa': prefs.getString('profile_emergency_wa') ?? '',
        'gerd_status': prefs.getString('profile_gerd_status') ?? 'Belum Dites',
        'avatar_url': '',
      };
    }

    try {
      final user = _client.auth.currentUser;
      if (user == null) return null;

      final response = await _client
          .from('users')
          .select()
          .eq('user_id', user.id)
          .maybeSingle();

      return {
        'name': user.userMetadata?['full_name'] ??
            user.userMetadata?['name'] ??
            'Pengguna',
        'email': user.email ?? '',
        'avatar_url': user.userMetadata?['avatar_url'] ??
            user.userMetadata?['picture'] ??
            '',
        'height': response?['height']?.toString() ?? '-',
        'weight': response?['weight']?.toString() ?? '-',
        'birth_date': response?['birth_date'] ?? '-',
        'emergency_wa': response?['emergency_wa'] ?? '-',
        'gerd_status': response?['status_gerd'] ?? 'Belum Dites',
      };
    } catch (e) {
      debugPrint("Error fetching profile from Supabase: $e");
      final user = _client.auth.currentUser;
      if (user != null) {
        return {
          'name': user.userMetadata?['full_name'] ?? user.userMetadata?['name'] ?? 'Pengguna',
          'email': user.email ?? '',
          'avatar_url': user.userMetadata?['avatar_url'] ?? user.userMetadata?['picture'] ?? '',
          'height': '-',
          'weight': '-',
          'birth_date': '-',
          'emergency_wa': '-',
          'gerd_status': 'Belum Dites',
        };
      }
    }
    return null;
  }

  /// Get current logged-in user info (name, email, avatar)
  Map<String, String> getMockUserInfo() {
    if (isConfigured && _client.auth.currentUser != null) {
      final user = _client.auth.currentUser!;
      return {
        'name': user.userMetadata?['full_name'] ??
            user.userMetadata?['name'] ??
            'Pengguna',
        'email': user.email ?? '',
        'avatar': user.userMetadata?['avatar_url'] ??
            user.userMetadata?['picture'] ??
            '',
      };
    }
    return {
      'name': 'Pengguna',
      'email': '',
      'avatar': '',
    };
  }
}
