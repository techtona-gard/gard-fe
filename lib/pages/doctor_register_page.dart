import 'package:flutter/material.dart';
import 'package:gard_fe/pages/doctor_verification_page.dart';
import 'package:gard_fe/constants/app_colors.dart';

class DoctorRegisterPage extends StatefulWidget {
  const DoctorRegisterPage({super.key});

  @override
  State<DoctorRegisterPage> createState() => _DoctorRegisterPageState();
}

class _DoctorRegisterPageState extends State<DoctorRegisterPage> {
  bool _isAgreed = false;

  @override
  Widget build(BuildContext context) {
    const emeraldGreen = AppColors.doctorPrimary;
    const offWhite = Color(0xFFF8F9FA);

    return Scaffold(
      backgroundColor: offWhite,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    )
                  ],
                ),
                child: const Icon(Icons.health_and_safety_rounded, size: 50, color: emeraldGreen),
              ),
              const SizedBox(height: 24),
              const Text(
                'GARD for Doctors',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1A1C1E)),
              ),
              const Text(
                'GERBANG LAYANAN KEMITRAAN DOKTER',
                style: TextStyle(fontSize: 12, color: Colors.grey, letterSpacing: 1.2, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 48),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: emeraldGreen,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Text(
                    'PERNYATAAN & PERSETUJUAN KEMITRAAN',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'TINJAU KLASIFIKASI AKUN SEBELUM MELANJUTKAN',
                style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade100),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.info_outline_rounded, size: 18, color: emeraldGreen),
                        const SizedBox(width: 8),
                        Text(
                          'Kerja Sama Mitra GARD',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black.withOpacity(0.7)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: emeraldGreen.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'PASAL 2 - KEWAJIBAN VERIFIKASI IDENTITAS & KREDENSIAL MEDIS',
                        style: TextStyle(color: emeraldGreen, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Setiap pendaftar mitra dokter berkewajiban melengkapi profil profesional, surat izin praktik, serta dokumen legalitas medis lainnya pada fase onboarding sebelum layanan diaktifkan.',
                      style: TextStyle(fontSize: 13, color: Colors.black54, height: 1.5),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Checkbox(
                      value: _isAgreed,
                      activeColor: emeraldGreen,
                      onChanged: (val) => setState(() => _isAgreed = val ?? false),
                    ),
                    const Expanded(
                      child: Text(
                        'Saya menyatakan secara sadar bahwa saya adalah tenaga medis resmi dan menyetujui seluruh ketentuan mitra GARD.',
                        style: TextStyle(fontSize: 12, color: Colors.black87),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Batalkan Proses', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isAgreed ? () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const DoctorVerificationPage()));
                  } : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: emeraldGreen,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey.shade300,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: const Text('Daftar Sebagai Dokter', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
              const SizedBox(height: 40),
              const Text(
                'GARD PLATFORM © 2024',
                style: TextStyle(color: Colors.grey, fontSize: 10, letterSpacing: 1),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
