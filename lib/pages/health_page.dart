import 'package:flutter/material.dart';
import 'package:gard/constants/app_colors.dart';
import 'package:gard/services/health_connect_service.dart';

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
        : SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!_isConnected)
                Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: AppColors.error),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Gagal mengambil data. Pastikan izin Health Connect diberikan.',
                          style: TextStyle(color: AppColors.error, fontSize: 13),
                        ),
                      ),
                      TextButton(
                        onPressed: _initHealthConnect,
                        child: const Text('COBA LAGI'),
                      )
                    ],
                  ),
                ),
                
              const Text(
                'Grafik Aktivitas Mingguan',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryGard),
              ),
              const SizedBox(height: 20),
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                ),
                child: const Center(
                  child: Icon(Icons.bar_chart_rounded, size: 100, color: primaryGard),
                ),
              ),
              const SizedBox(height: 30),
              _buildStatTile('Kalori Terbakar', caloriesText, Icons.local_fire_department_rounded, Colors.orange),
              _buildStatTile('Kualitas Tidur', sleepText, Icons.bedtime_rounded, primaryGard),
              _buildStatTile('Aktivitas Fisik', stepsText, Icons.directions_walk_rounded, primaryGard),
            ],
          ),
        ),
    );
  }

  Widget _buildStatTile(String title, String subtitle, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
