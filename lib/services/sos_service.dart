import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

class SosService {
  static const String emergencyNumber = "081272733891";

  static Future<void> checkAndRequestLocationPermission(BuildContext context) async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check GPS Service
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (context.mounted) {
        await _showLocationDialog(
          context,
          "GPS Tidak Aktif",
          "Fitur SOS membutuhkan GPS aktif. Silakan aktifkan GPS Anda.",
          true,
        );
        // Recursive check after coming back from settings
        if (context.mounted) checkAndRequestLocationPermission(context);
      }
      return;
    }

    // Check Permission
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (context.mounted) {
          await _showLocationDialog(
            context,
            "Izin Lokasi Ditolak",
            "Fitur SOS mendeteksi lokasi darurat sangat membutuhkan izin GPS agar bisa berjalan.",
            false,
          );
          if (context.mounted) checkAndRequestLocationPermission(context);
        }
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (context.mounted) {
        await _showLocationDialog(
          context,
          "Izin Lokasi Ditolak Permanen",
          "Fitur SOS mendeteksi lokasi darurat sangat membutuhkan izin GPS agar bisa berjalan. Silakan aktifkan di Pengaturan.",
          false,
        );
        if (context.mounted) checkAndRequestLocationPermission(context);
      }
      return;
    }
  }

  static Future<void> _showLocationDialog(BuildContext context, String title, String message, bool isGps) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () async {
              if (isGps) {
                await Geolocator.openLocationSettings();
              } else {
                await openAppSettings();
              }
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text("PENGATURAN"),
          ),
        ],
      ),
    );
  }

  static Future<void> sendSosMessage(BuildContext context, {required String name, required String phone}) async {
    try {
      // Step A: Get GPS
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Step B: Format Message
      String message = "🚨 *PANGGILAN DARURAT SOS - GERD* 🚨\n\n"
          "*Data Diri:*\n"
          "- Nama: $name\n"
          "- Kontak Darurat: $emergencyNumber\n"
          "- Kondisi: Mengalami serangan GERD akut / Sesak Napas\n\n"
          "*Ringkasan Rekam Medis:*\n"
          "- 16 Juli: Gejala GERD (Sedang)\n"
          "- 14 Juli: Konsultasi dr. Andi (Sp.PD)\n"
          "- 10 Juli: GerdQ (Resiko Tinggi)\n\n"
          "*Lokasi Terkini (Google Maps):*\n"
          "https://www.google.com/maps/search/?api=1&query=${position.latitude},${position.longitude}\n\n"
          "*Catatan:* Saya juga melampirkan dokumen Rekam Medis (PDF) saya setelah pesan ini terkirim.";

      String whatsappUrl = "https://wa.me/$emergencyNumber?text=${Uri.encodeComponent(message)}";

      if (await canLaunchUrl(Uri.parse(whatsappUrl))) {
        await launchUrl(
          Uri.parse(whatsappUrl),
          mode: LaunchMode.externalApplication,
        );
        
        _shareMedicalRecord();
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("WhatsApp tidak terinstall di perangkat ini.")),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal mengirim SOS: $e")),
        );
      }
    }
  }

  static Future<void> _shareMedicalRecord() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final path = "${directory.path}/rekam_medis.pdf";
      final file = File(path);

      if (await file.exists()) {
        await Share.shareXFiles([XFile(path)], text: 'Dokumen Rekam Medis');
      } else {
        // If file doesn't exist, we can't share it. 
        // In a demo, we might want to create a dummy file or just skip.
        debugPrint("File rekam_medis.pdf tidak ditemukan di $path");
      }
    } catch (e) {
      debugPrint("Gagal berbagi file: $e");
    }
  }
}
