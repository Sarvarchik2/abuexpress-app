import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/theme_helper.dart';
import '../utils/theme.dart' show AppTheme;
import '../utils/localization_helper.dart';
import '../widgets/custom_snackbar.dart';
import '../services/api_service.dart';
import 'main_screen.dart';
import '../providers/user_provider.dart';
import '../models/api/login_request.dart';
import '../models/api/user_registration.dart';
import 'login_screen.dart';
import '../services/notification_service.dart';

class EmailVerificationScreen extends StatefulWidget {
  final String email;
  final String? password; // Optional, for auto-login after verification
  final bool isResetPassword; // New flag for reset password flow
  final UserRegistration? registrationData; // Optional, to retry registration after verification

  const EmailVerificationScreen({
    super.key,
    required this.email,
    this.password,
    this.isResetPassword = false,
    this.registrationData,
  });

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  final _otpController = TextEditingController();
  final _apiService = ApiService();
  bool _isLoading = false;
  int _secondsRemaining = 60;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
    // Auto-send OTP on start? Usually done before navigation.
  }

  void _startTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        if (_secondsRemaining > 0) {
          setState(() {
            _secondsRemaining--;
          });
          _startTimer();
        } else {
          setState(() {
            _canResend = true;
          });
        }
      }
    });
  }

  Future<void> _resendCode() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _apiService.sendOtp(widget.email);
      CustomSnackBar.success(
        context: context,
        message: 'Код отправлен повторно',
      );
      setState(() {
        _secondsRemaining = 60;
        _canResend = false;
      });
      _startTimer();
    } catch (e) {
      CustomSnackBar.error(
        context: context,
        message: e.toString().replaceAll('Exception: ', ''),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _verifyCode() async {
    if (_otpController.text.length != 6) { 
       return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // STRATEGY: For registration flow, try to use resetPassword to verify OTP + set password
      // This handles the "User already exists (unverified)" case where verifyOtp doesn't update password.
      if (widget.registrationData != null) {
         try {
            debugPrint('=== ATTEMPTING PASS-THROUGH VERIFICATION (RESET) ===');
            await _apiService.resetPassword(
              widget.email, 
              _otpController.text, 
              widget.registrationData!.password
            );
            
            // If successful, the email is verified AND password is set.
            debugPrint('Pass-through verification success');
            
            // Proceed directly to login
            await _performAutoLogin(widget.registrationData!.password);
            return;
         } catch (e) {
            debugPrint('Pass-through verification failed: $e');
            // If the error is NOT 404 (endpoint missing), it might be "Invalid OTP".
            // If it is 404, we fall back to standard verifyOtp.
            if (!e.toString().contains('404') && !e.toString().contains('Функция сброса пароля временно недоступна')) {
               // Likely invalid OTP or similar
               throw e;
            }
         }
      }

      // Standard Verification Flow
      await _apiService.verifyOtp(widget.email, _otpController.text);
      
      CustomSnackBar.success(
        context: context,
        message: 'Email успешно подтвержден',
      );
      
      // Если это сброс пароля, показываем диалог ввода нового пароля
      if (widget.isResetPassword) {
        if (mounted) {
           _showResetPasswordDialog();
        }
        _isLoading = false; 
        return;
      }

      // Check if we need to retry registration (User provided "First email confirmed then registers" logic)
      if (widget.registrationData != null) {
         try {
           debugPrint('=== RETRYING REGISTRATION AFTER VERIFICATION ===');
           final regResponse = await _apiService.register(widget.registrationData!);
           debugPrint('Registration retry success: ${regResponse.accessToken}');
           // If registration returns token, use it
           if (regResponse.accessToken != null) {
              if (mounted) {
                _handleSuccessfulLogin(regResponse.accessToken!);
                return; // Exit function
              }
           }
         } catch (e) {
            debugPrint('Registration retry failed: $e');
         } catch (e) {
            debugPrint('Registration retry failed: $e');
            
            if (e.toString().contains('Email already exists') || e.toString().contains('already exists')) {
               CustomSnackBar.info(context: context, message: 'Email уже зарегистрирован. Пробуем войти...');
               // Proceed to auto-login below
            } else if (e.toString().contains('500')) {
                 CustomSnackBar.error(context: context, message: 'Ошибка регистрации: ${e.toString().replaceAll('Exception: ', '')}');
                  _isLoading = false;
                  return;
            }
         }
      }
      
      // Если у нас есть пароль, выполняем автоматический вход
      if (widget.password != null) {
        await _performAutoLogin(widget.password!);
        return;
      }
      
      // Default success navigation
      if (!mounted) return;
      CustomSnackBar.success(context: context, message: 'Email подтвержден. Пожалуйста, войдите.');
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );

    } catch (e) {
      CustomSnackBar.error(
        context: context,
        message: e.toString().contains('404') 
            ? 'Endpoint verification not found. Please contact support.' 
            : e.toString().replaceAll('Exception: ', ''),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _performAutoLogin(String password) async {
      try {
        debugPrint('=== AUTO LOGIN START ===');
        final loginResponse = await _apiService.login(LoginRequest(
          email: widget.email,
          password: password,
        ));
        
        if (loginResponse.accessToken != null) {
           _handleSuccessfulLogin(loginResponse.accessToken!);
           return;
        }
      } catch (e) {
        debugPrint('Auto login failed: $e');
        if (!mounted) return;
        
        String errorMessage = e.toString().replaceAll('Exception: ', '');
        if (errorMessage.contains('Invalid credentials') || errorMessage.contains('Неверный email или пароль')) {
           errorMessage = 'Аккаунт существует, но пароль не подходит. Пожалуйста, восстановите пароль или используйте другой Email.';
        }
        
        CustomSnackBar.error(
          context: context,
          message: 'Войти не удалось: $errorMessage',
        );
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
  }

  Future<void> _handleSuccessfulLogin(String token) async {
      if (!mounted) return;
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.setAuthToken(token);
      _apiService.setAuthToken(token);
      
      try {
        final userInfo = await _apiService.getMe();
        userProvider.setUserInfo(userInfo);
      } catch (e) {
        debugPrint('Error loading user info: $e');
      }

      // Синхронизируем токен для пуш уведомлений после успешной регистрации
      NotificationService().syncToken();

      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const MainScreen()),
        (route) => false,
      );
  }

  void _showResetPasswordDialog() {
    final passwordController = TextEditingController();
    final confirmController = TextEditingController();
    bool isLoading = false;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
          return Container(
            padding: EdgeInsets.only(
              left: 24, 
              right: 24, 
              top: 24, 
              bottom: 24 + keyboardHeight
            ),
            decoration: BoxDecoration(
              color: ThemeHelper.getBackgroundColor(context),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Новый пароль',
                  style: TextStyle(
                    fontSize: 20, 
                    fontWeight: FontWeight.bold,
                    color: ThemeHelper.getTextColor(context),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Введите новый пароль',
                    filled: true,
                    fillColor: ThemeHelper.getCardColor(context),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: confirmController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Повторите пароль',
                    filled: true,
                    fillColor: ThemeHelper.getCardColor(context),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : () async {
                      if (passwordController.text != confirmController.text) {
                        CustomSnackBar.error(context: context, message: 'Пароли не совпадают');
                        return;
                      }
                      if (passwordController.text.length < 6) {
                        CustomSnackBar.error(context: context, message: 'Пароль должен быть не менее 6 символов');
                        return;
                      }

                      setModalState(() => isLoading = true);
                      
                      try {
                        await _apiService.resetPassword(
                          widget.email, 
                          _otpController.text, // Use the verified OTP
                          passwordController.text
                        );
                        
                        if (!mounted) return;
                        
                        Navigator.pop(context); // Close sheet
                        
                        CustomSnackBar.success(context: context, message: 'Пароль успешно изменен');
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (context) => const LoginScreen()),
                          (route) => false,
                        );
                      } catch (e) {
                         setModalState(() => isLoading = false);
                         CustomSnackBar.error(
                           context: context, 
                           message: e.toString().replaceAll('Exception: ', '')
                         );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.gold,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: isLoading 
                       ? const CircularProgressIndicator()
                       : const Text('Сохранить', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          );
        }
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = ThemeHelper.getBackgroundColor(context);
    final textColor = ThemeHelper.getTextColor(context);
    final textSecondaryColor = ThemeHelper.getTextSecondaryColor(context);
    
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              Icon(
                Icons.mark_email_read_outlined,
                size: 80,
                color: AppTheme.gold,
              ),
              const SizedBox(height: 32),
              Text(
                'Подтверждение Email',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: textColor,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Мы отправили код подтверждения на\n${widget.email}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: textSecondaryColor,
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 48),
              
              // OTP Input
              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24, 
                  fontWeight: FontWeight.bold, 
                  color: textColor,
                  letterSpacing: 8,
                ),
                decoration: InputDecoration(
                  hintText: '------',
                  hintStyle: TextStyle(
                    color: textSecondaryColor.withValues(alpha: 0.3),
                    letterSpacing: 8,
                  ),
                  filled: true,
                  fillColor: ThemeHelper.getCardColor(context),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppTheme.gold, width: 2),
                  ),
                  counterText: '',
                ),
                onSubmitted: (_) => _verifyCode(),
              ),
              
              const SizedBox(height: 40),
              
              // Verify Button
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _verifyCode,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.gold,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text(
                          'Подтвердить',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black, // Assuming default button text color
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Resend Timer
              Center(
                child: _canResend
                    ? TextButton(
                        onPressed: _resendCode,
                        child: const Text(
                          'Отправить код повторно',
                          style: TextStyle(
                            color: AppTheme.gold,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      )
                    : Text(
                        'Отправить код повторно через $_secondsRemaining сек',
                        style: TextStyle(
                          color: textSecondaryColor,
                          fontSize: 14,
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
