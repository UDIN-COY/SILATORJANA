import 'package:flutter/material.dart';
import '../../../core/network/api_service.dart';
import '../../auth/services/auth_service.dart';
import '../../auth/services/biometric_service.dart';

class ProfileViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();
  final BiometricService _biometricService = BiometricService();

  bool isLoading = false;
  String? errorMessage;
  String? successMessage;
  
  bool isBiometricEnabled = false;

  ProfileViewModel() {
    _checkBiometricStatus();
  }

  Future<void> _checkBiometricStatus() async {
    final creds = await _authService.getCredentials();
    isBiometricEnabled = creds != null;
    notifyListeners();
  }

  Future<bool> enableBiometric(String email, String password) async {
    isLoading = true;
    errorMessage = null;
    successMessage = null;
    notifyListeners();

    try {
      debugPrint('BIOMETRIC: Verifying password...');
      // Verify password via a separate login call
      final success = await _authService.login(email, password);
      debugPrint('BIOMETRIC: Password verify result=$success');
      if (!success) {
        isLoading = false;
        errorMessage = 'Password salah. Gagal mengaktifkan biometrik.';
        notifyListeners();
        return false;
      }

      // Check device support & authenticate
      debugPrint('BIOMETRIC: Checking device biometric support...');
      final hasBiometrics = await _biometricService.hasBiometrics();
      debugPrint('BIOMETRIC: hasBiometrics=$hasBiometrics');
      if (!hasBiometrics) {
        isLoading = false;
        errorMessage = 'Perangkat tidak mendukung atau belum disetting biometrik.';
        notifyListeners();
        return false;
      }

      debugPrint('BIOMETRIC: Requesting fingerprint/face scan...');
      final authenticated = await _biometricService.authenticate();
      debugPrint('BIOMETRIC: authenticate result=$authenticated');
      if (authenticated) {
        await _authService.saveCredentials(email, password);
        isBiometricEnabled = true;
        successMessage = 'Login Biometrik berhasil diaktifkan!';
        isLoading = false;
        notifyListeners();
        return true;
      } else {
        isLoading = false;
        errorMessage = 'Otentikasi biometrik dibatalkan/gagal.';
        notifyListeners();
        return false;
      }
    } catch (e) {
      debugPrint('BIOMETRIC ERROR: $e');
      isLoading = false;
      errorMessage = 'Terjadi kesalahan: $e';
      notifyListeners();
      return false;
    }
  }

  Future<void> disableBiometric() async {
    await _authService.deleteCredentials();
    isBiometricEnabled = false;
    successMessage = 'Login Biometrik dinonaktifkan.';
    notifyListeners();
  }

  Future<bool> changePassword(String currentPassword, String newPassword) async {
    isLoading = true;
    errorMessage = null;
    successMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.post(
        '/change-password',
        body: {
          'current_password': currentPassword,
          'new_password': newPassword,
        },
      );

      if (response.statusCode == 200) {
        successMessage = 'Password berhasil diubah.';
        isLoading = false;
        notifyListeners();
        return true;
      } else {
        errorMessage = 'Gagal mengubah password. Pastikan password lama benar.';
        isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      errorMessage = 'Terjadi kesalahan jaringan.';
      isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
