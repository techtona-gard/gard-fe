import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class DoctorSchedulePage extends StatefulWidget {
  const DoctorSchedulePage({super.key});

  @override
  State<DoctorSchedulePage> createState() => _DoctorSchedulePageState();
}

class _DoctorSchedulePageState extends State<DoctorSchedulePage> {
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
    const bgColor = Color(0xFFF8F9FA);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text('Jadwal Praktik', 
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Calendar Card (Sama seperti gaya pasien)
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
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
                  rowHeight: 52,
                  calendarStyle: CalendarStyle(
                    todayDecoration: BoxDecoration(
                      color: emeraldGreen.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    todayTextStyle: const TextStyle(
                      color: emeraldGreen, 
                      fontWeight: FontWeight.bold
                    ),
                    selectedDecoration: const BoxDecoration(
                      color: emeraldGreen,
                      shape: BoxShape.circle,
                    ),
                    selectedTextStyle: const TextStyle(
                      color: Colors.white, 
                      fontWeight: FontWeight.bold
                    ),
                    outsideDaysVisible: false,
                    defaultTextStyle: const TextStyle(color: Colors.black87),
                    weekendTextStyle: const TextStyle(color: Colors.black87),
                  ),
                  headerStyle: const HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                    titleTextStyle: TextStyle(
                      fontWeight: FontWeight.bold, 
                      fontSize: 16,
                      color: Colors.black87
                    ),
                    headerPadding: EdgeInsets.symmetric(vertical: 16),
                    leftChevronIcon: Icon(Icons.chevron_left_rounded, color: emeraldGreen),
                    rightChevronIcon: Icon(Icons.chevron_right_rounded, color: emeraldGreen),
                  ),
                  daysOfWeekStyle: const DaysOfWeekStyle(
                    weekdayStyle: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold, fontSize: 12),
                    weekendStyle: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // 2. Timeline Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'DAFTAR JANJI TEMU',
                    style: TextStyle(
                      fontSize: 12, 
                      fontWeight: FontWeight.bold, 
                      color: Colors.black38, 
                      letterSpacing: 1.2
                    ),
                  ),
                  Icon(Icons.tune_rounded, size: 20, color: Colors.grey.shade400),
                ],
              ),
              const SizedBox(height: 20),

              // Daftar Item (Manual list agar scroll mengikuti scroll utama)
              _buildScheduleItem('09:00', 'Siti Aminah', 'Telekonsultasi', true),
              _buildScheduleItem('10:30', 'Reza Rahadian', 'Tatap Muka', true),
              _buildScheduleItem('13:00', 'Wulan Sari', 'Telekonsultasi', false),
              _buildScheduleItem('15:00', 'Ahmad Dani', 'Tatap Muka', false),
              
              const SizedBox(height: 100), // Space for bottom nav
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScheduleItem(String time, String patient, String type, bool isCompleted) {
    const emeraldGreen = Color(0xFF006D32);
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: emeraldGreen.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              time,
              style: const TextStyle(
                fontWeight: FontWeight.bold, 
                color: emeraldGreen,
                fontSize: 14
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  patient,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold, 
                    fontSize: 16,
                    color: Color(0xFF2D3142)
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  type,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          Icon(
            isCompleted ? Icons.check_circle_rounded : Icons.arrow_forward_ios_rounded,
            color: isCompleted ? emeraldGreen : Colors.grey.shade300,
            size: isCompleted ? 24 : 16,
          ),
        ],
      ),
    );
  }
}
