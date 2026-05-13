import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:pick_pack/core/app_constants.dart';
import 'package:pick_pack/core/app_theme.dart';
import 'package:pick_pack/features/auth/services/auth_service.dart';
import 'package:pick_pack/models/app_user.dart';
import 'package:pick_pack/features/parcels/screens/create_parcel_screen.dart';
import 'package:pick_pack/features/dashboard/screens/agent_dashboard.dart';
import 'package:pick_pack/features/dashboard/screens/owner_dashboard.dart';
import 'package:pick_pack/features/dashboard/screens/helper_dashboard.dart';
import 'package:pick_pack/features/dashboard/screens/admin_dashboard.dart';
import 'package:pick_pack/features/dashboard/screens/stats_dashboard.dart';
import 'package:pick_pack/features/dashboard/screens/settings_screen.dart';
import 'package:pick_pack/features/dashboard/screens/helper_parcels_screen.dart';
import 'package:pick_pack/features/dashboard/screens/buses_screen.dart';
import 'package:pick_pack/features/dashboard/screens/check_seats_screen.dart';
import 'package:pick_pack/features/dashboard/screens/notifications_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pick_pack/l10n/app_localizations.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  Widget _buildBodyContent(bool isDesktop, AppUser user, AppLocalizations l10n) {
    if (user.role == UserRole.admin) {
      return const AdminDashboard();
    }
    
    // Role-based content based on selected tab
    if (user.role == UserRole.agent) {
      if (_selectedIndex == 0) return const AgentDashboard();
      if (_selectedIndex == 1) return const HelperDashboard();
      if (_selectedIndex == 2) return const StatsDashboard();
      if (_selectedIndex == 3) return const BusesScreen();
      if (_selectedIndex == 4) return const CheckSeatsScreen();
      return const SettingsScreen();
    }

    if (user.role == UserRole.helper) {
      if (_selectedIndex == 0) return const HelperParcelsScreen();
      if (_selectedIndex == 1) return const HelperDashboard();
      return const SettingsScreen();
    }

    if (user.role == UserRole.owner) {
      if (_selectedIndex == 4) return const SettingsScreen();
      return OwnerDashboard(currentTab: _selectedIndex);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.horizontalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatsGrid(isDesktop, user, l10n),
          const SizedBox(height: 32),
          _buildRecentParcels(l10n),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final user = auth.currentUser;
    final isDesktop = MediaQuery.of(context).size.width > 900;
    final l10n = AppLocalizations.of(context)!;

    if (auth.error != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(LucideIcons.alertTriangle, color: AppTheme.errorColor, size: 48),
              const SizedBox(height: 16),
              Text(l10n.initializationError, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(auth.error!, style: const TextStyle(color: Colors.white70)),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => auth.signOut(),
                child: Text(l10n.signOutAndTryAgain),
              ),
            ],
          ),
        ),
      );
    }

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // All roles now use the main Scaffold to share the BottomNav/Header structure

    // Admin sees the full dashboard below
    if (isDesktop) {
      return Scaffold(
        body: Row(
          children: [
            _buildSidebar(user, l10n),
            Expanded(
              child: Column(
                children: [
                  _buildHeader(user, false, l10n),
                  Expanded(
                    child: _buildBodyContent(true, user, l10n),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(user, true, l10n),
            Expanded(
              child: _buildBodyContent(false, user, l10n),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(user, l10n),
    );
  }

  Widget _buildSidebar(AppUser user, AppLocalizations l10n) {
    return Container(
      width: 250,
      color: AppTheme.surfaceColor,
      child: Column(
        children: [
          const SizedBox(height: 40),
          Text(
            AppConstants.appName,
            style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 24),
          ),
          const SizedBox(height: 40),
          if (user.role == UserRole.admin)
            _buildSidebarItem(LucideIcons.shieldCheck, l10n.adminPanel, 0)
          else if (user.role == UserRole.agent) ...[
            _buildSidebarItem(LucideIcons.layoutDashboard, l10n.home, 0),
            _buildSidebarItem(LucideIcons.search, l10n.track, 1),
            _buildSidebarItem(LucideIcons.barChart, l10n.stats, 2),
            _buildSidebarItem(LucideIcons.bus, l10n.buses, 3),
            _buildSidebarItem(LucideIcons.sofa, l10n.checkSeats, 4),
            _buildSidebarItem(LucideIcons.settings, l10n.settings, 5),
          ] else if (user.role == UserRole.helper) ...[
            _buildSidebarItem(LucideIcons.inbox, l10n.parcel, 0),
            _buildSidebarItem(LucideIcons.search, l10n.track, 1),
            _buildSidebarItem(LucideIcons.settings, l10n.settings, 2),
          ] else if (user.role == UserRole.owner) ...[
            _buildSidebarItem(LucideIcons.layoutDashboard, l10n.home, 0),
            _buildSidebarItem(LucideIcons.building2, l10n.myAgencies, 1),
            _buildSidebarItem(LucideIcons.users, l10n.users, 2),
            _buildSidebarItem(LucideIcons.banknote, l10n.fees, 3),
            _buildSidebarItem(LucideIcons.settings, l10n.settings, 4),
          ] else ...[
            // default
            _buildSidebarItem(LucideIcons.layoutDashboard, l10n.home, 0),
            _buildSidebarItem(LucideIcons.settings, l10n.settings, 1),
          ],
        ],
      ),
    );
  }

  Widget _buildSidebarItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    return ListTile(
      leading: Icon(icon, color: isSelected ? AppTheme.primaryColor : Colors.white60),
      title: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.white60,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      onTap: () => setState(() => _selectedIndex = index),
      selected: isSelected,
    );
  }

  Widget _buildHeader(AppUser user, bool isMobile, AppLocalizations l10n) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppConstants.horizontalPadding,
        vertical: isMobile ? 12 : 20,
      ),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.05))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l10n.welcomeBack, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white60)),
                Text(
                  '${user.name} (${user.role.name.toUpperCase()})',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('notifications')
                    .where('userId', isEqualTo: user.uid)
                    .where('isRead', isEqualTo: false)
                    .snapshots(),
                builder: (context, snapshot) {
                  final unreadCount = snapshot.data?.docs.length ?? 0;
                  return Stack(
                    children: [
                      IconButton(
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            backgroundColor: Colors.transparent,
                            isScrollControlled: true,
                            builder: (context) => DraggableScrollableSheet(
                              initialChildSize: 0.7,
                              maxChildSize: 0.9,
                              minChildSize: 0.5,
                              builder: (context, scrollController) => 
                                  NotificationsScreen(userId: user.uid),
                            ),
                          );
                        },
                        icon: const Icon(LucideIcons.bell, size: 20),
                        visualDensity: VisualDensity.compact,
                      ),
                      if (unreadCount > 0)
                        Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppTheme.backgroundColor, width: 1.5),
                            ),
                            constraints: const BoxConstraints(minWidth: 12, minHeight: 12),
                            child: Text(
                              unreadCount > 9 ? '9+' : '$unreadCount',
                              style: const TextStyle(color: Colors.white, fontSize: 7, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
              const SizedBox(width: 4),
              IconButton(
                onPressed: () => context.read<AuthService>().signOut(),
                icon: const Icon(LucideIcons.logOut, color: Colors.white60, size: 20),
                visualDensity: VisualDensity.compact,
              ),
              const SizedBox(width: 8),
              CircleAvatar(
                radius: 16,
                backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
                child: const Icon(LucideIcons.user, color: AppTheme.primaryColor, size: 16),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(bool isDesktop, AppUser user, AppLocalizations l10n) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: isDesktop ? 4 : 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(l10n.totalParcels, '124', LucideIcons.package, AppTheme.primaryColor),
        _buildStatCard(l10n.inTransit, '45', LucideIcons.truck, AppTheme.accentColor),
        _buildStatCard(l10n.delivered, '78', LucideIcons.checkCircle, AppTheme.secondaryColor),
        _buildStatCard(l10n.pending, '12', LucideIcons.clock, Colors.orange),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: AppConstants.borderRadiusLg,
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 24)),
              Text(title, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentParcels(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(l10n.recentParcels, style: Theme.of(context).textTheme.titleLarge),
            TextButton(onPressed: () {}, child: Text(l10n.viewAll)),
          ],
        ),
        const SizedBox(height: 16),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 5,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            return _buildParcelItem(l10n);
          },
        ),
      ],
    );
  }

  Widget _buildParcelItem(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: AppConstants.borderRadiusMd,
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: AppConstants.borderRadiusSm,
            ),
            child: const Icon(LucideIcons.package, color: AppTheme.primaryColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('PK-2024-001', style: Theme.of(context).textTheme.titleSmall),
                Text('${l10n.toDestination} Lagos Agency', style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.accentColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              l10n.inTransit,
              style: const TextStyle(color: AppTheme.accentColor, fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav(AppUser user, AppLocalizations l10n) {
    if (user.role == UserRole.admin) return const SizedBox.shrink();

    List<BottomNavigationBarItem> items = [];
    if (user.role == UserRole.agent) {
      items = [
        BottomNavigationBarItem(icon: const Icon(LucideIcons.layoutDashboard), label: l10n.home),
        BottomNavigationBarItem(icon: const Icon(LucideIcons.search), label: l10n.track),
        BottomNavigationBarItem(icon: const Icon(LucideIcons.barChart), label: l10n.stats),
        BottomNavigationBarItem(icon: const Icon(LucideIcons.bus), label: l10n.buses),
        BottomNavigationBarItem(icon: const Icon(LucideIcons.armchair), label: l10n.checkSeats),
        BottomNavigationBarItem(icon: const Icon(LucideIcons.settings), label: l10n.settings),
      ];
    } else if (user.role == UserRole.helper) {
      items = [
        BottomNavigationBarItem(icon: const Icon(LucideIcons.inbox), label: l10n.parcel),
        BottomNavigationBarItem(icon: const Icon(LucideIcons.search), label: l10n.track),
        BottomNavigationBarItem(icon: const Icon(LucideIcons.settings), label: l10n.settings),
      ];
    } else if (user.role == UserRole.owner) {
      items = [
        BottomNavigationBarItem(icon: const Icon(LucideIcons.layoutDashboard), label: l10n.home),
        BottomNavigationBarItem(icon: const Icon(LucideIcons.building2), label: l10n.myAgencies),
        BottomNavigationBarItem(icon: const Icon(LucideIcons.users), label: l10n.users),
        BottomNavigationBarItem(icon: const Icon(LucideIcons.banknote), label: l10n.fees),
        BottomNavigationBarItem(icon: const Icon(LucideIcons.settings), label: l10n.settings),
      ];
    } else {
      items = [
        BottomNavigationBarItem(icon: const Icon(LucideIcons.layoutDashboard), label: l10n.home),
        BottomNavigationBarItem(icon: const Icon(LucideIcons.settings), label: l10n.settings),
      ];
    }

    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (index) => setState(() => _selectedIndex = index),
      backgroundColor: AppTheme.surfaceColor,
      selectedItemColor: AppTheme.primaryColor,
      unselectedItemColor: Colors.white60,
      type: BottomNavigationBarType.fixed,
      items: items,
    );
  }
}
