import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:gard/services/health_connect_service.dart';
import 'package:gard/pages/chatbot_page.dart';
import 'package:gard/pages/gerdq_page.dart';
import 'package:gard/pages/consultation_page.dart';
import 'package:gard/pages/education_page.dart';
import 'package:gard/pages/lifestyle_graph_page.dart';
import 'package:gard/pages/pharmacy_page.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:gard/models/history_model.dart';
import 'package:gard/services/history_service.dart';

import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:gard/constants/app_colors.dart';
import 'package:gard/services/supabase_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late AnimationController _sosController;
  bool _isSosHolding = false;
  Map<String, dynamic>? _healthSummary;
  Map<String, dynamic>? _profileData;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
    _loadHealthData();
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

  Future<void> _loadProfileData() async {
    final data = await SupabaseService.instance.getProfileData();
    if (mounted) {
      setState(() {
        _profileData = data;
      });
    }
  }

  Future<void> _loadHealthData() async {
    final healthService = HealthService();
    await healthService.init();
    
    // Cek apakah sudah ada izin
    bool hasPermission = await healthService.hasPermissions();
    if (hasPermission) {
      final summary = await healthService.getTodaySummary();
      if (mounted) {
        setState(() {
          _healthSummary = summary;
        });
      }
    } else {
      // Karena ini setelah await, kita bisa langsung panggil showDialog jika masih mounted
      if (mounted) {
        _showHealthConnectDialog(healthService);
      }
    }
  }

  void _showHealthConnectDialog(HealthService healthService) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Row(
            children: [
              const Icon(Icons.health_and_safety_rounded, color: AppColors.primary, size: 28),
              const SizedBox(width: 10),
              const Expanded(
                child: Text('Hubungkan Google Health', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.darkAccent)),
              ),
            ],
          ),
          content: const Text(
            'Hubungkan GARD dengan Google Health Connect untuk mendapatkan analisis kesehatan lambung yang lebih terpersonalisasi berdasarkan data aktivitas, detak jantung, dan pola tidur Anda.',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.5),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('NANTI', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context); // Tutup dialog
                bool authorized = await healthService.requestPermissions();
                if (authorized) {
                  final summary = await healthService.getTodaySummary();
                  if (mounted) {
                    setState(() {
                      _healthSummary = summary;
                    });
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('HUBUNGKAN', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _triggerSos() async {
    setState(() => _isSosHolding = false);
    _sosController.reset();

    final freshData = await SupabaseService.instance.getProfileData();
    final emergencyNumber = freshData?['emergency_wa'] ?? '';

    // Log SOS to history
    final userId = Supabase.instance.client.auth.currentUser?.id;
    final displayNum = (emergencyNumber.isNotEmpty && emergencyNumber != '-') ? emergencyNumber : '081280295818';
    if (userId != null) {
      final history = HistoryModel(
        historyId: 0,
        userId: userId,
        category: 'DETEKSI',
        historyDate: DateTime.now(),
        description: 'Panggilan ke $displayNum',
      );
      await HistoryService.instance.insertHistory(history);
    }

    // Send WA first — directCall suspends Dart isolate, must await before calling
    await _sendFonnteWhatsApp(emergencyNumber, freshData);

    // Call emergency number after WA
    try {
      final status = await Permission.phone.request();
      if (status.isGranted) {
        const platform = MethodChannel('com.gard.sos/call');
        if (emergencyNumber.isNotEmpty && emergencyNumber != '-') {
          await platform.invokeMethod('directCall', {'number': emergencyNumber});
        }
      }
    } catch (_) {}

    if (!mounted) return;
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

  Future<void> _sendFonnteWhatsApp(String? emergencyNumber, Map<String, dynamic>? profileData) async {
    try {
      Position? position;
      try {
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }
        if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
          position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
            timeLimit: const Duration(seconds: 5),
          );
        }
      } catch (geoErr) {
        debugPrint('Geolocator error: $geoErr. Sending message without location.');
      }

      const String token = 'ZV8uTKHBBwpK69p6MU4V';
      final String targetNumber = (emergencyNumber != null && emergencyNumber.isNotEmpty && emergencyNumber != '-') ? emergencyNumber : '081272733891';
      
      final userName = profileData?['name'] ?? 'Pengguna GARD';
      final height = profileData?['height'] ?? '-';
      final weight = profileData?['weight'] ?? '-';
      final birthDateStr = profileData?['birth_date'] ?? '';
      
      String ageStr = '-';
      if (birthDateStr.isNotEmpty && birthDateStr != '-') {
        try {
          final parts = birthDateStr.split('-');
          if (parts.length == 3) {
            final birthYear = int.parse(parts[0]);
            final age = DateTime.now().year - birthYear;
            ageStr = '$age Tahun';
          }
        } catch (_) {}
      }

      String message = '🚨 SOS DARURAT!\n\n'
          'Pengguna GARD *$userName* terdeteksi membutuhkan bantuan medis segera akibat serangan gejala lambung/GERD akut.\n\n'
          '👤 *Data Pasien:*\n'
          '- Usia: $ageStr\n'
          '- Tinggi badan: $height cm\n'
          '- Berat badan: $weight kg\n\n';
      
      if (position != null) {
        message += '📍 Lokasi Terkini:\n'
            'https://www.google.com/maps/search/?api=1&query=${position.latitude},${position.longitude}\n\n';
      } else {
        message += '📍 Lokasi Terkini: (Izin GPS tidak aktif / Gagal mendeteksi lokasi)\n\n';
      }
      
      message += '📋 Ringkasan Rekam Medis:\n'
          '- Gejala GERD Akut terdeteksi\n'
          '- Riwayat GerdQ Tersimpan';

      final response = await http.post(
        Uri.parse('https://api.fonnte.com/send'),
        headers: {'Authorization': token},
        body: {'target': targetNumber, 'message': message, 'countryCode': '62'},
      ).timeout(const Duration(seconds: 15));
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async {
              await _loadProfileData();
              await _loadHealthData();
            },
            child: CustomScrollView(
              slivers: [
              SliverToBoxAdapter(
                child: SafeArea(
                  bottom: false,
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.15),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(2.5),
                            decoration: BoxDecoration(
                              color: AppColors.softAccent.withOpacity(0.3),
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.softAccent, width: 1.5),
                            ),
                            child: CircleAvatar(
                              radius: 24,
                              backgroundColor: AppColors.softAccent,
                              child: ClipOval(
                                child: _profileData != null && (_profileData!['avatar_url'] ?? '').isNotEmpty
                                    ? Image.network(
                                        _profileData!['avatar_url'],
                                        width: 48,
                                        height: 48,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => const Icon(Icons.person, color: AppColors.primary),
                                      )
                                    : Image.asset(
                                        'assets/images/logo_full.png',
                                        width: 36,
                                        height: 36,
                                        fit: BoxFit.contain,
                                      ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Selamat Datang,',
                                    style: TextStyle(color: AppColors.softAccent, fontSize: 13)),
                                Text(_profileData?['name'] ?? 'Pengguna',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
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
                                    color: AppColors.softAccent,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                        decoration: BoxDecoration(
                          color: AppColors.darkAccent.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: Colors.white.withOpacity(0.15)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Status Risiko GERD',
                                    style: TextStyle(color: AppColors.softAccent, fontSize: 12)),
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
                                    Text((_profileData?['gerd_status'] ?? 'Belum Dites').toUpperCase(),
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
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
                                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
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
                    ],
                  ),
                ),
              ),
              ),

              // ── Quick Stats ────────────────────────────────────────────────
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                sliver: SliverToBoxAdapter(
                  child: Builder(
                    builder: (context) {
                      String bpm = '-';
                      String sleep = '-';
                      String steps = '-';

                      if (_healthSummary != null) {
                        final heartRate = _healthSummary!['heartRate'] ?? 0.0;
                        final sleepMins = _healthSummary!['sleepMinutes'] ?? 0;
                        final stepsCount = _healthSummary!['steps'] ?? 0;
                        
                        if (heartRate > 0) bpm = heartRate.toStringAsFixed(0);
                        if (sleepMins > 0) {
                          int h = sleepMins ~/ 60;
                          int m = sleepMins % 60;
                          sleep = '${h}h ${m}m';
                        }
                        if (stepsCount > 0) {
                          steps = stepsCount >= 1000 ? '${(stepsCount / 1000).toStringAsFixed(1)}k' : stepsCount.toString();
                        }
                      }

                      return Row(
                        children: [
                          Expanded(child: _buildStatCard(bpm, 'BPM', Icons.favorite_rounded, const Color(0xFFE53935))),
                          const SizedBox(width: 12),
                          Expanded(child: _buildStatCard(sleep, 'Tidur', Icons.bedtime_rounded, AppColors.primary)),
                          const SizedBox(width: 12),
                          Expanded(child: _buildStatCard(steps, 'Langkah', Icons.directions_walk_rounded, const Color(0xFFE67E22))),
                        ],
                      );
                    }
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
                      // 3+2 service grid layout
                      Wrap(
                        spacing: 16,
                        runSpacing: 20,
                        alignment: WrapAlignment.start,
                        children: [
                          _buildServiceItem('Kesehatan', Icons.favorite_outlined, const Color(0xFFE53935), const Color(0xFFFFEBEE),
                              () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LifestyleGraphPage()))),
                          _buildServiceItem('Konsultasi', Icons.person_search_rounded, const Color(0xFF1565C0), const Color(0xFFE3F2FD),
                              () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ConsultationPage()))),
                          _buildServiceItem('Edukasi', Icons.auto_stories_rounded, const Color(0xFFE67E22), const Color(0xFFFFF3E0),
                              () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EducationPage()))),
                          _buildServiceItem('Chatbot', Icons.smart_toy_rounded, AppColors.primary, AppColors.softAccent,
                              () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatbotPage()))),
                          _buildServiceItem('Apotek', Icons.local_pharmacy_rounded, const Color(0xFF6A1B9A), const Color(0xFFF3E5F5),
                              () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PharmacyPage()))),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 160)),
            ],
          ),
        ),

          Positioned(
            bottom: 100,
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
    final bool isEmpty = val == '-' || val.isEmpty;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.softAccent, width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isEmpty ? '--' : val,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: isEmpty ? AppColors.textHint : AppColors.textPrimary,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceItem(String label, IconData icon, Color iconColor, Color bgColor, [VoidCallback? onTap]) {
    return SizedBox(
      width: (MediaQuery.of(context).size.width - 40 - 32) / 3,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.12),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: AppColors.softAccent, size: 28),
                  ),
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
              letterSpacing: 0.1,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
