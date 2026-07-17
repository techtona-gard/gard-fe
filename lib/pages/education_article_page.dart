import 'package:flutter/material.dart';
import 'package:gard/constants/app_colors.dart';

class EducationArticle {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final String readTime;
  final List<EducationSection> sections;

  const EducationArticle({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.readTime,
    required this.sections,
  });
}

class EducationSection {
  final String heading;
  final String body;
  final List<String>? bullets;

  const EducationSection({
    required this.heading,
    required this.body,
    this.bullets,
  });
}

// ── DATA ARTIKEL ──────────────────────────────────────────────────────────────

final List<EducationArticle> educationArticles = [
  EducationArticle(
    id: 'gerd_symptoms',
    title: 'Mengenal Gejala GERD',
    subtitle: 'Pelajari perbedaan maag biasa dan GERD secara menyeluruh',
    icon: Icons.menu_book_rounded,
    readTime: '5 menit',
    sections: [
      const EducationSection(
        heading: 'Apa Itu GERD?',
        body:
            'GERD (Gastroesophageal Reflux Disease) adalah kondisi kronis di mana asam lambung naik kembali ke kerongkongan (esofagus). Berbeda dengan maag biasa yang bersifat sementara, GERD adalah gangguan yang persisten dan membutuhkan penanganan serius.',
      ),
      const EducationSection(
        heading: 'Gejala Utama GERD',
        body: 'Gejala GERD sangat beragam dan bisa memengaruhi kualitas hidup. Berikut tanda-tanda paling umum:',
        bullets: [
          'Heartburn – sensasi terbakar di dada, terutama setelah makan atau saat berbaring',
          'Regurgitasi – asam atau makanan naik kembali ke mulut',
          'Kesulitan menelan (disfagia)',
          'Nyeri dada yang sering dikira penyakit jantung',
          'Batuk kering kronis terutama di malam hari',
          'Suara serak atau tenggorokan terasa mengganjal',
          'Rasa asam atau pahit di mulut',
        ],
      ),
      const EducationSection(
        heading: 'GERD vs Maag Biasa',
        body:
            'Maag biasa (gastritis) adalah peradangan pada lapisan lambung yang umumnya bersifat sementara, dipicu oleh telat makan, stres, atau obat tertentu. GERD lebih kompleks karena melibatkan kelemahan otot katup antara kerongkongan dan lambung (Lower Esophageal Sphincter/LES), sehingga asam lebih mudah naik.',
      ),
      const EducationSection(
        heading: 'Kapan Harus ke Dokter?',
        body:
            'Segera konsultasikan ke dokter jika gejala terjadi lebih dari dua kali seminggu, tidak membaik dengan antasida, atau disertai penurunan berat badan tanpa sebab, muntah darah, atau kesulitan menelan yang memburuk.',
      ),
      const EducationSection(
        heading: 'Komplikasi Jika Dibiarkan',
        body: 'GERD yang tidak ditangani dapat menyebabkan:',
        bullets: [
          "Barrett's Esophagus – perubahan sel kerongkongan yang bisa berkembang menjadi kanker",
          'Esofagitis – peradangan dan luka pada lapisan kerongkongan',
          'Striktur esofagus – penyempitan yang menyulitkan menelan',
          'Pneumonia aspirasi akibat asam masuk ke saluran napas',
        ],
      ),
    ],
  ),
  EducationArticle(
    id: 'diet_tips',
    title: 'Tips Diet Lambung',
    subtitle: 'Daftar makanan aman dan yang harus dihindari penderita GERD',
    icon: Icons.restaurant_rounded,
    readTime: '6 menit',
    sections: [
      const EducationSection(
        heading: 'Prinsip Diet untuk Lambung Sehat',
        body:
            'Pola makan memegang peran kunci dalam mengelola GERD. Tujuan utama diet adalah mengurangi tekanan pada lambung, menghindari pemicu peningkatan asam, dan memperkuat otot katup lambung-kerongkongan.',
      ),
      const EducationSection(
        heading: 'Makanan yang Aman Dikonsumsi',
        body: 'Pilihan makanan berikut terbukti ramah bagi penderita asam lambung:',
        bullets: [
          'Oatmeal dan gandum utuh – menyerap asam lambung',
          'Pisang dan melon – buah rendah asam yang menenangkan lambung',
          'Sayuran hijau: brokoli, bayam, asparagus, kacang hijau',
          'Dada ayam tanpa kulit, ikan rebus atau kukus',
          'Putih telur – hindari kuningnya yang tinggi lemak',
          'Jahe – sifat anti-inflamasi alami',
          'Susu rendah lemak atau susu oat',
          'Air putih dan teh herbal tanpa kafein',
        ],
      ),
      const EducationSection(
        heading: 'Makanan yang Harus Dihindari',
        body: 'Beberapa jenis makanan diketahui memperparah gejala GERD:',
        bullets: [
          'Makanan berlemak tinggi (gorengan, fast food)',
          'Makanan pedas dan asam (cabai, tomat, jeruk)',
          'Coklat dan mint – melemahkan otot katup LES',
          'Kopi dan minuman berkafein',
          'Minuman bersoda dan beralkohol',
          'Bawang bombay dan bawang putih (dapat meningkatkan gas)',
          'Daging berlemak tinggi seperti sosis dan bacon',
        ],
      ),
      const EducationSection(
        heading: 'Tips Pola Makan',
        body: 'Selain jenis makanan, cara makan juga sangat penting:',
        bullets: [
          'Makan dalam porsi kecil tapi sering (5–6 kali sehari)',
          'Jangan makan 2–3 jam sebelum tidur',
          'Kunyah makanan perlahan dan jangan terburu-buru',
          'Hindari berbaring langsung setelah makan',
          'Minumlah air sedikit-sedikit di antara suapan, bukan banyak sekaligus',
        ],
      ),
      const EducationSection(
        heading: 'Suplemen yang Bisa Membantu',
        body:
            'Konsultasikan dengan dokter mengenai suplemen seperti probiotik untuk membantu keseimbangan bakteri usus, enzim pencernaan, atau suplemen aloe vera yang dikenal meredakan peradangan lambung.',
      ),
    ],
  ),
  EducationArticle(
    id: 'healthy_lifestyle',
    title: 'Gaya Hidup Sehat',
    subtitle: 'Mengatur kebiasaan harian untuk mendukung kesehatan lambung',
    icon: Icons.accessibility_new_rounded,
    readTime: '7 menit',
    sections: [
      const EducationSection(
        heading: 'Hubungan Gaya Hidup dan GERD',
        body:
            'Banyak kebiasaan sehari-hari yang secara langsung memperburuk atau membantu kondisi GERD. Perubahan gaya hidup seringkali sama efektifnya dengan obat-obatan dalam mengelola gejala jangka panjang.',
      ),
      const EducationSection(
        heading: 'Posisi Tidur yang Tepat',
        body: 'Posisi tidur adalah salah satu faktor terpenting bagi penderita GERD:',
        bullets: [
          'Tidur miring ke kiri – posisi terbaik untuk mencegah refluks',
          'Elevasi kepala 15–20 cm menggunakan bantal wedge atau mengganjal kaki tempat tidur',
          'Hindari tidur telentang setelah makan besar',
          'Jangan tidur dalam posisi tengkurap karena meningkatkan tekanan pada lambung',
        ],
      ),
      const EducationSection(
        heading: 'Olahraga yang Dianjurkan',
        body:
            'Olahraga teratur membantu menjaga berat badan ideal dan mengurangi stres, keduanya krusial untuk GERD. Pilih jenis olahraga yang tidak meningkatkan tekanan perut:',
        bullets: [
          'Jalan kaki 30 menit setiap hari',
          'Renang dan aqua aerobik',
          'Yoga (hindari pose terbalik)',
          'Bersepeda ringan',
          'Hindari angkat beban berat dan sit-up agresif',
        ],
      ),
      const EducationSection(
        heading: 'Manajemen Stres',
        body:
            'Stres secara langsung meningkatkan produksi asam lambung. Teknik-teknik berikut terbukti efektif:',
        bullets: [
          'Meditasi atau mindfulness 10–15 menit per hari',
          'Pernapasan dalam (deep breathing exercises)',
          'Tidur cukup 7–8 jam per malam',
          'Journaling atau curhat untuk melepaskan beban pikiran',
          'Rutinitas harian yang konsisten dan terstruktur',
        ],
      ),
      const EducationSection(
        heading: 'Berat Badan dan GERD',
        body:
            'Kelebihan berat badan meningkatkan tekanan pada lambung dan melemahkan katup LES. Menurunkan berat badan bahkan 5–10% saja sudah terbukti secara klinis mampu mengurangi frekuensi dan intensitas gejala GERD secara signifikan.',
      ),
      const EducationSection(
        heading: 'Hindari Rokok dan Alkohol',
        body:
            'Nikotin dari rokok melemahkan otot LES dan meningkatkan produksi asam lambung. Alkohol mengiritasi lapisan esofagus dan lambung secara langsung. Berhenti merokok dan membatasi konsumsi alkohol adalah langkah paling impactful yang bisa dilakukan.',
      ),
    ],
  ),
  EducationArticle(
    id: 'myths_facts',
    title: 'Mitos vs Fakta',
    subtitle: 'Luruskan kesalahpahaman umum seputar penyakit asam lambung',
    icon: Icons.help_outline_rounded,
    readTime: '4 menit',
    sections: [
      const EducationSection(
        heading: 'Mengapa Mitos Berbahaya?',
        body:
            'Informasi yang salah tentang GERD dan maag dapat membuat penderita menghindari pengobatan yang tepat, atau justru melakukan hal-hal yang memperburuk kondisi mereka. Yuk luruskan beberapa mitos yang paling umum beredar.',
      ),
      const EducationSection(
        heading: 'Mitos 1: Kopi Selalu Harus Dihindari',
        body:
            'Fakta: Tidak semua orang dengan GERD sensitif terhadap kopi. Beberapa penelitian menunjukkan bahwa kopi rendah asam atau kopi cold brew lebih dapat ditoleransi. Kuncinya adalah kenali tubuhmu sendiri. Jika kopi memicu gejalamu, kurangi atau ganti alternatif.',
      ),
      const EducationSection(
        heading: 'Mitos 2: Coklat Harus Sepenuhnya Dihindari',
        body:
            'Fakta: Coklat hitam (dark chocolate) mengandung theobromine yang memang melemahkan LES. Namun dalam porsi sangat kecil, beberapa penderita GERD masih bisa mengonsumsinya. Lebih penting memperhatikan total pola makan secara keseluruhan daripada menghindari satu makanan secara ekstrem.',
      ),
      const EducationSection(
        heading: 'Mitos 3: Minum Susu Meredakan Asam Lambung',
        body:
            'Fakta: Susu memang memberikan efek menenangkan sementara karena sifat alkalinya, namun lemak dan protein dalam susu justru merangsang produksi asam lebih banyak setelah beberapa jam. Susu rendah lemak lebih baik, namun bukan solusi utama.',
      ),
      const EducationSection(
        heading: 'Mitos 4: GERD Hanya Masalah Pola Makan',
        body:
            'Fakta: GERD adalah kondisi medis yang kompleks dengan faktor genetik, anatomi (seperti hernia hiatus), dan kelemahan otot LES yang tidak sepenuhnya bisa diatasi hanya dengan diet. Banyak penderita membutuhkan kombinasi perubahan gaya hidup, obat-obatan, dan dalam kasus berat, prosedur medis.',
      ),
      const EducationSection(
        heading: 'Mitos 5: Antasida Adalah Solusi Jangka Panjang',
        body:
            'Fakta: Antasida hanya menetralisir asam yang sudah ada, bukan mengatasi akar masalah. Penggunaan jangka panjang tanpa pengawasan dokter bisa mengganggu keseimbangan elektrolit dan menyembunyikan kondisi yang lebih serius. Konsultasi dokter untuk penanganan yang tepat.',
      ),
      const EducationSection(
        heading: 'Fakta Penting yang Sering Tidak Diketahui',
        body: 'Beberapa fakta tentang GERD yang penting untuk diketahui:',
        bullets: [
          'GERD bisa dialami bayi dan anak-anak, bukan hanya orang dewasa',
          'Gejala GERD tidak selalu berupa nyeri dada – batuk kronis dan suara serak juga bisa jadi tandanya',
          'Stres adalah pemicu GERD yang sangat kuat namun sering diabaikan',
          'GERD yang tidak diobati meningkatkan risiko kanker kerongkongan',
          'Obat-obatan seperti aspirin dan ibuprofen dapat memperburuk GERD',
        ],
      ),
    ],
  ),
];

