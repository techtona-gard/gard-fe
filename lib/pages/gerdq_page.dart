import 'package:flutter/material.dart';
import 'package:gard/constants/app_colors.dart';
import 'package:gard/main.dart';
import 'package:gard/models/history_model.dart';
import 'package:gard/services/history_service.dart';
import 'package:gard/services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ─────────────────────────────────────────────────────────────────────────────
// GerdQ berdasarkan paper resmi:
//   Jones R, et al. "Development of the GerdQ, a tool for the diagnosis and
//   management of gastro-oesophageal reflux disease in primary care."
//   Alimentary Pharmacology & Therapeutics 30(10), 2009.
//
// Scoring:
//   Q1 Heartburn       → POSITIF  (0, 1, 2, 3)
//   Q2 Regurgitasi     → POSITIF  (0, 1, 2, 3)
//   Q3 Nyeri Epigastrik→ POSITIF  (0, 1, 2, 3)
//   Q4 Mual            → POSITIF  (0, 1, 2, 3)
//   Q5 Gangg. Tidur    → NEGATIF  (3, 2, 1, 0) — terbalik
//   Q6 Obat Tambahan   → NEGATIF  (3, 2, 1, 0) — terbalik
//   Total maks: 18
//   Cut-off ≥ 8 → Kemungkinan GERD Tinggi
// ─────────────────────────────────────────────────────────────────────────────

class GerdQPage extends StatefulWidget {
  const GerdQPage({super.key});

  @override
  State<GerdQPage> createState() => _GerdQPageState();
}

class _GerdQPageState extends State<GerdQPage> {
  int _currentStep = 0;
  final List<int?> _answers = List.filled(6, null);

  /// type: 'positive' → skor = indeks jawaban (0,1,2,3)
  /// type: 'negative' → skor = 3 − indeks jawaban (3,2,1,0)
  final List<Map<String, dynamic>> _questions = [
    {
      'question':
          'Seberapa sering Anda merasakan sensasi terbakar di belakang tulang dada (heartburn) dalam 7 hari terakhir?',
      'type': 'positive',
      'icon': Icons.local_fire_department_rounded,
      'highlight': 'chest',
      'hint': 'Rasa panas/perih yang menjalar dari dada ke leher.',
    },
    {
      'question':
          'Seberapa sering Anda merasa ada cairan atau makanan naik dari lambung ke mulut/tenggorokan (regurgitasi) dalam 7 hari terakhir?',
      'type': 'positive',
      'icon': Icons.keyboard_double_arrow_up_rounded,
      'highlight': 'throat',
      'hint': 'Sensasi isi lambung naik ke atas tanpa disengaja.',
    },
    {
      'question':
          'Seberapa sering Anda merasa nyeri di bagian tengah perut atas (ulu hati/epigastrik) dalam 7 hari terakhir?',
      'type': 'positive',
      'icon': Icons.fmd_bad_rounded,
      'highlight': 'upper_abdomen',
      'hint': 'Nyeri atau rasa tidak nyaman di bagian tengah perut atas.',
    },
    {
      'question':
          'Seberapa sering Anda merasa mual dalam 7 hari terakhir?',
      'type': 'positive',
      'icon': Icons.sick_rounded,
      'highlight': 'stomach',
      'hint': 'Rasa ingin muntah atau perut tidak enak.',
    },
    {
      'question':
          'Seberapa sering Anda mengalami gangguan tidur akibat heartburn atau regurgitasi dalam 7 hari terakhir?',
      'type': 'negative',
      'icon': Icons.bedtime_rounded,
      'highlight': 'head',
      'hint': 'Terbangun di malam hari atau sulit tidur karena gejala GERD.',
    },
    {
      'question':
          'Seberapa sering Anda mengonsumsi obat tambahan (seperti antasida/obat warung) di luar resep dokter untuk meredakan gejala dalam 7 hari terakhir?',
      'type': 'negative',
      'icon': Icons.medication_rounded,
      'highlight': 'mouth',
      'hint': 'Obat pengurang asam yang dibeli sendiri, bukan dari resep dokter.',
    },
  ];

  final List<String> _optionLabels = [
    '0 Hari (Tidak Pernah)',
    '1 Hari',
    '2–3 Hari',
    '4–7 Hari',
  ];

  /// Poin untuk soal positif: indeks = skor
  final List<int> _positivePoints = [0, 1, 2, 3];

  /// Poin untuk soal negatif: terbalik
  final List<int> _negativePoints = [3, 2, 1, 0];

