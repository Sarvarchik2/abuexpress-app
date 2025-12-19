import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'cart_screen.dart';
import '../widgets/bottom_navigation_bar.dart';
import '../providers/theme_provider.dart';
import '../utils/theme_helper.dart';
import '../utils/theme.dart';
import '../utils/localization_helper.dart';

class FavoritesScreen extends StatefulWidget {
  final int currentIndex;
  final Function(int) onNavTap;
  
  const FavoritesScreen({
    super.key,
    required this.currentIndex,
    required this.onNavTap,
  });

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final List<Product> _favoriteProducts = [
    Product(
      id: '1',
      name: 'Смартфон iPhone 15 Pro',
      price: 999,
      image: 'iphone',
      isFavorite: true,
      category: 'Электроника',
    ),
    Product(
      id: '3',
      name: 'Беспроводные наушники',
      price: 199,
      image: 'headphones',
      isFavorite: true,
      category: 'Аксессуары',
    ),
    Product(
      id: '5',
      name: 'Умные часы Apple Watch',
      price: 449,
      image: 'watch',
      isFavorite: true,
      category: 'Электроника',
    ),
    Product(
      id: '6',
      name: 'Кроссовки Nike Air Max',
      price: 149,
      image: 'shoes',
      isFavorite: true,
      category: 'Одежда',
    ),
  ];

  int _cartItemsCount = 2;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = ThemeHelper.getBackgroundColor(context);
    
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return Scaffold(
          backgroundColor: backgroundColor,
          body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        context.l10n.translate('favorites'),
                        style: TextStyle(
                          color: ThemeHelper.getTextColor(context),
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CartScreen(),
                            ),
                          );
                        },
                        child: Stack(
                          children: [
                            Icon(
                              Icons.shopping_cart_outlined,
                              color: ThemeHelper.getTextColor(context),
                              size: 28,
                            ),
                            if (_cartItemsCount > 0)
                              Positioned(
                                right: 0,
                                top: 0,
                                child: Container(
                                  width: 18,
                                  height: 18,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFFFD700),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      _cartItemsCount.toString(),
                                      style: TextStyle(
                                        color: ThemeHelper.isDark(context) ? const Color(0xFF0A0E27) : const Color(0xFF212121),
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
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
                const SizedBox(height: 16),
                // Products grid
                Expanded(
                  child: _favoriteProducts.isEmpty
                      ? _buildEmptyState()
                      : GridView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.68,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                          itemCount: _favoriteProducts.length,
                          itemBuilder: (context, index) {
                            return _buildProductCard(_favoriteProducts[index]);
                          },
                        ),
                ),
              ],
            ),
          ),
          // Навигация прикреплена к низу
          CustomBottomNavigationBar(
            currentIndex: widget.currentIndex,
            onTap: widget.onNavTap,
          ),
        ],
      ),
    );
      },
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 100),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: ThemeHelper.getCardColor(context),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.favorite_border,
              color: ThemeHelper.getTextSecondaryColor(context),
              size: 60,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            context.l10n.translate('no_favorites'),
            style: TextStyle(
              color: ThemeHelper.getTextColor(context),
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              context.l10n.translate('add_to_favorites'),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: ThemeHelper.getTextSecondaryColor(context),
                fontSize: 14,
              ),
            ),
          ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    final cardColor = ThemeHelper.getCardColor(context);
    final secondaryColor = ThemeHelper.getSecondaryColor(context);
    final textColor = ThemeHelper.getTextColor(context);
    final textSecondaryColor = ThemeHelper.getTextSecondaryColor(context);
    
    return Container(
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
                    onTap: () {
                      setState(() {
                        _favoriteProducts.removeWhere((p) => p.id == product.id);
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.3),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.favorite,
                        color: AppTheme.gold,
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
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  height: 36,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _cartItemsCount++;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${product.name} ${context.l10n.translate('added_to_cart')}'),
                          backgroundColor: const Color(0xFFFFD700),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFD700),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                      padding: EdgeInsets.zero,
                    ),
                    child: Text(
                      context.l10n.translate('add_to_cart'),
                      style: TextStyle(
                        color: ThemeHelper.isDark(context) ? const Color(0xFF0A0E27) : const Color(0xFF212121),
                        fontSize: 12,
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

class Product {
  final String id;
  final String name;
  final double price;
  final String image;
  bool isFavorite;
  final String category;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.image,
    required this.isFavorite,
    required this.category,
  });
}
