import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../auth/models/user.dart';

import 'home_tab_view.dart';
import 'kegiatan_list_view.dart';
import 'kegiatan_archive_view.dart';
import 'kegiatan_history_view.dart';
import '../../chat/views/jana_chat_view.dart';
import '../../profile/views/profile_view.dart';
import '../../monitoring/views/monitoring_dashboard_view.dart';
import '../../lpj/views/lpj_list_view.dart';
import '../../user_management/views/user_list_view.dart';
import '../../master_data/views/iku_config_view.dart';

/// Role-adaptive dashboard that mirrors the web's ROLE_MENUS pattern.
/// Each role gets a different set of bottom navigation tabs.
class DashboardView extends StatefulWidget {
  final User user;
  const DashboardView({super.key, required this.user});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  int _currentIndex = 0;

  late final List<_NavItem> _navItems;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _navItems = _getNavItemsForRole(widget.user.role);
    _pages = _navItems.map((item) => item.page).toList();
  }

  List<_NavItem> _getNavItemsForRole(String role) {
    final normalizedRole = role.startsWith('wadir') ? 'wadir' : role;

    switch (normalizedRole) {
      case 'pengusul':
        return [
          _NavItem(icon: LucideIcons.home, label: 'Beranda', page: HomeTabView(user: widget.user)),
          _NavItem(icon: LucideIcons.fileText, label: 'Usulan', page: KegiatanListView(currentUser: widget.user)),
          _NavItem(icon: LucideIcons.archive, label: 'Riwayat', page: const KegiatanHistoryView()),
          _NavItem(icon: LucideIcons.bot, label: 'Jana AI', page: const JanaChatView()),
          _NavItem(icon: LucideIcons.userCircle, label: 'Profil', page: ProfileView(user: widget.user)),
        ];

      case 'verifikator':
        return [
          _NavItem(icon: LucideIcons.home, label: 'Beranda', page: HomeTabView(user: widget.user)),
          _NavItem(icon: LucideIcons.clipboardList, label: 'Proposal', page: KegiatanListView(currentUser: widget.user)),
          _NavItem(icon: LucideIcons.archive, label: 'Arsip', page: const KegiatanArchiveView()),
          _NavItem(icon: LucideIcons.activity, label: 'Monitor', page: const MonitoringDashboardView()),
          _NavItem(icon: LucideIcons.userCircle, label: 'Profil', page: ProfileView(user: widget.user)),
        ];

      case 'ppk':
        return [
          _NavItem(icon: LucideIcons.home, label: 'Beranda', page: HomeTabView(user: widget.user)),
          _NavItem(icon: LucideIcons.clipboardList, label: 'Proposal', page: KegiatanListView(currentUser: widget.user)),
          _NavItem(icon: LucideIcons.archive, label: 'Arsip', page: const KegiatanArchiveView()),
          _NavItem(icon: LucideIcons.activity, label: 'Monitor', page: const MonitoringDashboardView()),
          _NavItem(icon: LucideIcons.userCircle, label: 'Profil', page: ProfileView(user: widget.user)),
        ];

      case 'wadir':
        return [
          _NavItem(icon: LucideIcons.home, label: 'Beranda', page: HomeTabView(user: widget.user)),
          _NavItem(icon: LucideIcons.clipboardList, label: 'Proposal', page: KegiatanListView(currentUser: widget.user)),
          _NavItem(icon: LucideIcons.archive, label: 'Arsip', page: const KegiatanArchiveView()),
          _NavItem(icon: LucideIcons.activity, label: 'Monitor', page: const MonitoringDashboardView()),
          _NavItem(icon: LucideIcons.userCircle, label: 'Profil', page: ProfileView(user: widget.user)),
        ];

      case 'bendahara':
        return [
          _NavItem(icon: LucideIcons.home, label: 'Beranda', page: HomeTabView(user: widget.user)),
          _NavItem(icon: LucideIcons.dollarSign, label: 'Dana & LPJ', page: const LpjListView()),
          _NavItem(icon: LucideIcons.activity, label: 'Monitor', page: const MonitoringDashboardView()),
          _NavItem(icon: LucideIcons.bot, label: 'Jana AI', page: const JanaChatView()),
          _NavItem(icon: LucideIcons.userCircle, label: 'Profil', page: ProfileView(user: widget.user)),
        ];

      case 'rektorat':
        return [
          _NavItem(icon: LucideIcons.home, label: 'Beranda', page: HomeTabView(user: widget.user)),
          _NavItem(icon: LucideIcons.barChart3, label: 'Laporan', page: const MonitoringDashboardView()),
          _NavItem(icon: LucideIcons.activity, label: 'Monitor', page: const MonitoringDashboardView()),
          _NavItem(icon: LucideIcons.bot, label: 'Jana AI', page: const JanaChatView()),
          _NavItem(icon: LucideIcons.userCircle, label: 'Profil', page: ProfileView(user: widget.user)),
        ];

      case 'admin':
        return [
          _NavItem(icon: LucideIcons.home, label: 'Beranda', page: HomeTabView(user: widget.user)),
          _NavItem(icon: LucideIcons.users, label: 'Users', page: const UserListView()),
          _NavItem(icon: LucideIcons.database, label: 'Config', page: const IkuConfigView()),
          _NavItem(icon: LucideIcons.activity, label: 'Monitor', page: const MonitoringDashboardView()),
          _NavItem(icon: LucideIcons.userCircle, label: 'Profil', page: ProfileView(user: widget.user)),
        ];

      default:
        return [
          _NavItem(icon: LucideIcons.home, label: 'Beranda', page: HomeTabView(user: widget.user)),
          _NavItem(icon: LucideIcons.fileText, label: 'Usulan', page: KegiatanListView(currentUser: widget.user)),
          _NavItem(icon: LucideIcons.bot, label: 'Jana AI', page: const JanaChatView()),
          _NavItem(icon: LucideIcons.userCircle, label: 'Profil', page: ProfileView(user: widget.user)),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
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
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedItemColor: const Color(0xFF047857),
            unselectedItemColor: const Color(0xFF94A3B8),
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 11),
            elevation: 0,
            items: _navItems.map((item) => BottomNavigationBarItem(
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
}

class _NavItem {
  final IconData icon;
  final String label;
  final Widget page;

  _NavItem({required this.icon, required this.label, required this.page});
}
