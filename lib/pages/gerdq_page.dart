import 'package:flutter/material.dart';

class GerdQPage extends StatefulWidget {
  const GerdQPage({super.key});

  @override
  State<GerdQPage> createState() => _GerdQPageState();
}

class _GerdQPageState extends State<GerdQPage> {
  int _currentStep = 0;
  final List<int?> _answers = List.filled(6, null);

  final List<Map<String, dynamic>> _questions = [
    {
      'question': 'Seberapa sering Anda merasa nyeri dada terbakar (heartburn)?',
      'type': 'positive',
      'icon': Icons.local_fire_department_rounded,
    },
    {
      'question': 'Seberapa sering Anda merasa ada isi lambung yang naik ke arah tenggorokan (regurgitasi)?',
      'type': 'positive',
      'icon': Icons.keyboard_double_arrow_up_rounded,
    },
    {
      'question': 'Seberapa sering Anda merasa nyeri di ulu hati?',
      'type': 'negative',
      'icon': Icons.fmd_bad_rounded,
    },
    {
      'question': 'Seberapa sering Anda merasa mual?',
      'type': 'negative',
      'icon': Icons.sick_rounded,
    },
    {
      'question': 'Seberapa sering Anda mengalami gangguan tidur akibat rasa terbakar atau lambung naik?',
      'type': 'positive',
      'icon': Icons.bedtime_rounded,
    },
    {
      'question': 'Seberapa sering Anda mengonsumsi obat tambahan (seperti Antasida) untuk gejala tersebut?',
      'type': 'positive',
      'icon': Icons.medication_rounded,
    },
  ];

  final List<String> _options = [
    '0 Hari (Tidak Pernah)',
    '1 Hari',
    '2-3 Hari',
    '4-7 Hari',
  ];

  void _handleAnswer(int optionIndex) {
    setState(() {
      _answers[_currentStep] = optionIndex;
    });

    Future.delayed(const Duration(milliseconds: 300), () {
      if (_currentStep < _questions.length - 1) {
        setState(() {
          _currentStep++;
        });
      } else {
        _showResult();
      }
    });
  }

  void _showResult() {
    int totalScore = 0;
    for (int i = 0; i < _questions.length; i++) {
      int score = 0;
      int answerIndex = _answers[i]!;
      if (_questions[i]['type'] == 'positive') {
        score = answerIndex;
      } else {
        score = 3 - answerIndex;
      }
      totalScore += score;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => GerdQResultPage(score: totalScore),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const emeraldGreen = Color(0xFF006D32);
    const offWhite = Color(0xFFF8F9FA);

    return Scaffold(
      backgroundColor: offWhite,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'GerdQ Kuesioner',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2.0),
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
              const SizedBox(height: 30),
              SizedBox(
                height: 140,
                width: 100,
                child: CustomPaint(
                  painter: TorsoPainter(
                    highlightArea: _getHighlightArea(_currentStep),
                    highlightColor: emeraldGreen,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
              const SizedBox(height: 20),
              Text(
                _questions[_currentStep]['question'],
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A1C1E),
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 40),
              Expanded(
                child: ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  itemCount: _options.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    bool isSelected = _answers[_currentStep] == index;
                    return GestureDetector(
                      onTap: () => _handleAnswer(index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? emeraldGreen : Colors.grey.shade200,
                            width: isSelected ? 2.5 : 1,
                          ),
                          boxShadow: [
                            if (isSelected)
                              BoxShadow(
                                color: emeraldGreen.withOpacity(0.1),
                                blurRadius: 10,
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
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected ? emeraldGreen : Colors.grey.shade400,
                                  width: isSelected ? 7 : 2,
                                ),
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                _options[index],
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                  color: isSelected ? emeraldGreen : Colors.black87,
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

  String _getHighlightArea(int step) {
    switch (step) {
      case 0: return 'chest';
      case 1: return 'throat';
      case 2: return 'upper_abdomen';
      case 3: return 'stomach';
      case 4: return 'head';
      case 5: return 'mouth';
      default: return 'none';
    }
  }
}

class TorsoPainter extends CustomPainter {
  final String highlightArea;
  final Color highlightColor;

  TorsoPainter({required this.highlightArea, required this.highlightColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade300
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final highlightPaint = Paint()
      ..color = highlightColor.withOpacity(0.6)
      ..style = PaintingStyle.fill;

    final highlightGlow = Paint()
      ..color = highlightColor.withOpacity(0.2)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    final path = Path();
    path.moveTo(size.width * 0.5, size.height * 0.1); 
    path.addOval(Rect.fromLTWH(size.width * 0.35, 0, size.width * 0.3, size.height * 0.2)); 
    
    path.moveTo(size.width * 0.45, size.height * 0.2);
    path.lineTo(size.width * 0.55, size.height * 0.2);
    
    path.moveTo(size.width * 0.2, size.height * 0.3);
    path.quadraticBezierTo(size.width * 0.5, size.height * 0.25, size.width * 0.8, size.height * 0.3);
    path.lineTo(size.width * 0.75, size.height * 0.8);
    path.lineTo(size.width * 0.25, size.height * 0.8);
    path.close();

    canvas.drawPath(path, paint);

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
      canvas.drawCircle(center, radius + 10, highlightGlow);
      canvas.drawCircle(center, radius, highlightPaint);
    }
  }

  @override
  bool shouldRepaint(covariant TorsoPainter oldDelegate) => 
      oldDelegate.highlightArea != highlightArea;
}

class GerdQResultPage extends StatelessWidget {
  final int score;
  const GerdQResultPage({super.key, required this.score});

  @override
  Widget build(BuildContext context) {
    const emeraldGreen = Color(0xFF006D32);
    const offWhite = Color(0xFFF8F9FA);
    bool isHighRisk = score >= 8;

    return Scaffold(
      backgroundColor: offWhite,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Hasil Analisis GerdQ',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3142),
                ),
              ),
              const SizedBox(height: 32),
              
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
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
                    const Text(
                      'Total Skor Anda',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$score',
                      style: const TextStyle(
                        fontSize: 64,
                        fontWeight: FontWeight.bold,
                        color: emeraldGreen,
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                      decoration: BoxDecoration(
                        color: isHighRisk ? Colors.red.shade50 : emeraldGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: isHighRisk ? Colors.red : emeraldGreen,
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        isHighRisk ? 'STATUS RESIKO GERD: TINGGI' : 'STATUS RESIKO GERD: RENDAH',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isHighRisk ? Colors.red : emeraldGreen,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    Text(
                      isHighRisk 
                        ? 'Skor Anda menunjukkan kemungkinan tinggi menderita GERD. Disarankan untuk segera berkonsultasi dengan tenaga medis.'
                        : 'Skor Anda menunjukkan kemungkinan rendah menderita GERD. Tetap jaga pola makan dan gaya hidup sehat.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey.shade700,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              
              const Spacer(),
              
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Mengunduh hasil laporan...')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: emeraldGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Unduh Hasil untuk Dokter', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: emeraldGreen, width: 2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    foregroundColor: emeraldGreen,
                  ),
                  child: const Text('Kembali ke Beranda', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
