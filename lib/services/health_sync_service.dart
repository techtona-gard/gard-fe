import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:gard/models/lifestyle_model.dart';
import 'package:flutter/foundation.dart';

class HealthSyncService {
  static final HealthSyncService _instance = HealthSyncService._internal();
  static HealthSyncService get instance => _instance;

  HealthSyncService._internal();

  final SupabaseClient _client = Supabase.instance.client;

  /// Fetch lifestyle records for the current user
  Future<List<LifestyleModel>> fetchLifestyles() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      final response = await _client
          .from('lifestyles')
          .select()
          .eq('user_id', user.id)
          .order('recorded_at', ascending: true);

      final List<dynamic> data = response;
      return data.map((json) => LifestyleModel.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error fetching lifestyles: $e');
      return [];
    }
  }

  /// Insert a new lifestyle record
  Future<bool> syncLifestyleData({
    int? steps,
    int? heartRate,
    double? sleepHours,
  }) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      // Hindari insert jika semua data null
      if (steps == null && heartRate == null && sleepHours == null) {
        return false;
      }

      await _client.from('lifestyles').insert({
        'user_id': user.id,
        'step': steps,
        'heartrate': heartRate,
        'sleep': sleepHours,
      });
      return true;
    } catch (e) {
      debugPrint('Error syncing lifestyle data: $e');
      return false;
    }
  }
}
