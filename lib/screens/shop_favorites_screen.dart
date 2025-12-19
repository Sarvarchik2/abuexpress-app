import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/theme_helper.dart';
import '../utils/theme.dart';
import '../utils/localization_helper.dart';
import '../providers/theme_provider.dart';
import '../models/product.dart';

class ShopFavoritesScreen extends StatefulWidget {
  final List<Product> favoriteProducts;
  final Function(Product) onProductTap;
  final Function(Product) onToggleFavorite;
  final ScrollController? scrollController;

  const ShopFavoritesScreen({
    super.key,
    required this.favoriteProducts,
    required this.onProductTap,
    required this.onToggleFavorite,
    this.scrollController,
  });

  @override
  State<ShopFavoritesScreen> createState() => _ShopFavoritesScreenState();
}

class _ShopFavoritesScreenState extends State<ShopFavoritesScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        final textSecondaryColor = ThemeHelper.getTextSecondaryColor(context);

        if (widget.favoriteProducts.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.favorite_border,
                  size: 80,
                  color: textSecondaryColor,
                ),
                const SizedBox(height: 16),
                Text(
                  context.l10n.translate('no_favorites'),
                  style: TextStyle(
                    color: textSecondaryColor,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          );
        }

        return GridView.builder(
          controller: widget.scrollController,
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.68,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: widget.favoriteProducts.length,
          itemBuilder: (context, index) {
            return _buildProductCard(widget.favoriteProducts[index]);
          },
        );
      },
    );
  }

  Widget _buildProductCard(Product product) {
    final cardColor = ThemeHelper.getCardColor(context);
    final secondaryColor = ThemeHelper.getSecondaryColor(context);
    final textColor = ThemeHelper.getTextColor(context);
    final textSecondaryColor = ThemeHelper.getTextSecondaryColor(context);
    
    return GestureDetector(
      onTap: () => widget.onProductTap(product),
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Product image
            Expanded(
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: secondaryColor,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        _getProductIcon(product.image),
                        size: 80,
                        color: textSecondaryColor,
                      ),
                    ),
                  ),
                  // Favorite icon
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () => widget.onToggleFavorite(product),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.3),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          product.isFavorite
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: product.isFavorite
                              ? AppTheme.gold
                              : textColor,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Product info
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    product.name,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${product.price % 1 == 0 ? product.price.toInt() : product.price.toStringAsFixed(1)}',
                    style: const TextStyle(
                      color: Color(0xFFFFD700),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
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

