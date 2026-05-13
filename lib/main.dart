import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:pick_pack/core/app_theme.dart';
import 'package:pick_pack/core/app_constants.dart';
import 'package:pick_pack/core/theme_service.dart';
import 'package:pick_pack/features/auth/screens/login_screen.dart';
import 'package:pick_pack/features/auth/services/auth_service.dart';
import 'package:pick_pack/features/dashboard/screens/dashboard_screen.dart';
import 'package:pick_pack/core/services/notification_service.dart';
import 'package:pick_pack/core/services/language_service.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:pick_pack/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Initialize Notifications
  await NotificationService.initialize();
  
  // Load saved language
  final prefs = await SharedPreferences.getInstance();
  final String? languageCode = prefs.getString('language_code');
  final initialLocale = Locale(languageCode ?? 'en');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => ThemeService()),
        ChangeNotifierProvider(create: (_) => LanguageService(initialLocale)),
      ],
      child: const PickPackApp(),
    ),
  );
}

class PickPackApp extends StatelessWidget {
  const PickPackApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeService = context.watch<ThemeService>();
    final authService = context.watch<AuthService>();
    final languageService = context.watch<LanguageService>();
    print('PickPackApp building with locale: ${languageService.locale.languageCode}');
    
    return MaterialApp(
      key: ValueKey(languageService.locale.languageCode),
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeService.themeMode,
      locale: languageService.locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: authService.currentUser != null 
          ? const DashboardScreen() 
          : const LoginScreen(),
    );
  }
}
