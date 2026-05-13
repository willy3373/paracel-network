import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageService extends ChangeNotifier {
  static const String _languageKey = 'language_code';
  Locale _locale;

  LanguageService(this._locale);

  Locale get locale => _locale;

  Future<void> setLocale(Locale locale) async {
    print('LanguageService.setLocale called with: ${locale.languageCode}');
    if (_locale.languageCode == locale.languageCode) {
      print('Locale is already ${locale.languageCode}, ignoring.');
      return;
    }
    _locale = locale;
    print('Calling notifyListeners for locale: ${locale.languageCode}');
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, locale.languageCode);
    } catch (e) {
      debugPrint('Error saving language: $e');
    }
  }

  Future<void> clearLocale() async {
    _locale = const Locale('en');
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_languageKey);
    } catch (e) {
      debugPrint('Error clearing language: $e');
    }
  }
}
