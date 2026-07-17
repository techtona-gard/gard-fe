import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gard/constants/app_colors.dart';

// ── Model ─────────────────────────────────────────────────────────────────────

class DoctorModel {
  final String id;
  final String name;
  final String specialty;
  final String price;
  final int priceNum;
  final String rating;
  final String reviews;
  final String avatar;
  final String bio;
  final List<String> education;
  final List<String> availableSlots;
  final List<String> consultTypes;

  const DoctorModel({
    required this.id,
    required this.name,
    required this.specialty,
    required this.price,
    required this.priceNum,
    required this.rating,
    required this.reviews,
    required this.avatar,
    required this.bio,
    required this.education,
    required this.availableSlots,
    required this.consultTypes,
  });
}

final List<DoctorModel> allDoctors = const [
  DoctorModel(
    id: 'd1',
    name: 'Dr. Andi Wijaya, Sp.PD-KGEH',
    specialty: 'Spesialis Gastroentero-Hepatologi',
    price: 'Rp 85.000',
    priceNum: 85000,
    rating: '4.9',
    reviews: '150',
    avatar: 'https://i.pravatar.cc/150?img=11',
    bio:
        'Dokter Andi Wijaya adalah Spesialis Penyakit Dalam dengan keahlian khusus di bidang Gastroentero-Hepatologi. Beliau memiliki pengalaman lebih dari 12 tahun dalam menangani kasus GERD, tukak lambung, dan gangguan hepar.',
    education: [
      'S1 Kedokteran - Universitas Indonesia',
      'Sp.PD - RSCM Jakarta',
      'Fellowship Gastroenterologi - NUS Singapore',
    ],
    availableSlots: ['08:00', '09:00', '10:30', '14:00', '15:30', '16:00'],
    consultTypes: ['Chat', 'Video Call'],
  ),
  DoctorModel(
    id: 'd2',
    name: 'Dr. Sarah Quinn, Sp.PD',
    specialty: 'Spesialis Penyakit Dalam (GERD Expert)',
    price: 'Rp 70.000',
    priceNum: 70000,
    rating: '4.8',
    reviews: '98',
    avatar: 'https://i.pravatar.cc/150?img=5',
    bio:
        'Dokter Sarah Quinn dikenal luas sebagai pakar GERD di Indonesia. Dengan pendekatan holistik yang menggabungkan terapi medis dan pola hidup, beliau membantu ratusan pasien meraih hidup bebas GERD.',
    education: [
      'S1 Kedokteran - Universitas Airlangga',
      'Sp.PD - RSUD Dr. Soetomo',
    ],
    availableSlots: ['09:00', '11:00', '13:00', '15:00'],
    consultTypes: ['Chat', 'Video Call'],
  ),
  DoctorModel(
    id: 'd3',
    name: 'Dr. Budi Santoso, Sp.PD',
    specialty: 'Konsultan Lambung & Pencernaan',
    price: 'Rp 95.000',
    priceNum: 95000,
    rating: '5.0',
    reviews: '210',
    avatar: 'https://i.pravatar.cc/150?img=12',
    bio:
        'Dengan pengalaman lebih dari 15 tahun, Dr. Budi Santoso adalah konsultan terpercaya untuk masalah lambung dan saluran pencernaan. Beliau sering diundang sebagai pembicara di seminar nasional gastroenterologi.',
    education: [
      'S1 Kedokteran - Universitas Gadjah Mada',
      'Sp.PD - RSUP Dr. Sardjito',
      'Kursus Endoskopi Diagnostik - Tokyo',
    ],
    availableSlots: ['07:30', '08:30', '10:00', '14:00', '16:30'],
    consultTypes: ['Chat', 'Video Call'],
  ),
  DoctorModel(
    id: 'd4',
    name: 'Dr. Linda Sari, Sp.PD',
    specialty: 'Spesialis Gastroentero-Hepatologi',
    price: 'Rp 80.000',
    priceNum: 80000,
    rating: '4.7',
    reviews: '85',
    avatar: 'https://i.pravatar.cc/150?img=9',
    bio:
        'Dr. Linda Sari menempuh spesialisasi di bidang gastroenterologi dengan fokus pada penyakit refluks asam dan dispepsia fungsional. Beliau dikenal ramah dan sabar dalam menjelaskan kondisi pasien.',
    education: [
      'S1 Kedokteran - Universitas Diponegoro',
      'Sp.PD-KGEH - RSUP Dr. Kariadi',
    ],
    availableSlots: ['09:30', '11:30', '14:30', '16:00'],
    consultTypes: ['Chat', 'Video Call'],
  ),
];

