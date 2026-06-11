import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../kegiatan/models/kegiatan.dart';
import '../viewmodels/lpj_viewmodel.dart';

/// LPJ Upload view — for pengusul to submit LPJ after funds disbursed.
/// Mirrors web's LpjPage.tsx upload functionality.
class LpjUploadView extends StatefulWidget {
  final Kegiatan kegiatan;
  const LpjUploadView({super.key, required this.kegiatan});

  @override
  State<LpjUploadView> createState() => _LpjUploadViewState();
}

class _LpjUploadViewState extends State<LpjUploadView> {
  final LpjViewModel _viewModel = LpjViewModel();
  final _catatanCtrl = TextEditingController();

  @override
  void dispose() {
    _viewModel.dispose();
    _catatanCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final success = await _viewModel.submitLpj(widget.kegiatan.id, _catatanCtrl.text);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('LPJ berhasil disubmit!'), backgroundColor: Color(0xFF047857)),
      );
      Navigator.pop(context, true);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal mengirim LPJ.'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Upload LPJ'),
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
                    color: const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFA7F3D0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Kegiatan', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF047857))),
                      const SizedBox(height: 4),
                      Text(widget.kegiatan.namaKegiatan, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E293B))),
                      if (widget.kegiatan.totalAnggaran != null) ...[
                        const SizedBox(height: 4),
                        Text('Total RAB: Rp ${widget.kegiatan.totalAnggaran}', style: const TextStyle(fontSize: 13, color: Color(0xFF047857))),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Upload section (placeholder — real upload needs file_picker)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0), style: BorderStyle.solid),
                  ),
                  child: Column(
                    children: [
                      Icon(LucideIcons.upload, size: 48, color: Colors.grey.shade400),
                      const SizedBox(height: 12),
                      const Text('Upload Lampiran LPJ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E293B))),
                      const SizedBox(height: 4),
                      const Text('File kuitansi pengeluaran & laporan kegiatan', style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                      const SizedBox(height: 16),
                      OutlinedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Fitur upload file memerlukan package file_picker')),
                          );
                        },
                        icon: const Icon(LucideIcons.paperclip, size: 16),
                        label: const Text('Pilih File'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF047857),
                          side: const BorderSide(color: Color(0xFFA7F3D0)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Catatan
                TextField(
                  controller: _catatanCtrl,
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: 'Catatan LPJ',
                    alignLabelWithHint: true,
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _viewModel.isSubmitting ? null : _submit,
                  icon: _viewModel.isSubmitting
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Icon(LucideIcons.send, size: 18),
                  label: const Text('Kirim LPJ', style: TextStyle(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF047857),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
