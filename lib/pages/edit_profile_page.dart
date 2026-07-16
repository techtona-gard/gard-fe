import 'package:flutter/material.dart';
import 'package:gard_fe/constants/app_colors.dart';

class EditProfilePage extends StatefulWidget {
  final String name;
  final String height;
  final String weight;
  final String emergencyContact;
  final String email;
  final String birthDate;

  const EditProfilePage({
    super.key,
    required this.name,
    required this.height,
    required this.weight,
    required this.emergencyContact,
    required this.email,
    required this.birthDate,
  });

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _nameCtrl;
  late TextEditingController _heightCtrl;
  late TextEditingController _weightCtrl;
  late TextEditingController _contactCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _birthDateCtrl;

  String _selectedGender = 'Laki-laki';
  String _selectedBloodType = 'B';
  bool _isSaving = false;

  final _formKey = GlobalKey<FormState>();

  final List<String> _genders = ['Laki-laki', 'Perempuan'];
  final List<String> _bloodTypes = ['A', 'B', 'AB', 'O'];

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.name);
    _heightCtrl = TextEditingController(text: widget.height);
    _weightCtrl = TextEditingController(text: widget.weight);
    _contactCtrl = TextEditingController(text: widget.emergencyContact);
    _emailCtrl = TextEditingController(text: widget.email);
    _birthDateCtrl = TextEditingController(text: widget.birthDate);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _heightCtrl.dispose();
    _weightCtrl.dispose();
    _contactCtrl.dispose();
    _emailCtrl.dispose();
    _birthDateCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    await Future.delayed(const Duration(milliseconds: 800));
    setState(() => _isSaving = false);
    if (mounted) {
      Navigator.pop(context, {
        'name': _nameCtrl.text,
        'height': _heightCtrl.text,
        'weight': _weightCtrl.text,
        'emergencyContact': _contactCtrl.text,
        'email': _emailCtrl.text,
        'birthDate': _birthDateCtrl.text,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
              SizedBox(width: 10),
              Text('Data profil berhasil diperbarui!'),
            ],
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // ── Header ───────────────────────────────────────────────────────
          Container(
            padding: EdgeInsets.fromLTRB(16, MediaQuery.of(context).padding.top + 16, 16, 28),
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 4),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Ubah Data Profil',
                          style: TextStyle(
                              color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      Text('Perbarui informasi akun Anda',
                          style: TextStyle(color: Colors.white60, fontSize: 12)),
                    ],
                  ),
                ),
                // Avatar preview
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
                  ),
                  child: const CircleAvatar(
                    radius: 22,
                    backgroundColor: AppColors.softAccent,
                    backgroundImage: NetworkImage('https://i.pravatar.cc/300'),
                  ),
                ),
              ],
            ),
          ),

          // ── Form ─────────────────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar edit section
                    Center(
                      child: Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.softAccent, width: 3),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.1),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                )
                              ],
                            ),
                            child: const CircleAvatar(
                              radius: 50,
                              backgroundImage: NetworkImage('https://i.pravatar.cc/300'),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: () {},
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.camera_alt_rounded,
                                    color: Colors.white, size: 16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 8),
                    const Center(
                      child: Text('Ketuk ikon kamera untuk mengubah foto',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                    ),

                    const SizedBox(height: 28),

                    // ── Informasi Pribadi ─────────────────────────────────
                    _buildSectionHeader('Informasi Pribadi', Icons.person_rounded),
                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: _nameCtrl,
                      label: 'Nama Lengkap',
                      icon: Icons.badge_outlined,
                      validator: (v) => v!.isEmpty ? 'Nama tidak boleh kosong' : null,
                    ),
                    const SizedBox(height: 14),
                    _buildTextField(
                      controller: _birthDateCtrl,
                      label: 'Tanggal Lahir',
                      icon: Icons.cake_rounded,
                      readOnly: true,
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime(1998, 8, 12),
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
                          final months = [
                            'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
                            'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
                          ];
                          setState(() {
                            _birthDateCtrl.text = "${picked.day} ${months[picked.month - 1]} ${picked.year}";
                          });
                        }
                      },
                      validator: (v) => v!.isEmpty ? 'Tanggal lahir wajib diisi' : null,
                    ),
                    const SizedBox(height: 14),
                    _buildTextField(
                      controller: _emailCtrl,
                      label: 'Email',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) =>
                          v!.isEmpty || !v.contains('@') ? 'Masukkan email valid' : null,
                    ),
                    const SizedBox(height: 14),

                    // Gender Selector
                    _buildDropdownField(
                      label: 'Jenis Kelamin',
                      icon: Icons.wc_rounded,
                      value: _selectedGender,
                      items: _genders,
                      onChanged: (val) => setState(() => _selectedGender = val!),
                    ),

                    const SizedBox(height: 28),

                    // ── Informasi Kesehatan ───────────────────────────────
                    _buildSectionHeader('Informasi Kesehatan', Icons.monitor_heart_rounded),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _heightCtrl,
                            label: 'Tinggi (cm)',
                            icon: Icons.height_rounded,
                            keyboardType: TextInputType.number,
                            validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildTextField(
                            controller: _weightCtrl,
                            label: 'Berat (kg)',
                            icon: Icons.monitor_weight_outlined,
                            keyboardType: TextInputType.number,
                            validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    _buildDropdownField(
                      label: 'Golongan Darah',
                      icon: Icons.bloodtype_rounded,
                      value: _selectedBloodType,
                      items: _bloodTypes,
                      onChanged: (val) => setState(() => _selectedBloodType = val!),
                    ),

                    const SizedBox(height: 28),

                    // ── Kontak Darurat ────────────────────────────────────
                    _buildSectionHeader('Kontak Darurat', Icons.contact_phone_rounded),
                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: _contactCtrl,
                      label: 'Nomor WhatsApp Darurat',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      validator: (v) => v!.isEmpty ? 'Nomor darurat wajib diisi' : null,
                    ),

                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.warning.withOpacity(0.2)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.info_outline_rounded, color: AppColors.warning, size: 16),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Nomor ini akan dihubungi otomatis saat SOS darurat dikirim.',
                              style: TextStyle(color: AppColors.warning, fontSize: 11, height: 1.4),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 36),

                    // ── Save Button ───────────────────────────────────────
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                          disabledBackgroundColor: AppColors.textHint,
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2))
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.save_rounded, size: 20),
                                  SizedBox(width: 10),
                                  Text('Simpan Perubahan',
                                      style: TextStyle(
                                          fontSize: 16, fontWeight: FontWeight.bold)),
                                ],
                              ),
                      ),
                    ),

                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.softAccent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary, size: 18),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: AppColors.darkAccent,
          ),
        ),
      ],
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
        fillColor: AppColors.card,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.softAccent, width: 1.5),
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

  Widget _buildDropdownField({
    required String label,
    required IconData icon,
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      onChanged: onChanged,
      style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
        prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
        filled: true,
        fillColor: AppColors.card,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.softAccent, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      dropdownColor: AppColors.card,
      borderRadius: BorderRadius.circular(16),
      items: items
          .map((item) => DropdownMenuItem(
                value: item,
                child: Text(item),
              ))
          .toList(),
    );
  }
}
