import 'dart:convert';
import 'package:flutter/material.dart';
import '../../kegiatan/models/kegiatan.dart';
import '../../../core/network/api_service.dart';

class MonitoringViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Kegiatan> allItems = [];
  bool isLoading = false;
  String? errorMessage;

  // Stats from /api/stats
  Map<String, int> stats = {};
  bool isStatsLoading = false;

  Future<void> fetchMonitoringData() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.get('/kegiatan?monitoring=true');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List dynamicList = data['data'] ?? data;
        allItems = dynamicList.map((json) => Kegiatan.fromJson(json)).toList();
      } else {
        errorMessage = 'Gagal memuat data monitoring (${response.statusCode})';
      }
    } catch (e) {
      errorMessage = 'Kesalahan jaringan: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchStats() async {
    isStatsLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.get('/stats');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        stats = Map<String, int>.from(data.map((k, v) => MapEntry(k, (v as num).toInt())));
      }
    } catch (e) {
      // Silently fail stats
    } finally {
      isStatsLoading = false;
      notifyListeners();
    }
  }
}
