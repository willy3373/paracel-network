import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pick_pack/core/app_constants.dart';
import 'package:pick_pack/core/app_theme.dart';
import 'package:pick_pack/features/auth/services/auth_service.dart';
import 'package:pick_pack/features/parcels/services/parcel_service.dart';
import 'package:pick_pack/l10n/app_localizations.dart';

class HelperDashboard extends StatefulWidget {
  const HelperDashboard({super.key});

  @override
  State<HelperDashboard> createState() => _HelperDashboardState();
}

class _HelperDashboardState extends State<HelperDashboard> {
  final _trackingController = TextEditingController();
  Map<String, dynamic>? _result;
  bool _isSearching = false;
  String? _error;

  @override
  void dispose() {
    _trackingController.dispose();
    super.dispose();
  }

  Future<void> _trackParcel(AppLocalizations l10n) async {
    final query = _trackingController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _isSearching = true;
      _result = null;
      _error = null;
    });

    try {
      final snap = await FirebaseFirestore.instance
          .collection('parcels')
          .where(
            Filter.or(
              Filter('trackingCode', isEqualTo: query),
              Filter('receiverPhone', isEqualTo: query),
            ),
          )
          .limit(1)
          .get();

      if (snap.docs.isNotEmpty) {
        final data = snap.docs.first.data();
        data['id'] = snap.docs.first.id;

        if (mounted) {
          final user = context.read<AuthService>().currentUser!;
          if (data['originAgencyId'] != user.agencyId && data['destinationAgencyId'] != user.agencyId) {
            setState(() {
              _error = l10n.noPermissionToTrack;
              _isSearching = false;
            });
            return;
          }
        }

        setState(() {
          _result = data;
          _isSearching = false;
        });
      } else {
        setState(() {
          _error = l10n.noParcelFound(query);
          _isSearching = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = l10n.errorLookingUpParcel;
        _isSearching = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.horizontalPadding),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),

            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
                  AppTheme.secondaryColor,
                  AppTheme.secondaryColor.withOpacity(0.7),
                ]),
                borderRadius: AppConstants.borderRadiusLg,
              ),
              child: Row(
                children: [
                  const Icon(LucideIcons.search, color: Colors.white, size: 32),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.trackParcel,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                      Text(l10n.enterTrackingOrPhone,
                          style: const TextStyle(color: Colors.white70, fontSize: 13)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Search field
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _trackingController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: l10n.trackingCodeOrPhone,
                      hintStyle: const TextStyle(color: Colors.white38),
                      prefixIcon: const Icon(LucideIcons.hash,
                          color: Colors.white38, size: 20),
                      filled: true,
                      fillColor: AppTheme.surfaceColor,
                      border: OutlineInputBorder(
                        borderRadius: AppConstants.borderRadiusMd,
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: AppConstants.borderRadiusMd,
                        borderSide: BorderSide(
                            color: Colors.white.withOpacity(0.08)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: AppConstants.borderRadiusMd,
                        borderSide: const BorderSide(
                            color: AppTheme.secondaryColor),
                      ),
                    ),
                    onSubmitted: (_) => _trackParcel(l10n),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isSearching ? null : () => _trackParcel(l10n),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.secondaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: AppConstants.borderRadiusMd),
                    ),
                    child: _isSearching
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Icon(LucideIcons.search),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Error
            if (_error != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.errorColor.withOpacity(0.1),
                  borderRadius: AppConstants.borderRadiusMd,
                  border: Border.all(color: AppTheme.errorColor.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(LucideIcons.alertCircle,
                        color: AppTheme.errorColor, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                        child: Text(_error!,
                            style: const TextStyle(color: AppTheme.errorColor))),
                  ],
                ),
              ),

            // Parcel result
            if (_result != null) _TrackingResult(data: _result!),
          ],
      ),
    );
  }
}

class _TrackingResult extends StatefulWidget {
  final Map<String, dynamic> data;
  const _TrackingResult({required this.data});

  @override
  State<_TrackingResult> createState() => _TrackingResultState();
}

class _TrackingResultState extends State<_TrackingResult> {
  late String _status;
  bool _isUpdating = false;
  final _parcelService = ParcelService();

  @override
  void initState() {
    super.initState();
    _status = widget.data['status'] ?? 'sent';
  }

  Future<void> _updateStatus(AppLocalizations l10n) async {
    final newStatus = _status == 'sent' ? 'received' : 'delivered';
    setState(() => _isUpdating = true);
    try {
      await _parcelService.updateParcelStatus(widget.data['id'], newStatus);
      setState(() => _status = newStatus);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.parcelStatusUpdated),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppTheme.errorColor),
        );
      }
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final user = context.read<AuthService>().currentUser;
    final isReceiver = widget.data['destinationAgencyId'] == user?.agencyId;

    final List<_TrackStep> steps = [
      _TrackStep(l10n.parcelSent, 'sent', LucideIcons.packagePlus),
      _TrackStep(l10n.receivedAtDestination, 'received', LucideIcons.mapPin),
      _TrackStep(l10n.deliveredToCustomer, 'delivered', LucideIcons.checkCircle),
    ];

    final statusOrder = ['sent', 'received', 'delivered'];
    final currentStep = statusOrder.indexOf(_status);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: AppConstants.borderRadiusLg,
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.secondaryColor.withOpacity(0.1),
                  borderRadius: AppConstants.borderRadiusSm,
                ),
                child: const Icon(LucideIcons.package, color: AppTheme.secondaryColor),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${l10n.toDestination} ${widget.data['receiverName'] ?? 'Unknown'}',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(
                      '${widget.data['originAgencyId'] ?? '-'} → ${widget.data['destinationAgencyId'] ?? '-'}',
                      style: const TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Journey stepper
          ...steps.asMap().entries.map((entry) {
            final i = entry.key;
            final step = entry.value;
            final isDone = i <= currentStep;
            final isActive = i == currentStep;

            return Row(
              children: [
                Column(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: isDone ? AppTheme.secondaryColor : Colors.white.withOpacity(0.08),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(step.icon, size: 16, color: isDone ? Colors.white : Colors.white30),
                    ),
                    if (i < steps.length - 1)
                      Container(
                        width: 2,
                        height: 32,
                        color: isDone && i < currentStep ? AppTheme.secondaryColor : Colors.white.withOpacity(0.1),
                      ),
                  ],
                ),
                const SizedBox(width: 16),
                Padding(
                  padding: const EdgeInsets.only(bottom: 32),
                  child: Text(
                    step.label,
                    style: TextStyle(
                      color: isActive ? Colors.white : isDone ? Colors.white60 : Colors.white24,
                      fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            );
          }),

          if (isReceiver)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (_status != 'sent' || _isUpdating) ? null : () => _updateStatus(l10n),
                style: ElevatedButton.styleFrom(
                  disabledBackgroundColor: Colors.white.withOpacity(0.05),
                  disabledForegroundColor: Colors.white30,
                  backgroundColor: _status == 'sent' ? Colors.blue.withOpacity(0.2) : Colors.green.withOpacity(0.1),
                  foregroundColor: _status == 'sent' ? Colors.blue : Colors.green.withOpacity(0.5),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isUpdating
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(
                        _status == 'sent' ? l10n.markAsReceived : (_status == 'received' ? l10n.received : l10n.delivered),
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
        ],
      ),
    );
  }
}

class _TrackStep {
  final String label;
  final String status;
  final IconData icon;
  const _TrackStep(this.label, this.status, this.icon);
}
