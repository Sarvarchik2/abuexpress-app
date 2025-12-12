import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import 'theme.dart';

class ThemeHelper {
  static bool isDark(BuildContext context) {
    try {
      return Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
    } catch (e) {
      // Если Provider недоступен, возвращаем дефолтное значение (темная тема)
      return true;
    }
  }

  static Color getBackgroundColor(BuildContext context) {
    return isDark(context) ? AppTheme.darkBackground : AppTheme.lightBackground;
  }

  static Color getCardColor(BuildContext context) {
    return isDark(context) ? AppTheme.darkCard : AppTheme.lightCard;
  }

  static Color getTextColor(BuildContext context) {
    return isDark(context) ? AppTheme.darkText : AppTheme.lightText;
  }

  static Color getTextSecondaryColor(BuildContext context) {
    return isDark(context) ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary;
  }

  static Color getSecondaryColor(BuildContext context) {
    return isDark(context) ? AppTheme.darkSecondary : AppTheme.lightSecondary;
  }
}
