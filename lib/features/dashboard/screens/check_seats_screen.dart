import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:pick_pack/core/app_constants.dart';
import 'package:pick_pack/core/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:pick_pack/features/auth/services/auth_service.dart';
import 'package:pick_pack/l10n/app_localizations.dart';

class CheckSeatsScreen extends StatefulWidget {
  const CheckSeatsScreen({super.key});

  @override
  State<CheckSeatsScreen> createState() => _CheckSeatsScreenState();
}

class _CheckSeatsScreenState extends State<CheckSeatsScreen> {
  String? _expandedBusId;
  bool _showLineSeats = true;
  String? _fromCity;
  String? _toCity;
  String? _myAgencyId;
  String? _myGangLine;
  Map<String, String> _agencyToCity = {};
  Set<String> _lineAgencyIds = {};
  List<String> _availableFromCities = [];
  List<String> _availableToCities = [];
  bool _isInit = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final user = context.read<AuthService>().currentUser;
    if (user == null) return;
    _myAgencyId = user.agencyId;
    final myAgencyDoc = await FirebaseFirestore.instance.collection('agencies').doc(_myAgencyId).get();
    if (myAgencyDoc.exists) _myGangLine = myAgencyDoc.data()?['gangLine'];
    final agenciesSnap = await FirebaseFirestore.instance.collection('agencies').get();
    final Map<String, String> cityMap = {};
    final Set<String> lineCities = {};
    final Set<String> lineAgencyIds = {_myAgencyId!};
    for (var doc in agenciesSnap.docs) {
      final data = doc.data();
      final city = data['city'] as String?;
      final gangLine = data['gangLine'] as String?;
      if (city != null && city.isNotEmpty) {
        cityMap[doc.id] = city;
        if (gangLine == _myGangLine && _myGangLine != null) {
          lineCities.add(city);
          lineAgencyIds.add(doc.id);
        }
      }
    }
    if (mounted) {
      setState(() {
        _agencyToCity = cityMap;
        _lineAgencyIds = lineAgencyIds;
        final allCities = cityMap.values.toSet().toList()..sort();
        final filteredCities = lineCities.isNotEmpty ? (lineCities.toList()..sort()) : allCities;
        _availableFromCities = filteredCities;
        _availableToCities = allCities;
        _isInit = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (!_isInit) return const Center(child: CircularProgressIndicator());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(AppConstants.horizontalPadding, AppConstants.horizontalPadding, AppConstants.horizontalPadding, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.checkSeatsTitle, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(l10n.browseSeats, style: const TextStyle(color: Colors.white54, fontSize: 13)),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.03),
                  borderRadius: AppConstants.borderRadiusMd,
                  border: Border.all(color: Colors.white.withOpacity(0.06)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(LucideIcons.network, size: 16, color: _showLineSeats ? AppTheme.primaryColor : Colors.white30),
                            const SizedBox(width: 8),
                            Text(l10n.showAllLineAgencies, style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500)),
                          ],
                        ),
                        Switch.adaptive(value: _showLineSeats, onChanged: (v) => setState(() => _showLineSeats = v), activeColor: AppTheme.primaryColor),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Divider(color: Colors.white10, height: 1),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(l10n.fromCity, style: const TextStyle(color: Colors.white38, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1)),
                              const SizedBox(height: 6),
                              _buildCityDropdown(value: _fromCity, hint: l10n.selectCity, cities: _availableFromCities, icon: LucideIcons.mapPin, onChanged: (v) => setState(() => _fromCity = v)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(l10n.toCityLabel, style: const TextStyle(color: Colors.white38, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1)),
                              const SizedBox(height: 6),
                              _buildCityDropdown(value: _toCity, hint: l10n.selectCity, cities: _availableToCities, icon: LucideIcons.navigation, onChanged: (v) => setState(() => _toCity = v)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('buses').where('status', isEqualTo: 'active').snapshots(),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
              if (snap.hasError) return Center(child: Text('Error: ${snap.error}', style: const TextStyle(color: Colors.red)));
              final bool isSearching = _fromCity != null || _toCity != null;
              final buses = (snap.data?.docs ?? []).where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final agencyIdOfBus = data['agencyId'] as String?;
                if (!isSearching && !_showLineSeats) return false;
                if (_showLineSeats || isSearching) {
                  if (agencyIdOfBus == null || !_lineAgencyIds.contains(agencyIdOfBus)) return false;
                } else {
                  if (agencyIdOfBus != _myAgencyId) return false;
                }
                if (_fromCity != null && (agencyIdOfBus == null || _agencyToCity[agencyIdOfBus] != _fromCity)) return false;
                if (_toCity != null && (data['destinationCity'] ?? '').toString() != _toCity) return false;
                return true;
              }).toList();
              buses.sort((a, b) {
                final aDate = (a.data() as Map)['departureAt'] as Timestamp?;
                final bDate = (b.data() as Map)['departureAt'] as Timestamp?;
                if (aDate == null) return 1;
                if (bDate == null) return -1;
                return aDate.compareTo(bDate);
              });
              if (buses.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(LucideIcons.bus, size: 64, color: Colors.white.withOpacity(0.1)),
                      const SizedBox(height: 16),
                      Text(isSearching ? l10n.noRouteBusesFound : l10n.selectCityToSeeResults, style: const TextStyle(color: Colors.white30, fontSize: 14), textAlign: TextAlign.center),
                    ],
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: AppConstants.horizontalPadding),
                itemCount: buses.length,
                itemBuilder: (context, i) {
                  final doc = buses[i];
                  final data = doc.data() as Map<String, dynamic>;
                  final id = doc.id;
                  final expanded = _expandedBusId == id;
                  return _BusSeatsCard(busId: id, busData: data, isExpanded: expanded, departureCity: _agencyToCity[data['agencyId']] ?? 'Unknown', onToggle: () => setState(() => _expandedBusId = expanded ? null : id));
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCityDropdown({required String? value, required String hint, required List<String> cities, required IconData icon, required ValueChanged<String?> onChanged}) {
    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.white.withOpacity(0.1))),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(hint, style: const TextStyle(color: Colors.white24, fontSize: 13)),
          dropdownColor: const Color(0xFF1E293B),
          icon: const Icon(LucideIcons.chevronDown, size: 14, color: Colors.white30),
          isExpanded: true,
          style: const TextStyle(color: Colors.white, fontSize: 13),
          items: cities.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _BusSeatsCard extends StatelessWidget {
  final String busId;
  final Map<String, dynamic> busData;
  final bool isExpanded;
  final String departureCity;
  final VoidCallback onToggle;
  const _BusSeatsCard({required this.busId, required this.busData, required this.isExpanded, required this.departureCity, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final dep = (busData['departureAt'] as Timestamp?)?.toDate();
    final depStr = dep != null ? '${dep.day.toString().padLeft(2, '0')}/${dep.month.toString().padLeft(2, '0')}/${dep.year}  ${dep.hour.toString().padLeft(2, '0')}:${dep.minute.toString().padLeft(2, '0')}' : 'Unknown';
    final totalSeats = (busData['seats'] ?? 0) as int;
    final destCity = busData['destinationCity'] ?? 'Unknown';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: AppTheme.surfaceColor, borderRadius: AppConstants.borderRadiusMd, border: Border.all(color: isExpanded ? AppTheme.primaryColor.withOpacity(0.4) : Colors.white.withOpacity(0.06))),
      child: Column(
        children: [
          InkWell(
            onTap: onToggle,
            borderRadius: AppConstants.borderRadiusMd,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: AppTheme.primaryColor.withOpacity(0.12), shape: BoxShape.circle), child: const Icon(LucideIcons.bus, color: AppTheme.primaryColor, size: 20)),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Text(departureCity, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(width: 8),
                          Icon(LucideIcons.arrowRight, size: 14, color: AppTheme.primaryColor.withOpacity(0.5)),
                          const SizedBox(width: 8),
                          Text(destCity, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                        ]),
                        const SizedBox(height: 4),
                        Row(children: [const Icon(LucideIcons.calendar, size: 11, color: Colors.white38), const SizedBox(width: 4), Text(depStr, style: const TextStyle(color: Colors.white54, fontSize: 12))]),
                      ],
                    ),
                  ),
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('tickets').where('busId', isEqualTo: busId).where('status', isEqualTo: 'confirmed').snapshots(),
                    builder: (context, snap) {
                      final booked = snap.data?.docs.length ?? 0;
                      final available = totalSeats - booked;
                      final pct = totalSeats > 0 ? booked / totalSeats : 0.0;
                      return Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                        Text('$available ${l10n.free}', style: TextStyle(color: available > 0 ? Colors.greenAccent : Colors.redAccent, fontSize: 13, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        SizedBox(width: 60, child: ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: pct, backgroundColor: Colors.white12, color: pct > 0.8 ? Colors.redAccent : pct > 0.5 ? Colors.orangeAccent : Colors.greenAccent, minHeight: 5))),
                        const SizedBox(height: 4),
                        Text('$booked/$totalSeats ${l10n.bookedOf}', style: const TextStyle(color: Colors.white38, fontSize: 10)),
                      ]);
                    },
                  ),
                  const SizedBox(width: 8),
                  AnimatedRotation(turns: isExpanded ? 0.5 : 0, duration: const Duration(milliseconds: 200), child: const Icon(LucideIcons.chevronDown, color: Colors.white38, size: 18)),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 250),
            crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            firstChild: const SizedBox.shrink(),
            secondChild: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('tickets').where('busId', isEqualTo: busId).where('status', isEqualTo: 'confirmed').snapshots(),
              builder: (context, snap) {
                final l10n = AppLocalizations.of(context)!;
                final bookedSeats = (snap.data?.docs ?? []).map((d) => (d.data() as Map)['seatNumber'] as int?).whereType<int>().toSet();
                return Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Divider(color: Colors.white10),
                    const SizedBox(height: 8),
                    Row(children: [_LegendDot(color: Colors.green.shade400, label: l10n.available), const SizedBox(width: 16), _LegendDot(color: Colors.red.shade400, label: l10n.booked)]),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: AppTheme.primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2))),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [const Icon(LucideIcons.bus, size: 14, color: AppTheme.primaryColor), const SizedBox(width: 6), Text(l10n.driver, style: const TextStyle(color: AppTheme.primaryColor, fontSize: 11, fontWeight: FontWeight.bold))]),
                    ),
                    const SizedBox(height: 12),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, crossAxisSpacing: 8, mainAxisSpacing: 8, childAspectRatio: 1.2),
                      itemCount: totalSeats,
                      itemBuilder: (context, idx) {
                        final seatNum = idx + 1;
                        final isBooked = bookedSeats.contains(seatNum);
                        return Tooltip(
                          message: isBooked ? l10n.seatBooked(seatNum) : l10n.seatAvailable(seatNum),
                          child: Container(
                            decoration: BoxDecoration(color: isBooked ? Colors.red.withOpacity(0.15) : Colors.green.withOpacity(0.12), borderRadius: BorderRadius.circular(8), border: Border.all(color: isBooked ? Colors.red.withOpacity(0.5) : Colors.green.withOpacity(0.5))),
                            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                              Icon(LucideIcons.armchair, size: 16, color: isBooked ? Colors.red.shade300 : Colors.green.shade400),
                              const SizedBox(height: 2),
                              Text('$seatNum', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isBooked ? Colors.red.shade300 : Colors.green.shade400)),
                            ]),
                          ),
                        );
                      },
                    ),
                  ]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 5),
      Text(label, style: const TextStyle(color: Colors.white54, fontSize: 11)),
    ]);
  }
}
