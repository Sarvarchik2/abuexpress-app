import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

extension LocalizationExtension on BuildContext {
  AppLocalizations get l10n {
    final localizations = AppLocalizations.of(this);
    if (localizations == null) {
      debugPrint('Warning: AppLocalizations is null, using default locale');
      return AppLocalizations(const Locale('ru'));
    }
    return localizations;
  }
}

