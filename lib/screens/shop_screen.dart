import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'cart_screen.dart';
import '../widgets/bottom_navigation_bar.dart';
import '../utils/theme_helper.dart';
import '../utils/theme.dart';
import '../providers/theme_provider.dart';

class ShopScreen extends StatefulWidget {
  final int currentIndex;
  final Function(int) onNavTap;
  
  const ShopScreen({
    super.key,
    required this.currentIndex,
    required this.onNavTap,
  });

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  String _selectedCategory = 'Все';
  final List<String> _categories = ['Все', 'Электроника', 'Аксессуары', 'Одежда'];
  final List<Product> _products = [
    Product(
      id: '1',
      name: 'Смартфон iPhone 15 Pro',
      price: 999,
      image: 'iphone',
      isFavorite: true,
      category: 'Электроника',
    ),
    Product(
      id: '2',
      name: 'Дизайнерская куртка',
      price: 299,
      image: 'jacket',
      isFavorite: false,
      category: 'Одежда',
    ),
    Product(
      id: '3',
      name: 'Беспроводные наушники',
      price: 199,
      image: 'headphones',
      isFavorite: false,
      category: 'Аксессуары',
    ),
    Product(
      id: '4',
      name: 'MacBook Pro 16',
      price: 2499,
      image: 'macbook',
      isFavorite: false,
      category: 'Электроника',
    ),
    Product(
      id: '5',
      name: 'Apple Watch Series 9',
      price: 399,
      image: 'watch',
      isFavorite: false,
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
    Product(
      id: '7',
      name: 'Солнечные очки Ray-Ban',
      price: 179,
      image: 'glasses',
      isFavorite: false,
      category: 'Аксессуары',
    ),
    Product(
      id: '8',
      name: 'Рюкзак The North Face',
      price: 129,
      image: 'backpack',
      isFavorite: false,
      category: 'Аксессуары',
    ),
  ];

  int _cartItemsCount = 2;

  @override
  Widget build(BuildContext context) {
    final filteredProducts = _selectedCategory == 'Все'
        ? _products
        : _products.where((p) => p.category == _selectedCategory).toList();

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        final backgroundColor = ThemeHelper.getBackgroundColor(context);
        
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
                    'Магазин',
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
            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: ThemeHelper.getCardColor(context),
                  borderRadius: BorderRadius.circular(44),
                ),
                child: TextField(
                  style: TextStyle(color: ThemeHelper.getTextColor(context)),
                  decoration: InputDecoration(
                    hintText: 'Поиск товаров...',
                    hintStyle: TextStyle(
                      color: ThemeHelper.getTextSecondaryColor(context),
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: ThemeHelper.getTextSecondaryColor(context),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
            ),
            // Category filters
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  final isSelected = category == _selectedCategory;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.gold
                            : ThemeHelper.getCardColor(context),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Text(
                          category,
                          style: TextStyle(
                            color: isSelected
                                ? (ThemeHelper.isDark(context) ? const Color(0xFF0A0E27) : const Color(0xFF212121))
                                : ThemeHelper.getTextColor(context),
                            fontSize: 14,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            // Products grid
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.68,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: filteredProducts.length,
                itemBuilder: (context, index) {
                  return _buildProductCard(filteredProducts[index]);
                },
              ),
            ),
            // Spacer для навигации
            // const SizedBox(height: 80),
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
                        product.isFavorite = !product.isFavorite;
                      });
                    },
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
                    color: Color(0xFFFFD700), // Желтый цвет цены
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
                          content: Text('${product.name} добавлен в корзину'),
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
                      'В корзину',
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

