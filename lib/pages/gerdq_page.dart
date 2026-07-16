import 'package:flutter/material.dart';

class GerdQPage extends StatefulWidget {
  const GerdQPage({super.key});

  @override
  State<GerdQPage> createState() => _GerdQPageState();
}

class _GerdQPageState extends State<GerdQPage> {
  // Questions and user answers
  final List<String> questions = [
    "Seberapa sering Anda merasakan sensasi terbakar di dada (heartburn)?",
    "Seberapa sering Anda merasakan isi lambung (cairan/makanan) naik ke kerongkongan atau mulut?",
    "Seberapa sering Anda merasakan nyeri di ulu hati?",
    "Seberapa sering Anda merasa mual?",
    "Seberapa sering Anda mengalami sulit tidur karena gejala heartburn atau regurgitasi?",
    "Seberapa sering Anda meminum obat tambahan untuk gejala heartburn atau regurgitasi (selain obat rutin)?"
  ];

  final List<int> answers = List.filled(6, 0);

  void _calculateResult() {
    // Scoring logic (Simplified GerdQ): 
    // Q1, Q2, Q5, Q6: 0=0, 1=1, 2=2, 3=3
    // Q3, Q4: 0=3, 1=2, 2=1, 3=0
    int score = 0;
    for (int i = 0; i < 6; i++) {
      if (i == 2 || i == 3) {
        score += (3 - answers[i]);
      } else {
        score += answers[i];
      }
    }

    String category;
    Color color;
    if (score <= 7) {
      category = "Resiko Rendah (GERD tidak mungkin)";
      color = Colors.green;
    } else {
      category = "Resiko Tinggi (Sangat mungkin GERD)";
      color = Colors.red;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hasil GerdQ'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Total Skor Anda: $score', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text(category, textAlign: TextAlign.center, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kuesioner GerdQ'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: questions.length + 1,
        itemBuilder: (context, index) {
          if (index == questions.length) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: ElevatedButton(
                onPressed: _calculateResult,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('LIHAT HASIL'),
              ),
            );
          }

          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Pertanyaan ${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 8),
                  Text(questions[index], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    value: answers[index],
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    items: const [
                      DropdownMenuItem(value: 0, child: Text("Tidak pernah (0 hari)")),
                      DropdownMenuItem(value: 1, child: Text("1 hari")),
                      DropdownMenuItem(value: 2, child: Text("2-3 hari")),
                      DropdownMenuItem(value: 3, child: Text("4-7 hari")),
                    ],
                    onChanged: (val) {
                      setState(() {
                        answers[index] = val!;
                      });
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
