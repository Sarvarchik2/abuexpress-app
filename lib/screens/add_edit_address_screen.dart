import 'package:flutter/material.dart';
import '../models/delivery_address.dart';
import '../utils/theme_helper.dart';
import '../utils/localization_helper.dart';
import '../utils/theme.dart' show AppTheme;

class AddEditAddressScreen extends StatefulWidget {
  final DeliveryAddress? address; // Если null - добавление, иначе - редактирование

  const AddEditAddressScreen({
    super.key,
    this.address,
  });

  @override
  State<AddEditAddressScreen> createState() => _AddEditAddressScreenState();
}

class _AddEditAddressScreenState extends State<AddEditAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Тип адреса
  String _selectedType = 'home'; // Используем ключи вместо текста
  final _customTypeController = TextEditingController();
  bool _isCustomType = false;
  
  // Контактная информация
  final _recipientNameController = TextEditingController();
  final _phoneController = TextEditingController();
  
  // Адрес доставки
  final _cityController = TextEditingController();
  final _districtController = TextEditingController();
  final _streetController = TextEditingController();
  final _houseController = TextEditingController();
  final _apartmentController = TextEditingController();
  
  // По умолчанию
  bool _isDefault = false;

  @override
  void initState() {
    super.initState();
    if (widget.address != null) {
      // Редактирование существующего адреса
      final addressType = widget.address!.type;
      // Проверяем, является ли тип стандартным
      final standardTypes = ['Дом', 'Работа', 'Другое', 'Home', 'Work', 'Other', 'Uy', 'Ish', 'Boshqa'];
      _isCustomType = !standardTypes.contains(addressType);
      if (_isCustomType) {
        _customTypeController.text = addressType;
        _selectedType = 'custom';
      } else {
        // Маппинг стандартных типов на ключи
        if (addressType == 'Дом' || addressType == 'Home' || addressType == 'Uy') {
          _selectedType = 'home';
        } else if (addressType == 'Работа' || addressType == 'Work' || addressType == 'Ish') {
          _selectedType = 'work';
        } else if (addressType == 'Другое' || addressType == 'Other' || addressType == 'Boshqa') {
          _selectedType = 'other';
        }
      }
      _recipientNameController.text = widget.address!.recipientName;
      _phoneController.text = widget.address!.phone;
      _cityController.text = widget.address!.city;
      _districtController.text = widget.address!.district;
      _streetController.text = widget.address!.street;
      _houseController.text = widget.address!.house;
      _apartmentController.text = widget.address!.apartment ?? '';
      _isDefault = widget.address!.isDefault;
    }
  }

  @override
  void dispose() {
    _customTypeController.dispose();
    _recipientNameController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _districtController.dispose();
    _streetController.dispose();
    _houseController.dispose();
    _apartmentController.dispose();
    super.dispose();
  }

  IconData _getTypeIcon(String typeKey) {
    switch (typeKey) {
      case 'home':
        return Icons.home;
      case 'work':
        return Icons.business;
      case 'other':
        return Icons.business_center;
      default:
        return Icons.location_on;
    }
  }

  void _saveAddress() {
    if (_formKey.currentState?.validate() ?? false) {
      String type;
      if (_isCustomType && _customTypeController.text.isNotEmpty) {
        type = _customTypeController.text;
      } else {
        // Используем локализованное название типа
        switch (_selectedType) {
          case 'home':
            type = context.l10n.translate('home');
            break;
          case 'work':
            type = context.l10n.translate('work');
            break;
          case 'other':
            type = context.l10n.translate('other');
            break;
          default:
            type = _selectedType;
        }
      }
      
      final address = DeliveryAddress(
        id: widget.address?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        type: type,
        icon: _getTypeIcon(_selectedType),
        isDefault: _isDefault,
        address: '', // Будет сгенерирован автоматически
        recipientName: _recipientNameController.text.trim(),
        phone: _phoneController.text.trim(),
        city: _cityController.text.trim(),
        district: _districtController.text.trim(),
        street: _streetController.text.trim(),
        house: _houseController.text.trim(),
        apartment: _apartmentController.text.trim().isEmpty 
            ? null 
            : _apartmentController.text.trim(),
      );

      Navigator.pop(context, address);
    }
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
          widget.address == null 
              ? context.l10n.translate('add_address') 
              : context.l10n.translate('edit_address'),
          style: TextStyle(color: textColor),
        ),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Тип адреса
            _buildSectionTitle(context.l10n.translate('address_type'), Icons.category_outlined, textColor),
            const SizedBox(height: 12),
            _buildAddressTypeSelector(textColor),
            if (_isCustomType) ...[
              const SizedBox(height: 12),
              _buildTextField(
                label: context.l10n.translate('type_name'),
                controller: _customTypeController,
                hint: context.l10n.translate('enter_name'),
                textColor: textColor,
              ),
            ],
            const SizedBox(height: 24),
            
            // Контактная информация
            _buildSectionTitle(context.l10n.translate('contact_info'), Icons.person_outline, textColor),
            const SizedBox(height: 12),
            _buildTextField(
              label: context.l10n.translate('recipient_name'),
              controller: _recipientNameController,
              hint: context.l10n.translate('enter_full_name'),
              textColor: textColor,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return context.l10n.translate('please_enter_name');
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildTextField(
              label: context.l10n.translate('phone_number'),
              controller: _phoneController,
              hint: '+998 90 123 45 67',
              textColor: textColor,
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return context.l10n.translate('please_enter_phone');
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            
            // Адрес доставки
            _buildSectionTitle(context.l10n.translate('delivery_address'), Icons.location_on_outlined, textColor),
            const SizedBox(height: 12),
            _buildTextField(
              label: context.l10n.translate('city'),
              controller: _cityController,
              hint: context.l10n.translate('enter_city'),
              textColor: textColor,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return context.l10n.translate('please_enter_city');
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildTextField(
              label: context.l10n.translate('district'),
              controller: _districtController,
              hint: context.l10n.translate('enter_district'),
              textColor: textColor,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return context.l10n.translate('please_enter_district');
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildTextField(
              label: context.l10n.translate('street'),
              controller: _streetController,
              hint: context.l10n.translate('enter_street'),
              textColor: textColor,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return context.l10n.translate('please_enter_street');
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    label: context.l10n.translate('house'),
                    controller: _houseController,
                    hint: '123',
                    textColor: textColor,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return context.l10n.translate('required');
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTextField(
                    label: context.l10n.translate('apartment'),
                    controller: _apartmentController,
                    hint: '45',
                    textColor: textColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // По умолчанию
            _buildDefaultToggle(textColor),
            const SizedBox(height: 32),
          ],
        ),
      ),
      bottomNavigationBar: Container(
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
          child: ElevatedButton.icon(
            onPressed: _saveAddress,
            icon: Icon(
              Icons.add,
              color: ThemeHelper.isDark(context) 
                  ? const Color(0xFF0A0E27) 
                  : const Color(0xFF212121),
            ),
            label: Text(
              widget.address == null 
                  ? context.l10n.translate('add_address') 
                  : context.l10n.translate('save_changes'),
              style: TextStyle(
                color: ThemeHelper.isDark(context) 
                    ? const Color(0xFF0A0E27) 
                    : const Color(0xFF212121),
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.gold,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, Color textColor) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.gold, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            color: textColor,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildAddressTypeSelector(Color textColor) {
    final cardColor = ThemeHelper.getCardColor(context);
    final textSecondaryColor = ThemeHelper.getTextSecondaryColor(context);
    
    final types = [
      {'key': 'home', 'label': context.l10n.translate('home')},
      {'key': 'work', 'label': context.l10n.translate('work')},
      {'key': 'other', 'label': context.l10n.translate('other')},
    ];
    
    return Row(
      children: [
        ...types.map((typeData) {
          final typeKey = typeData['key'] as String;
          final typeLabel = typeData['label'] as String;
          final isSelected = !_isCustomType && _selectedType == typeKey;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedType = typeKey;
                  _isCustomType = false;
                  _customTypeController.clear();
                });
              },
              child: Container(
                margin: EdgeInsets.only(
                  right: typeData != types.last ? 8 : 0,
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.gold : cardColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Icon(
                      _getTypeIcon(typeKey),
                      color: isSelected
                          ? (ThemeHelper.isDark(context) 
                              ? const Color(0xFF0A0E27) 
                              : const Color(0xFF212121))
                          : textSecondaryColor,
                      size: 24,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      typeLabel,
                      style: TextStyle(
                        color: isSelected
                            ? (ThemeHelper.isDark(context) 
                                ? const Color(0xFF0A0E27) 
                                : const Color(0xFF212121))
                            : textColor,
                        fontSize: 14,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
        const SizedBox(width: 8),
        // Кнопка для кастомного типа
        GestureDetector(
          onTap: () {
            setState(() {
              _isCustomType = true;
              _selectedType = '';
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            decoration: BoxDecoration(
              color: _isCustomType ? AppTheme.gold : cardColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.add,
              color: _isCustomType
                  ? (ThemeHelper.isDark(context) 
                      ? const Color(0xFF0A0E27) 
                      : const Color(0xFF212121))
                  : textSecondaryColor,
              size: 24,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    String? hint,
    required Color textColor,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    final textSecondaryColor = ThemeHelper.getTextSecondaryColor(context);
    final cardColor = ThemeHelper.getCardColor(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: textColor,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          style: TextStyle(color: textColor),
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: textSecondaryColor,
              fontSize: 14,
            ),
            filled: true,
            fillColor: cardColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDefaultToggle(Color textColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          context.l10n.translate('set_as_default'),
          style: TextStyle(
            color: textColor,
            fontSize: 16,
          ),
        ),
        Switch(
          value: _isDefault,
          onChanged: (value) {
            setState(() {
              _isDefault = value;
            });
          },
          activeThumbColor: AppTheme.gold,
        ),
      ],
    );
  }
}

