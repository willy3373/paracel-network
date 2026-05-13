import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pick_pack/core/app_constants.dart';
import 'package:pick_pack/core/app_theme.dart';
import 'package:pick_pack/features/auth/services/auth_service.dart';

class OwnerDashboard extends StatelessWidget {
  final int currentTab;
  const OwnerDashboard({super.key, this.currentTab = 0});

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthService>().currentUser!;
    final gangId = user.gangId ?? '';

    if (gangId.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.layers, size: 64, color: Colors.white.withOpacity(0.2)),
            const SizedBox(height: 16),
            Text(
              'No Gang assigned to this Owner.\nPlease contact your administrator.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 16),
            ),
          ],
        ),
      );
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('gangs').doc(gangId).snapshots(),
      builder: (context, gangSnap) {
        if (!gangSnap.hasData || !gangSnap.data!.exists) {
          return const Center(child: CircularProgressIndicator());
        }

        final gangData = gangSnap.data!.data() as Map<String, dynamic>;
        final List<String> agencyIds = List<String>.from(gangData['agencyIds'] ?? []);

        if (agencyIds.isEmpty) {
          return Center(
            child: Text('This gang "${gangData['name']}" has no agencies assigned.',
                style: const TextStyle(color: Colors.white38)),
          );
        }

        return _GangView(
          gangName: gangData['name'] ?? 'Your Gang',
          agencyIds: agencyIds,
          currentTab: currentTab,
        );
      },
    );
  }
}

class _GangView extends StatelessWidget {
  final String gangName;
  final List<String> agencyIds;
  final int currentTab;

  const _GangView({
    required this.gangName,
    required this.agencyIds,
    required this.currentTab,
  });

  @override
  Widget build(BuildContext context) {
    if (agencyIds.isEmpty) return const SizedBox.shrink();

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('agencies')
          .where(FieldPath.documentId, whereIn: agencyIds.take(10).toList())
          .snapshots(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final Map<String, String> agencyNames = {};
        for (var doc in snap.data?.docs ?? []) {
          final data = doc.data() as Map<String, dynamic>;
          agencyNames[doc.id] = data['name'] ?? 'Unknown';
        }

        switch (currentTab) {
          case 0:
            return _HomeTab(gangName: gangName, agencyIds: agencyIds, agencyNames: agencyNames);
          case 1:
            return _AgenciesTab(agencyIds: agencyIds);
          case 2:
            return _UsersTab(agencyIds: agencyIds, agencyNames: agencyNames);
          case 3:
            return _FeesTab(agencyIds: agencyIds, agencyNames: agencyNames);
          default:
            return _HomeTab(gangName: gangName, agencyIds: agencyIds, agencyNames: agencyNames);
        }
      },
    );
  }
}

// ── Tab 0: Home (Today's Money) ──────────────────────────────────────────────

