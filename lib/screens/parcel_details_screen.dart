import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/parcel.dart';
import '../models/parcel_history.dart';
import '../utils/theme_helper.dart';
import '../utils/theme.dart' show AppTheme;
import '../utils/localization_helper.dart';
import '../widgets/custom_snackbar.dart';

class ParcelDetailsScreen extends StatelessWidget {
  final Parcel parcel;

  const ParcelDetailsScreen({
    super.key,
    required this.parcel,
  });

  @override
  Widget build(BuildContext context) {
    final backgroundColor = ThemeHelper.getBackgroundColor(context);
    final textColor = ThemeHelper.getTextColor(context);
    final textSecondaryColor = ThemeHelper.getTextSecondaryColor(context);
    final cardColor = ThemeHelper.getCardColor(context);

    // Генерируем историю, если её нет
    final history = parcel.history ?? _generateDefaultHistory(parcel, context);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          context.l10n.translate('parcel_details'),
          style: TextStyle(color: textColor),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Карточка с информацией о посылке
          _buildParcelSummaryCard(context, parcel, textColor, textSecondaryColor, cardColor),
          const SizedBox(height: 24),
          
          // История перемещений
          Row(
            children: [
              const Icon(
                Icons.local_shipping_outlined,
                color: AppTheme.gold,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                context.l10n.translate('movement_history'),
                style: TextStyle(
                  color: textColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildHistoryTimeline(history, textColor, textSecondaryColor, cardColor),
          const SizedBox(height: 24),
          
          // Кнопка позвонить
          SizedBox(
            width: double.infinity,
            height: 56,
            child: OutlinedButton.icon(
              onPressed: () async {
                final phoneNumber = '+998901234567'; // Номер службы поддержки
                final url = Uri.parse('tel:$phoneNumber');
                if (await canLaunchUrl(url)) {
                  await launchUrl(url);
                } else {
                  if (context.mounted) {
                    CustomSnackBar.error(
                      context: context,
                      message: 'Не удалось совершить звонок',
                    );
                  }
                }
              },
              icon: const Icon(Icons.phone, color: AppTheme.gold),
              label: Text(
                context.l10n.translate('call'),
                style: const TextStyle(
                  color: AppTheme.gold,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppTheme.gold, width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Помощь
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.help_outline,
                  color: AppTheme.gold,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.l10n.translate('need_help'),
                        style: TextStyle(
                          color: textColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        context.l10n.translate('contact_support'),
                        style: TextStyle(
                          color: textSecondaryColor,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParcelSummaryCard(
    BuildContext context,
    Parcel parcel,
    Color textColor,
    Color textSecondaryColor,
    Color cardColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Заголовок и статус
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.inbox_outlined,
                  color: Color(0xFF3B82F6),
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      parcel.items.length == 1
                          ? parcel.items.first.productName
                          : '${parcel.items.length} товаров',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (parcel.storeName.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        parcel.storeName,
                        style: TextStyle(
                          color: textSecondaryColor,
                          fontSize: 14,
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(parcel.status),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        parcel.status,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Номер отслеживания
          if (parcel.trackNumber.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildDetailItem(
                Icons.qr_code_outlined,
                context.l10n.translate('tracking_number_label'),
                parcel.trackNumber,
                textColor,
                textSecondaryColor,
              ),
            ),
          
          // Детали в две колонки
          Row(
            children: [
              Expanded(
                child: _buildDetailItem(
                  Icons.shopping_bag_outlined,
                  context.l10n.translate('weight'),
                  parcel.formattedWeight,
                  textColor,
                  textSecondaryColor,
                ),
              ),
              Expanded(
                child: _buildDetailItem(
                  Icons.inbox_outlined,
                  context.l10n.translate('dimensions'),
                  parcel.dimensions,
                  textColor,
                  textSecondaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildDetailItem(
                  Icons.attach_money_outlined,
                  context.l10n.translate('cost_label'),
                  '${parcel.cost.toStringAsFixed(2)} \$',
                  textColor,
                  textSecondaryColor,
                ),
              ),
              Expanded(
                child: _buildDetailItem(
                  Icons.inventory_2_outlined,
                  context.l10n.translate('quantity_label'),
                  '${parcel.quantity} ${context.l10n.translate('item')}',
                  textColor,
                  textSecondaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildDetailItem(
                  Icons.location_on_outlined,
                  context.l10n.translate('from'),
                  parcel.origin,
                  textColor,
                  textSecondaryColor,
                ),
              ),
              Expanded(
                child: _buildDetailItem(
                  Icons.calendar_today_outlined,
                  context.l10n.translate('delivery'),
                  parcel.formattedDeliveryDate,
                  textColor,
                  textSecondaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(
    IconData icon,
    String label,
    String value,
    Color textColor,
    Color textSecondaryColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: textSecondaryColor, size: 16),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: textSecondaryColor,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
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

  Widget _buildHistoryTimeline(
    List<ParcelHistoryItem> history,
    Color textColor,
    Color textSecondaryColor,
    Color cardColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Таймлайн с непрерывной линией
          SizedBox(
            width: 32,
            child: Stack(
              children: [
                // Непрерывная вертикальная линия через центр всех иконок
                Positioned(
                  left: 15, // Центр (32/2 - 1)
                  top: 16, // Начинается от центра первой иконки
                  bottom: 16, // Заканчивается у центра последней иконки
                  child: Container(
                    width: 2,
                    color: AppTheme.gold, // Можно сделать динамическим, но для простоты используем золотой
                  ),
                ),
                // Иконки
                Column(
                  children: List.generate(history.length, (index) {
                    final item = history[index];
                    final isLast = index == history.length - 1;
                    
                    return Column(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: item.isCompleted ? AppTheme.gold : textSecondaryColor.withValues(alpha: 0.3),
                            shape: BoxShape.circle,
                          ),
                          child: item.isCompleted
                              ? const Icon(
                                  Icons.check,
                                  color: Color(0xFF0A0E27),
                                  size: 20,
                                )
                              : Icon(
                                  Icons.access_time,
                                  color: textSecondaryColor,
                                  size: 20,
                                ),
                        ),
                        if (!isLast) const SizedBox(height: 60),
                      ],
                    );
                  }),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Информация
          Expanded(
            child: Column(
              children: List.generate(history.length, (index) {
                final item = history[index];
                final isLast = index == history.length - 1;
                
                return Padding(
                  padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.status,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.location,
                        style: const TextStyle(
                          color: AppTheme.gold,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.description,
                        style: TextStyle(
                          color: textSecondaryColor,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        item.formattedDateTime,
                        style: TextStyle(
                          color: textSecondaryColor,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'На складе':
        return const Color(0xFF3B82F6); // Синий
      case 'В пути':
        return AppTheme.gold; // Желтый
      case 'Доставлено':
      case 'Доставлен':
        return const Color(0xFF10B981); // Зеленый
      case 'Отклонено':
        return const Color(0xFFEF4444); // Красный
      case 'Принято':
        return const Color(0xFF3B82F6); // Синий
      case 'Ожидает':
        return const Color(0xFF6B7280); // Серый
      default:
        return const Color(0xFF6B7280); // Серый
    }
  }

  List<ParcelHistoryItem> _generateDefaultHistory(Parcel parcel, BuildContext context) {
    final history = <ParcelHistoryItem>[];
    int dayOffset = 0;

    // Безопасная проверка статусов
    final isAccepted = parcel.isAccepted;
    final isRejected = parcel.isRejected;
    final isShipped = parcel.isShipped;
    final isArrived = parcel.isArrived;
    final isDelivered = parcel.isDelivered;
    
    final l10n = context.l10n;
    
    final originLocation = parcel.origin != l10n.translate('not_specified')
        ? '${l10n.translate('warehouse_location')}, ${parcel.origin.split(',')[0]}'
        : l10n.translate('warehouse_location');

    // 1. Заказ создан - всегда показываем
    history.add(ParcelHistoryItem(
      id: '1',
      status: l10n.translate('order_created'),
      location: l10n.translate('online'),
      description: l10n.translate('order_created_description'),
      dateTime: parcel.dateAdded,
      isCompleted: true,
    ));
    dayOffset++;

    // 2. Принято - всегда показываем
    history.add(ParcelHistoryItem(
      id: '2',
      status: isAccepted ? l10n.translate('accepted') : l10n.translate('awaiting_acceptance'),
      location: originLocation,
      description: isAccepted 
          ? l10n.translate('accepted_description')
          : l10n.translate('awaiting_acceptance_description'),
      dateTime: parcel.dateAdded.add(Duration(days: dayOffset)),
      isCompleted: isAccepted,
    ));
    dayOffset++;

    // 3. Отклонено - показываем только если отклонен, и останавливаемся
    if (isRejected) {
      history.add(ParcelHistoryItem(
        id: '3',
        status: l10n.translate('rejected'),
        location: originLocation,
        description: l10n.translate('rejected_description'),
        dateTime: parcel.dateAdded.add(Duration(days: dayOffset)),
        isCompleted: true,
      ));
      return history; // Если отклонен, останавливаемся здесь
    }

    // 4. Отправлено - всегда показываем
    final airportName = parcel.origin.contains('США') || parcel.origin.contains('USA')
        ? 'JFK Airport, Нью-Йорк'
        : parcel.origin.contains('Китай') || parcel.origin.contains('China')
            ? 'Аэропорт Пекина'
            : parcel.origin.contains('Турция') || parcel.origin.contains('Turkey')
                ? 'Аэропорт Стамбула'
                : l10n.translate('airport');
    
    history.add(ParcelHistoryItem(
      id: '4',
      status: isShipped ? l10n.translate('shipped') : l10n.translate('preparing_for_shipment'),
      location: isShipped ? airportName : originLocation,
      description: isShipped
          ? l10n.translate('shipped_description')
          : l10n.translate('preparing_for_shipment_description'),
      dateTime: parcel.dateAdded.add(Duration(days: dayOffset)),
      isCompleted: isShipped,
    ));
    dayOffset++;

    // 5. На складе - всегда показываем
    history.add(ParcelHistoryItem(
      id: '5',
      status: isArrived ? l10n.translate('at_warehouse') : l10n.translate('in_transit'),
      location: isArrived ? '${l10n.translate('warehouse_location')}, Ташкент' : l10n.translate('in_transit'),
      description: isArrived
          ? l10n.translate('at_warehouse_description')
          : l10n.translate('in_transit_description'),
      dateTime: parcel.dateAdded.add(Duration(days: dayOffset)),
      isCompleted: isArrived,
    ));
    dayOffset++;

    // 6. Доставлено - всегда показываем
    history.add(ParcelHistoryItem(
      id: '6',
      status: isDelivered ? l10n.translate('delivered') : l10n.translate('ready_for_pickup'),
      location: l10n.translate('pickup_office'),
      description: isDelivered
          ? l10n.translate('delivered_description')
          : l10n.translate('ready_for_pickup_description'),
      dateTime: parcel.dateAdded.add(Duration(days: dayOffset)),
      isCompleted: isDelivered,
    ));

    return history;
  }
}

