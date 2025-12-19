import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/locale_provider.dart';
import '../utils/theme.dart';
import '../utils/localization_helper.dart';
import '../widgets/custom_dialog.dart';
import '../widgets/custom_snackbar.dart';
import 'delivery_addresses_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final Map<String, String> _languageMap = {
    // Основные языки приложения (с полной локализацией)
    'ru': 'Русский',
    'en': 'English',
    'uz': 'O\'zbekcha',
    // Дополнительные языки (поддержка Flutter Material)
  };

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
          onPressed: () => Navigator.pop(context),
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
                // TODO: Navigate to change password screen
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
              Icon(
                icon,
                color: AppTheme.gold, // Желтая/золотая иконка
                size: 24,
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
                color: Colors.white,
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
    final cardColor = isDark ? AppTheme.darkCard : AppTheme.lightCard;
    
    return Row(
      children: [
        Expanded(
          child: _buildSocialButton(
            icon: Icons.facebook_outlined,
            iconColor: const Color(0xFF1DA1F2), // Светло-синий контур Facebook
            backgroundColor: cardColor,
            onTap: () {
              // TODO: Open Facebook
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSocialButton(
            icon: Icons.camera_alt_outlined,
            iconColor: const Color(0xFFE4405F), // Розовый контур Instagram
            backgroundColor: cardColor,
            onTap: () {
              // TODO: Open Instagram
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSocialButton(
            icon: Icons.alternate_email,
            iconColor: const Color(0xFF1DA1F2), // Светло-синий контур Twitter
            backgroundColor: cardColor,
            onTap: () {
              // TODO: Open Twitter
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required Color iconColor,
    required Color backgroundColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Icon(
            icon,
            color: iconColor,
            size: 28,
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () {
          _showLogoutDialog();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF8B4513), // Красно-коричневый цвет
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.exit_to_app_outlined, // Контурная иконка выхода
              color: const Color(0xFFFF6B6B), // Светло-красный цвет иконки
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              context.l10n.translate('logout'),
              style: const TextStyle(
                color: Color(0xFFFF6B6B), // Светло-красный цвет текста
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
        const SizedBox(width: 8),
        CustomDialogActions.primaryButton(
          context: context,
          text: context.l10n.translate('logout'),
          onPressed: () {
            Navigator.pop(context);
            // TODO: Implement logout logic
            CustomSnackBar.success(
              context: context,
              message: context.l10n.translate('logged_out'),
            );
          },
          backgroundColor: const Color(0xFFDC3545),
        ),
      ],
    );
  }
}
