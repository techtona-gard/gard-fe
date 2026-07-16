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
    const emeraldGreen = Color(0xFF006D32);
    const forestGreen = Color(0xFF004D21);
    const softGreenTint = Color(0xFFE8F5E9);
    const bgColor = Color(0xFFF8F9FA);

    return Scaffold(
      backgroundColor: bgColor,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Elegant Rounded Header (Non-floating)
            Container(
              width: double.infinity,
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
              child: const Column(
                children: [
                  Text(
                    'Aktivitas & Jadwal',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Pantau rutinitas kesehatan Anda harian',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 2. Clean Monthly Calendar Card
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 15,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.only(bottom: 16),
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
                      onPageChanged: (focusedDay) {
                        _focusedDay = focusedDay;
                      },
                      calendarStyle: CalendarStyle(
                        todayDecoration: BoxDecoration(
                          color: emeraldGreen.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        todayTextStyle: const TextStyle(
                            color: emeraldGreen, fontWeight: FontWeight.bold),
                        selectedDecoration: const BoxDecoration(
                          color: emeraldGreen,
                          shape: BoxShape.circle,
                        ),
                        selectedTextStyle: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                        outsideDaysVisible: true,
                        outsideTextStyle: const TextStyle(color: Colors.black12),
                        defaultTextStyle: const TextStyle(color: Colors.black87),
                        weekendTextStyle: const TextStyle(color: Colors.black87),
                      ),
                      headerStyle: const HeaderStyle(
                        formatButtonVisible: false,
                        titleCentered: true,
                        titleTextStyle:
                            TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        headerPadding: EdgeInsets.symmetric(vertical: 16),
                        leftChevronIcon:
                            Icon(Icons.chevron_left, color: emeraldGreen),
                        rightChevronIcon:
                            Icon(Icons.chevron_right, color: emeraldGreen),
                      ),
                      daysOfWeekStyle: const DaysOfWeekStyle(
                        weekdayStyle: TextStyle(
                            color: Colors.black54,
                            fontWeight: FontWeight.bold,
                            fontSize: 12),
                        weekendStyle: TextStyle(
                            color: Colors.redAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 12),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // 3. Activity Reminders Section
                  const Text(
                    'PENGINGAT HARI INI',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.black38,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildActivityCard(
                    'Sarapan Pagi',
                    '07:30',
                    Icons.wb_sunny_outlined,
                    emeraldGreen,
                    softGreenTint,
                    () => NotificationService.scheduleEatingReminder(
                      title: 'Waktunya Sarapan! 🥣',
                      body: 'Jangan lupa sarapan sehat untuk menjaga lambungmu.',
                      secondsDelay: 6,
                    ),
                  ),
                  _buildActivityCard(
                    'Makan Siang',
                    '12:30',
                    Icons.restaurant_rounded,
                    emeraldGreen,
                    softGreenTint,
                    () => NotificationService.scheduleEatingReminder(
                      title: 'Waktunya Makan Siang! 🥗',
                      body: 'Sudah jam 12:30, yuk makan siang tepat waktu.',
                      secondsDelay: 6,
                    ),
                  ),
                  _buildActivityCard(
                    'Makan Malam',
                    '19:00',
                    Icons.nightlight_round_rounded,
                    emeraldGreen,
                    softGreenTint,
                    () => NotificationService.scheduleEatingReminder(
                      title: 'Waktunya Makan Malam! 🍲',
                      body: 'Jangan makan terlalu malam ya agar GERD tidak kambuh.',
                      secondsDelay: 6,
                    ),
                  ),

                  const SizedBox(height: 120), // Space for navigation
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityCard(String title, String time, IconData icon,
      Color accentColor, Color tintColor, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: tintColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: accentColor, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  time,
                  style: const TextStyle(
                    color: Colors.black38,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onTap,
            icon: Icon(Icons.play_circle_fill_rounded,
                color: accentColor, size: 28),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}
