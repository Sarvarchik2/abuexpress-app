class DepartureTime {
  final int id;
  final String country;
  final DateTime departureTime;
  final DateTime createdAt;
  final DateTime updatedAt;

  DepartureTime({
    required this.id,
    required this.country,
    required this.departureTime,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DepartureTime.fromJson(Map<String, dynamic> json) {
    return DepartureTime(
      id: json['id'] as int,
      country: json['country'] as String,
      departureTime: DateTime.parse(json['departure_time'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'country': country,
      'departure_time': departureTime.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
