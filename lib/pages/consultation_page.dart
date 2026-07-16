import 'package:flutter/material.dart';
import 'package:gard_fe/constants/app_colors.dart';

class ConsultationPage extends StatelessWidget {
  const ConsultationPage({super.key});

  static final List<Map<String, dynamic>> _doctors = [
    {
      'name': 'Dr. Andi Wijaya, Sp.PD-KGEH',
      'specialty': 'Spesialis Gastroentero-Hepatologi',
      'price': 'Rp 85.000',
      'rating': '4.9',
      'reviews': '150',
      'image': 'https://i.pravatar.cc/150?img=11',
    },
    {
      'name': 'Dr. Sarah Quinn, Sp.PD',
      'specialty': 'Spesialis Penyakit Dalam (GERD Expert)',
      'price': 'Rp 70.000',
      'rating': '4.8',
      'reviews': '98',
      'image': 'https://i.pravatar.cc/150?img=5',
    },
    {
      'name': 'Dr. Budi Santoso, Sp.PD',
      'specialty': 'Konsultan Lambung & Pencernaan',
      'price': 'Rp 95.000',
      'rating': '5.0',
      'reviews': '210',
      'image': 'https://i.pravatar.cc/150?img=12',
    },
    {
      'name': 'Dr. Linda Sari, Sp.PD',
      'specialty': 'Spesialis Gastroentero-Hepatologi',
      'price': 'Rp 80.000',
      'rating': '4.7',
      'reviews': '85',
      'image': 'https://i.pravatar.cc/150?img=9',
    },
  ];

  @override
  Widget build(BuildContext context) {
    const emeraldGreen = AppColors.doctorPrimary;
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Konsultasi Dokter',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
            },
            icon: const Icon(Icons.history_rounded, color: emeraldGreen),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _buildFilterChip('Semua', true),
                  _buildFilterChip('Terdekat', false),
                  _buildFilterChip('Harga Terendah', false),
                  _buildFilterChip('Rating Tertinggi', false),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _buildActiveBookingCard(emeraldGreen),
                const SizedBox(height: 24),
                const Text(
                  'Rekomendasi Spesialis GERD',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                const SizedBox(height: 16),
                ..._doctors.map((doctor) => _buildDoctorCard(doctor, emeraldGreen)).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    const emeraldGreen = AppColors.doctorPrimary;
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? emeraldGreen : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isSelected ? emeraldGreen : Colors.grey.shade300),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.grey.shade700,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildActiveBookingCard(Color themeColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [themeColor, themeColor.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: themeColor.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.videocam_rounded, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Konsultasi Sedang Berlangsung',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    Text(
                      'Dr. Andi Wijaya - 25 Okt, 14:00',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 16),
            ],
          ),
          const Divider(color: Colors.white24, height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Status: Menunggu Dokter',
                style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'PROSES',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorCard(Map<String, dynamic> doctor, Color emeraldGreen) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 85,
            height: 85,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              image: DecorationImage(
                image: NetworkImage(doctor['image']),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doctor['name'],
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  doctor['specialty'],
                  style: TextStyle(color: emeraldGreen, fontSize: 12, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.star_rounded, color: Colors.orange, size: 18),
                    Text(
                      ' ${doctor['rating']} ',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    Text(
                      '(${doctor['reviews']} Review)',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      doctor['price'],
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                        color: Color(0xFF2D3142),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: emeraldGreen,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Konsul',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
