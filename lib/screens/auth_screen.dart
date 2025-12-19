import 'package:flutter/material.dart';
import '../widgets/onboarding_icon.dart';
import '../models/onboarding_item.dart';
import '../utils/localization_helper.dart';
import 'login_screen.dart';
import 'registration_choice_screen.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    String tagline;
    String footer;
    try {
      tagline = context.l10n.translate('international_delivery');
      footer = context.l10n.translate('worldwide_delivery');
    } catch (e) {
      debugPrint('Localization error in build: $e');
      tagline = 'Международная доставка посылок';
      footer = 'Доставка по всему миру';
    }

    return Scaffold(
      backgroundColor: const Color(0xFF030712),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              // Logo
              const OnboardingIcon(iconType: OnboardingIconType.airplane),
              const SizedBox(height: 40),
              // Brand name
              const Text(
                'AbuExpress',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              // Tagline
              Text(
                tagline,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
              const Spacer(flex: 3),
              // Login button
              _buildLoginButton(context),
              const SizedBox(height: 16),
              // Register button
              _buildRegisterButton(context),
              const SizedBox(height: 40),
              // Footer text
              Text(
                footer,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton(BuildContext context) {
    String buttonText;
    try {
      buttonText = context.l10n.translate('login');
    } catch (e) {
      debugPrint('Localization error: $e');
      buttonText = 'Вход';
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        debugPrint('=== LOGIN BUTTON TAPPED ===');
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const LoginScreen(),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: const Color(0xFFFFD700),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.arrow_forward,
              color: Color(0xFF0A0E27),
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              buttonText,
              style: const TextStyle(
                color: Color(0xFF0A0E27),
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegisterButton(BuildContext context) {
    String buttonText;
    try {
      buttonText = context.l10n.translate('register');
    } catch (e) {
      debugPrint('Localization error: $e');
      buttonText = 'Регистрация';
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        debugPrint('=== REGISTER BUTTON TAPPED ===');
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const RegistrationChoiceScreen(),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF1A1F3A),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 1.5,
                ),
              ),
              child: const Icon(
                Icons.add,
                color: Colors.white,
                size: 14,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              buttonText,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
