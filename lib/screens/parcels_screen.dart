import 'package:flutter/material.dart';
import 'add_parcel_screen.dart';
import 'parcel_details_screen.dart';
import '../models/parcel.dart';
import '../models/notification.dart';
import '../widgets/bottom_navigation_bar.dart';
import '../widgets/notifications_bottom_sheet.dart';
import '../utils/theme_helper.dart';
import '../utils/localization_helper.dart';
import '../utils/theme.dart';

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

class _ParcelsScreenState extends State<ParcelsScreen> {
  String _selectedFilterKey = 'all';
  final List<Parcel> _parcels = [];

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

  final List<NotificationItem> _notifications = [
    NotificationItem(
      id: '1',
      title: 'Посылка прибыла на склад',
      description: 'Ваша посылка ABU123456 успешно прибыла на склад',
      dateTime: DateTime.now().subtract(const Duration(hours: 2)),
      type: NotificationType.parcelArrived,
      isRead: false,
    ),
    NotificationItem(
      id: '2',
      title: 'Посылка в пути',
      description: 'Посылка ABU789012 находится в пути',
      dateTime: DateTime.now().subtract(const Duration(hours: 5)),
      type: NotificationType.parcelInTransit,
      isRead: false,
    ),
    NotificationItem(
      id: '3',
      title: 'Специальное предложение!',
      description: 'Скидка 20% на доставку из США до конца месяца',
      dateTime: DateTime.now().subtract(const Duration(days: 1)),
      type: NotificationType.specialOffer,
      isRead: true,
    ),
    NotificationItem(
      id: '4',
      title: 'Обновление приложения',
      description: 'Доступна новая версия приложения с улучшенным интерфейсом',
      dateTime: DateTime.now().subtract(const Duration(days: 2)),
      type: NotificationType.appUpdate,
      isRead: true,
    ),
    NotificationItem(
      id: '5',
      title: 'Посылка доставлена',
      description: 'Посылка ABU345678 успешно доставлена в офис',
      dateTime: DateTime.now().subtract(const Duration(days: 3)),
      type: NotificationType.parcelDelivered,
      isRead: true,
    ),
    NotificationItem(
      id: '6',
      title: 'Новые товары в магазине',
      description: 'Более 100 новых товаров от популярных брендов теперь доступны',
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
                const SizedBox(height: 20),
                // Filter buttons
                _buildFilters(),
                const SizedBox(height: 24),
                // My Parcels section
                _buildMyParcelsHeader(context),
                const SizedBox(height: 16),
                // Empty state or parcel list
                Expanded(
                  child: _parcels.isEmpty
                      ? _buildEmptyState(context)
                      : _buildParcelsList(context),
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
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          // Avatar
          Stack(
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
                    'АЖ',
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
          const SizedBox(width: 12),
          // User info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Журабаев Асадбек',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'ID: 12345678',
                  style: TextStyle(
                    color: textSecondaryColor,
                    fontSize: 14,
                  ),
                ),
              ],
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
                if (result != null && result is Parcel) {
                  setState(() {
                    _parcels.add(result);
                  });
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
              if (result != null && result is Parcel) {
                setState(() {
                  _parcels.add(result);
                });
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
            final statusMap = {
              'in_warehouse': 'На складе',
              'in_transit': 'В пути',
              'at_customs': 'В таможне',
              'delivered': 'Доставлен',
            };
            return p.status == statusMap[_selectedFilterKey];
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
    
    switch (parcel.status) {
      case 'На складе':
        statusColor = const Color(0xFF3B82F6); // Синий
        statusTextColor = Colors.white;
        break;
      case 'В пути':
        statusColor = AppTheme.gold; // Желтый
        statusTextColor = ThemeHelper.isDark(context) ? const Color(0xFF0A0E27) : const Color(0xFF212121);
        break;
      case 'Доставлен':
        statusColor = const Color(0xFF374151); // Темно-серый
        statusTextColor = Colors.white;
        break;
      default:
        statusColor = cardColor;
        statusTextColor = textColor;
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ParcelDetailsScreen(parcel: parcel),
          ),
        );
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
              _getStatusLabel(_getStatusKey(parcel.status), context),
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

  String _getStatusKey(String status) {
    switch (status) {
      case 'На складе':
        return 'in_warehouse';
      case 'В пути':
        return 'in_transit';
      case 'В таможне':
        return 'at_customs';
      case 'Доставлен':
        return 'delivered';
      default:
        return 'all';
    }
  }

  String _getStatusLabel(String key, BuildContext context) {
    switch (key) {
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
}


