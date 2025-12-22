import 'package:flutter/material.dart';
import '../models/shipping_calculator.dart';
import '../utils/theme_helper.dart';
import '../utils/theme.dart' show AppTheme;
import '../utils/localization_helper.dart';
import '../widgets/custom_snackbar.dart';

class ShippingCalculatorScreen extends StatefulWidget {
  final ShippingCost shippingCost;
  final double totalWeight;
  final double totalCost;
  final int itemCount;

  const ShippingCalculatorScreen({
    super.key,
    required this.shippingCost,
    required this.totalWeight,
    required this.totalCost,
    required this.itemCount,
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
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    // Анимация нажатия
    await _animationController.forward();
    await _animationController.reverse();

    // Имитация обработки
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    // Показываем успешное сообщение
    CustomSnackBar.success(
      context: context,
      message: 'Посылка успешно оформлена!',
    );

    // Переходим назад через небольшую задержку
    await Future.delayed(const Duration(milliseconds: 1500));

    if (!mounted) return;

    Navigator.pop(context, true);
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

