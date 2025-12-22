import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../utils/theme_helper.dart';
import '../utils/theme.dart' show AppTheme;
import '../utils/localization_helper.dart';
import '../widgets/custom_snackbar.dart';
import 'main_screen.dart';

class SelfRegistrationScreen extends StatefulWidget {
  const SelfRegistrationScreen({super.key});

  @override
  State<SelfRegistrationScreen> createState() => _SelfRegistrationScreenState();
}

class _SelfRegistrationScreenState extends State<SelfRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passportSeriesController = TextEditingController();
  final _passportNumberController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  final ImagePicker _picker = ImagePicker();
  File? _frontPassportImage;
  File? _backPassportImage;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isRegistering = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passportSeriesController.dispose();
    _passportNumberController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(bool isFront) async {
    final cardColor = ThemeHelper.getCardColor(context);
    final textColor = ThemeHelper.getTextColor(context);
    
    showModalBottomSheet(
      context: context,
      backgroundColor: cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.camera_alt, color: textColor),
              title: Text(
                context.l10n.translate('take_photo'),
                style: TextStyle(color: textColor),
              ),
              onTap: () async {
                Navigator.pop(context);
                final XFile? image = await _picker.pickImage(source: ImageSource.camera);
                if (image != null) {
                  setState(() {
                    if (isFront) {
                      _frontPassportImage = File(image.path);
                    } else {
                      _backPassportImage = File(image.path);
                    }
                  });
                }
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library, color: textColor),
              title: Text(
                context.l10n.translate('choose_from_gallery'),
                style: TextStyle(color: textColor),
              ),
              onTap: () async {
                Navigator.pop(context);
                final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
                if (image != null) {
                  setState(() {
                    if (isFront) {
                      _frontPassportImage = File(image.path);
                    } else {
                      _backPassportImage = File(image.path);
                    }
                  });
                }
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = ThemeHelper.getBackgroundColor(context);
    final textColor = ThemeHelper.getTextColor(context);
    
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
          context.l10n.translate('register'),
          style: TextStyle(color: textColor),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Full Name field
                _buildTextField(
                  label: context.l10n.translate('recipient_name'),
                  controller: _fullNameController,
                  icon: Icons.person_outlined,
                  hint: context.l10n.translate('enter_full_name'),
                ),
                const SizedBox(height: 20),
                // Email field
                _buildTextField(
                  label: context.l10n.translate('email'),
                  controller: _emailController,
                  icon: Icons.email_outlined,
                  hint: 'example@email.com',
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 20),
                // Phone field
                _buildTextField(
                  label: context.l10n.translate('phone_number'),
                  controller: _phoneController,
                  icon: Icons.phone_outlined,
                  hint: '+998 90 123 45 67',
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 20),
                // Passport Series field
                _buildTextField(
                  label: context.l10n.translate('passport_series'),
                  controller: _passportSeriesController,
                  icon: Icons.credit_card_outlined,
                  hint: 'AA',
                ),
                const SizedBox(height: 20),
                // Passport Number field
                _buildTextField(
                  label: context.l10n.translate('passport_number'),
                  controller: _passportNumberController,
                  icon: Icons.credit_card_outlined,
                  hint: '1234567',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 24),
                // Passport Front Image
                _buildImageUpload(
                  label: context.l10n.translate('passport_front'),
                  image: _frontPassportImage,
                  onTap: () => _pickImage(true),
                ),
                const SizedBox(height: 16),
                // Passport Back Image
                _buildImageUpload(
                  label: context.l10n.translate('passport_back'),
                  image: _backPassportImage,
                  onTap: () => _pickImage(false),
                ),
                const SizedBox(height: 20),
                // Password field
                _buildPasswordField(
                  label: context.l10n.translate('password'),
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  onToggle: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
                const SizedBox(height: 20),
                // Confirm Password field
                _buildPasswordField(
                  label: context.l10n.translate('confirm_password'),
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  onToggle: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                ),
                const SizedBox(height: 32),
                // Register button
                _buildRegisterButton(),
                const SizedBox(height: 20),
              ],
            ),
          ),
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
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
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
      ],
    );
  }

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required bool obscureText,
    required VoidCallback onToggle,
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
        TextFormField(
          controller: controller,
          obscureText: obscureText,
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
                obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                color: textSecondaryColor,
                size: 20,
              ),
              onPressed: onToggle,
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
      ],
    );
  }

  Widget _buildImageUpload({
    required String label,
    required File? image,
    required VoidCallback onTap,
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
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            height: 150,
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: textSecondaryColor.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: image == null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.camera_alt_outlined,
                        color: textSecondaryColor,
                        size: 40,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        context.l10n.translate('click_to_upload'),
                        style: TextStyle(
                          color: textSecondaryColor,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  )
                : Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          image,
                          width: double.infinity,
                          height: 150,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.6),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
        if (image != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: TextButton(
              onPressed: () {
                setState(() {
                  if (label.contains('лицевая')) {
                    _frontPassportImage = null;
                  } else {
                    _backPassportImage = null;
                  }
                });
              },
              child: Text(
                context.l10n.translate('delete_photo'),
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 12,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _registerUser() async {
    if (_isRegistering) return;

    setState(() {
      _isRegistering = true;
    });

    try {
      // Собираем данные для регистрации
      final registrationData = {
        'fullName': _fullNameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'passportSeries': _passportSeriesController.text.trim(),
        'passportNumber': _passportNumberController.text.trim(),
        'password': _passwordController.text,
        'frontPassportImage': _frontPassportImage?.path,
        'backPassportImage': _backPassportImage?.path,
      };

      // Имитация отправки данных на сервер
      // В реальном приложении здесь будет API вызов
      debugPrint('Registration data: ${registrationData.keys.join(', ')}');
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;

      // Имитация успешной регистрации
      // В реальном приложении здесь будет проверка ответа от сервера
      CustomSnackBar.success(
        context: context,
        message: 'Регистрация успешно завершена',
      );

      // Переходим на главный экран через небольшую задержку
      await Future.delayed(const Duration(seconds: 1));

      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const MainScreen(),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      debugPrint('Registration error: $e');
      CustomSnackBar.error(
        context: context,
        message: 'Произошла ошибка при регистрации. Попробуйте еще раз.',
      );

      setState(() {
        _isRegistering = false;
      });
    }
  }

  Widget _buildRegisterButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isRegistering
            ? null
            : () {
                if (_formKey.currentState!.validate()) {
                    if (_frontPassportImage == null || _backPassportImage == null) {
                    CustomSnackBar.error(
                      context: context,
                      message: context.l10n.translate('upload_both_sides'),
                    );
                    return;
                  }
                  if (_passwordController.text != _confirmPasswordController.text) {
                    CustomSnackBar.error(
                      context: context,
                      message: context.l10n.translate('passwords_dont_match'),
                    );
                    return;
                  }
                  _registerUser();
                }
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.gold,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: _isRegistering
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    ThemeHelper.isDark(context) ? const Color(0xFF0A0E27) : const Color(0xFF212121),
                  ),
                ),
              )
            : Text(
                context.l10n.translate('register_button'),
                style: TextStyle(
                  color: ThemeHelper.isDark(context) ? const Color(0xFF0A0E27) : const Color(0xFF212121),
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}
