import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pick_pack/core/app_constants.dart';
import 'package:pick_pack/core/app_theme.dart';
import 'package:pick_pack/features/auth/services/auth_service.dart';
import 'package:pick_pack/features/parcels/screens/create_parcel_screen.dart';
import 'package:pick_pack/features/parcels/services/parcel_service.dart';
import 'package:pick_pack/l10n/app_localizations.dart';

class AgentDashboard extends StatelessWidget {
  const AgentDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthService>().currentUser!;
    final l10n = AppLocalizations.of(context)!;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Action Cards Row
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppConstants.horizontalPadding,
                  AppConstants.horizontalPadding,
                  AppConstants.horizontalPadding,
                  0,
                ),
                child: Row(
                  children: [
                    // ── Send Parcel Card ──
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const CreateParcelScreen()),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFF6366F1), Color(0xFF4338CA)],
                            ),
                            borderRadius: AppConstants.borderRadiusLg,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF6366F1).withOpacity(0.35),
                                blurRadius: 18,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(LucideIcons.send, color: Colors.white, size: 22),
                              ),
                              const SizedBox(height: 14),
                              Text(
                                l10n.sendParcel,
                                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                l10n.registerNewShipment,
                                style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12),
                              ),
                              const SizedBox(height: 14),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(l10n.start, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                                    const SizedBox(width: 4),
                                    const Icon(LucideIcons.arrowRight, color: Colors.white, size: 12),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    // ── Book Ticket Card ──
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _showBookTicketSheet(context),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFF0EA5E9), Color(0xFF0369A1)],
                            ),
                            borderRadius: AppConstants.borderRadiusLg,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF0EA5E9).withOpacity(0.35),
                                blurRadius: 18,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(LucideIcons.ticket, color: Colors.white, size: 22),
                              ),
                              const SizedBox(height: 14),
                              Text(
                                l10n.bookTicket,
                                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                l10n.reserveBusSeat,
                                style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12),
                              ),
                              const SizedBox(height: 14),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(l10n.book, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                                    const SizedBox(width: 4),
                                    const Icon(LucideIcons.arrowRight, color: Colors.white, size: 12),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Recent Parcels Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppConstants.horizontalPadding),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.recentParcels,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: Text(l10n.viewAll, style: const TextStyle(color: AppTheme.primaryColor)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('parcels')
              .where(
                Filter.or(
                  Filter('originAgencyId', isEqualTo: user.agencyId),
                  Filter('destinationAgencyId', isEqualTo: user.agencyId),
                ),
              )
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SliverFillRemaining(child: Center(child: CircularProgressIndicator()));
            }
            if (snapshot.hasError) {
              return SliverFillRemaining(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'Error: ${snapshot.error}',
                      style: const TextStyle(color: AppTheme.errorColor),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              );
            }
            final todayStr = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day).toIso8601String();
            
            final allDocs = snapshot.data?.docs ?? [];
            final parcels = allDocs.where((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final createdAt = data['createdAt'];
              if (createdAt == null) return false;
              
              String? dateStr;
              if (createdAt is String) {
                dateStr = createdAt;
              } else if (createdAt is Timestamp) {
                dateStr = createdAt.toDate().toIso8601String();
              }
              
              return dateStr != null && dateStr.compareTo(todayStr) >= 0;
            }).toList();

            if (parcels.isEmpty) {
              return SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(LucideIcons.packageOpen,
                          size: 64, color: Colors.white.withOpacity(0.2)),
                      const SizedBox(height: 16),
                      Text(l10n.noParcelsToday,
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.4),
                              fontSize: 16)),
                    ],
                  ),
                ),
              );
            }
            parcels.sort((a, b) {
              final aData = a.data() as Map<String, dynamic>;
              final bData = b.data() as Map<String, dynamic>;
              
              DateTime? aDate;
              try {
                if (aData['createdAt'] != null) {
                  aDate = (aData['createdAt'] as dynamic).toDate();
                }
              } catch (_) {
                if (aData['createdAt'] is String) {
                  aDate = DateTime.tryParse(aData['createdAt']);
                }
              }
              
              DateTime? bDate;
              try {
                if (bData['createdAt'] != null) {
                  bDate = (bData['createdAt'] as dynamic).toDate();
                }
              } catch (_) {
                if (bData['createdAt'] is String) {
                  bDate = DateTime.tryParse(bData['createdAt']);
                }
              }

              if (aDate == null || bDate == null) return 0;
              return bDate.compareTo(aDate);
            });

            return SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppConstants.horizontalPadding,
                10,
                AppConstants.horizontalPadding,
                80, // Padding for bottom nav
              ),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final data = parcels[index].data() as Map<String, dynamic>;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _ParcelTile(
                        data: data,
                        currentAgencyId: user.agencyId ?? '',
                      ),
                    );
                  },
                  childCount: parcels.length,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  void _showBookTicketSheet(BuildContext context) {
    final user = context.read<AuthService>().currentUser!;
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        builder: (_, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Color(0xFF0F172A),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Handle
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 16),
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    const Icon(LucideIcons.bus, color: Color(0xFF0EA5E9), size: 22),
                    const SizedBox(width: 10),
                    Text(l10n.availableBuses, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(l10n.selectBusToBook, style: const TextStyle(color: Colors.white54, fontSize: 13)),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('buses')
                      .where('agencyId', isEqualTo: user.agencyId)
                      .where('status', isEqualTo: 'active')
                      .snapshots(),
                  builder: (context, snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final buses = snap.data?.docs ?? [];
                    if (buses.isEmpty) {
                      return Center(
                        child: Text(l10n.noBusesAvailable, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white38)),
                      );
                    }
                    return ListView.separated(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: buses.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, i) {
                        final data = buses[i].data() as Map<String, dynamic>;
                        final dep = (data['departureAt'] as Timestamp?)?.toDate();
                        final depStr = dep != null
                            ? '${dep.day.toString().padLeft(2,'0')}/${dep.month.toString().padLeft(2,'0')}/${dep.year}  ${dep.hour.toString().padLeft(2,'0')}:${dep.minute.toString().padLeft(2,'0')}'
                            : 'Unknown';
                        final seats = data['seats']?.toString() ?? '?';
                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E293B),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.white.withOpacity(0.06)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0EA5E9).withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(LucideIcons.bus, color: Color(0xFF0EA5E9), size: 20),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(data['busName'] ?? 'Bus', style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 4),
                                    Row(children: [
                                      const Icon(LucideIcons.mapPin, size: 12, color: Colors.white38),
                                      const SizedBox(width: 4),
                                      Text('${l10n.toDestination} ${data['destinationCity'] ?? 'Unknown'}', style: const TextStyle(color: Colors.white54, fontSize: 12)),
                                    ]),
                                    const SizedBox(height: 4),
                                    Row(children: [
                                      const Icon(LucideIcons.calendar, size: 12, color: Colors.white38),
                                      const SizedBox(width: 4),
                                      Text(depStr, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                                    ]),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Row(children: [
                                    const Icon(LucideIcons.armchair, size: 13, color: Colors.white38),
                                    const SizedBox(width: 4),
                                    Text('$seats', style: const TextStyle(color: Colors.white60, fontSize: 12)),
                                  ]),
                                  const SizedBox(height: 8),
                                  ElevatedButton(
                                    onPressed: () {
                                      _showPassengerForm(context, buses[i].id, data);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF0EA5E9),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                      minimumSize: const Size(0, 32),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                    child: Text(l10n.book, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _showPassengerForm(BuildContext outerContext, String busId, Map<String, dynamic> busData) {
    final l10n = AppLocalizations.of(outerContext)!;
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final priceController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    int? selectedSeat;
    bool isSaving = false;
    bool showDetails = false;

    final dep = (busData['departureAt'] as Timestamp?)?.toDate();
    final depStr = dep != null
        ? '${dep.day.toString().padLeft(2,'0')}/${dep.month.toString().padLeft(2,'0')}/${dep.year}  ${dep.hour.toString().padLeft(2,'0')}:${dep.minute.toString().padLeft(2,'0')}'
        : 'Unknown';

    showModalBottomSheet(
      context: outerContext,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            decoration: const BoxDecoration(
              color: Color(0xFF0F172A),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(ctx).size.height * 0.9,
            ),
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handle
                    Center(
                      child: Container(
                        width: 40, height: 4,
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
                      ),
                    ),
  
                    // Bus summary
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0EA5E9).withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF0EA5E9).withOpacity(0.2)),
                      ),
                      child: Row(
                        children: [
                          const Icon(LucideIcons.bus, color: Color(0xFF0EA5E9), size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(busData['busName'] ?? 'Bus', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                                Text(depStr, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                              ],
                            ),
                          ),
                          Text('${busData['totalSeats'] ?? 40} Seats', style: const TextStyle(color: Colors.white54, fontSize: 12)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
  
                    if (!showDetails) ...[
                      Text(l10n.selectSeat, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Row(children: [
                        _seatLegend(Colors.green.shade400, l10n.available),
                        const SizedBox(width: 14),
                        _seatLegend(Colors.red.shade400, l10n.booked),
                        const SizedBox(width: 14),
                        _seatLegend(const Color(0xFF0EA5E9), l10n.selected),
                      ]),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.03),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white.withOpacity(0.05)),
                        ),
                        child: StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('tickets')
                              .where('busId', isEqualTo: busId)
                              .where('status', isEqualTo: 'confirmed')
                              .snapshots(),
                          builder: (context, snap) {
                            if (!snap.hasData) return const Center(child: CircularProgressIndicator());
                            final bookedSeats = snap.data!.docs
                                .map((doc) => (doc.data() as Map<String, dynamic>)['seatNumber'] as int?)
                                .whereType<int>()
                                .toSet();
                            int totalSeats = 0;
                            if (busData['seats'] is int) {
                              totalSeats = busData['seats'];
                            } else if (busData['seats'] is String) {
                              totalSeats = int.tryParse(busData['seats']) ?? 0;
                            }
                            if (totalSeats == 0) {
                              return const Center(child: Text('No seats defined', style: TextStyle(color: Colors.white38)));
                            }
                            final isFullyBooked = bookedSeats.length >= totalSeats;
                            if (isFullyBooked && selectedSeat != null) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                setModalState(() => selectedSeat = null);
                              });
                            }
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Center(
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF0EA5E9).withOpacity(0.08),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: const Color(0xFF0EA5E9).withOpacity(0.25)),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(LucideIcons.user, size: 14, color: Color(0xFF0EA5E9)),
                                        const SizedBox(width: 6),
                                        Text(l10n.driver, style: const TextStyle(color: Color(0xFF0EA5E9), fontSize: 11, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  ),
                                ),
                                if (isFullyBooked)
                                  Container(
                                    width: double.infinity,
                                    margin: const EdgeInsets.only(bottom: 12),
                                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                                    decoration: BoxDecoration(
                                      color: Colors.red.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: Colors.red.withOpacity(0.4)),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(LucideIcons.alertCircle, color: Colors.redAccent, size: 16),
                                        const SizedBox(width: 8),
                                        Text(l10n.fullyBooked, style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1.2)),
                                      ],
                                    ),
                                  ),
                                GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 4,
                                    mainAxisSpacing: 10,
                                    crossAxisSpacing: 10,
                                    childAspectRatio: 0.85,
                                  ),
                                  itemCount: totalSeats,
                                  itemBuilder: (context, index) {
                                    final seatNum = index + 1;
                                    final isBooked = bookedSeats.contains(seatNum);
                                    final isSelected = selectedSeat == seatNum;
                                    final Color bgColor;
                                    final Color borderColor;
                                    final Color iconColor;
                                    final Color labelColor;
                                    if (isBooked) {
                                      bgColor = Colors.red.withOpacity(0.1);
                                      borderColor = Colors.red.withOpacity(0.35);
                                      iconColor = Colors.red.withOpacity(0.4);
                                      labelColor = Colors.red.withOpacity(0.5);
                                    } else if (isSelected) {
                                      bgColor = const Color(0xFF0EA5E9);
                                      borderColor = const Color(0xFF0EA5E9);
                                      iconColor = Colors.white;
                                      labelColor = Colors.white;
                                    } else {
                                      bgColor = Colors.green.withOpacity(0.08);
                                      borderColor = Colors.green.withOpacity(0.35);
                                      iconColor = Colors.green.shade400;
                                      labelColor = Colors.green.shade400;
                                    }
                                    return GestureDetector(
                                      onTap: isBooked ? null : () {
                                        setModalState(() => selectedSeat = seatNum);
                                      },
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 180),
                                        decoration: BoxDecoration(
                                          color: bgColor,
                                          borderRadius: BorderRadius.circular(10),
                                          border: Border.all(color: borderColor, width: 1.5),
                                          boxShadow: isSelected ? [BoxShadow(color: const Color(0xFF0EA5E9).withOpacity(0.4), blurRadius: 8)] : null,
                                        ),
                                        child: Stack(
                                          children: [
                                            Center(
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Icon(LucideIcons.armchair, size: 22, color: iconColor),
                                                  const SizedBox(height: 3),
                                                  Text('$seatNum', style: TextStyle(color: labelColor, fontSize: 11, fontWeight: FontWeight.bold)),
                                                ],
                                              ),
                                            ),
                                            if (isBooked)
                                              Positioned.fill(child: CustomPaint(painter: _CrossPainter())),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('tickets')
                            .where('busId', isEqualTo: busId)
                            .where('status', isEqualTo: 'confirmed')
                            .snapshots(),
                        builder: (ctx2, snap2) {
                          final int totalSeats = (busData['seats'] is int)
                              ? busData['seats']
                              : int.tryParse(busData['seats']?.toString() ?? '') ?? 0;
                          final booked = snap2.data?.docs.length ?? 0;
                          final isFullyBooked = booked >= totalSeats;
                          return SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: (selectedSeat == null || isFullyBooked) ? null : () {
                                setModalState(() => showDetails = true);
                              },
                              icon: isFullyBooked
                                  ? const Icon(LucideIcons.ban, size: 16)
                                  : const Icon(LucideIcons.arrowRight, size: 16),
                              label: Text(
                                isFullyBooked ? l10n.fullyBooked : l10n.continueBtn,
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isFullyBooked ? Colors.red.withOpacity(0.15) : const Color(0xFF0EA5E9),
                                foregroundColor: isFullyBooked ? Colors.redAccent : Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                disabledBackgroundColor: isFullyBooked ? Colors.red.withOpacity(0.08) : Colors.white.withOpacity(0.08),
                                disabledForegroundColor: isFullyBooked ? Colors.redAccent : Colors.white38,
                              ),
                            ),
                          );
                        },
                      ),
                    ] else ...[

                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(LucideIcons.arrowLeft, color: Colors.white),
                            onPressed: () => setModalState(() => showDetails = false),
                          ),
                          Text(l10n.passengerDetails, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 16),
  
                    // Passenger Name
                    TextFormField(
                      controller: nameController,
                      style: const TextStyle(color: Colors.white),
                      decoration: _ticketInputDecoration(l10n.passengerName, LucideIcons.user),
                      validator: (v) => (v == null || v.trim().isEmpty) ? l10n.enterPassengerName : null,
                    ),
                    const SizedBox(height: 14),
  
                    // Phone
                    TextFormField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      style: const TextStyle(color: Colors.white),
                      decoration: _ticketInputDecoration(l10n.phoneNumber, LucideIcons.phone),
                      validator: (v) => (v == null || v.trim().isEmpty) ? l10n.requiredField : null,
                    ),
                    const SizedBox(height: 14),
  
                    // Ticket Price
                    TextFormField(
                      controller: priceController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: const TextStyle(color: Colors.white),
                      decoration: _ticketInputDecoration(l10n.ticketPrice, LucideIcons.coins),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return l10n.enterTicketPrice;
                        if (double.tryParse(v.trim()) == null) return l10n.mustBeValidNumber;
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
  
                    // Confirm Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: isSaving ? null : () async {
                          if (!formKey.currentState!.validate()) return;
                          if (selectedSeat == null) {
                            ScaffoldMessenger.of(ctx).showSnackBar(
                              SnackBar(content: Text(l10n.pleaseSelectASeat), backgroundColor: Colors.orange),
                            );
                            return;
                          }
                          
                          setModalState(() => isSaving = true);
                          try {
                            final user = outerContext.read<AuthService>().currentUser!;
                            await FirebaseFirestore.instance.collection('tickets').add({
                              'busId': busId,
                              'busName': busData['busName'],
                              'departureAt': busData['departureAt'],
                              'passengerName': nameController.text.trim(),
                              'passengerPhone': phoneController.text.trim(),
                              'price': double.parse(priceController.text.trim()),
                              'seatNumber': selectedSeat,
                              'agencyId': user.agencyId,
                              'destinationAgencyId': busData['destinationAgencyId'] ?? '',
                              'destinationCity': busData['destinationCity'] ?? '',

                              'bookedBy': user.uid,
                              'bookedAt': FieldValue.serverTimestamp(),
                              'status': 'confirmed',
                            });
                            if (ctx.mounted) Navigator.pop(ctx);
                            if (outerContext.mounted) Navigator.pop(outerContext);
                            if (outerContext.mounted) {
                              ScaffoldMessenger.of(outerContext).showSnackBar(
                                SnackBar(
                                  content: Text('✓ Ticket #${selectedSeat} booked for ${nameController.text.trim()}!'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          } catch (e) {
                            setModalState(() => isSaving = false);
                            if (ctx.mounted) {
                              ScaffoldMessenger.of(ctx).showSnackBar(
                                SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                              );
                            }
                          }
                        },
                        icon: isSaving
                            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Icon(LucideIcons.ticket, size: 18),
                        label: Text(isSaving ? 'Saving...' : 'Confirm Booking'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0EA5E9),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _ticketInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white54),
      prefixIcon: Icon(icon, color: Colors.white38, size: 18),
      filled: true,
      fillColor: Colors.white.withOpacity(0.05),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF0EA5E9)),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.red),
      ),
    );
  }
}

