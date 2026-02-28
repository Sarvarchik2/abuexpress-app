class NotificationItem {
  final String id;
  final String title;
  final String description;
  final DateTime dateTime;
  final NotificationType type;
  final String? orderId;
  bool isRead;

  NotificationItem({
    required this.id,
    required this.title,
    required this.description,
    required this.dateTime,
    required this.type,
    this.orderId,
    this.isRead = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'dateTime': dateTime.toIso8601String(),
    'type': type.index,
    'orderId': orderId,
    'isRead': isRead,
  };

  factory NotificationItem.fromJson(Map<String, dynamic> json) => NotificationItem(
    id: json['id'],
    title: json['title'],
    description: json['description'],
    dateTime: DateTime.parse(json['dateTime']),
    type: NotificationType.values[json['type']],
    orderId: json['orderId'],
    isRead: json['isRead'] ?? false,
  );
}

enum NotificationType {
  parcelArrived,
  parcelInTransit,
  parcelDelivered,
  specialOffer,
  appUpdate,
  newProducts,
}

