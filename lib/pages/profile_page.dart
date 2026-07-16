import 'package:flutter/material.dart';
import 'package:gard_fe/pages/gerdq_page.dart';
import 'package:gard_fe/pages/login_page.dart';
import 'package:gard_fe/pages/edit_profile_page.dart';
import 'package:gard_fe/constants/app_colors.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String name = "Brawidya Puja Dharma";
  String height = "175";
  String weight = "70";
  String emergencyContact = "081272733891";
  String gerdStatus = "Resiko Rendah";
  String email = "brawidya12@gmail.com";
  String birthDate = "12 Agustus 1998";

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Keluar Akun'),
        content: const Text('Apakah Anda yakin ingin keluar dari aplikasi?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Ya, Keluar'),
          ),
        ],
      ),
    );
  }

  Future<void> _openEditProfile() async {
    final result = await Navigator.push<Map<String, String>>(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfilePage(
          name: name,
          height: height,
          weight: weight,
          emergencyContact: emergencyContact,
          email: email,
        ),
      ),
    );
    if (result != null) {
      setState(() {
        name = result['name'] ?? name;
        height = result['height'] ?? height;
        weight = result['weight'] ?? weight;
        emergencyContact = result['emergencyContact'] ?? emergencyContact;
        email = result['email'] ?? email;
        birthDate = result['birthDate'] ?? birthDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // ── CARD 1: Profile Summary ───────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Header Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Profile',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkAccent,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'PASIEN',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Rounded Rectangle Avatar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Image.network(
                        'https://i.pravatar.cc/300',
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 18),
                    // Name
                    Text(
                      name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: AppColors.darkAccent,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Subtitle
                    const Text(
                      'PENGGUNA GARD',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 18),
                    // Email Pill Container
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.email, size: 16, color: AppColors.primary),
                          const SizedBox(width: 8),
                          Text(
                            email,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ── CARD 2: Informasi Kesehatan ───────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Card 2 Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'INFORMASI KESEHATAN',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textSecondary,
                            letterSpacing: 0.8,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: _openEditProfile,
                          icon: const Icon(Icons.edit_rounded, size: 14, color: Colors.white),
                          label: const Text(
                            'UBAH DATA',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Profile Fields matching screenshot style
                    _buildScreenInfoField('NAMA LENGKAP', name),
                    _buildScreenInfoField('TANGGAL LAHIR', birthDate),
                    _buildScreenInfoField('TINGGI BADAN', '$height cm'),
                    _buildScreenInfoField('BERAT BADAN', '$weight kg'),
                    _buildScreenInfoField('NO. WA DARURAT', emergencyContact),
                    _buildScreenInfoField('STATUS GERD', gerdStatus,
                        isHighlighted: gerdStatus.toLowerCase().contains('tinggi')),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ── Pengecekan GERD Card ─────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 16,
                        offset: const Offset(0, 6))
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.assignment_turned_in_rounded,
                            size: 16, color: AppColors.primary),
                        SizedBox(width: 8),
                        Text(
                          'PENGECEKAN GERD',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textSecondary,
                              letterSpacing: 0.8),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Lakukan pengecekan rutin menggunakan kuesioner GerdQ untuk memantau tingkat keparahan gejala Anda.',
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 13, height: 1.5),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const GerdQPage()),
                          );
                        },
                        icon: const Icon(Icons.assignment_outlined, size: 18),
                        label: const Text('MULAI PENGECEKAN GERDQ',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.warning.withOpacity(0.1),
                          foregroundColor: AppColors.warning,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          side: BorderSide(color: AppColors.warning.withOpacity(0.25)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ── Logout Button ────────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton.icon(
                  onPressed: _handleLogout,
                  icon: const Icon(Icons.logout_rounded, color: AppColors.error, size: 20),
                  label: const Text(
                    'KELUAR AKUN',
                    style: TextStyle(
                        color: AppColors.error,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFFFCDD2), width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    backgroundColor: AppColors.error.withOpacity(0.04),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Branding footer
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/images/logo_icon.png',
                      width: 14,
                      height: 14,
                      color: AppColors.textHint,
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'GARD · Gerd Guard',
                      style: TextStyle(
                          color: AppColors.textHint, fontSize: 11, letterSpacing: 0.5),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScreenInfoField(String label, String value, {bool isHighlighted = false}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isHighlighted
            ? AppColors.error.withOpacity(0.05)
            : AppColors.background.withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isHighlighted ? AppColors.error.withOpacity(0.2) : Colors.transparent,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: isHighlighted ? AppColors.error : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
