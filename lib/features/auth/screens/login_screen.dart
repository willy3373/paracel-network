import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:pick_pack/core/app_constants.dart';
import 'package:pick_pack/core/app_theme.dart';
import 'package:pick_pack/features/auth/services/auth_service.dart';
import 'package:pick_pack/features/dashboard/screens/dashboard_screen.dart';
import 'package:pick_pack/core/services/language_service.dart';
import 'package:pick_pack/l10n/app_localizations.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final error = await authService.signIn(
      _usernameController.text.trim(),
      _passwordController.text.trim(),
    );

    if (!mounted) return;

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DashboardScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthService>().isLoading;    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppTheme.backgroundColor, Color(0xFF1E1B4B)],
              ),
            ),
          ),
          
          
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2)),
                    ),
                    child: const Icon(LucideIcons.package, size: 64, color: AppTheme.primaryColor),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    AppLocalizations.of(context)!.appName,
                    style: Theme.of(context).textTheme.displayLarge,
                  ),
                  Text(
                    AppLocalizations.of(context)!.agencyParcelManagement,
                    style: const TextStyle(color: Colors.white60, letterSpacing: 1.2),
                  ),
                  
                  const SizedBox(height: 60),
                  
                  // Login Card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: AppConstants.borderRadiusLg,
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: Column(
                      children: [
                        _buildTextField(AppLocalizations.of(context)!.usernameOrEmail, LucideIcons.user, _usernameController),
                        const SizedBox(height: 16),
                        _buildTextField(AppLocalizations.of(context)!.password, LucideIcons.lock, _passwordController, obscureText: true),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : _handleLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: AppConstants.borderRadiusMd),
                            ),
                            child: isLoading 
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : Text(AppLocalizations.of(context)!.signIn, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  TextButton(
                    onPressed: () {},
                    child: Text(AppLocalizations.of(context)!.forgotPassword, style: const TextStyle(color: Colors.white60)),
                  ),
                ],
              ),
            ),
          ),
          
          // Language Selector in top corner (rendered last so it's on top and clickable)
          Positioned(
            top: 40,
            right: 20,
            child: _buildLanguageSelector(context),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageSelector(BuildContext context) {
    final languageService = context.watch<LanguageService>();
    final l10n = AppLocalizations.of(context)!;

    return PopupMenuButton<Locale>(
      icon: const Icon(LucideIcons.languages, color: Colors.white70),
      onSelected: (Locale locale) {
        context.read<LanguageService>().setLocale(locale);
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: const Locale('en'),
          child: Text(l10n.english),
        ),
        PopupMenuItem(
          value: const Locale('ar'),
          child: Text(l10n.arabic),
        ),
        PopupMenuItem(
          value: const Locale('fr'),
          child: Text(l10n.french),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, IconData icon, TextEditingController controller, {bool obscureText = false}) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white60),
        prefixIcon: Icon(icon, size: 20, color: Colors.white60),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: AppConstants.borderRadiusMd,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppConstants.borderRadiusMd,
          borderSide: BorderSide(color: Colors.white.withOpacity(0.05)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppConstants.borderRadiusMd,
          borderSide: const BorderSide(color: AppTheme.primaryColor),
        ),
      ),
    );
  }
}
