import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:gard_fe/pages/camera_page.dart';
import 'package:gard_fe/pages/activity_page.dart';
import 'package:gard_fe/pages/profile_page.dart';
import 'package:gard_fe/pages/login_page.dart';
import 'package:gard_fe/pages/home_page.dart';
import 'package:gard_fe/services/notification_service.dart';

List<CameraDescription> cameras = [];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await NotificationService.initializeNotification();
  } catch (e) {
    debugPrint("Notification initialization failed: $e");
  }

  try {
    cameras = await availableCameras();
  } catch (e) {
    debugPrint("Camera error: $e");
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Gard-Fe',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const LoginPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const HomePage(key: ValueKey('home')),
      const ActivityPage(key: ValueKey('activity')),
      const Center(key: ValueKey('camera_placeholder'), child: Text('Halaman Camera / Scan', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
      const HistoryPage(key: ValueKey('history')),
      const ProfilePage(key: ValueKey('profile')),
    ];
  }

  void _onItemTapped(int index) {
    if (index == 2) {
      if (cameras.isNotEmpty) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CameraPage(camera: cameras.first)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kamera tidak ditemukan pada perangkat ini')),
        );
      }
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = Colors.green.shade700;

    return Scaffold(
      backgroundColor: const Color(0xfff4f4f4),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _pages[_selectedIndex],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: SizedBox(
        width: 62,
        height: 62,
        child: FloatingActionButton(
          onPressed: () => _onItemTapped(2),
          elevation: 3,
          shape: const CircleBorder(),
          backgroundColor: themeColor,
          foregroundColor: Colors.white,
          child: const Icon(Icons.camera_alt_outlined, size: 26),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        clipBehavior: Clip.antiAlias,
        shape: const AutomaticNotchedShape(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          CircleBorder(),
        ),
        notchMargin: 7.0,
        color: Colors.white,
        elevation: 10,
        height: 75,
        padding: EdgeInsets.zero,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(index: 0, icon: Icons.home_outlined, activeIcon: Icons.home, label: 'Home', activeColor: themeColor),
            _buildNavItem(index: 1, icon: Icons.calendar_month_outlined, activeIcon: Icons.calendar_month, label: 'Activity', activeColor: themeColor),
            const SizedBox(width: 44),
            _buildNavItem(index: 3, icon: Icons.receipt_long_outlined, activeIcon: Icons.receipt_long, label: 'History', activeColor: themeColor),
            _buildNavItem(index: 4, icon: Icons.person_outline, activeIcon: Icons.person, label: 'Profile', activeColor: themeColor),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required Color activeColor,
  }) {
    final isSelected = _selectedIndex == index;

    return InkWell(
      onTap: () => _onItemTapped(index),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: SizedBox(
        width: 65,
        height: 75,
        child: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              top: isSelected ? 22 : 14,
              child: Icon(
                isSelected ? activeIcon : icon,
                color: isSelected ? activeColor : Colors.grey.shade400,
                size: isSelected ? 30 : 25,
              ),
            ),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              bottom: isSelected ? 0 : 12,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 150),
                opacity: isSelected ? 0.0 : 1.0,
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade500,
                  ),
                  maxLines: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeColor = Colors.green.shade700;
    return Scaffold(
      backgroundColor: const Color(0xfff4f4f4),
      appBar: AppBar(
        title: const Text('Rekam Medis & History', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: themeColor,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildHistoryItem(
              context,
              'Gejala GERD Terdeteksi',
              '16 Juli 2024, 08:30',
              'Tingkat Keparahan: Sedang',
              Icons.warning_amber_rounded,
              Colors.orange,
            ),
            _buildHistoryItem(
              context,
              'Konsultasi Dokter',
              '14 Juli 2024, 10:00',
              'Dokter: dr. Andi (Sp.PD)',
              Icons.medical_services_outlined,
              Colors.blue,
            ),
            _buildHistoryItem(
              context,
              'Pemeriksaan GerdQ',
              '10 Juli 2024, 20:00',
              'Hasil: Resiko Tinggi',
              Icons.assignment_outlined,
              Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryItem(BuildContext context, String title, String date, String desc, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(date, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 4),
                Text(desc, style: const TextStyle(color: Colors.black54, fontSize: 13)),
              ],
            ),
          ),
          TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              backgroundColor: Colors.green.shade700,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            child: const Text('DETAIL', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