class _HomeTab extends StatelessWidget {
  final String gangName;
  final List<String> agencyIds;
  final Map<String, String> agencyNames;
  const _HomeTab({required this.gangName, required this.agencyIds, required this.agencyNames});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);
    final timestampToday = Timestamp.fromDate(startOfToday);

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('parcels')
          .where('originAgencyId', whereIn: agencyIds.take(10).toList())
          .snapshots(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        // Local filtering to avoid Firestore Composite Index requirements
        final allParcels = snap.data?.docs ?? [];
        final parcels = allParcels.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          if (data['status'] != 'sent') return false;
          
          final createdAtRaw = data['createdAt'];
          DateTime? createdAt;
          if (createdAtRaw is String) {
            createdAt = DateTime.tryParse(createdAtRaw);
          } else if (createdAtRaw is Timestamp) {
            createdAt = createdAtRaw.toDate();
          }
          
          if (createdAt == null) return false;
          return createdAt.compareTo(startOfToday) >= 0;
        }).toList();
        double todayTotal = 0.0;
        for (var doc in parcels) {
          final data = doc.data() as Map<String, dynamic>;
          final amt = data['amount'];
          if (amt is num) {
            todayTotal += amt;
          } else if (amt is String) {
            todayTotal += double.tryParse(amt) ?? 0.0;
          }
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.horizontalPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF4F46E5)]),
                  borderRadius: AppConstants.borderRadiusLg,
                ),
                child: Row(
                  children: [
                    const Icon(LucideIcons.layers, color: Colors.white, size: 32),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Owner of Gang', style: TextStyle(color: Colors.white70, fontSize: 13)),
                        Text(gangName, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              const Text('Today\'s Overview', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceColor,
                  borderRadius: AppConstants.borderRadiusLg,
                  border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2)),
                  boxShadow: [
                    BoxShadow(color: AppTheme.primaryColor.withOpacity(0.1), blurRadius: 20, spreadRadius: 0),
                  ],
                ),
                child: Column(
                  children: [
                    const Icon(LucideIcons.coins, color: AppTheme.primaryColor, size: 48),
                    const SizedBox(height: 16),
                    const Text('Collected Today (Sent Parcels)', style: TextStyle(color: Colors.white60, fontSize: 14)),
                    const SizedBox(height: 8),
                    Text(
                      '${todayTotal.toStringAsFixed(2)} MRU',
                      style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text('${parcels.length} parcels processed', style: const TextStyle(color: AppTheme.primaryColor, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Tab 1: My Agencies ───────────────────────────────────────────────────────

class _AgenciesTab extends StatelessWidget {
  final List<String> agencyIds;
  const _AgenciesTab({required this.agencyIds});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('agencies')
          .where(FieldPath.documentId, whereIn: agencyIds.take(10).toList())
          .snapshots(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        final agencies = snap.data?.docs ?? [];

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.horizontalPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('My Agencies', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text('${agencies.length} agencies in your gang', style: const TextStyle(color: Colors.white60)),
              const SizedBox(height: 24),
              if (agencies.isEmpty)
                const _EmptyState(message: 'No agencies found.')
              else
                ...agencies.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceColor,
                      borderRadius: AppConstants.borderRadiusMd,
                      border: Border.all(color: Colors.white.withOpacity(0.05)),
                    ),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          backgroundColor: Colors.white10,
                          child: Icon(LucideIcons.building2, color: Colors.white),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(data['name'] ?? 'Unknown', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                              Text(data['phone'] ?? 'No Phone', style: const TextStyle(color: Colors.white54, fontSize: 12)),
                            ],
                          ),
                        ),
                        if (data['isBlocked'] == true)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                            child: const Text('BLOCKED', style: TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold)),
                          ),
                      ],
                    ),
                  );
                }),
            ],
          ),
        );
      },
    );
  }
}

// ── Tab 2: Users ─────────────────────────────────────────────────────────────

class _UsersTab extends StatelessWidget {
  final List<String> agencyIds;
  final Map<String, String> agencyNames;
  const _UsersTab({required this.agencyIds, required this.agencyNames});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('agencyId', whereIn: agencyIds.take(10).toList())
          .snapshots(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        final users = snap.data?.docs ?? [];

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.horizontalPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Agency Users', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text('${users.length} active users across your agencies', style: const TextStyle(color: Colors.white60)),
              const SizedBox(height: 24),
              if (users.isEmpty)
                const _EmptyState(message: 'No users found.')
              else
                ...users.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final role = (data['role'] ?? 'agent').toString().toUpperCase();
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceColor,
                      borderRadius: AppConstants.borderRadiusMd,
                      border: Border.all(color: Colors.white.withOpacity(0.05)),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                          child: const Icon(LucideIcons.user, color: AppTheme.primaryColor),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(data['name'] ?? 'Unknown User', style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                              Text(data['email'] ?? 'No Email', style: const TextStyle(color: Colors.white54, fontSize: 12)),
                              Text('Agency: ${agencyNames[data['agencyId']] ?? data['agencyId'] ?? '-'}', style: const TextStyle(color: Colors.white38, fontSize: 11)),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(4)),
                          child: Text(role, style: const TextStyle(color: Colors.white60, fontSize: 11, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  );
                }),
            ],
          ),
        );
      },
    );
  }
}

