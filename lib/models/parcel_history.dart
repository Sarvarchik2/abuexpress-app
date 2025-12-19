class ParcelHistoryItem {
  final String id;
  final String status;
  final String location;
  final String description;
  final DateTime dateTime;
  final bool isCompleted;

  ParcelHistoryItem({
    required this.id,
    required this.status,
    required this.location,
    required this.description,
    required this.dateTime,
    this.isCompleted = false,
  });

  String get formattedDateTime {
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final year = dateTime.year;
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$day.$month.$year • $hour:$minute';
  }
}

