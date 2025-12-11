import 'package:flutter/material.dart';

class DeliveryAddressesScreen extends StatefulWidget {
  const DeliveryAddressesScreen({super.key});

  @override
  State<DeliveryAddressesScreen> createState() => _DeliveryAddressesScreenState();
}

class _DeliveryAddressesScreenState extends State<DeliveryAddressesScreen> {
  List<DeliveryAddress> _addresses = [
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
          'Адреса доставки',
          style: TextStyle(color: Colors.white),
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFF1A1F3A),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.location_on_outlined,
              color: Colors.white54,
              size: 60,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'У вас пока нет адресов доставки',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Добавьте адрес доставки, чтобы начать заказывать товары',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white54,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressCard(DeliveryAddress address) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F3A),
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
                  color: const Color(0xFF0A0E27),
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
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (address.isDefault) ...[
                      const SizedBox(height: 4),
                      const Text(
                        'По умолчанию',
                        style: TextStyle(
                          color: Color(0xFFFFD700),
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
                  child: const Icon(
                    Icons.edit_outlined,
                    color: Colors.white54,
                    size: 20,
                  ),
                ),
              ),
              // Delete button
              GestureDetector(
                onTap: () => _deleteAddress(address),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: const Icon(
                    Icons.delete_outline,
                    color: Colors.white54,
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
              const Icon(
                Icons.location_on_outlined,
                color: Colors.white54,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  address.address,
                  style: const TextStyle(
                    color: Colors.white,
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
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          // Phone number
          Row(
            children: [
              const Icon(
                Icons.phone_outlined,
                color: Colors.white54,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                address.phone,
                style: const TextStyle(
                  color: Colors.white70,
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
          backgroundColor: const Color(0xFFFFD700),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(
              Icons.add,
              color: Color(0xFF0A0E27),
              size: 24,
            ),
            SizedBox(width: 8),
            Text(
              'Добавить адрес',
              style: TextStyle(
                color: Color(0xFF0A0E27),
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
        backgroundColor: Color(0xFFFFD700),
      ),
    );
  }

  void _editAddress(DeliveryAddress address) {
    // TODO: Navigate to edit address form
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Редактирование адреса: ${address.type}'),
        backgroundColor: const Color(0xFFFFD700),
      ),
    );
  }

  void _deleteAddress(DeliveryAddress address) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1F3A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Удалить адрес?',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Вы уверены, что хотите удалить адрес "${address.type}"?',
          style: const TextStyle(
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
              setState(() {
                _addresses.removeWhere((a) => a.id == address.id);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Адрес "${address.type}" удален'),
                  backgroundColor: const Color(0xFFFFD700),
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
