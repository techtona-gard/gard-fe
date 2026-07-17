import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:gard/pages/camera_page.dart';
import 'package:gard/pages/activity_page.dart';
import 'package:gard/pages/profile_page.dart';
import 'package:gard/pages/login_page.dart';
import 'package:gard/pages/home_page.dart';
import 'package:gard/pages/history_page.dart';
import 'package:gard/services/notification_service.dart';
import 'package:gard/services/sos_service.dart';
import 'package:gard/constants/app_colors.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app_links/app_links.dart';

List<CameraDescription> cameras = [];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Supabase.initialize(
      url: const String.fromEnvironment('SUPABASE_URL', defaultValue: 'https://auqzdznuffaldjrriepv.supabase.co'),
      anonKey: const String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImF1cXpkem51ZmZhbGRqcnJpZXB2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODQxOTA3MTMsImV4cCI6MjA5OTc2NjcxM30.gIJ-1w8rAzlKuEYPSOo-DMfqZkY-h89mRHNCrZzQjLE'),
    );
  } catch (e) {
    debugPrint("Supabase initialization failed: $e");
  }

  // Setup deep link listener to handle gardapp://login-callback from Google OAuth
  _setupDeepLinks();

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

void _setupDeepLinks() {
  final appLinks = AppLinks();
  appLinks.uriLinkStream.listen((uri) async {
    debugPrint("Deep link received: $uri");
    // Let supabase_flutter handle the OAuth callback URI
    try {
      await Supabase.instance.client.auth.getSessionFromUrl(uri);
    } catch (e) {
      debugPrint("Error processing deep link: $e");
    }
  });
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Gard',
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          secondary: AppColors.midTeal,
          surface: AppColors.card,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          color: AppColors.card,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.card,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SosService.checkAndRequestLocationPermission(context);
    });
  }

  final List<Widget> _pages = [
    const HomePage(key: ValueKey('home')),
    const ActivityPage(key: ValueKey('activity')),
    const HistoryPage(key: ValueKey('history')),
    const ProfilePage(key: ValueKey('profile')),
  ];

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      extendBody: true,
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
        backgroundColor: primaryColor,
        shape: const CircleBorder(),
        child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 30),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
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
            elevation: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Expanded(child: _buildNavItem(0, Icons.home_outlined, Icons.home_rounded, 'Home', primaryColor)),
                Expanded(child: _buildNavItem(1, Icons.calendar_month_outlined, Icons.calendar_month_rounded, 'Aktivitas', primaryColor)),
                const SizedBox(width: 70),
                Expanded(child: _buildNavItem(2, Icons.receipt_long_outlined, Icons.receipt_long_rounded, 'Riwayat', primaryColor)),
                Expanded(child: _buildNavItem(3, Icons.person_outline_rounded, Icons.person_rounded, 'Profil', primaryColor)),
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
