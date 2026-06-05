import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../auth/models/user.dart';
import '../viewmodels/kegiatan_viewmodel.dart';
import 'kegiatan_detail_view.dart';

class KegiatanListView extends StatefulWidget {
  final User currentUser;
  const KegiatanListView({super.key, required this.currentUser});

  @override
  State<KegiatanListView> createState() => _KegiatanListViewState();
}

class _KegiatanListViewState extends State<KegiatanListView> {
  final KegiatanViewModel _kegiatanViewModel = KegiatanViewModel();

  @override
  void initState() {
    super.initState();
    _kegiatanViewModel.fetchKegiatanList();
  }

  @override
  void dispose() {
    _kegiatanViewModel.dispose();
    super.dispose();
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'draft': return Colors.grey;
      case 'submitted': return Colors.blue;
      case 'pending_ppk': return Colors.orange;
      case 'approved_ppk': return Colors.orangeAccent;
      case 'approved_wadir': return Colors.green;
      case 'funds_disbursed': return Colors.teal;
      case 'rejected': return Colors.red;
      case 'revision_requested': return Colors.deepOrange;
      default: return Colors.black54;
    }
  }

  String _formatStatus(String status) {
    return status.replaceAll('_', ' ').toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Daftar Pengajuan'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.refreshCw),
            onPressed: () => _kegiatanViewModel.fetchKegiatanList(),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: _kegiatanViewModel,
        builder: (context, _) => _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_kegiatanViewModel.isListLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF047857)));
    }

    if (_kegiatanViewModel.listErrorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(LucideIcons.alertTriangle, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(_kegiatanViewModel.listErrorMessage!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _kegiatanViewModel.fetchKegiatanList(),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    if (_kegiatanViewModel.kegiatanList.isEmpty) {
      return const Center(
        child: Text('Belum ada data pengajuan.', style: TextStyle(fontSize: 16, color: Colors.grey)),
      );
    }

    return RefreshIndicator(
      onRefresh: _kegiatanViewModel.fetchKegiatanList,
      color: const Color(0xFF047857),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _kegiatanViewModel.kegiatanList.length,
        itemBuilder: (context, index) {
          final item = _kegiatanViewModel.kegiatanList[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            color: Colors.white,
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => KegiatanDetailView(
                      kegiatan: item,
                      currentUser: widget.currentUser,
                    ),
                  ),
                ).then((value) {
                  if (value == true) _kegiatanViewModel.fetchKegiatanList();
                });
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            item.judul,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getStatusColor(item.status).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: _getStatusColor(item.status)),
                          ),
                          child: Text(
                            _formatStatus(item.status),
                            style: TextStyle(
                              color: _getStatusColor(item.status),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(LucideIcons.user, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(item.namaPengusul, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
