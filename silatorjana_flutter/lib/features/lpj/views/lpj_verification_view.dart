import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../kegiatan/models/kegiatan.dart';
import '../viewmodels/lpj_viewmodel.dart';
import 'components/spk_score_card_widget.dart';

/// LPJ Verification — bendahara reviews LPJ.
/// Mirrors web's LpjVerificationPage.tsx.
class LpjVerificationView extends StatefulWidget {
  final Kegiatan kegiatan;
  const LpjVerificationView({super.key, required this.kegiatan});

  @override
  State<LpjVerificationView> createState() => _LpjVerificationViewState();
}

class _LpjVerificationViewState extends State<LpjVerificationView> {
  final LpjViewModel _viewModel = LpjViewModel();
  final _catatanCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _viewModel.fetchLpjDetail(widget.kegiatan.id);
  }

  @override
  void dispose() {
    _viewModel.dispose();
    _catatanCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleAction(String action) async {
    if (_catatanCtrl.text.isEmpty && action == 'revision') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Catatan wajib diisi untuk revisi.'), backgroundColor: Colors.orange),
      );
      return;
    }

    final success = await _viewModel.approveLpj(widget.kegiatan.id, action, _catatanCtrl.text);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(action == 'approve' ? 'LPJ disetujui!' : 'LPJ diminta revisi.'),
          backgroundColor: action == 'approve' ? const Color(0xFF047857) : Colors.orange,
        ),
      );
      Navigator.pop(context, true);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal memproses LPJ.'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Verifikasi LPJ'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        elevation: 1,
      ),
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Kegiatan info
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
                      Text(widget.kegiatan.namaKegiatan, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF1E293B))),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(LucideIcons.user, size: 14, color: Color(0xFF94A3B8)),
                          const SizedBox(width: 4),
                          Text(widget.kegiatan.namaPengusul, style: const TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                        ],
                      ),
                      if (widget.kegiatan.totalAnggaran != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(LucideIcons.banknote, size: 14, color: Color(0xFF94A3B8)),
                            const SizedBox(width: 4),
                            Text('Rp ${widget.kegiatan.totalAnggaran}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF047857))),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // LPJ Detail (if loaded)
                if (_viewModel.isDetailLoading)
                  const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator(color: Color(0xFF047857))))
                else if (_viewModel.lpjDetail != null) ...[
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
                        const Text('Detail LPJ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1E293B))),
                        const Divider(height: 20),
                        if (_viewModel.lpjDetail!['catatan_pengusul'] != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text('Catatan Pengusul: ${_viewModel.lpjDetail!['catatan_pengusul']}', style: const TextStyle(fontSize: 13, color: Color(0xFF475569))),
                          ),
                        Text('Status: ${_viewModel.lpjDetail!['status'] ?? '-'}', style: const TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SpkScoreCardWidget(kegiatanId: widget.kegiatan.id),
                  const SizedBox(height: 16),
                ],
                // Catatan bendahara
                TextField(
                  controller: _catatanCtrl,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Catatan Verifikasi',
                    alignLabelWithHint: true,
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                  ),
                ),
                const SizedBox(height: 24),
                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _viewModel.isSubmitting ? null : () => _handleAction('revision'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.orange,
                          side: const BorderSide(color: Colors.orange),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Minta Revisi', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _viewModel.isSubmitting ? null : () => _handleAction('approve'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF047857),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: _viewModel.isSubmitting
                            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Text('Setujui LPJ', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