// ── HALAMAN UTAMA KONSULTASI ───────────────────────────────────────────────

class ConsultationPage extends StatefulWidget {
  const ConsultationPage({super.key});

  @override
  State<ConsultationPage> createState() => _ConsultationPageState();
}

class _ConsultationPageState extends State<ConsultationPage> {
  String _selectedFilter = 'Semua';
  final List<String> _filters = ['Semua', 'Harga Terendah', 'Rating Tertinggi'];

  List<DoctorModel> get _filteredDoctors {
    final list = List<DoctorModel>.from(allDoctors);
    if (_selectedFilter == 'Harga Terendah') {
      list.sort((a, b) => a.priceNum.compareTo(b.priceNum));
    } else if (_selectedFilter == 'Rating Tertinggi') {
      list.sort((a, b) => b.rating.compareTo(a.rating));
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.darkAccent, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Konsultasi Dokter',
          style: TextStyle(color: AppColors.darkAccent, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.softAccent.withOpacity(0.5), height: 1),
        ),
      ),
      body: Column(
        children: [
          // Filter Chips
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _filters.map((f) {
                  final isActive = _selectedFilter == f;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedFilter = f),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                      decoration: BoxDecoration(
                        color: isActive ? AppColors.primary : AppColors.background,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isActive ? AppColors.primary : AppColors.softAccent.withOpacity(0.5),
                        ),
                      ),
                      child: Text(
                        f,
                        style: TextStyle(
                          color: isActive ? Colors.white : AppColors.textSecondary,
                          fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          Container(height: 1, color: AppColors.softAccent.withOpacity(0.3)),

          // Doctor List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              children: [
                // Info banner
                Container(
                  padding: const EdgeInsets.all(14),
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: AppColors.softAccent.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.softAccent),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.verified_user_rounded, color: AppColors.primary, size: 18),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Semua dokter telah terverifikasi dan berlisensi IDI',
                          style: TextStyle(color: AppColors.darkAccent, fontSize: 12, height: 1.4),
                        ),
                      ),
                    ],
                  ),
                ),

                const Text(
                  'Spesialis GERD & Lambung',
                  style: TextStyle(
                    color: AppColors.darkAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 14),
                ..._filteredDoctors.map((doc) => _buildDoctorCard(doc)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorCard(DoctorModel doc) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DoctorProfilePage(doctor: doc))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.softAccent.withOpacity(0.5)),
          boxShadow: [
            BoxShadow(color: AppColors.primary.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 36,
              backgroundImage: NetworkImage(doc.avatar),
              backgroundColor: AppColors.softAccent,
            ),
            const SizedBox(width: 14),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(doc.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.darkAccent),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 3),
                  Text(doc.specialty,
                      style: const TextStyle(color: AppColors.primary, fontSize: 11.5, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, color: Colors.orange, size: 14),
                      const SizedBox(width: 3),
                      Text(doc.rating,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.darkAccent)),
                      const SizedBox(width: 4),
                      Text('(${doc.reviews})',
                          style: const TextStyle(color: AppColors.textHint, fontSize: 11)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(doc.price,
                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: AppColors.darkAccent)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text('Konsul',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
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

// ── HALAMAN PROFIL DOKTER ─────────────────────────────────────────────────────

class DoctorProfilePage extends StatefulWidget {
  final DoctorModel doctor;
  const DoctorProfilePage({super.key, required this.doctor});

  @override
  State<DoctorProfilePage> createState() => _DoctorProfilePageState();
}

class _DoctorProfilePageState extends State<DoctorProfilePage> {
  String? _selectedSlot;
  String _selectedType = 'Chat';

  @override
  Widget build(BuildContext context) {
    final doc = widget.doctor;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ── SliverAppBar ──────────────────────────────────────────────────
          SliverAppBar(
            pinned: true,
            expandedHeight: 220,
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Colors.white),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: AppColors.primary,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 56, 24, 20),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 44,
                          backgroundImage: NetworkImage(doc.avatar),
                          backgroundColor: AppColors.softAccent,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(doc.name,
                                  style: const TextStyle(
                                      color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16, height: 1.3)),
                              const SizedBox(height: 4),
                              Text(doc.specialty,
                                  style: const TextStyle(color: AppColors.softAccent, fontSize: 12)),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  const Icon(Icons.star_rounded, color: Colors.orange, size: 14),
                                  const SizedBox(width: 4),
                                  Text('${doc.rating} · ${doc.reviews} ulasan',
                                      style: const TextStyle(color: Colors.white70, fontSize: 11)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Content ───────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Pricing & consult type
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.softAccent.withOpacity(0.5)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Biaya Konsultasi',
                                  style: TextStyle(color: AppColors.textHint, fontSize: 11)),
                              const SizedBox(height: 2),
                              Text(doc.price,
                                  style: const TextStyle(
                                      color: AppColors.darkAccent, fontWeight: FontWeight.w900, fontSize: 20)),
                            ],
                          ),
                        ),
                        Row(
                          children: doc.consultTypes.map((type) {
                            final isActive = _selectedType == type;
                            return GestureDetector(
                              onTap: () => setState(() => _selectedType = type),
                              child: Container(
                                margin: const EdgeInsets.only(left: 8),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                                decoration: BoxDecoration(
                                  color: isActive ? AppColors.primary : AppColors.background,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: isActive ? AppColors.primary : AppColors.softAccent.withOpacity(0.5),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      type == 'Chat' ? Icons.chat_bubble_outline_rounded : Icons.videocam_rounded,
                                      size: 14,
                                      color: isActive ? Colors.white : AppColors.textSecondary,
                                    ),
                                    const SizedBox(width: 5),
                                    Text(type,
                                        style: TextStyle(
                                          color: isActive ? Colors.white : AppColors.textSecondary,
                                          fontSize: 11,
                                          fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                                        )),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Bio
                  _sectionTitle('Tentang Dokter'),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.softAccent.withOpacity(0.5)),
                    ),
                    child: Text(doc.bio,
                        style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, height: 1.6)),
                  ),

                  const SizedBox(height: 20),

                  // Education
                  _sectionTitle('Pendidikan & Sertifikasi'),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.softAccent.withOpacity(0.5)),
                    ),
                    child: Column(
                      children: doc.education.map((e) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(top: 5),
                              width: 6, height: 6,
                              decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(e,
                                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, height: 1.4)),
                            ),
                          ],
                        ),
                      )).toList(),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Time Slot
                  _sectionTitle('Pilih Jadwal Konsultasi'),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: doc.availableSlots.map((slot) {
                      final isActive = _selectedSlot == slot;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedSlot = slot),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                          decoration: BoxDecoration(
                            color: isActive ? AppColors.primary : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isActive ? AppColors.primary : AppColors.softAccent.withOpacity(0.5),
                            ),
                            boxShadow: isActive
                                ? [BoxShadow(color: AppColors.primary.withOpacity(0.15), blurRadius: 8)]
                                : [],
                          ),
                          child: Text(
                            slot,
                            style: TextStyle(
                              color: isActive ? Colors.white : AppColors.textSecondary,
                              fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 28),

                  // CTA
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _selectedSlot == null
                          ? null
                          : () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ConsultationPaymentPage(
                                    doctor: doc,
                                    slot: _selectedSlot!,
                                    consultType: _selectedType,
                                  ),
                                ),
                              ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        disabledBackgroundColor: AppColors.softAccent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                      ),
                      child: Text(
                        _selectedSlot == null ? 'Pilih Jadwal Terlebih Dahulu' : 'Lanjut ke Pembayaran →',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) => Row(
        children: [
          Container(
            width: 3, height: 16,
            decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(width: 8),
          Text(title,
              style: const TextStyle(color: AppColors.darkAccent, fontWeight: FontWeight.bold, fontSize: 15)),
        ],
      );
}

