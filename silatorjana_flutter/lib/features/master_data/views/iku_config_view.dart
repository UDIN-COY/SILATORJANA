import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../viewmodels/master_data_viewmodel.dart';

/// IKU Configuration — admin only.
/// Mirrors web's IkuConfigPage.tsx.
class IkuConfigView extends StatefulWidget {
  const IkuConfigView({super.key});

  @override
  State<IkuConfigView> createState() => _IkuConfigViewState();
}

class _IkuConfigViewState extends State<IkuConfigView> {
  final MasterDataViewModel _viewModel = MasterDataViewModel();

  @override
  void initState() {
    super.initState();
    _viewModel.fetchIkuMaster();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  void _showAddDialog() {
    final namaCtrl = TextEditingController();
    final deskripsiCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tambah IKU'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: namaCtrl, decoration: const InputDecoration(labelText: 'Nama Indikator')),
            const SizedBox(height: 12),
            TextField(controller: deskripsiCtrl, maxLines: 2, decoration: const InputDecoration(labelText: 'Deskripsi')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              if (namaCtrl.text.isNotEmpty) {
                final success = await _viewModel.createIku({'nama': namaCtrl.text, 'deskripsi': deskripsiCtrl.text});
                if (ctx.mounted) Navigator.pop(ctx);
                if (success) _viewModel.fetchIkuMaster();
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF047857), foregroundColor: Colors.white),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Konfigurasi IKU'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        elevation: 1,
        actions: [
          IconButton(icon: const Icon(LucideIcons.refreshCw, size: 20), onPressed: () => _viewModel.fetchIkuMaster()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        backgroundColor: const Color(0xFF047857),
        foregroundColor: Colors.white,
        child: const Icon(LucideIcons.plus),
      ),
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) {
          if (_viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF047857)));
          }

          if (_viewModel.errorMessage != null) {
            return Center(child: Text(_viewModel.errorMessage!));
          }

          if (_viewModel.ikuList.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(LucideIcons.target, size: 48, color: Colors.grey.shade300),
                  const SizedBox(height: 12),
                  const Text('Belum ada data IKU.', style: TextStyle(color: Color(0xFF64748B))),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => _viewModel.fetchIkuMaster(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _viewModel.ikuList.length,
              itemBuilder: (context, index) {
                final iku = _viewModel.ikuList[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFECFDF5),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(LucideIcons.target, size: 20, color: Color(0xFF047857)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(iku['nama'] ?? '-', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            if (iku['deskripsi'] != null)
                              Text(iku['deskripsi'], style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
