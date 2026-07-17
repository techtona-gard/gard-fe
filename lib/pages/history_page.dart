import 'package:flutter/material.dart';
import 'package:gard/constants/app_colors.dart';
import 'package:gard/pages/history_detail_page.dart';
import 'package:gard/models/history_model.dart';
import 'package:gard/services/history_service.dart';
import 'package:intl/intl.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  String _selectedFilter = 'Semua';

  // Helper untuk warna ikon berdasarkan kategori
  IconData _getCategoryIcon(String category) {
    switch (category) {
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

  String _getTitle(String category) {
    switch (category) {
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

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<HistoryModel>>(
      future: HistoryService.instance.fetchHistory(),
      builder: (context, snapshot) {
        final List<HistoryModel> historyItems = snapshot.data ?? [];
        final isLoading = snapshot.connectionState == ConnectionState.waiting;
        
        final totalRiwayat = historyItems.length;
            
            return Scaffold(
              backgroundColor: AppColors.background,
              body: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Header ──────────────────────────────────────────────────
                    SafeArea(
                      bottom: false,
                      child: Container(
                        width: double.infinity,
                        margin: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.15),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Rekam Medis',
                            style: TextStyle(
                                color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Catatan perjalanan kesehatan Anda',
                            style: TextStyle(color: AppColors.softAccent, fontSize: 13),
                          ),
                          const SizedBox(height: 20),
                          // Stat pills row
                          Row(
                            children: [
                              _buildHeaderStatPill(null, '$totalRiwayat', 'Riwayat'),
                              const SizedBox(width: 10),
                              _buildHeaderStatPill(null, '0', 'Konsultasi'),
                              const SizedBox(width: 10),
                              _buildHeaderStatPill(null, 'Sedang', 'Kondisi'),
                            ],
                          ),
                        ],
                      ),
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
                                _buildFilterChip('Semua'),
                                const SizedBox(width: 8),
                                _buildFilterChip('Deteksi'),
                                const SizedBox(width: 8),
                                _buildFilterChip('Konsultasi'),
                                const SizedBox(width: 8),
                                _buildFilterChip('Kuesioner'),
                                const SizedBox(width: 8),
                                _buildFilterChip('SOS'),
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

                          if (isLoading)
                            const Center(child: Padding(
                              padding: EdgeInsets.all(20.0),
                              child: CircularProgressIndicator(color: AppColors.primary),
                            ))
                          else if (historyItems.where((item) {
                            final isSos = item.category.toUpperCase() == 'SOS' || 
                                (item.category.toUpperCase() == 'DETEKSI' && item.description != null && item.description!.contains('Panggilan ke'));
                            if (_selectedFilter == 'Semua') return true;
                            if (_selectedFilter == 'SOS') return isSos;
                            if (_selectedFilter == 'Deteksi') return item.category.toUpperCase() == 'DETEKSI' && !isSos;
                            return item.category.toUpperCase() == _selectedFilter.toUpperCase();
                          }).isEmpty)
                            Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary.withOpacity(0.12),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    )
                                  ],
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.history_rounded,
                                      color: AppColors.softAccent,
                                      size: 36,
                                    ),
                                    const SizedBox(height: 12),
                                    const Text(
                                      'Belum ada riwayat medis.',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    const Text(
                                      'Aktivitas rekam medis Anda akan muncul di sini',
                                      style: TextStyle(
                                        color: AppColors.softAccent,
                                        fontSize: 11,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            )
                          else
                            ...historyItems
                                .where((item) {
                                  final isSos = item.category.toUpperCase() == 'SOS' || 
                                      (item.category.toUpperCase() == 'DETEKSI' && item.description != null && item.description!.contains('Panggilan ke'));
                                  if (_selectedFilter == 'Semua') return true;
                                  if (_selectedFilter == 'SOS') return isSos;
                                  if (_selectedFilter == 'Deteksi') return item.category.toUpperCase() == 'DETEKSI' && !isSos;
                                  return item.category.toUpperCase() == _selectedFilter.toUpperCase();
                                })
                                .map((item) {
                                  final isSos = item.category.toUpperCase() == 'SOS' || 
                                      (item.category.toUpperCase() == 'DETEKSI' && item.description != null && item.description!.contains('Panggilan ke'));
                                  if (isSos) {
                                    return _buildSosCard(context, item);
                                  }
                                  return _buildHistoryCard(context, item);
                                }),

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

  Widget _buildSosCard(BuildContext context, HistoryModel event) {
    // Format timestamp manually since it's a HistoryModel
    final d = event.historyDate;
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    final formattedTime = '${d.day} ${months[d.month - 1]} ${d.year}, '
        '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.07),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        leading: Container(
          width: 46,
          height: 46,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: const Center(child: Icon(Icons.sos_rounded, color: AppColors.softAccent, size: 20)),
        ),
        title: const Text(
          'SOS Darurat Dikirim',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.darkAccent),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(formattedTime,
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            const SizedBox(height: 4),
            Text(event.description ?? 'Panggilan Darurat',
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text('SOS',
              style: TextStyle(
                  fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary)),
        ),
      ),
    );
  }

  Widget _buildHeaderStatPill(IconData? icon, String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        decoration: BoxDecoration(
          color: AppColors.darkAccent.withOpacity(0.4),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.15)),
        ),
        child: Row(
          mainAxisAlignment: icon == null ? MainAxisAlignment.center : MainAxisAlignment.start,
          children: [
            if (icon != null) ...[
              Icon(icon, color: AppColors.softAccent, size: 14),
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
                    style: const TextStyle(color: AppColors.softAccent, fontSize: 10)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    bool isActive = _selectedFilter == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = label;
        });
      },
      child: Container(
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
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryCard(BuildContext context, HistoryModel item) {
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.softAccent),
          boxShadow: [
            BoxShadow(
                color: AppColors.primary.withOpacity(0.04),
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
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: Center(child: Icon(_getCategoryIcon(item.category), color: AppColors.softAccent, size: 20)),
            ),
            const SizedBox(width: 14),
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
                        child: Text(_getTitle(item.category),
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: AppColors.darkAccent)),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          item.category,
                          style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                              letterSpacing: 0.4),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Description
                  if (item.description != null)
                    Text(item.description!,
                        style: const TextStyle(
                            color: AppColors.textPrimary, fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 6),
                  // Date row
                  Row(
                    children: [
                      const Icon(Icons.access_time_rounded,
                          size: 11, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(DateFormat('dd MMMM yyyy, HH:mm').format(item.historyDate),
                          style: const TextStyle(
                              color: AppColors.textSecondary, fontSize: 11)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

