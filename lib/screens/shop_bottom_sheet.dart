import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'product_details_screen.dart';
import 'shop_home_screen.dart';
import 'shop_favorites_screen.dart';
import 'shop_cart_screen.dart';
import '../utils/theme_helper.dart';
import '../utils/theme.dart';
import '../utils/localization_helper.dart';
import '../providers/theme_provider.dart';
import '../models/product.dart';

// Импортируем CartItem из модели

// Observer для отслеживания изменений в Navigator
class _NavigatorObserver extends NavigatorObserver {
  final Function(bool canPop) onRouteChanged;

  _NavigatorObserver({required this.onRouteChanged});

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    // Откладываем вызов, чтобы избежать проблем во время сборки
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final navigator = route.navigator;
      if (navigator != null && navigator.mounted) {
        onRouteChanged(navigator.canPop());
      } else {
        onRouteChanged(true);
      }
    });
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    // Откладываем вызов, чтобы избежать проблем во время сборки
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final navigator = route.navigator;
      if (navigator != null && navigator.mounted) {
        onRouteChanged(navigator.canPop());
      } else {
        onRouteChanged(false);
      }
    });
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didRemove(route, previousRoute);
    // Откладываем вызов, чтобы избежать проблем во время сборки
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final navigator = route.navigator;
      if (navigator != null && navigator.mounted) {
        onRouteChanged(navigator.canPop());
      } else {
        onRouteChanged(false);
      }
    });
  }
}

class ShopBottomSheet extends StatefulWidget {
  const ShopBottomSheet({super.key});

  @override
  State<ShopBottomSheet> createState() => _ShopBottomSheetState();
}

class _ShopBottomSheetState extends State<ShopBottomSheet> {
  int _shopNavIndex = 0;
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  bool _showNavigationBar = true;
  final ScrollController _scrollController = ScrollController();
  bool _isScrollingDown = false;
  double _lastScrollOffset = 0;
  
  final List<Product> _products = [
    Product(
      id: '1',
      name: 'Смартфон iPhone 15 Pro',
      price: 999,
      image: 'iphone',
      isFavorite: true,
      category: 'Электроника',
      description: 'Новейший смартфон от Apple с титановым корпусом, чипом A17 Pro и камерой ProRAW.',
    ),
    Product(
      id: '2',
      name: 'Дизайнерская куртка',
      price: 299,
      image: 'jacket',
      isFavorite: false,
      category: 'Одежда',
      description: 'Стильная куртка премиум-класса из качественных материалов.',
    ),
    Product(
      id: '3',
      name: 'Беспроводные наушники',
      price: 199,
      image: 'headphones',
      isFavorite: false,
      category: 'Аксессуары',
      description: 'Высококачественные беспроводные наушники с активным шумоподавлением.',
    ),
    Product(
      id: '4',
      name: 'MacBook Pro 16',
      price: 2499,
      image: 'macbook',
      isFavorite: false,
      category: 'Электроника',
      description: 'Мощный ноутбук для профессионалов с дисплеем Liquid Retina XDR.',
    ),
    Product(
      id: '5',
      name: 'Apple Watch Series 9',
      price: 399,
      image: 'watch',
      isFavorite: false,
      category: 'Электроника',
      description: 'Умные часы с расширенными функциями здоровья и фитнеса.',
    ),
    Product(
      id: '6',
      name: 'Кроссовки Nike Air Max',
      price: 149,
      image: 'shoes',
      isFavorite: true,
      category: 'Одежда',
      description: 'Комфортные кроссовки с технологией Air Max для максимальной амортизации.',
    ),
    Product(
      id: '7',
      name: 'Солнечные очки Ray-Ban',
      price: 179,
      image: 'glasses',
      isFavorite: false,
      category: 'Аксессуары',
      description: 'Классические солнцезащитные очки с защитой от ультрафиолета.',
    ),
    Product(
      id: '8',
      name: 'Рюкзак The North Face',
      price: 129,
      image: 'backpack',
      isFavorite: false,
      category: 'Аксессуары',
      description: 'Прочный и функциональный рюкзак для повседневного использования.',
    ),
  ];

