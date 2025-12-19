class Product {
  final String id;
  final String name;
  final double price;
  final String image;
  bool isFavorite;
  final String category;
  final String description;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.image,
    required this.isFavorite,
    required this.category,
    this.description = '',
  });
}

