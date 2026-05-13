import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:pick_pack/core/app_constants.dart';
import 'package:pick_pack/core/app_theme.dart';
import 'package:pick_pack/features/auth/services/auth_service.dart';
import 'package:pick_pack/l10n/app_localizations.dart';

class BusesScreen extends StatefulWidget {
  const BusesScreen({super.key});

  @override
  State<BusesScreen> createState() => _BusesScreenState();
}

class _BusesScreenState extends State<BusesScreen> {
  bool _showForm = false;

  final _formKey = GlobalKey<FormState>();
  final _busNameController = TextEditingController();
  final _seatsController = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _departureTime;
  bool _isSaving = false;

  List<QueryDocumentSnapshot> _agencies = [];
  String? _selectedDestinationAgencyId;
  String? _selectedDestinationCity;

  @override
  void initState() {
    super.initState();
    _fetchAgencies();
  }

  Future<void> _fetchAgencies() async {
    final snap = await FirebaseFirestore.instance.collection('agencies').get();
    if (mounted) {
      setState(() {
        _agencies = snap.docs;
      });
    }
  }

  @override
  void dispose() {
    _busNameController.dispose();
    _seatsController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppTheme.primaryColor,
            surface: Color(0xFF1E293B),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppTheme.primaryColor,
            surface: Color(0xFF1E293B),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _departureTime = picked);
  }

  Future<void> _saveBus(AppLocalizations l10n) async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null) {
      _showSnack(l10n.pleaseSelectDepartureDate);
      return;
    }
    if (_departureTime == null) {
      _showSnack(l10n.pleaseSelectDepartureTime);
      return;
    }

    setState(() => _isSaving = true);
    try {
      final user = context.read<AuthService>().currentUser!;
      final departureDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _departureTime!.hour,
        _departureTime!.minute,
      );

      await FirebaseFirestore.instance.collection('buses').add({
        'busName': _busNameController.text.trim(),
        'seats': int.parse(_seatsController.text.trim()),
        'departureAt': Timestamp.fromDate(departureDateTime),
        'agencyId': user.agencyId,
        'destinationAgencyId': _selectedDestinationAgencyId,
        'destinationCity': _selectedDestinationCity ?? '',
        'createdBy': user.uid,
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'active',
      });

      _showSnack(l10n.busAddedSuccessfully, isSuccess: true);
      _busNameController.clear();
      _seatsController.clear();
      setState(() {
        _selectedDate = null;
        _departureTime = null;
        _selectedDestinationAgencyId = null;
        _selectedDestinationCity = null;
        _showForm = false;
      });
    } catch (e) {
      _showSnack(l10n.errorSavingBus(e.toString()));
    } finally {
      setState(() => _isSaving = false);
    }
  }

  void _showSnack(String msg, {bool isSuccess = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isSuccess ? Colors.green : AppTheme.errorColor,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final user = context.read<AuthService>().currentUser!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.horizontalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ────────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.busesTitle, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(l10n.manageBuses, style: const TextStyle(color: Colors.white54, fontSize: 13)),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => setState(() => _showForm = !_showForm),
                icon: Icon(_showForm ? LucideIcons.x : LucideIcons.plusCircle, size: 18),
                label: Text(_showForm ? l10n.cancel : l10n.addBus),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _showForm ? Colors.red.withOpacity(0.7) : AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ── Add Bus Form ──────────────────────────────────────────
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: _showForm ? _buildForm(l10n) : const SizedBox.shrink(),
          ),

          // ── Bus List ─────────────────────────────────────────────
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('buses')
                .where('agencyId', isEqualTo: user.agencyId)
                .snapshots(),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snap.hasError) {
                return Center(child: Text('Error: ${snap.error}', style: const TextStyle(color: Colors.red)));
              }

              final buses = snap.data?.docs.toList() ?? [];
              buses.sort((a, b) {
                final aData = a.data() as Map<String, dynamic>;
                final bData = b.data() as Map<String, dynamic>;
                final aDate = aData['departureAt'] as Timestamp?;
                final bDate = bData['departureAt'] as Timestamp?;
                if (aDate == null) return 1;
                if (bDate == null) return -1;
                return aDate.compareTo(bDate);
              });

              if (buses.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 60),
                    child: Column(
                      children: [
                        Icon(LucideIcons.bus, size: 64, color: Colors.white.withOpacity(0.1)),
                        const SizedBox(height: 16),
                        Text(l10n.noBusesYet, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white30, fontSize: 14)),
                      ],
                    ),
                  ),
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${buses.length} bus${buses.length == 1 ? '' : 'es'} scheduled', style: const TextStyle(color: Colors.white60, fontSize: 13)),
                  const SizedBox(height: 12),
                  ...buses.map((doc) => _buildBusCard(doc, l10n)),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildForm(AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.only(bottom: 28),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: AppConstants.borderRadiusLg,
        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.25)),
        boxShadow: [BoxShadow(color: AppTheme.primaryColor.withOpacity(0.08), blurRadius: 20)],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.newBus, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),

            // Bus Name
            TextFormField(
              controller: _busNameController,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration(l10n.busName, LucideIcons.bus),
              validator: (v) => (v == null || v.trim().isEmpty) ? l10n.enterBusName : null,
            ),
            const SizedBox(height: 16),

            // Destination Agency
            DropdownButtonFormField<String>(
              value: _selectedDestinationAgencyId,
              dropdownColor: AppTheme.surfaceColor,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration(l10n.destinationAgencyLabel, LucideIcons.mapPin),
              items: _agencies.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return DropdownMenuItem(
                  value: doc.id,
                  child: Text('${data['name']} (${data['city'] ?? 'No City'})'),
                );
              }).toList(),
              onChanged: (val) {
                setState(() {
                  _selectedDestinationAgencyId = val;
                  if (val != null) {
                    final selectedAgency = _agencies.firstWhere((doc) => doc.id == val);
                    final data = selectedAgency.data() as Map<String, dynamic>;
                    _selectedDestinationCity = data['city'];
                  }
                });
              },
              validator: (v) => v == null ? l10n.selectDestination : null,
            ),
            const SizedBox(height: 16),

            // Departure Date + Time
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: _pickDate,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: AppConstants.borderRadiusMd,
                        border: Border.all(color: Colors.white.withOpacity(0.1)),
                      ),
                      child: Row(
                        children: [
                          const Icon(LucideIcons.calendar, color: Colors.white54, size: 18),
                          const SizedBox(width: 10),
                          Text(
                            _selectedDate != null
                                ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                                : l10n.selectDate,
                            style: TextStyle(color: _selectedDate != null ? Colors.white : Colors.white38),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: _pickTime,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: AppConstants.borderRadiusMd,
                        border: Border.all(color: Colors.white.withOpacity(0.1)),
                      ),
                      child: Row(
                        children: [
                          const Icon(LucideIcons.clock, color: Colors.white54, size: 18),
                          const SizedBox(width: 10),
                          Text(
                            _departureTime != null
                                ? _departureTime!.format(context)
                                : l10n.departureTime,
                            style: TextStyle(color: _departureTime != null ? Colors.white : Colors.white38),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Seats
            TextFormField(
              controller: _seatsController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration(l10n.numberOfSeats, LucideIcons.armchair),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return l10n.enterSeatCount;
                if (int.tryParse(v.trim()) == null) return l10n.mustBeWholeNumber;
                if (int.parse(v.trim()) <= 0) return l10n.mustBeGreaterThanZero;
                return null;
              },
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isSaving ? null : () => _saveBus(l10n),
                icon: _isSaving
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(LucideIcons.save, size: 18),
                label: Text(_isSaving ? l10n.saving : l10n.saveBus),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBusCard(QueryDocumentSnapshot doc, AppLocalizations l10n) {
    final data = doc.data() as Map<String, dynamic>;
    final dep = (data['departureAt'] as Timestamp?)?.toDate();
    final depStr = dep != null
        ? '${dep.day.toString().padLeft(2, '0')}/${dep.month.toString().padLeft(2, '0')}/${dep.year}  ${dep.hour.toString().padLeft(2, '0')}:${dep.minute.toString().padLeft(2, '0')}'
        : 'Unknown';
    final seats = data['seats']?.toString() ?? '?';
    final name = data['busName'] ?? 'Unnamed Bus';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: AppConstants.borderRadiusMd,
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(LucideIcons.bus, color: AppTheme.primaryColor, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(LucideIcons.mapPin, size: 12, color: Colors.white38),
                    const SizedBox(width: 4),
                    Text('${l10n.toCity} ${data['destinationCity'] ?? 'Unknown'}', style: const TextStyle(color: Colors.white54, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(LucideIcons.calendar, size: 12, color: Colors.white38),
                    const SizedBox(width: 4),
                    Text(depStr, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  const Icon(LucideIcons.armchair, size: 14, color: Colors.white54),
                  const SizedBox(width: 4),
                  Text('$seats ${l10n.seatsLabel}', style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(l10n.active, style: const TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white54),
      prefixIcon: Icon(icon, color: Colors.white38, size: 18),
      filled: true,
      fillColor: Colors.white.withOpacity(0.05),
      enabledBorder: OutlineInputBorder(
        borderRadius: AppConstants.borderRadiusMd,
        borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: AppConstants.borderRadiusMd,
        borderSide: const BorderSide(color: AppTheme.primaryColor),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: AppConstants.borderRadiusMd,
        borderSide: const BorderSide(color: AppTheme.errorColor),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: AppConstants.borderRadiusMd,
        borderSide: const BorderSide(color: AppTheme.errorColor),
      ),
    );
  }
}
