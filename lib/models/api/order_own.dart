class OrderOwn {
  final int id;
  final String? invoiceId;
  final String trackNumber;
  final String marketName;
  final String urlProduct;
  final String productName;
  final num productPrice;
  final int productQuantity;
  final num? productWeight;
  final String productColor;
  final String? productSize;
  final String? comment;
  final bool isAccepted;
  final bool isRejected;
  final bool isShipped;
  final bool isArrived;
  final bool isDelivered;
  final int receiverAddress;

  OrderOwn({
    required this.id,
    this.invoiceId,
    required this.trackNumber,
    required this.marketName,
    required this.urlProduct,
    required this.productName,
    required this.productPrice,
    required this.productQuantity,
    this.productWeight,
    required this.productColor,
    this.productSize,
    this.comment,
    required this.isAccepted,
    required this.isRejected,
    required this.isShipped,
    required this.isArrived,
    required this.isDelivered,
    required this.receiverAddress,
  });

  factory OrderOwn.fromJson(Map<String, dynamic> json) {
    return OrderOwn(
      id: (json['id'] as num?)?.toInt() ?? 0,
      invoiceId: json['invoice_id']?.toString(),
      trackNumber: json['track_number']?.toString() ?? '',
      marketName: json['market_name']?.toString() ?? '',
      urlProduct: json['url_product']?.toString() ?? '',
      productName: json['product_name']?.toString() ?? '',
      productPrice: (json['product_price'] as num?) ?? 0,
      productQuantity: (json['product_quantity'] as num?)?.toInt() ?? 0,
      productWeight: json['product_weight'] != null 
          ? (json['product_weight'] as num) 
          : null,
      productColor: json['product_color']?.toString() ?? '',
      productSize: json['product_size']?.toString(),
      comment: json['comment']?.toString(),
      isAccepted: json['is_accepted'] as bool? ?? false,
      isRejected: json['is_rejected'] as bool? ?? false,
      isShipped: json['is_shipped'] as bool? ?? false,
      isArrived: json['is_arrived'] as bool? ?? false,
      isDelivered: json['is_delivered'] as bool? ?? false,
      receiverAddress: (json['receiver_address'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'invoice_id': invoiceId,
      'track_number': trackNumber,
      'market_name': marketName,
      'url_product': urlProduct,
      'product_name': productName,
      'product_price': productPrice,
      'product_quantity': productQuantity,
      'product_weight': productWeight,
      'product_color': productColor,
      'product_size': productSize,
      'comment': comment,
      'is_accepted': isAccepted,
      'is_rejected': isRejected,
      'is_shipped': isShipped,
      'is_arrived': isArrived,
      'is_delivered': isDelivered,
      'receiver_address': receiverAddress,
    };
  }

  // Геттер для статуса посылки (для совместимости с Parcel)
  String get status {
    if (isDelivered) return 'delivered';
    if (isArrived) return 'in_warehouse';
    if (isShipped) return 'in_transit';
    if (isRejected) return 'rejected';
    if (isAccepted) return 'accepted';
    return 'pending';
  }

  // Геттер для даты (если есть в API, иначе используем текущую)
  DateTime get dateAdded => DateTime.now(); // TODO: добавить поле даты из API если есть
}

