import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/theme_helper.dart';
import '../utils/theme.dart' show AppTheme;
import '../utils/localization_helper.dart';
import '../models/delivery_address.dart';
import '../models/api/receiver.dart';
import '../services/api_service.dart';
import '../providers/user_provider.dart';
import '../widgets/custom_snackbar.dart';
import 'add_edit_address_screen.dart';

class SelectDeliveryAddressScreen extends StatefulWidget {
  const SelectDeliveryAddressScreen({super.key});

  @override
  State<SelectDeliveryAddressScreen> createState() => _SelectDeliveryAddressScreenState();
}

class _SelectDeliveryAddressScreenState extends State<SelectDeliveryAddressScreen> {
  final List<DeliveryAddress> _addresses = [];
  late final ApiService _apiService;
  bool _isLoading = true;
  String? _errorMessage;
  String? _selectedAddressId;

  @override
  void initState() {
    super.initState();
    // Получаем токен из UserProvider и создаем ApiService с токеном
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final token = userProvider.authToken;
    _apiService = ApiService(authToken: token);
    _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final currentUser = userProvider.userInfo;
      
      if (currentUser == null) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Пользователь не авторизован';
        });
        return;
      }

      debugPrint('=== LOADING ADDRESSES FOR SELECTION ===');
      debugPrint('Current user email: ${currentUser.email}');
      
      final receivers = await _apiService.getAddresses();
      debugPrint('=== ADDRESSES LOADED ===');
      debugPrint('Total addresses from API: ${receivers.length}');

      // Фильтруем адреса по email текущего пользователя
      final userAddresses = receivers.where((receiver) {
        final matches = receiver.email.toLowerCase() == currentUser.email.toLowerCase();
        return matches;
      }).toList();

      debugPrint('Filtered addresses for user: ${userAddresses.length}');

      if (mounted) {
        setState(() {
          _addresses.clear();
          _addresses.addAll(userAddresses.map((receiver) => _receiverToDeliveryAddress(receiver)));
          // Выбираем адрес по умолчанию, если есть
          if (_addresses.isNotEmpty && _selectedAddressId == null) {
            final defaultAddress = _addresses.firstWhere(
              (addr) => addr.isDefault,
              orElse: () => _addresses.first,
            );
            _selectedAddressId = defaultAddress.id;
          }
          _isLoading = false;
        });
      }
    } catch (e, stackTrace) {
      debugPrint('=== ERROR LOADING ADDRESSES ===');
      debugPrint('Error: $e');
      debugPrint('Stack Trace: $stackTrace');
      
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Ошибка загрузки адресов';
        });
      }
    }
  }

  DeliveryAddress _receiverToDeliveryAddress(Receiver receiver) {
    // Определяем тип адреса по officeNumber
    final hasOffice = receiver.officeNumber != null && receiver.officeNumber!.isNotEmpty;
    final type = hasOffice ? 'Работа' : 'Дом';
    final icon = hasOffice ? Icons.business : Icons.home;
    
    // Формируем полный адрес
    final addressParts = <String>[];
    if (receiver.address.isNotEmpty) {
      addressParts.add(receiver.address);
    }
    if (receiver.apartment.isNotEmpty) {
      addressParts.add('кв. ${receiver.apartment}');
    } else if (receiver.officeNumber != null && receiver.officeNumber!.isNotEmpty) {
      addressParts.add('офис ${receiver.officeNumber}');
    }
    if (receiver.district.isNotEmpty) {
      addressParts.add(receiver.district);
    }
    if (receiver.city.isNotEmpty) {
      addressParts.add('г. ${receiver.city}');
    }
    
    final fullAddress = addressParts.isNotEmpty 
        ? addressParts.join(', ')
        : receiver.fullAddress;
    
    // Извлекаем номер дома из адреса (если есть)
    final houseMatch = RegExp(r'д\.\s*(\d+)').firstMatch(receiver.address);
    final house = houseMatch?.group(1) ?? receiver.address.split(' ').last;
    
    return DeliveryAddress(
      id: receiver.id.toString(),
      type: type,
      icon: icon,
      isDefault: _addresses.isEmpty, // Первый адрес по умолчанию
      address: fullAddress,
      recipientName: receiver.fullName,
      phone: receiver.phoneNumber,
      city: receiver.city,
      district: receiver.district,
      street: receiver.address,
      house: house,
      apartment: receiver.apartment.isNotEmpty ? receiver.apartment : null,
    );
  }

  Future<void> _addNewAddress() async {
    // Переходим на экран добавления адреса
    final result = await Navigator.push<DeliveryAddress>(
      context,
      MaterialPageRoute(
        builder: (context) => const AddEditAddressScreen(),
      ),
    );

    // После добавления адреса обновляем список
    if (result != null && mounted) {
      await _loadAddresses();
      
      // Автоматически выбираем только что добавленный адрес
      if (_addresses.isNotEmpty) {
        setState(() {
          _selectedAddressId = result.id;
        });
      }
      
      CustomSnackBar.success(
        context: context,
        message: context.l10n.translate('address_added'),
      );
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
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 64,
                              color: textSecondaryColor,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _errorMessage!,
                              style: TextStyle(
                                color: textColor,
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadAddresses,
                              child: const Text('Повторить'),
                            ),
                          ],
                        ),
                      )
                    : _addresses.isEmpty
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

