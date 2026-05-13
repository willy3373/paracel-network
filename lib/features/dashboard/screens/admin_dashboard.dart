import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pick_pack/core/app_constants.dart';
import 'package:pick_pack/core/app_theme.dart';
import 'package:pick_pack/features/auth/services/auth_service.dart';
import 'package:pick_pack/features/dashboard/services/admin_service.dart';
import 'package:pick_pack/models/agency.dart';
import 'package:pick_pack/models/agency_gang.dart';
import 'package:pick_pack/models/app_user.dart';
import 'package:pick_pack/models/parcel.dart';
import 'package:pick_pack/models/system_settings.dart';
import 'package:pick_pack/features/dashboard/services/settings_service.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});
  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final _adminService = AdminService();
  final _settingsService = SettingsService();

  // ── Add Agency ─────────────────────────────────────────────
  final _agencyFormKey = GlobalKey<FormState>();
  final _agencyNameCtrl = TextEditingController();
  final _agencyPhoneCtrl = TextEditingController();
  final _agencyCityCtrl = TextEditingController();
  final _agencyDescriptionCtrl = TextEditingController();
  final _agencyLogoCtrl = TextEditingController();
  String? _agencyGangId;
  String? _agencyGangLine;
  bool _agencyLoading = false;

  // ── Add User ───────────────────────────────────────────────
  final _userFormKey = GlobalKey<FormState>();
  final _userEmailCtrl = TextEditingController();
  final _userPassCtrl = TextEditingController();
  final _userNameCtrl = TextEditingController();
  UserRole _userRole = UserRole.agent;
  String? _selectedAgencyId;
  String? _selectedGangId;
  bool _userLoading = false;

  // ── Create Gang ────────────────────────────────────────────
  final _gangFormKey = GlobalKey<FormState>();
  final _gangNameCtrl = TextEditingController();
  final _gangFeeCtrl = TextEditingController();
  final List<TextEditingController> _gangLinesCtrls = [TextEditingController()];
  final Set<String> _gangAgencyIds = {};
  bool _gangLoading = false;
  int _currentIndex = 0;

  // ── Fees Tab State ─────────────────────────────────────────
  String? _feeGangId;
  String? _feeAgencyId;
  DateTime _feeDateFrom = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime _feeDateTo = DateTime.now();

  // ── Search Controllers ─────────────────────────────────────
  final _agencySearchCtrl = TextEditingController();
  final _gangSearchCtrl = TextEditingController();
  final _userSearchCtrl = TextEditingController();

  @override
  void dispose() {
    _agencyNameCtrl.dispose();
    _agencyPhoneCtrl.dispose();
    _agencyCityCtrl.dispose();
    _agencyDescriptionCtrl.dispose();
    _agencyLogoCtrl.dispose();
    _userEmailCtrl.dispose();
    _userPassCtrl.dispose();
    _userNameCtrl.dispose();
    _gangNameCtrl.dispose();
    _gangFeeCtrl.dispose();
    for (var ctrl in _gangLinesCtrls) {
      ctrl.dispose();
    }
    _agencySearchCtrl.dispose();
    _gangSearchCtrl.dispose();
    _userSearchCtrl.dispose();
    super.dispose();
  }

  void _snack(String msg, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: error ? AppTheme.errorColor : AppTheme.secondaryColor,
    ));
  }

  Future<void> _submitAgency() async {
    if (!_agencyFormKey.currentState!.validate()) return;
    setState(() => _agencyLoading = true);
    final err = await _adminService.addAgency(
      name: _agencyNameCtrl.text,
      phone: _agencyPhoneCtrl.text,
      city: _agencyCityCtrl.text,
      description: _agencyDescriptionCtrl.text,
      logoUrl: _agencyLogoCtrl.text,
      gangId: _agencyGangId,
      gangLine: _agencyGangLine,
    );
    setState(() => _agencyLoading = false);
    if (err != null) { _snack(err, error: true); return; }
    _agencyNameCtrl.clear();
    _agencyPhoneCtrl.clear();
    _agencyCityCtrl.clear();
    _agencyDescriptionCtrl.clear();
    _agencyLogoCtrl.clear();
    setState(() { _agencyGangId = null; _agencyGangLine = null; });
    _snack('Agency added successfully!');
  }

  Future<void> _submitUser() async {
    if (!_userFormKey.currentState!.validate()) return;
    if (_userRole == UserRole.owner) {
      if (_selectedGangId == null) { _snack('Please select a gang for the owner.', error: true); return; }
    } else {
      if (_selectedAgencyId == null) { _snack('Please select an agency.', error: true); return; }
    }
    setState(() => _userLoading = true);
    final auth = context.read<AuthService>();
    final err = await auth.adminCreateUser(
      email: _userEmailCtrl.text.trim(),
      password: _userPassCtrl.text.trim(),
      name: _userNameCtrl.text.trim(),
      role: _userRole,
      agencyId: _userRole == UserRole.owner ? null : _selectedAgencyId,
      gangId: _userRole == UserRole.owner ? _selectedGangId : null,
    );
    setState(() => _userLoading = false);
    if (err != null) { _snack(err, error: true); return; }
    _userEmailCtrl.clear(); _userPassCtrl.clear(); _userNameCtrl.clear();
    setState(() { _selectedAgencyId = null; _selectedGangId = null; _userRole = UserRole.agent; });
    _snack('User created successfully!');
  }

  Future<void> _submitGang() async {
    if (!_gangFormKey.currentState!.validate()) return;
    setState(() => _gangLoading = true);
    final linesList = _gangLinesCtrls
        .map((c) => c.text.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    final err = await _adminService.createGang(
      name: _gangNameCtrl.text,
      agencyIds: _gangAgencyIds.toList(),
      lines: linesList,
      fee: double.tryParse(_gangFeeCtrl.text) ?? 0.0,
    );
    setState(() => _gangLoading = false);
    if (err != null) { _snack(err, error: true); return; }
    _gangNameCtrl.clear();
    _gangFeeCtrl.clear();
    setState(() {
      _gangLinesCtrls.clear();
      _gangLinesCtrls.add(TextEditingController());
      _gangAgencyIds.clear();
    });
    _snack('Gang created successfully!');
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth > 800;
        
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Row(
            children: [
              if (isDesktop) _buildSideNav(),
              Expanded(
                child: StreamBuilder<List<Agency>>(
                  stream: _adminService.agenciesStream(),
                  builder: (context, agSnap) {
                    final agencies = agSnap.data ?? [];
                    return StreamBuilder<List<AgencyGang>>(
                      stream: _adminService.gangsStream(),
                      builder: (context, gangSnap) {
                        final gangs = gangSnap.data ?? [];
                        return _buildCurrentTab(agencies, gangs);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
          bottomNavigationBar: isDesktop ? null : _buildBottomNav(),
        );
      },
    );
  }

  Widget _buildSideNav() {
    return Container(
      width: 200,
      color: AppTheme.surfaceColor,
      child: Column(
        children: [
          const SizedBox(height: 32),
          const Icon(LucideIcons.shieldCheck, color: AppTheme.primaryColor, size: 48),
          const SizedBox(height: 32),
          _navItem(0, LucideIcons.plusSquare, 'Create New'),
          _navItem(1, LucideIcons.building2, 'Agencies'),
          _navItem(2, LucideIcons.layers, 'Gangs'),
          _navItem(3, LucideIcons.users, 'Users'),
          _navItem(4, LucideIcons.banknote, 'Fees'),
          _navItem(5, LucideIcons.settings, 'Settings'),
        ],
      ),
    );
  }

  Widget _navItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    return ListTile(
      leading: Icon(icon, color: isSelected ? AppTheme.primaryColor : Colors.white60, size: 20),
      title: Text(label, style: TextStyle(color: isSelected ? Colors.white : Colors.white60, fontSize: 13, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
      onTap: () => setState(() => _currentIndex = index),
      selected: isSelected,
      selectedTileColor: AppTheme.primaryColor.withOpacity(0.1),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (i) => setState(() => _currentIndex = i),
      backgroundColor: AppTheme.surfaceColor,
      selectedItemColor: AppTheme.primaryColor,
      unselectedItemColor: Colors.white60,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(icon: Icon(LucideIcons.plusSquare), label: 'New'),
        BottomNavigationBarItem(icon: Icon(LucideIcons.building2), label: 'Agencies'),
        BottomNavigationBarItem(icon: Icon(LucideIcons.layers), label: 'Gangs'),
        BottomNavigationBarItem(icon: Icon(LucideIcons.users), label: 'Users'),
        BottomNavigationBarItem(icon: Icon(LucideIcons.banknote), label: 'Fees'),
        BottomNavigationBarItem(icon: Icon(LucideIcons.settings), label: 'Settings'),
      ],
    );
  }

  Widget _buildCurrentTab(List<Agency> agencies, List<AgencyGang> gangs) {
    switch (_currentIndex) {
      case 0:
        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.horizontalPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Admin Dashboard', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text('Manage agencies, users and gangs', style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 32),
              _buildAddAgencyCard(gangs),
              const SizedBox(height: 24),
              _buildAddUserCard(agencies, gangs),
              const SizedBox(height: 24),
              _buildCreateGangCard(agencies, gangs),
            ],
          ),
        );
      case 1: return _buildAgenciesTab(agencies);
      case 2: return _buildGangsTab(gangs, agencies);
      case 3: return _buildUsersTab(agencies);
      case 4: return _buildFeesTab(agencies, gangs);
      case 5: return _buildSettingsTab();
      default: return const SizedBox();
    }
  }

  // ── Panel 1: Add Agency ───────────────────────────────────────────────────

  Widget _buildAddAgencyCard(List<AgencyGang> gangs) {
    return _card(
      icon: LucideIcons.building2,
      title: 'Add New Agency',
      child: Form(
        key: _agencyFormKey,
        child: Column(children: [
          _field('Agency Name', LucideIcons.building2, _agencyNameCtrl,
              validator: (v) => v!.isEmpty ? 'Required' : null),
          const SizedBox(height: 16),
          _field('Phone Number', LucideIcons.phone, _agencyPhoneCtrl,
              keyboardType: TextInputType.phone,
              validator: (v) => v!.isEmpty ? 'Required' : null),
          const SizedBox(height: 16),
          _field('City', LucideIcons.mapPin, _agencyCityCtrl,
              validator: (v) => v!.isEmpty ? 'Required' : null),
          const SizedBox(height: 16),
          _field('Agency Description', LucideIcons.fileText, _agencyDescriptionCtrl,
              maxLines: 3),
          const SizedBox(height: 16),
          _field('Logo URL', LucideIcons.image, _agencyLogoCtrl),
          const SizedBox(height: 16),
          _dropdown<String>(
            label: 'Assign to Gang (Optional)',
            icon: LucideIcons.layers,
            value: _agencyGangId,
            items: gangs.map((g) => g.id).toList(),
            itemLabel: (id) => gangs.firstWhere((g) => g.id == id).name,
            onChanged: (v) => setState(() { _agencyGangId = v; _agencyGangLine = null; }),
          ),
          if (_agencyGangId != null) ...[
            const SizedBox(height: 16),
            Builder(builder: (context) {
              final gang = gangs.firstWhere((g) => g.id == _agencyGangId);
              if (gang.lines.isEmpty) return const SizedBox.shrink();
              return _dropdown<String>(
                label: 'Assign to Gang Line (Optional)',
                icon: LucideIcons.gitCommit,
                value: _agencyGangLine,
                items: gang.lines,
                itemLabel: (line) => line,
                onChanged: (v) => setState(() => _agencyGangLine = v),
              );
            }),
          ],
          const SizedBox(height: 24),
          _btn('Add Agency', _agencyLoading, _submitAgency),
        ]),
      ),
    );
  }

  // ── Panel 2: Add User ────────────────────────────────────────────────────

  Widget _buildAddUserCard(List<Agency> agencies, List<AgencyGang> gangs) {
    return _card(
      icon: LucideIcons.userPlus,
      title: 'Add New User',
      child: Form(
        key: _userFormKey,
        child: Column(children: [
          _field('Full Name', LucideIcons.user, _userNameCtrl,
              validator: (v) => v!.isEmpty ? 'Required' : null),
          const SizedBox(height: 16),
          _field('Email Address', LucideIcons.mail, _userEmailCtrl,
              keyboardType: TextInputType.emailAddress,
              validator: (v) => !v!.contains('@') ? 'Invalid email' : null),
          const SizedBox(height: 16),
          _field('Password', LucideIcons.lock, _userPassCtrl,
              obscure: true,
              validator: (v) => v!.length < 6 ? 'Min 6 characters' : null),
          const SizedBox(height: 16),
          _dropdown<UserRole>(
            label: 'Role',
            icon: LucideIcons.shield,
            value: _userRole,
            items: [UserRole.owner, UserRole.agent, UserRole.helper],
            itemLabel: (r) => r.name.toUpperCase(),
            onChanged: (v) => setState(() {
              _userRole = v!;
              _selectedAgencyId = null;
              _selectedGangId = null;
            }),
          ),
          const SizedBox(height: 16),
          if (_userRole == UserRole.owner)
            _dropdown<String>(
              label: 'Assign to Gang',
              icon: LucideIcons.layers,
              value: _selectedGangId,
              items: gangs.map((g) => g.id).toList(),
              itemLabel: (id) => gangs.firstWhere((g) => g.id == id).name,
              onChanged: (v) => setState(() => _selectedGangId = v),
            )
          else
            _dropdown<String>(
              label: 'Assign to Agency',
              icon: LucideIcons.building2,
              value: _selectedAgencyId,
              items: agencies.map((a) => a.id).toList(),
              itemLabel: (id) => agencies.firstWhere((a) => a.id == id).name,
              onChanged: (v) => setState(() => _selectedAgencyId = v),
            ),
          const SizedBox(height: 24),
          _btn('Create User', _userLoading, _submitUser),
        ]),
      ),
    );
  }

  // ── Panel 4: Create Gang ─────────────────────────────────────────────────

  Widget _buildCreateGangCard(List<Agency> agencies, List<AgencyGang> gangs) {
    return _card(
      icon: LucideIcons.layers,
      title: 'Manage Gangs of Agencies',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Form(
            key: _gangFormKey,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _field('New Gang Name', LucideIcons.tag, _gangNameCtrl,
                  validator: (v) => v!.isEmpty ? 'Required' : null),
              const SizedBox(height: 16),
              _field('Shipment Fee (MRU)', LucideIcons.banknote, _gangFeeCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (v) => v!.isEmpty ? 'Required' : null),
              const SizedBox(height: 16),
              const Text('Gang Lines (Optional)', style: TextStyle(color: Colors.white70, fontSize: 13)),
              const SizedBox(height: 8),
              ..._gangLinesCtrls.asMap().entries.map((e) {
                final idx = e.key;
                final ctrl = e.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: _field('Line Name', LucideIcons.gitBranch, ctrl),
                      ),
                      if (_gangLinesCtrls.length > 1)
                        IconButton(
                          icon: const Icon(LucideIcons.minusCircle, color: AppTheme.errorColor),
                          onPressed: () {
                            setState(() {
                              ctrl.dispose();
                              _gangLinesCtrls.removeAt(idx);
                            });
                          },
                        ),
                    ],
                  ),
                );
              }),
              TextButton.icon(
                onPressed: () => setState(() => _gangLinesCtrls.add(TextEditingController())),
                icon: const Icon(LucideIcons.plusCircle, size: 16, color: AppTheme.primaryColor),
                label: const Text('Add Another Line', style: TextStyle(color: AppTheme.primaryColor)),
              ),
              const SizedBox(height: 16),
              Text('Select Agencies for New Gang (Optional)', style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 8),
              agencies.isEmpty
                  ? const Text('No agencies yet.', style: TextStyle(color: Colors.white38))
                  : Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: agencies.map((a) {
                        final selected = _gangAgencyIds.contains(a.id);
                        return FilterChip(
                          label: Text(a.name),
                          selected: selected,
                          onSelected: (on) => setState(() {
                            if (on) _gangAgencyIds.add(a.id);
                            else _gangAgencyIds.remove(a.id);
                          }),
                          selectedColor: AppTheme.primaryColor.withOpacity(0.3),
                          checkmarkColor: AppTheme.primaryColor,
                          backgroundColor: Colors.white.withOpacity(0.05),
                          labelStyle: TextStyle(
                            color: selected ? AppTheme.primaryColor : Colors.white70,
                          ),
                        );
                      }).toList(),
                    ),
              const SizedBox(height: 24),
              _btn('Create Gang', _gangLoading, _submitGang),
            ]),
          ),
        ],
      ),
    );
  }

  // ── Shared Widgets ────────────────────────────────────────────────────────

  Widget _card({required IconData icon, required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: AppConstants.borderRadiusLg,
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.15),
              borderRadius: AppConstants.borderRadiusSm,
            ),
            child: Icon(icon, color: AppTheme.primaryColor, size: 20),
          ),
          const SizedBox(width: 12),
          Text(title, style: Theme.of(context).textTheme.titleMedium),
        ]),
        const SizedBox(height: 24),
        child,
      ]),
    );
  }

  Widget _field(
    String label,
    IconData icon,
    TextEditingController ctrl, {
    bool obscure = false,
    TextInputType? keyboardType,
    int? maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: ctrl,
      obscureText: obscure,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white60),
        prefixIcon: Icon(icon, size: 20, color: Colors.white60),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(borderRadius: AppConstants.borderRadiusMd, borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppConstants.borderRadiusMd,
          borderSide: BorderSide(color: Colors.white.withOpacity(0.07)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppConstants.borderRadiusMd,
          borderSide: const BorderSide(color: AppTheme.primaryColor),
        ),
      ),
    );
  }

  Widget _dropdown<T>({
    required String label,
    required IconData icon,
    required T? value,
    required List<T> items,
    required String Function(T) itemLabel,
    required void Function(T?) onChanged,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white60),
        prefixIcon: Icon(icon, size: 20, color: Colors.white60),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(borderRadius: AppConstants.borderRadiusMd, borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppConstants.borderRadiusMd,
          borderSide: BorderSide(color: Colors.white.withOpacity(0.07)),
        ),
      ),
      dropdownColor: AppTheme.surfaceColor,
      style: const TextStyle(color: Colors.white),
      hint: Text('Select $label', style: const TextStyle(color: Colors.white38)),
      items: items.map((item) => DropdownMenuItem<T>(
        value: item,
        child: Text(itemLabel(item)),
      )).toList(),
      onChanged: onChanged,
    );
  }

  Widget _btn(String label, bool loading, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: loading ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: AppConstants.borderRadiusMd),
        ),
        child: loading
            ? const SizedBox(height: 20, width: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
      ),
    );
  }

  // ── Tab: Agencies ─────────────────────────────────────────────────────────
  Widget _buildAgenciesTab(List<Agency> agencies) {
    final query = _agencySearchCtrl.text.toLowerCase();
    final filtered = agencies.where((a) => a.name.toLowerCase().contains(query)).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(AppConstants.horizontalPadding),
          child: _searchField('Search Agencies by Name...', _agencySearchCtrl),
        ),
        Expanded(
          child: filtered.isEmpty
              ? const Center(child: Text('No agencies found.', style: TextStyle(color: Colors.white38)))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: AppConstants.horizontalPadding),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final a = filtered[index];
                    final isBlocked = a.isBlocked;
                    return Card(
                      color: AppTheme.surfaceColor,
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: Icon(LucideIcons.building2, color: isBlocked ? AppTheme.errorColor : AppTheme.primaryColor),
                        title: Text(a.name, style: TextStyle(fontWeight: FontWeight.bold, color: isBlocked ? Colors.white38 : Colors.white)),
                        subtitle: Text(isBlocked ? 'BLOCKED' : '${a.city} • ${a.phone}${a.gangLine != null ? ' • Line: ${a.gangLine}' : ''}', style: TextStyle(color: isBlocked ? AppTheme.errorColor : Colors.white60)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(LucideIcons.edit3, color: AppTheme.primaryColor, size: 20),
                              onPressed: () => _showEditAgencyDialog(a),
                              tooltip: 'Edit',
                            ),
                            IconButton(
                              icon: Icon(isBlocked ? LucideIcons.unlock : LucideIcons.lock, color: isBlocked ? Colors.green : Colors.orange, size: 20),
                              onPressed: () => _adminService.toggleBlockAgency(a.id, isBlocked),
                              tooltip: isBlocked ? 'Unblock' : 'Block',
                            ),
                            IconButton(
                              icon: const Icon(LucideIcons.trash2, color: AppTheme.errorColor, size: 20),
                              onPressed: () async {
                                final confirm = await _showConfirm('Delete Agency', 'Are you sure you want to delete "${a.name}"?');
                                if (confirm) {
                                  final err = await _adminService.deleteAgency(a.id);
                                  if (err != null) _snack(err, error: true);
                                  else _snack('Agency deleted.');
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Future<bool> _showConfirm(String title, String content) async {
    return await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Confirm', style: TextStyle(color: AppTheme.errorColor))),
        ],
      ),
    ) ?? false;
  }

  // ── Tab: Gangs ────────────────────────────────────────────────────────────
  Widget _buildGangsTab(List<AgencyGang> gangs, List<Agency> agencies) {
    final query = _gangSearchCtrl.text.toLowerCase();
    final filtered = gangs.where((g) => g.name.toLowerCase().contains(query)).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(AppConstants.horizontalPadding),
          child: _searchField('Search Gangs by Name...', _gangSearchCtrl),
        ),
        Expanded(
          child: filtered.isEmpty
              ? const Center(child: Text('No gangs found.', style: TextStyle(color: Colors.white38)))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: AppConstants.horizontalPadding),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final g = filtered[index];
                    final isBlocked = g.isBlocked;
                    return Card(
                      color: AppTheme.surfaceColor,
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: Icon(LucideIcons.layers, color: isBlocked ? AppTheme.errorColor : AppTheme.primaryColor),
                        title: Text(g.name, style: TextStyle(fontWeight: FontWeight.bold, color: isBlocked ? Colors.white38 : Colors.white)),
                        subtitle: Text(isBlocked ? 'BLOCKED' : '${g.agencyIds.length} agencies  •  Fee: ${g.fee} MRU', style: TextStyle(color: isBlocked ? AppTheme.errorColor : Colors.white60)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(LucideIcons.edit3, color: AppTheme.primaryColor, size: 20),
                              onPressed: () => _showEditGangDialog(g, agencies),
                              tooltip: 'Edit',
                            ),
                            IconButton(
                              icon: Icon(isBlocked ? LucideIcons.unlock : LucideIcons.lock, color: isBlocked ? Colors.green : Colors.orange, size: 20),
                              onPressed: () => _adminService.toggleBlockGang(g.id, isBlocked),
                              tooltip: isBlocked ? 'Unblock' : 'Block',
                            ),
                            IconButton(
                              icon: const Icon(LucideIcons.trash2, color: AppTheme.errorColor, size: 20),
                              onPressed: () async {
                                final confirm = await _showConfirm('Delete Gang', 'Are you sure you want to delete "${g.name}"?');
                                if (confirm) {
                                  final err = await _adminService.deleteGang(g.id);
                                  if (err != null) _snack(err, error: true);
                                  else _snack('Gang deleted.');
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  // ── Tab: Users ────────────────────────────────────────────────────────────
  Widget _buildUsersTab(List<Agency> agencies) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _adminService.usersStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Error loading users', style: TextStyle(color: Colors.white60)));
        }
        
        final query = _userSearchCtrl.text.toLowerCase();
        final users = (snapshot.data ?? []).where((u) {
          final name = (u['name'] ?? '').toString().toLowerCase();
          final email = (u['email'] ?? '').toString().toLowerCase();
          final phone = (u['phone'] ?? '').toString().toLowerCase(); // Just in case it's there
          return name.contains(query) || email.contains(query) || phone.contains(query);
        }).toList();

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppConstants.horizontalPadding),
              child: _searchField('Search Users by Name, Email or Phone...', _userSearchCtrl),
            ),
            Expanded(
              child: users.isEmpty
                  ? const Center(child: Text('No users found.', style: TextStyle(color: Colors.white38)))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: AppConstants.horizontalPadding),
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        final u = users[index];
                        final uid = u['uid'] ?? '';
                        final role = u['role']?.toString().toUpperCase() ?? 'UNKNOWN';
                        final isBlocked = u['isBlocked'] == true;
                        return Card(
                          color: AppTheme.surfaceColor,
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: isBlocked ? AppTheme.errorColor : AppTheme.primaryColor,
                              child: Icon(isBlocked ? LucideIcons.userX : LucideIcons.user, color: Colors.white, size: 18),
                            ),
                            title: Row(
                              children: [
                                Expanded(child: Text(u['name'] ?? 'No Name', style: TextStyle(fontWeight: FontWeight.bold, color: isBlocked ? Colors.white38 : Colors.white))),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: isBlocked ? Colors.white10 : AppTheme.primaryColor.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(role, style: TextStyle(color: isBlocked ? Colors.white24 : AppTheme.primaryColor, fontSize: 10, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                            subtitle: Text(u['email'] ?? 'No Email', style: TextStyle(color: isBlocked ? Colors.white24 : Colors.white60)),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(LucideIcons.edit3, color: AppTheme.primaryColor, size: 18),
                                  onPressed: () => _showEditUserDialog(u, agencies, _adminService.gangsStream()),
                                  tooltip: 'Edit',
                                ),
                                IconButton(
                                  icon: const Icon(LucideIcons.key, color: Colors.blue, size: 18),
                                  onPressed: () => _showResetPasswordDialog(u['email'] ?? '', u['name'] ?? 'User'),
                                  tooltip: 'Reset Password',
                                ),
                                IconButton(
                                  icon: Icon(isBlocked ? LucideIcons.unlock : LucideIcons.lock, color: isBlocked ? Colors.green : Colors.orange, size: 18),
                                  onPressed: () => _adminService.toggleBlockUser(uid, isBlocked),
                                  tooltip: isBlocked ? 'Unblock' : 'Block',
                                ),
                                IconButton(
                                  icon: const Icon(LucideIcons.trash2, color: AppTheme.errorColor, size: 18),
                                  onPressed: () async {
                                    final confirm = await _showConfirm('Delete User', 'Delete "${u['name']}"? This cannot be undone.');
                                    if (confirm) {
                                      final err = await _adminService.deleteUser(uid);
                                      if (err != null) _snack(err, error: true);
                                      else _snack('User profile deleted.');
                                    }
                                  },
                                  tooltip: 'Delete',
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _searchField(String hint, TextEditingController ctrl) {
    return TextFormField(
      controller: ctrl,
      onChanged: (_) => setState(() {}),
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white30),
        prefixIcon: const Icon(LucideIcons.search, size: 18, color: Colors.white30),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
        border: OutlineInputBorder(borderRadius: AppConstants.borderRadiusMd, borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppConstants.borderRadiusMd,
          borderSide: BorderSide(color: Colors.white.withOpacity(0.05)),
        ),
      ),
    );
  }

  void _showResetPasswordDialog(String email, String name) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Reset Password for $name'),
        content: Text('This will send a password reset email to $email. The user will be able to set their own new password safely.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final err = await _adminService.resetUserPassword(email);
              if (ctx.mounted) Navigator.pop(ctx);
              if (err != null) _snack(err, error: true);
              else _snack('Password reset email sent to $email');
            },
            child: const Text('Send Email'),
          ),
        ],
      ),
    );
  }

  // ── Edit Dialogs ──────────────────────────────────────────────────────────

  void _showEditAgencyDialog(Agency a) {
    final nameCtrl = TextEditingController(text: a.name);
    final phoneCtrl = TextEditingController(text: a.phone);
    final cityCtrl = TextEditingController(text: a.city);
    final descCtrl = TextEditingController(text: a.description);
    final logoCtrl = TextEditingController(text: a.logoUrl);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Agency'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _field('Agency Name', LucideIcons.building2, nameCtrl),
              const SizedBox(height: 16),
              _field('Phone Number', LucideIcons.phone, phoneCtrl),
              const SizedBox(height: 16),
              _field('City', LucideIcons.mapPin, cityCtrl),
              const SizedBox(height: 16),
              _field('Description', LucideIcons.fileText, descCtrl, maxLines: 3),
              const SizedBox(height: 16),
              _field('Logo URL', LucideIcons.image, logoCtrl),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final err = await _adminService.updateAgency(
                id: a.id,
                name: nameCtrl.text,
                phone: phoneCtrl.text,
                city: cityCtrl.text,
                description: descCtrl.text,
                logoUrl: logoCtrl.text,
              );
              if (ctx.mounted) Navigator.pop(ctx);
              if (err != null) _snack(err, error: true);
              else _snack('Agency updated.');
            },
            child: const Text('Save Changes'),
          ),
        ],
      ),
    );
  }

  void _showEditGangDialog(AgencyGang g, List<Agency> allAgencies) {
    final nameCtrl = TextEditingController(text: g.name);
    final feeCtrl = TextEditingController(text: g.fee.toString());
    final List<TextEditingController> linesCtrls = g.lines.isNotEmpty 
        ? g.lines.map((l) => TextEditingController(text: l)).toList() 
        : [TextEditingController()];
    Set<String> selectedIds = Set.from(g.agencyIds);
    
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Edit Gang'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _field('Gang Name', LucideIcons.tag, nameCtrl),
                const SizedBox(height: 16),
                _field('Fee (MRU)', LucideIcons.banknote, feeCtrl, keyboardType: TextInputType.number),
                const SizedBox(height: 16),
                const Text('Gang Lines', style: TextStyle(fontSize: 12, color: Colors.white60)),
                const SizedBox(height: 8),
                ...linesCtrls.asMap().entries.map((e) {
                  final idx = e.key;
                  final ctrl = e.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      children: [
                        Expanded(child: _field('Line Name', LucideIcons.gitBranch, ctrl)),
                        if (linesCtrls.length > 1)
                          IconButton(
                            icon: const Icon(LucideIcons.minusCircle, color: AppTheme.errorColor),
                            onPressed: () => setDialogState(() {
                              ctrl.dispose();
                              linesCtrls.removeAt(idx);
                            }),
                          ),
                      ],
                    ),
                  );
                }),
                TextButton.icon(
                  onPressed: () => setDialogState(() => linesCtrls.add(TextEditingController())),
                  icon: const Icon(LucideIcons.plusCircle, size: 16, color: AppTheme.primaryColor),
                  label: const Text('Add Another Line', style: TextStyle(color: AppTheme.primaryColor)),
                ),
                const SizedBox(height: 16),
                const Text('Agencies in this Gang:', style: TextStyle(fontSize: 12, color: Colors.white60)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 4, runSpacing: 4,
                  children: allAgencies.map((a) {
                    final isSelected = selectedIds.contains(a.id);
                    return FilterChip(
                      label: Text(a.name, style: const TextStyle(fontSize: 10)),
                      selected: isSelected,
                      onSelected: (on) => setDialogState(() {
                        if (on) selectedIds.add(a.id);
                        else selectedIds.remove(a.id);
                      }),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                final linesList = linesCtrls.map((c) => c.text.trim()).where((s) => s.isNotEmpty).toList();
                final err = await _adminService.updateGang(
                  id: g.id, 
                  name: nameCtrl.text, 
                  agencyIds: selectedIds.toList(), 
                  lines: linesList,
                  fee: double.tryParse(feeCtrl.text) ?? 0.0
                );
                if (ctx.mounted) Navigator.pop(ctx);
                if (err != null) _snack(err, error: true);
                else _snack('Gang updated.');
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditUserDialog(Map<String, dynamic> u, List<Agency> allAgencies, Stream<List<AgencyGang>> gangsStream) {
    final nameCtrl = TextEditingController(text: u['name'] ?? '');
    final emailCtrl = TextEditingController(text: u['email'] ?? '');
    UserRole selectedRole = UserRole.values.firstWhere((e) => e.name == u['role'], orElse: () => UserRole.agent);
    String? selectedAgency = u['agencyId'];
    String? selectedGang = u['gangId'];

    showDialog(
      context: context,
      builder: (ctx) => StreamBuilder<List<AgencyGang>>(
        stream: gangsStream,
        builder: (ctx, gangSnap) {
          final gangs = gangSnap.data ?? [];
          return StatefulBuilder(
            builder: (ctx, setDialogState) => AlertDialog(
              title: const Text('Edit User Profile'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _field('Full Name', LucideIcons.user, nameCtrl),
                    const SizedBox(height: 16),
                    _field('Email', LucideIcons.mail, emailCtrl),
                    const SizedBox(height: 16),
                    _dropdown<UserRole>(
                      label: 'Role',
                      icon: LucideIcons.shield,
                      value: selectedRole,
                      items: UserRole.values.where((r) => r != UserRole.admin).toList(),
                      itemLabel: (r) => r.name.toUpperCase(),
                      onChanged: (v) => setDialogState(() {
                        selectedRole = v!;
                        selectedAgency = null;
                        selectedGang = null;
                      }),
                    ),
                    const SizedBox(height: 16),
                    if (selectedRole == UserRole.owner)
                      _dropdown<String>(
                        label: 'Gang',
                        icon: LucideIcons.layers,
                        value: selectedGang,
                        items: gangs.map((g) => g.id).toList(),
                        itemLabel: (id) => gangs.firstWhere((g) => g.id == id).name,
                        onChanged: (v) => setDialogState(() => selectedGang = v),
                      )
                    else
                      _dropdown<String>(
                        label: 'Agency',
                        icon: LucideIcons.building2,
                        value: selectedAgency,
                        items: allAgencies.map((a) => a.id).toList(),
                        itemLabel: (id) => allAgencies.firstWhere((a) => a.id == id).name,
                        onChanged: (v) => setDialogState(() => selectedAgency = v),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                ElevatedButton(
                  onPressed: () async {
                    final err = await _adminService.updateUserProfile(
                      uid: u['uid'],
                      name: nameCtrl.text,
                      role: selectedRole.name,
                      agencyId: selectedRole == UserRole.owner ? null : selectedAgency,
                      gangId: selectedRole == UserRole.owner ? selectedGang : null,
                      email: emailCtrl.text,
                    );
                    if (ctx.mounted) Navigator.pop(ctx);
                    if (err != null) _snack(err, error: true);
                    else _snack('User profile updated.');
                  },
                  child: const Text('Save'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── Tab: Fees ─────────────────────────────────────────────────────────────

  Widget _buildFeesTab(List<Agency> allAgencies, List<AgencyGang> allGangs) {
    if (_feeGangId == null && _feeAgencyId == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(LucideIcons.search, size: 64, color: Colors.white10),
            const SizedBox(height: 16),
            const Text('Fees Report', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Please select a Gang or Agency to view the fee data.', style: TextStyle(color: Colors.white38)),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48),
              child: _dropdown<String?>(
                label: 'Start by Selecting a Gang',
                icon: LucideIcons.layers,
                value: _feeGangId,
                items: [null, ...allGangs.map((g) => g.id)],
                itemLabel: (id) => id == null ? 'Select Gang' : allGangs.firstWhere((g) => g.id == id).name,
                onChanged: (v) => setState(() => _feeGangId = v),
              ),
            ),
            const SizedBox(height: 16),
            const Text('OR', style: TextStyle(color: Colors.white10, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48),
              child: _dropdown<String?>(
                label: 'Select an Agency Directly',
                icon: LucideIcons.building2,
                value: _feeAgencyId,
                items: [null, ...allAgencies.map((a) => a.id)],
                itemLabel: (id) => id == null ? 'Select Agency' : allAgencies.firstWhere((a) => a.id == id).name,
                onChanged: (v) => setState(() => _feeAgencyId = v),
              ),
            ),
          ],
        ),
      );
    }

    return StreamBuilder<List<Parcel>>(
      stream: _adminService.allParcelsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        final parcels = snapshot.data ?? [];
        
        // Apply Filters
        final filtered = parcels.where((p) {
          final inDateRange = p.createdAt.isAfter(_feeDateFrom.subtract(const Duration(seconds: 1))) && 
                              p.createdAt.isBefore(_feeDateTo.add(const Duration(days: 1)));
          if (!inDateRange) return false;

          if (_feeAgencyId != null && p.originAgencyId != _feeAgencyId) return false;

          if (_feeGangId != null) {
            // Check if origin agency belongs to this gang
            final gang = allGangs.firstWhere((g) => g.id == _feeGangId, orElse: () => AgencyGang(id: '', name: '', agencyIds: [], fee: 0));
            if (!gang.agencyIds.contains(p.originAgencyId)) return false;
          }

          return true;
        }).toList();

        double total = 0;
        Map<String, double> agencyFees = {}; // agencyId -> totalFee

        for (var p in filtered) {
          total += p.amount;
          agencyFees[p.originAgencyId] = (agencyFees[p.originAgencyId] ?? 0) + p.amount;
        }

        return Column(
          children: [
            // Filters Header
            Container(
              padding: const EdgeInsets.all(16),
              color: AppTheme.surfaceColor,
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _dropdown<String?>(
                          label: 'Filter by Gang',
                          icon: LucideIcons.layers,
                          value: _feeGangId,
                          items: [null, ...allGangs.map((g) => g.id)],
                          itemLabel: (id) => id == null ? 'All Gangs' : allGangs.firstWhere((g) => g.id == id).name,
                          onChanged: (v) => setState(() => _feeGangId = v),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _dropdown<String?>(
                          label: 'Filter by Agency',
                          icon: LucideIcons.building2,
                          value: _feeAgencyId,
                          items: [null, ...allAgencies.map((a) => a.id)],
                          itemLabel: (id) => id == null ? 'All Agencies' : allAgencies.firstWhere((a) => a.id == id).name,
                          onChanged: (v) => setState(() => _feeAgencyId = v),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: _feeDateFrom,
                              firstDate: DateTime(2024),
                              lastDate: DateTime.now(),
                            );
                            if (picked != null) setState(() => _feeDateFrom = picked);
                          },
                          icon: const Icon(LucideIcons.calendar, size: 16),
                          label: Text('From: ${_feeDateFrom.day}/${_feeDateFrom.month}/${_feeDateFrom.year}'),
                          style: OutlinedButton.styleFrom(foregroundColor: Colors.white70),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: _feeDateTo,
                              firstDate: DateTime(2024),
                              lastDate: DateTime.now(),
                            );
                            if (picked != null) setState(() => _feeDateTo = picked);
                          },
                          icon: const Icon(LucideIcons.calendar, size: 16),
                          label: Text('Until: ${_feeDateTo.day}/${_feeDateTo.month}/${_feeDateTo.year}'),
                          style: OutlinedButton.styleFrom(foregroundColor: Colors.white70),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Summary Card
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [AppTheme.primaryColor, Color(0xFF6366F1)]),
                borderRadius: AppConstants.borderRadiusLg,
                boxShadow: [BoxShadow(color: AppTheme.primaryColor.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Column(
                children: [
                  const Text('TOTAL FEES COLLECTED', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
                  const SizedBox(height: 8),
                  Text('${total.toStringAsFixed(0)} MRU', style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 4),
                  Text('${filtered.length} Parcels Processed', style: const TextStyle(color: Colors.white60, fontSize: 12)),
                ],
              ),
            ),

            // Breakdown List
            Expanded(
              child: agencyFees.isEmpty
                  ? const Center(child: Text('No data for this period.', style: TextStyle(color: Colors.white38)))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: agencyFees.length,
                      itemBuilder: (ctx, i) {
                        final agencyId = agencyFees.keys.elementAt(i);
                        final fee = agencyFees[agencyId]!;
                        final agency = allAgencies.firstWhere((a) => a.id == agencyId, orElse: () => Agency(id: '', name: 'Deleted Agency', phone: ''));
                        
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceColor,
                            borderRadius: AppConstants.borderRadiusMd,
                            border: Border.all(color: Colors.white.withOpacity(0.05)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(agency.name, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                                  Text('${(fee / total * 100).toStringAsFixed(1)}% of total', style: const TextStyle(color: Colors.white38, fontSize: 10)),
                                ],
                              ),
                              Text('${fee.toStringAsFixed(0)} MRU', style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
  // ── Tab: Settings ─────────────────────────────────────────────────────────
  
  Widget _buildSettingsTab() {
    return StreamBuilder<SystemSettings>(
      stream: _settingsService.settingsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        final settings = snapshot.data ?? SystemSettings.defaultSettings();
        
        final appNameCtrl = TextEditingController(text: settings.appName);
        final feeCtrl = TextEditingController(text: settings.defaultFee.toStringAsFixed(0));
        final contactCtrl = TextEditingController(text: settings.supportContact);
        bool maintenance = settings.maintenanceMode;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.horizontalPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('System Settings', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              const Text('Manage global application configuration and sensitive defaults.', style: TextStyle(color: Colors.white60)),
              const SizedBox(height: 32),
              
              _card(
                icon: LucideIcons.settings2,
                title: 'Global Configuration',
                child: Column(
                  children: [
                    _field('App Display Name', LucideIcons.info, appNameCtrl),
                    const SizedBox(height: 16),
                    _field('Default Shipment Fee (MRU)', LucideIcons.banknote, feeCtrl, keyboardType: TextInputType.number),
                    const SizedBox(height: 16),
                    _field('Support Contact Info', LucideIcons.helpCircle, contactCtrl),
                    const SizedBox(height: 24),
                    StatefulBuilder(
                      builder: (context, setInnerState) => SwitchListTile(
                        title: const Text('Maintenance Mode', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        subtitle: const Text('Block all non-admin access to the app', style: TextStyle(color: Colors.white38, fontSize: 12)),
                        value: maintenance,
                        activeColor: AppTheme.primaryColor,
                        onChanged: (v) => setInnerState(() => maintenance = v),
                      ),
                    ),
                    const SizedBox(height: 32),
                    _btn('Save Global Settings', false, () async {
                      final newSettings = SystemSettings(
                        appName: appNameCtrl.text.trim(),
                        defaultFee: double.tryParse(feeCtrl.text) ?? 100.0,
                        supportContact: contactCtrl.text.trim(),
                        maintenanceMode: maintenance,
                      );
                      final err = await _settingsService.updateSettings(newSettings);
                      if (err != null) _snack(err, error: true);
                      else _snack('Settings updated successfully!');
                    }),
                  ],
                ),
              ),
              
              const SizedBox(height: 40),
              const Center(
                child: Text('Note: These settings are sensitive and affect all agencies and users.', 
                  style: TextStyle(color: Colors.white24, fontSize: 12, fontStyle: FontStyle.italic)),
              ),
            ],
          ),
        );
      },
    );
  }
}
