class UserRegistration {
  final String email;
  final String password;
  final String fullName;
  final String phoneNumber;
  final String? personalNumber;
  final String? cardNumber;
  final String? role;
  final String? location;

  UserRegistration({
    required this.email,
    required this.password,
    required this.fullName,
    required this.phoneNumber,
    this.personalNumber,
    this.cardNumber,
    this.role,
    this.location,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'full_name': fullName,
      'phone_number': phoneNumber,
      if (personalNumber != null) 'personal_number': personalNumber,
      if (cardNumber != null) 'card_number': cardNumber,
      if (role != null) 'role': role,
      if (location != null) 'location': location,
    };
  }
}
