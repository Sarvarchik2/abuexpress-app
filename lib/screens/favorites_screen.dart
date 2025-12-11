import 'package:flutter/material.dart';
import 'cart_screen.dart';
import '../widgets/bottom_navigation_bar.dart';

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
  List<Product> _favoriteProducts = [
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
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
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
                      const Text(
                        'Избранное',
                        style: TextStyle(
                          color: Colors.white,
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
                            const Icon(
                              Icons.shopping_cart_outlined,
                              color: Colors.white,
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
                                      style: const TextStyle(
                                        color: Color(0xFF0A0E27),
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
                color: const Color(0xFF1A1F3A),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.favorite_border,
                color: Colors.white54,
                size: 60,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'У вас пока нет избранных товаров',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Добавьте товары в избранное, чтобы они появились здесь',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white54,
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
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F3A),
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
                    color: const Color(0xFF2A2F4A),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      _getProductIcon(product.image),
                      size: 80,
                      color: Colors.white.withOpacity(0.3),
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
                        color: Colors.black.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.favorite,
                        color: Color(0xFFFFD700),
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
                  style: const TextStyle(
                    color: Colors.white,
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
                    child: const Text(
                      'В корзину',
                      style: TextStyle(
                        color: Color(0xFF0A0E27),
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
