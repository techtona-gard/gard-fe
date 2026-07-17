import 'package:flutter/material.dart';
import 'package:gard/pages/gerdq_page.dart';
import 'package:gard/pages/login_page.dart';
import 'package:gard/pages/edit_profile_page.dart';
import 'package:gard/constants/app_colors.dart';
import 'package:gard/services/supabase_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String name = "Pengguna";
  String height = "-";
  String weight = "-";
  String emergencyContact = "-";
  String gerdStatus = "Belum Dites";
  String email = "";
  String birthDate = "-";
  String avatarUrl = "";
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    setState(() => _isLoading = true);
    final data = await SupabaseService.instance.getProfileData();
    if (data != null) {
      setState(() {
        name = data['name'] ?? name;
        email = data['email'] ?? email;
        height = data['height'] ?? height;
        weight = data['weight'] ?? weight;
        birthDate = data['birth_date'] ?? birthDate;
        emergencyContact = data['emergency_wa'] ?? emergencyContact;
        gerdStatus = data['gerd_status'] ?? gerdStatus;
        avatarUrl = data['avatar_url'] ?? avatarUrl;
      });
    }
    setState(() => _isLoading = false);
  }

  void _handleLogout() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 28),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            // Icon illustration
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.logout_rounded,
                color: AppColors.error,
                size: 34,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Keluar Akun?',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.darkAccent,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Anda akan keluar dari sesi ini.\nSemua data tetap aman tersimpan.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),
            // Tombol Ya, Keluar
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () async {
                  // Show loading or just sign out
                  await SupabaseService.instance.signOut();
                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginPage()),
                      (route) => false,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Ya, Keluar',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Tombol Batal
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Batal',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
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
          birthDate: birthDate,
        ),
      ),
    );
    if (result != null) {
      final newName = result['name'] ?? name;
      final newEmail = result['email'] ?? email;
      final newHeight = result['height'] ?? height;
      final newWeight = result['weight'] ?? weight;
      final newEmergencyContact = result['emergencyContact'] ?? emergencyContact;
      final newBirthDate = result['birthDate'] ?? birthDate;

      setState(() => _isLoading = true);
      try {
        await SupabaseService.instance.saveProfile(
          name: newName,
          height: num.tryParse(newHeight) ?? 175,
          weight: num.tryParse(newWeight) ?? 70,
          birthDate: newBirthDate,
          emergencyWa: newEmergencyContact,
        );
        setState(() {
          name = newName;
          email = newEmail;
          height = newHeight;
          weight = newWeight;
          emergencyContact = newEmergencyContact;
          birthDate = newBirthDate;
        });
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal memperbarui data: $e'), backgroundColor: AppColors.primary),
          );
        }
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }
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
                      child: avatarUrl.isNotEmpty
                          ? Image.network(
                              avatarUrl,
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  color: AppColors.softAccent,
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: const Icon(Icons.person_rounded,
                                    size: 50, color: AppColors.primary),
                              ),
                            )
                          : Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                color: AppColors.softAccent,
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: const Icon(Icons.person_rounded,
                                  size: 50, color: AppColors.primary),
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
