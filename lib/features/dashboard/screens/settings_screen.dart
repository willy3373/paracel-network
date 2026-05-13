import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:pick_pack/core/app_theme.dart';
import 'package:pick_pack/core/app_constants.dart';
import 'package:pick_pack/core/theme_service.dart';
import 'package:pick_pack/features/auth/services/auth_service.dart';
import 'package:pick_pack/core/services/language_service.dart';
import 'package:pick_pack/l10n/app_localizations.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeService = context.watch<ThemeService>();
    final languageService = context.watch<LanguageService>();
    final user = context.watch<AuthService>().currentUser;
    final isDark = themeService.isDark;
    final l10n = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.horizontalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),

          // Profile card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.primaryColor, AppTheme.primaryColor.withOpacity(0.7)],
              ),
              borderRadius: AppConstants.borderRadiusLg,
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  child: const Icon(LucideIcons.user, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.name ?? 'User',
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        user?.role.name.toUpperCase() ?? '',
                        style: const TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          
          // Appearance section
          _sectionLabel(l10n.appearance, context),
          const SizedBox(height: 12),

          _settingsTile(
            context: context,
            icon: isDark ? LucideIcons.moon : LucideIcons.sun,
            iconColor: isDark ? Colors.indigo : Colors.amber,
            title: l10n.theme,
            subtitle: isDark ? 'Dark Mode' : 'Light Mode',
            trailing: Switch(
              value: isDark,
              onChanged: (_) => context.read<ThemeService>().toggle(),
              activeColor: AppTheme.primaryColor,
            ),
          ),

          const SizedBox(height: 12),

          _settingsTile(
            context: context,
            icon: LucideIcons.languages,
            iconColor: Colors.blue,
            title: l10n.language,
            subtitle: l10n.selectLanguage,
            trailing: DropdownButton<String>(
              value: languageService.locale.languageCode,
              underline: const SizedBox(),
              icon: const Icon(LucideIcons.chevronDown, size: 16),
              onChanged: (String? code) {
                if (code != null) {
                  context.read<LanguageService>().setLocale(Locale(code));
                }
              },
              items: [
                DropdownMenuItem(value: 'en', child: Text(l10n.english)),
                DropdownMenuItem(value: 'ar', child: Text(l10n.arabic)),
                DropdownMenuItem(value: 'fr', child: Text(l10n.french)),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Account section
          _sectionLabel(l10n.account, context),
          const SizedBox(height: 12),

          _settingsTile(
            context: context,
            icon: LucideIcons.logOut,
            iconColor: AppTheme.errorColor,
            title: l10n.signOut,
            subtitle: l10n.logOutOfAccount,
            trailing: const Icon(LucideIcons.chevronRight, size: 18),
            onTap: () => context.read<AuthService>().signOut(),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String label, BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        color: Theme.of(context).colorScheme.primary,
        fontSize: 13,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _settingsTile({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required Widget trailing,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: AppConstants.borderRadiusMd,
          border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.12),
                borderRadius: AppConstants.borderRadiusSm,
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                  Text(subtitle, style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5))),
                ],
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}
