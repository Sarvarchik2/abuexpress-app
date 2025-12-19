import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'providers/theme_provider.dart';
import 'providers/locale_provider.dart';
import 'utils/theme.dart';
import 'l10n/app_localizations.dart';
import 'screens/onboarding_screen.dart';

void main() {
  // Подавляем предупреждения о клавиатуре в симуляторе
  FlutterError.onError = (FlutterErrorDetails details) {
    // Игнорируем предупреждения о KeyUpEvent в симуляторе
    final exceptionString = details.exception.toString();
    if (exceptionString.contains('KeyUpEvent') ||
        exceptionString.contains('HardwareKeyboard') ||
        exceptionString.contains('KeyDownEvent') ||
        exceptionString.contains('_pressedKeys.containsKey')) {
      return; // Игнорируем эти предупреждения
    }
    FlutterError.presentError(details);
  };

  // Перехватываем ошибки из зоны выполнения
  runZonedGuarded(() {
    runApp(const AbuExpressApp());
  }, (error, stack) {
    // Игнорируем ошибки клавиатуры из services library
    final errorString = error.toString();
    if (errorString.contains('KeyUpEvent') ||
        errorString.contains('HardwareKeyboard') ||
        errorString.contains('_pressedKeys.containsKey')) {
      return; // Игнорируем
    }
    // Для других ошибок можно добавить логирование
  });
}

class AbuExpressApp extends StatelessWidget {
  const AbuExpressApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
      ],
      child: Consumer2<ThemeProvider, LocaleProvider>(
        builder: (context, themeProvider, localeProvider, _) {
          return MaterialApp(
            title: 'AbuExpress',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.getLightTheme(),
            darkTheme: AppTheme.getDarkTheme(),
            themeMode: themeProvider.themeMode,
            locale: localeProvider.locale,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
              AppLocalizations.delegate,
            ],
            supportedLocales: const [
              // Основные языки приложения (с полной локализацией)
              Locale('ru', ''), // Русский
              Locale('en', ''), // English
              Locale('uz', ''), // O'zbekcha
            ],
            home: const OnboardingScreen(),
          );
        },
      ),
    );
  }
}

