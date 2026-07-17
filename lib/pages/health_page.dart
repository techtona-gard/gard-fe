import 'package:flutter/material.dart';
import 'package:gard/constants/app_colors.dart';
import 'package:gard/services/health_connect_service.dart';
import 'package:gard/services/health_sync_service.dart';
import 'package:gard/pages/lifestyle_graph_page.dart';

class HealthPage extends StatefulWidget {
  const HealthPage({super.key});

  @override
  State<HealthPage> createState() => _HealthPageState();
}

class _HealthPageState extends State<HealthPage> {
  final HealthService _healthService = HealthService();
  bool _isLoading = true;
  bool _isConnected = false;
  Map<String, dynamic>? _healthSummary;

  @override
  void initState() {
    super.initState();
    _initHealthConnect();
  }

  Future<void> _initHealthConnect() async {
    setState(() => _isLoading = true);
    
    // 1. Initialize plugin
    await _healthService.init();

    // 2. Request permissions directly when page opens
    bool authorized = await _healthService.requestPermissions();
    
    if (authorized) {
      // 3. Fetch data if authorized
      final summary = await _healthService.getTodaySummary();
      if (mounted) {
        setState(() {
          _isConnected = true;
          _healthSummary = summary;
          _isLoading = false;
        });
      }
      
      // Sync ke backend (Supabase)
      if (summary != null) {
        final int steps = summary['steps'] ?? 0;
        final double heartRate = summary['heartRate'] ?? 0.0;
        final int sleepMins = summary['sleepMinutes'] ?? 0;
        
        await HealthSyncService.instance.syncLifestyleData(
          steps: steps > 0 ? steps : null,
          heartRate: heartRate > 0 ? heartRate.toInt() : null,
          sleepHours: sleepMins > 0 ? (sleepMins / 60) : null,
        );
      }
    } else {
      if (mounted) {
        setState(() {
          _isConnected = false;
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Izin Health Connect belum diberikan.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryGard = AppColors.primary;
    const bgGard = AppColors.background;

    // Get dynamic values or default to '-'
    String stepsText = '- Langkah';
    String sleepText = '- Jam';
    String caloriesText = '- Kkal';

    if (_healthSummary != null) {
      final steps = _healthSummary!['steps'] ?? 0;
      final sleepMins = _healthSummary!['sleepMinutes'] ?? 0;
      final calories = _healthSummary!['calories'] ?? 0.0;
      
      stepsText = '$steps Langkah';
      if (sleepMins > 0) {
        final hours = (sleepMins / 60).toStringAsFixed(1);
        sleepText = '$hours Jam';
      }
      if (calories > 0) {
        caloriesText = '${calories.toStringAsFixed(0)} Kkal';
      }
    }

    return Scaffold(
      backgroundColor: bgGard,
      appBar: AppBar(
        title: const Text('Kesehatan & Lifestyle', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: primaryGard,
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: _initHealthConnect,
            tooltip: 'Sinkronisasi Ulang',
          ),
        ],
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: primaryGard))
        : const LifestyleGraphPage(),
    );
  }
}
