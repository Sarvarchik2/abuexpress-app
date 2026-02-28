import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/notification_service.dart';

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

  Future<void> setLocale(Locale newLocale) async {
    if (_locale == newLocale) return;
    
    _locale = newLocale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', newLocale.languageCode);
    notifyListeners();
    
    // Как только пользователь меняет язык, сразу обновляем его на сервере (для пуш-уведомлений)
    NotificationService().syncToken();
  }

  void setLanguage(String languageCode) {
    setLocale(Locale(languageCode));
  }
}

