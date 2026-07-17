import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:gard/models/history_model.dart';
import 'package:flutter/foundation.dart';

class HistoryService {
  static final HistoryService _instance = HistoryService._internal();
  static HistoryService get instance => _instance;

  HistoryService._internal();

  final SupabaseClient _client = Supabase.instance.client;

  /// Fetch history records for the current user
  Future<List<HistoryModel>> fetchHistory() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      final response = await _client
          .from('histories')
          .select()
          .eq('user_id', user.id)
          .order('history_date', ascending: false);

      final List<dynamic> data = response;
      return data.map((json) => HistoryModel.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error fetching history: $e');
      return [];
    }
  }

  /// Insert a new history record
  Future<bool> insertHistory(HistoryModel history) async {
    try {
      await _client.from('histories').insert(history.toJson());
      return true;
    } catch (e) {
      debugPrint('Error inserting history: $e');
      return false;
    }
  }
}
