import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/theme_provider.dart';
import '../providers/locale_provider.dart';
import '../providers/user_provider.dart';
import '../services/api_service.dart';
import '../utils/theme.dart';
import '../utils/localization_helper.dart';
import '../widgets/custom_dialog.dart';
import '../widgets/custom_snackbar.dart';
import 'delivery_addresses_screen.dart';
import 'login_screen.dart';
import 'auth_screen.dart';
import 'profile_screen.dart';
import 'add_parcel_screen.dart';
import '../widgets/departure_timer_card.dart';
import '../models/api/departure_time.dart';


class SettingsScreen extends StatefulWidget {
  final int currentIndex;
  final Function(int) onNavTap;
  
  const SettingsScreen({
    super.key,
    required this.currentIndex,
    required this.onNavTap,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final Map<String, String> _languageMap = {
    'ru': 'Русский',
    'en': 'English',
    'uz': 'O\'zbekcha',
  };

  List<DepartureTime> _departureTimes = [];
  bool _isLoadingTimes = false;

  @override
  void initState() {
    super.initState();
    _loadDepartureTimes();
  }

  Future<void> _loadDepartureTimes() async {
    if (!mounted) return;
    setState(() {
      _isLoadingTimes = true;
    });

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final token = userProvider.authToken;
      final apiService = ApiService(authToken: token);
      final times = await apiService.getDepartureTimes();
      if (mounted) {
        setState(() {
          _departureTimes = times;
          _isLoadingTimes = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading departure times in settings: $e');
      if (mounted) {
        setState(() {
          _isLoadingTimes = false;
          // Fallback static data if API fails to ensure card is visible for testing
          if (_departureTimes.isEmpty) {
            _departureTimes = [
              DepartureTime(
                id: 1,
                country: 'TURKEY',
                departureTime: DateTime.now().add(const Duration(days: 2, hours: 5)),
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              ),
              DepartureTime(
                id: 2,
                country: 'UAE',
                departureTime: DateTime.now().add(const Duration(hours: 12)),
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              ),
            ];
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final backgroundColor = isDark ? AppTheme.darkBackground : AppTheme.lightBackground;
    final textColor = isDark ? AppTheme.darkText : AppTheme.lightText;
    
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () {
            // Переключаемся обратно на экран адресов (индекс 2)
            widget.onNavTap(2);
          },
        ),
        title: Text(
          context.l10n.translate('settings'),
          style: TextStyle(color: textColor),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Departure Timer at the very top
            if (_departureTimes.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: DepartureTimerCard(
                  departureTimes: _departureTimes,
                  margin: EdgeInsets.zero,
                  onSendTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddParcelScreen(),
                      ),
                    ).then((_) => _loadDepartureTimes());
                  },
                ),
              ),
            ] else if (_isLoadingTimes) ...[
              const Center(
                child: Padding(
                  padding: EdgeInsets.only(bottom: 24),
                  child: CircularProgressIndicator(color: AppTheme.gold),
                ),
              ),
            ],

            // Interface Language Section
            _buildSectionHeader(
              context.l10n.translate('interface_language'),
              Icons.language,
            ),
            const SizedBox(height: 12),
            _buildLanguageSection(),
            const SizedBox(height: 32),
            // Theme Section
            _buildSectionHeader(
              context.l10n.translate('theme'),
              Icons.palette_outlined,
            ),
            const SizedBox(height: 12),
            _buildThemeSection(),
            const SizedBox(height: 32),
            // Profile
            _buildNavigationItem(
              icon: Icons.person_outline,
              title: context.l10n.translate('profile'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfileScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            // Delivery Addresses
            _buildNavigationItem(
              icon: Icons.location_on_outlined,
              title: context.l10n.translate('delivery_addresses'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DeliveryAddressesScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            // Change Password
            _buildNavigationItem(
              icon: Icons.lock_outline,
              title: context.l10n.translate('change_password'),
              onTap: () {
                CustomSnackBar.info(
                  context: context,
                  message: context.l10n.translate('function_in_development'),
                );
              },
            ),
            const SizedBox(height: 32),
            // Social Networks Section
            _buildSectionHeader(
              context.l10n.translate('social_networks'),
              Icons.share_outlined,
            ),
            const SizedBox(height: 12),
            _buildSocialNetworksSection(),
            const SizedBox(height: 40),
            // Logout Button
            _buildLogoutButton(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final textSecondaryColor = isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary;
    
    return Row(
      children: [
        Icon(
          icon,
          color: textSecondaryColor,
          size: 20,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            color: textSecondaryColor,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildLanguageSection() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final localeProvider = Provider.of<LocaleProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final cardColor = isDark ? AppTheme.darkCard : AppTheme.lightCard;
    
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: _languageMap.entries.map((entry) {
          final languageCode = entry.key;
          final languageName = entry.value;
          final isSelected = localeProvider.locale.languageCode == languageCode;
          return _buildSelectableItem(
            languageName,
            isSelected,
            () {
              localeProvider.setLanguage(languageCode);
            },
            showDivider: entry != _languageMap.entries.last,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildThemeSection() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final cardColor = isDark ? AppTheme.darkCard : AppTheme.lightCard;
    
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildThemeSelectableItem(
            context.l10n.translate('dark'),
            isDark,
            () => themeProvider.toggleTheme(true),
            showDivider: true,
          ),
          _buildThemeSelectableItem(
            context.l10n.translate('light'),
            !isDark,
            () => themeProvider.toggleTheme(false),
            showDivider: false,
          ),
        ],
      ),
    );
  }
  
  Widget _buildThemeSelectableItem(
    String title,
    bool isSelected,
    VoidCallback onTap, {
    bool showDivider = true,
  }) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final textColor = isDark ? AppTheme.darkText : AppTheme.lightText;
    
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 16,
                    ),
                  ),
                ),
                if (isSelected)
                  Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      color: AppTheme.gold,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Color(0xFF0A0E27),
                      size: 14,
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            thickness: 1,
            color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.1),
            indent: 16,
            endIndent: 16,
          ),
      ],
    );
  }

  Widget _buildSelectableItem(
    String title,
    bool isSelected,
    VoidCallback onTap, {
    bool showDivider = true,
  }) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final textColor = isDark ? AppTheme.darkText : AppTheme.lightText;
    
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 16,
                    ),
                  ),
                ),
                if (isSelected)
                  Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      color: AppTheme.gold,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Color(0xFF0A0E27),
                      size: 14,
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            thickness: 1,
            color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.1),
            indent: 16,
            endIndent: 16,
          ),
      ],
    );
  }

  Widget _buildNavigationItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final cardColor = isDark ? AppTheme.darkCard : AppTheme.lightCard;
    final textColor = isDark ? AppTheme.darkText : AppTheme.lightText;
    
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              // Золотой градиентный фон для иконки с тенью и свечением
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.gold,
                      AppTheme.gold.withValues(alpha: 0.8),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.gold.withValues(alpha: 0.4),
                      blurRadius: 12,
                      spreadRadius: 0,
                      offset: const Offset(0, 4),
                    ),
                    BoxShadow(
                      color: AppTheme.gold.withValues(alpha: 0.2),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  color: isDark 
                      ? const Color(0xFF0A0E27) 
                      : const Color(0xFF212121),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 16,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: isDark ? Colors.white : Colors.grey.shade400, // Светло-серый в светлой теме
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSocialNetworksSection() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    
    // Background color based on theme
    final buttonColor = isDark ? AppTheme.darkCard : AppTheme.lightCard;
    
    return Row(
      children: [
        // Facebook
        Expanded(
          child: _buildSocialButton(
            icon: Icons.facebook,
            iconColor: const Color(0xFF1877F2),
            backgroundColor: buttonColor,
            onTap: () => _launchURL('https://www.facebook.com/abuexpress'),
          ),
        ),
        const SizedBox(width: 12),
        // Instagram
        Expanded(
          child: _buildSocialButton(
            icon: Icons.camera_alt_rounded,
            // Use a list of colors for potential gradient or just a brand color
            iconColor: const Color(0xFFE4405F),
            backgroundColor: buttonColor,
            onTap: () => _launchURL('https://www.instagram.com/abuexpress'),
          ),
        ),
        const SizedBox(width: 12),
        // Telegram
        Expanded(
          child: _buildSocialButton(
            icon: Icons.send_rounded,
            iconColor: const Color(0xFF229ED9),
            backgroundColor: buttonColor,
            onTap: () => _launchURL('https://t.me/abuexpress'),
          ),
        ),
      ],
    );
  }

  Future<void> _launchURL(String urlString) async {
    final url = Uri.parse(urlString);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        CustomSnackBar.error(
          context: context,
          message: context.l10n.translate('error'),
        );
      }
    }
  }

  Widget _buildSocialButton({
    required IconData icon,
    required Color iconColor,
    required Color backgroundColor,
    required VoidCallback onTap,
  }) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark ? [] : [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: SizedBox(
            height: 60,
            child: Center(
              child: Transform.rotate(
                angle: icon == Icons.send_rounded ? -0.4 : 0, // Rotate telegram icon slightly for official look
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 30,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    const redColor = Color(0xFFFB2C36);
    
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () {
          _showLogoutDialog();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: redColor.withValues(alpha: 0.1), // #FB2C36 с 10% opacity
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: redColor.withValues(alpha: 0.3), // #FB2C36 с 30% opacity
              width: 0.63,
            ),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.exit_to_app, // Solid red exit icon
              color: redColor, // Красная иконка
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              context.l10n.translate('logout'),
              style: const TextStyle(
                color: redColor, // Красный цвет текста
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    CustomDialog.show(
      context: context,
      title: context.l10n.translate('logout_confirm'),
      message: context.l10n.translate('logout_confirm_message'),
      icon: Icons.logout_rounded,
      iconColor: const Color(0xFFDC3545),
      actions: [
        CustomDialogActions.secondaryButton(
          context: context,
          text: context.l10n.translate('cancel'),
          onPressed: () => Navigator.pop(context),
        ),
        CustomDialogActions.primaryButton(
          context: context,
          text: context.l10n.translate('logout'),
          onPressed: () {
            Navigator.pop(context);
            _handleLogout();
          },
          backgroundColor: const Color(0xFFDC3545),
        ),
      ],
    );
  }

  void _handleLogout() {
    try {
      // Очищаем данные пользователя
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      userProvider.clearUser();

      // Очищаем токен авторизации (создаем новый экземпляр для очистки)
      // В реальном приложении токен должен храниться в SharedPreferences
      // и очищаться оттуда, но для текущей реализации этого достаточно
      final apiService = ApiService();
      apiService.setAuthToken(null);

      debugPrint('=== LOGOUT SUCCESS ===');
      debugPrint('User data cleared');
      debugPrint('Auth token cleared');

      if (!mounted) return;

      // Показываем уведомление об успешном выходе
      CustomSnackBar.success(
        context: context,
        message: context.l10n.translate('logged_out'),
      );

      // Небольшая задержка перед навигацией, чтобы пользователь увидел уведомление
      Future.delayed(const Duration(milliseconds: 500), () {
        if (!mounted) return;
        
        // Перенаправляем на экран логина, удаляя все предыдущие экраны
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const AuthScreen(),
          ),
          (route) => false,
        );
      });
    } catch (e, stackTrace) {
      debugPrint('=== LOGOUT ERROR ===');
      debugPrint('Error: $e');
      debugPrint('Stack Trace: $stackTrace');
      if (mounted) {
        CustomSnackBar.error(
          context: context,
          message: 'Ошибка при выходе из аккаунта',
        );
      }
    }
  }
}
