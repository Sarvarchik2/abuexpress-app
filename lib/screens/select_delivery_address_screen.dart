import 'package:flutter/material.dart';
import '../utils/theme_helper.dart';
import '../utils/theme.dart' show AppTheme;
import '../utils/localization_helper.dart';
import '../models/delivery_address.dart';
import 'delivery_addresses_screen.dart';

class SelectDeliveryAddressScreen extends StatefulWidget {
  const SelectDeliveryAddressScreen({super.key});

  @override
  State<SelectDeliveryAddressScreen> createState() => _SelectDeliveryAddressScreenState();
}

class _SelectDeliveryAddressScreenState extends State<SelectDeliveryAddressScreen> {
  // В реальном приложении это должно быть из провайдера или базы данных
  final List<DeliveryAddress> _addresses = [
    DeliveryAddress(
      id: '1',
      type: 'Дом',
      icon: Icons.home,
      isDefault: true,
      address: 'г. Ташкент, Юнусабадский район, ул. Амира Темура, д. 123, кв. 45',
      recipientName: 'Журабаев Асадбек Нодирович',
      phone: '+998 90 123 45 67',
      city: 'Ташкент',
      district: 'Юнусабадский район',
      street: 'ул. Амира Темура',
      house: '123',
      apartment: '45',
    ),
    DeliveryAddress(
      id: '2',
      type: 'Работа',
      icon: Icons.business,
      isDefault: false,
      address: 'г. Ташкент, Мирзо-Улугбекский район, ул. Мустакиллик, офис 501',
      recipientName: 'Журабаев Асадбек Нодирович',
      phone: '+998 90 123 45 67',
      city: 'Ташкент',
      district: 'Мирзо-Улугбекский район',
      street: 'ул. Мустакиллик',
      house: '501',
      apartment: null,
    ),
  ];

  String? _selectedAddressId;

  @override
  void initState() {
    super.initState();
    // Загружаем адреса (в реальном приложении из провайдера)
    _loadAddresses();
  }

  void _loadAddresses() {
    // В реальном приложении здесь будет загрузка из провайдера или базы данных
    // Пока используем тестовые данные
  }

  Future<void> _addNewAddress() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const DeliveryAddressesScreen(),
      ),
    );

    // После возврата обновляем список адресов
    if (mounted) {
      setState(() {
        _loadAddresses();
      });
    }
  }

  void _selectAddress(String addressId) {
    setState(() {
      _selectedAddressId = addressId;
    });
  }

  void _confirmSelection() {
    if (_selectedAddressId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.translate('please_select_address')),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Navigator.pop(context, _selectedAddressId);
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
          context.l10n.translate('select_delivery_address'),
          style: TextStyle(color: textColor),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: _addresses.isEmpty
                ? _buildEmptyState(textColor, textSecondaryColor)
                : ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: _addresses.length,
                    itemBuilder: (context, index) {
                      final address = _addresses[index];
                      final isSelected = _selectedAddressId == address.id;
                      return _buildAddressCard(
                        address,
                        isSelected,
                        textColor,
                        textSecondaryColor,
                        cardColor,
                      );
                    },
                  ),
          ),
          // Кнопка подтверждения
          if (_addresses.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: backgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _confirmSelection,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.gold,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    context.l10n.translate('checkout_parcel_button'),
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
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(Color textColor, Color textSecondaryColor) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_off_outlined,
              size: 80,
              color: textSecondaryColor,
            ),
            const SizedBox(height: 24),
            Text(
              context.l10n.translate('no_addresses_title'),
              style: TextStyle(
                color: textColor,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              context.l10n.translate('add_address_to_checkout_message'),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: textSecondaryColor,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _addNewAddress,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.gold,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add,
                      color: ThemeHelper.isDark(context) 
                          ? const Color(0xFF0A0E27) 
                          : const Color(0xFF212121),
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      context.l10n.translate('add_address'),
                      style: TextStyle(
                        color: ThemeHelper.isDark(context) 
                            ? const Color(0xFF0A0E27) 
                            : const Color(0xFF212121),
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressCard(
    DeliveryAddress address,
    bool isSelected,
    Color textColor,
    Color textSecondaryColor,
    Color cardColor,
  ) {
    return GestureDetector(
      onTap: () => _selectAddress(address.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppTheme.gold : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Radio button
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppTheme.gold : textSecondaryColor,
                  width: 2,
                ),
                color: isSelected ? AppTheme.gold : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      size: 16,
                      color: Color(0xFF0A0E27),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            // Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.gold.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                address.icon,
                color: AppTheme.gold,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            // Address info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        address.type,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (address.isDefault)
                        Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.gold.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              context.l10n.translate('default'),
                              style: const TextStyle(
                                color: AppTheme.gold,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    address.address,
                    style: TextStyle(
                      color: textSecondaryColor,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    address.recipientName,
                    style: TextStyle(
                      color: textSecondaryColor,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    address.phone,
                    style: TextStyle(
                      color: textSecondaryColor,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

