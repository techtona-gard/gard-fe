import 'package:flutter/material.dart';
import 'package:gard/constants/app_colors.dart';

/// Model data untuk item riwayat
class HistoryItem {
  final String title;
  final String date;
  final String description;
  final String category;
  final IconData icon;
  final Color color;
  final String? doctor;
  final String? result;
  final String? notes;
  final List<String> symptoms;

  const HistoryItem({
    required this.title,
    required this.date,
    required this.description,
    required this.category,
    required this.icon,
    required this.color,
    this.doctor,
    this.result,
    this.notes,
    this.symptoms = const [],
  });
}

class HistoryDetailPage extends StatelessWidget {
  final HistoryItem item;

  const HistoryDetailPage({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // ── Header ─────────────────────────────────────────────────────
          Container(
            padding: EdgeInsets.fromLTRB(
                16, MediaQuery.of(context).padding.top + 16, 24, 32),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [item.color, item.color.withOpacity(0.7)],
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(36),
                bottomRight: Radius.circular(36),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: Colors.white, size: 20),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withOpacity(0.3)),
                      ),
                      child: Text(
                        item.category,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(item.icon, color: Colors.white, size: 28),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        item.title,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.2),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today_rounded,
                              color: Colors.white70, size: 13),
                          const SizedBox(width: 6),
                          Text(item.date,
                              style: const TextStyle(color: Colors.white70, fontSize: 13)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Content ────────────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status Badge
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: item.color.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: item.color.withOpacity(0.15)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: item.color.withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(item.icon, color: item.color, size: 24),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.description,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: item.color),
                              ),
                              if (item.result != null) ...[
                                const SizedBox(height: 4),
                                Text(item.result!,
                                    style: const TextStyle(
                                        color: AppColors.textSecondary, fontSize: 12)),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── Dokter (jika ada) ─────────────────────────────────
                  if (item.doctor != null) ...[
                    _buildDetailCard(
                      title: 'Dokter yang Menangani',
                      icon: Icons.person_pin_rounded,
                      content: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: const BoxDecoration(
                                  color: AppColors.softAccent,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.medical_services_rounded,
                                    color: AppColors.primary, size: 20),
                              ),
                              const SizedBox(width: 14),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item.doctor!,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                          color: AppColors.darkAccent)),
                                  const Text('Spesialis Penyakit Dalam',
                                      style: TextStyle(
                                          color: AppColors.textSecondary, fontSize: 12)),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // ── Gejala (jika ada) ─────────────────────────────────
                  if (item.symptoms.isNotEmpty) ...[
                    _buildDetailCard(
                      title: 'Gejala yang Terdeteksi',
                      icon: Icons.list_alt_rounded,
                      content: Column(
                        children: item.symptoms
                            .map((symptom) => Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          color: item.color,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          symptom,
                                          style: const TextStyle(
                                              color: AppColors.textPrimary,
                                              fontSize: 14,
                                              height: 1.4),
                                        ),
                                      ),
                                    ],
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // ── Catatan ───────────────────────────────────────────
                  if (item.notes != null) ...[
                    _buildDetailCard(
                      title: 'Catatan & Rekomendasi',
                      icon: Icons.note_alt_outlined,
                      content: Text(
                        item.notes!,
                        style: const TextStyle(
                            color: AppColors.textPrimary, fontSize: 14, height: 1.6),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // ── Timeline ──────────────────────────────────────────
                  _buildDetailCard(
                    title: 'Timeline Kejadian',
                    icon: Icons.timeline_rounded,
                    content: Column(
                      children: [
                        _buildTimelineItem('08:00', 'Gejala mulai terdeteksi', true),
                        _buildTimelineItem('08:15', 'Data dicatat sistem GARD', true),
                        _buildTimelineItem('08:30', 'Notifikasi terkirim ke dokter', true),
                        _buildTimelineItem('09:00', 'Tindak lanjut dijadwalkan', false),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ── Aksi ──────────────────────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.share_rounded, size: 18),
                          label: const Text('Bagikan'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: const BorderSide(color: AppColors.softAccent, width: 1.5),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.download_rounded, size: 18),
                          label: const Text('Unduh PDF'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailCard({
    required String title,
    required IconData icon,
    required Widget content,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 16),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary,
                    letterSpacing: 0.8),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Divider(color: AppColors.softAccent),
          const SizedBox(height: 8),
          content,
        ],
      ),
    );
  }

  Widget _buildTimelineItem(String time, String event, bool isDone) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: isDone ? AppColors.primary : AppColors.softAccent,
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: isDone ? AppColors.primary : AppColors.textHint, width: 2),
                ),
              ),
              Container(width: 1.5, height: 26, color: AppColors.softAccent),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(time,
                    style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(event,
                    style: TextStyle(
                        color: isDone ? AppColors.textPrimary : AppColors.textHint,
                        fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
