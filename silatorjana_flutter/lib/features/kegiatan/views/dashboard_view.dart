import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../auth/models/user.dart';
import '../../auth/viewmodels/auth_viewmodel.dart';
import '../../auth/views/login_view.dart';

import 'home_tab_view.dart';
import 'kegiatan_list_view.dart';
import 'kegiatan_archive_view.dart';
import 'kegiatan_history_view.dart';
import '../../chat/views/jana_chat_view.dart';
import '../../profile/views/profile_view.dart';
import '../../monitoring/views/monitoring_dashboard_view.dart';
import '../../monitoring/views/rekap_jurusan_view.dart';
import '../../lpj/views/lpj_list_view.dart';
import '../../user_management/views/user_list_view.dart';
import '../../master_data/views/iku_config_view.dart';
import '../../documents/views/panduan_view.dart';
import '../../documents/views/template_view.dart';
import '../../lpj/views/bendahara_laporan_view.dart';
import '../../monitoring/views/rektorat_laporan_view.dart';
import 'needs_work_view.dart';

/// Role-adaptive dashboard that mirrors the web's layouts exactly.
/// On Mobile (< 768px): Uses a BottomNavigationBar with drawer overflow.
/// On Desktop/Linux (>= 768px): Uses a premium Dark Emerald Sidebar (matching RoleLayout.tsx)
/// and a top Navbar header (height 72px).
class DashboardView extends StatefulWidget {
  final User user;
  const DashboardView({super.key, required this.user});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  int _currentIndex = 0;

  late final List<_NavItem> _allItems;
  late final List<_NavItem> _bottomItems; // max 5 for bottom nav
  late final List<_NavItem> _drawerItems; // overflow items in drawer
  late final List<Widget> _allPages;

  static const _roleLabels = {
    'admin': 'Super Admin',
    'pengusul': 'Pengusul',
    'verifikator': 'Verifikator',
    'ppk': 'PPK',
    'wadir1': 'Wadir I',
    'wadir2': 'Wadir II',
    'wadir3': 'Wadir III',
    'wadir4': 'Wadir IV',
    'bendahara': 'Bendahara',
    'rektorat': 'Rektorat',
  };

  @override
  void initState() {
    super.initState();
    _allItems = _getNavItemsForRole(widget.user.role);
    // Bottom nav max 5 items, rest go to drawer (for mobile)
    if (_allItems.length <= 5) {
      _bottomItems = _allItems;
      _drawerItems = [];
    } else {
      _bottomItems = _allItems.sublist(0, 4); // first 4
      _bottomItems.add(_NavItem(icon: LucideIcons.menu, label: 'Lainnya', page: const SizedBox()));
      _drawerItems = _allItems.sublist(4); // rest
    }
    _allPages = _allItems.map((item) => item.page).toList();
  }

