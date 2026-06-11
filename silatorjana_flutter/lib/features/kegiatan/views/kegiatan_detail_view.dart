import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../models/kegiatan.dart';
import '../../auth/models/user.dart';
import '../viewmodels/kegiatan_viewmodel.dart';
import '../../monitoring/views/timeline_view.dart';
import 'kegiatan_print_view.dart';

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

  /// Shows a dialog for user to input catatan before approving/rejecting
  Future<void> _submitAction(String action) async {
    final catatanCtrl = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(action == 'approve' ? 'Setujui Proposal' : 'Minta Revisi'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              action == 'approve'
                  ? 'Apakah Anda yakin menyetujui proposal ini?'
                  : 'Berikan catatan revisi untuk pengusul:',
              style: const TextStyle(fontSize: 14, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: catatanCtrl,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: action == 'approve' ? 'Catatan (opsional)' : 'Catatan revisi *',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              if (action == 'reject' && catatanCtrl.text.isEmpty) {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  const SnackBar(content: Text('Catatan wajib diisi untuk revisi'), backgroundColor: Colors.orange),
                );
                return;
              }
              Navigator.pop(ctx, true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: action == 'approve' ? const Color(0xFF047857) : Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(action == 'approve' ? 'Setujui' : 'Minta Revisi'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final catatan = catatanCtrl.text.isNotEmpty
        ? catatanCtrl.text
        : 'Disetujui oleh ${widget.currentUser.nama} (${widget.currentUser.role})';

    final success = await _kegiatanViewModel.submitAction(
      widget.kegiatan.id,
      action,
      catatan,
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
    catatanCtrl.dispose();
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
        actions: [
          // Timeline button
          IconButton(
            icon: const Icon(LucideIcons.clock, size: 20),
            tooltip: 'Timeline',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TimelineView(
                    kegiatanId: widget.kegiatan.id,
                    title: 'Timeline: ${widget.kegiatan.namaKegiatan}',
                  ),
                ),
              );
            },
          ),
          // Print button
          IconButton(
            icon: const Icon(LucideIcons.printer, size: 20),
            tooltip: 'Pratinjau',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => KegiatanPrintView(kegiatanId: widget.kegiatan.id)),
              );
            },
          ),
        ],
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
    final k = widget.kegiatan;

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
                  k.judul,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                ),
                const SizedBox(height: 16),
                _buildInfoRow(LucideIcons.calendar, 'Tanggal Dibuat', k.formattedDate),
                _buildInfoRow(LucideIcons.user, 'Pengusul', k.namaPengusul),
                _buildInfoRow(LucideIcons.banknote, 'Total RAB', k.formattedAnggaran),
                _buildInfoRow(LucideIcons.activity, 'Status', k.status.replaceAll('_', ' ').toUpperCase()),
                if (k.namaJurusan != null)
                  _buildInfoRow(LucideIcons.building2, 'Jurusan', k.namaJurusan!),
                if (k.jenisKegiatan != null)
                  _buildInfoRow(LucideIcons.tag, 'Jenis', k.jenisKegiatan!),
                if (k.tempat != null)
                  _buildInfoRow(LucideIcons.mapPin, 'Tempat', k.tempat!),
                if (k.pengusulOrganisasi != null)
                  _buildInfoRow(LucideIcons.users, 'Organisasi', k.pengusulOrganisasi!),
                if (k.kodeMak != null)
                  _buildInfoRow(LucideIcons.hash, 'Kode MAK', k.kodeMak!),
                if (k.catatanRevisi != null && k.catatanRevisi!.isNotEmpty)
                  _buildInfoRow(LucideIcons.messageCircle, 'Catatan Revisi', k.catatanRevisi!),
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
              detailData['deskripsi']?.toString() ?? detailData['kak']?['latar_belakang']?.toString() ?? 'Belum ada deskripsi.',
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1E293B))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget? _buildActionButtons() {
    // Approval buttons for all approval roles (not pengusul/admin)
    final role = widget.currentUser.role;
    if (role == 'pengusul' || role == 'admin' || role.isEmpty) return null;

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
