import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../kegiatan/models/kegiatan.dart';
import '../viewmodels/lpj_viewmodel.dart';

/// Pencairan (Disbursement) view — for bendahara to disburse funds.
/// Mirrors web's PencairanPage.tsx. Supports partial disbursement (%).
class PencairanView extends StatefulWidget {
  final Kegiatan kegiatan;
  const PencairanView({super.key, required this.kegiatan});

  @override
  State<PencairanView> createState() => _PencairanViewState();
}

class _PencairanViewState extends State<PencairanView> {
  final LpjViewModel _viewModel = LpjViewModel();
  final _persentaseCtrl = TextEditingController(text: '100');
  final _catatanCtrl = TextEditingController();

  @override
  void dispose() {
    _viewModel.dispose();
    _persentaseCtrl.dispose();
    _catatanCtrl.dispose();
    super.dispose();
  }

  Future<void> _handlePencairan() async {
    final persen = double.tryParse(_persentaseCtrl.text) ?? 0;
    if (persen <= 0 || persen > 100) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Persentase harus antara 1-100'), backgroundColor: Colors.red),
      );
      return;
    }

    final success = await _viewModel.pencairan(widget.kegiatan.id, persen, _catatanCtrl.text);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pencairan berhasil!'), backgroundColor: Color(0xFF047857)),
      );
      Navigator.pop(context, true);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal mencairkan dana.'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Pencairan Dana'),
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
                // Kegiatan info card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFF047857), Color(0xFF059669)]),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Kegiatan', style: TextStyle(color: Colors.white70, fontSize: 12)),
                      const SizedBox(height: 4),
                      Text(widget.kegiatan.namaKegiatan, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                      const SizedBox(height: 12),
                      if (widget.kegiatan.totalAnggaran != null)
                        Text('Total RAB: Rp ${widget.kegiatan.totalAnggaran}', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Persentase pencairan
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
                      const Text('Persentase Pencairan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1E293B))),
                      const SizedBox(height: 4),
                      const Text('Bisa dicairkan bertahap (misal 50% dulu)', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _persentaseCtrl,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          suffixText: '%',
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Catatan
                TextField(
                  controller: _catatanCtrl,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Catatan Pencairan',
                    alignLabelWithHint: true,
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _viewModel.isSubmitting ? null : _handlePencairan,
                  icon: _viewModel.isSubmitting
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Icon(LucideIcons.banknote, size: 20),
                  label: const Text('Cairkan Dana', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
