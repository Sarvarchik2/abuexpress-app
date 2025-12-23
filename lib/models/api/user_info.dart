class UserInfo {
  final int id;
  final String email;
  final String fullName;
  final String phoneNumber;
  final String? cardNumber;
  final String? personalNumber;
  final String? role;
  final String? location;

  UserInfo({
    required this.id,
    required this.email,
    required this.fullName,
    required this.phoneNumber,
    this.cardNumber,
    this.personalNumber,
    this.role,
    this.location,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    try {
      // Безопасный парсинг id
      int parsedId = 0;
      if (json['id'] != null) {
        if (json['id'] is num) {
          parsedId = (json['id'] as num).toInt();
        } else if (json['id'] is String) {
          parsedId = int.tryParse(json['id'] as String) ?? 0;
        }
      }

      // Безопасный парсинг строковых полей
      String parsedEmail = '';
      if (json['email'] != null) {
        parsedEmail = json['email'].toString();
      }

      String parsedFullName = '';
      if (json['full_name'] != null) {
        parsedFullName = json['full_name'].toString();
      } else if (json['fullName'] != null) {
        parsedFullName = json['fullName'].toString();
      }

      String parsedPhoneNumber = '';
      if (json['phone_number'] != null) {
        parsedPhoneNumber = json['phone_number'].toString();
      } else if (json['phoneNumber'] != null) {
        parsedPhoneNumber = json['phoneNumber'].toString();
      }

      return UserInfo(
        id: parsedId,
        email: parsedEmail,
        fullName: parsedFullName,
        phoneNumber: parsedPhoneNumber,
        cardNumber: json['card_number']?.toString() ?? json['cardNumber']?.toString(),
        personalNumber: json['personal_number']?.toString() ?? json['personalNumber']?.toString(),
        role: json['role']?.toString(),
        location: json['location']?.toString(),
      );
    } catch (e) {
      // В случае ошибки возвращаем объект с дефолтными значениями
      return UserInfo(
        id: 0,
        email: json['email']?.toString() ?? '',
        fullName: json['full_name']?.toString() ?? json['fullName']?.toString() ?? '',
        phoneNumber: json['phone_number']?.toString() ?? json['phoneNumber']?.toString() ?? '',
        cardNumber: json['card_number']?.toString() ?? json['cardNumber']?.toString(),
        personalNumber: json['personal_number']?.toString() ?? json['personalNumber']?.toString(),
        role: json['role']?.toString(),
        location: json['location']?.toString(),
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'phone_number': phoneNumber,
      'card_number': cardNumber,
      'personal_number': personalNumber,
      'role': role,
      'location': location,
    };
  }
}

