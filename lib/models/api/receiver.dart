class Receiver {
  final int id;
  final String firstName;
  final String lastName;
  final String passportNumber;
  final String phoneNumber;
  final String? phoneNumber2;
  final String email;
  final String apartment;
  final String address;
  final String country;
  final String city;
  final String district;
  final String? officeNumber;
  final String postalCode;
  final String? frontPassportImage;
  final String? backPassportImage;

  Receiver({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.passportNumber,
    required this.phoneNumber,
    this.phoneNumber2,
    required this.email,
    required this.apartment,
    required this.address,
    required this.country,
    required this.city,
    required this.district,
    this.officeNumber,
    required this.postalCode,
    this.frontPassportImage,
    this.backPassportImage,
  });

  factory Receiver.fromJson(Map<String, dynamic> json) {
    return Receiver(
      id: (json['id'] as num?)?.toInt() ?? 0,
      firstName: json['first_name']?.toString() ?? '',
      lastName: json['last_name']?.toString() ?? '',
      passportNumber: json['passport_number']?.toString() ?? '',
      phoneNumber: json['phone_number']?.toString() ?? '',
      phoneNumber2: json['phone_number2']?.toString(),
      email: json['email']?.toString() ?? '',
      apartment: json['apartment']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      country: json['country']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      district: json['district']?.toString() ?? '',
      officeNumber: json['office_number']?.toString(),
      postalCode: json['postal_code']?.toString() ?? '',
      frontPassportImage: json['front_passport_image']?.toString(),
      backPassportImage: json['back_passport_image']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'first_name': firstName,
      'last_name': lastName,
      'passport_number': passportNumber,
      'phone_number': phoneNumber,
      'email': email,
      'apartment': apartment,
      'address': address,
      'country': country,
      'city': city,
      'district': district,
      'postal_code': postalCode,
    };

    if (phoneNumber2 != null) {
      json['phone_number2'] = phoneNumber2;
    }
    if (officeNumber != null) {
      json['office_number'] = officeNumber;
    }

    return json;
  }

  // Геттер для полного имени
  String get fullName => '$firstName $lastName';

  // Геттер для полного адреса
  String get fullAddress {
    final parts = <String>[];
    if (address.isNotEmpty) parts.add(address);
    if (apartment.isNotEmpty) parts.add('кв. $apartment');
    if (district.isNotEmpty) parts.add(district);
    if (city.isNotEmpty) parts.add(city);
    if (country.isNotEmpty) parts.add(country);
    if (postalCode.isNotEmpty) parts.add(postalCode);
    return parts.join(', ');
  }
}

