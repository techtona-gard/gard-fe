import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:gard_fe/pages/camera_page.dart';
import 'package:gard_fe/pages/activity_page.dart';
import 'package:gard_fe/pages/profile_page.dart';
import 'package:gard_fe/pages/login_page.dart';
import 'package:gard_fe/pages/home_page.dart';
import 'package:gard_fe/pages/history_page.dart';
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
    const emeraldGreen = Color(0xFF006D32);

    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Gard-Fe',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: emeraldGreen),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
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

  final List<Widget> _pages = [
    const HomePage(key: ValueKey('home')),
    const ActivityPage(key: ValueKey('activity')),
    const HistoryPage(key: ValueKey('history')),
    const ProfilePage(key: ValueKey('profile')),
  ];

  @override
  Widget build(BuildContext context) {
    const emeraldGreen = Color(0xFF006D32);

    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _pages[_selectedIndex],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Container(
        height: 68,
        width: 68,
        decoration: BoxDecoration(
          color: emeraldGreen,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: emeraldGreen.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            )
          ],
        ),
        child: FloatingActionButton(
          onPressed: () {
            if (cameras.isNotEmpty) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CameraPage(camera: cameras.first)),
              );
            }
          },
          elevation: 0,
          backgroundColor: Colors.transparent,
          shape: const CircleBorder(),
          child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 30),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 10,
        color: Colors.white,
        elevation: 10,
        height: 75,
        padding: EdgeInsets.zero,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(0, Icons.home_outlined, Icons.home_rounded, 'Home', emeraldGreen),
            _buildNavItem(1, Icons.calendar_month_outlined, Icons.calendar_month_rounded, 'Aktivitas', emeraldGreen),
            const SizedBox(width: 48), // Gap for FAB
            _buildNavItem(2, Icons.receipt_long_outlined, Icons.receipt_long_rounded, 'Riwayat', emeraldGreen),
            _buildNavItem(3, Icons.person_outline_rounded, Icons.person_rounded, 'Profil', emeraldGreen),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, IconData activeIcon, String label, Color activeColor) {
    final isSelected = _selectedIndex == index;
    return InkWell(
      onTap: () => setState(() => _selectedIndex = index),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: SizedBox(
        width: 65,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? activeColor : Colors.grey.shade400,
              size: 26,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? activeColor : Colors.grey.shade400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
