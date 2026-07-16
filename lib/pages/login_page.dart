import 'package:flutter/material.dart';
import 'package:gard_fe/main.dart';
import 'package:gard_fe/pages/doctor_register_page.dart';
import 'package:gard_fe/constants/app_colors.dart';
import 'package:gard_fe/services/supabase_service.dart';
import 'package:gard_fe/pages/complete_profile_page.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ── LOGO ICON ───────────────────────────────────────────────
                Image.asset(
                  'assets/images/logo_icon.png',
                  width: 80,
                  height: 80,
                  fit: BoxFit.contain,
                ),

                const SizedBox(height: 40),

                // ── Form Card ────────────────────────────────────────────────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.08),
                        blurRadius: 30,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 4),
                      const Text(
                        'Selamat Datang Kembali',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkAccent,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Silakan masuk untuk melanjutkan\npemantauan kesehatan Anda.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                          height: 1.6,
                        ),
                      ),

                      const SizedBox(height: 36),

                      // ── Tombol Masuk ───────────────────────────────────────
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () async {
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) => const Center(
                                child: CircularProgressIndicator(color: AppColors.primary),
                              ),
                            );

                            try {
                              await SupabaseService.instance.signInWithGoogle();
                              final profileExists = await SupabaseService.instance.checkProfileExists();

                              if (context.mounted) {
                                Navigator.pop(context); // close loading dialog

                                if (profileExists) {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(builder: (context) => const MainNavigation()),
                                  );
                                } else {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(builder: (context) => const CompleteProfilePage()),
                                  );
                                }
                              }
                            } catch (e) {
                              if (context.mounted) {
                                Navigator.pop(context); // close loading dialog
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Login Gagal: $e'),
                                    backgroundColor: AppColors.error,
                                  ),
                                );
                              }
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
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/images/logo_icon.png',
                                width: 22,
                                height: 22,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 10),
                              const Text(
                                'Masuk ke GARD',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 28),

                      // ── Divider ────────────────────────────────────────────
                      const Row(
                        children: [
                          Expanded(child: Divider(color: AppColors.softAccent, thickness: 1)),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'AKSES PLATFORM',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                          Expanded(child: Divider(color: AppColors.softAccent, thickness: 1)),
                        ],
                      ),

                      const SizedBox(height: 20),

                      _buildAccessRule(
                        icon: Icons.person_outline_rounded,
                        title: 'Pengguna Umum',
                        desc: 'Gunakan akun Google untuk akses cepat.',
                        color: AppColors.primary,
                      ),
                      const SizedBox(height: 12),
                      _buildAccessRule(
                        icon: Icons.medical_services_outlined,
                        title: 'Tenaga Medis',
                        desc: 'Akses khusus pemantauan pasien.',
                        color: AppColors.darkAccent,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 36),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Ingin bergabung sebagai mitra?',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) => const DoctorRegisterPage()));
                      },
                      child: const Text(
                        'Daftar Dokter',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Placeholder brand tagline
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/logo_icon.png',
                      width: 14,
                      height: 14,
                      color: AppColors.textHint,
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'GARD · Gerd Guard © 2024',
                      style: TextStyle(
                        color: AppColors.textHint,
                        fontSize: 11,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAccessRule(
      {required IconData icon, required String title, required String desc, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.10),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppColors.darkAccent,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  desc,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
