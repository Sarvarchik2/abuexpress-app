import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http; // Added import
import '../config/api_config.dart'; // Added import
import '../models/shipping_calculator.dart';
import '../models/parcel_item.dart';
import '../models/api/order_own_create_request.dart';
import '../services/api_service.dart';
import '../providers/user_provider.dart';
import '../utils/theme_helper.dart';
import '../utils/theme.dart' show AppTheme;
import '../utils/localization_helper.dart';
import '../widgets/custom_snackbar.dart';

class ShippingCalculatorScreen extends StatefulWidget {
  final ShippingCost shippingCost;
  final double totalWeight;
  final double totalCost;
  final int itemCount;
  final List<ParcelItem> items;
  final String? selectedAddressId;
  final String? locationId;

  const ShippingCalculatorScreen({
    super.key,
    required this.shippingCost,
    required this.totalWeight,
    required this.totalCost,
    required this.itemCount,
    required this.items,
    this.selectedAddressId,
    this.locationId,
  });

  @override
  State<ShippingCalculatorScreen> createState() => _ShippingCalculatorScreenState();
}

class _ShippingCalculatorScreenState extends State<ShippingCalculatorScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.8).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleCheckout() async {
    if (_isProcessing) return; // ... (rest of the method)

    if (widget.selectedAddressId == null) {
      CustomSnackBar.error(
        context: context,
        message: 'Адрес доставки не выбран',
      );
      return;
    }

    // Валидация полей перед отправкой
    final missingFields = <String>[];
    for (final item in widget.items) {
      if (item.trackNumber.trim().isEmpty) {
        missingFields.add(context.l10n.translate('tracking_number_label'));
      }
      if (item.storeName.trim().isEmpty) {
        missingFields.add(context.l10n.translate('store_name'));
      }
      if (item.productLink == null || item.productLink!.trim().isEmpty) {
        missingFields.add(context.l10n.translate('product_link'));
      }
      if (item.productName.trim().isEmpty) {
        missingFields.add(context.l10n.translate('product_name'));
      }
      if (item.cost <= 0) {
        missingFields.add(context.l10n.translate('cost'));
      }
      if (item.quantity <= 0) {
        missingFields.add(context.l10n.translate('quantity'));
      }
      if (item.color == null || item.color!.trim().isEmpty) {
        missingFields.add(context.l10n.translate('color'));
      }
    }

