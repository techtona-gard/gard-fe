import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SupabaseService {
  static final SupabaseService instance = SupabaseService._init();
  SupabaseService._init();

  final SupabaseClient _client = Supabase.instance.client;

  bool get isConfigured {
    // Check if initialized with actual credentials or placeholder
    final url = Supabase.instance.client.rest.url;
    return !url.contains('placeholder.supabase.co');
  }

  /// Initiates Google Sign-In with Supabase
  Future<void> signInWithGoogle() async {
    if (!isConfigured) {
      // Simulation/Mock mode
      debugPrint("Supabase not configured. Simulating successful Google OAuth Sign-in.");
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('mock_logged_in', true);
      return;
    }

    try {
      await _client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'gardapp://login-callback',
      );
    } catch (e) {
      debugPrint("Google OAuth Error: $e");
      rethrow;
    }
  }

  /// Logs out the user
  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('mock_logged_in');
    await prefs.remove('mock_profile_completed');
    if (isConfigured) {
      await _client.auth.signOut();
    }
  }

  /// Checks if the currently logged in user has a completed profile in database
  Future<bool> checkProfileExists() async {
    final prefs = await SharedPreferences.getInstance();
    if (!isConfigured) {
      // Mock check
      final completed = prefs.getBool('mock_profile_completed') ?? false;
      return completed;
    }

    try {
      final user = _client.auth.currentUser;
      if (user == null) return false;

      final response = await _client
          .from('profiles')
          .select('height, weight, birth_date')
          .eq('id', user.id)
          .maybeSingle();

      if (response == null) return false;

      // Profile exists if height, weight, and birth_date are filled
      return response['height'] != null &&
          response['weight'] != null &&
          response['birth_date'] != null;
    } catch (e) {
      debugPrint("Error checking profile: $e");
      // Fallback to local cache in case of offline/auth issues
      return prefs.getBool('mock_profile_completed') ?? false;
    }
  }

  /// Saves the additional profile details
  Future<void> saveProfile({
    required double height,
    required double weight,
    required String birthDate,
    String? name,
    String? email,
    String? emergencyContact,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('mock_profile_completed', true);
    if (name != null) await prefs.setString('profile_name', name);
    if (email != null) await prefs.setString('profile_email', email);
    await prefs.setString('profile_height', height.toString());
    await prefs.setString('profile_weight', weight.toString());
    await prefs.setString('profile_birth_date', birthDate);
    if (emergencyContact != null) await prefs.setString('profile_emergency_contact', emergencyContact);

    if (!isConfigured) {
      debugPrint("Saved profile details to Mock database.");
      return;
    }

    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception("No authenticated user found.");

      // Store in profiles table with RLS enabled
      await _client.from('profiles').upsert({
        'id': user.id,
        'full_name': name ?? user.userMetadata?['full_name'] ?? user.userMetadata?['name'] ?? '',
        'email': email ?? user.email ?? '',
        'avatar_url': user.userMetadata?['avatar_url'] ?? user.userMetadata?['picture'] ?? '',
        'height': height,
        'weight': weight,
        'birth_date': birthDate,
        'emergency_contact': emergencyContact ?? '',
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint("Error saving profile to Supabase: $e");
      rethrow;
    }
  }

  /// Fetches profile data from database or SharedPreferences
  Future<Map<String, dynamic>?> getProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    if (!isConfigured) {
      return {
        'name': prefs.getString('profile_name') ?? 'Brawidya Puja Dharma',
        'email': prefs.getString('profile_email') ?? 'brawidya12@gmail.com',
        'height': prefs.getString('profile_height') ?? '175',
        'weight': prefs.getString('profile_weight') ?? '70',
        'birth_date': prefs.getString('profile_birth_date') ?? '12 Agustus 1998',
        'emergency_contact': prefs.getString('profile_emergency_contact') ?? '081272733891',
        'gerd_status': prefs.getString('profile_gerd_status') ?? 'Resiko Rendah',
      };
    }

    try {
      final user = _client.auth.currentUser;
      if (user == null) return null;

      final response = await _client
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (response != null) {
        return {
          'name': response['full_name'] ?? user.userMetadata?['full_name'] ?? user.userMetadata?['name'] ?? '',
          'email': response['email'] ?? user.email ?? '',
          'avatar_url': response['avatar_url'] ?? user.userMetadata?['avatar_url'] ?? user.userMetadata?['picture'] ?? '',
          'height': response['height']?.toString() ?? '',
          'weight': response['weight']?.toString() ?? '',
          'birth_date': response['birth_date'] ?? '',
          'emergency_contact': response['emergency_contact'] ?? '',
          'gerd_status': response['gerd_status'] ?? 'Resiko Rendah',
        };
      }
    } catch (e) {
      debugPrint("Error fetching profile from Supabase: $e");
    }
    return null;
  }

  /// Get current user display info
  Map<String, String> getMockUserInfo() {
    if (isConfigured && _client.auth.currentUser != null) {
      final user = _client.auth.currentUser!;
      return {
        'name': user.userMetadata?['full_name'] ?? user.userMetadata?['name'] ?? 'Brawidya Puja Dharma',
        'email': user.email ?? 'brawidya12@gmail.com',
        'avatar': user.userMetadata?['avatar_url'] ?? user.userMetadata?['picture'] ?? 'https://i.pravatar.cc/300',
      };
    }
    return {
      'name': 'Brawidya Puja Dharma',
      'email': 'brawidya12@gmail.com',
      'avatar': 'https://i.pravatar.cc/300',
    };
  }
}
