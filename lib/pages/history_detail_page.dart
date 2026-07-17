import 'package:flutter/material.dart';
import 'package:gard/constants/app_colors.dart';
import 'package:gard/models/history_model.dart';
import 'package:intl/intl.dart';

class HistoryDetailPage extends StatelessWidget {
  final HistoryModel item;

  const HistoryDetailPage({super.key, required this.item});

  // Helper untuk menentukan icon & warna
  IconData _getCategoryIcon() {
    switch (item.category) {
      case 'DETEKSI':
        return Icons.warning_amber_rounded;
      case 'KONSULTASI':
        return Icons.medical_services_outlined;
      case 'KUESIONER':
        return Icons.assignment_outlined;
      case 'SOS':
        return Icons.sos_rounded;
      default:
        return Icons.history_rounded;
    }
  }

  String _getTitle() {
    switch (item.category) {
      case 'DETEKSI':
        return 'Deteksi Kondisi GERD';
      case 'KONSULTASI':
        return 'Konsultasi Medis';
      case 'KUESIONER':
        return 'Hasil Pemeriksaan GerdQ';
      case 'SOS':
        return 'Riwayat Panggilan SOS Darurat';
      default:
        return 'Detail Riwayat';
    }
  }

  String _getFormattedDate() {
    return DateFormat('dd MMMM yyyy, HH:mm').format(item.historyDate);
  }

  @override
  Widget build(BuildContext context) {
    final icon = _getCategoryIcon();
    final title = _getTitle();
    
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // ── Header ─────────────────────────────────────────────────────
          Container(
            padding: EdgeInsets.fromLTRB(
                16, MediaQuery.of(context).padding.top + 16, 24, 24),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: AppColors.softAccent, width: 1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: AppColors.darkAccent, size: 20),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        item.category,
                        style: const TextStyle(
                            color: AppColors.primary,
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
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(icon, color: AppColors.primary, size: 24),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              title,
                              style: const TextStyle(
                                  color: AppColors.darkAccent,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.2),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today_rounded,
                              color: AppColors.textSecondary, size: 14),
                          const SizedBox(width: 6),
                          Text(_getFormattedDate(),
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
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
                  if (item.description != null && item.description!.isNotEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.softAccent),
                      ),
                      child: Text(
                        item.description!,
                        style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textPrimary, height: 1.5),
                      ),
                    ),

                  // ── Dokter (jika ada) ─────────────────────────────────
                  if (item.doctorName != null) ...[
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
                                  Text(item.doctorName!,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                          color: AppColors.darkAccent)),
                                  if (item.doctorTitle != null)
                                    Text(item.doctorTitle!,
                                        style: const TextStyle(
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

                  if (item.gerdqScore != null) ...[
                    _buildDetailCard(
                      title: 'Skor GerdQ',
                      icon: Icons.assignment_rounded,
                      content: Row(
                        children: [
                          Text('${item.gerdqScore} / 18',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: AppColors.primary)),
                          const SizedBox(width: 10),
                          Text(item.gerdqScore! >= 8 ? 'Resiko Tinggi GERD' : 'Resiko Rendah',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: item.gerdqScore! >= 8 ? Colors.red : Colors.green)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  
                  if (item.severityLevel != null) ...[
                    _buildDetailCard(
                      title: 'Tingkat Keparahan',
                      icon: Icons.monitor_heart_rounded,
                      content: Text(
                        item.severityLevel!,
                        style: const TextStyle(
                            color: AppColors.darkAccent, fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // ── Timeline ──────────────────────────────────────────
                  _buildDetailCard(
                    title: 'Waktu Perekaman',
                    icon: Icons.timeline_rounded,
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTimelineItem(_getFormattedDate(), 'Data direkam ke dalam sistem GARD', true),
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
