import 'package:flutter/material.dart';

class ChatbotPage extends StatefulWidget {
  const ChatbotPage({super.key});

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final List<Map<String, String>> _messages = [
    {"role": "bot", "text": "Halo! Saya GARD AI. Ada yang bisa saya bantu terkait keluhan atau nutrisi lambung Anda hari ini?"},
  ];
  final TextEditingController _chatController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  void _sendMessage([String? text]) {
    final messageText = text ?? _chatController.text.trim();
    if (messageText.isEmpty) return;

    setState(() {
      _messages.add({"role": "user", "text": messageText});
      if (text == null) _chatController.clear();
      
      _scrollToBottom();

      // GARD AI Logic
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
    Future.delayed(const Duration(milliseconds: 100), () {
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
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 24),
            const Text('Unggah Media Medis', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildUploadOption(Icons.camera_alt_rounded, 'Kamera', const Color(0xFF006D32)),
                _buildUploadOption(Icons.photo_library_rounded, 'Galeri', Colors.blue),
                _buildUploadOption(Icons.description_rounded, 'Dokumen', Colors.orange),
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
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 12),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        ],
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
        title: const Text('GARD AI Assistant', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
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
                return Align(
                  alignment: isBot ? Alignment.centerLeft : Alignment.centerRight,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                    decoration: BoxDecoration(
                      color: isBot ? Colors.white : emeraldGreen,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(20),
                        topRight: const Radius.circular(20),
                        bottomLeft: Radius.circular(isBot ? 4 : 20),
                        bottomRight: Radius.circular(isBot ? 20 : 4),
                      ),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
                    ),
                    child: Text(
                      msg['text']!,
                      style: TextStyle(
                        color: isBot ? const Color(0xFF2D3142) : Colors.white,
                        fontSize: 15,
                        height: 1.5,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          
          // GARD Trigger & Template Pertanyaan (Horizontal Chips)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  _buildQuickTemplate('🚨', 'Asam Lambung Kambuh', emeraldGreen),
                  _buildQuickTemplate('🥗', 'Rekomendasi Menu', emeraldGreen),
                  _buildQuickTemplate('💊', 'Info Obat Lambung', emeraldGreen),
                ],
              ),
            ),
          ),

          // Bottom Chat Bar
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32)),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))],
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: _showUploadMenu,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: offWhite, borderRadius: BorderRadius.circular(15)),
                    child: const Icon(Icons.add_rounded, color: emeraldGreen, size: 26),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(color: offWhite, borderRadius: BorderRadius.circular(20)),
                    child: TextField(
                      controller: _chatController,
                      decoration: const InputDecoration(
                        hintText: 'Ketik pesan Anda...',
                        hintStyle: TextStyle(fontSize: 14, color: Colors.grey),
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
                    decoration: const BoxDecoration(color: emeraldGreen, shape: BoxShape.circle),
                    child: const Icon(Icons.send_rounded, color: Colors.white, size: 22),
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
            Text(text, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }
}
