import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/theme_helper.dart';
import '../utils/theme.dart';
import '../utils/localization_helper.dart';
import '../providers/theme_provider.dart';
import '../widgets/custom_dialog.dart';
import '../widgets/custom_snackbar.dart';

class ShopCartScreen extends StatefulWidget {
  final List<CartItem> cartItems;
  final Function(CartItem) onRemoveItem;
  final Function(CartItem, int) onUpdateQuantity;
  final ScrollController? scrollController;

  const ShopCartScreen({
    super.key,
    required this.cartItems,
    required this.onRemoveItem,
    required this.onUpdateQuantity,
    this.scrollController,
  });

  @override
  State<ShopCartScreen> createState() => _ShopCartScreenState();
}

class _ShopCartScreenState extends State<ShopCartScreen> {
  double get _totalPrice {
    return widget.cartItems.fold(0, (sum, item) => sum + (item.price * item.quantity));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        final textColor = ThemeHelper.getTextColor(context);
        final textSecondaryColor = ThemeHelper.getTextSecondaryColor(context);
        final cardColor = ThemeHelper.getCardColor(context);

        if (widget.cartItems.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.shopping_cart_outlined,
                  size: 80,
                  color: textSecondaryColor,
                ),
                const SizedBox(height: 16),
                Text(
                  context.l10n.translate('cart_empty'),
                  style: TextStyle(
                    color: textSecondaryColor,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: widget.scrollController,
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                itemCount: widget.cartItems.length,
                itemBuilder: (context, index) {
                  final item = widget.cartItems[index];
                  return _buildCartItem(item);
                },
              ),
            ),
            // Order Summary
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        context.l10n.translate('total'),
                        style: TextStyle(
                          color: textColor,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '\$${_totalPrice % 1 == 0 ? _totalPrice.toInt() : _totalPrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: AppTheme.gold,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        CustomSnackBar.show(
                          context: context,
                          message: context.l10n.translate('order_placed'),
                          icon: Icons.check_circle,
                          backgroundColor: AppTheme.gold,
                          iconColor: const Color(0xFF0A0E27),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.gold,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        context.l10n.translate('checkout'),
                        style: TextStyle(
                          color: ThemeHelper.isDark(context) 
                              ? const Color(0xFF0A0E27) 
                              : const Color(0xFF212121),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCartItem(CartItem item) {
    final cardColor = ThemeHelper.getCardColor(context);
    final textColor = ThemeHelper.getTextColor(context);
    final textSecondaryColor = ThemeHelper.getTextSecondaryColor(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Product image
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: ThemeHelper.getSecondaryColor(context),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getProductIcon(item.image),
              size: 40,
              color: textSecondaryColor,
            ),
          ),
          const SizedBox(width: 16),
          // Product info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '\$${item.price % 1 == 0 ? item.price.toInt() : item.price.toStringAsFixed(1)}',
                  style: const TextStyle(
                    color: AppTheme.gold,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          // Quantity controls
          Row(
            children: [
              IconButton(
                onPressed: () {
                  if (item.quantity > 1) {
                    widget.onUpdateQuantity(item, item.quantity - 1);
                  }
                },
                icon: Icon(Icons.remove_circle_outline, color: textColor),
              ),
              Text(
                item.quantity.toString(),
                style: TextStyle(
                  color: textColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              IconButton(
                onPressed: () {
                  widget.onUpdateQuantity(item, item.quantity + 1);
                },
                icon: Icon(Icons.add_circle_outline, color: textColor),
              ),
            ],
          ),
          // Remove button
          IconButton(
            onPressed: () {
              CustomDialog.show(
                context: context,
                title: context.l10n.translate('remove_item'),
                message: context.l10n.translate('remove_item_message').replaceAll('{item}', item.name),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(context.l10n.translate('cancel')),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      widget.onRemoveItem(item);
                      CustomSnackBar.show(
                        context: context,
                        message: context.l10n.translate('item_removed'),
                        icon: Icons.check_circle,
                        backgroundColor: AppTheme.gold,
                        iconColor: const Color(0xFF0A0E27),
                      );
                    },
                    child: Text(context.l10n.translate('remove')),
                  ),
                ],
              );
            },
            icon: Icon(Icons.delete_outline, color: textSecondaryColor),
          ),
        ],
      ),
    );
  }

  IconData _getProductIcon(String image) {
    switch (image) {
      case 'iphone':
        return Icons.smartphone;
      case 'jacket':
        return Icons.checkroom;
      case 'headphones':
        return Icons.headphones;
      case 'macbook':
        return Icons.laptop;
      case 'watch':
        return Icons.watch;
      case 'shoes':
        return Icons.shopping_bag;
      case 'glasses':
        return Icons.remove_red_eye;
      case 'backpack':
        return Icons.backpack;
      default:
        return Icons.shopping_bag;
    }
  }
}

class CartItem {
  final String id;
  final String name;
  final double price;
  final String image;
  int quantity;

  CartItem({
    required this.id,
    required this.name,
    required this.price,
    required this.image,
    this.quantity = 1,
  });
}

