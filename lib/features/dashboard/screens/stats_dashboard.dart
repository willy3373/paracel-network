import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:pick_pack/core/app_constants.dart';
import 'package:pick_pack/core/app_theme.dart';
import 'package:pick_pack/features/auth/services/auth_service.dart';
import 'package:pick_pack/l10n/app_localizations.dart';

class StatsDashboard extends StatelessWidget {
  const StatsDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final user = context.watch<AuthService>().currentUser;
    if (user == null) return const SizedBox.shrink();

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('parcels')
          .where(Filter.or(
            Filter('originAgencyId', isEqualTo: user.agencyId),
            Filter('destinationAgencyId', isEqualTo: user.agencyId),
          ))
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor));
        }

        if (snapshot.hasError) {
          return Center(child: Text(l10n.errorLoadingStats, style: const TextStyle(color: Colors.white54)));
        }

        int sentCount = 0;
        int receivedCount = 0;
        double totalCollected = 0.0;

        if (snapshot.hasData) {
          for (var doc in snapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic>;

            if (data['originAgencyId'] == user.agencyId) {
              sentCount++;
              totalCollected += (data['amount'] ?? 0.0) is int
                  ? (data['amount'] as int).toDouble()
                  : (data['amount'] as double? ?? 0.0);
            }
            if (data['destinationAgencyId'] == user.agencyId) {
              receivedCount++;
            }
          }
        }

        return Scaffold(
          backgroundColor: AppTheme.backgroundColor,
          appBar: AppBar(
            title: Text(l10n.agencyStatistics),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.horizontalPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatCard(
                  title: l10n.totalMoneyCollected,
                  value: '${totalCollected.toStringAsFixed(2)} MRU',
                  icon: LucideIcons.banknote,
                  color: Colors.green,
                  isLarge: true,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        title: l10n.sentParcels,
                        value: sentCount.toString(),
                        icon: LucideIcons.packagePlus,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        title: l10n.receivedParcels,
                        value: receivedCount.toString(),
                        icon: LucideIcons.packageCheck,
                        color: AppTheme.secondaryColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    bool isLarge = false,
  }) {
    return Container(
      padding: EdgeInsets.all(isLarge ? 24 : 20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: AppConstants.borderRadiusLg,
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: AppConstants.borderRadiusSm,
                ),
                child: Icon(icon, color: color, size: isLarge ? 28 : 20),
              ),
            ],
          ),
          SizedBox(height: isLarge ? 24 : 16),
          Text(
            title,
            style: TextStyle(
              color: Colors.white54,
              fontSize: isLarge ? 16 : 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: isLarge ? 36 : 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
