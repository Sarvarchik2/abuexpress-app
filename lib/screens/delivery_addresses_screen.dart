import 'package:flutter/material.dart';
import '../utils/theme_helper.dart';
import '../utils/theme.dart' show AppTheme;
import '../utils/localization_helper.dart';
import '../models/delivery_address.dart';
import '../widgets/custom_dialog.dart';
import '../widgets/custom_snackbar.dart';
import 'add_edit_address_screen.dart';

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
          context.l10n.translate('delivery_addresses'),
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
            context.l10n.translate('no_addresses_yet'),
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
              context.l10n.translate('add_address_to_start'),
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
                      Text(
                        context.l10n.translate('default'),
                        style: const TextStyle(
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
                onTap: () {
                  _editAddress(address);
                },
                behavior: HitTestBehavior.opaque,
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
                onTap: () {
                  _deleteAddress(address);
                },
                behavior: HitTestBehavior.opaque,
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
                  address.address.isNotEmpty ? address.address : address.fullAddress,
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
              context.l10n.translate('add_address'),
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

  Future<void> _addAddress() async {
    final result = await Navigator.push<DeliveryAddress>(
      context,
      MaterialPageRoute(
        builder: (context) => const AddEditAddressScreen(),
      ),
    );

    if (result != null && mounted) {
      setState(() {
        // Если выбран как адрес по умолчанию, снимаем флаг с других
        if (result.isDefault) {
          for (var address in _addresses) {
            if (address.isDefault) {
              // В реальном приложении нужно обновить объект
            }
          }
        }
        _addresses.add(result);
      });
      
      CustomSnackBar.success(
        context: context,
        message: context.l10n.translate('address_added'),
      );
    }
  }

  Future<void> _editAddress(DeliveryAddress address) async {
    final result = await Navigator.push<DeliveryAddress>(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditAddressScreen(address: address),
      ),
    );

    if (result != null && mounted) {
      setState(() {
        final index = _addresses.indexWhere((a) => a.id == address.id);
        if (index != -1) {
          _addresses[index] = result;
        }
      });
      
      CustomSnackBar.success(
        context: context,
        message: context.l10n.translate('address_updated'),
      );
    }
  }


  void _deleteAddress(DeliveryAddress address) {
    CustomDialog.show(
      context: context,
      title: context.l10n.translate('delete_address_confirm'),
      message: context.l10n.translate('delete_address_message').replaceAll('{type}', address.type),
      icon: Icons.delete_outline_rounded,
      iconColor: Colors.red,
      actions: [
        CustomDialogActions.secondaryButton(
          context: context,
          text: context.l10n.translate('cancel'),
          onPressed: () => Navigator.pop(context),
        ),
        const SizedBox(width: 8),
        CustomDialogActions.primaryButton(
          context: context,
          text: context.l10n.translate('delete'),
          onPressed: () {
            Navigator.pop(context);
            if (mounted) {
              setState(() {
                _addresses.removeWhere((a) => a.id == address.id);
              });
              CustomSnackBar.success(
                context: context,
                message: context.l10n.translate('address_deleted').replaceAll('{type}', address.type),
              );
            }
          },
          backgroundColor: Colors.red,
        ),
      ],
    );
  }
}

