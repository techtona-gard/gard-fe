import 'package:flutter/material.dart';
import 'package:gard/constants/app_colors.dart';
import 'package:gard/main.dart';
import 'package:gard/services/supabase_service.dart';
import 'package:gard/pages/login_page.dart';
import 'package:gard/pages/gerdq_page.dart';

class CompleteProfilePage extends StatefulWidget {
  const CompleteProfilePage({super.key});

  @override
  State<CompleteProfilePage> createState() => _CompleteProfilePageState();
}

class _CompleteProfilePageState extends State<CompleteProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _heightCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _birthDateCtrl = TextEditingController();
  final _emergencyWaCtrl = TextEditingController();
  DateTime? _selectedBirthDate;

  bool _isSaving = false;
  late Map<String, String> _userInfo;

  @override
  void initState() {
    super.initState();
    _userInfo = SupabaseService.instance.getMockUserInfo();
  }

  @override
  void dispose() {
    _heightCtrl.dispose();
    _weightCtrl.dispose();
    _birthDateCtrl.dispose();
    _emergencyWaCtrl.dispose();
    super.dispose();
  }

  bool _isAtLeast13YearsOld(DateTime birthDate) {
    final today = DateTime.now();
    var age = today.year - birthDate.year;
    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age >= 13;
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedBirthDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan pilih tanggal lahir Anda.')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final height = num.parse(_heightCtrl.text);
      final weight = num.parse(_weightCtrl.text);

      await SupabaseService.instance.saveProfile(
        name: _userInfo['name'] ?? 'Pengguna',
        height: height,
        weight: weight,
        birthDate: "${_selectedBirthDate!.year}-${_selectedBirthDate!.month.toString().padLeft(2, '0')}-${_selectedBirthDate!.day.toString().padLeft(2, '0')}",
        emergencyWa: _emergencyWaCtrl.text,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                SizedBox(width: 10),
                Text('Profil berhasil dilengkapi!'),
              ],
            ),
            backgroundColor: AppColors.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );

        // Redirect to GerdQ questionnaire before entering main app
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const GerdQPage()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan data: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _selectBirthDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)), // default to 18 years ago
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedBirthDate = picked;
        final months = [
          'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
          'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
        ];
        _birthDateCtrl.text = "${picked.day} ${months[picked.month - 1]} ${picked.year}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ── Header Card ─────────────────────────────────────────────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.06),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Logo full
                      Image.asset(
                        'assets/images/logo_full.png',
                        width: 100,
                        height: 50,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Lengkapi Profil Anda',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkAccent,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Kami membutuhkan informasi tambahan berikut untuk membantu memantau kesehatan lambung Anda.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                          height: 1.5,
                        ),
                      ),

                      const SizedBox(height: 24),
                      const Divider(color: AppColors.softAccent),
                      const SizedBox(height: 16),

                      // Read-only Google User Information Section
                      Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              _userInfo['avatar']!,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const CircleAvatar(
                                radius: 25,
                                backgroundColor: AppColors.softAccent,
                                child: Icon(Icons.person, color: AppColors.primary),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _userInfo['name']!,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: AppColors.darkAccent,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _userInfo['email']!,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 28),

                      // ── Inputs Form ────────────────────────────────────────
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            // Height Field
                            _buildTextField(
                              controller: _heightCtrl,
                              label: 'Tinggi Badan (cm)',
                              icon: Icons.height_rounded,
                              keyboardType: TextInputType.number,
                              validator: (v) {
                                if (v == null || v.isEmpty) return 'Tinggi badan wajib diisi';
                                final val = double.tryParse(v);
                                if (val == null) return 'Harus berupa angka';
                                if (val < 50 || val > 300) return 'Tinggi harus di antara 50 - 300 cm';
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Weight Field
                            _buildTextField(
                              controller: _weightCtrl,
                              label: 'Berat Badan (kg)',
                              icon: Icons.monitor_weight_outlined,
                              keyboardType: TextInputType.number,
                              validator: (v) {
                                if (v == null || v.isEmpty) return 'Berat badan wajib diisi';
                                final val = double.tryParse(v);
                                if (val == null) return 'Harus berupa angka';
                                if (val < 10 || val > 500) return 'Berat harus di antara 10 - 500 kg';
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Date of Birth Field (DatePicker)
                            _buildTextField(
                              controller: _birthDateCtrl,
                              label: 'Tanggal Lahir',
                              icon: Icons.cake_rounded,
                              readOnly: true,
                              onTap: _selectBirthDate,
                              validator: (v) {
                                if (v == null || v.isEmpty) return 'Tanggal lahir wajib diisi';
                                if (_selectedBirthDate == null) return 'Silakan pilih tanggal';
                                if (_selectedBirthDate!.isAfter(DateTime.now())) {
                                  return 'Tanggal lahir tidak boleh di masa depan';
                                }
                                if (!_isAtLeast13YearsOld(_selectedBirthDate!)) {
                                  return 'Minimal usia adalah 13 tahun';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 16),
                            
                            // Emergency WA Field
                            _buildTextField(
                              controller: _emergencyWaCtrl,
                              label: 'No. WA Darurat (Emergency)',
                              icon: Icons.phone_rounded,
                              keyboardType: TextInputType.phone,
                              validator: (v) {
                                if (v == null || v.isEmpty) return 'No. WA Darurat wajib diisi';
                                if (v.length < 9) return 'No. WA tidak valid';
                                return null;
                              },
                            ),

                            const SizedBox(height: 32),

                            // Submit Button
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton(
                                onPressed: _isSaving ? null : _saveProfile,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: _isSaving
                                    ? const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Text(
                                        'Simpan & Lanjutkan',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Back to login button
                TextButton.icon(
                  onPressed: () async {
                    await SupabaseService.instance.signOut();
                    if (mounted) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginPage()),
                      );
                    }
                  },
                  icon: const Icon(Icons.arrow_back_rounded, size: 16),
                  label: const Text('Kembali ke Halaman Login'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      readOnly: readOnly,
      onTap: onTap,
      style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
        prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
        filled: true,
        fillColor: AppColors.background.withOpacity(0.4),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.softAccent, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}
