import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/theme_helper.dart';
import '../utils/theme.dart';
import '../utils/localization_helper.dart';
import '../providers/theme_provider.dart';
import '../models/product.dart';
import '../widgets/custom_snackbar.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Product product;

  const ProductDetailsScreen({
    super.key,
    required this.product,
  });

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  bool _isFavorite = false;
  int _quantity = 1;
  final PageController _imageController = PageController();
  int _currentImageIndex = 0;

  // Генерируем список изображений для товара
  List<String> get _productImages {
    // Для каждого товара создаем несколько изображений
    return List.generate(3, (index) => widget.product.image);
  }

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.product.isFavorite;
  }

  @override
  void dispose() {
    _imageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        final backgroundColor = ThemeHelper.getBackgroundColor(context);
        final cardColor = ThemeHelper.getCardColor(context);
        final textColor = ThemeHelper.getTextColor(context);
        final textSecondaryColor = ThemeHelper.getTextSecondaryColor(context);
        
        return Scaffold(
          backgroundColor: backgroundColor,
          body: SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: cardColor,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.arrow_back,
                            color: textColor,
                            size: 24,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isFavorite = !_isFavorite;
                          });
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: cardColor,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: _isFavorite ? AppTheme.gold : textColor,
                            size: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Scrollable content
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Product Images Carousel
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            children: [
                              // Main Image Swiper
                              SizedBox(
                                height: 300,
                                child: PageView.builder(
                                  controller: _imageController,
                                  onPageChanged: (index) {
                                    setState(() {
                                      _currentImageIndex = index;
                                    });
                                  },
                                  itemCount: _productImages.length,
                                  itemBuilder: (context, index) {
                                    return Container(
                                      margin: const EdgeInsets.symmetric(horizontal: 4),
                                      decoration: BoxDecoration(
                                        color: ThemeHelper.getSecondaryColor(context),
                                        borderRadius: BorderRadius.circular(24),
                                      ),
                                      child: Center(
                                        child: Icon(
                                          _getProductIcon(_productImages[index]),
                                          size: 150,
                                          color: textSecondaryColor,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 12),
                              // Thumbnail Images
                              SizedBox(
                                height: 60,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: _productImages.length,
                                  itemBuilder: (context, index) {
                                    final isSelected = index == _currentImageIndex;
                                    return GestureDetector(
                                      onTap: () {
                                        _imageController.animateToPage(
                                          index,
                                          duration: const Duration(milliseconds: 300),
                                          curve: Curves.easeInOut,
                                        );
                                      },
                                      child: Container(
                                        width: 60,
                                        height: 60,
                                        margin: const EdgeInsets.only(right: 8),
                                        decoration: BoxDecoration(
                                          color: ThemeHelper.getSecondaryColor(context),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(
                                            color: isSelected
                                                ? AppTheme.gold
                                                : Colors.transparent,
                                            width: 2,
                                          ),
                                        ),
                                        child: Center(
                                          child: Icon(
                                            _getProductIcon(_productImages[index]),
                                            size: 30,
                                            color: textSecondaryColor,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Product Info Card
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(32),
                              topRight: Radius.circular(32),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Category badge
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: AppTheme.gold.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    widget.product.category,
                                    style: TextStyle(
                                      color: AppTheme.gold,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                // Product Name
                                Text(
                                  widget.product.name,
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                // Price
                                Text(
                                  '\$${widget.product.price % 1 == 0 ? widget.product.price.toInt() : widget.product.price.toStringAsFixed(1)}',
                                  style: const TextStyle(
                                    color: AppTheme.gold,
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                // Divider
                                Divider(
                                  color: textSecondaryColor.withValues(alpha: 0.2),
                                  height: 1,
                                ),
                                const SizedBox(height: 24),
                                // Description Section
                                Text(
                                  'Описание',
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  widget.product.description.isNotEmpty
                                      ? widget.product.description
                                      : 'Высококачественный товар премиум-класса с отличными характеристиками и долгим сроком службы.',
                                  style: TextStyle(
                                    color: textSecondaryColor,
                                    fontSize: 16,
                                    height: 1.6,
                                  ),
                                ),
                                const SizedBox(height: 32),
                                // Specifications Section
                                Text(
                                  'Характеристики',
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                _buildSpecificationItem('Бренд', 'Apple', textColor, textSecondaryColor),
                                _buildSpecificationItem('Модель', widget.product.name, textColor, textSecondaryColor),
                                _buildSpecificationItem('Категория', widget.product.category, textColor, textSecondaryColor),
                                _buildSpecificationItem('В наличии', 'Да', textColor, textSecondaryColor),
                                const SizedBox(height: 32),
                                // Quantity Selector
                                Row(
                                  children: [
                                    Text(
                                      'Количество:',
                                      style: TextStyle(
                                        color: textColor,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const Spacer(),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: backgroundColor,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: textSecondaryColor.withValues(alpha: 0.2),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            onPressed: () {
                                              if (_quantity > 1) {
                                                setState(() {
                                                  _quantity--;
                                                });
                                              }
                                            },
                                            icon: Icon(
                                              Icons.remove,
                                              color: textColor,
                                              size: 20,
                                            ),
                                          ),
                                          Container(
                                            width: 50,
                                            alignment: Alignment.center,
                                            child: Text(
                                              _quantity.toString(),
                                              style: TextStyle(
                                                color: textColor,
                                                fontSize: 18,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                          IconButton(
                                            onPressed: () {
                                              setState(() {
                                                _quantity++;
                                              });
                                            },
                                            icon: Icon(
                                              Icons.add,
                                              color: textColor,
                                              size: 20,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 32),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Fixed bottom button
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                  decoration: BoxDecoration(
                    color: cardColor,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    top: false,
                    child: SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          CustomSnackBar.show(
                            context: context,
                            message: '${widget.product.name} ${context.l10n.translate('added_to_cart')}',
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
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.shopping_cart,
                              color: Color(0xFF0A0E27),
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              context.l10n.translate('add_to_cart'),
                              style: TextStyle(
                                color: ThemeHelper.isDark(context) 
                                    ? const Color(0xFF0A0E27) 
                                    : const Color(0xFF212121),
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSpecificationItem(String label, String value, Color textColor, Color textSecondaryColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                color: textSecondaryColor,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: textColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
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
