import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../widgets/bottom_navigation_bar.dart';
import '../utils/theme_helper.dart';
import '../utils/theme.dart' show AppTheme;

class AddressesScreen extends StatefulWidget {
  final int currentIndex;
  final Function(int) onNavTap;
  
  const AddressesScreen({
    super.key,
    required this.currentIndex,
    required this.onNavTap,
  });

  @override
  State<AddressesScreen> createState() => _AddressesScreenState();
}

class _AddressesScreenState extends State<AddressesScreen> {
  String _selectedCountry = 'USA';

  final Map<String, OfficeAddress> _addresses = {
    'USA': OfficeAddress(
      country: 'США',
      state: 'Штат DE',
      address: 'Room 501, Building A, 123 Huaqiang',
      id: '107923406',
      city: 'New York',
      zip: '10700',
      phone: '+86 755 1234 5678',
      workingHours: 'Пн-Сб: 8:00 - 20:00',
    ),
    'Turkey': OfficeAddress(
      country: 'Турция',
      state: 'Стамбул',
      address: 'Atatürk Mahallesi, İnönü Caddesi, No: 45',
      id: '108234567',
      city: 'Istanbul',
      zip: '34000',
      phone: '+90 212 555 1234',
      workingHours: 'Пн-Сб: 9:00 - 19:00',
    ),
  };

  @override
  Widget build(BuildContext context) {
    final address = _addresses[_selectedCountry]!;
    final backgroundColor = ThemeHelper.getBackgroundColor(context);
    final textColor = ThemeHelper.getTextColor(context);
    
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Text(
                          'Адреса офисов',
                          style: TextStyle(
                            color: textColor,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Используйте эти адреса при заказе товаров в интернет-магазинах',
                          style: TextStyle(
                            color: AppTheme.gold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Country selection
                        Row(
                          children: [
                            Expanded(
                              child: _buildCountryButton(
                                'USA',
                                'США',
                                Icons.flag,
                                _selectedCountry == 'USA',
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildCountryButton(
                                'Turkey',
                                'Турция',
                                Icons.flag,
                                _selectedCountry == 'Turkey',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // Address card
                        _buildAddressCard(address),
                        // Spacer для навигации
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Навигация прикреплена к низу
          CustomBottomNavigationBar(
            currentIndex: widget.currentIndex,
            onTap: widget.onNavTap,
          ),
        ],
      ),
    );
  }

  Widget _buildCountryButton(
    String countryCode,
    String countryName,
    IconData icon,
    bool isSelected,
  ) {
    final cardColor = ThemeHelper.getCardColor(context);
    final textColor = ThemeHelper.getTextColor(context);
    final textSecondaryColor = ThemeHelper.getTextSecondaryColor(context);
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCountry = countryCode;
        });
      },
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.gold.withValues(alpha: 0.3)
              : cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppTheme.gold
                : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Flag icon in circle
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: textSecondaryColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  countryCode == 'USA' ? '🇺🇸' : '🇹🇷',
                  style: const TextStyle(fontSize: 28),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              countryName,
              style: TextStyle(
                color: isSelected
                    ? AppTheme.gold
                    : textColor,
                fontSize: 16,
                fontWeight: isSelected
                    ? FontWeight.w600
                    : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressCard(OfficeAddress address) {
    final cardColor = ThemeHelper.getCardColor(context);
    final textColor = ThemeHelper.getTextColor(context);
    final textSecondaryColor = ThemeHelper.getTextSecondaryColor(context);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with country name and warehouse button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      address.country,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      address.state,
                      style: TextStyle(
                        color: textSecondaryColor,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF1877F2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Склад',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Address line
          _buildAddressLine(
            Icons.location_on_outlined,
            address.address,
          ),
          const SizedBox(height: 16),
          // ID line
          _buildAddressLine(
            Icons.location_on_outlined,
            'ID ${address.id}',
          ),
          const SizedBox(height: 16),
          // City line
          _buildAddressLine(
            Icons.business_outlined,
            'Город - ${address.city}',
          ),
          const SizedBox(height: 16),
          // ZIP line
          _buildAddressLine(
            Icons.label_outline,
            'ZIP - ${address.zip}',
          ),
          const SizedBox(height: 16),
          Divider(
            height: 1,
            thickness: 1,
            color: textSecondaryColor.withValues(alpha: 0.15),
          ),
          const SizedBox(height: 16),
          // Phone line
          _buildAddressLine(
            Icons.phone_outlined,
            address.phone,
          ),
          const SizedBox(height: 16),
          // Working hours line
          _buildAddressLine(
            Icons.access_time_outlined,
            address.workingHours,
          ),
        ],
      ),
    );
  }

  Widget _buildAddressLine(IconData icon, String text) {
    final textColor = ThemeHelper.getTextColor(context);
    final textSecondaryColor = ThemeHelper.getTextSecondaryColor(context);
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: textSecondaryColor,
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: textColor,
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () {
            Clipboard.setData(ClipboardData(text: text));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Скопировано в буфер обмена'),
                backgroundColor: AppTheme.gold,
                duration: Duration(seconds: 1),
              ),
            );
          },
          child: Container(
            width: 24,
            height: 24,
            padding: const EdgeInsets.all(4),
            child: SvgPicture.asset(
              'assets/icon/Copy.svg',
              colorFilter: ColorFilter.mode(
                textSecondaryColor,
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class OfficeAddress {
  final String country;
  final String state;
  final String address;
  final String id;
  final String city;
  final String zip;
  final String phone;
  final String workingHours;

  OfficeAddress({
    required this.country,
    required this.state,
    required this.address,
    required this.id,
    required this.city,
    required this.zip,
    required this.phone,
    required this.workingHours,
  });
}
