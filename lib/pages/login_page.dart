import 'dart:async';
import 'package:flutter/material.dart';
import 'package:gard/main.dart';
import 'package:gard/pages/doctor_register_page.dart';
import 'package:gard/constants/app_colors.dart';
import 'package:gard/services/supabase_service.dart';
import 'package:gard/services/google_calendar_service.dart';
import 'package:gard/pages/complete_profile_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLoading = false;
  StreamSubscription<AuthState>? _authSubscription;

  @override
  void initState() {
    super.initState();
    // Listen ONLY for actual sign-in events (not initialSession)
    _authSubscription =
        Supabase.instance.client.auth.onAuthStateChange.listen((data) async {
      final event = data.event;
      debugPrint("Auth event: $event");

      // Only navigate on a fresh sign-in, NOT on initialSession
      if (event == AuthChangeEvent.signedIn && mounted) {
        // Persist the Google provider token so it survives app restarts
        final providerToken = data.session?.providerToken;
        if (providerToken != null && providerToken.isNotEmpty) {
          await GoogleCalendarService.instance.persistProviderToken(providerToken);
          debugPrint("Token Calendar Berhasil Disimpan dari Login");
        } else {
          debugPrint("Warning: Token Calendar kosong/tidak didapatkan pada saat Login");
        }
        await _navigateAfterLogin();
      }
    });
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  Future<void> _navigateAfterLogin() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final profileExists = await SupabaseService.instance.checkProfileExists();
      if (!mounted) return;

      if (profileExists) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainNavigation()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const CompleteProfilePage()),
        );
      }
    } catch (e) {
      debugPrint("Error checking profile: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    try {
      await SupabaseService.instance.signInWithGoogle();

      // Mock mode: signInWithGoogle() sets prefs and returns, navigate manually
      if (!SupabaseService.instance.isConfigured && mounted) {
        await _navigateAfterLogin();
        return;
      }
      // Real OAuth: browser opens → user signs in → deep link fires →
      // onAuthStateChange emits signedIn → _navigateAfterLogin() is called
      // So we just stop loading indicator here
      if (mounted) setState(() => _isLoading = false);
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login Gagal: $e'),
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
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ── LOGO ────────────────────────────────────────────────────
                Image.asset(
                  'assets/images/logo_full.png',
                  width: 160,
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
                        'Selamat Datang',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkAccent,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Masuk dengan akun Google Anda untuk\nmemulai pemantauan kesehatan lambung.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                          height: 1.6,
                        ),
                      ),

                      const SizedBox(height: 36),

                      // ── Sign in with Google Button ──────────────────────────
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleGoogleSignIn,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.darkAccent,
                            elevation: 0,
                            side: const BorderSide(
                                color: AppColors.softAccent, width: 1.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    color: AppColors.primary,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // Google G logo colors
                                    _GoogleIcon(),
                                    const SizedBox(width: 12),
                                    const Text(
                                      'Masuk dengan Google',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.darkAccent,
                                        letterSpacing: 0.3,
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
                          Expanded(
                              child: Divider(
                                  color: AppColors.softAccent, thickness: 1)),
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
                          Expanded(
                              child: Divider(
                                  color: AppColors.softAccent, thickness: 1)),
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
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 13),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const DoctorRegisterPage()));
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

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/logo_icon.png',
                      width: 14,
                      height: 14,
                      color: AppColors.textHint,
                      errorBuilder: (_, __, ___) => const Icon(
                          Icons.favorite,
                          size: 14,
                          color: AppColors.textHint),
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

  Widget _buildAccessRule({
    required IconData icon,
    required String title,
    required String desc,
    required Color color,
  }) {
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
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Google "G" logo icon using colored shapes
class _GoogleIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 22,
      height: 22,
      child: CustomPaint(painter: _GoogleLogoPainter()),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Draw background circle
    canvas.drawCircle(center, radius, Paint()..color = Colors.white);

    // Draw "G" segments
    final paints = [
      Paint()..color = const Color(0xFF4285F4), // blue
      Paint()..color = const Color(0xFF34A853), // green
      Paint()..color = const Color(0xFFFBBC05), // yellow
      Paint()..color = const Color(0xFFEA4335), // red
    ];

    // Blue top-right arc
    canvas.drawArc(rect, -1.1, 1.85, true, paints[0]);
    // Green bottom-right arc
    canvas.drawArc(rect, 0.75, 1.1, true, paints[1]);
    // Yellow bottom-left arc
    canvas.drawArc(rect, 1.85, 1.1, true, paints[2]);
    // Red top-left arc
    canvas.drawArc(rect, 2.95, 1.33, true, paints[3]);

    // Inner white circle
    canvas.drawCircle(center, radius * 0.6, Paint()..color = Colors.white);

    // Blue right bar (horizontal bar of G)
    final barPaint = Paint()..color = const Color(0xFF4285F4);
    canvas.drawRect(
      Rect.fromLTWH(center.dx, center.dy - radius * 0.15,
          radius * 0.95, radius * 0.3),
      barPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
