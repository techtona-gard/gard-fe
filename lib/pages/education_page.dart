import 'package:flutter/material.dart';
import 'package:gard/constants/app_colors.dart';

class EducationPage extends StatelessWidget {
  const EducationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Edukasi Lambung', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildArticleCard('Mengenal Gejala GERD', 'Pelajari perbedaan maag biasa dan GERD...', Icons.menu_book_rounded),
          _buildArticleCard('Tips Diet Lambung', 'Daftar makanan yang aman dikonsumsi...', Icons.restaurant_rounded),
          _buildArticleCard('Gaya Hidup Sehat', 'Mengatur posisi tidur untuk penderita asam lambung...', Icons.accessibility_new_rounded),
          _buildArticleCard('Mitos vs Fakta', 'Kebenaran tentang konsumsi kopi dan coklat...', Icons.help_outline_rounded),
        ],
      ),
    );
  }

  Widget _buildArticleCard(String title, String desc, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppColors.doctorPrimary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: AppColors.doctorPrimary),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(desc, style: const TextStyle(color: Colors.grey, fontSize: 13), maxLines: 2, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
