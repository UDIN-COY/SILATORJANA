import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../models/kegiatan.dart';
import '../../auth/models/user.dart';
import '../viewmodels/kegiatan_viewmodel.dart';

class KegiatanDetailView extends StatefulWidget {
  final Kegiatan kegiatan;
  final User currentUser;

  const KegiatanDetailView({super.key, required this.kegiatan, required this.currentUser});

  @override
  State<KegiatanDetailView> createState() => _KegiatanDetailViewState();
}

class _KegiatanDetailViewState extends State<KegiatanDetailView> {
  final KegiatanViewModel _kegiatanViewModel = KegiatanViewModel();

  @override
  void initState() {
    super.initState();
    _kegiatanViewModel.fetchKegiatanDetail(widget.kegiatan.id);
  }

  @override
  void dispose() {
    _kegiatanViewModel.dispose();
    super.dispose();
  }

  Future<void> _submitAction(String action) async {
    final success = await _kegiatanViewModel.submitAction(
      widget.kegiatan.id,
      action,
      'Disetujui dari aplikasi Mobile.',
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Status berhasil diperbarui!'), backgroundColor: Color(0xFF047857)),
      );
      Navigator.pop(context, true); 
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal memperbarui status.'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Detail Pengajuan'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        elevation: 1,
      ),
      body: ListenableBuilder(
        listenable: _kegiatanViewModel,
        builder: (context, _) => _buildBody(),
      ),
      bottomNavigationBar: ListenableBuilder(
        listenable: _kegiatanViewModel,
        builder: (context, _) => _buildActionButtons() ?? const SizedBox.shrink(),
      ),
    );
  }

  Widget _buildBody() {
    if (_kegiatanViewModel.isDetailLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF047857)));
    }
    if (_kegiatanViewModel.detailErrorMessage != null) {
      return Center(child: Text(_kegiatanViewModel.detailErrorMessage!));
    }
    if (_kegiatanViewModel.detailData == null) {
      return const Center(child: Text('Data tidak ditemukan.'));
    }

    final detailData = _kegiatanViewModel.detailData!;
    final totalAnggaran = detailData['total_anggaran'] ?? 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.kegiatan.judul,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                ),
                const SizedBox(height: 16),
                _buildInfoRow(LucideIcons.calendar, 'Tanggal Dibuat', widget.kegiatan.createdAt),
                _buildInfoRow(LucideIcons.user, 'Pengusul', widget.kegiatan.namaPengusul),
                _buildInfoRow(LucideIcons.banknote, 'Total RAB', 'Rp $totalAnggaran'),
                _buildInfoRow(LucideIcons.activity, 'Status Terkini', widget.kegiatan.status.toUpperCase()),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text('Deskripsi Kegiatan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Text(
              detailData['kak']?['latar_belakang'] ?? 'Belum ada deskripsi KAK.',
              style: const TextStyle(color: Color(0xFF475569)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: const Color(0xFF94A3B8)),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
              Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1E293B))),
            ],
          ),
        ],
      ),
    );
  }

  Widget? _buildActionButtons() {
    if (widget.currentUser.role == 'pengusul' || widget.currentUser.role == 'admin') return null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, -2))],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _kegiatanViewModel.isActionLoading ? null : () => _submitAction('reject'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: const BorderSide(color: Colors.red),
                foregroundColor: Colors.red,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Minta Revisi', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: _kegiatanViewModel.isActionLoading ? null : () => _submitAction('approve'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: const Color(0xFF047857),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _kegiatanViewModel.isActionLoading 
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('Setujui', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
