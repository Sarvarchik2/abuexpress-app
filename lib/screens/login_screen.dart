import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/theme_helper.dart';
import '../utils/theme.dart' show AppTheme;
import '../utils/localization_helper.dart';
import '../widgets/custom_snackbar.dart';
import '../services/api_service.dart';
import '../models/api/login_request.dart';
import '../providers/user_provider.dart';
import 'main_screen.dart';
// import 'registration_choice_screen.dart';
import 'self_registration_screen.dart';
import 'forgot_password_screen.dart';
import '../services/notification_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _apiService = ApiService();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = ThemeHelper.getBackgroundColor(context);
    final textColor = ThemeHelper.getTextColor(context);
    
    String loginTitle;
    try {
      loginTitle = context.l10n.translate('login');
    } catch (e) {
      debugPrint('Localization error in LoginScreen: $e');
      loginTitle = 'Вход';
    }
    
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Custom AppBar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: textColor),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Text(
                      loginTitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48), // Balance for back button
                ],
              ),
            ),
            // Scrollable content
            Expanded(
              child: GestureDetector(
                onTap: () {
                  // Убираем фокус с полей при нажатии вне их
                  FocusScope.of(context).unfocus();
                },
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 20),
                    // Email field
                    _buildTextField(
                      label: context.l10n.translate('email'),
                      controller: _emailController,
                      icon: Icons.email_outlined,
                      hint: 'example@email.com',
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 24),
                    // Password field
                    _buildPasswordField(),
                    const SizedBox(height: 16),
                    // Forgot password link
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ForgotPasswordScreen(),
                            ),
                          );
                        },
                        child: Text(
                          context.l10n.translate('forgot_password'),
                          style: const TextStyle(
                            color: Color(0xFF4A90E2),
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Login button
                    _buildLoginButton(),
                    const SizedBox(height: 40),
                    // Register link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${context.l10n.translate('no_account')} ',
                          style: TextStyle(
                            color: ThemeHelper.getTextColor(context),
                            fontSize: 14,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const SelfRegistrationScreen(),
                              ),
                            );
                          },
                          child: Text(
                            context.l10n.translate('register_here'),
                            style: const TextStyle(
                              color: Color(0xFF4A90E2),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
                ),
              ),
            ),
          ],
      ),
    ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    IconData? icon,
    String? hint,
    TextInputType? keyboardType,
  }) {
    final textColor = ThemeHelper.getTextColor(context);
    final textSecondaryColor = ThemeHelper.getTextSecondaryColor(context);
    final cardColor = ThemeHelper.getCardColor(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: textColor,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Material(
          color: Colors.transparent,
          child: TextField(
          controller: controller,
          keyboardType: keyboardType,
          enabled: true,
            readOnly: false,
            autofocus: false,
          style: TextStyle(color: textColor),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: textSecondaryColor,
              fontSize: 14,
            ),
            prefixIcon: icon != null
                ? Icon(
                    icon,
                    color: textSecondaryColor,
                    size: 20,
                  )
                : null,
            filled: true,
            fillColor: cardColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    final textColor = ThemeHelper.getTextColor(context);
    final textSecondaryColor = ThemeHelper.getTextSecondaryColor(context);
    final cardColor = ThemeHelper.getCardColor(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.translate('password'),
          style: TextStyle(
            color: textColor,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Material(
          color: Colors.transparent,
          child: TextField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          enabled: true,
            readOnly: false,
            autofocus: false,
          style: TextStyle(color: textColor),
          decoration: InputDecoration(
            hintText: '••••••••',
            hintStyle: TextStyle(
              color: textSecondaryColor,
              fontSize: 14,
            ),
            prefixIcon: Icon(
              Icons.lock_outlined,
              color: textSecondaryColor,
              size: 20,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: textSecondaryColor,
                size: 20,
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
            filled: true,
            fillColor: cardColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleLogin() async {
    // Проверяем, что поля не пустые
    if (_emailController.text.trim().isEmpty || _passwordController.text.trim().isEmpty) {
      CustomSnackBar.warning(
        context: context,
        message: context.l10n.translate('fill_all_fields'),
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

    try {
      final request = LoginRequest(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      final response = await _apiService.login(request);

      if (!mounted) return;

      // Успешный вход
      debugPrint('=== LOGIN SUCCESS IN SCREEN ===');
      debugPrint('Login successful');
      debugPrint('Email: ${response.email ?? _emailController.text.trim()}');
      debugPrint('Access Token: ${response.accessToken != null ? "${response.accessToken!.substring(0, 20)}..." : "null"}');
      
      if (!mounted) {
        debugPrint('Widget not mounted, cannot show snackbar or navigate');
        return;
      }

      // Загружаем информацию о пользователе
      try {
        if (!mounted) return;
        
        try {
          final userProvider = Provider.of<UserProvider>(context, listen: false);
          
          // Сохраняем токен в UserProvider
          if (response.accessToken != null) {
            userProvider.setAuthToken(response.accessToken);
            _apiService.setAuthToken(response.accessToken);
            debugPrint('=== AUTH TOKEN SAVED TO PROVIDER ===');
          }
          
          debugPrint('=== LOADING USER INFO ===');
          final userInfo = await _apiService.getMe();
          
          if (!mounted) return;
          
          debugPrint('=== USER INFO LOADED ===');
          debugPrint('Full Name: ${userInfo.fullName}');
          debugPrint('Email: ${userInfo.email}');
          debugPrint('Phone: ${userInfo.phoneNumber}');
          
          if (mounted) {
            userProvider.setUserInfo(userInfo);
            debugPrint('=== USER INFO SAVED TO PROVIDER ===');
          }
        } on ProviderNotFoundException catch (e) {
          debugPrint('=== PROVIDER NOT FOUND ===');
          debugPrint('Error: $e');
          debugPrint('UserProvider not available in context, skipping user info loading');
        } catch (e, stackTrace) {
          debugPrint('=== ERROR LOADING USER INFO ===');
          debugPrint('Error: $e');
          debugPrint('Stack Trace: $stackTrace');
          // Продолжаем даже если не удалось загрузить информацию о пользователе
        }
      } catch (e, stackTrace) {
        debugPrint('=== OUTER ERROR IN USER INFO LOADING ===');
        debugPrint('Error: $e');
        debugPrint('Stack Trace: $stackTrace');
        // Продолжаем даже если произошла ошибка
      }

      if (!mounted) return;

      // Сбрасываем состояние загрузки
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }

      if (!mounted) return;

      try {
        CustomSnackBar.success(
          context: context,
          message: 'Вход выполнен успешно',
        );
      } catch (e) {
        debugPrint('=== ERROR SHOWING SNACKBAR ===');
        debugPrint('Error: $e');
      }

      debugPrint('=== NAVIGATING TO MAIN SCREEN ===');
      
      // Синхронизируем FCM Token с бэкендом (убрали await, чтобы не задерживать переход в приложение!)
      try {
        debugPrint('=== SYNCING FCM TOKEN ===');
        NotificationService().syncToken();
      } catch (e) {
        debugPrint('Error syncing token: $e');
      }

      // Переходим на главный экран без задержки
      if (!mounted) {
        debugPrint('Widget not mounted, cannot navigate');
        return;
      }

      try {
        debugPrint('=== CALLING Navigator.pushAndRemoveUntil ===');
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const MainScreen(),
          ),
          (route) => false,
        );
        debugPrint('=== NAVIGATION COMPLETED ===');
      } catch (e, stackTrace) {
        debugPrint('=== NAVIGATION ERROR ===');
        debugPrint('Error: $e');
        debugPrint('Stack Trace: $stackTrace');
        if (mounted) {
          try {
            CustomSnackBar.error(
              context: context,
              message: 'Ошибка перехода: $e',
            );
          } catch (snackbarError) {
            debugPrint('=== ERROR SHOWING ERROR SNACKBAR ===');
            debugPrint('Error: $snackbarError');
          }
        }
      }
    } catch (e, stackTrace) {
      if (!mounted) return;

      debugPrint('=== LOGIN SCREEN ERROR ===');
      debugPrint('Error: $e');
      debugPrint('Stack Trace: $stackTrace');
      
      final errorMessage = e.toString().replaceFirst('Exception: ', '');
      
      CustomSnackBar.error(
        context: context,
        message: errorMessage,
      );

      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.gold,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: _isLoading
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    ThemeHelper.isDark(context) 
                        ? const Color(0xFF0A0E27) 
                        : const Color(0xFF030712),
                  ),
                ),
              )
            : Text(
                context.l10n.translate('enter'),
                style: TextStyle(
                  color: ThemeHelper.isDark(context) 
                      ? const Color(0xFF0A0E27) 
                      : const Color(0xFF030712),
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}
