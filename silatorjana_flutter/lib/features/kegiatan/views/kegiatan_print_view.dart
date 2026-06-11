import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/network/api_service.dart';

/// Print/Preview proposal — mirrors web's PrintProposalPage.tsx.
/// Shows a formatted preview of the full proposal for printing or sharing.
class KegiatanPrintView extends StatefulWidget {
  final int kegiatanId;
  const KegiatanPrintView({super.key, required this.kegiatanId});

  @override
  State<KegiatanPrintView> createState() => _KegiatanPrintViewState();
}

class _KegiatanPrintViewState extends State<KegiatanPrintView> {
  final ApiService _apiService = ApiService();
  Map<String, dynamic>? _data;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final response = await _apiService.get('/kegiatan/${widget.kegiatanId}');
      if (response.statusCode == 200) {
        _data = jsonDecode(response.body);
      }
    } catch (e) {
      // Handle error
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Pratinjau Proposal'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.share2, size: 20),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Fitur share memerlukan package tambahan')),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF047857)))
          : _data == null
              ? const Center(child: Text('Gagal memuat data'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Center(
                        child: Column(
                          children: [
                            const Text('PROPOSAL KEGIATAN', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 2, color: Color(0xFF1E293B))),
                            const SizedBox(height: 4),
                            const Text('Si-LATORJANA — Politeknik Negeri Jakarta', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                            const SizedBox(height: 16),
                            const Divider(thickness: 2),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Info Umum
                      _buildSection('INFORMASI UMUM', [
                        _buildRow('Nama Kegiatan', _data!['nama_kegiatan'] ?? '-'),
                        _buildRow('Jenis Kegiatan', _data!['jenis_kegiatan'] ?? '-'),
                        _buildRow('Status', _data!['status'] ?? '-'),
                        _buildRow('Jurusan', _data!['nama_jurusan'] ?? '-'),
                        _buildRow('Tanggal Mulai', _data!['tanggal_mulai'] ?? '-'),
                        _buildRow('Tanggal Selesai', _data!['tanggal_selesai'] ?? '-'),
                      ]),
                      // KAK
                      if (_data!['kak'] != null) ...[
                        _buildSection('KERANGKA ACUAN KERJA (KAK)', [
                          _buildRow('Latar Belakang', _data!['kak']?['latar_belakang'] ?? '-'),
                          _buildRow('Tujuan', _data!['kak']?['tujuan'] ?? '-'),
                          _buildRow('Sasaran', _data!['kak']?['sasaran'] ?? '-'),
                          _buildRow('Target Capaian', _data!['kak']?['target_capaian'] ?? '-'),
                        ]),
                      ],
                      // RAB
                      if (_data!['total_anggaran'] != null) ...[
                        _buildSection('RENCANA ANGGARAN BIAYA (RAB)', [
                          _buildRow('Total Anggaran', 'Rp ${_data!['total_anggaran']}'),
                        ]),
                      ],
                      const SizedBox(height: 32),
                      const Divider(thickness: 1),
                      const SizedBox(height: 16),
                      const Center(
                        child: Text('— Dokumen dihasilkan dari Aplikasi Si-LATORJANA —', style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8), fontStyle: FontStyle.italic)),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 1, color: Color(0xFF047857))),
          const SizedBox(height: 8),
          const Divider(height: 1, thickness: 0.5),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF64748B))),
          ),
          const Text(': ', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 12, color: Color(0xFF1E293B)))),
        ],
      ),
    );
  }
}
