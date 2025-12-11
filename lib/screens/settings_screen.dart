import 'package:flutter/material.dart';
import 'delivery_addresses_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _selectedLanguage = 'Русский';
  String _selectedTheme = 'Тёмная';

  final List<String> _languages = ['Русский', 'English', 'O\'zbekcha'];
  final List<String> _themes = ['Тёмная', 'Светлая'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Настройки',
          style: TextStyle(color: Colors.white),
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
              'Язык интерфейса',
              Icons.language,
            ),
            const SizedBox(height: 12),
            _buildLanguageSection(),
            const SizedBox(height: 32),
            // Theme Section
            _buildSectionHeader(
              'Тема оформления',
              Icons.palette_outlined,
            ),
            const SizedBox(height: 12),
            _buildThemeSection(),
            const SizedBox(height: 32),
            // Delivery Addresses
            _buildNavigationItem(
              icon: Icons.location_on_outlined,
              title: 'Адреса доставки',
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
              title: 'Изменить пароль',
              onTap: () {
                // TODO: Navigate to change password screen
              },
            ),
            const SizedBox(height: 32),
            // Social Networks Section
            _buildSectionHeader(
              'Социальные сети',
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
    return Row(
      children: [
        Icon(
          icon,
          color: Colors.white54,
          size: 20,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildLanguageSection() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F3A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: _languages.map((language) {
          final isSelected = language == _selectedLanguage;
          return _buildSelectableItem(
            language,
            isSelected,
            () {
              setState(() {
                _selectedLanguage = language;
              });
            },
            showDivider: language != _languages.last,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildThemeSection() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F3A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: _themes.map((theme) {
          final isSelected = theme == _selectedTheme;
          return _buildSelectableItem(
            theme,
            isSelected,
            () {
              setState(() {
                _selectedTheme = theme;
              });
            },
            showDivider: theme != _themes.last,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSelectableItem(
    String title,
    bool isSelected,
    VoidCallback onTap, {
    bool showDivider = true,
  }) {
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
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
                if (isSelected)
                  Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFD700),
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
            color: Colors.white.withOpacity(0.1),
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
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F3A),
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
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: Colors.white54,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSocialNetworksSection() {
    return Row(
      children: [
        Expanded(
          child: _buildSocialButton(
            icon: Icons.facebook,
            color: const Color(0xFF1877F2),
            onTap: () {
              // TODO: Open Facebook
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSocialButton(
            icon: Icons.camera_alt_outlined,
            color: const Color(0xFFE4405F),
            onTap: () {
              // TODO: Open Instagram
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSocialButton(
            icon: Icons.alternate_email,
            color: const Color(0xFF1DA1F2),
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
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 28,
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
          backgroundColor: const Color(0xFFDC3545),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(
              Icons.logout,
              color: Colors.white,
              size: 20,
            ),
            SizedBox(width: 8),
            Text(
              'Выйти из аккаунта',
              style: TextStyle(
                color: Colors.white,
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1F3A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Выйти из аккаунта?',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          'Вы уверены, что хотите выйти из аккаунта?',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Отмена',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement logout logic
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Вы вышли из аккаунта'),
                  backgroundColor: Color(0xFFFFD700),
                ),
              );
            },
            child: const Text(
              'Выйти',
              style: TextStyle(
                color: Color(0xFFDC3545),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
