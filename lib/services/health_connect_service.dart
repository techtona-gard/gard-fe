import 'package:health/health.dart';
import 'package:flutter/foundation.dart';

class HealthService {
  final Health _health = Health();

  // 1. Daftar tipe data yang ingin dibaca dari Health Connect
  static const List<HealthDataType> _types = [
    HealthDataType.STEPS,
    HealthDataType.HEART_RATE,
    HealthDataType.TOTAL_CALORIES_BURNED,
    HealthDataType.SLEEP_ASLEEP,
    HealthDataType.WEIGHT,
    HealthDataType.SPEED,
    HealthDataType.DISTANCE_DELTA,
  ];

  // Set izin hanya untuk membaca (READ)
  static final List<HealthDataAccess> _permissions =
      List.filled(_types.length, HealthDataAccess.READ);

  /// Inisialisasi plugin & set SDK ke Health Connect
  Future<void> init() async {
    await _health.configure();
  }

  /// Cek apakah izin sudah diberikan
  Future<bool> hasPermissions() async {
    try {
      bool? hasPermission = await _health.hasPermissions(
        _types,
        permissions: _permissions,
      );
      return hasPermission ?? false;
    } catch (e) {
      debugPrint('Error checking permissions: $e');
      return false;
    }
  }

  /// Minta izin ke user via dialog Health Connect
  Future<bool> requestPermissions() async {
    try {
      // Tampilkan popup minta izin dari sistem Health Connect
      bool hasPermission = await _health.requestAuthorization(
        _types,
        permissions: _permissions,
      );
      return hasPermission;
    } catch (e) {
      debugPrint('Error requesting Health Connect permissions: $e');
      return false;
    }
  }

  /// Ambil Raw Data berdasarkan rentang waktu (Default: Hari Ini)
  Future<List<HealthDataPoint>> fetchRawHealthData({
    DateTime? startTime,
    DateTime? endTime,
  }) async {
    final now = DateTime.now();
    final start = startTime ?? DateTime(now.year, now.month, now.day);
    final end = endTime ?? now;

    try {
      List<HealthDataPoint> healthData = await _health.getHealthDataFromTypes(
        types: _types,
        startTime: start,
        endTime: end,
      );

      // Bersihkan data duplikat jika sync dari multiple device
      return _health.removeDuplicates(healthData);
    } catch (e) {
      debugPrint('Error fetching health data: $e');
      return [];
    }
  }

  /// Helper Praktis: Mengolah Raw Data menjadi Ringkasan Angka (Siap Tampil di UI)
  Future<Map<String, dynamic>> getTodaySummary() async {
    final rawData = await fetchRawHealthData();

    int totalSteps = 0;
    double latestHeartRate = 0;
    double totalCalories = 0;
    double totalDistanceMeters = 0;
    double latestWeightKg = 0;
    double latestSpeedMps = 0;
    Duration totalSleepDuration = Duration.zero;

    for (var point in rawData) {
      final value = point.value;

      switch (point.type) {
        case HealthDataType.STEPS:
          if (value is NumericHealthValue) {
            totalSteps += value.numericValue.toInt();
          }
          break;
        case HealthDataType.HEART_RATE:
          if (value is NumericHealthValue) {
            latestHeartRate = value.numericValue.toDouble();
          }
          break;
        case HealthDataType.TOTAL_CALORIES_BURNED:
          if (value is NumericHealthValue) {
            totalCalories += value.numericValue.toDouble();
          }
          break;
        case HealthDataType.DISTANCE_DELTA:
          if (value is NumericHealthValue) {
            totalDistanceMeters += value.numericValue.toDouble();
          }
          break;
        case HealthDataType.WEIGHT:
          if (value is NumericHealthValue) {
            latestWeightKg = value.numericValue.toDouble();
          }
          break;
        case HealthDataType.SPEED:
          if (value is NumericHealthValue) {
            latestSpeedMps = value.numericValue.toDouble();
          }
          break;
        case HealthDataType.SLEEP_ASLEEP:
          final duration = point.dateTo.difference(point.dateFrom).abs();
          totalSleepDuration += duration;
          break;
        default:
          break;
      }
    }

    return {
      'steps': totalSteps,
      'heartRate': latestHeartRate,
      'calories': totalCalories,
      'distanceMeters': totalDistanceMeters,
      'weight': latestWeightKg,
      'speed': latestSpeedMps,
      'sleepMinutes': totalSleepDuration.inMinutes,
    };
  }
}