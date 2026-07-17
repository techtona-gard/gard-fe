import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gard/constants/app_colors.dart';
import 'package:gard/services/agent_service.dart';
import 'package:gard/services/supabase_service.dart';
import 'package:gard/services/health_connect_service.dart';
import 'package:gard/main.dart';
import 'package:gard/pages/camera_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';

class ChatbotPage extends StatefulWidget {
  final String? capturedImagePath;
  final String? capturedImageBase64;
  const ChatbotPage({super.key, this.capturedImagePath, this.capturedImageBase64});

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final List<Map<String, dynamic>> _messages = [];
  final TextEditingController _chatController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Konteks pengguna (diload saat init)
  Map<String, dynamic>? _profileData;
  Map<String, dynamic>? _healthSummary;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _messages.add({
      "role": "bot",
      "text": "Halo! Saya GARD AI. Ada yang bisa saya bantu terkait keluhan atau nutrisi lambung Anda hari ini?",
    });
    _loadContext();

    // If came from camera, auto-send the captured image
    if (widget.capturedImagePath != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _addImageMessage(
          widget.capturedImagePath!,
          base64: widget.capturedImageBase64,
        );
      });
    }
  }

  /// Load profil + health data pengguna sebagai konteks untuk AI
  Future<void> _loadContext() async {
    try {
      final profile = await SupabaseService.instance.getProfileData();
      final healthService = HealthService();
      await healthService.init();
      final hasHealth = await healthService.hasPermissions();
      Map<String, dynamic>? health;
      if (hasHealth) {
        health = await healthService.getTodaySummary();
      }
      if (mounted) {
        setState(() {
          _profileData = profile;
          _healthSummary = health;
        });
      }
    } catch (e) {
      debugPrint('ChatbotPage: failed to load context: $e');
    }
  }

  void _addImageMessage(String imagePath, {String? base64}) {
    setState(() {
      _messages.add({"role": "user", "image": imagePath});
      _messages.add({"role": "bot", "loading": true});
    });
    _scrollToBottom();

    if (base64 != null) {
      _sendImageToApi(base64);
    } else {
      _simulateAnalysis();
    }
  }

  /// Kirim gambar ke /api/v1/scan-food dengan base64
  Future<void> _sendImageToApi(String base64Image) async {
    final userId =
        Supabase.instance.client.auth.currentUser?.id ?? 'anonymous';

    final result = await AgentService.instance.scanFood(
      userId: userId,
      imageBase64: base64Image,
      chatInput: 'Apakah makanan ini aman untuk penderita GERD? Berikan analisis kandungan nutrisinya.',
    );

    if (!mounted) return;
    setState(() {
      _messages.removeWhere((m) => m['loading'] == true);
      _messages.add({
        'role': 'bot',
        'text': result.analysisText,
      });
    });
    _scrollToBottom();
  }

  void _simulateAnalysis() {
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      setState(() {
        _messages.removeWhere((m) => m['loading'] == true);
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
        _messages.add({
          "role": "bot",
          "text": null,
          "analysis": {
            "title": "Analisis Makanan (Simulasi)",
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
            "note": "Ini adalah simulasi. Hubungkan ke backend API untuk analisis nyata.",
          }
        });
        _scrollToBottom();
      });
    });
  }

  /// Kirim pesan teks ke /api/v1/chat (AI Agent)
  void _sendMessage([String? text]) {
    final messageText = text ?? _chatController.text.trim();
    if (messageText.isEmpty || _isLoading) return;

    setState(() {
      _messages.add({"role": "user", "text": messageText});
      _messages.add({"role": "bot", "loading": true});
      if (text == null) _chatController.clear();
      _isLoading = true;
    });
    _scrollToBottom();

    _callChatApi(messageText);
  }

  Future<void> _callChatApi(String messageText) async {
    final userId =
        Supabase.instance.client.auth.currentUser?.id ?? 'anonymous';

    final result = await AgentService.instance.sendChat(
      userId: userId,
      chatInput: messageText,
      healthSummary: _healthSummary,
      profileData: _profileData,
    );

    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _messages.removeWhere((m) => m['loading'] == true);
      _messages.add({'role': 'bot', 'text': result.message});
    });
    _scrollToBottom();
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

  Future<void> _pickImageFromGallery() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        final base64String = base64Encode(bytes);
        _addImageMessage(pickedFile.path, base64: base64String);
      }
    } catch (e) {
      debugPrint('Error picking image from gallery: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat gambar: $e')),
        );
      }
    }
  }

  void _openCamera() {
    if (cameras.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => CameraPage(camera: cameras.first)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kamera tidak tersedia')),
      );
    }
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

                // Loading bubble (waiting for API response)
                if (msg['loading'] == true) {
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                          bottomLeft: Radius.circular(4),
                          bottomRight: Radius.circular(20),
                        ),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 10)
                        ],
                      ),
                      child: const TypingIndicator(),
                    ),
                  );
                }

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
                  onTap: _openCamera,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle),
                    child: const Icon(Icons.camera_alt_rounded,
                        color: Colors.white, size: 22),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _pickImageFromGallery,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        shape: BoxShape.circle),
                    child: const Icon(Icons.photo_library_rounded,
                        color: AppColors.primary, size: 22),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey.shade200)),
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

class TypingIndicator extends StatefulWidget {
  const TypingIndicator({super.key});

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    _animations = List.generate(3, (index) {
      final start = index * 0.2;
      final end = start + 0.6;
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(start, end, curve: Curves.easeInOut),
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (index) {
          return AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final val = _animations[index].value;
              final offset = -6.0 * (val > 0.5 ? (1.0 - val) * 2 : val * 2);
              return Transform.translate(
                offset: Offset(0, offset),
                child: Container(
                  width: 7,
                  height: 7,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
