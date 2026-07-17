import 'package:flutter/material.dart';
import 'package:gard/constants/app_colors.dart';
import 'package:gard/pages/history_detail_page.dart';
import 'package:gard/services/sos_history_service.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  static final List<HistoryItem> _historyItems = [
    const HistoryItem(
      title: 'Gejala GERD Terdeteksi',
      date: '16 Juli 2024, 08:30',
      description: 'Tingkat Keparahan: Sedang',
      category: 'DETEKSI',
      icon: Icons.warning_amber_rounded,
      color: Colors.orange,
      result: 'Kamera GARD mendeteksi 5 gejala aktif',
      notes:
          'Hindari makanan berlemak tinggi, kafein, dan alkohol. Makan dalam porsi kecil dan sering. Jangan berbaring segera setelah makan. Gunakan bantal lebih tinggi saat tidur. Konsultasikan ke dokter jika gejala berlanjut lebih dari 3 hari.',
      symptoms: [
        'Rasa terbakar di dada (heartburn)',
        'Regurgitasi asam ke tenggorokan',
        'Kesulitan menelan (disfagia)',
        'Mual setelah makan',
        'Sendawa berlebihan',
      ],
    ),
    const HistoryItem(
      title: 'Konsultasi Dokter',
      date: '14 Juli 2024, 10:00',
      description: 'dr. Andi Pratama, Sp.PD',
      category: 'KONSULTASI',
      icon: Icons.medical_services_outlined,
      color: AppColors.primary,
      doctor: 'dr. Andi Pratama, Sp.PD',
      result: 'Durasi konsultasi: 45 menit',
      notes:
          'Pasien disarankan untuk menjalani endoskopi jika gejala tidak membaik dalam 2 minggu. Resep: Omeprazole 20mg 2x sehari selama 14 hari. Pantoprazole sebagai alternatif. Hindari NSAIDs dan aspirin.',
      symptoms: [
        'Dyspepsia fungsional',
        'Refluks asam lambung ringan',
        'Perut kembung',
      ],
    ),
    const HistoryItem(
      title: 'Pemeriksaan GerdQ',
      date: '10 Juli 2024, 20:00',
      description: 'Skor GerdQ: 12/18',
      category: 'KUESIONER',
      icon: Icons.assignment_outlined,
      color: Colors.red,
      result: 'Hasil: Resiko Tinggi GERD',
      notes:
          'Skor GerdQ ≥ 8 mengindikasikan kemungkinan GERD yang signifikan. Disarankan segera berkonsultasi dengan dokter spesialis. Pemantauan pola makan harus ditingkatkan dan stres harus dikurangi.',
      symptoms: [
        'Heartburn ≥ 2 hari/minggu',
        'Regurgitasi ≥ 2 hari/minggu',
        'Gangguan tidur akibat gejala',
        'Penggunaan obat antasida tambahan',
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: SosHistoryService(),
      builder: (context, _) {
        final sosEvents = SosHistoryService().events;
        final totalRiwayat = _historyItems.length + sosEvents.length;
        return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 60, 24, 32),
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Rekam Medis',
                    style: TextStyle(
                        color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Catatan perjalanan kesehatan Anda',
                    style: TextStyle(color: Colors.white60, fontSize: 13),
                  ),
                  const SizedBox(height: 20),
                  // Stat pills row
                  Row(
                    children: [
                      _buildHeaderStatPill(null, '$totalRiwayat', 'Riwayat'),
                      const SizedBox(width: 10),
                      _buildHeaderStatPill(null, '1', 'Konsultasi'),
                      const SizedBox(width: 10),
                      _buildHeaderStatPill(Icons.favorite_rounded, 'Sedang', 'Kondisi'),
                    ],
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Filter Chips ────────────────────────────────────────
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip('Semua', true),
                        const SizedBox(width: 8),
                        _buildFilterChip('Deteksi', false),
                        const SizedBox(width: 8),
                        _buildFilterChip('Konsultasi', false),
                        const SizedBox(width: 8),
                        _buildFilterChip('Kuesioner', false),
                        const SizedBox(width: 8),
                        _buildFilterChip('SOS', false),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Container(width: 3, height: 16,
                          decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(2))),
                      const SizedBox(width: 10),
                      const Text(
                        'RIWAYAT TERBARU',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textSecondary,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // SOS events dari service (ditampilkan paling atas)
                  ...sosEvents.map((e) => _buildSosCard(context, e)),

                  ..._historyItems.map((item) => _buildHistoryCard(context, item)),

                  const SizedBox(height: 120),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  },
);
  }

  Widget _buildSosCard(BuildContext context, SosEvent event) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE53935).withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE53935).withOpacity(0.07),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFFFEBEE),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(Icons.sos_rounded, color: Color(0xFFE53935), size: 24),
        ),
        title: const Text(
          'SOS Darurat Dikirim',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.darkAccent),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(event.formattedTime,
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            const SizedBox(height: 4),
            Text('Tenaga Kesehatan: ${event.number}',
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFFFEBEE),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text('SOS',
              style: TextStyle(
                  fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFE53935))),
        ),
      ),
    );
  }

  Widget _buildHeaderStatPill(IconData? icon, String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisAlignment: icon == null ? MainAxisAlignment.center : MainAxisAlignment.start,
          children: [
            if (icon != null) ...[
              Icon(icon, color: Colors.white70, size: 14),
              const SizedBox(width: 6),
            ],
            Column(
              crossAxisAlignment: icon == null ? CrossAxisAlignment.center : CrossAxisAlignment.start,
              children: [
                Text(value,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold)),
                Text(label,
                    style: const TextStyle(color: Colors.white60, fontSize: 10)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? AppColors.primary : AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: isActive ? AppColors.primary : AppColors.softAccent, width: 1.5),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isActive ? Colors.white : AppColors.textSecondary,
          fontSize: 12,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildHistoryCard(BuildContext context, HistoryItem item) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HistoryDetailPage(item: item)),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 3))
          ],
        ),
        child: Row(
          children: [
            // Icon circle
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: item.color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(child: Icon(item.icon, color: item.color, size: 20)),
            ),
            const SizedBox(width: 12),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top row: title + category badge
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(item.title,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: AppColors.darkAccent)),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: item.color.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          item.category,
                          style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: item.color,
                              letterSpacing: 0.4),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  // Description
                  Text(item.description,
                      style: const TextStyle(
                          color: AppColors.textPrimary, fontSize: 12)),
                  const SizedBox(height: 3),
                  // Date row
                  Row(
                    children: [
                      const Icon(Icons.access_time_rounded,
                          size: 10, color: AppColors.textSecondary),
                      const SizedBox(width: 3),
                      Text(item.date,
                          style: const TextStyle(
                              color: AppColors.textSecondary, fontSize: 10)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.textSecondary, size: 18),
          ],
        ),
      ),
    );
  }
}

