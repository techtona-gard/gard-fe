import 'dart:io';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:gard/constants/app_colors.dart';
import 'package:gard/pages/chatbot_page.dart';

class CameraPage extends StatefulWidget {
  final CameraDescription camera;
  const CameraPage({super.key, required this.camera});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage>
    with SingleTickerProviderStateMixin {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  bool _isFlashOn = false;
  bool _isCapturing = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.high,
      enableAudio: false,
    );
    _initializeControllerFuture = _controller.initialize();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _toggleFlash() async {
    if (!_controller.value.isInitialized) return;
    setState(() => _isFlashOn = !_isFlashOn);
    await _controller.setFlashMode(
      _isFlashOn ? FlashMode.torch : FlashMode.off,
    );
  }

  void _takePicture() async {
    if (_isCapturing) return;
    try {
      await _initializeControllerFuture;
      setState(() => _isCapturing = true);
      final image = await _controller.takePicture();

      // Konversi file ke base64 untuk dikirim ke backend API
      final bytes = await File(image.path).readAsBytes();
      final base64Image = base64Encode(bytes);

      setState(() => _isCapturing = false);
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ChatbotPage(
              capturedImagePath: image.path,
              capturedImageBase64: base64Image,
            ),
          ),
        );
      }
    } catch (e) {
      setState(() => _isCapturing = false);
      debugPrint("Gagal mengambil gambar: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    const frameSize = 270.0;
    const frameRadius = 24.0;

    return Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: AppColors.primary),
                  SizedBox(height: 16),
                  Text('Memuat kamera...', style: TextStyle(color: Colors.white54, fontSize: 14)),
                ],
              ),
            );
          }

          return Stack(
            children: [
              // ── Full-screen camera preview (Scaled to prevent squishing) ──────
              Positioned.fill(
                child: Builder(
                  builder: (context) {
                    final size = MediaQuery.of(context).size;
                    final deviceRatio = size.width / size.height;
                    
                    // Fallback to 1.0 if not initialized or previewSize is null
                    double scale = 1.0;
                    if (_controller.value.isInitialized && _controller.value.previewSize != null) {
                      final previewSize = _controller.value.previewSize!;
                      // Swap width/height for portrait
                      final cameraRatio = previewSize.height / previewSize.width;
                      
                      scale = deviceRatio / cameraRatio;
                      if (scale < 1.0) {
                        scale = 1.0 / scale;
                      }
                    }
                    
                    return Transform.scale(
                      scale: scale,
                      child: Center(
                        child: CameraPreview(_controller),
                      ),
                    );
                  },
                ),
              ),

              // ── Dark overlay except scan frame ──────────────────────────
              Positioned.fill(
                child: ClipPath(
                  clipper: _ScanFrameClipper(
                    frameSize: frameSize,
                    radius: frameRadius,
                    offsetY: -60,
                  ),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                    child: Container(color: Colors.black.withOpacity(0.55)),
                  ),
                ),
              ),

              // ── Scan frame border + corners ─────────────────────────────
              Center(
                child: Transform.translate(
                  offset: const Offset(0, -60),
                  child: SizedBox(
                    width: frameSize,
                    height: frameSize,
                    child: AnimatedBuilder(
                      animation: _pulseAnim,
                      builder: (context, _) => Stack(
                        children: [
                          // Border
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: AppColors.primary.withOpacity(_pulseAnim.value * 0.6),
                                width: 1.5,
                              ),
                              borderRadius: BorderRadius.circular(frameRadius),
                            ),
                          ),
                          // Corner brackets
                          _buildCorner(Alignment.topLeft, AppColors.primary),
                          _buildCorner(Alignment.topRight, AppColors.primary),
                          _buildCorner(Alignment.bottomLeft, AppColors.primary),
                          _buildCorner(Alignment.bottomRight, AppColors.primary),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // ── Top bar ─────────────────────────────────────────────────
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Row(
                      children: [
                        _buildIconBtn(
                          icon: Icons.close_rounded,
                          onTap: () => Navigator.pop(context),
                        ),
                        const Spacer(),
                        // Flash toggle
                        _buildIconBtn(
                          icon: _isFlashOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                          onTap: _toggleFlash,
                          active: _isFlashOn,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Hint label above frame ──────────────────────────────────
              Positioned(
                left: 0,
                right: 0,
                top: size.height / 2 - frameSize / 2 - 60 - 40,
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Pindai Makanan',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            letterSpacing: 0.5),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Hint label below frame ──────────────────────────────────
              Positioned(
                left: 0,
                right: 0,
                top: size.height / 2 + frameSize / 2 - 60 + 16,
                child: Center(
                  child: Text(
                    'Arahkan kamera ke makanan Anda',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                ),
              ),

              // ── Bottom control panel ─────────────────────────────────────
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(36),
                    topRight: Radius.circular(36),
                  ),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(32, 24, 32, 48),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.55),
                        border: Border(
                          top: BorderSide(
                            color: AppColors.primary.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Gallery button
                          _buildBottomAction(
                            icon: Icons.photo_library_rounded,
                            label: 'Galeri',
                            onTap: () {},
                          ),

                          // Shutter button
                          GestureDetector(
                            onTap: _takePicture,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              width: _isCapturing ? 68 : 74,
                              height: _isCapturing ? 68 : 74,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _isCapturing
                                    ? AppColors.primary.withOpacity(0.6)
                                    : AppColors.primary,
                                border: Border.all(color: Colors.white, width: 3),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withOpacity(0.5),
                                    blurRadius: 20,
                                    spreadRadius: 4,
                                  ),
                                ],
                              ),
                              child: _isCapturing
                                  ? const Padding(
                                      padding: EdgeInsets.all(20),
                                      child: CircularProgressIndicator(
                                          color: Colors.white, strokeWidth: 2),
                                    )
                                  : const Icon(Icons.camera_alt_rounded,
                                      color: Colors.white, size: 30),
                            ),
                          ),

                          // Flip camera button (placeholder)
                          _buildBottomAction(
                            icon: Icons.flip_camera_ios_rounded,
                            label: 'Balik',
                            onTap: () {},
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildIconBtn({
    required IconData icon,
    required VoidCallback onTap,
    bool active = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: active
              ? AppColors.primary.withOpacity(0.85)
              : Colors.black.withOpacity(0.45),
          shape: BoxShape.circle,
          border: Border.all(
              color: active ? AppColors.primary : Colors.white.withOpacity(0.2),
              width: 1),
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }

  Widget _buildBottomAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(height: 6),
          Text(label,
              style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 11,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildCorner(Alignment alignment, Color color) {
    const size = 26.0;
    const thickness = 3.5;
    const r = 10.0;
    final isLeft = alignment == Alignment.topLeft || alignment == Alignment.bottomLeft;
    final isTop = alignment == Alignment.topLeft || alignment == Alignment.topRight;
    return Align(
      alignment: alignment,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          border: Border(
            top: isTop ? BorderSide(color: color, width: thickness) : BorderSide.none,
            bottom: !isTop ? BorderSide(color: color, width: thickness) : BorderSide.none,
            left: isLeft ? BorderSide(color: color, width: thickness) : BorderSide.none,
            right: !isLeft ? BorderSide(color: color, width: thickness) : BorderSide.none,
          ),
          borderRadius: BorderRadius.only(
            topLeft: (isTop && isLeft) ? const Radius.circular(r) : Radius.zero,
            topRight: (isTop && !isLeft) ? const Radius.circular(r) : Radius.zero,
            bottomLeft: (!isTop && isLeft) ? const Radius.circular(r) : Radius.zero,
            bottomRight: (!isTop && !isLeft) ? const Radius.circular(r) : Radius.zero,
          ),
        ),
      ),
    );
  }
}

class _ScanFrameClipper extends CustomClipper<Path> {
  final double frameSize;
  final double radius;
  final double offsetY;

  const _ScanFrameClipper({
    required this.frameSize,
    required this.radius,
    this.offsetY = 0,
  });

  @override
  Path getClip(Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2 + offsetY;
    final l = cx - frameSize / 2;
    final t = cy - frameSize / 2;
    return Path.combine(
      PathOperation.difference,
      Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height)),
      Path()
        ..addRRect(RRect.fromRectAndRadius(
          Rect.fromLTWH(l, t, frameSize, frameSize),
          Radius.circular(radius),
        )),
    );
  }

  @override
  bool shouldReclip(_ScanFrameClipper old) =>
      old.frameSize != frameSize ||
      old.radius != radius ||
      old.offsetY != offsetY;
}
