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
      extendBody: true, // Allows content to flow behind the notch
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _pages[_selectedIndex],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (cameras.isNotEmpty) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CameraPage(camera: cameras.first)),
            );
          }
        },
        elevation: 8,
        backgroundColor: emeraldGreen,
        shape: const CircleBorder(),
        child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 30),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          child: BottomAppBar(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            height: 80,
            color: Colors.white,
            shape: const CircularNotchedRectangle(),
            notchMargin: 10,
            elevation: 0, // Elevation is handled by the Container's shadow
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Expanded(child: _buildNavItem(0, Icons.home_outlined, Icons.home_rounded, 'Home', emeraldGreen)),
                Expanded(child: _buildNavItem(1, Icons.calendar_month_outlined, Icons.calendar_month_rounded, 'Aktivitas', emeraldGreen)),
                const SizedBox(width: 70), // Sufficient space for the sunken SOS button
                Expanded(child: _buildNavItem(2, Icons.receipt_long_outlined, Icons.receipt_long_rounded, 'Riwayat', emeraldGreen)),
                Expanded(child: _buildNavItem(3, Icons.person_outline_rounded, Icons.person_rounded, 'Profil', emeraldGreen)),
              ],
            ),
          ),
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
    );
  }
}
