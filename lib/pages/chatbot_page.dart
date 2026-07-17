import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gard/constants/app_colors.dart';

class ChatbotPage extends StatefulWidget {
  final String? capturedImagePath;
  const ChatbotPage({super.key, this.capturedImagePath});

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final List<Map<String, dynamic>> _messages = [];
  final TextEditingController _chatController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _messages.add({
      "role": "bot",
      "text": "Halo! Saya GARD AI. Ada yang bisa saya bantu terkait keluhan atau nutrisi lambung Anda hari ini?",
    });

    // If came from camera, auto-send the captured image
    if (widget.capturedImagePath != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _addImageMessage(widget.capturedImagePath!);
      });
    }
  }

  void _addImageMessage(String imagePath) {
    setState(() {
      _messages.add({"role": "user", "image": imagePath});
    });
    _scrollToBottom();

    // Simulate AI analysis after 1.5 seconds
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      final now = DateTime.now();
      String mealContext;
      if (now.hour >= 6 && now.hour < 10) {
        mealContext = "sarapan pagi";
      } else if (now.hour >= 11 && now.hour < 14) {
        mealContext = "makan siang";
      } else if (now.hour >= 17 && now.hour < 20) {
        mealContext = "makan malam";
      } else {
        mealContext = "snack di luar jam makan utama";
      }

      setState(() {
        _messages.add({
          "role": "bot",
          "text": null,
          "analysis": {
            "title": "Analisis Makanan Terdeteksi",
            "mealTime": mealContext,
            "items": ["Karbohidrat sedang", "Protein cukup", "Lemak rendah"],
            "risk": "Rendah",
            "riskColor": "green",
            "recommendations": [
              "✅ Waktu makan ini sesuai untuk kondisi lambung Anda.",
              "⏱ Hindari berbaring minimal 2 jam setelah makan.",
              "💧 Minum air hangat 30 menit setelah makan.",
              "🚫 Hindari konsumsi kopi/teh bersamaan dengan makanan ini.",
            ],
            "note": "Analisis ini bersifat indikatif. Konsultasikan ke dokter untuk diagnosis lebih lanjut.",
          }
        });
        _scrollToBottom();
      });
    });
  }

  void _sendMessage([String? text]) {
    final messageText = text ?? _chatController.text.trim();
    if (messageText.isEmpty) return;

    setState(() {
      _messages.add({"role": "user", "text": messageText});
      if (text == null) _chatController.clear();
      _scrollToBottom();

      Future.delayed(const Duration(seconds: 1), () {
        if (!mounted) return;
        setState(() {
          String response = "Analisis GARD AI: Terima kasih atas pertanyaannya. Jika gejala memberat, harap hubungi tenaga medis.";
          if (messageText.contains("Kambuh")) {
            response = "🚨 GARD Trigger Alert: Gejala kambuh terdeteksi. Disarankan minum air hangat, duduk tegak, dan hindari makanan asam selama 2 jam ke depan.";
          } else if (messageText.contains("Menu")) {
            response = "🥗 Rekomendasi Menu: Konsumsi nasi lembek, sop ayam bening, atau melon. Hindari santan, cabai, dan kafein saat ini.";
          } else if (messageText.contains("Obat")) {
            response = "💊 Info Obat: Antasida atau Sucralfate sering digunakan untuk meredakan asam lambung. Pastikan jeda makan 30 menit sebelum/sesudah minum obat.";
          }
          _messages.add({"role": "bot", "text": response});
          _scrollToBottom();
        });
      });
    });
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 120), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showUploadMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 24),
            const Text('Unggah Media Medis',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildUploadOption(Icons.camera_alt_rounded, 'Kamera', AppColors.primary),
                _buildUploadOption(Icons.photo_library_rounded, 'Galeri', AppColors.darkAccent),
                _buildUploadOption(Icons.description_rounded, 'Dokumen', AppColors.warning),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadOption(IconData icon, String label, Color color) {
    return InkWell(
      onTap: () => Navigator.pop(context),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration:
                BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 12),
          Text(label,
              style:
                  const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildAnalysisCard(Map<String, dynamic> analysis) {
    final Color riskColor = analysis['riskColor'] == 'green'
        ? const Color(0xFF2E7D32)
        : const Color(0xFFE67E22);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
          bottomRight: Radius.circular(4),
          bottomLeft: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.analytics_rounded,
                    color: AppColors.primary, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  analysis['title'],
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: AppColors.darkAccent),
                ),
              ),
            ],
          ),
          const Divider(height: 20),

          // Meal time
          Row(
            children: [
              const Icon(Icons.access_time_rounded,
                  size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Text(
                'Terdeteksi sebagai: ${analysis['mealTime']}',
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Detected items
          const Text('Kandungan Terdeteksi:',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkAccent)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: (analysis['items'] as List<String>)
                .map((item) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.softAccent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(item,
                          style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600)),
                    ))
                .toList(),
          ),
          const SizedBox(height: 12),

          // Risk level
          Row(
            children: [
              const Text('Tingkat Risiko GERD: ',
                  style: TextStyle(
                      fontSize: 12, color: AppColors.textSecondary)),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: riskColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  analysis['risk'],
                  style: TextStyle(
                      fontSize: 11,
                      color: riskColor,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Recommendations
          const Text('Rekomendasi:',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkAccent)),
          const SizedBox(height: 6),
          ...((analysis['recommendations'] as List<String>)
              .map((rec) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(rec,
                        style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            height: 1.4)),
                  ))),
          const SizedBox(height: 10),

          // Note
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              analysis['note'],
              style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textHint,
                  fontStyle: FontStyle.italic),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        flexibleSpace: Container(
            decoration:
                const BoxDecoration(gradient: AppColors.primaryGradient)),
        title: const Text('GARD AI Assistant',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.white)),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(20),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isBot = msg['role'] == 'bot';

                // Image message from user
                if (msg['image'] != null) {
                  return Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      constraints: BoxConstraints(
                          maxWidth:
                              MediaQuery.of(context).size.width * 0.65),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 10)
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.file(
                          File(msg['image']),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  );
                }

                // Analysis card from bot
                if (msg['analysis'] != null) {
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      constraints: BoxConstraints(
                          maxWidth:
                              MediaQuery.of(context).size.width * 0.85),
                      child: _buildAnalysisCard(msg['analysis']),
                    ),
                  );
                }

                // Normal text message
                return Align(
                  alignment:
                      isBot ? Alignment.centerLeft : Alignment.centerRight,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 14),
                    constraints: BoxConstraints(
                        maxWidth:
                            MediaQuery.of(context).size.width * 0.75),
                    decoration: BoxDecoration(
                      color: isBot ? AppColors.card : AppColors.primary,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(20),
                        topRight: const Radius.circular(20),
                        bottomLeft: Radius.circular(isBot ? 4 : 20),
                        bottomRight: Radius.circular(isBot ? 20 : 4),
                      ),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 10)
                      ],
                    ),
                    child: Text(
                      msg['text'] ?? '',
                      style: TextStyle(
                        color: isBot
                            ? AppColors.textPrimary
                            : Colors.white,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  _buildQuickTemplate('🚨', 'Asam Lambung Kambuh',
                      AppColors.primary),
                  _buildQuickTemplate('🥗', 'Rekomendasi Menu',
                      AppColors.primary),
                  _buildQuickTemplate('💊', 'Info Obat Lambung',
                      AppColors.primary),
                ],
              ),
            ),
          ),

          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28)),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 12,
                    offset: const Offset(0, -2))
              ],
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: _showUploadMenu,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        color: AppColors.softAccent,
                        borderRadius: BorderRadius.circular(14)),
                    child: const Icon(Icons.add_rounded,
                        color: AppColors.primary, size: 24),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.softAccent)),
                    child: TextField(
                      controller: _chatController,
                      decoration: const InputDecoration(
                        hintText: 'Ketik pesan Anda...',
                        hintStyle: TextStyle(
                            fontSize: 13, color: AppColors.textHint),
                        border: InputBorder.none,
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () => _sendMessage(),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                        color: AppColors.primary, shape: BoxShape.circle),
                    child: const Icon(Icons.send_rounded,
                        color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickTemplate(String emoji, String text, Color color) {
    return GestureDetector(
      onTap: () => _sendMessage(text),
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.4), width: 1.5),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 8),
            Text(text,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: color)),
          ],
        ),
      ),
    );
  }
}
