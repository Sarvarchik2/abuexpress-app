import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/theme_helper.dart';
import '../utils/theme.dart' show AppTheme;
import '../utils/localization_helper.dart';
import '../models/delivery_address.dart';
import '../models/api/receiver.dart';
import '../services/api_service.dart';
import '../providers/user_provider.dart';
import '../widgets/custom_dialog.dart';
import '../widgets/custom_snackbar.dart';
import 'add_edit_address_screen.dart';

class DeliveryAddressesScreen extends StatefulWidget {
  const DeliveryAddressesScreen({super.key});

  @override
  State<DeliveryAddressesScreen> createState() => _DeliveryAddressesScreenState();
}

class _DeliveryAddressesScreenState extends State<DeliveryAddressesScreen> {
  final List<DeliveryAddress> _addresses = [];
  late final ApiService _apiService;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Получаем токен из UserProvider и создаем ApiService с токеном
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final token = userProvider.authToken;
    _apiService = ApiService(authToken: token);
    debugPrint('=== API SERVICE CREATED ===');
    debugPrint('Token: ${token != null ? "${token.substring(0, 20)}..." : "null"}');
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

      debugPrint('=== LOADING ADDRESSES ===');
      debugPrint('Current user email: ${currentUser.email}');
      
      final receivers = await _apiService.getAddresses();
      debugPrint('=== ADDRESSES LOADED ===');
      debugPrint('Total addresses from API: ${receivers.length}');

      // Фильтруем адреса по email текущего пользователя
      final userAddresses = receivers.where((receiver) {
        final matches = receiver.email.toLowerCase() == currentUser.email.toLowerCase();
        debugPrint('Address ${receiver.id}: email=${receiver.email}, matches=$matches');
        return matches;
      }).toList();

      debugPrint('Filtered addresses for user: ${userAddresses.length}');

      if (mounted) {
        setState(() {
          _addresses.clear();
          _addresses.addAll(userAddresses.map((receiver) => _receiverToDeliveryAddress(receiver)));
          _isLoading = false;
        });
      }
    } catch (e, stackTrace) {
      debugPrint('=== ERROR LOADING ADDRESSES ===');
      debugPrint('Error: $e');
      debugPrint('Stack Trace: $stackTrace');
      
      if (mounted) {
        String userFriendlyMessage = 'Не удалось загрузить адреса';
        
        // Более понятные сообщения об ошибках
        if (e.toString().contains('401') || e.toString().contains('авторизац')) {
          userFriendlyMessage = 'Требуется авторизация. Пожалуйста, войдите снова';
        } else if (e.toString().contains('403') || e.toString().contains('запрещен')) {
          userFriendlyMessage = 'Доступ запрещен';
        } else if (e.toString().contains('500') || e.toString().contains('сервер')) {
          userFriendlyMessage = 'Ошибка сервера. Попробуйте позже';
        } else if (e.toString().contains('подключен') || e.toString().contains('timeout')) {
          userFriendlyMessage = 'Проблема с подключением. Проверьте интернет';
        }
        
        setState(() {
          _isLoading = false;
          _errorMessage = userFriendlyMessage;
        });
        
        CustomSnackBar.error(
          context: context,
          message: userFriendlyMessage,
        );
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
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_errorMessage != null)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: ThemeHelper.getTextSecondaryColor(context),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _errorMessage!,
                    style: TextStyle(
                      color: ThemeHelper.getTextColor(context),
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
          else if (_addresses.isEmpty)
            _buildEmptyState()
          else
            RefreshIndicator(
              onRefresh: _loadAddresses,
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                itemCount: _addresses.length,
                itemBuilder: (context, index) {
                  return _buildAddressCard(_addresses[index]);
                },
              ),
            ),
          // Add Address Button
          if (!_isLoading && _errorMessage == null)
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
      // Перезагружаем адреса из API
      await _loadAddresses();
      
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
      // Перезагружаем адреса из API
      await _loadAddresses();
      
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
          onPressed: () async {
            Navigator.pop(context);
            if (mounted) {
              // Удаляем локально
              setState(() {
                _addresses.removeWhere((a) => a.id == address.id);
              });
              
              // TODO: Добавить API endpoint для удаления адреса
              // await _apiService.deleteAddress(int.parse(address.id));
              
              CustomSnackBar.success(
                context: context,
                message: context.l10n.translate('address_deleted').replaceAll('{type}', address.type),
              );
              
              // Перезагружаем адреса для синхронизации с сервером
              await _loadAddresses();
            }
          },
          backgroundColor: Colors.red,
        ),
      ],
    );
  }
}

