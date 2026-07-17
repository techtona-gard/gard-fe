package com.example.gard_fe

import android.content.Intent
import android.net.Uri
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterFragmentActivity() {
    private val CHANNEL = "com.gard.sos/call"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "directCall") {
                val number = call.argument<String>("number")
                if (number != null) {
                    try {
                        // ACTION_CALL langsung menelepon tanpa membuka picker
                        // (Berbeda dengan ACTION_DIAL yang hanya membuka layar dialer)
                        val intent = Intent(Intent.ACTION_CALL)
                        intent.data = Uri.parse("tel:$number")
                        intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
                        startActivity(intent)
                        result.success(true)
                    } catch (e: SecurityException) {
                        result.error("PERMISSION_DENIED", "Izin CALL_PHONE belum diberikan: ${e.message}", null)
                    } catch (e: Exception) {
                        result.error("UNAVAILABLE", "Gagal menelepon: ${e.message}", null)
                    }
                } else {
                    result.error("INVALID_NUMBER", "Nomor telepon tidak ditemukan.", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }
}
