import 'package:flutter/material.dart';
import 'package:gard_fe/pages/chatbot_page.dart';
import 'package:gard_fe/pages/gerdq_page.dart';
import 'package:gard_fe/pages/health_page.dart';
import 'package:gard_fe/pages/consultation_page.dart';
import 'package:gard_fe/pages/education_page.dart';

import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:ui';
import 'package:gard_fe/constants/app_colors.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late AnimationController _sosController;
  bool _isSosHolding = false;

  @override
  void initState() {
    super.initState();
    _sosController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _triggerSos();
        }
      });
  }

  @override
  void dispose() {
    _sosController.dispose();
    super.dispose();
  }

  void _triggerSos() {
    setState(() => _isSosHolding = false);
    _sosController.reset();
    _sendFonnteWhatsApp();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('SOS TERKIRIM!',
            style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
        content:
            const Text('Bantuan medis darurat sedang dalam perjalanan. Pihak terkait telah dihubungi otomatis.'),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('OK'),
          )
        ],
      ),
    );
  }

  void _sendFonnteWhatsApp() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      const String token = 'ZV8uTKHBBwpK69p6MU4V';
      const String targetNumber = '081272733891';
      final String message = '🚨 SOS DARURAT!\n\n'
          'Pengguna GARD *Brawidya Dharma* terdeteksi membutuhkan bantuan medis segera akibat serangan gejala lambung/GERD akut.\n\n'
          '📍 Lokasi Terkini:\n'
          'https://www.google.com/maps/search/?api=1&query=${position.latitude},${position.longitude}\n\n'
          '📋 Ringkasan Rekam Medis:\n'
          '- 16 Juli: Gejala GERD (Sedang)\n'
          '- 14 Juli: Konsultasi dr. Andi (Sp.PD)\n'
          '- 10 Juli: GerdQ (Resiko Tinggi)';

      final response = await http.post(
        Uri.parse('https://api.fonnte.com/send'),
        headers: {'Authorization': token},
        body: {'target': targetNumber, 'message': message, 'countryCode': '62'},
      ).timeout(const Duration(seconds: 15));
      debugPrint('Fonnte Response: ${response.body}');
    } catch (e) {
      debugPrint('Error sending SOS via Fonnte: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // ── Header Section ─────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(24, 56, 24, 40),
                  decoration: const BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(40),
                      bottomRight: Radius.circular(40),
                    ),
                  ),
                  child: Column(
                    children: [
                      // ── Top Bar ──────────────────────────────────────────
                      Row(
                        children: [
                          // Avatar dengan logo_icon
                          Container(
                            padding: const EdgeInsets.all(2.5),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.25),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white.withOpacity(0.6), width: 1.5),
                            ),
                            child: CircleAvatar(
                              radius: 24,
                              backgroundColor: AppColors.softAccent,
                              child: ClipOval(
                                child: Image.asset(
                                  'assets/images/logo_icon.png',
                                  width: 36,
                                  height: 36,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Selamat Datang,',
                                    style: TextStyle(color: Colors.white60, fontSize: 13)),
                                Text('Brawidya Dharma',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                          // Notif dengan logo_icon sebagai badge
                          Stack(
                            children: [
                              IconButton(
                                onPressed: () {},
                                icon: const Icon(Icons.notifications_none_rounded,
                                    color: Colors.white, size: 28),
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Container(
                                  width: 10,
                                  height: 10,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFD1E8D0),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 28),

                      // ── Status Card ────────────────────────────────────────
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white.withOpacity(0.25)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Status Risiko GERD',
                                        style: TextStyle(color: Colors.white70, fontSize: 12)),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Container(
                                          width: 8,
                                          height: 8,
                                          margin: const EdgeInsets.only(right: 8),
                                          decoration: const BoxDecoration(
                                            color: AppColors.softAccent,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const Text('RENDAH',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  ],
                                ),
                                GestureDetector(
                                  onTap: () => Navigator.push(context,
                                      MaterialPageRoute(builder: (context) => const GerdQPage())),
                                  child: Container(
                                    padding:
                                        const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: const Text('Cek Ulang',
                                        style: TextStyle(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Quick Stats ────────────────────────────────────────────────
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStatCard('80', 'BPM', Icons.favorite_rounded, Colors.redAccent),
                      _buildStatCard('Normal', 'Stres', Icons.psychology_rounded, AppColors.midTeal),
                      _buildStatCard('7h 20m', 'Tidur', Icons.bedtime_rounded, AppColors.primary),
                      _buildStatCard('4.2k', 'Langkah', Icons.directions_walk_rounded, const Color(0xFFE67E22)),
                    ],
                  ),
                ),
              ),

              // ── Layanan Utama ─────────────────────────────────────────────
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 36),
                      Row(
                        children: [
                          Container(
                            width: 3,
                            height: 16,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'LAYANAN UTAMA',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textSecondary,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      GridView.count(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 4,
                        mainAxisSpacing: 20,
                        crossAxisSpacing: 12,
                        childAspectRatio: 0.78,
                        children: [
                          _buildServiceItem('Kesehatan', Icons.add_circle_outline_rounded,
                              () => Navigator.push(context, MaterialPageRoute(builder: (context) => const HealthPage()))),
                          _buildServiceItem('Konsultasi', Icons.person_search_rounded,
                              () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ConsultationPage()))),
                          _buildServiceItem('Edukasi', Icons.auto_stories_outlined,
                              () => Navigator.push(context, MaterialPageRoute(builder: (context) => const EducationPage()))),
                          _buildServiceItem('Chatbot', Icons.chat_bubble_outline_rounded,
                              () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ChatbotPage()))),
                          _buildServiceItem('Apotek', Icons.local_pharmacy_outlined),
                          _buildServiceItem('Nutrisi', Icons.restaurant_menu_rounded),
                          _buildServiceItem('Komunitas', Icons.groups_2_outlined),
                          _buildServiceItem('Lainnya', Icons.grid_view_rounded),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 160)),
            ],
          ),

          // ── SOS Button ────────────────────────────────────────────────────
          Positioned(
            bottom: 110,
            right: 20,
            child: GestureDetector(
              onLongPressStart: (_) {
                setState(() => _isSosHolding = true);
                _sosController.forward();
              },
              onLongPressEnd: (_) {
                setState(() => _isSosHolding = false);
                if (_sosController.status != AnimationStatus.completed) _sosController.reverse();
              },
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 68,
                    height: 68,
                    child: CircularProgressIndicator(
                      value: _sosController.value,
                      strokeWidth: 3,
                      backgroundColor: AppColors.primary.withOpacity(0.08),
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  ),
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: _isSosHolding ? AppColors.primary.withOpacity(0.1) : Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.22),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        )
                      ],
                      border: Border.all(
                          color: _isSosHolding ? AppColors.primary : AppColors.primary.withOpacity(0.2),
                          width: 1.5),
                    ),
                    child: Center(
                      child: Text(
                        'SOS',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String val, String label, IconData icon, Color iconColor) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: AppColors.card,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              )
            ],
          ),
          child: Center(
            child: Icon(icon, color: iconColor, size: 28),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          val,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildServiceItem(String label, IconData icon, [VoidCallback? onTap]) {
    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(22),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.darkAccent.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: AppColors.softAccent,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppColors.primary, size: 24),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.darkAccent,
              letterSpacing: 0.1),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
