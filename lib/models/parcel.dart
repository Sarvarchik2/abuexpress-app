import 'parcel_item.dart';
import 'shipping_calculator.dart';
import 'parcel_history.dart';

class Parcel {
  final String id;
  final List<ParcelItem> items;
  final String status;
  final DateTime dateAdded;
  final String? deliveryAddressId;
  final String? originCountry;
  final ShippingCost? shippingCost;
  final List<ParcelHistoryItem>? history;

  Parcel({
    required this.id,
    required this.items,
    required this.status,
    required this.dateAdded,
    this.deliveryAddressId,
    this.originCountry,
    this.shippingCost,
    this.history,
  });

  // Геттеры для обратной совместимости
  String get trackNumber => items.isNotEmpty ? items.first.trackNumber : '';
  String get storeName => items.isNotEmpty ? items.first.storeName : '';
  String get productName => items.length == 1 
      ? items.first.productName 
      : '${items.length} товаров';
  String? get productLink => items.isNotEmpty ? items.first.productLink : null;
  double get cost => items.fold(0.0, (sum, item) => sum + (item.cost * item.quantity));
  double get weight => items.fold(0.0, (sum, item) => sum + (item.weight * item.quantity));
  String? get color => items.length == 1 ? items.first.color : null;
  String? get size => items.length == 1 ? items.first.size : null;
  int get quantity => items.fold(0, (sum, item) => sum + item.quantity);
  String? get comment => items.length == 1 ? items.first.comment : null;

  String get formattedDate {
    final day = dateAdded.day.toString().padLeft(2, '0');
    final month = dateAdded.month.toString().padLeft(2, '0');
    final year = dateAdded.year;
    return '$day.$month.$year';
  }

  String get formattedWeight => '${weight.toStringAsFixed(1)} кг';

  // Дополнительные геттеры для детального экрана
  String get dimensions {
    if (items.isEmpty) return 'Не указано';
    // Примерные размеры на основе веса
    final baseSize = weight * 10; // Примерный расчет
    return '${(baseSize * 1.2).toStringAsFixed(0)}x${(baseSize * 1.0).toStringAsFixed(0)}x${(baseSize * 0.8).toStringAsFixed(0)} см';
  }

  String get origin {
    if (originCountry == null) return 'Не указано';
    final countryNames = {
      'USA': 'Нью-Йорк, США',
      'Turkey': 'Стамбул, Турция',
      'China': 'Пекин, Китай',
      'UAE': 'Дубай, ОАЭ',
    };
    return countryNames[originCountry] ?? originCountry!;
  }

  DateTime get estimatedDelivery {
    // Примерная дата доставки: +10-15 дней
    return dateAdded.add(const Duration(days: 12));
  }

  String get formattedDeliveryDate {
    final delivery = estimatedDelivery;
    final day = delivery.day.toString().padLeft(2, '0');
    final month = delivery.month.toString().padLeft(2, '0');
    final year = delivery.year;
    return '$day.$month.$year';
  }
}

