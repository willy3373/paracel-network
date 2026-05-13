import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pick_pack/core/app_constants.dart';
import 'package:pick_pack/core/app_theme.dart';
import 'package:pick_pack/features/auth/services/auth_service.dart';
import 'package:pick_pack/models/parcel.dart';
import 'package:pick_pack/features/parcels/services/parcel_service.dart';
import 'package:pick_pack/l10n/app_localizations.dart';

class HelperParcelsScreen extends StatelessWidget {
  const HelperParcelsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final user = context.read<AuthService>().currentUser!;
    final agencyId = user.agencyId ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(AppConstants.horizontalPadding, 12, AppConstants.horizontalPadding, 0),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [AppTheme.primaryColor, AppTheme.primaryColor.withOpacity(0.7)]),
              borderRadius: AppConstants.borderRadiusLg,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: AppConstants.borderRadiusMd),
                  child: const Icon(LucideIcons.inbox, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.receivedParcelsTitle, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    Text(l10n.allParcelsSentToAgency, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: agencyId.isEmpty
              ? Center(child: Text(l10n.noAgencyAssigned, style: const TextStyle(color: Colors.white54)))
              : StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('parcels').where('destinationAgencyId', isEqualTo: agencyId).snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                    if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.white54)));

                    final allDocs = snapshot.data?.docs ?? [];
                    final now = DateTime.now();
                    final todayStart = DateTime(now.year, now.month, now.day);

                    final todayDocs = allDocs.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final createdAtStr = data['createdAt'] as String?;
                      if (createdAtStr == null) return false;
                      try {
                        final date = DateTime.parse(createdAtStr);
                        return date.isAfter(todayStart);
                      } catch (_) { return false; }
                    }).toList();

                    final int totalToday = todayDocs.length;
                    final int receivedToday = todayDocs.where((doc) {
                      final s = (doc.data() as Map)['status'] ?? 'sent';
                      return s == 'received' || s == 'delivered';
                    }).length;
                    final int deliveredToday = todayDocs.where((doc) => (doc.data() as Map)['status'] == 'delivered').length;

                    final displayDocs = todayDocs;
                    displayDocs.sort((a, b) {
                      final aDate = (a.data() as Map)['createdAt'] as String? ?? '';
                      final bDate = (b.data() as Map)['createdAt'] as String? ?? '';
                      return bDate.compareTo(aDate);
                    });

                    if (displayDocs.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(LucideIcons.packageOpen, color: Colors.white24, size: 64),
                            const SizedBox(height: 16),
                            Text(l10n.noParcelsToday2, style: const TextStyle(color: Colors.white54, fontSize: 16)),
                            Text(l10n.parcelsWillAppearHere, style: const TextStyle(color: Colors.white30, fontSize: 13)),
                          ],
                        ),
                      );
                    }

                    return Column(
                      children: [
                        if (totalToday > 0)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(AppConstants.horizontalPadding, 0, AppConstants.horizontalPadding, 16),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppTheme.surfaceColor,
                                borderRadius: AppConstants.borderRadiusMd,
                                border: Border.all(color: Colors.white.withOpacity(0.08)),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(l10n.todaysOverview, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                                      Text('$receivedToday ${l10n.ofReceived(totalToday)}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  LinearProgressIndicator(
                                    value: receivedToday / totalToday,
                                    backgroundColor: Colors.white12,
                                    color: AppTheme.primaryColor,
                                    minHeight: 6,
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      _SummaryStat(label: l10n.inTransit, value: '${totalToday - receivedToday}', color: Colors.orange),
                                      _SummaryStat(label: l10n.received, value: '${receivedToday - deliveredToday}', color: Colors.blue),
                                      _SummaryStat(label: l10n.delivered, value: '$deliveredToday', color: Colors.green),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        Expanded(
                          child: ListView.separated(
                            padding: const EdgeInsets.symmetric(horizontal: AppConstants.horizontalPadding),
                            itemCount: displayDocs.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 10),
                            itemBuilder: (context, i) {
                              final data = displayDocs[i].data() as Map<String, dynamic>;
                              final parcel = Parcel.fromMap(data, displayDocs[i].id);
                              return _ParcelCard(parcel: parcel);
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _ParcelCard extends StatefulWidget {
  final Parcel parcel;
  const _ParcelCard({required this.parcel});
  @override
  State<_ParcelCard> createState() => _ParcelCardState();
}

class _ParcelCardState extends State<_ParcelCard> {
  bool _expanded = false;
  bool _isUpdating = false;
  late String _status;
  final _parcelService = ParcelService();

  @override
  void initState() {
    super.initState();
    _status = widget.parcel.status;
  }

  Future<void> _updateStatus(String newStatus) async {
    setState(() => _isUpdating = true);
    try {
      await _parcelService.updateParcelStatus(widget.parcel.id, newStatus);
      setState(() => _status = newStatus);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bool isProcessed = _status != 'sent';
    return Opacity(
      opacity: isProcessed ? 0.6 : 1.0,
      child: GestureDetector(
        onTap: () => setState(() => _expanded = !_expanded),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: AppConstants.borderRadiusMd,
            border: Border.all(color: _expanded ? AppTheme.primaryColor.withOpacity(0.4) : Colors.white.withOpacity(0.05)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(LucideIcons.package, color: Colors.white54, size: 20),
                  const SizedBox(width: 12),
                  Expanded(child: Text('${l10n.toDestination} ${widget.parcel.receiverName}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(12)),
                    child: Text(_status.toUpperCase(), style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              if (_expanded) ...[
                const SizedBox(height: 16),
                const Divider(color: Colors.white10),
                _DetailRow(l10n.codeLabel, widget.parcel.trackingCode),
                _DetailRow(l10n.fromLabel, widget.parcel.originAgencyId),
                _DetailRow(l10n.receiverLabel, widget.parcel.receiverPhone),
                _DetailRow(l10n.amountLabel, '${widget.parcel.amount.toStringAsFixed(0)} DA'),
                const SizedBox(height: 12),
                if (_status == 'sent')
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isUpdating ? null : () => _updateStatus('received'),
                      child: _isUpdating ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : Text(l10n.markAsReceivedBtn),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow(this.label, this.value);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(children: [
        SizedBox(width: 80, child: Text(label, style: const TextStyle(color: Colors.white38, fontSize: 12))),
        Expanded(child: Text(value, style: const TextStyle(color: Colors.white70, fontSize: 12))),
      ]),
    );
  }
}

class _SummaryStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _SummaryStat({required this.label, required this.value, required this.color});
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text(value, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.bold)),
      Text(label, style: const TextStyle(color: Colors.white38, fontSize: 10)),
    ]);
  }
}
