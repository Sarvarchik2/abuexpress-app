class ShippingCalculator {
  // Стоимость доставки за кг в зависимости от страны
  static const Map<String, double> _pricePerKg = {
    'USA': 15.0,      // $15 за кг из США
    'Turkey': 12.0,   // $12 за кг из Турции
    'China': 8.0,    // $8 за кг из Китая
    'UAE': 10.0,     // $10 за кг из ОАЭ
  };

  // Минимальная стоимость доставки
  static const double _minShippingCost = 20.0;

  // Дополнительные услуги
  static const double _insuranceRate = 0.02; // 2% от стоимости товара
  static const double _packagingCost = 5.0; // $5 за упаковку
  static const double _customsRate = 0.15; // 15% таможенные сборы от стоимости товара

  /// Рассчитывает стоимость доставки
  static ShippingCost calculate({
    required String country,
    required double totalWeight,
    required double totalCost,
    int itemCount = 1,
  }) {
    final pricePerKg = _pricePerKg[country] ?? 15.0;
    final baseShipping = totalWeight * pricePerKg;
    final shippingCost = baseShipping < _minShippingCost 
        ? _minShippingCost 
        : baseShipping;

    final insurance = totalCost * _insuranceRate;
    final packaging = _packagingCost * itemCount;
    final customs = totalCost * _customsRate;
    final total = shippingCost + insurance + packaging + customs;

    return ShippingCost(
      baseShipping: shippingCost,
      insurance: insurance,
      packaging: packaging,
      customs: customs,
      total: total,
      country: country,
    );
  }

  static List<String> get availableCountries => _pricePerKg.keys.toList();
}

class ShippingCost {
  final double baseShipping;
  final double insurance;
  final double packaging;
  final double customs;
  final double total;
  final String country;

  ShippingCost({
    required this.baseShipping,
    required this.insurance,
    required this.packaging,
    required this.customs,
    required this.total,
    required this.country,
  });

  String get formattedTotal => '\$${total.toStringAsFixed(2)}';
  String get formattedBaseShipping => '\$${baseShipping.toStringAsFixed(2)}';
  String get formattedInsurance => '\$${insurance.toStringAsFixed(2)}';
  String get formattedPackaging => '\$${packaging.toStringAsFixed(2)}';
  String get formattedCustoms => '\$${customs.toStringAsFixed(2)}';
}