class _ParcelTile extends StatelessWidget {
  final Map<String, dynamic> data;
  final String currentAgencyId;
  const _ParcelTile({required this.data, required this.currentAgencyId});

  Color _statusColor(String status) {
    switch (status) {
      case 'delivered':
        return AppTheme.secondaryColor;
      case 'received':
        return Colors.blue;
      case 'sent':
        return Colors.orange;
      default:
        return Colors.white60;
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = data['status'] ?? 'sent';
    final isReceiver = data['destinationAgencyId'] == currentAgencyId;
    final parcelId = data['id'];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: AppConstants.borderRadiusMd,
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: AppConstants.borderRadiusSm,
                ),
                child: const Icon(LucideIcons.package, color: AppTheme.primaryColor, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(data['receiverName'] ?? 'Unknown Receiver',
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(LucideIcons.phone, size: 12, color: Colors.white54),
                        const SizedBox(width: 4),
                        Text(data['receiverPhone'] ?? '-', style: const TextStyle(color: Colors.white54, fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 2),
                    GestureDetector(
                      onTap: () async {
                        final code = data['trackingCode'] ?? '-';
                        if (code != '-') {
                          await Clipboard.setData(ClipboardData(text: code));
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Tracking code copied to clipboard!'), backgroundColor: Colors.green),
                            );
                          }
                        }
                      },
                      child: Row(
                        children: [
                          const Icon(LucideIcons.copy, size: 12, color: Colors.blueAccent),
                          const SizedBox(width: 4),
                          Text(data['trackingCode'] ?? '-', style: const TextStyle(color: Colors.white54, fontSize: 12, decoration: TextDecoration.underline)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(LucideIcons.building2, size: 12, color: Colors.white54),
                        const SizedBox(width: 4),
                        FutureBuilder<DocumentSnapshot>(
                          future: FirebaseFirestore.instance.collection('agencies').doc(isReceiver ? (data['originAgencyId'] ?? '') : (data['destinationAgencyId'] ?? '')).get(),
                          builder: (context, snapshot) {
                            String agencyName = isReceiver ? (data['originAgencyId'] ?? '-') : (data['destinationAgencyId'] ?? '-');
                            if (snapshot.hasData && snapshot.data!.exists) {
                              agencyName = (snapshot.data!.data() as Map<String, dynamic>)['name'] ?? agencyName;
                            }
                            return Text(isReceiver ? 'From: $agencyName' : 'To: $agencyName',
                                style: const TextStyle(color: Colors.white54, fontSize: 12));
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (!isReceiver)
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _statusColor(status).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        status.replaceAll('_', ' ').toUpperCase(),
                        style: TextStyle(
                            color: _statusColor(status),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5),
                      ),
                    ),
                  if (isReceiver) ...[
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: status == 'delivered' ? null : () async {
                        try {
                          final newStatus = status == 'sent' ? 'received' : 'delivered';
                          await ParcelService().updateParcelStatus(parcelId, newStatus);
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(e.toString()), backgroundColor: AppTheme.errorColor)
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        disabledBackgroundColor: Colors.white.withOpacity(0.05),
                        disabledForegroundColor: Colors.white30,
                        backgroundColor: status == 'sent' ? Colors.blue.withOpacity(0.2) : AppTheme.secondaryColor.withOpacity(0.2),
                        foregroundColor: status == 'sent' ? Colors.blue : AppTheme.secondaryColor,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                        minimumSize: const Size(0, 32),
                      ),
                      child: Text(status == 'sent' ? 'Mark as Received' : (status == 'received' ? 'Mark as Delivered' : 'Delivered'), style: const TextStyle(fontSize: 11)),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Seat Legend helper ───────────────────────────────────────────────────────
Widget _seatLegend(Color color, String label) {
  return Row(mainAxisSize: MainAxisSize.min, children: [
    Container(
      width: 10, height: 10,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    ),
    const SizedBox(width: 5),
    Text(label, style: const TextStyle(color: Colors.white54, fontSize: 11)),
  ]);
}

// ── Cross painter for booked seats ───────────────────────────────────────────
class _CrossPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red.withOpacity(0.55)
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(size.width * 0.2, size.height * 0.2),
        Offset(size.width * 0.8, size.height * 0.8), paint);
    canvas.drawLine(Offset(size.width * 0.8, size.height * 0.2),
        Offset(size.width * 0.2, size.height * 0.8), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
