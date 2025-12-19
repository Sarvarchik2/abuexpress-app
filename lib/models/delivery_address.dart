import 'package:flutter/material.dart';

class DeliveryAddress {
  final String id;
  final String type;
  final IconData icon;
  final bool isDefault;
  final String address; // Полный адрес для отображения
  final String recipientName;
  final String phone;
  
  // Детали адреса
  final String city;
  final String district;
  final String street;
  final String house;
  final String? apartment;

  DeliveryAddress({
    required this.id,
    required this.type,
    required this.icon,
    required this.isDefault,
    required this.address,
    required this.recipientName,
    required this.phone,
    required this.city,
    required this.district,
    required this.street,
    required this.house,
    this.apartment,
  });

  // Генерация полного адреса из деталей
  String get fullAddress {
    final apt = apartment != null && apartment!.isNotEmpty ? ', кв. $apartment' : '';
    return 'г. $city, $district, $street, д. $house$apt';
  }
}

