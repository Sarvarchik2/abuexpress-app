import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/theme_provider.dart';
import 'utils/theme.dart';
import 'screens/onboarding_screen.dart';

void main() {
  runApp(const AbuExpressApp());
}

class AbuExpressApp extends StatelessWidget {
  const AbuExpressApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'AbuExpress',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.getLightTheme(),
            darkTheme: AppTheme.getDarkTheme(),
            themeMode: themeProvider.themeMode,
            home: const OnboardingScreen(),
          );
        },
      ),
    );
  }
}

