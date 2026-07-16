import 'package:flutter/material.dart';
import 'package:gard_fe/pages/chatbot_page.dart';
import 'package:gard_fe/pages/gerdq_page.dart';
import 'package:gard_fe/pages/health_page.dart';
import 'package:gard_fe/pages/consultation_page.dart';
import 'package:gard_fe/pages/education_page.dart';
import 'package:gard_fe/services/health_connect_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late AnimationController _sosController;
  bool _isSosHolding = false;

  // ===========================================================================
  // STATE KHUSUS HEALTH CONNECT
  // ===========================================================================
  final HealthService _healthService = HealthService();
  bool _isLoadingHealth = true;
  int _steps = 0;
  double _heartRate = 0;
  int _sleepMinutes = 0;

  @override
  void initState() {
    super.initState();
    _sosController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..addListener(() {
        setState(() {});
      })..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _triggerSos();
        }
      });

    // Panggil fungsi tarik data kesehatan saat halaman dibuka
    _fetchHealthData();
  }

  /// Fungsi untuk mengoneksikan Health Connect & mengupdate UI
  Future<void> _fetchHealthData() async {
    await _healthService.init();

    // 1. Cek apakah izin sudah diberikan
    bool hasPermission = await _healthService.hasPermissions();

    // 2. Jika belum ada izin, cek apakah ini pertama kali install/buka
    if (!hasPermission) {
      final prefs = await SharedPreferences.getInstance();
      bool isFirstTime = prefs.getBool('first_time_health_permission') ?? true;

      if (isFirstTime) {
        // Tampilkan dialog selamat datang & ajakan koneksi Health Connect
        if (mounted) {
          await _showHealthConnectWelcomeDialog();
        }

        // Minta izin ke sistem
        hasPermission = await _healthService.requestPermissions();

        // Simpan status bahwa kita sudah pernah meminta izin (agar tidak muncul terus jika ditolak)
        await prefs.setBool('first_time_health_permission', false);
      }
    }

    // 3. Jika izin diberikan (atau sudah ada), tarik data summary
    if (hasPermission) {
      final summary = await _healthService.getTodaySummary();
      if (mounted) {
        setState(() {
          _steps = summary['steps'] ?? 0;
          _heartRate = summary['heartRate'] ?? 0;
          _sleepMinutes = summary['sleepMinutes'] ?? 0;
          _isLoadingHealth = false;
        });
      }
    } else {
      if (mounted) {
        setState(() => _isLoadingHealth = false);
      }
    }
  }

  /// Dialog selamat datang khusus untuk Health Connect (UX First Install)
  Future<void> _showHealthConnectWelcomeDialog() async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.health_and_safety_rounded, color: Color(0xFF006D32)),
            SizedBox(width: 10),
            Text('Koneksi Kesehatan', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text(
          'Untuk memberikan analisis risiko GERD yang lebih akurat, Gard-Fe ingin terhubung dengan Health Connect untuk memantau aktivitas fisik dan pola tidur Anda.',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Nanti Saja', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF006D32),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Hubungkan Sekarang'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _sosController.dispose();
    super.dispose();
  }

  void _triggerSos() {
    setState(() => _isSosHolding = false);
    _sosController.reset();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('SOS TERKIRIM!', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF006D32))),
        content: const Text('Bantuan medis darurat sedang dalam perjalanan. Lokasi Anda telah dibagikan.'),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
      ),
    );
  }

  // Helper untuk format display jam tidur (menit -> 0h 0m)
  String _formatSleep(int minutes) {
    if (minutes <= 0) return '0h 0m';
    int hours = minutes ~/ 60;
    int mins = minutes % 60;
    return '${hours}h ${mins}m';
  }

  // Helper untuk format display langkah kaki
  String _formatSteps(int steps) {
    if (steps >= 1000) {
      return '${(steps / 1000).toStringAsFixed(1)}k';
    }
    return steps.toString();
  }

  @override
  Widget build(BuildContext context) {
    const emeraldGreen = Color(0xFF006D32);
    const forestGreen = Color(0xFF004D21);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // Elegant Header
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(24, 60, 24, 40),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [emeraldGreen, forestGreen],
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(40),
                      bottomRight: Radius.circular(40),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                            child: const CircleAvatar(
                              radius: 28,
                              backgroundImage: NetworkImage('https://i.pravatar.cc/300'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Selamat Datang,', style: TextStyle(color: Colors.white70, fontSize: 14)),
                              Text('Brawidya Dharma', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const Spacer(),
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.notifications_none_rounded, color: Colors.white, size: 28),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      // Glassmorphism Status Card
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white.withOpacity(0.2)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Status Risiko GERD', style: TextStyle(color: Colors.white70, fontSize: 12)),
                                    SizedBox(height: 4),
                                    Text('RENDAH', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                GestureDetector(
                                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const GerdQPage())),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                                    child: const Text('Cek Ulang', style: TextStyle(color: emeraldGreen, fontWeight: FontWeight.bold, fontSize: 12)),
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

              // ===============================================================
              // CIRCLE HEALTH STATS (DARI HEALTH CONNECT)
              // ===============================================================
              SliverPadding(
                padding: const EdgeInsets.all(24),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildWhiteCircleStat(
                        _isLoadingHealth ? '...' : (_heartRate > 0 ? '${_heartRate.toInt()}' : '--'),
                        'BPM',
                        Icons.favorite_rounded,
                        Colors.redAccent,
                      ),
                      _buildWhiteCircleStat(
                        'Normal',
                        'Stres',
                        Icons.psychology_rounded,
                        Colors.deepPurpleAccent,
                      ),
                      _buildWhiteCircleStat(
                        _isLoadingHealth ? '...' : _formatSleep(_sleepMinutes),
                        'Tidur',
                        Icons.bedtime_rounded,
                        Colors.blueAccent,
                      ),
                      _buildWhiteCircleStat(
                        _isLoadingHealth ? '...' : _formatSteps(_steps),
                        'Langkah',
                        Icons.directions_walk_rounded,
                        Colors.orangeAccent,
                      ),
                    ],
                  ),
                ),
              ),

              // Main Services Grid
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('LAYANAN UTAMA', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54, letterSpacing: 1.5)),
                      const SizedBox(height: 32),
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 4,
                        mainAxisSpacing: 24,
                        crossAxisSpacing: 12,
                        childAspectRatio: 0.8,
                        children: [
                          _buildServiceItem('Kesehatan', Icons.insights_rounded, emeraldGreen, () => Navigator.push(context, MaterialPageRoute(builder: (context) => const HealthPage()))),
                          _buildServiceItem('Konsultasi', Icons.forum_rounded, Colors.blue, () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ConsultationPage()))),
                          _buildServiceItem('Edukasi', Icons.auto_stories_rounded, Colors.orange, () => Navigator.push(context, MaterialPageRoute(builder: (context) => const EducationPage()))),
                          _buildServiceItem('Chatbot', Icons.smart_toy_rounded, Colors.purple, () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ChatbotPage()))),
                          _buildServiceItem('Apotek', Icons.local_pharmacy_rounded, Colors.indigo),
                          _buildServiceItem('Nutrisi', Icons.restaurant_rounded, Colors.red),
                          _buildServiceItem('Komunitas', Icons.groups_rounded, Colors.teal),
                          _buildServiceItem('Lainnya', Icons.grid_view_rounded, Colors.grey),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 140)),
            ],
          ),

          // White Floating SOS Button
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
                    width: 65,
                    height: 65,
                    child: CircularProgressIndicator(
                      value: _sosController.value,
                      strokeWidth: 3,
                      backgroundColor: emeraldGreen.withOpacity(0.1),
                      valueColor: const AlwaysStoppedAnimation<Color>(emeraldGreen),
                    ),
                  ),
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: emeraldGreen.withOpacity(0.15),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        )
                      ],
                      border: Border.all(color: emeraldGreen.withOpacity(0.05), width: 1),
                    ),
                    child: const Center(
                      child: Text(
                        'SOS',
                        style: TextStyle(
                          color: emeraldGreen,
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
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

  Widget _buildWhiteCircleStat(String val, String label, IconData icon, Color iconColor) {
    return Column(
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))
            ],
          ),
          child: Center(child: Icon(icon, color: iconColor, size: 28)),
        ),
        const SizedBox(height: 10),
        Text(val, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87)),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildServiceItem(String label, IconData icon, Color color, [VoidCallback? onTap]) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 4))],
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.black87),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}