// ── Tab 3: Fees ──────────────────────────────────────────────────────────────

class _FeesTab extends StatelessWidget {
  final List<String> agencyIds;
  final Map<String, String> agencyNames;
  const _FeesTab({required this.agencyIds, required this.agencyNames});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('parcels')
          .where('originAgencyId', whereIn: agencyIds.take(10).toList())
          .snapshots(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        if (snap.hasError) {
          return Center(child: Text('Error loading fees: ${snap.error}', style: const TextStyle(color: AppTheme.errorColor)));
        }
        
        // Local sorting to avoid Firestore Composite Index requirement
        final parcels = snap.data?.docs.toList() ?? [];
        parcels.sort((a, b) {
          final dataA = a.data() as Map<String, dynamic>;
          final dataB = b.data() as Map<String, dynamic>;
          
          DateTime? parseDate(dynamic val) {
            if (val is String) return DateTime.tryParse(val);
            if (val is Timestamp) return val.toDate();
            return null;
          }

          final dateA = parseDate(dataA['createdAt']);
          final dateB = parseDate(dataB['createdAt']);
          
          if (dateA == null && dateB == null) return 0;
          if (dateA == null) return 1;
          if (dateB == null) return -1;
          return dateB.compareTo(dateA); // descending
        });
        double totalFees = 0.0;
        
        for (var doc in parcels) {
          final data = doc.data() as Map<String, dynamic>;
          final amt = data['amount'];
          if (amt is num) {
            totalFees += amt;
          } else if (amt is String) {
            totalFees += double.tryParse(amt) ?? 0.0;
          }
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.horizontalPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('All Fees & Revenue', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              const Text('Historical view of all collected amounts.', style: TextStyle(color: Colors.white60)),
              const SizedBox(height: 24),
              
              // Total Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceColor,
                  borderRadius: AppConstants.borderRadiusLg,
                  border: Border.all(color: Colors.orange.withOpacity(0.2)),
                ),
                child: Column(
                  children: [
                    const Text('Total Historic Revenue', style: TextStyle(color: Colors.white60, fontSize: 14)),
                    const SizedBox(height: 8),
                    Text(
                      '${totalFees.toStringAsFixed(2)} MRU',
                      style: const TextStyle(color: Colors.orange, fontSize: 32, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              const Text('Recent Transactions', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              
              if (parcels.isEmpty)
                const _EmptyState(message: 'No parcels or fees recorded yet.')
              else
                ...parcels.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final amt = data['amount']?.toString() ?? '0';
                  
                  final dateRaw = data['createdAt'];
                  DateTime? date;
                  if (dateRaw is String) {
                    date = DateTime.tryParse(dateRaw);
                  } else if (dateRaw is Timestamp) {
                    date = dateRaw.toDate();
                  }
                  
                  final dateStr = date != null ? '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}' : 'Unknown Date';
                  
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceColor,
                      borderRadius: AppConstants.borderRadiusMd,
                      border: Border.all(color: Colors.white.withOpacity(0.05)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), shape: BoxShape.circle),
                          child: const Icon(LucideIcons.banknote, color: Colors.orange, size: 18),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('From: ${agencyNames[data['originAgencyId']] ?? data['originAgencyId'] ?? '?'}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              Text(dateStr, style: const TextStyle(color: Colors.white54, fontSize: 11)),
                              Text('To: ${agencyNames[data['destinationAgencyId']] ?? data['destinationAgencyId'] ?? '?'}', style: const TextStyle(color: Colors.white38, fontSize: 10)),
                            ],
                          ),
                        ),
                        Text(
                          '+$amt MRU',
                          style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ],
                    ),
                  );
                }),
            ],
          ),
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String message;
  const _EmptyState({required this.message});
  @override
  Widget build(BuildContext context) {
    return Center(child: Padding(
      padding: const EdgeInsets.all(20),
      child: Text(message, style: const TextStyle(color: Colors.white24, fontSize: 13)),
    ));
  }
}
