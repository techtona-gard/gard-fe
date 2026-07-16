import 'package:flutter/material.dart';
import 'package:gard_fe/pages/chatbot_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late AnimationController _sosController;
  bool _isSosHolding = false;

  @override
  void initState() {
    super.initState();
    _sosController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..addListener(() {
        setState(() {});
      })..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _triggerSos();
        }
      });
  }

  @override
  void dispose() {
    _sosController.dispose();
    super.dispose();
  }

  void _triggerSos() {
    setState(() => _isSosHolding = false);
    _sosController.reset();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('SOS DIKIRIM!'),
        content: const Text('Bantuan darurat dan riwayat medis telah dikirim ke kontak terdekat.'),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const emeraldGreen = Color(0xFF006D32);
    const forestGreen = Color(0xFF004D21);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: CustomScrollView(
        slivers: [
          // Elegant Header with Profile and GERD Status
          SliverToBoxAdapter(
            child: Container(
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
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                        child: const CircleAvatar(
                          radius: 28,
                          backgroundImage: NetworkImage('https://i.pravatar.cc/300'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Selamat Datang,', style: TextStyle(color: Colors.white70, fontSize: 14)),
                          Text('Brawidya Dharma', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.notifications_none_rounded, color: Colors.white, size: 28),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  // GERD Risk Badge Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Status Risiko GERD', style: TextStyle(color: Colors.white70, fontSize: 12)),
                            SizedBox(height: 4),
                            Text('RENDAH', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                          child: const Text('Cek Ulang', style: TextStyle(color: emeraldGreen, fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Mini Stats Section
          SliverPadding(
            padding: const EdgeInsets.all(24),
            sliver: SliverToBoxAdapter(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildMiniStat('80', 'BPM', Icons.favorite_rounded, Colors.redAccent),
                  _buildMiniStat('Normal', 'Stres', Icons.psychology_rounded, Colors.deepPurpleAccent),
                  _buildMiniStat('7h 20m', 'Tidur', Icons.bedtime_rounded, Colors.blueAccent),
                  _buildMiniStat('4.2k', 'Langkah', Icons.directions_walk_rounded, Colors.orangeAccent),
                ],
              ),
            ),
          ),

          // Main Services Grid (BRImo Style)
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('LAYANAN UTAMA', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54, letterSpacing: 1.2)),
                  const SizedBox(height: 20),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 4,
                    mainAxisSpacing: 24,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.8,
                    children: [
                      _buildServiceItem('Gejala', Icons.medical_information_rounded, emeraldGreen),
                      _buildServiceItem('Edukasi', Icons.auto_stories_rounded, Colors.blue),
                      _buildServiceItem('Chat Dokter', Icons.forum_rounded, Colors.orange),
                      _buildServiceItem('Nutrisi', Icons.restaurant_rounded, Colors.red),
                      _buildServiceItem('Komunitas', Icons.groups_rounded, Colors.teal),
                      _buildServiceItem('Apotek', Icons.local_pharmacy_rounded, Colors.indigo),
                      _buildServiceItem('Checkup', Icons.fact_check_rounded, Colors.brown),
                      _buildServiceItem('Lainnya', Icons.grid_view_rounded, Colors.grey),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // SOS Section
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 40, 24, 120),
            sliver: SliverToBoxAdapter(
              child: Center(
                child: GestureDetector(
                  onLongPressStart: (_) {
                    setState(() => _isSosHolding = true);
                    _sosController.forward();
                  },
                  onLongPressEnd: (_) {
                    setState(() => _isSosHolding = false);
                    if (_sosController.status != AnimationStatus.completed) _sosController.reverse();
                  },
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 130,
                        height: 130,
                        child: CircularProgressIndicator(
                          value: _sosController.value,
                          strokeWidth: 6,
                          backgroundColor: Colors.red.withOpacity(0.1),
                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.red),
                        ),
                      ),
                      Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: Colors.red.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))
                          ],
                        ),
                        child: const Center(
                          child: Text('SOS', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 2)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      
      // Modern Pop-Out Chatbot
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 90), // Offset from Navbar
        child: GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ChatbotPage())),
          child: Container(
            width: 65,
            height: 65,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F3F4),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 15, offset: const Offset(0, 8))
              ],
            ),
            child: const Center(
              child: Text('G', style: TextStyle(color: emeraldGreen, fontSize: 32, fontWeight: FontWeight.bold)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMiniStat(String val, String label, IconData icon, Color color) {
    return Container(
      width: 75,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(val, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildServiceItem(String label, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 4))],
          ),
          child: Icon(icon, color: color, size: 26),
        ),
        const SizedBox(height: 10),
        Text(
          label,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.black87),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
