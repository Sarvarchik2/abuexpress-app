import 'package:flutter/material.dart';
import '../models/notification.dart';
import '../utils/theme_helper.dart';
import '../utils/theme.dart' show AppTheme;

class NotificationsBottomSheet extends StatefulWidget {
  final List<NotificationItem> notifications;
  final Function(String) onNotificationTap;
  final ScrollController? scrollController;

  const NotificationsBottomSheet({
    super.key,
    required this.notifications,
    required this.onNotificationTap,
    this.scrollController,
  });

  @override
  State<NotificationsBottomSheet> createState() => _NotificationsBottomSheetState();
}

class _NotificationsBottomSheetState extends State<NotificationsBottomSheet> {
  int get unreadCount => widget.notifications.where((n) => !n.isRead).length;

  IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.parcelArrived:
        return Icons.inbox_outlined;
      case NotificationType.parcelInTransit:
        return Icons.access_time;
      case NotificationType.parcelDelivered:
        return Icons.check_circle_outline;
      case NotificationType.specialOffer:
        return Icons.star_outline;
      case NotificationType.appUpdate:
        return Icons.trending_up;
      case NotificationType.newProducts:
        return Icons.star_outline;
    }
  }

  void _handleNotificationTap(NotificationItem notification) {
    setState(() {
      notification.isRead = true;
    });
    widget.onNotificationTap(notification.id);
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = ThemeHelper.getBackgroundColor(context);
    final textColor = ThemeHelper.getTextColor(context);
    final textSecondaryColor = ThemeHelper.getTextSecondaryColor(context);
    final cardColor = ThemeHelper.getCardColor(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: textSecondaryColor.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Уведомления',
                          style: TextStyle(
                            color: textColor,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$unreadCount непрочитанных',
                          style: TextStyle(
                            color: textSecondaryColor,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: textColor),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              // Notifications list
              Flexible(
                child: ListView.builder(
                  controller: widget.scrollController,
                  padding: const EdgeInsets.only(bottom: 20),
                  itemCount: widget.notifications.length,
                  itemBuilder: (context, index) {
                    final notification = widget.notifications[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _buildNotificationItem(
                        notification,
                        textColor,
                        textSecondaryColor,
                        cardColor,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNotificationItem(
    NotificationItem notification,
    Color textColor,
    Color textSecondaryColor,
    Color cardColor,
  ) {
    final iconColor = notification.isRead
        ? textSecondaryColor
        : AppTheme.gold;

    return GestureDetector(
      onTap: () => _handleNotificationTap(notification),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: notification.isRead
                    ? cardColor
                    : AppTheme.gold.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getNotificationIcon(notification.type),
                color: iconColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 16,
                      fontWeight: notification.isRead
                          ? FontWeight.normal
                          : FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.description,
                    style: TextStyle(
                      color: textSecondaryColor,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    notification.timeAgo,
                    style: TextStyle(
                      color: textSecondaryColor,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            // Unread indicator
            if (!notification.isRead)
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(left: 8),
                decoration: const BoxDecoration(
                  color: AppTheme.gold,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

