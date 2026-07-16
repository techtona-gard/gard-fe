import 'package:flutter/material.dart';

void main() {
    runApp(const MyApp());
}

class MyApp extends StatelessWidget {
    const MyApp({super.key});

    @override
    Widget build(BuildContext context) {
        return MaterialApp(
            title: 'Gard Fe App',
            theme: ThemeData(
                colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
                useMaterial3: true,
            ),
            home: const MainNavigation(),
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
    // // Halaman Indeks Active
    int _selectedIndex = 0;

    // // List Konten Halaman
    final List<Widget> _pages = [
        const Center(child: Text('Halaman Home / Dashboard', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
        const Center(child: Text('Halaman Calendar Activity', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
        const Center(child: Text('Halaman Scan Kamera', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
        const Center(child: Text('Halaman Grafik Data / Chart', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
        const Center(child: Text('Halaman Pop Chat / AI', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
    ];

    // // Fungsi Pindah Halaman
    void _onItemTapped(int index) {
        setState(() {
            _selectedIndex = index;
        });
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            backgroundColor: const Color(0xfff4f4f4),

            // // Header / AppBar
            appBar: AppBar(
                title: const Text('Gard-Fe', style: TextStyle(fontWeight: FontWeight.bold)),
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                centerTitle: true,
            ),

            // // Area Konten Halaman
            body: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: _pages[_selectedIndex],
            ),

            // // Button Scan Bulat (Tengah)
            floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
            floatingActionButton: SizedBox(
                width: 65,
                height: 65,
                child: FloatingActionButton(
                    onPressed: () => _onItemTapped(2),
                    elevation: 2,
                    shape: const CircleBorder(),
                    backgroundColor: Colors.white,
                    foregroundColor: _selectedIndex == 2 ? Colors.green.shade700 : Colors.black87,
                    child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.black54, width: 1.5),
                        ),
                        child: const Icon(Icons.document_scanner_outlined, size: 24),
                    ),
                ),
            ),

            // // Curved Navigation Bar
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
                notchMargin: 8.0,
                color: Colors.white,
                elevation: 10,
                height: 75,
                padding: EdgeInsets.zero,
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                        // // Button Home
                        _buildNavItem(index: 0, icon: Icons.home_outlined, activeIcon: Icons.home, label: 'Home'),

                        // // Button Calendar
                        _buildNavItem(index: 1, icon: Icons.calendar_month_outlined, activeIcon: Icons.calendar_month, label: 'Calendar'),

                        // // Spacer Notched Tengah
                        const SizedBox(width: 48),

                        // // Button Chart
                        _buildNavItem(index: 3, icon: Icons.bar_chart_outlined, activeIcon: Icons.bar_chart, label: 'Chart'),

                        // // Button Pop Chat
                        _buildNavItem(index: 4, icon: Icons.chat_bubble_outline, activeIcon: Icons.chat_bubble, label: 'Pop Chat'),
                    ],
                ),
            ),
        );
    }

    // // Item Navigasi Kustom (Icon + Label)
    Widget _buildNavItem({
        required int index,
        required IconData icon,
        required IconData activeIcon,
        required String label,
    }) {
        final isSelected = _selectedIndex == index;
        return InkWell(
            onTap: () => _onItemTapped(index),
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            child: SizedBox(
                width: 65,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                        Icon(
                            isSelected ? activeIcon : icon,
                            color: isSelected ? Colors.green.shade700 : Colors.grey.shade500,
                            size: 26,
                        ),
                        const SizedBox(height: 4),
                        Text(
                            label,
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                color: isSelected ? Colors.green.shade700 : Colors.grey.shade500,
                            ),
                        ),
                    ],
                ),
            ),
        );
    }
}