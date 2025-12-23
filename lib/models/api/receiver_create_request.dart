class ReceiverCreateRequest {
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

  ReceiverCreateRequest({
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
  });

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
}

