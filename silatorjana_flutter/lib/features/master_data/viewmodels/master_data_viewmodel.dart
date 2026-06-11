import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../core/network/api_service.dart';

class MasterDataViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Map<String, dynamic>> ikuList = [];
  bool isLoading = false;
  bool isSubmitting = false;
  String? errorMessage;

  Future<void> fetchIkuMaster() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.get('/iku-master');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        ikuList = List<Map<String, dynamic>>.from(data['data'] ?? data);
      } else {
        errorMessage = 'Gagal memuat data IKU (${response.statusCode})';
      }
    } catch (e) {
      errorMessage = 'Kesalahan jaringan: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createIku(Map<String, dynamic> body) async {
    isSubmitting = true;
    notifyListeners();

    try {
      final response = await _apiService.post('/iku-master', body: body);
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }

  Future<bool> updateIku(int id, Map<String, dynamic> body) async {
    isSubmitting = true;
    notifyListeners();

    try {
      final response = await _apiService.put('/iku-master/$id', body: body);
      return response.statusCode == 200;
    } catch (e) {
      return false;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }
}
