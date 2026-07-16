import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class CameraPage extends StatefulWidget {
  final CameraDescription camera;
  const CameraPage({super.key, required this.camera});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  bool _isFlashOn = false;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.max,
      enableAudio: false,
    );
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleFlash() async {
    if (!_controller.value.isInitialized) return;
    setState(() {
      _isFlashOn = !_isFlashOn;
    });
    await _controller.setFlashMode(
      _isFlashOn ? FlashMode.torch : FlashMode.off,
    );
  }

  void _takePicture() async {
    try {
      await _initializeControllerFuture;
      final image = await _controller.takePicture();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Foto berhasil dianalisis: ${image.name}'),
            backgroundColor: const Color(0xFF006D32),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint("Gagal mengambil gambar: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    const emeraldGreen = Color(0xFF006D32);
    const neonGreen = Color(0xFF39FF14);

    return Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
              children: [
                // 1. Camera Preview (Full Screen)
                Positioned.fill(
                  child: CameraPreview(_controller),
                ),

                // 2. Translucent Overlay with Cutout Scanner Frame
                Positioned.fill(
                  child: ColorFiltered(
                    colorFilter: ColorFilter.mode(
                      Colors.black.withOpacity(0.6),
                      BlendMode.srcOut,
                    ),
                    child: Stack(
                      children: [
                        Container(
                          decoration: const BoxDecoration(
                            color: Colors.black,
                            backgroundBlendMode: BlendMode.dstOut,
                          ),
                        ),
                        Center(
                          child: Container(
                            width: 280,
                            height: 280,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // 3. Esthetic Scanning Frame Border
                Center(
                  child: Container(
                    width: 280,
                    height: 280,
                    decoration: BoxDecoration(
                      border: Border.all(color: neonGreen.withOpacity(0.5), width: 1.5),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Stack(
                      children: [
                        _buildCorner(Alignment.topLeft, neonGreen),
                        _buildCorner(Alignment.topRight, neonGreen),
                        _buildCorner(Alignment.bottomLeft, neonGreen),
                        _buildCorner(Alignment.bottomRight, neonGreen),
                      ],
                    ),
                  ),
                ),

                // 4. Top Navigation Bar
                Positioned(
                  top: 50,
                  left: 0,
                  right: 0,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.close_rounded, color: Colors.white, size: 30),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const Text(
                          'Pindai Makanan',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(width: 48), // Balancing spacer
                      ],
                    ),
                  ),
                ),

                // 5. Bottom Control Bar (Curved White Container)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 40),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(40),
                        topRight: Radius.circular(40),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Left Placeholder for balance
                        const SizedBox(width: 48),

                        // Main Capture Button
                        GestureDetector(
                          onTap: _takePicture,
                          child: Container(
                            width: 80,
                            height: 80,
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: emeraldGreen.withOpacity(0.2), width: 2),
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(color: emeraldGreen, width: 4),
                                boxShadow: [
                                  BoxShadow(
                                    color: emeraldGreen.withOpacity(0.2),
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                  )
                                ],
                              ),
                              child: const Icon(Icons.camera_alt_rounded, color: emeraldGreen, size: 32),
                            ),
                          ),
                        ),

                        // Flash Toggle Button
                        IconButton(
                          onPressed: _toggleFlash,
                          icon: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: Icon(
                              _isFlashOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                              key: ValueKey(_isFlashOn),
                              color: _isFlashOn ? Colors.orangeAccent : Colors.grey.shade400,
                              size: 28,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(color: emeraldGreen),
            );
          }
        },
      ),
    );
  }

  Widget _buildCorner(Alignment alignment, Color color) {
    const double cornerSize = 30;
    const double thickness = 4;
    
    return Align(
      alignment: alignment,
      child: Container(
        width: cornerSize,
        height: cornerSize,
        decoration: BoxDecoration(
          border: Border(
            top: (alignment == Alignment.topLeft || alignment == Alignment.topRight)
                ? BorderSide(color: color, width: thickness)
                : BorderSide.none,
            bottom: (alignment == Alignment.bottomLeft || alignment == Alignment.bottomRight)
                ? BorderSide(color: color, width: thickness)
                : BorderSide.none,
            left: (alignment == Alignment.topLeft || alignment == Alignment.bottomLeft)
                ? BorderSide(color: color, width: thickness)
                : BorderSide.none,
            right: (alignment == Alignment.topRight || alignment == Alignment.bottomRight)
                ? BorderSide(color: color, width: thickness)
                : BorderSide.none,
          ),
        ),
      ),
    );
  }
}
