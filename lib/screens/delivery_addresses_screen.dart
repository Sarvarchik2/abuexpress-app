import 'package:flutter/material.dart';
import '../utils/theme_helper.dart';
import '../utils/theme.dart' show AppTheme;

class DeliveryAddressesScreen extends StatefulWidget {
  const DeliveryAddressesScreen({super.key});

  @override
  State<DeliveryAddressesScreen> createState() => _DeliveryAddressesScreenState();
}

class _DeliveryAddressesScreenState extends State<DeliveryAddressesScreen> {
  final List<DeliveryAddress> _addresses = [
    DeliveryAddress(
      id: '1',
      type: 'Дом',
      icon: Icons.home,
      isDefault: true,
      address: 'г. Ташкент, Юнусабадский район, ул. Амира Темура, д. 123, кв. 45',
      recipientName: 'Иванов Иван Иванович',
      phone: '+998 90 123 45 67',
    ),
    DeliveryAddress(
      id: '2',
      type: 'Работа',
      icon: Icons.business,
      isDefault: false,
      address: 'г. Ташкент, Мирзо-Улугбекский район, ул. Мустакиллик, офис 501',
      recipientName: 'Иванов Иван Иванович',
      phone: '+998 90 123 45 67',
    ),
  ];

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
          'Адреса доставки',
          style: TextStyle(color: textColor),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          _addresses.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                  itemCount: _addresses.length,
                  itemBuilder: (context, index) {
                    return _buildAddressCard(_addresses[index]);
                  },
                ),
          // Add Address Button
          Positioned(
            left: 20,
            right: 20,
            bottom: 20,
            child: _buildAddButton(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final cardColor = ThemeHelper.getCardColor(context);
    final textColor = ThemeHelper.getTextColor(context);
    final textSecondaryColor = ThemeHelper.getTextSecondaryColor(context);
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: cardColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.location_on_outlined,
              color: textSecondaryColor,
              size: 60,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'У вас пока нет адресов доставки',
            style: TextStyle(
              color: textColor,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Добавьте адрес доставки, чтобы начать заказывать товары',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: textSecondaryColor,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressCard(DeliveryAddress address) {
    final cardColor = ThemeHelper.getCardColor(context);
    final textColor = ThemeHelper.getTextColor(context);
    final textSecondaryColor = ThemeHelper.getTextSecondaryColor(context);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with icon, type, and actions
          Row(
            children: [
              // Icon
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFD700),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  address.icon,
                  color: ThemeHelper.isDark(context) ? const Color(0xFF0A0E27) : const Color(0xFF212121),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              // Type and default status
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      address.type,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (address.isDefault) ...[
                      const SizedBox(height: 4),
                      const Text(
                        'По умолчанию',
                        style: TextStyle(
                          color: AppTheme.gold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // Edit button
              GestureDetector(
                onTap: () => _editAddress(address),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: Icon(
                    Icons.edit_outlined,
                    color: textSecondaryColor,
                    size: 20,
                  ),
                ),
              ),
              // Delete button
              GestureDetector(
                onTap: () => _deleteAddress(address),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: Icon(
                    Icons.delete_outline,
                    color: textSecondaryColor,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Address details
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.location_on_outlined,
                color: textSecondaryColor,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  address.address,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Recipient name
          Text(
            address.recipientName,
            style: TextStyle(
              color: textSecondaryColor,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          // Phone number
          Row(
            children: [
              Icon(
                Icons.phone_outlined,
                color: textSecondaryColor,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                address.phone,
                style: TextStyle(
                  color: textSecondaryColor,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () => _addAddress(),
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
              color: ThemeHelper.isDark(context) ? const Color(0xFF0A0E27) : const Color(0xFF212121),
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              'Добавить адрес',
              style: TextStyle(
                color: ThemeHelper.isDark(context) ? const Color(0xFF0A0E27) : const Color(0xFF212121),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addAddress() {
    // TODO: Navigate to add/edit address form
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Форма добавления адреса будет реализована'),
        backgroundColor: AppTheme.gold,
      ),
    );
  }

  void _editAddress(DeliveryAddress address) {
    // TODO: Navigate to edit address form
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Редактирование адреса: ${address.type}'),
        backgroundColor: AppTheme.gold,
      ),
    );
  }

  void _deleteAddress(DeliveryAddress address) {
    final cardColor = ThemeHelper.getCardColor(context);
    final textColor = ThemeHelper.getTextColor(context);
    final textSecondaryColor = ThemeHelper.getTextSecondaryColor(context);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Удалить адрес?',
          style: TextStyle(
            color: textColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Вы уверены, что хотите удалить адрес "${address.type}"?',
          style: TextStyle(
            color: textSecondaryColor,
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Отмена',
              style: TextStyle(
                color: textSecondaryColor,
                fontSize: 16,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _addresses.removeWhere((a) => a.id == address.id);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Адрес "${address.type}" удален'),
                  backgroundColor: AppTheme.gold,
                ),
              );
            },
            child: const Text(
              'Удалить',
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

class DeliveryAddress {
  final String id;
  final String type;
  final IconData icon;
  final bool isDefault;
  final String address;
  final String recipientName;
  final String phone;

  DeliveryAddress({
    required this.id,
    required this.type,
    required this.icon,
    required this.isDefault,
    required this.address,
    required this.recipientName,
    required this.phone,
  });
}
