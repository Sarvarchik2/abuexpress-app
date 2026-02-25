import 'package:flutter/material.dart';
import '../models/parcel_item.dart';
import '../models/shipping_calculator.dart';
import '../utils/theme_helper.dart';
import '../utils/localization_helper.dart';
import '../utils/theme.dart' show AppTheme;
import 'package:provider/provider.dart';
import '../models/api/office_address.dart';
import '../providers/user_provider.dart';
import '../services/api_service.dart';
import '../widgets/custom_snackbar.dart';
import 'select_delivery_address_screen.dart';
import 'shipping_calculator_screen.dart';

class AddParcelScreen extends StatefulWidget {
  const AddParcelScreen({super.key});

  @override
  State<AddParcelScreen> createState() => _AddParcelScreenState();
}

class _AddParcelScreenState extends State<AddParcelScreen> {
  final _formKey = GlobalKey<FormState>();
  final List<ParcelItem> _items = [];
  final Map<int, bool> _expandedItems = {}; // Для отслеживания развернутых товаров
  
  List<OfficeAddress> _officeAddresses = [];
  bool _isLoadingCountries = true;
  String? _selectedCountry;
  String? _selectedAddressId;
  ShippingCost? _shippingCost;
  
  // Флаги для отслеживания, что пользователь начал вводить данные
  bool _hasUserInput = false;
  
