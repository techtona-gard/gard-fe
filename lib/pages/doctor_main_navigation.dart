import 'package:flutter/material.dart';
import 'package:gard_fe/pages/doctor_home_page.dart';
import 'package:gard_fe/pages/doctor_schedule_page.dart';
import 'package:gard_fe/pages/doctor_profile_page.dart';

class DoctorMainNavigation extends StatefulWidget {
  const DoctorMainNavigation({super.key});

  @override
  State<DoctorMainNavigation> createState() => _DoctorMainNavigationState();
}

class _DoctorMainNavigationState extends State<DoctorMainNavigation> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const DoctorHomePage(),
    const DoctorSchedulePage(),
    const DoctorProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    const emeraldGreen = Color(0xFF006D32);

    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5))]),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: (index) {
              setState(() => _selectedIndex = index);
            },
            selectedItemColor: emeraldGreen,
            unselectedItemColor: Colors.grey.shade400,
            showUnselectedLabels: true,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: 'Dashboard'),
              BottomNavigationBarItem(icon: Icon(Icons.calendar_month_rounded), label: 'Jadwal'),
              BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Profil'),
            ],
          ),
        ),
      ),
    );
  }
}
