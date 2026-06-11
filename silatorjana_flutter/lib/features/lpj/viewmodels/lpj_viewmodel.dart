import 'dart:convert';
import 'package:flutter/material.dart';
import '../../kegiatan/models/kegiatan.dart';
import '../../../core/network/api_service.dart';

class LpjViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Kegiatan> lpjList = [];
  bool isLoading = false;
  String? errorMessage;
  bool isSubmitting = false;

  Map<String, dynamic>? lpjDetail;
  bool isDetailLoading = false;

  /// Fetch kegiatan that are in LPJ-related statuses
  Future<void> fetchLpjList() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.get('/kegiatan');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List dynamicList = data['data'] ?? data;
        final all = dynamicList.map((json) => Kegiatan.fromJson(json)).toList();
        // Filter LPJ-related statuses
        lpjList = all.where((k) {
          final s = k.status.toLowerCase();
          return ['approved_wadir', 'accepted_funds', 'funds_disbursed',
                  'lpj_submitted', 'lpj_revision', 'lpj_approved', 'lpj_verified', 'lpj_done'].contains(s);
        }).toList();
      } else {
        errorMessage = 'Gagal memuat data LPJ (${response.statusCode})';
      }
    } catch (e) {
      errorMessage = 'Kesalahan jaringan: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Fetch LPJ detail for a specific kegiatan
  Future<void> fetchLpjDetail(int kegiatanId) async {
    isDetailLoading = true;
    lpjDetail = null;
    notifyListeners();

    try {
      final response = await _apiService.get('/lpj/detail/$kegiatanId');
      if (response.statusCode == 200) {
        lpjDetail = jsonDecode(response.body);
      }
    } catch (e) {
      // Handle silently
    } finally {
      isDetailLoading = false;
      notifyListeners();
    }
  }

  /// Submit LPJ
  Future<bool> submitLpj(int kegiatanId, String catatan) async {
    isSubmitting = true;
    notifyListeners();

    try {
      final response = await _apiService.post('/lpj/submit', body: {
        'kegiatan_id': kegiatanId,
        'catatan_pengusul': catatan,
      });
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }

  /// Approve or request revision for LPJ (bendahara action)
  Future<bool> approveLpj(int kegiatanId, String action, String catatan) async {
    isSubmitting = true;
    notifyListeners();

    try {
      final response = await _apiService.post('/kegiatan/$kegiatanId/status', body: {
        'action': action,
        'catatan': catatan,
      });
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }

  /// Perform pencairan (disbursement)
  Future<bool> pencairan(int kegiatanId, double persentase, String catatan) async {
    isSubmitting = true;
    notifyListeners();

    try {
      final response = await _apiService.post('/kegiatan/$kegiatanId/pencairan', body: {
        'persentase': persentase,
        'catatan': catatan,
      });
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }
}
