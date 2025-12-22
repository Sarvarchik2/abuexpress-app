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
    final history = parcel.history ?? _generateDefaultHistory(parcel);

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
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3B82F6),
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
      child: Column(
        children: List.generate(history.length, (index) {
          final item = history[index];
          final isLast = index == history.length - 1;
          
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Таймлайн
              Column(
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
                  if (!isLast)
                    Container(
                      width: 2,
                      height: 60,
                      color: item.isCompleted
                          ? AppTheme.gold
                          : textSecondaryColor.withValues(alpha: 0.2),
                    ),
                ],
              ),
              const SizedBox(width: 16),
              // Информация
              Expanded(
                child: Padding(
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
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  List<ParcelHistoryItem> _generateDefaultHistory(Parcel parcel) {
    return [
      ParcelHistoryItem(
        id: '1',
        status: 'Получено',
        location: 'Склад AbuExpress, ${parcel.origin.split(',')[0]}',
        description: 'Посылка принята на складе',
        dateTime: parcel.dateAdded,
        isCompleted: true,
      ),
      ParcelHistoryItem(
        id: '2',
        status: 'Упаковано',
        location: 'Склад AbuExpress, ${parcel.origin.split(',')[0]}',
        description: 'Посылка упакована и подготовлена к отправке',
        dateTime: parcel.dateAdded.add(const Duration(days: 1)),
        isCompleted: true,
      ),
      ParcelHistoryItem(
        id: '3',
        status: 'Отправлено',
        location: parcel.origin.contains('США') ? 'JFK Airport' : 'Аэропорт',
        description: 'Посылка отправлена авиарейсом',
        dateTime: parcel.dateAdded.add(const Duration(days: 2)),
        isCompleted: true,
      ),
      ParcelHistoryItem(
        id: '4',
        status: 'На складе',
        location: 'Склад AbuExpress, Ташкент',
        description: 'Посылка прибыла на склад в Ташкенте',
        dateTime: parcel.dateAdded.add(const Duration(days: 4)),
        isCompleted: parcel.status == 'На складе' || parcel.status == 'В таможне' || parcel.status == 'Доставлен',
      ),
      ParcelHistoryItem(
        id: '5',
        status: 'В таможне',
        location: 'Таможенный терминал',
        description: 'Ожидает таможенного оформления',
        dateTime: parcel.dateAdded.add(const Duration(days: 5)),
        isCompleted: parcel.status == 'Доставлен',
      ),
      ParcelHistoryItem(
        id: '6',
        status: 'Готово к выдаче',
        location: 'Офис выдачи',
        description: 'Готово к получению в офисе',
        dateTime: parcel.dateAdded.add(const Duration(days: 7)),
        isCompleted: parcel.status == 'Доставлен',
      ),
    ];
  }
}