// ── HALAMAN PEMBAYARAN ────────────────────────────────────────────────────────

class ConsultationPaymentPage extends StatefulWidget {
  final DoctorModel doctor;
  final String slot;
  final String consultType;

  const ConsultationPaymentPage({
    super.key,
    required this.doctor,
    required this.slot,
    required this.consultType,
  });

  @override
  State<ConsultationPaymentPage> createState() => _ConsultationPaymentPageState();
}

class _ConsultationPaymentPageState extends State<ConsultationPaymentPage> {
  String _selectedPayment = 'BCA Virtual Account';
  bool _isProcessing = false;

  static const int _platformFee = 2000;
  static const int _tax = 1500;

  final List<Map<String, dynamic>> _paymentMethods = [
    {'name': 'BCA Virtual Account', 'icon': Icons.account_balance_rounded, 'tag': 'Populer'},
    {'name': 'Mandiri Virtual Account', 'icon': Icons.account_balance_rounded, 'tag': null},
    {'name': 'GoPay', 'icon': Icons.account_balance_wallet_rounded, 'tag': null},
    {'name': 'OVO', 'icon': Icons.account_balance_wallet_rounded, 'tag': null},
    {'name': 'Dana', 'icon': Icons.account_balance_wallet_rounded, 'tag': null},
    {'name': 'QRIS', 'icon': Icons.qr_code_rounded, 'tag': 'Universal'},
  ];

