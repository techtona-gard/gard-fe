import 'package:flutter/material.dart';
import 'package:gard_fe/constants/app_colors.dart';

class HealthPage extends StatelessWidget {
  const HealthPage({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryGard = AppColors.primary;
    const bgGard = AppColors.background;

    return Scaffold(
      backgroundColor: bgGard,
      appBar: AppBar(
        title: const Text('Kesehatan & Lifestyle', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: primaryGard,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            _buildStatTile('Pola Makan', '85% Teratur', Icons.restaurant_rounded, Colors.orange),
            _buildStatTile('Kualitas Tidur', 'Baik (7.5 Jam)', Icons.bedtime_rounded, primaryGard),
            _buildStatTile('Aktivitas Fisik', '4.200 Langkah', Icons.directions_walk_rounded, primaryGard),
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
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text(subtitle, style: const TextStyle(color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }
}
