import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:gard_fe/services/notification_service.dart';

class ActivityPage extends StatefulWidget {
  const ActivityPage({super.key});

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = Colors.green.shade700;

    return Scaffold(
      backgroundColor: const Color(0xfff4f4f4),
      appBar: AppBar(
        title: const Text('Aktivitas & Jadwal', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: themeColor,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Calendar Card
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TableCalendar(
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  },
                  calendarStyle: CalendarStyle(
                    todayDecoration: BoxDecoration(color: themeColor.withOpacity(0.3), shape: BoxShape.circle),
                    selectedDecoration: BoxDecoration(color: themeColor, shape: BoxShape.circle),
                  ),
                  headerStyle: const HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Daily Reminders Card (Tap to trigger Alarm)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'PENGINGAT HARI INI (TAP UNTUK TES ALARM)',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    _buildActivityItem('Sarapan Pagi', '07:30', Icons.wb_sunny_outlined, Colors.orange, () {
                      NotificationService.scheduleEatingReminder(
                        title: 'Waktunya Sarapan! 🥣',
                        body: 'Jangan lupa sarapan sehat untuk menjaga lambungmu.',
                        secondsDelay: 3,
                      );
                    }),
                    _buildActivityItem('Makan Siang', '12:30', Icons.restaurant, Colors.green, () {
                      NotificationService.scheduleEatingReminder(
                        title: 'Waktunya Makan Siang! 🥗',
                        body: 'Sudah jam 12:30, yuk makan siang tepat waktu.',
                        secondsDelay: 3,
                      );
                    }),
                    _buildActivityItem('Makan Malam', '19:00', Icons.nightlight_round, Colors.blue, () {
                      NotificationService.scheduleEatingReminder(
                        title: 'Waktunya Makan Malam! 🍲',
                        body: 'Jangan makan terlalu malam ya agar GERD tidak kambuh.',
                        secondsDelay: 3,
                      );
                    }),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Consultation Card (Changed to Green)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'JADWAL KONSULTASI',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50, // Changed to Green
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.green.shade100),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.video_call, color: themeColor),
                          const SizedBox(width: 16),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Konsultasi Dokter Andi', style: TextStyle(fontWeight: FontWeight.bold)),
                                Text('Google Meet • 10:00 - 11:00', style: TextStyle(fontSize: 12, color: Colors.black54)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivityItem(String title, String time, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xfff8f9fa),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  Text(time, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.play_circle_outline, color: Colors.green, size: 24),
          ],
        ),
      ),
    );
  }
}
