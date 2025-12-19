import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/locale_provider.dart';

class LanguageSelector extends StatelessWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final currentLang = localeProvider.locale.languageCode.toUpperCase();
    
    final languageMap = {
      'RU': 'ru',
      'EN': 'en',
      'UZ': 'uz',
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F3A),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: languageMap.keys.map((lang) {
          final isSelected = lang == currentLang;
          return GestureDetector(
            onTap: () {
              localeProvider.setLanguage(languageMap[lang]!);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFFFD700) : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                lang,
                style: TextStyle(
                  color: isSelected ? const Color(0xFF0A0E27) : Colors.white,
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

