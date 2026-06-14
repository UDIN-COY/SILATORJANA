import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConfig {
  // ──────────────────────────────────────────
  // Konfigurasi Server
  // ──────────────────────────────────────────
  //
  // Untuk development pada device fisik (HP):
  //   Ganti _physicalDeviceIp di bawah dengan IP WiFi komputer kamu.
  //   Contoh: '192.168.1.10'
  //   Pastikan HP dan komputer terhubung ke WiFi yang sama.
  //
  // Untuk emulator Android → sudah otomatis pakai 10.0.2.2
  // Untuk Web/Desktop → sudah otomatis pakai localhost
  // ──────────────────────────────────────────
  static const String _customBaseUrl = ''; // ← Kosongkan jika tidak memakai Ngrok yang aktif, isi jika pakai Ngrok
  static const String _physicalDeviceIp = '192.168.18.202'; // ← Ganti dengan IP WiFi komputer saat ini jika run di HP fisik
  static const int _port = 8000;

  static String get baseUrl {
    // 1. Jika ada Custom URL (misal: Ngrok), prioritaskan ini!
    if (_customBaseUrl.isNotEmpty) {
      return '$_customBaseUrl/api';
    }

    // Web atau Desktop → localhost
    if (kIsWeb) {
      return 'http://localhost:$_port/api';
    }

    try {
      if (Platform.isLinux || Platform.isMacOS || Platform.isWindows) {
        return 'http://localhost:$_port/api';
      }

      if (Platform.isAndroid) {
        // Secara default gunakan 10.0.2.2 untuk Android Emulator.
        // Ubah isEmulator ke false jika menggunakan HP fisik (pastikan satu jaringan WiFi dengan laptop).
        const bool isEmulator = true;
        if (isEmulator) {
          return 'http://10.0.2.2:$_port/api';
        }
        return 'http://$_physicalDeviceIp:$_port/api';
      }

      if (Platform.isIOS) {
        // Secara default gunakan localhost untuk iOS Simulator.
        // Ubah isSimulator ke false jika menggunakan HP fisik (pastikan satu jaringan WiFi dengan laptop).
        const bool isSimulator = true;
        if (isSimulator) {
          return 'http://localhost:$_port/api';
        }
        return 'http://$_physicalDeviceIp:$_port/api';
      }
    } catch (_) {
      // Fallback jika Platform tidak tersedia
    }

    return 'http://localhost:$_port/api';
  }
}