  /// Mirrors web's ROLE_MENUS exactly
  List<_NavItem> _getNavItemsForRole(String role) {
    final normalizedRole = role.startsWith('wadir') ? 'wadir' : role;

    switch (normalizedRole) {
      case 'pengusul':
        return [
          _NavItem(icon: LucideIcons.home, label: 'Dashboard', page: HomeTabView(user: widget.user)),
          _NavItem(icon: LucideIcons.fileText, label: 'Usulan Saya', page: KegiatanListView(currentUser: widget.user)),
          _NavItem(icon: LucideIcons.alertTriangle, label: 'Perlu Revisi', page: NeedsWorkView(currentUser: widget.user)),
          _NavItem(icon: LucideIcons.archive, label: 'Riwayat', page: const KegiatanHistoryView()),
          _NavItem(icon: LucideIcons.activity, label: 'Monitoring', page: const MonitoringDashboardView()),
          _NavItem(icon: LucideIcons.settings, label: 'Panduan', page: const PanduanView()),
          _NavItem(icon: LucideIcons.fileText, label: 'Template', page: const TemplateView()),
          _NavItem(icon: LucideIcons.bot, label: 'Jana AI', page: const JanaChatView()),
          _NavItem(icon: LucideIcons.userCircle, label: 'Profil', page: ProfileView(user: widget.user)),
        ];

      case 'verifikator':
        return [
          _NavItem(icon: LucideIcons.home, label: 'Dashboard', page: HomeTabView(user: widget.user)),
          _NavItem(icon: LucideIcons.clipboardList, label: 'Proposal', page: KegiatanListView(currentUser: widget.user)),
          _NavItem(icon: LucideIcons.archive, label: 'Arsip', page: const KegiatanArchiveView()),
          _NavItem(icon: LucideIcons.activity, label: 'Monitoring', page: const MonitoringDashboardView()),
          _NavItem(icon: LucideIcons.userCircle, label: 'Profil', page: ProfileView(user: widget.user)),
        ];

      case 'ppk':
        return [
          _NavItem(icon: LucideIcons.home, label: 'Dashboard', page: HomeTabView(user: widget.user)),
          _NavItem(icon: LucideIcons.clipboardList, label: 'Proposal', page: KegiatanListView(currentUser: widget.user)),
          _NavItem(icon: LucideIcons.archive, label: 'Arsip', page: const KegiatanArchiveView()),
          _NavItem(icon: LucideIcons.activity, label: 'Monitoring', page: const MonitoringDashboardView()),
          _NavItem(icon: LucideIcons.userCircle, label: 'Profil', page: ProfileView(user: widget.user)),
        ];

      case 'wadir':
        return [
          _NavItem(icon: LucideIcons.home, label: 'Dashboard', page: HomeTabView(user: widget.user)),
          _NavItem(icon: LucideIcons.clipboardList, label: 'Proposal', page: KegiatanListView(currentUser: widget.user)),
          _NavItem(icon: LucideIcons.archive, label: 'Arsip', page: const KegiatanArchiveView()),
          _NavItem(icon: LucideIcons.activity, label: 'Monitoring', page: const MonitoringDashboardView()),
          _NavItem(icon: LucideIcons.userCircle, label: 'Profil', page: ProfileView(user: widget.user)),
        ];

      case 'bendahara':
        return [
          _NavItem(icon: LucideIcons.home, label: 'Dashboard', page: HomeTabView(user: widget.user)),
          _NavItem(icon: LucideIcons.dollarSign, label: 'Pencairan & LPJ', page: const LpjListView()),
          _NavItem(icon: LucideIcons.checkCircle, label: 'Laporan LPJ', page: const BendaharaLaporanView()),
          _NavItem(icon: LucideIcons.activity, label: 'Monitoring', page: const MonitoringDashboardView()),
          _NavItem(icon: LucideIcons.userCircle, label: 'Profil', page: ProfileView(user: widget.user)),
        ];

      case 'rektorat':
        return [
          _NavItem(icon: LucideIcons.home, label: 'Dashboard', page: HomeTabView(user: widget.user)),
          _NavItem(icon: LucideIcons.barChart3, label: 'Laporan', page: const RektoratLaporanView()),
          _NavItem(icon: LucideIcons.building2, label: 'Rekap Jurusan', page: const RekapJurusanView()),
          _NavItem(icon: LucideIcons.activity, label: 'Monitoring', page: const MonitoringDashboardView()),
          _NavItem(icon: LucideIcons.userCircle, label: 'Profil', page: ProfileView(user: widget.user)),
        ];

      case 'admin':
        return [
          _NavItem(icon: LucideIcons.home, label: 'Dashboard', page: HomeTabView(user: widget.user)),
          _NavItem(icon: LucideIcons.users, label: 'Users', page: const UserListView()),
          _NavItem(icon: LucideIcons.database, label: 'Config', page: const IkuConfigView()),
          _NavItem(icon: LucideIcons.activity, label: 'Monitoring', page: const MonitoringDashboardView()),
          _NavItem(icon: LucideIcons.userCircle, label: 'Profil', page: ProfileView(user: widget.user)),
        ];

      default:
        return [
          _NavItem(icon: LucideIcons.home, label: 'Dashboard', page: HomeTabView(user: widget.user)),
          _NavItem(icon: LucideIcons.fileText, label: 'Usulan', page: KegiatanListView(currentUser: widget.user)),
          _NavItem(icon: LucideIcons.bot, label: 'Jana AI', page: const JanaChatView()),
          _NavItem(icon: LucideIcons.userCircle, label: 'Profil', page: ProfileView(user: widget.user)),
        ];
    }
  }

  void _onBottomNavTap(int index) {
    if (_drawerItems.isNotEmpty && index == _bottomItems.length - 1) {
      _showDrawerMenu();
      return;
    }
    setState(() => _currentIndex = index);
  }

