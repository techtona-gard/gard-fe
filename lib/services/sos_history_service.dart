import 'package:flutter/material.dart';

class SosEvent {
  final String id;
  final DateTime timestamp;
  final String number;

  SosEvent({
    required this.id,
    required this.timestamp,
    required this.number,
  });

  String get formattedTime {
    final d = timestamp;
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}, '
        '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }
}

/// Singleton service to store SOS events in memory.
/// Can be replaced with a persistent database (Supabase/Hive) later.
class SosHistoryService extends ChangeNotifier {
  static final SosHistoryService _instance = SosHistoryService._internal();
  factory SosHistoryService() => _instance;
  SosHistoryService._internal();

  final List<SosEvent> _events = [];

  List<SosEvent> get events => List.unmodifiable(_events.reversed.toList());

  void addEvent({required String number}) {
    _events.add(SosEvent(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      timestamp: DateTime.now(),
      number: number,
    ));
    notifyListeners();
  }
}
