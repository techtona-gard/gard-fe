import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:gard/constants/app_colors.dart';
import 'package:gard/models/lifestyle_model.dart';
import 'package:gard/services/health_sync_service.dart';
import 'package:gard/services/health_connect_service.dart';
import 'package:intl/intl.dart';

class LifestyleGraphPage extends StatefulWidget {
  const LifestyleGraphPage({super.key});

  @override
  State<LifestyleGraphPage> createState() => _LifestyleGraphPageState();
}

class _LifestyleGraphPageState extends State<LifestyleGraphPage> {
  List<LifestyleModel> _lifestyles = [];
  bool _isLoading = true;
  String _selectedMetric = 'Langkah'; // 'Langkah', 'Detak Jantung', 'Tidur'

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final data = await HealthSyncService.instance.fetchLifestyles();
    setState(() {
      _lifestyles = data;
      _isLoading = false;
    });
  }

  Future<void> _manualSync() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            ),
            SizedBox(width: 16),
            Text("Mengirim data gaya hidup ke Supabase..."),
          ],
        ),
        duration: Duration(seconds: 2),
      ),
    );

    try {
      final healthService = HealthService();
      await healthService.init();
      final hasPerm = await healthService.requestPermissions();
      
      if (hasPerm) {
        final summary = await healthService.getTodaySummary();
        final int steps = summary['steps'] ?? 0;
        final double heartRate = summary['heartRate'] ?? 0.0;
        final int sleepMins = summary['sleepMinutes'] ?? 0;

        final success = await HealthSyncService.instance.syncLifestyleData(
          steps: steps > 0 ? steps : null,
          heartRate: heartRate > 0 ? heartRate.toInt() : null,
          sleepHours: sleepMins > 0 ? (sleepMins / 60) : null,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(success ? "Data gaya hidup berhasil dikirim ke Supabase!" : "Gagal mengirim data (data hari ini kosong)."),
              backgroundColor: success ? AppColors.primary : AppColors.warning,
            ),
          );
        }
        await _loadData();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Izin akses Health Connect ditolak."),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: $e"),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.darkAccent, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Grafik Gaya Hidup',
          style: TextStyle(color: AppColors.darkAccent, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync_rounded, color: AppColors.primary),
            onPressed: _manualSync,
            tooltip: 'Sync Data Sekarang',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _lifestyles.isEmpty
              ? const Center(child: Text('Belum ada data gaya hidup yang direkam.', style: TextStyle(color: AppColors.textSecondary)))
              : _buildContent(),
    );
  }

  Widget _buildContent() {
    return Column(
      children: [
        // Metric Selector
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildMetricChip('Langkah', Icons.directions_walk_rounded),
                const SizedBox(width: 8),
                _buildMetricChip('Detak Jantung', Icons.favorite_rounded),
                const SizedBox(width: 8),
                _buildMetricChip('Tidur', Icons.bedtime_rounded),
              ],
            ),
          ),
        ),
        
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Riwayat $_selectedMetric',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.darkAccent),
                  ),
                  const SizedBox(height: 30),
                  Expanded(
                    child: _buildChart(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricChip(String metric, IconData icon) {
    final isSelected = _selectedMetric == metric;
    return GestureDetector(
      onTap: () => setState(() => _selectedMetric = metric),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.background,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? AppColors.primary : AppColors.softAccent),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: isSelected ? Colors.white : AppColors.textSecondary),
            const SizedBox(width: 6),
            Text(
              metric,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChart() {
    List<FlSpot> spots = [];
    double minY = 0;
    double maxY = 100;
    
    // Process data based on selected metric
    for (int i = 0; i < _lifestyles.length; i++) {
      final item = _lifestyles[i];
      double? value;
      
      if (_selectedMetric == 'Langkah' && item.step != null) {
        value = item.step!.toDouble();
        if (value > maxY) maxY = value + (value * 0.2);
      } else if (_selectedMetric == 'Detak Jantung' && item.heartrate != null) {
        value = item.heartrate!.toDouble();
        if (value > maxY) maxY = value + 20;
        if (minY == 0 || value < minY) minY = value - 20;
      } else if (_selectedMetric == 'Tidur' && item.sleep != null) {
        value = item.sleep!;
        if (value > maxY) maxY = value + 2;
      }

      if (value != null) {
        spots.add(FlSpot(i.toDouble(), value));
      }
    }

    if (spots.isEmpty) {
      return const Center(child: Text('Data kosong untuk metrik ini.', style: TextStyle(color: AppColors.textSecondary)));
    }

    if (minY < 0) minY = 0;

    return LineChart(
      LineChartData(
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (touchedSpot) => AppColors.primary,
            getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
              return touchedBarSpots.map((barSpot) {
                return LineTooltipItem(
                  barSpot.y.toInt().toString(),
                  const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                );
              }).toList();
            },
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxY > 10 ? maxY / 5 : 1,
          getDrawingHorizontalLine: (value) {
            return FlLine(color: AppColors.softAccent, strokeWidth: 1, dashArray: [5, 5]);
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < _lifestyles.length) {
                  final date = _lifestyles[value.toInt()].recordedAt;
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      DateFormat('dd/MM').format(date),
                      style: const TextStyle(color: AppColors.textHint, fontSize: 10),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: maxY > 10 ? maxY / 5 : 1,
              reservedSize: 42,
              getTitlesWidget: (value, meta) {
                return Text(
                  _selectedMetric == 'Langkah' 
                      ? '${(value / 1000).toStringAsFixed(1)}k' 
                      : value.toInt().toString(),
                  style: const TextStyle(color: AppColors.textHint, fontSize: 10),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: (_lifestyles.length - 1).toDouble(),
        minY: minY,
        maxY: maxY,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: AppColors.primary,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: AppColors.primary.withOpacity(0.15),
            ),
          ),
        ],
      ),
    );
  }
}
