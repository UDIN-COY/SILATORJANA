import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../auth/models/user.dart';
import '../../auth/viewmodels/auth_viewmodel.dart';
import '../../auth/views/login_view.dart';
import '../viewmodels/kegiatan_viewmodel.dart';
import '../models/kegiatan.dart';

class HomeTabView extends StatefulWidget {
  final User user;
  const HomeTabView({super.key, required this.user});

  @override
  State<HomeTabView> createState() => _HomeTabViewState();
}

class _HomeTabViewState extends State<HomeTabView> {
  final AuthViewModel _authViewModel = AuthViewModel();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<KegiatanViewModel>().fetchKegiatanList();
    });
  }

  void _logout() async {
    await _authViewModel.logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginView()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Si-LATORJANA', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF047857),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.logOut),
            onPressed: _logout,
            tooltip: 'Keluar',
          ),
        ],
        elevation: 0,
      ),
      body: Consumer<KegiatanViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isListLoading && viewModel.kegiatanList.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF047857)));
          }

          final list = viewModel.kegiatanList;
          
          int total = list.length;
          int menunggu = 0;
          int berjalan = 0;
          int selesai = 0;

          for (var doc in list) {
            final s = doc.status.toLowerCase();
            if (s == 'selesai' || s == 'completed' || s == 'lpj_done') {
              selesai++;
            } else if (s.startsWith('menunggu') || s.startsWith('disetujui') || 
                ['pending_ppk', 'approved_ppk', 'approved_wadir', 'accepted_funds', 'funds_disbursed'].contains(s)) {
              berjalan++;
            } else if (['draft', 'diajukan', 'revisi', 'submitted', 'revisi_done', 'diverifikasi', 'verified'].contains(s)) {
              menunggu++;
            }
          }

          final recentActivity = list.take(5).toList();

          return RefreshIndicator(
            onRefresh: () => viewModel.fetchKegiatanList(),
            color: const Color(0xFF047857),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildWelcomeCard(),
                  const SizedBox(height: 24),
                  
                  // Bagian Statistik
                  const Text(
                    'Ringkasan',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                  ),
                  const SizedBox(height: 16),
                  GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: 1.5,
                    children: [
                      _buildStatCard('Total', total.toString(), LucideIcons.package, const Color(0xFF10B981)),
                      _buildStatCard('Verifikasi', menunggu.toString(), LucideIcons.clock, const Color(0xFFF59E0B)),
                      _buildStatCard('Berjalan', berjalan.toString(), LucideIcons.shieldCheck, const Color(0xFF6366F1)),
                      _buildStatCard('Selesai', selesai.toString(), LucideIcons.checkCircle, const Color(0xFF10B981)),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Bagian Aktivitas Terakhir
                  const Text(
                    'Aktivitas Terakhir',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                  ),
                  const SizedBox(height: 16),
                  
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: recentActivity.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.all(32.0),
                          child: Center(
                            child: Text(
                              'Belum ada aktivitas usulan',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        )
                      : ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: recentActivity.length,
                          separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFF1F5F9)),
                          itemBuilder: (context, index) {
                            final item = recentActivity[index];
                            return ListTile(
                              leading: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: const BoxDecoration(color: Color(0xFFF1F5F9), shape: BoxShape.circle),
                                child: const Icon(LucideIcons.fileText, color: Color(0xFF64748B), size: 20),
                              ),
                              title: Text(
                                item.namaKegiatan,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                              ),
                              subtitle: Text(
                                item.createdAt.substring(0, 10),
                                style: const TextStyle(fontSize: 12),
                              ),
                              trailing: _buildStatusBadge(item.status),
                              onTap: () {
                                // Bisa di-link ke Detail jika perlu
                              },
                            );
                          },
                        ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String title, String count, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 28),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 8),
          Text(count, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF1E293B), height: 1.1)),
          Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF64748B))),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor = Colors.grey.shade100;
    Color textColor = Colors.grey.shade700;
    String label = status.toUpperCase();

    if (['diajukan', 'submitted', 'menunggu'].contains(status.toLowerCase())) {
      bgColor = Colors.blue.shade50;
      textColor = Colors.blue.shade700;
    } else if (['revisi', 'revision_requested'].contains(status.toLowerCase())) {
      bgColor = Colors.orange.shade50;
      textColor = Colors.orange.shade700;
    } else if (['disetujui', 'verified', 'approved_ppk', 'approved_wadir'].contains(status.toLowerCase())) {
      bgColor = Colors.green.shade50;
      textColor = Colors.green.shade700;
    } else if (status.toLowerCase().contains('tolak') || status.toLowerCase() == 'rejected') {
      bgColor = Colors.red.shade50;
      textColor = Colors.red.shade700;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: textColor),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF047857), Color(0xFF059669)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF047857).withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Selamat Datang kembali,',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.user.nama,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    widget.user.role.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: SvgPicture.asset(
              'assets/svg/app-logo.svg',
              height: 40,
              width: 40,
            ),
          )
        ],
      ),
    );
  }
}
