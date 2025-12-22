import 'package:flutter/material.dart';
import '../utils/theme_helper.dart';
import '../utils/theme.dart' show AppTheme;
import '../utils/localization_helper.dart';
import '../widgets/custom_snackbar.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    if (_emailController.text.trim().isEmpty) {
      CustomSnackBar.error(
        context: context,
        message: 'Введите email адрес',
      );
      return;
    }

    // Валидация email
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(_emailController.text.trim())) {
      CustomSnackBar.error(
        context: context,
        message: 'Введите корректный email адрес',
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Имитация отправки запроса
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      CustomSnackBar.success(
        context: context,
        message: 'Инструкции по восстановлению пароля отправлены на ваш email',
      );

      // Возвращаемся назад через 2 секунды
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          Navigator.pop(context);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = ThemeHelper.getBackgroundColor(context);
    final textColor = ThemeHelper.getTextColor(context);
    final textSecondaryColor = ThemeHelper.getTextSecondaryColor(context);
    final cardColor = ThemeHelper.getCardColor(context);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          context.l10n.translate('forgot_password'),
          style: TextStyle(color: textColor),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              // Иконка
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppTheme.gold.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.lock_reset_rounded,
                    color: AppTheme.gold,
                    size: 40,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // Заголовок
              Text(
                'Восстановление пароля',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: textColor,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              // Описание
              Text(
                'Введите ваш email адрес, и мы отправим вам инструкции по восстановлению пароля',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: textSecondaryColor,
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 40),
              // Email поле
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _resetPassword(),
                style: TextStyle(color: textColor),
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(color: textSecondaryColor),
                  hintText: 'example@mail.com',
                  hintStyle: TextStyle(color: textSecondaryColor.withValues(alpha: 0.5)),
                  filled: true,
                  fillColor: cardColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppTheme.gold, width: 2),
                  ),
                  prefixIcon: const Icon(Icons.email_outlined, color: AppTheme.gold),
                ),
              ),
              const SizedBox(height: 32),
              // Кнопка отправки
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _resetPassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.gold,
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
                          'Отправить',
                          style: TextStyle(
                            color: ThemeHelper.isDark(context)
                                ? const Color(0xFF0A0E27)
                                : const Color(0xFF212121),
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