  void _handleAnswer(int optionIndex) {
    setState(() => _answers[_currentStep] = optionIndex);
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_currentStep < _questions.length - 1) {
        setState(() => _currentStep++);
      } else {
        _showResult();
      }
    });
  }

  Future<void> _showResult() async {
    int totalScore = 0;
    for (int i = 0; i < _questions.length; i++) {
      final ans = _answers[i]!;
      totalScore += _questions[i]['type'] == 'positive'
          ? _positivePoints[ans]
          : _negativePoints[ans];
    }

    final String riskLabel = totalScore >= 8 ? 'Tinggi' : 'Rendah';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
    );

    try {
      await SupabaseService.instance.saveGerdStatus(riskLabel);
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId != null) {
        await HistoryService.instance.insertHistory(HistoryModel(
          historyId: 0,
          userId: userId,
          category: 'KUESIONER',
          historyDate: DateTime.now(),
          description: 'Skor GerdQ: $totalScore / 18',
          gerdqScore: totalScore,
          severityLevel: riskLabel,
        ));
      }
    } catch (e) {
      debugPrint('Error saving GerdQ result: $e');
    }

    if (mounted) {
      Navigator.pop(context);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => GerdQResultPage(
            score: totalScore,
            answers: List<int>.from(_answers.map((a) => a ?? 0)),
            questions: _questions,
            positivePoints: _positivePoints,
            negativePoints: _negativePoints,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const emeraldGreen = AppColors.doctorPrimary;
    const offWhite = Color(0xFFF8F9FA);
    final currentQ = _questions[_currentStep];

    return Scaffold(
      backgroundColor: offWhite,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Kuesioner GerdQ',
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3.0),
          child: LinearProgressIndicator(
            value: (_currentStep + 1) / _questions.length,
            backgroundColor: Colors.grey.shade100,
            valueColor: const AlwaysStoppedAnimation<Color>(emeraldGreen),
            minHeight: 3,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 24),
              Image.asset(
                'assets/images/gerdQ-icon.png',
                height: 140,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 20),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: emeraldGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'PERTANYAAN ${_currentStep + 1} / ${_questions.length}',
                  style: const TextStyle(
                    color: emeraldGreen,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                currentQ['question'],
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A1C1E),
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                currentQ['hint'],
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 13, color: Colors.grey.shade600, height: 1.4),
              ),
              const SizedBox(height: 28),
              Expanded(
                child: ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  itemCount: _optionLabels.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final bool isSelected = _answers[_currentStep] == index;
                    final int pts = currentQ['type'] == 'positive'
                        ? _positivePoints[index]
                        : _negativePoints[index];
                    return GestureDetector(
                      onTap: () => _handleAnswer(index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        padding: const EdgeInsets.symmetric(
                            vertical: 16, horizontal: 20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? emeraldGreen
                                : Colors.grey.shade200,
                            width: isSelected ? 2.5 : 1,
                          ),
                          boxShadow: [
                            if (isSelected)
                              BoxShadow(
                                color: emeraldGreen.withOpacity(0.12),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              )
                            else
                              BoxShadow(
                                color: Colors.black.withOpacity(0.02),
                                blurRadius: 5,
                                offset: const Offset(0, 2),
                              ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected
                                      ? emeraldGreen
                                      : Colors.grey.shade400,
                                  width: isSelected ? 6 : 2,
                                ),
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                _optionLabels[index],
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.w500,
                                  color: isSelected
                                      ? emeraldGreen
                                      : Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TorsoPainter
// ─────────────────────────────────────────────────────────────────────────────

class TorsoPainter extends CustomPainter {
  final String highlightArea;
  final Color highlightColor;
  TorsoPainter({required this.highlightArea, required this.highlightColor});

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = Colors.grey.shade300
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    final fillPaint = Paint()
      ..color = highlightColor.withOpacity(0.6)
      ..style = PaintingStyle.fill;
    final glowPaint = Paint()
      ..color = highlightColor.withOpacity(0.2)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    final bodyPath = Path()
      ..addOval(Rect.fromLTWH(
          size.width * 0.35, 0, size.width * 0.3, size.height * 0.2))
      ..moveTo(size.width * 0.2, size.height * 0.3)
      ..quadraticBezierTo(size.width * 0.5, size.height * 0.25,
          size.width * 0.8, size.height * 0.3)
      ..lineTo(size.width * 0.75, size.height * 0.8)
      ..lineTo(size.width * 0.25, size.height * 0.8)
      ..close();
    canvas.drawPath(bodyPath, linePaint);

    Offset center = Offset.zero;
    double radius = 15;
    switch (highlightArea) {
      case 'chest':
        center = Offset(size.width * 0.5, size.height * 0.4);
        break;
      case 'throat':
        center = Offset(size.width * 0.5, size.height * 0.22);
        radius = 8;
        break;
      case 'upper_abdomen':
        center = Offset(size.width * 0.5, size.height * 0.55);
        break;
      case 'stomach':
        center = Offset(size.width * 0.5, size.height * 0.65);
        break;
      case 'head':
        center = Offset(size.width * 0.5, size.height * 0.1);
        break;
      case 'mouth':
        center = Offset(size.width * 0.5, size.height * 0.18);
        radius = 5;
        break;
    }
    if (center != Offset.zero) {
      canvas.drawCircle(center, radius + 10, glowPaint);
      canvas.drawCircle(center, radius, fillPaint);
    }
  }

  @override
  bool shouldRepaint(covariant TorsoPainter old) =>
      old.highlightArea != highlightArea;
}

// ─────────────────────────────────────────────────────────────────────────────
// GerdQ Result Page
// ─────────────────────────────────────────────────────────────────────────────

class GerdQResultPage extends StatelessWidget {
  final int score;
  final List<int> answers;
  final List<Map<String, dynamic>> questions;
  final List<int> positivePoints;
  final List<int> negativePoints;

  const GerdQResultPage({
    super.key,
    required this.score,
    required this.answers,
    required this.questions,
    required this.positivePoints,
    required this.negativePoints,
  });

  @override
  Widget build(BuildContext context) {
    const emeraldGreen = AppColors.doctorPrimary;
    const offWhite = Color(0xFFF8F9FA);

    final bool isHighRisk = score >= 8;
    final Color riskColor = isHighRisk ? Colors.red.shade600 : emeraldGreen;
    final Color riskBg =
        isHighRisk ? Colors.red.shade50 : emeraldGreen.withOpacity(0.08);
    final String riskLabel = isHighRisk ? 'TINGGI' : 'RENDAH';

    final String clinicalNote;
    if (score <= 2) {
      clinicalNote =
          'Kemungkinan GERD sangat kecil. Gejala yang Anda alami kemungkinan bukan disebabkan oleh GERD.';
    } else if (score <= 7) {
      clinicalNote =
          'Kemungkinan GERD rendah. Perhatikan gejala Anda dan konsultasikan jika gejala memburuk atau berlanjut.';
    } else if (score <= 10) {
      clinicalNote =
          'Kemungkinan besar Anda menderita GERD. Disarankan segera berkonsultasi dengan dokter untuk konfirmasi diagnosis dan penanganan.';
    } else if (score <= 14) {
      clinicalNote =
          'Gejala GERD Anda cukup berat dan berdampak pada kualitas hidup. Segera temui dokter spesialis gastroenterologi.';
    } else {
      clinicalNote =
          'Gejala sangat berat. Penanganan medis segera sangat dianjurkan untuk mencegah komplikasi seperti esofagitis atau Barrett\'s esophagus.';
    }

    final List<String> labels = ['0 Hari', '1 Hari', '2–3 Hari', '4–7 Hari'];

    return Scaffold(
      backgroundColor: offWhite,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text(
          'Hasil GerdQ',
          style: TextStyle(
              color: Color(0xFF1A1C1E),
              fontWeight: FontWeight.bold,
              fontSize: 18),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Skor utama
              Container(
                padding: const EdgeInsets.symmetric(
                    vertical: 32, horizontal: 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text('Total Skor GerdQ Anda',
                        style: TextStyle(fontSize: 15, color: Colors.grey)),
                    const SizedBox(height: 8),
                    RichText(
                      text: TextSpan(children: [
                        TextSpan(
                          text: '$score',
                          style: TextStyle(
                            fontSize: 72,
                            fontWeight: FontWeight.bold,
                            color: riskColor,
                          ),
                        ),
                        const TextSpan(
                          text: ' / 18',
                          style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w400,
                              color: Colors.grey),
                        ),
                      ]),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 20),
                      decoration: BoxDecoration(
                        color: riskBg,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: riskColor, width: 1.5),
                      ),
                      child: Text(
                        'RISIKO GERD: $riskLabel',
                        style: TextStyle(
                          color: riskColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      clinicalNote,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                          height: 1.6),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border:
                            Border.all(color: Colors.grey.shade200),
                      ),
                      child: const Text(
                        '📌 Berdasarkan paper GerdQ (Jones et al., 2009):\nSkor ≥ 8 = kemungkinan GERD tinggi\n(Sensitivitas 65%, Spesifisitas 71%)',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 11.5,
                            color: Colors.grey,
                            height: 1.6),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ── Breakdown per pertanyaan
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Rincian Jawaban',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1C1E)),
                    ),
                    const SizedBox(height: 14),
                    ...List.generate(questions.length, (i) {
                      final q = questions[i];
                      final ans = answers[i];
                      final pts = q['type'] == 'positive'
                          ? positivePoints[ans]
                          : negativePoints[ans];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(q['icon'] as IconData,
                                size: 18, color: emeraldGreen),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Q${i + 1}: ${labels[ans]}',
                                style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                            Text(
                              '+$pts',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: pts >= 2
                                    ? Colors.red.shade400
                                    : emeraldGreen,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ── CTA Buttons
              SizedBox(
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content:
                              Text('Fitur unduh laporan segera hadir.')),
                    );
                  },
                  icon: const Icon(Icons.download_rounded, size: 20),
                  label: const Text(
                    'Unduh Hasil untuk Dokter',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: emeraldGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const MainNavigation()),
                  ),
                  icon: const Icon(Icons.home_rounded, size: 20),
                  label: const Text(
                    'Masuk ke Beranda',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: emeraldGreen, width: 2),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    foregroundColor: emeraldGreen,
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
