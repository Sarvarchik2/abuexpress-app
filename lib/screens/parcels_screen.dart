import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'add_parcel_screen.dart';
import 'parcel_details_screen.dart';
import 'profile_screen.dart';
import '../models/parcel.dart';
import '../models/parcel_item.dart';
import '../models/api/order_own.dart';
import '../models/notification.dart';
import '../services/api_service.dart';
import '../widgets/bottom_navigation_bar.dart';
import '../widgets/notifications_bottom_sheet.dart';
import '../utils/theme_helper.dart';
import '../utils/localization_helper.dart';
import '../utils/theme.dart';
import '../providers/user_provider.dart';

class ParcelsScreen extends StatefulWidget {
  final int currentIndex;
  final Function(int) onNavTap;
  
  const ParcelsScreen({
    super.key,
    required this.currentIndex,
    required this.onNavTap,
  });

  @override
  State<ParcelsScreen> createState() => _ParcelsScreenState();
}

class _ParcelsScreenState extends State<ParcelsScreen> with WidgetsBindingObserver {
  String _selectedFilterKey = 'all';
  final List<Parcel> _parcels = [];
  late final ApiService _apiService;
  bool _isLoading = false;
  DateTime? _lastUpdateTime;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Получаем токен из UserProvider и создаем ApiService с токеном
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final token = userProvider.authToken;
    _apiService = ApiService(authToken: token);
    _loadParcels();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Обновляем данные при возврате приложения в активное состояние
    if (state == AppLifecycleState.resumed) {
      _loadParcels();
    }
  }

  @override
  void didUpdateWidget(ParcelsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Обновляем данные при переключении на вкладку посылок
    if (widget.currentIndex == 0 && oldWidget.currentIndex != 0) {
      _loadParcels();
    }
  }


  Future<void> _loadParcels() async {
    setState(() {
      _isLoading = true;
    });

    try {
      debugPrint('=== LOADING PARCELS FROM API ===');
      final orders = await _apiService.getOrderOwn();
      debugPrint('=== ORDERS LOADED ===');
      debugPrint('Total orders: ${orders.length}');

      // Группируем заказы по track_number для создания посылок
      final Map<String, List<OrderOwn>> ordersByTrack = {};
      for (final order in orders) {
        final track = order.trackNumber.isNotEmpty ? order.trackNumber : 'order_${order.id}';
        if (!ordersByTrack.containsKey(track)) {
          ordersByTrack[track] = [];
        }
        ordersByTrack[track]!.add(order);
      }

      debugPrint('=== GROUPED ORDERS ===');
      debugPrint('Unique tracks: ${ordersByTrack.length}');

      // Преобразуем заказы в посылки
      final parcels = <Parcel>[];
      for (final entry in ordersByTrack.entries) {
        final orders = entry.value;
        if (orders.isEmpty) continue;

        // Берем первый заказ для основной информации
        final firstOrder = orders.first;

        // Преобразуем заказы в ParcelItem
        final items = orders.map((order) {
          return ParcelItem(
            id: order.id.toString(),
            trackNumber: order.trackNumber,
            storeName: order.marketName,
            productName: order.productName,
            productLink: order.urlProduct.isNotEmpty ? order.urlProduct : null,
            cost: order.productPrice.toDouble(),
            weight: order.productWeight?.toDouble() ?? 0.0,
            color: order.productColor.isNotEmpty ? order.productColor : null,
            size: order.productSize,
            quantity: order.productQuantity,
            comment: order.comment,
          );
        }).toList();

        // Используем ключ статуса напрямую
        String statusKey = firstOrder.status;

        // Определяем страну отправления на основе названия магазина
        String? originCountry = _determineOriginCountry(firstOrder.marketName);

        parcels.add(Parcel(
          id: firstOrder.id.toString(),
          items: items,
          status: statusKey, // Сохраняем ключ вместо переведенной строки
          dateAdded: firstOrder.dateAdded,
          deliveryAddressId: firstOrder.receiverAddress.toString(),
          originCountry: originCountry,
          shippingCost: null, // Можно добавить позже
          isAccepted: firstOrder.isAccepted,
          isRejected: firstOrder.isRejected,
          isShipped: firstOrder.isShipped,
          isArrived: firstOrder.isArrived,
          isDelivered: firstOrder.isDelivered,
          isWaiting: firstOrder.isWaiting,
        ));
      }

      debugPrint('=== PARCELS CREATED ===');
      debugPrint('Total parcels: ${parcels.length}');

      if (mounted) {
        setState(() {
          _parcels.clear();
          _parcels.addAll(parcels);
          _isLoading = false;
          _lastUpdateTime = DateTime.now();
        });
        debugPrint('=== PARCELS UPDATED ===');
        debugPrint('Update time: ${_lastUpdateTime}');
      }
    } catch (e, stackTrace) {
      debugPrint('=== ERROR LOADING PARCELS ===');
      debugPrint('Error: $e');
      debugPrint('Stack Trace: $stackTrace');

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String? _determineOriginCountry(String marketName) {
    final marketNameLower = marketName.toLowerCase();
    
    if (marketNameLower.contains('amazon') || 
        marketNameLower.contains('ebay') ||
        marketNameLower.contains('walmart') ||
        marketNameLower.contains('target')) {
      return 'USA';
    } else if (marketNameLower.contains('aliexpress') || 
               marketNameLower.contains('taobao') ||
               marketNameLower.contains('1688')) {
      return 'China';
    } else if (marketNameLower.contains('trendyol') || 
               marketNameLower.contains('hepsiburada') ||
               marketNameLower.contains('gitti')) {
      return 'Turkey';
    } else if (marketNameLower.contains('noon') || 
               marketNameLower.contains('amazon.ae')) {
      return 'UAE';
    }
    
    return null; // Не удалось определить
  }

  String _getStatusLabelFromKey(String statusKey) {
    // Перевод статусов через локализацию
    switch (statusKey.toLowerCase()) {
      case 'delivered':
      case 'is_delivered':
        return context.l10n.translate('delivered');
      case 'in_warehouse':
      case 'is_in_warehouse':
        return context.l10n.translate('in_warehouse');
      case 'in_transit':
      case 'is_shipped':
        return context.l10n.translate('in_transit');
      case 'at_customs':
        return context.l10n.translate('at_customs');
      case 'rejected':
      case 'is_rejected':
        return context.l10n.translate('rejected');
      case 'accepted':
      case 'is_accepted':
        return context.l10n.translate('accepted');
      case 'pending':
      case 'is_waiting':
        return context.l10n.translate('pending');
      default:
        return statusKey;
    }
  }

  List<String> _getFilters(BuildContext context) {
    return ['all', 'in_warehouse', 'in_transit', 'at_customs', 'delivered'];
  }

  String _getFilterLabel(String key, BuildContext context) {
    switch (key) {
      case 'all':
        return context.l10n.translate('all');
      case 'in_warehouse':
        return context.l10n.translate('in_warehouse');
      case 'in_transit':
        return context.l10n.translate('in_transit');
      case 'at_customs':
        return context.l10n.translate('at_customs');
      case 'delivered':
        return context.l10n.translate('delivered');
      default:
        return key;
    }
  }

  List<NotificationItem> get _notifications => [
    NotificationItem(
      id: '1',
      title: context.l10n.translate('parcel_arrived'),
      description: '${context.l10n.translate('parcel_arrived')} ABU123456',
      dateTime: DateTime.now().subtract(const Duration(hours: 2)),
      type: NotificationType.parcelArrived,
      isRead: false,
    ),
    NotificationItem(
      id: '2',
      title: context.l10n.translate('parcel_in_transit'),
      description: '${context.l10n.translate('parcel_in_transit')} ABU789012',
      dateTime: DateTime.now().subtract(const Duration(hours: 5)),
      type: NotificationType.parcelInTransit,
      isRead: false,
    ),
    NotificationItem(
      id: '3',
      title: context.l10n.translate('special_offer'),
      description: context.l10n.translate('special_offer'),
      dateTime: DateTime.now().subtract(const Duration(days: 1)),
      type: NotificationType.specialOffer,
      isRead: true,
    ),
    NotificationItem(
      id: '4',
      title: context.l10n.translate('app_update'),
      description: context.l10n.translate('app_update'),
      dateTime: DateTime.now().subtract(const Duration(days: 2)),
      type: NotificationType.appUpdate,
      isRead: true,
    ),
    NotificationItem(
      id: '5',
      title: context.l10n.translate('parcel_delivered'),
      description: '${context.l10n.translate('parcel_delivered')} ABU345678',
      dateTime: DateTime.now().subtract(const Duration(days: 3)),
      type: NotificationType.parcelDelivered,
      isRead: true,
    ),
    NotificationItem(
      id: '6',
      title: context.l10n.translate('new_products'),
      description: context.l10n.translate('new_products'),
      dateTime: DateTime.now().subtract(const Duration(days: 4)),
      type: NotificationType.newProducts,
      isRead: true,
    ),
  ];

  int get _unreadNotificationsCount => _notifications.where((n) => !n.isRead).length;

  void _showNotificationsBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => NotificationsBottomSheet(
          notifications: _notifications,
          scrollController: scrollController,
          onNotificationTap: (notificationId) {
            // Обновляем состояние для обновления счетчика
            if (mounted) {
              setState(() {});
            }
          },
        ),
      ),
    ).then((_) {
      // Обновляем счетчик после закрытия bottom sheet
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = ThemeHelper.getBackgroundColor(context);
    
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                // Header with user profile
                _buildHeader(),
                const SizedBox(height: 10),
                // Filter buttons
                _buildFilters(),
                const SizedBox(height: 24),
                // My Parcels section
                _buildMyParcelsHeader(context),
                const SizedBox(height: 16),
                // Empty state or parcel list
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _parcels.isEmpty
                          ? RefreshIndicator(
                              onRefresh: _loadParcels,
                              child: SingleChildScrollView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                child: _buildEmptyState(context),
                              ),
                            )
                          : RefreshIndicator(
                              onRefresh: _loadParcels,
                              child: _buildParcelsList(context),
                            ),
                ),
                // Spacer для навигации
                const SizedBox(height: 80),
              ],
            ),
          ),
          // Навигация прикреплена к низу
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: CustomBottomNavigationBar(
            currentIndex: widget.currentIndex,
            onTap: widget.onNavTap,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final textColor = ThemeHelper.getTextColor(context);
    final textSecondaryColor = ThemeHelper.getTextSecondaryColor(context);
    final userProvider = Provider.of<UserProvider>(context);
    final userInfo = userProvider.userInfo;
    final fullName = userInfo?.fullName ?? context.l10n.translate('user');
    final userId = userInfo?.id ?? 0;
    final initials = userProvider.getInitials();
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          // Avatar - кликабельно для перехода в профиль
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfileScreen(),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(30),
              child: Stack(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: const BoxDecoration(
                      color: AppTheme.gold,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        initials,
                        style: TextStyle(
                          color: ThemeHelper.isDark(context) ? const Color(0xFF0A0E27) : const Color(0xFF212121),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: ThemeHelper.isDark(context) ? const Color(0xFF0A0E27) : Colors.white,
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 12,
                  ),
                ),
              ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          // User info - кликабельно для перехода в профиль
          Expanded(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfileScreen(),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fullName,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ID: $userId',
                        style: TextStyle(
                          color: textSecondaryColor,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Notification icon
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                debugPrint('Notification icon tapped');
                _showNotificationsBottomSheet();
              },
              borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                Icon(
                  Icons.notifications_outlined,
                  color: textColor,
                  size: 28,
                ),
                if (_unreadNotificationsCount > 0)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: const BoxDecoration(
                        color: AppTheme.gold,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          _unreadNotificationsCount > 9 ? '9+' : _unreadNotificationsCount.toString(),
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
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    final cardColor = ThemeHelper.getCardColor(context);
    final textColor = ThemeHelper.getTextColor(context);
    final filters = _getFilters(context);
    
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filterKey = filters[index];
          final filterLabel = _getFilterLabel(filterKey, context);
          final isSelected = filterKey == _selectedFilterKey;
          return Material(
            color: Colors.transparent,
            child: InkWell(
            onTap: () {
                debugPrint('Filter tapped: $filterKey');
              setState(() {
                _selectedFilterKey = filterKey;
              });
            },
              borderRadius: BorderRadius.circular(20),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.gold
                    : cardColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  filterLabel,
                  style: TextStyle(
                    color: isSelected
                        ? (ThemeHelper.isDark(context) ? const Color(0xFF0A0E27) : const Color(0xFF212121))
                        : textColor,
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMyParcelsHeader(BuildContext context) {
    final textColor = ThemeHelper.getTextColor(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            context.l10n.translate('my_parcels'),
            style: TextStyle(
              color: textColor,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
            onTap: () async {
                debugPrint('Add parcel button tapped');
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddParcelScreen(),
                ),
              );
              // Обновляем список из API после возврата
              if (result != null || mounted) {
                await _loadParcels();
              }
            },
              borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFFFD700),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.add,
                color: ThemeHelper.isDark(context) ? const Color(0xFF0A0E27) : const Color(0xFF212121),
                size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final cardColor = ThemeHelper.getCardColor(context);
    final textColor = ThemeHelper.getTextColor(context);
    final textSecondaryColor = ThemeHelper.getTextSecondaryColor(context);
    
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
              color: cardColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.inbox_outlined,
              color: textSecondaryColor,
              size: 60,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            context.l10n.translate('no_parcels'),
            style: TextStyle(
              color: textColor,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              context.l10n.translate('add_first_parcel'),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: textSecondaryColor,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddParcelScreen(),
                ),
              );
              // Обновляем список из API после возврата
              if (result != null || mounted) {
                await _loadParcels();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFD700),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              context.l10n.translate('add_parcel'),
              style: TextStyle(
                color: ThemeHelper.isDark(context) ? const Color(0xFF0A0E27) : const Color(0xFF212121),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildParcelsList(BuildContext context) {
    final filteredParcels = _selectedFilterKey == 'all'
        ? _parcels
        : _parcels.where((p) {
            switch (_selectedFilterKey) {
              case 'in_warehouse':
                return p.isArrived && !p.isDelivered;
              case 'in_transit':
                return p.isShipped && !p.isArrived;
              case 'delivered':
                return p.isDelivered;
              case 'at_customs':
                // Пока нет отдельного флага для таможни, используем in_transit как временное решение или возвращаем false
                return false;
              default:
                return true;
            }
          }).toList();

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
      itemCount: filteredParcels.length,
      itemBuilder: (context, index) {
        final parcel = filteredParcels[index];
        return _buildParcelCard(parcel);
      },
    );
  }

  Widget _buildParcelCard(Parcel parcel) {
    final cardColor = ThemeHelper.getCardColor(context);
    final textColor = ThemeHelper.getTextColor(context);
    final textSecondaryColor = ThemeHelper.getTextSecondaryColor(context);
    
    Color statusColor;
    Color statusTextColor;

    debugPrint('Parcel ${parcel.trackNumber}: status=${parcel.status}, shipped=${parcel.isShipped}, arrived=${parcel.isArrived}, delivered=${parcel.isDelivered}, accepted=${parcel.isAccepted}, waiting=${parcel.isWaiting}');

    if (parcel.isDelivered) {
      statusColor = const Color(0xFF10B981); // Зеленый
      statusTextColor = Colors.white;
    } else if (parcel.isArrived) {
      statusColor = const Color(0xFF3B82F6); // Синий
      statusTextColor = Colors.white;
    } else if (parcel.isShipped) {
      statusColor = AppTheme.gold; // Желтый
      statusTextColor = ThemeHelper.isDark(context) ? const Color(0xFF0A0E27) : const Color(0xFF212121);
    } else if (parcel.isRejected) {
      statusColor = const Color(0xFFEF4444); // Красный
      statusTextColor = Colors.white;
    } else if (parcel.isAccepted) {
      statusColor = const Color(0xFF3B82F6); // Синий
      statusTextColor = Colors.white;
    } else {
      statusColor = const Color(0xFF6B7280); // Серый
      statusTextColor = Colors.white;
    }

    return GestureDetector(
      onTap: () async {
        // Открываем детальный экран и обновляем данные при возврате
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ParcelDetailsScreen(parcel: parcel),
          ),
        );
        // Обновляем данные после возврата из детального экрана
        if (mounted) {
          _loadParcels();
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
          // Icon - квадратная иконка с темно-желтым фоном и желтым контуром коробки
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFB8860B).withValues(alpha: 0.3), // Темно-желтый фон
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.inbox_outlined,
              color: Color(0xFFFFD700), // Желтый контур
              size: 28,
              weight: 1.5,
            ),
          ),
          const SizedBox(width: 12),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  parcel.productName,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'ID: ${parcel.trackNumber}',
                  style: TextStyle(
                    color: textSecondaryColor,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      parcel.formattedDate,
                      style: TextStyle(
                        color: textSecondaryColor,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: textSecondaryColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      parcel.formattedWeight,
                      style: TextStyle(
                        color: textSecondaryColor,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _getStatusLabelFromKey(parcel.status),
              style: TextStyle(
                color: statusTextColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          // Стрелка для навигации
          const SizedBox(width: 8),
          Icon(
            Icons.chevron_right,
            color: textSecondaryColor,
            size: 24,
          ),
        ],
      ),
      ),
    );
  }

  // Методы _getStatusKey и _getStatusLabel больше не нужны, 
  // так как используется консолидированный метод _getStatusLabelFromKey
}