  void _logout() async {
    await context.read<AuthViewModel>().logout();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginView()),
        (route) => false,
      );
    }
  }

  void _showDrawerMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Menu Lainnya', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
              ),
            ),
            const SizedBox(height: 8),
            ..._drawerItems.asMap().entries.map((entry) {
              final drawerIndex = entry.key;
              final item = entry.value;
              final actualIndex = 4 + drawerIndex;
              final isActive = _currentIndex == actualIndex;
              return ListTile(
                leading: Icon(item.icon, color: isActive ? const Color(0xFF047857) : const Color(0xFF64748B)),
                title: Text(
                  item.label,
                  style: TextStyle(
                    fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                    color: isActive ? const Color(0xFF047857) : const Color(0xFF334155),
                  ),
                ),
                selected: isActive,
                selectedTileColor: const Color(0xFFECFDF5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                onTap: () {
                  Navigator.pop(ctx);
                  setState(() => _currentIndex = actualIndex);
                },
              );
            }),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 768;

    if (isDesktop) {
      return Scaffold(
        body: Row(
          children: [
            // Sidebar Layout (Web Style)
            _buildSidebar(),
            // Main Content Layout
            Expanded(
              child: Column(
                children: [
                  // Top Navbar (Web Style)
                  _buildTopNavbar(),
                  // Active Page
                  Expanded(
                    child: IndexedStack(
                      index: _currentIndex < _allPages.length ? _currentIndex : 0,
                      children: _allPages,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Mobile Layout
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex < _allPages.length ? _currentIndex : 0,
        children: _allPages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -4),
            )
          ],
        ),
        child: SafeArea(
          child: BottomNavigationBar(
            currentIndex: _currentIndex < _bottomItems.length ? _currentIndex : _bottomItems.length - 1,
            onTap: _onBottomNavTap,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedItemColor: const Color(0xFF047857),
            unselectedItemColor: const Color(0xFF94A3B8),
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 11),
            elevation: 0,
            items: _bottomItems.map((item) => BottomNavigationBarItem(
              icon: Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Icon(item.icon, size: 22),
              ),
              label: item.label,
            )).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildSidebar() {
    final activeRoleLabel = _roleLabels[widget.user.role] ?? widget.user.role.toUpperCase();

    return Container(
      width: 260,
      color: const Color(0xFF064E3B), // bg-[#064e3b]
      child: Column(
        children: [
          // BRAND HEADER
          Padding(
            padding: const EdgeInsets.only(top: 24, bottom: 16, left: 20, right: 20),
            child: Row(
              children: [
                // Logo Icon Box
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    LucideIcons.graduationCap,
                    color: Color(0xFF34D399),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Si-LATORJANA',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0x3334D399),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          activeRoleLabel,
                          style: const TextStyle(
                            color: Color(0xFF34D399),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          const Divider(color: Color(0x1AFFFFFF), height: 1),
          const SizedBox(height: 16),
          // MENU ITEMS
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _allItems.length,
              itemBuilder: (context, index) {
                final item = _allItems[index];
                final isActive = _currentIndex == index;
                return Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  child: InkWell(
                    onTap: () => setState(() => _currentIndex = index),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: isActive ? const Color(0xFF047857) : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            item.icon,
                            color: isActive ? Colors.white : const Color(0xB3D1FAE5),
                            size: 18,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              item.label,
                              style: TextStyle(
                                color: isActive ? Colors.white : const Color(0xB3D1FAE5),
                                fontSize: 13,
                                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                              ),
                            ),
                          ),
                          if (isActive)
                            Container(
                              width: 4,
                              height: 16,
                              decoration: BoxDecoration(
                                color: const Color(0xFF34D399),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            )
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // LOGOUT BUTTON
          const Divider(color: Color(0x1AFFFFFF), height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: InkWell(
              onTap: _logout,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  children: [
                    Icon(
                      LucideIcons.logOut,
                      color: Color(0xFFFCA5A5),
                      size: 18,
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Keluar Sesi',
                      style: TextStyle(
                        color: Color(0xFFFCA5A5),
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopNavbar() {
    final activeRoleLabel = _roleLabels[widget.user.role] ?? widget.user.role.toUpperCase();

    // Find indices for shortcuts
    final profileIndex = _allItems.indexWhere((item) => item.label == 'Profil' || item.page is ProfileView);
    final janaIndex = _allItems.indexWhere((item) => item.label == 'Jana AI' || item.page is JanaChatView);
    final panduanIndex = _allItems.indexWhere((item) => item.label == 'Panduan' || item.page is PanduanView);

    return Container(
      height: 72,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // PANEL IDENTITY (Web Style)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Text(
              'Panel $activeRoleLabel',
              style: const TextStyle(
                color: Color(0xFF334155),
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          
          // MIDDLE & RIGHT CONTROLS
          Row(
            children: [
              // Calendar Info
              const Icon(LucideIcons.calendar, size: 16, color: Color(0xFF64748B)),
              const SizedBox(width: 6),
              const Text(
                'Tahun Ajaran 2025/2026',
                style: TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
              ),
              const SizedBox(width: 20),
              
              // Jana AI Assistant Shortcut (Web Style)
              IconButton(
                icon: const Icon(LucideIcons.bot, size: 20, color: Color(0xFF047857)),
                tooltip: 'Jana AI Assistant',
                onPressed: () {
                  if (janaIndex >= 0) {
                    setState(() => _currentIndex = janaIndex);
                  } else {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const JanaChatView()));
                  }
                },
              ),
              
              // Interactive Guide Help (Web Style)
              IconButton(
                icon: const Icon(LucideIcons.helpCircle, size: 20, color: Color(0xFF64748B)),
                tooltip: 'Panduan Interaktif',
                onPressed: () {
                  if (panduanIndex >= 0) {
                    setState(() => _currentIndex = panduanIndex);
                  } else {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const PanduanView()));
                  }
                },
              ),
              
              // Notification Bell (Web Style)
              PopupMenuButton<String>(
                icon: const Icon(LucideIcons.bell, size: 20, color: Color(0xFF64748B)),
                tooltip: 'Notifikasi',
                itemBuilder: (ctx) => [
                  const PopupMenuItem(
                    enabled: false,
                    child: Text('Notifikasi Terbaru', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A))),
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem(
                    child: Row(
                      children: [
                        Icon(LucideIcons.checkCircle, color: Color(0xFF047857), size: 16),
                        SizedBox(width: 8),
                        Expanded(child: Text('LPJ kegiatan #10 telah disetujui', style: TextStyle(fontSize: 12))),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    child: Row(
                      children: [
                        Icon(LucideIcons.alertTriangle, color: Colors.orange, size: 16),
                        SizedBox(width: 8),
                        Expanded(child: Text('Ada 1 usulan perlu revisi segera', style: TextStyle(fontSize: 12))),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(width: 12),
              Container(width: 1, height: 24, color: const Color(0xFFE2E8F0)),
              const SizedBox(width: 16),
              
              // Profile Summary Button with Dropdown (Web Style)
              PopupMenuButton<String>(
                onSelected: (val) {
                  if (val == 'profile') {
                    if (profileIndex >= 0) {
                      setState(() => _currentIndex = profileIndex);
                    } else {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => ProfileView(user: widget.user)));
                    }
                  } else if (val == 'logout') {
                    _logout();
                  }
                },
                offset: const Offset(0, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFECFDF5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(LucideIcons.user, color: Color(0xFF047857), size: 16),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.user.nama,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                          ),
                          Text(
                            activeRoleLabel,
                            style: const TextStyle(fontSize: 10, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      const SizedBox(width: 8),
                      const Icon(LucideIcons.chevronDown, size: 14, color: Color(0xFF64748B)),
                    ],
                  ),
                ),
                itemBuilder: (ctx) => [
                  PopupMenuItem(
                    value: 'profile',
                    child: Row(
                      children: [
                        const Icon(LucideIcons.user, size: 16, color: Color(0xFF64748B)),
                        const SizedBox(width: 8),
                        const Text('Profil Lengkap', style: TextStyle(fontSize: 13)),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'logout',
                    child: Row(
                      children: [
                        const Icon(LucideIcons.logOut, size: 16, color: Colors.red),
                        const SizedBox(width: 8),
                        const Text('Keluar Sesi', style: TextStyle(fontSize: 13, color: Colors.red, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          )
        ],
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  final Widget page;

  _NavItem({required this.icon, required this.label, required this.page});
}
