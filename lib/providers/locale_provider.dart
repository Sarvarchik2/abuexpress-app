import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('ru'); // По умолчанию русский

  Locale get locale => _locale;

  LocaleProvider() {
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final languageCode = prefs.getString('language_code') ?? 'ru';
      // Убеждаемся, что locale поддерживается
      if (['ru', 'en', 'uz'].contains(languageCode)) {
        _locale = Locale(languageCode);
      } else {
        _locale = const Locale('ru');
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading locale: $e');
      _locale = const Locale('ru');
      notifyListeners();
    }
  }

  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;
    
    _locale = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', locale.languageCode);
    notifyListeners();
  }

  void setLanguage(String languageCode) {
    setLocale(Locale(languageCode));
  }
}

