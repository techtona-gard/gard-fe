import 'package:flutter/material.dart';
import 'package:gard/constants/app_colors.dart';

class MedicineModel {
  final String name;
  final String activeIngredient;
  final String category;
  final String indication;
  final String howToTake;
  final String description;
  final String safetyLevel; // 'Aman (OTC)', 'Bebas Terbatas', 'Butuh Resep'
  final Color safetyColor;

  const MedicineModel({
    required this.name,
    required this.activeIngredient,
    required this.category,
    required this.indication,
    required this.howToTake,
    required this.description,
    required this.safetyLevel,
    required this.safetyColor,
  });
}

class PharmacyPage extends StatefulWidget {
  const PharmacyPage({super.key});

  @override
  State<PharmacyPage> createState() => _PharmacyPageState();
}

class _PharmacyPageState extends State<PharmacyPage> {
  String _selectedCategory = 'Semua';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  final List<String> _categories = [
    'Semua',
    'Antasida',
    'PPI (Penghambat Asam)',
    'H2 Blocker',
    'Herbal & Alami',
    'Suplemen Serat',
  ];

  final List<MedicineModel> _medicines = const [
    MedicineModel(
      name: 'Antasida DOEN',
      activeIngredient: 'Aluminium Hidroksida & Magnesium Hidroksida',
      category: 'Antasida',
      indication: 'Meredakan gejala sakit maag, asam lambung tinggi, dan kembung dengan cepat.',
      howToTake: 'Dikunyah dahulu, 1 jam sebelum makan atau 2 jam setelah makan, dan menjelang tidur.',
      description: 'Antasida bekerja cepat dengan menetralisir asam lambung yang ada di lambung. Sangat efektif untuk pertolongan pertama saat nyeri dada (heartburn) menyerang secara tiba-tiba.',
      safetyLevel: 'Bebas (OTC)',
      safetyColor: AppColors.success,
    ),
    MedicineModel(
      name: 'Famotidine',
      activeIngredient: 'Famotidine 10mg / 20mg',
      category: 'H2 Blocker',
      indication: 'Mengurangi produksi asam lambung berlebih, meredakan heartburn kronis.',
      howToTake: 'Diminum 1 jam sebelum makan utama, maksimal 2 kali sehari.',
      description: 'H2 Blocker bekerja dengan cara memblokir histamin pada sel lambung untuk mengurangi produksi asam. Efek bertahap namun bertahan lebih lama dibanding antasida biasa.',
      safetyLevel: 'Bebas Terbatas',
      safetyColor: AppColors.warning,
    ),
    MedicineModel(
      name: 'Omeprazole',
      activeIngredient: 'Omeprazole 20mg',
      category: 'PPI (Penghambat Asam)',
      indication: 'Pengobatan jangka pendek untuk luka lambung, GERD, dan refluks esofagitis.',
      howToTake: 'Diminum pagi hari saat perut kosong, 30–60 menit sebelum sarapan.',
      description: 'Proton Pump Inhibitor (PPI) adalah obat penekan asam lambung paling kuat yang bekerja dengan mematikan pompa asam di dinding lambung. Membantu pemulihan dinding esofagus yang iritasi.',
      safetyLevel: 'Butuh Resep',
      safetyColor: AppColors.info,
    ),
    MedicineModel(
      name: 'Lansoprazole',
      activeIngredient: 'Lansoprazole 30mg',
      category: 'PPI (Penghambat Asam)',
      indication: 'Meredakan nyeri ulu hati parah, menyembuhkan tukak lambung dan GERD.',
      howToTake: 'Diminum sekali sehari sebelum makan di pagi hari.',
      description: 'Lansoprazole termasuk golongan PPI generasi baru yang sangat efektif menghambat sekresi asam lambung guna memulihkan kerusakan jaringan tenggorokan akibat asam lambung naik.',
      safetyLevel: 'Butuh Resep',
      safetyColor: AppColors.info,
    ),
    MedicineModel(
      name: 'Sucralfate Sirup',
      activeIngredient: 'Sucralfate 500mg/5ml',
      category: 'Antasida',
      indication: 'Melapisi dinding lambung dan esofagus dari iritasi akibat asam lambung.',
      howToTake: 'Diminum dalam kondisi perut kosong, 1 jam sebelum makan atau 2 jam setelah makan.',
      description: 'Sucralfate bekerja seperti "plester pelindung" yang menempel pada bagian lambung atau esofagus yang terluka/iritasi sehingga mempercepat proses penyembuhan jaringan.',
      safetyLevel: 'Butuh Resep',
      safetyColor: AppColors.info,
    ),
    MedicineModel(
      name: 'Madu Lambung (Honeymag)',
      activeIngredient: 'Madu Murni, Ekstrak Kunyit, Temulawak, Ketumbar',
      category: 'Herbal & Alami',
      indication: 'Menenangkan lambung, mengurangi begah/kembung, memperkuat sistem pencernaan.',
      howToTake: 'Diminum 1–2 sendok makan secara langsung sebelum makan, atau dicampur air hangat.',
      description: 'Madu alami dengan kombinasi kunyit dan temulawak membantu melapisi lambung secara alami dan memiliki efek anti-inflamasi alami untuk mengurangi sensasi perih.',
      safetyLevel: 'Bebas (Alami)',
      safetyColor: AppColors.success,
    ),
    MedicineModel(
      name: 'Teh Jahe Hangat',
      activeIngredient: 'Ekstrak Jahe Merah Alami',
      category: 'Herbal & Alami',
      indication: 'Meredakan mual akibat asam lambung naik, membantu relaksasi pencernaan.',
      howToTake: 'Diminum hangat-hangat di pagi hari atau sore hari.',
      description: 'Jahe memiliki sifat anti-inflamasi alami. Namun harus diminum dalam konsentrasi sedang karena jahe yang terlalu pedas justru dapat memicu iritasi lambung pada beberapa orang.',
      safetyLevel: 'Bebas (Alami)',
      safetyColor: AppColors.success,
    ),
    MedicineModel(
      name: 'Psyllium Husk',
      activeIngredient: 'Serat Larut Air Psyllium',
      category: 'Suplemen Serat',
      indication: 'Membantu mengikat asam di pencernaan dan memperlancar buang air besar.',
      howToTake: 'Campurkan 1 sendok teh ke dalam segelas air dingin, segera minum sebelum mengental.',
      description: 'Serat larut air membantu menyerap kelebihan asam lambung di saluran pencernaan serta menjaga pergerakan usus agar pencernaan bekerja secara optimal tanpa refluks.',
      safetyLevel: 'Bebas (OTC)',
      safetyColor: AppColors.success,
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Filter dan cari obat
    final filteredMedicines = _medicines.where((med) {
      final matchesCategory = _selectedCategory == 'Semua' || med.category == _selectedCategory;
      final matchesSearch = med.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          med.activeIngredient.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          med.indication.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();

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
          'Apotek & Info Obat',
          style: TextStyle(color: AppColors.darkAccent, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: AppColors.softAccent.withOpacity(0.5),
            height: 1,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Search & Header Section ──────────────────────────────────────────
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Cari obat lambung, kandungan...',
                    hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 14),
                    prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary, size: 22),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, color: AppColors.textSecondary, size: 20),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: AppColors.background,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: AppColors.softAccent.withOpacity(0.5)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Category Selector (Horizontal Scroll) ─────────────────────────────
          Container(
            height: 52,
            color: Colors.white,
            padding: const EdgeInsets.only(bottom: 12),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = _selectedCategory == category;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCategory = category;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : AppColors.background,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : AppColors.softAccent.withOpacity(0.5),
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        category,
                        style: TextStyle(
                          color: isSelected ? Colors.white : AppColors.textSecondary,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Divider
          Container(
            height: 1,
            color: AppColors.softAccent.withOpacity(0.3),
          ),

          // ── Medicine List ────────────────────────────────────────────────────
          Expanded(
            child: filteredMedicines.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.medical_services_outlined, size: 48, color: AppColors.textHint.withOpacity(0.7)),
                        const SizedBox(height: 12),
                        const Text(
                          'Obat tidak ditemukan',
                          style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Coba gunakan kata kunci pencarian yang lain.',
                          style: TextStyle(color: AppColors.textHint, fontSize: 12),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                    itemCount: filteredMedicines.length,
                    itemBuilder: (context, index) {
                      final med = filteredMedicines[index];
                      return _buildMedicineCard(med);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicineCard(MedicineModel med) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.softAccent.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _showMedicineDetails(med),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Title & Safety Badge
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            med.name,
                            style: const TextStyle(
                              color: AppColors.darkAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            med.activeIngredient,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: med.safetyColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: med.safetyColor.withOpacity(0.3), width: 1),
                      ),
                      child: Text(
                        med.safetyLevel,
                        style: TextStyle(
                          color: med.safetyColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Divider
                Container(
                  height: 1,
                  color: AppColors.background,
                ),
                const SizedBox(height: 12),

                // Indication
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 2),
                      child: const Icon(
                        Icons.check_circle_outline_rounded,
                        color: AppColors.primary,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        med.indication,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 13,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // How to take
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 2),
                      child: const Icon(
                        Icons.info_outline_rounded,
                        color: AppColors.midTeal,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        med.howToTake,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12.5,
                          height: 1.4,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                // Expander indicator link
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'Lihat Detail Obat',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      color: AppColors.primary,
                      size: 14,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showMedicineDetails(MedicineModel med) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(28),
              topRight: Radius.circular(28),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Pull-down handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textHint.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Title
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          med.name,
                          style: const TextStyle(
                            color: AppColors.darkAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          med.activeIngredient,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: med.safetyColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: med.safetyColor.withOpacity(0.3), width: 1),
                    ),
                    child: Text(
                      med.safetyLevel,
                      style: TextStyle(
                        color: med.safetyColor,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Details
              _buildDetailSection(
                title: 'Indikasi / Khasiat',
                content: med.indication,
                icon: Icons.check_circle_outline_rounded,
                iconColor: AppColors.success,
              ),
              const SizedBox(height: 16),

              _buildDetailSection(
                title: 'Cara Konsumsi',
                content: med.howToTake,
                icon: Icons.info_outline_rounded,
                iconColor: AppColors.primary,
              ),
              const SizedBox(height: 16),

              _buildDetailSection(
                title: 'Deskripsi Obat',
                content: med.description,
                icon: Icons.description_outlined,
                iconColor: AppColors.midTeal,
              ),
              const SizedBox(height: 28),

              // Warning alert box
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.warning.withOpacity(0.2), width: 1),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: AppColors.warning,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'PENTING: Selalu ikuti petunjuk dokter atau instruksi kemasan sebelum mengonsumsi obat apa pun. Jangan mengonsumsi obat penekan asam lambung jangka panjang tanpa rekomendasi medis.',
                        style: TextStyle(
                          color: AppColors.warning,
                          fontSize: 11.5,
                          height: 1.4,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Future update card
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.12),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.upcoming_rounded,
                      color: AppColors.softAccent,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'FUTURE UPDATE',
                            style: TextStyle(
                              color: AppColors.softAccent,
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.0,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Pemesanan obat langsung terintegrasi dengan Apotek terdekat akan segera hadir pada pembaruan mendatang.',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11.5,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Close button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Tutup',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailSection({
    required String title,
    required String content,
    required IconData icon,
    required Color iconColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: iconColor, size: 18),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                color: AppColors.darkAccent,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.only(left: 26),
          child: Text(
            content,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}