    if (missingFields.isNotEmpty) {
      final uniqueFields = missingFields.toSet().toList();
      CustomSnackBar.error(
        context: context,
        message: '${context.l10n.translate('fill_required_fields')}:\n${uniqueFields.join(', ')}',
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    // Анимация нажатия
    await _animationController.forward();
    await _animationController.reverse();

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final token = userProvider.authToken;
      final apiService = ApiService(authToken: token);

      final addressId = int.tryParse(widget.selectedAddressId!) ?? 0;
      if (addressId == 0) {
        throw Exception('Неверный ID адреса');
      }

      debugPrint('=== CREATING ORDERS ===');
      debugPrint('Items count: ${widget.items.length}');
      debugPrint('Address ID: $addressId');
      debugPrint('Location ID: ${widget.locationId}');

      // Создаем заказ для каждого товара
      int successCount = 0;
      int failCount = 0;

      for (final item in widget.items) {
        try {
          // Убеждаемся, что все обязательные поля заполнены
          // (валидация уже выполнена выше, но на всякий случай проверяем еще раз)
          if (item.trackNumber.trim().isEmpty ||
              item.storeName.trim().isEmpty ||
              item.productLink == null ||
              item.productLink!.trim().isEmpty ||
              item.productName.trim().isEmpty ||
              item.cost <= 0 ||
              item.quantity <= 0 ||
              item.color == null ||
              item.color!.trim().isEmpty) {
            throw Exception('Не все обязательные поля заполнены');
          }

          final request = OrderOwnCreateRequest(
            trackNumber: item.trackNumber.trim(),
            marketName: item.storeName.trim(),
            urlProduct: item.productLink!.trim(),
            productName: item.productName.trim(),
            productPrice: item.cost,
            productQuantity: item.quantity,
            productWeight: item.weight > 0 ? item.weight : null,
            productColor: item.color!.trim(),
            productSize: item.size?.trim().isNotEmpty == true ? item.size!.trim() : null,
            comment: item.comment?.trim().isNotEmpty == true ? item.comment!.trim() : null,
            receiverAddress: addressId,
            location: widget.locationId ?? 'USA',
            invoiceNumber: DateTime.now().millisecondsSinceEpoch ~/ 1000, 
          );

          debugPrint('=== CREATING ORDER FOR ITEM ===');
          debugPrint('Product: ${item.productName}');
          debugPrint('Track Number: ${item.trackNumber}');

          final order = await apiService.createOrderOwn(request);
          debugPrint('=== ORDER CREATED SUCCESSFULLY ===');
          debugPrint('Order ID: ${order.id}');
          successCount++;
        } catch (e) {
          debugPrint('=== ERROR CREATING ORDER FOR ITEM ===');
          debugPrint('Item: ${item.productName}');
          debugPrint('Error: $e');
          
          // Сохраняем ошибку для показа пользователю
          if (failCount == 0) {
            // Показываем первую ошибку пользователю
            if (mounted && e.toString().contains('Не заполнены')) {
              CustomSnackBar.error(
                context: context,
                message: e.toString().replaceAll('Exception: ', ''),
              );
            }
          }
          failCount++;
        }
      }

      if (!mounted) return;

      if (successCount > 0) {
        // Показываем успешное сообщение
        CustomSnackBar.success(
          context: context,
          message: failCount > 0
              ? '${context.l10n.translate('orders_created')}: $successCount. ${context.l10n.translate('errors')}: $failCount'
              : context.l10n.translate('parcel_created_successfully'),
        );

        // Переходим назад через небольшую задержку
        await Future.delayed(const Duration(milliseconds: 1500));

        if (!mounted) return;
        Navigator.pop(context, true);
      } else {
        // Все заказы не удалось создать
        setState(() {
          _isProcessing = false;
        });

        // Сообщение об ошибке уже показано в catch блоке
        // Здесь показываем только общее сообщение, если не было показано ранее
        if (failCount > 0) {
          CustomSnackBar.error(
            context: context,
            message: '${context.l10n.translate('failed_to_create_orders')}. ${context.l10n.translate('check_all_fields')}',
          );
        }
      }
    } catch (e, stackTrace) {
      debugPrint('=== ERROR IN CHECKOUT ===');
      debugPrint('Error: $e');
      debugPrint('Stack Trace: $stackTrace');

      if (!mounted) return;

      setState(() {
        _isProcessing = false;
      });

      CustomSnackBar.error(
        context: context,
        message: 'Ошибка при оформлении заказа: $e',
      );
    }
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
          onPressed: () => Navigator.pop(context, false),
        ),
        title: Text(
          context.l10n.translate('shipping_calculation'),
          style: TextStyle(color: textColor),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Итоговая стоимость - красивое оформление
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppTheme.gold.withValues(alpha: 0.2),
                        AppTheme.gold.withValues(alpha: 0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: AppTheme.gold.withValues(alpha: 0.5),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.gold.withValues(alpha: 0.2),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                        spreadRadius: -4,
                      ),
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppTheme.gold.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.receipt_long_rounded,
                              color: AppTheme.gold,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                      Text(
                              context.l10n.translate('total_to_pay'),
                        style: TextStyle(
                                color: textColor,
                          fontSize: 14,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text(
                            '\$',
                        style: TextStyle(
                              color: AppTheme.gold.withValues(alpha: 0.7),
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              height: 1,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            widget.shippingCost.total.toStringAsFixed(2).split('.')[0],
                            style: const TextStyle(
                          color: AppTheme.gold,
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -1.5,
                              height: 1,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              '.${widget.shippingCost.total.toStringAsFixed(2).split('.')[1]}',
                              style: TextStyle(
                                color: AppTheme.gold.withValues(alpha: 0.8),
                                fontSize: 28,
                          fontWeight: FontWeight.bold,
                                height: 1,
                              ),
                            ),
                        ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                
                // Детали расчета
                Row(
                  children: [
                    Container(
                      width: 4,
                      height: 24,
                      decoration: BoxDecoration(
                        color: AppTheme.gold,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 12),
                Text(
                      context.l10n.translate('calculation_details'),
                  style: TextStyle(
                    color: textColor,
                        fontSize: 20,
                    fontWeight: FontWeight.bold,
                        letterSpacing: 0.3,
                      ),
                  ),
                  ],
                ),
                const SizedBox(height: 18),
                
                _buildCostRow(
                  context.l10n.translate('shipping'),
                  widget.shippingCost.formattedBaseShipping,
                  '${widget.totalWeight.toStringAsFixed(1)} ${context.l10n.translate('kg')} × ${_getPricePerKg(widget.shippingCost.country)} \$/${context.l10n.translate('kg')}',
                  textColor,
                  textSecondaryColor,
                  cardColor,
                ),
                const SizedBox(height: 12),
                _buildCostRow(
                  'Таможенные сборы',
                  widget.shippingCost.formattedCustoms,
                  '15% от стоимости товара',
                  textColor,
                  textSecondaryColor,
                  cardColor,
                ),
                const SizedBox(height: 24),
                
                // Информация о посылке
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppTheme.gold.withValues(alpha: 0.1),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppTheme.gold.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.info_outline_rounded,
                              color: AppTheme.gold,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                      Text(
                            context.l10n.translate('parcel_info'),
                        style: TextStyle(
                          color: textColor,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow(
                        Icons.shopping_bag_outlined,
                        context.l10n.translate('total_weight'),
                        '${widget.totalWeight.toStringAsFixed(1)} ${context.l10n.translate('kg')}',
                        textColor,
                        textSecondaryColor,
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        Icons.attach_money,
                        context.l10n.translate('items_cost'),
                        '\$${widget.totalCost.toStringAsFixed(2)}',
                        textColor,
                        textSecondaryColor,
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        Icons.inbox_outlined,
                        context.l10n.translate('items_count'),
                        widget.itemCount.toString(),
                        textColor,
                        textSecondaryColor,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Кнопка подтверждения
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
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Opacity(
                    opacity: _fadeAnimation.value,
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                        onPressed: _isProcessing ? null : _handleCheckout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.gold,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                          elevation: _isProcessing ? 0 : 4,
                          shadowColor: AppTheme.gold.withValues(alpha: 0.4),
                        ),
                        child: _isProcessing
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        ThemeHelper.isDark(context)
                                            ? const Color(0xFF0A0E27)
                                            : const Color(0xFF212121),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Оформление...',
                                    style: TextStyle(
                                      color: ThemeHelper.isDark(context)
                                          ? const Color(0xFF0A0E27)
                                          : const Color(0xFF212121),
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.check_circle_outline,
                                    color: ThemeHelper.isDark(context)
                                        ? const Color(0xFF0A0E27)
                                        : const Color(0xFF212121),
                                    size: 24,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    context.l10n.translate('checkout_parcel'),
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
              ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCostRow(
    String label,
    String value,
    String description,
    Color textColor,
    Color textSecondaryColor,
    Color cardColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.gold.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: TextStyle(
                    color: textSecondaryColor,
                    fontSize: 13,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.gold.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
            value,
              style: const TextStyle(
              color: AppTheme.gold,
              fontSize: 18,
              fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value,
    Color textColor,
    Color textSecondaryColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
      children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.gold.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppTheme.gold, size: 18),
          ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: textSecondaryColor,
                fontSize: 15,
                height: 1.4,
              ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: textColor,
              fontSize: 15,
            fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ],
        ),
    );
  }

  String _getPricePerKg(String country) {
    final prices = {
      'USA': '15.00',
      'Turkey': '12.00',
      'China': '8.00',
      'UAE': '10.00',
    };
    return prices[country] ?? '15.00';
  }
}