  final List<CartItem> _cartItems = [
    CartItem(
      id: '4',
      name: 'MacBook Pro 16',
      price: 2499,
      image: 'macbook',
      quantity: 1,
    ),
    CartItem(
      id: '5',
      name: 'Apple Watch Series 9',
      price: 399,
      image: 'watch',
      quantity: 1,
    ),
  ];

  List<Product> get _favoriteProducts {
    return _products.where((p) => p.isFavorite).toList();
  }

  int get _cartItemsCount => _cartItems.length;

  void _onProductTap(Product product) {
    Navigator.of(_navigatorKey.currentContext!).push(
      MaterialPageRoute(
        builder: (context) => ProductDetailsScreen(product: product),
      ),
    );
  }

  void _onToggleFavorite(Product product) {
    setState(() {
      product.isFavorite = !product.isFavorite;
    });
  }

  void _onRemoveCartItem(CartItem item) {
    setState(() {
      _cartItems.removeWhere((i) => i.id == item.id);
    });
  }

  void _onUpdateQuantity(CartItem item, int quantity) {
    setState(() {
      final index = _cartItems.indexWhere((i) => i.id == item.id);
      if (index != -1) {
        _cartItems[index].quantity = quantity;
      }
    });
  }

  void _onNavTap(int index) {
    if (_shopNavIndex == index) return; // Если уже на этой вкладке, ничего не делаем
    
    setState(() {
      _shopNavIndex = index;
      _isScrollingDown = false; // Сбрасываем состояние скролла при переключении вкладок
    });
    // Очищаем стек навигации при переключении вкладок
    _navigatorKey.currentState?.popUntil((route) => route.isFirst);
    // Сбрасываем скролл
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0);
    }
  }

  Widget _buildCurrentScreen() {
    switch (_shopNavIndex) {
      case 0:
        return ShopHomeScreen(
          products: _products,
          onProductTap: _onProductTap,
          onToggleFavorite: _onToggleFavorite,
          scrollController: _scrollController,
        );
      case 1:
        return ShopFavoritesScreen(
          favoriteProducts: _favoriteProducts,
          onProductTap: _onProductTap,
          onToggleFavorite: _onToggleFavorite,
          scrollController: _scrollController,
        );
      case 2:
        return ShopHomeScreen(
          products: _products,
          onProductTap: _onProductTap,
          onToggleFavorite: _onToggleFavorite,
          scrollController: _scrollController,
        );
      case 3:
        return ShopCartScreen(
          cartItems: _cartItems,
          onRemoveItem: _onRemoveCartItem,
          onUpdateQuantity: _onUpdateQuantity,
          scrollController: _scrollController,
        );
      default:
        return ShopHomeScreen(
          products: _products,
          onProductTap: _onProductTap,
          onToggleFavorite: _onToggleFavorite,
        );
    }
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    
    final currentOffset = _scrollController.offset;
    final delta = currentOffset - _lastScrollOffset;
    
    // Скрываем навигацию только при скролле вниз более чем на 10px
    // Показываем при скролле вверх или если скролл меньше 10px
    if (delta > 10 && currentOffset > 50) {
      if (!_isScrollingDown) {
        setState(() {
          _isScrollingDown = true;
        });
      }
    } else if (delta < -10 || currentOffset <= 50) {
      if (_isScrollingDown) {
        setState(() {
          _isScrollingDown = false;
        });
      }
    }
    
    _lastScrollOffset = currentOffset;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        final backgroundColor = ThemeHelper.getBackgroundColor(context);
        
        return Container(
          height: MediaQuery.of(context).size.height * 0.9,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(28),
              topRight: Radius.circular(28),
            ),
          ),
          child: Stack(
            children: [
              Column(
                children: [
                  // Drag handle
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: ThemeHelper.getTextSecondaryColor(context),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.flight_takeoff_rounded,
                              color: AppTheme.gold,
                              size: 28,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              context.l10n.translate('shop'),
                              style: TextStyle(
                                color: ThemeHelper.getTextColor(context),
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        // Показываем кнопку "назад" на экране корзины, иначе кнопку "закрыть"
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              if (_shopNavIndex == 3) {
                                // На экране корзины - возвращаемся на главный экран
                                _onNavTap(0);
                              } else {
                                // На других экранах - закрываем bottom sheet
                                Navigator.pop(context);
                              }
                            },
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: ThemeHelper.getCardColor(context),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _shopNavIndex == 3 ? Icons.arrow_back : Icons.close,
                                color: ThemeHelper.getTextColor(context),
                                size: 24,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Navigator для экранов магазина
                  Expanded(
                    child: Navigator(
                      key: _navigatorKey,
                      onGenerateRoute: (settings) {
                        return MaterialPageRoute(
                          builder: (context) => _buildCurrentScreen(),
                          settings: settings,
                        );
                      },
                      observers: [
                        _NavigatorObserver(
                          onRouteChanged: (canPop) {
                            if (mounted) {
                              // Откладываем setState до завершения текущего кадра сборки
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                if (mounted) {
                                  setState(() {
                                    _showNavigationBar = !canPop;
                                  });
                                }
                              });
                            }
                          },
                        ),
                      ],
                      onGenerateInitialRoutes: (NavigatorState navigator, String initialRoute) {
                        // Возвращаем начальный маршрут
                        return [
                          MaterialPageRoute(
                            builder: (context) => _buildCurrentScreen(),
                            settings: RouteSettings(name: initialRoute),
                          ),
                        ];
                      },
                    ),
                  ),
                ],
              ),
              // Shop Navigation Bar (floating) - показываем только если нет открытых экранов и не на экране корзины
              if (_showNavigationBar && _shopNavIndex != 3) 
                _buildShopNavigationBar(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildShopNavigationBar() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        offset: _isScrollingDown ? const Offset(0, 1.2) : Offset.zero,
        child: Material(
          color: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: ThemeHelper.isDark(context) 
                        ? Colors.black.withValues(alpha: 0.1)
                        : Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: ThemeHelper.isDark(context)
                          ? Colors.white.withValues(alpha: 0.15)
                          : Colors.black.withValues(alpha: 0.1),
                      width: 0.5,
                    ),
                  ),
                  child: SafeArea(
                    top: false,
                    bottom: false,
                    child: SizedBox(
                      height: 65,
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildShopNavItem(Icons.home_outlined, context.l10n.translate('home'), 0),
                            const SizedBox(width: 12),
                            _buildShopNavItem(Icons.favorite_outline, context.l10n.translate('favorites'), 1),
                            const SizedBox(width: 12),
                            _buildShopNavItem(Icons.category_outlined, context.l10n.translate('categories'), 2),
                            const SizedBox(width: 12),
                            _buildShopNavItem(Icons.shopping_cart_outlined, context.l10n.translate('cart'), 3, badge: _cartItemsCount),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShopNavItem(IconData icon, String label, int index, {int? badge}) {
    final isSelected = _shopNavIndex == index;
    final textColor = ThemeHelper.getTextColor(context);
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          debugPrint('Nav item tapped: $index');
          _onNavTap(index);
        },
        borderRadius: BorderRadius.circular(60),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFFB8860B).withValues(alpha: 0.9)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(60),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(
                    icon,
                    color: isSelected
                        ? const Color(0xFFFFD700)
                        : textColor,
                    size: 20,
                  ),
                  if (badge != null && badge > 0)
                    Positioned(
                      right: -8,
                      top: -8,
                      child: Container(
                        width: 18,
                        height: 18,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFFD700),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            badge > 9 ? '9+' : badge.toString(),
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
              const SizedBox(height: 3),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 250),
                style: TextStyle(
                  color: isSelected
                      ? const Color(0xFFFFD700)
                      : textColor,
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  letterSpacing: -0.2,
                ),
                child: Text(label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
