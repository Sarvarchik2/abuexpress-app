class ParcelItem {
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

  ParcelItem({
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
  });

  ParcelItem copyWith({
    String? id,
    String? trackNumber,
    String? storeName,
    String? productName,
    String? productLink,
    double? cost,
    double? weight,
    String? color,
    String? size,
    int? quantity,
    String? comment,
  }) {
    return ParcelItem(
      id: id ?? this.id,
      trackNumber: trackNumber ?? this.trackNumber,
      storeName: storeName ?? this.storeName,
      productName: productName ?? this.productName,
      productLink: productLink ?? this.productLink,
      cost: cost ?? this.cost,
      weight: weight ?? this.weight,
      color: color ?? this.color,
      size: size ?? this.size,
      quantity: quantity ?? this.quantity,
      comment: comment ?? this.comment,
    );
  }
}

