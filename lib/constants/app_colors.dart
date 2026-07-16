import 'package:flutter/material.dart';

/// Palet warna GARD - diambil dari logo dan color palette "HAZY"
/// #192524 → darkAccent (teal paling gelap)
/// #2C5358 → primary (teal medium gelap)
/// #598090 → midTeal (teal medium)
/// #D1E8D0 → softMint (mint lembut)
/// #00D5CE → accent (teal cerah - tidak digunakan)
/// #EFECE9 → background (off-white warm)
class AppColors {
  // ── Warna Utama ──────────────────────────────────────────────────────────────
  /// Deep Teal - warna dominan logo Gard (huruf "ard" & outer G)
  static const Color primary = Color(0xFF2C5358);

  /// Darkest Teal - warna inner stomach pada logo
  static const Color darkAccent = Color(0xFF192524);

  /// Mid Teal - aksen pembeda, antara primary dan soft
  static const Color midTeal = Color(0xFF598090);

  // ── Warna Latar & Surface ─────────────────────────────────────────────────
  /// Off-White Warm - background keseluruhan aplikasi
  static const Color background = Color(0xFFF2F5F4);

  /// Putih bersih untuk card dan container
  static const Color card = Color(0xFFFFFFFF);

  /// Soft Mint - aksen ringan untuk tint/highlight
  static const Color softAccent = Color(0xFFD1E8D0);

  /// Mint sangat muda untuk background section
  static const Color mintLight = Color(0xFFEAF4EA);

  // ── Warna Teks ────────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF192524);
  static const Color textSecondary = Color(0xFF6B8A8A);
  static const Color textHint = Color(0xFFAFC5C5);

  // ── Status ────────────────────────────────────────────────────────────────
  static const Color error = Color(0xFFC0392B);
  static const Color success = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFE67E22);
  static const Color info = Color(0xFF2980B9);

  // ── Doctor Palette ────────────────────────────────────────────────────────
  /// Emerald Green - Warna Utama Dokter (disamakan dengan pasien)
  static const Color doctorPrimary = primary;

  // ── Gradient ─────────────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, darkAccent],
  );

  static const LinearGradient softGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [softAccent, mintLight],
  );
}
