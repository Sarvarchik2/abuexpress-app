import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/onboarding_screen.dart';

void main() {
  runApp(const AbuExpressApp());
}

class AbuExpressApp extends StatelessWidget {
  const AbuExpressApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AbuExpress',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFFFFD700),
        scaffoldBackgroundColor: const Color(0xFF0A0E27),
        textTheme: GoogleFonts.manropeTextTheme(),
        fontFamily: GoogleFonts.manrope().fontFamily,
      ),
      home: const OnboardingScreen(),
    );
  }
}