// ── HALAMAN ARTIKEL ─────────────────────────────────────────────────────────

class EducationArticlePage extends StatelessWidget {
  final EducationArticle article;

  const EducationArticlePage({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ── Header ──────────────────────────────────────────────────────
          SliverAppBar(
            pinned: true,
            expandedHeight: 200,
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
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
              collapseMode: CollapseMode.parallax,
              background: Container(
                color: AppColors.primary,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 56, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(article.icon, color: AppColors.softAccent, size: 24),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          article.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.schedule_rounded, size: 13, color: AppColors.softAccent),
                            const SizedBox(width: 5),
                            Text(
                              'Waktu baca: ${article.readTime}',
                              style: const TextStyle(color: AppColors.softAccent, fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Content ──────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Subtitle card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.softAccent.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.softAccent, width: 1),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline_rounded, size: 18, color: AppColors.primary),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            article.subtitle,
                            style: const TextStyle(
                              color: AppColors.darkAccent,
                              fontSize: 13,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Sections
                  ...article.sections.asMap().entries.map((entry) {
                    final index = entry.key;
                    final section = entry.value;
                    return _buildSection(index + 1, section);
                  }),

                  const SizedBox(height: 40),

                  // Bottom CTA
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Ingin tahu lebih lanjut?',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Konsultasikan kondisimu langsung dengan dokter spesialis kami.',
                          style: TextStyle(color: AppColors.softAccent, fontSize: 12, height: 1.4),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(int index, EducationSection section) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section heading
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '$index',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  section.heading,
                  style: const TextStyle(
                    color: AppColors.darkAccent,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Body text
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.softAccent.withOpacity(0.6)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  section.body,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13.5,
                    height: 1.6,
                  ),
                ),
                if (section.bullets != null) ...[
                  const SizedBox(height: 12),
                  ...section.bullets!.map((bullet) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(top: 6),
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                bullet,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 13,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
