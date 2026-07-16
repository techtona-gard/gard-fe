import 'package:flutter/material.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    const emeraldGreen = Color(0xFF006D32);

    return Scaffold(
      backgroundColor: const Color(0xfff4f4f4),
      appBar: AppBar(
        title: const Text('Rekam Medis & History', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: emeraldGreen,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildHistoryItem(
              context,
              'Gejala GERD Terdeteksi',
              '16 Juli 2024, 08:30',
              'Tingkat Keparahan: Sedang',
              Icons.warning_amber_rounded,
              Colors.orange,
            ),
            _buildHistoryItem(
              context,
              'Konsultasi Dokter',
              '14 Juli 2024, 10:00',
              'Dokter: dr. Andi (Sp.PD)',
              Icons.medical_services_outlined,
              Colors.blue,
            ),
            _buildHistoryItem(
              context,
              'Pemeriksaan GerdQ',
              '10 Juli 2024, 20:00',
              'Hasil: Resiko Tinggi',
              Icons.assignment_outlined,
              Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryItem(BuildContext context, String title, String date, String desc, IconData icon, Color color) {
    const emeraldGreen = Color(0xFF006D32);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24), // Smoother rounded
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(date, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 4),
                Text(desc, style: const TextStyle(color: Colors.black54, fontSize: 13)),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: emeraldGreen,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              minimumSize: Size.zero,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('DETAIL', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
