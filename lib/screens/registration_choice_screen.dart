import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/localization_helper.dart';
import '../widgets/custom_snackbar.dart';
import '../widgets/custom_dialog.dart';
import 'self_registration_screen.dart';
import 'main_screen.dart';

class RegistrationChoiceScreen extends StatefulWidget {
  const RegistrationChoiceScreen({super.key});

  @override
  State<RegistrationChoiceScreen> createState() => _RegistrationChoiceScreenState();
}

class _RegistrationChoiceScreenState extends State<RegistrationChoiceScreen> {
  bool _isLoading = false;

  Future<void> _handleOneIDRegistration(BuildContext context) async {
    // Показываем диалог с информацией о OneID
    final shouldProceed = await CustomDialog.show<bool>(
      context: context,
      title: 'Регистрация через OneID',
      message: 'Вы будете перенаправлены на официальный сайт OneID для авторизации. После успешной авторизации вы вернетесь в приложение.',
      actions: [
        CustomDialogActions.secondaryButton(
          context: context,
          text: 'Отмена',
          onPressed: () => Navigator.pop(context, false),
        ),
        CustomDialogActions.primaryButton(
          context: context,
          text: 'Продолжить',
          onPressed: () => Navigator.pop(context, true),
        ),
      ],
      showCloseButton: true,
    );

    if (shouldProceed != true || !mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Открываем OneID в браузере
      // В реальном приложении здесь будет URL для OneID авторизации
      final oneIdUrl = Uri.parse('https://my.oneid.uz/');
      
      if (await canLaunchUrl(oneIdUrl)) {
        final launched = await launchUrl(
          oneIdUrl,
          mode: LaunchMode.externalApplication,
        );

        if (!mounted) return;

        if (launched) {
          // Имитация успешной авторизации через OneID
          // В реальном приложении здесь будет обработка callback от OneID
          await Future.delayed(const Duration(seconds: 2));
          
          if (!mounted) return;

          setState(() {
            _isLoading = false;
          });

          // Показываем успешное сообщение
          CustomSnackBar.success(
            context: this.context,
            message: 'Регистрация через OneID успешно завершена',
          );

          // Переходим на главный экран
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) {
              Navigator.of(this.context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) => const MainScreen(),
                ),
                (route) => false,
              );
            }
          });
        }
      } else {
        if (!mounted) return;
        
        setState(() {
          _isLoading = false;
        });
        CustomSnackBar.error(
          context: this.context,
          message: 'Не удалось открыть OneID',
        );
      }
    } catch (e) {
      if (!mounted) return;
      
      setState(() {
        _isLoading = false;
      });
      CustomSnackBar.error(
        context: this.context,
        message: 'Произошла ошибка при открытии OneID',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF030712),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          context.l10n.translate('register'),
          style: const TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // OneID Registration button
              _buildOneIDButton(context),
              const SizedBox(height: 16),
              // Self Registration button
              _buildSelfRegistrationButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOneIDButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : () => _handleOneIDRegistration(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFFD700),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0A0E27)),
                ),
              )
            : Text(
                context.l10n.translate('oneid_registration'),
                style: const TextStyle(
                  color: Color(0xFF0A0E27),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Widget _buildSelfRegistrationButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const SelfRegistrationScreen(),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1A1F3A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: Text(
          context.l10n.translate('self_registration'),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
