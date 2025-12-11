class Parcel {
  final String id;
  final String trackNumber;
  final String storeName;
  final String productName;
  final String? productLink;
  final double cost;
  final double weight;
  final String? color;
  final String? size;
  final int quantity;
  final String? comment;
  final String status;
  final DateTime dateAdded;

  Parcel({
    required this.id,
    required this.trackNumber,
    required this.storeName,
    required this.productName,
    this.productLink,
    required this.cost,
    required this.weight,
    this.color,
    this.size,
    required this.quantity,
    this.comment,
    required this.status,
    required this.dateAdded,
  });

  String get formattedDate {
    final day = dateAdded.day.toString().padLeft(2, '0');
    final month = dateAdded.month.toString().padLeft(2, '0');
    final year = dateAdded.year;
    return '$day.$month.$year';
  }

  String get formattedWeight => '${weight.toStringAsFixed(1)} кг';
}

