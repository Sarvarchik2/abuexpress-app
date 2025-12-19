import 'package:flutter/material.dart';
import '../models/shipping_calculator.dart';
import '../utils/theme_helper.dart';
import '../utils/theme.dart' show AppTheme;
import '../utils/localization_helper.dart';

class ShippingCalculatorScreen extends StatelessWidget {
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
                // Итоговая стоимость
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppTheme.gold.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppTheme.gold,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        context.l10n.translate('total_to_pay'),
                        style: TextStyle(
                          color: textSecondaryColor,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        shippingCost.formattedTotal,
                        style: TextStyle(
                          color: AppTheme.gold,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                // Детали расчета
                Text(
                  context.l10n.translate('calculation_details'),
                  style: TextStyle(
                    color: textColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                _buildCostRow(
                  context.l10n.translate('shipping'),
                  shippingCost.formattedBaseShipping,
                  '$totalWeight ${context.l10n.translate('kg')} × ${_getPricePerKg(shippingCost.country)} \$/${context.l10n.translate('kg')}',
                  textColor,
                  textSecondaryColor,
                  cardColor,
                ),
                const SizedBox(height: 12),
                _buildCostRow(
                  context.l10n.translate('insurance'),
                  shippingCost.formattedInsurance,
                  '2% от стоимости товара',
                  textColor,
                  textSecondaryColor,
                  cardColor,
                ),
                const SizedBox(height: 12),
                _buildCostRow(
                  context.l10n.translate('packaging'),
                  shippingCost.formattedPackaging,
                  '$itemCount × 5.00 \$',
                  textColor,
                  textSecondaryColor,
                  cardColor,
                ),
                const SizedBox(height: 24),
                
                // Информация о посылке
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.l10n.translate('parcel_info'),
                        style: TextStyle(
                          color: textColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        Icons.shopping_bag_outlined,
                        context.l10n.translate('total_weight'),
                        '$totalWeight ${context.l10n.translate('kg')}',
                        textColor,
                        textSecondaryColor,
                      ),
                      const SizedBox(height: 8),
                      _buildInfoRow(
                        Icons.attach_money,
                        context.l10n.translate('items_cost'),
                        '\$${totalCost.toStringAsFixed(2)}',
                        textColor,
                        textSecondaryColor,
                      ),
                      const SizedBox(height: 8),
                      _buildInfoRow(
                        Icons.inbox_outlined,
                        context.l10n.translate('items_count'),
                        itemCount.toString(),
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
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.gold,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  context.l10n.translate('checkout_parcel'),
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

  Widget _buildCostRow(
    String label,
    String value,
    String description,
    Color textColor,
    Color textSecondaryColor,
    Color cardColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: textSecondaryColor,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: AppTheme.gold,
              fontSize: 18,
              fontWeight: FontWeight.bold,
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
    return Row(
      children: [
        Icon(icon, color: AppTheme.gold, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: textSecondaryColor,
              fontSize: 14,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: textColor,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
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

