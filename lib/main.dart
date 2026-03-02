import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'providers/theme_provider.dart';
import 'providers/locale_provider.dart';
import 'providers/user_provider.dart';
import 'utils/theme.dart';
import 'l10n/app_localizations.dart';
import 'screens/splash_screen.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'services/notification_service.dart';

void main() async {
  // Перехватываем ошибки из зоны выполнения
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Инициализация Firebase
    try {
      debugPrint("Starting Firebase.initializeApp()...");
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      ).catchError((e) {
        if (e.toString().contains('duplicate-app')) {
           debugPrint("Firebase already initialized (duplicate-app ignored)");
           return Firebase.app();
        }
        throw e;
      });
      debugPrint("Firebase initialized successfully");
    } catch (e) {
      if (e.toString().contains('duplicate-app')) {
         debugPrint("Firebase already initialized (duplicate-app caught)");
      } else {
         debugPrint("Failed to initialize Firebase: $e");
      }
    }

    // Инициализируем уведомления ВНЕ зависимости от того, была ли ошибка "уже инициализирован"
    try {
      debugPrint("Starting NotificationService().initialize()...");
      await NotificationService().initialize(); 
      debugPrint("NotificationService initialized successfully from main");
    } catch (e) {
      debugPrint("Error initializing NotificationService: $e");
    }

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
    debugPrint("Async error: $error");
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
        ChangeNotifierProvider(create: (_) => UserProvider()),
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
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}

