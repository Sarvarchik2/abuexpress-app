class NotificationItem {
  final String id;
  final String title;
  final String description;
  final DateTime dateTime;
  final NotificationType type;
  bool isRead;

  NotificationItem({
    required this.id,
    required this.title,
    required this.description,
    required this.dateTime,
    required this.type,
    this.isRead = false,
  });

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} ${_getDayWord(difference.inDays)} назад';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${_getHourWord(difference.inHours)} назад';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${_getMinuteWord(difference.inMinutes)} назад';
    } else {
      return 'Только что';
    }
  }

  String _getDayWord(int days) {
    if (days == 1) return 'день';
    if (days >= 2 && days <= 4) return 'дня';
    return 'дней';
  }

  String _getHourWord(int hours) {
    if (hours == 1) return 'час';
    if (hours >= 2 && hours <= 4) return 'часа';
    return 'часов';
  }

  String _getMinuteWord(int minutes) {
    if (minutes == 1) return 'минуту';
    if (minutes >= 2 && minutes <= 4) return 'минуты';
    return 'минут';
  }
}

enum NotificationType {
  parcelArrived,
  parcelInTransit,
  parcelDelivered,
  specialOffer,
  appUpdate,
  newProducts,
}