  final _trackNumberController = TextEditingController();
  final _storeNameController = TextEditingController();
  final _productNameController = TextEditingController();
  final _productLinkController = TextEditingController();
  final _costController = TextEditingController();
  final _weightController = TextEditingController();
  final _colorController = TextEditingController();
  final _sizeController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');
  final _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCountries();
    // Отслеживаем изменения в полях
    _trackNumberController.addListener(_onFieldChanged);
    _storeNameController.addListener(_onFieldChanged);
    _productNameController.addListener(_onFieldChanged);
    _productLinkController.addListener(_onFieldChanged);
    _costController.addListener(_onFieldChanged);
    _weightController.addListener(_onFieldChanged);
    _colorController.addListener(_onFieldChanged);
    _quantityController.addListener(_onFieldChanged);
  }

  Future<void> _loadCountries() async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final apiService = ApiService(authToken: userProvider.authToken);
      final addresses = await apiService.getOfficeAddresses();
      
      if (mounted) {
        setState(() {
          _officeAddresses = addresses;
          _isLoadingCountries = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading countries: $e');
      if (mounted) {
        setState(() {
          _isLoadingCountries = false;
          // Fallback to default countries if API fails, or just show empty
        });
        CustomSnackBar.error(
          context: context,
          message: '${context.l10n.translate('error_loading_countries')}: $e',
        );
      }
    }
  }

  void _onFieldChanged() {
    // Проверяем, начал ли пользователь вводить данные
    final hasInput = _productNameController.text.trim().isNotEmpty ||
                     _trackNumberController.text.trim().isNotEmpty ||
                     _storeNameController.text.trim().isNotEmpty ||
                     _productLinkController.text.trim().isNotEmpty ||
                     _colorController.text.trim().isNotEmpty ||
                     (double.tryParse(_costController.text.trim()) ?? 0.0) > 0 ||
                     (double.tryParse(_weightController.text.trim()) ?? 0.0) > 0 ||
                     (int.tryParse(_quantityController.text.trim()) ?? 0) > 0;
    
    // Всегда обновляем состояние, чтобы пересчитать _canAddItem, 
    // так как оно зависит от текста в контроллерах
    setState(() {
      _hasUserInput = hasInput;
    });
  }

  @override
  void dispose() {
    _trackNumberController.removeListener(_onFieldChanged);
    _storeNameController.removeListener(_onFieldChanged);
    _productNameController.removeListener(_onFieldChanged);
    _productLinkController.removeListener(_onFieldChanged);
    _costController.removeListener(_onFieldChanged);
    _weightController.removeListener(_onFieldChanged);
    _colorController.removeListener(_onFieldChanged);
    _quantityController.removeListener(_onFieldChanged);
    
    _trackNumberController.dispose();
    _storeNameController.dispose();
    _productNameController.dispose();
    _productLinkController.dispose();
    _costController.dispose();
    _weightController.dispose();
    _colorController.dispose();
    _sizeController.dispose();
    _quantityController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  bool get _canAddItem {
    // Проверяем, что все обязательные поля заполнены пользователем
    // API требует: track_number, market_name, url_product, product_name, product_price, product_quantity, product_color
    final productName = _productNameController.text.trim();
    final trackNumber = _trackNumberController.text.trim();
    final storeName = _storeNameController.text.trim();
    final productLink = _productLinkController.text.trim();
    final color = _colorController.text.trim();
    final cost = double.tryParse(_costController.text.trim()) ?? 0.0;
    // product_weight в API может быть null, но для калькулятора доставки он нужен
    final weight = double.tryParse(_weightController.text.trim()) ?? 0.0; 
    final quantity = int.tryParse(_quantityController.text.trim()) ?? 0;
    
    // Кнопки появляются только когда:
    // 1. Пользователь начал вводить данные (_hasUserInput)
    // 2. Все обязательные поля заполнены и имеют валидные значения
    return _hasUserInput &&
           productName.isNotEmpty &&
           trackNumber.isNotEmpty &&
           storeName.isNotEmpty &&
           productLink.isNotEmpty &&
           color.isNotEmpty &&
           cost > 0 &&
           weight > 0 &&
           quantity > 0;
  }

  void _addItem() {
    if (!_canAddItem) return;

    final item = ParcelItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      trackNumber: _trackNumberController.text.isEmpty
          ? 'ABU${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}'
          : _trackNumberController.text,
      storeName: _storeNameController.text.isEmpty
          ? context.l10n.translate('not_specified')
          : _storeNameController.text,
      productName: _productNameController.text.isEmpty
          ? context.l10n.translate('item')
          : _productNameController.text,
      productLink: _productLinkController.text.isNotEmpty // Обязательное поле
          ? _productLinkController.text
          : 'https://example.com', // Fallback, но валидация не должна пускать
      cost: double.tryParse(_costController.text) ?? 0.0,
      weight: double.tryParse(_weightController.text) ?? 0.0,
      color: _colorController.text.isNotEmpty 
          ? _colorController.text 
          : 'Multi', // Обязательное поле, fallback
      size: _sizeController.text.isEmpty ? null : _sizeController.text,
      quantity: int.tryParse(_quantityController.text) ?? 1,
      comment: _commentController.text.isEmpty
          ? null
          : _commentController.text,
    );

    setState(() {
      _items.add(item);
      _expandedItems[_items.length - 1] = false; // Сворачиваем после добавления
      _clearForm();
    });

      CustomSnackBar.success(
        context: context,
        message: '${context.l10n.translate('item')} ${_items.length} ${context.l10n.translate('item_added')}',
      );
  }

  void _clearForm() {
    _trackNumberController.clear();
    _storeNameController.clear();
    _productNameController.clear();
    _productLinkController.clear();
    _costController.clear();
    _weightController.clear();
    _colorController.clear();
    _sizeController.clear();
    _quantityController.text = '1';
    _commentController.clear();
    _hasUserInput = false; // Сбрасываем флаг после очистки
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
      _expandedItems.remove(index);
      // Обновляем ключи для оставшихся элементов
      final newExpanded = <int, bool>{};
      _expandedItems.forEach((key, value) {
        if (key < index) {
          newExpanded[key] = value;
        } else if (key > index) {
          newExpanded[key - 1] = value;
        }
      });
      _expandedItems.clear();
      _expandedItems.addAll(newExpanded);
    });
  }

  void _editItem(int index) {
    final item = _items[index];
    _trackNumberController.text = item.trackNumber;
    _storeNameController.text = item.storeName;
    _productNameController.text = item.productName;
    _productLinkController.text = item.productLink ?? '';
    _costController.text = item.cost.toStringAsFixed(2);
    _weightController.text = item.weight.toStringAsFixed(1);
    _colorController.text = item.color ?? '';
    _sizeController.text = item.size ?? '';
    _quantityController.text = item.quantity.toString();
    _commentController.text = item.comment ?? '';

    // Удаляем товар из списка, чтобы заменить его обновленной версией
    setState(() {
      _items.removeAt(index);
      _expandedItems.remove(index);
    });
  }

  void _toggleItemExpansion(int index) {
    setState(() {
      _expandedItems[index] = !(_expandedItems[index] ?? false);
    });
  }

  Future<void> _selectAddress() async {
    if (_items.isEmpty && !_canAddItem) {
      CustomSnackBar.error(
        context: context,
        message: context.l10n.translate('add_at_least_one_item'),
      );
      return;
    }

    // Если есть незаполненный товар, добавляем его
    if (_canAddItem) {
      _addItem();
    }

    if (_items.isEmpty) {
      return;
    }

    // Выбираем адрес
    final selectedAddressId = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => const SelectDeliveryAddressScreen(),
      ),
    );

    if (selectedAddressId != null && mounted) {
      setState(() {
        _selectedAddressId = selectedAddressId;
      });

      // Переходим к калькулятору стоимости
      await _showShippingCalculator();
    }
  }

  Future<void> _showShippingCalculator() async {
    if (_selectedCountry == null || _items.isEmpty) return;

    final totalWeight = _items.fold(0.0, (sum, item) => sum + (item.weight * item.quantity));
    final totalCost = _items.fold(0.0, (sum, item) => sum + (item.cost * item.quantity));

    final cost = ShippingCalculator.calculate(
      country: _selectedCountry!,
      totalWeight: totalWeight,
      totalCost: totalCost,
      itemCount: _items.length,
    );

    String locationId = 'USA'; // Default backup
    try {
      if (_officeAddresses.isNotEmpty) {
        // Пытаемся найти точное совпадение или совпадение без учета регистра
        final office = _officeAddresses.firstWhere(
          (element) => element.location.toLowerCase() == _selectedCountry?.toLowerCase(),
          orElse: () => _officeAddresses.first,
        );
        locationId = office.location;
      }
    } catch (e) {
      debugPrint('Error finding location ID: $e');
    }

    final confirmed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => ShippingCalculatorScreen(
          shippingCost: cost,
          totalWeight: totalWeight,
          totalCost: totalCost,
          itemCount: _items.length,
          items: _items,
          selectedAddressId: _selectedAddressId,
          locationId: locationId,
        ),
      ),
    );

    if (confirmed == true && mounted) {
      setState(() {
        _shippingCost = cost;
      });
      // Заказы уже созданы через API в ShippingCalculatorScreen._handleCheckout()
      // Просто возвращаемся назад - список обновится из API
      Navigator.pop(context, true);
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
          context.l10n.translate('add_parcel'),
          style: TextStyle(color: textColor),
        ),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // Выбор страны
                  if (_selectedCountry == null) ...[
                    Text(
                      context.l10n.translate('select_country'),
                      style: TextStyle(
                        color: textColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildCountrySelector(),
                    const SizedBox(height: 32),
                  ] else ...[
                    _buildSelectedCountryCard(),
                    const SizedBox(height: 24),
                  ],
                  
                  // Список добавленных товаров
                  if (_items.isNotEmpty) ...[
                    Text(
                      '${context.l10n.translate('items_in_parcel')} (${_items.length})',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...List.generate(_items.length, (index) {
                      return _buildCollapsibleItemCard(_items[index], index);
                    }),
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 24),
                  ],
                  
                  // Форма для нового товара
                  Text(
                    _items.isEmpty 
                        ? context.l10n.translate('product_info')
                        : context.l10n.translate('add_more_items'),
                    style: TextStyle(
                      color: textColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    label: context.l10n.translate('tracking_number'),
                    controller: _trackNumberController,
                    hint: '${context.l10n.translate('for_example')} 1Z999AA10123456784',
                    icon: Icons.inbox_outlined,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return context.l10n.translate('fill_required_fields');
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    label: context.l10n.translate('store_name'),
                    controller: _storeNameController,
                    hint: context.l10n.translate('store_name_hint'),
                    icon: Icons.local_offer_outlined,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return context.l10n.translate('fill_required_fields');
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    label: context.l10n.translate('product_name'),
                    controller: _productNameController,
                    hint: context.l10n.translate('product_name_hint'),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return context.l10n.translate('fill_required_fields');
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    label: context.l10n.translate('product_link'),
                    controller: _productLinkController,
                    hint: context.l10n.translate('product_link_hint'),
                    keyboardType: TextInputType.url,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return context.l10n.translate('fill_required_fields');
                      }
                      if (!value.startsWith('http')) {
                        return context.l10n.translate('invalid_url');
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    label: context.l10n.translate('cost'),
                    controller: _costController,
                    hint: context.l10n.translate('cost_hint'),
                    icon: Icons.attach_money,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return context.l10n.translate('fill_required_fields');
                      }
                      final cost = double.tryParse(value);
                      if (cost == null || cost <= 0) {
                        return context.l10n.translate('invalid_cost');
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    label: context.l10n.translate('weight'),
                    controller: _weightController,
                    hint: context.l10n.translate('weight_hint'),
                    icon: Icons.shopping_bag_outlined,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      // Вес не обязателен для API (может быть null), но мы требуем его для калькулятора
                      // Если поле пустое - ошибка
                      if (value == null || value.trim().isEmpty) {
                         return context.l10n.translate('fill_required_fields');
                      }
                      final weight = double.tryParse(value);
                      if (weight == null || weight <= 0) {
                        return context.l10n.translate('invalid_weight');
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    label: context.l10n.translate('color'),
                    controller: _colorController,
                    hint: context.l10n.translate('color_hint'),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return context.l10n.translate('fill_required_fields');
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    label: context.l10n.translate('size'),
                    controller: _sizeController,
                    hint: context.l10n.translate('size_hint'),
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    label: context.l10n.translate('quantity'),
                    controller: _quantityController,
                    hint: context.l10n.translate('quantity_hint'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return context.l10n.translate('fill_required_fields');
                      }
                      final qty = int.tryParse(value);
                      if (qty == null || qty <= 0) {
                        return context.l10n.translate('invalid_quantity');
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    label: context.l10n.translate('comment'),
                    controller: _commentController,
                    hint: context.l10n.translate('brief_description'),
                    icon: Icons.description_outlined,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
            // Кнопки внизу
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: backgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Кнопка добавления товара (всегда показывается если есть данные)
                  if (_canAddItem && _selectedCountry != null) ...[
                    // Кнопка отмены показывается если уже есть хотя бы 1 товар
                    if (_items.isNotEmpty)
                      Row(
                        children: [
                          // Кнопка отмены
                          Expanded(
                            child: SizedBox(
                              height: 56,
                              child: OutlinedButton(
                                onPressed: () {
                                  setState(() {
                                    _clearForm();
                                  });
                                },
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(
                                    color: ThemeHelper.getTextSecondaryColor(context),
                                    width: 1.5,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.close,
                                      color: ThemeHelper.getTextColor(context),
                                      size: 18,
                                    ),
                                    const SizedBox(width: 6),
                                    Flexible(
                                      child: Text(
                                        context.l10n.translate('cancel'),
                                        style: TextStyle(
                                          color: ThemeHelper.getTextColor(context),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Кнопка добавления
                          Expanded(
                            flex: 2,
                            child: SizedBox(
                              height: 56,
                              child: ElevatedButton(
                                onPressed: _addItem,
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
                                      size: 20,
                                    ),
                                    const SizedBox(width: 6),
                                    Flexible(
                                      child: Text(
                                        context.l10n.translate('add_item'),
                                        style: TextStyle(
                                          color: ThemeHelper.isDark(context) 
                                              ? const Color(0xFF0A0E27) 
                                              : const Color(0xFF212121),
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    else
                      // Если товаров меньше 2, показываем только кнопку добавления
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _addItem,
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
                              context.l10n.translate('add_item'),
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
                    const SizedBox(height: 32),
                  ],
                  if (_items.isNotEmpty || _canAddItem)
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _selectedCountry != null ? _selectAddress : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.gold,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          context.l10n.translate('select_address'),
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCountrySelector() {
    final textColor = ThemeHelper.getTextColor(context);
    final textSecondaryColor = ThemeHelper.getTextSecondaryColor(context);
    final cardColor = ThemeHelper.getCardColor(context);
    
    if (_isLoadingCountries) {
      return SizedBox(
        height: 140,
        child: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.gold),
          ),
        ),
      );
    }
    
    final uniqueLocations = _officeAddresses.map((e) => e.location).toSet().toList();
    
    // Если список пустой, показываем заглушку, но пытаемся использовать стандартные, если API упало?
    // Нет, если API вернуло пустоту, значит стран нет. Но если ошибка, список пустой.
    // Если список пустой - показываем сообщение
    if (uniqueLocations.isEmpty) {
      return SizedBox(
        height: 140,
        child: Center(
          child: Text(
            context.l10n.translate('no_countries_available'),
            style: TextStyle(color: textSecondaryColor),
          ),
        ),
      );
    }
    
    final Map<String, String> countryFlags = {
      'USA': '🇺🇸',
      'TURKEY': '🇹🇷',
      'Turkey': '🇹🇷',
      'CHINA': '🇨🇳',
      'China': '🇨🇳',
      'UAE': '🇦🇪',
      'GERMANY': '🇩🇪',
      'Germany': '🇩🇪',
      'RUSSIA': '🇷🇺',
      'Russia': '🇷🇺',
    };

    return SizedBox(
      height: 140,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        itemCount: uniqueLocations.length,
        itemBuilder: (context, index) {
          final country = uniqueLocations[index];
          final isSelected = _selectedCountry == country;
          
          // Пытаемся найти флаг, если нет - используем глобус
          String flag = '🌍';
          // Ищем совпадение без учета регистра
          for (var key in countryFlags.keys) {
            if (key.toUpperCase() == country.toUpperCase()) {
              flag = countryFlags[key]!;
              break;
            }
          }
          
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCountry = country;
              });
            },
            child: Container(
              width: 110,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected 
                    ? AppTheme.gold.withValues(alpha: 0.2)
                    : cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? AppTheme.gold : Colors.transparent,
                  width: 2,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppTheme.gold.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Флаг
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.gold.withValues(alpha: 0.15)
                          : textSecondaryColor.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        flag,
                        style: const TextStyle(fontSize: 32),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Название страны
                  Text(
                    country, // Используем название как есть из API, или можно переводить если совпадают ключи
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isSelected ? AppTheme.gold : textColor,
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                  // Иконка выбора
                  if (isSelected) ...[
                    const SizedBox(height: 8),
                    const Icon(
                      Icons.check_circle,
                      color: AppTheme.gold,
                      size: 20,
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSelectedCountryCard() {
    final textColor = ThemeHelper.getTextColor(context);
    final cardColor = ThemeHelper.getCardColor(context);
    final countryNames = {
      'USA': context.l10n.translate('usa'),
      'Turkey': context.l10n.translate('turkey'),
      'China': context.l10n.translate('china'),
      'UAE': context.l10n.translate('uae'),
    };

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.flag, color: AppTheme.gold, size: 24),
          const SizedBox(width: 12),
            Expanded(
            child: Text(
              '${context.l10n.translate('origin_country')}: ${countryNames[_selectedCountry] ?? _selectedCountry}',
              style: TextStyle(
                color: textColor,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _selectedCountry = null;
                _selectedAddressId = null;
                _shippingCost = null;
              });
            },
            child: Text(
              context.l10n.translate('edit'),
              style: const TextStyle(color: AppTheme.gold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCollapsibleItemCard(ParcelItem item, int index) {
    final textColor = ThemeHelper.getTextColor(context);
    final textSecondaryColor = ThemeHelper.getTextSecondaryColor(context);
    final cardColor = ThemeHelper.getCardColor(context);
    final isExpanded = _expandedItems[index] ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Заголовок товара (всегда видимый)
          InkWell(
            onTap: () => _toggleItemExpansion(index),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${index + 1}. ${item.productName}',
                          style: TextStyle(
                            color: textColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${item.storeName} • \$${item.cost.toStringAsFixed(2)} • ${item.weight} кг',
                          style: TextStyle(
                            color: textSecondaryColor,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.edit,
                          color: AppTheme.gold,
                          size: 20,
                        ),
                        onPressed: () => _editItem(index),
                      ),
                      IconButton(
                        icon: Icon(
                          isExpanded ? Icons.expand_less : Icons.expand_more,
                          color: textSecondaryColor,
                          size: 20,
                        ),
                        onPressed: () => _toggleItemExpansion(index),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.close,
                          color: textSecondaryColor,
                          size: 20,
                        ),
                        onPressed: () => _removeItem(index),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Детали товара (раскрываются)
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(),
                  const SizedBox(height: 12),
                  _buildDetailRow(context.l10n.translate('tracking_number'), item.trackNumber, textColor, textSecondaryColor),
                  if (item.productLink != null)
                    _buildDetailRow(context.l10n.translate('link'), item.productLink!, textColor, textSecondaryColor),
                  if (item.color != null)
                    _buildDetailRow(context.l10n.translate('color'), item.color!, textColor, textSecondaryColor),
                  if (item.size != null)
                    _buildDetailRow(context.l10n.translate('size'), item.size!, textColor, textSecondaryColor),
                  _buildDetailRow(context.l10n.translate('quantity'), item.quantity.toString(), textColor, textSecondaryColor),
                  if (item.comment != null)
                    _buildDetailRow(context.l10n.translate('comment'), item.comment!, textColor, textSecondaryColor),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, Color textColor, Color textSecondaryColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                color: textSecondaryColor,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: textColor,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    String? hint,
    IconData? icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    final textColor = ThemeHelper.getTextColor(context);
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
          style: TextStyle(color: textColor),
          maxLines: maxLines,
          keyboardType: keyboardType,
          onChanged: (_) => _onFieldChanged(), // Используем общий метод
          validator: validator,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: textSecondaryColor.withValues(alpha: 0.5),
              fontSize: 14,
            ),
            prefixIcon: icon != null
                ? Icon(
                    icon,
                    color: textSecondaryColor,
                    size: 20,
                  )
                : null,
            filled: true,
            fillColor: cardColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.gold, width: 1),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.redAccent, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.redAccent, width: 1),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            errorStyle: const TextStyle(
              color: Colors.redAccent,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}