  int get _total => widget.doctor.priceNum + _platformFee + _tax;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.darkAccent, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Pembayaran',
            style: TextStyle(color: AppColors.darkAccent, fontWeight: FontWeight.bold, fontSize: 16)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.softAccent.withOpacity(0.5), height: 1),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Order Summary Card
                _buildSectionLabel('Ringkasan Konsultasi'),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.softAccent.withOpacity(0.5)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 26,
                            backgroundImage: NetworkImage(widget.doctor.avatar),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(widget.doctor.name,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.darkAccent),
                                    maxLines: 1, overflow: TextOverflow.ellipsis),
                                const SizedBox(height: 2),
                                Text(widget.doctor.specialty,
                                    style: const TextStyle(color: AppColors.primary, fontSize: 11.5)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Container(height: 1, color: AppColors.background),
                      const SizedBox(height: 14),
                      _summaryRow('Tipe Konsultasi', widget.consultType),
                      const SizedBox(height: 6),
                      _summaryRow('Jadwal', 'Hari ini · ${widget.slot} WIB'),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Price Breakdown
                _buildSectionLabel('Rincian Biaya'),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.softAccent.withOpacity(0.5)),
                  ),
                  child: Column(
                    children: [
                      _priceRow('Biaya Konsultasi', widget.doctor.price),
                      const SizedBox(height: 8),
                      _priceRow('Biaya Platform', 'Rp ${_platformFee.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}'),
                      const SizedBox(height: 8),
                      _priceRow('Pajak (PPN)', 'Rp ${_tax}'),
                      const SizedBox(height: 12),
                      Container(height: 1, color: AppColors.background),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total Pembayaran',
                              style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.darkAccent, fontSize: 14)),
                          Text(
                            'Rp ${_formatPrice(_total)}',
                            style: const TextStyle(
                                fontWeight: FontWeight.w900, color: AppColors.primary, fontSize: 16),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Payment Methods
                _buildSectionLabel('Metode Pembayaran'),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.softAccent.withOpacity(0.5)),
                  ),
                  child: Column(
                    children: _paymentMethods.asMap().entries.map((entry) {
                      final index = entry.key;
                      final method = entry.value;
                      final isLast = index == _paymentMethods.length - 1;
                      final isSelected = _selectedPayment == method['name'];

                      return GestureDetector(
                        onTap: () => setState(() => _selectedPayment = method['name']),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                          decoration: BoxDecoration(
                            border: isLast
                                ? null
                                : Border(bottom: BorderSide(color: AppColors.background, width: 1)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: isSelected ? AppColors.primary.withOpacity(0.1) : AppColors.background,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(method['icon'],
                                    color: isSelected ? AppColors.primary : AppColors.textSecondary, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Row(
                                  children: [
                                    Text(method['name'],
                                        style: TextStyle(
                                            color: isSelected ? AppColors.darkAccent : AppColors.textSecondary,
                                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                            fontSize: 13)),
                                    if (method['tag'] != null) ...[
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(method['tag'],
                                            style: const TextStyle(
                                                color: AppColors.primary, fontSize: 9, fontWeight: FontWeight.bold)),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              Container(
                                width: 20, height: 20,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected ? AppColors.primary : AppColors.softAccent,
                                    width: 2,
                                  ),
                                ),
                                child: isSelected
                                    ? Center(
                                        child: Container(
                                          width: 10, height: 10,
                                          decoration: const BoxDecoration(
                                            color: AppColors.primary,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      )
                                    : null,
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 12),

                // Security note
                Row(
                  children: const [
                    Icon(Icons.lock_rounded, size: 13, color: AppColors.textHint),
                    SizedBox(width: 6),
                    Text('Pembayaran diproses secara aman dan terenkripsi',
                        style: TextStyle(color: AppColors.textHint, fontSize: 11)),
                  ],
                ),

                const SizedBox(height: 28),
              ],
            ),
          ),

          // Pay Button
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, -4)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('Total: ', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                    Text('Rp ${_formatPrice(_total)}',
                        style: const TextStyle(
                            color: AppColors.darkAccent, fontWeight: FontWeight.w900, fontSize: 16)),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isProcessing ? null : _processPayment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      elevation: 0,
                    ),
                    child: _isProcessing
                        ? const SizedBox(
                            width: 20, height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : Text('Bayar via $_selectedPayment',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _processPayment() async {
    setState(() => _isProcessing = true);
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() => _isProcessing = false);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ConsultationConfirmationPage(
          doctor: widget.doctor,
          slot: widget.slot,
          consultType: widget.consultType,
          paymentMethod: _selectedPayment,
          total: _total,
        ),
      ),
    );
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
  }

  Widget _summaryRow(String label, String value) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          Text(value,
              style: const TextStyle(color: AppColors.darkAccent, fontWeight: FontWeight.w600, fontSize: 12)),
        ],
      );

  Widget _priceRow(String label, String value) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          Text(value, style: const TextStyle(color: AppColors.darkAccent, fontSize: 13)),
        ],
      );

  Widget _buildSectionLabel(String label) => Row(
        children: [
          Container(width: 3, height: 16,
              decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 8),
          Text(label,
              style: const TextStyle(color: AppColors.darkAccent, fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      );
}

// ── HALAMAN KONFIRMASI ────────────────────────────────────────────────────────

class ConsultationConfirmationPage extends StatelessWidget {
  final DoctorModel doctor;
  final String slot;
  final String consultType;
  final String paymentMethod;
  final int total;

  const ConsultationConfirmationPage({
    super.key,
    required this.doctor,
    required this.slot,
    required this.consultType,
    required this.paymentMethod,
    required this.total,
  });

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),

              // Success icon
              Container(
                width: 90,
                height: 90,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded, color: Colors.white, size: 48),
              ),
              const SizedBox(height: 24),

              const Text(
                'Pembayaran Berhasil!',
                style: TextStyle(
                    color: AppColors.darkAccent, fontWeight: FontWeight.bold, fontSize: 22),
              ),
              const SizedBox(height: 8),
              const Text(
                'Konsultasi kamu telah terjadwal.\nDokter akan segera menghubungimu.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.5),
              ),

              const SizedBox(height: 32),

              // Summary card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.softAccent.withOpacity(0.5)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Detail Pemesanan',
                        style: TextStyle(
                            color: AppColors.darkAccent, fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 16),
                    _confirmRow('Dokter', doctor.name),
                    const SizedBox(height: 10),
                    _confirmRow('Tipe', consultType),
                    const SizedBox(height: 10),
                    _confirmRow('Jadwal', 'Hari ini · $slot WIB'),
                    const SizedBox(height: 10),
                    _confirmRow('Pembayaran', paymentMethod),
                    const SizedBox(height: 12),
                    Container(height: 1, color: AppColors.background),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total Dibayar',
                            style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.darkAccent)),
                        Text('Rp ${_formatPrice(total)}',
                            style: const TextStyle(
                                fontWeight: FontWeight.w900, color: AppColors.primary, fontSize: 16)),
                      ],
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Kembali ke beranda
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                  ),
                  child: const Text('Kembali ke Beranda',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Lihat Semua Konsultasi',
                    style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _confirmRow(String label, String value) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: const TextStyle(color: AppColors.textHint, fontSize: 12)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(color: AppColors.darkAccent, fontWeight: FontWeight.w600, fontSize: 12)),
          ),
        ],
      );
}
