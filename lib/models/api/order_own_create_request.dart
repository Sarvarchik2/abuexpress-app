class OrderOwnCreateRequest {
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
  final bool? isAccepted;
  final bool? isRejected;
  final bool? isShipped;
  final bool? isArrived;
  final bool? isDelivered;
  final int receiverAddress;

  OrderOwnCreateRequest({
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
    this.isAccepted,
    this.isRejected,
    this.isShipped,
    this.isArrived,
    this.isDelivered,
    required this.receiverAddress,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'track_number': trackNumber,
      'market_name': marketName,
      'url_product': urlProduct,
      'product_name': productName,
      'product_price': productPrice,
      'product_quantity': productQuantity,
      'product_color': productColor,
      'receiver_address': receiverAddress,
    };

    if (invoiceId != null) {
      json['invoice_id'] = invoiceId;
    }
    if (productWeight != null) {
      json['product_weight'] = productWeight;
    }
    if (productSize != null) {
      json['product_size'] = productSize;
    }
    if (comment != null) {
      json['comment'] = comment;
    }
    if (isAccepted != null) {
      json['is_accepted'] = isAccepted;
    }
    if (isRejected != null) {
      json['is_rejected'] = isRejected;
    }
    if (isShipped != null) {
      json['is_shipped'] = isShipped;
    }
    if (isArrived != null) {
      json['is_arrived'] = isArrived;
    }
    if (isDelivered != null) {
      json['is_delivered'] = isDelivered;
    }

    return json;
  }
}

