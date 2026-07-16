import 'package:flutter/material.dart';

class DoctorSchedulePage extends StatefulWidget {
  const DoctorSchedulePage({super.key});

  @override
  State<DoctorSchedulePage> createState() => _DoctorSchedulePageState();
}

class _DoctorSchedulePageState extends State<DoctorSchedulePage> {
  int _selectedDateIndex = 2; // Assuming today is Wednesday

  final List<Map<String, String>> _dates = [
    {'day': 'Sen', 'date': '21'},
    {'day': 'Sel', 'date': '22'},
    {'day': 'Rab', 'date': '23'},
    {'day': 'Kam', 'date': '24'},
    {'day': 'Jum', 'date': '25'},
    {'day': 'Sab', 'date': '26'},
    {'day': 'Min', 'date': '27'},
  ];

  @override
  Widget build(BuildContext context) {
    const emeraldGreen = Color(0xFF006D32);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Jadwal Praktik', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Horizontal Calendar Section
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: _dates.asMap().entries.map((entry) {
                  int idx = entry.key;
                  var item = entry.value;
                  bool isSelected = _selectedDateIndex == idx;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedDateIndex = idx),
                    child: Container(
                      margin: const EdgeInsets.only(right: 12),
                      width: 60,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: isSelected ? emeraldGreen : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: isSelected ? [BoxShadow(color: emeraldGreen.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))] : [],
                      ),
                      child: Column(
                        children: [
                          Text(item['day']!, style: TextStyle(color: isSelected ? Colors.white70 : Colors.grey, fontSize: 12)),
                          const SizedBox(height: 8),
                          Text(item['date']!, style: TextStyle(color: isSelected ? Colors.white : Colors.black87, fontWeight: FontWeight.bold, fontSize: 18)),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // Timeline / Appointments Section
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                const Text('DAFTAR JANJI TEMU', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey, letterSpacing: 1.2)),
                const SizedBox(height: 20),
                _buildScheduleItem('09:00 - 09:30', 'Siti Aminah', 'Telekonsultasi', true),
                _buildScheduleItem('10:30 - 11:00', 'Reza Rahadian', 'Tatap Muka', true),
                _buildScheduleItem('13:00 - 13:30', 'Wulan Sari', 'Telekonsultasi', false),
                _buildScheduleItem('15:00 - 15:30', 'Ahmad Dani', 'Tatap Muka', false),
              ],
            ),
          ),
        ],
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
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(time, style: const TextStyle(fontWeight: FontWeight.bold, color: emeraldGreen)),
              const SizedBox(height: 4),
              Text(type, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(patient, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(isCompleted ? Icons.check_circle_rounded : Icons.pending_actions_rounded, 
                      size: 14, color: isCompleted ? emeraldGreen : Colors.orange),
                    const SizedBox(width: 4),
                    Text(isCompleted ? 'Selesai' : 'Mendatang', 
                      style: TextStyle(color: isCompleted ? emeraldGreen : Colors.orange, fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
        ],
      ),
    );
  }
}
