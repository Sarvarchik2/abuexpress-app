class ApiConfig {
  static const String baseUrl = 'https://abuexpresslogisticscargo.com/api';
  
  // Endpoints
  static const String login = '/login/';
  static const String register = '/register/';
  static const String sendOtp = '/send-otp/';
  static const String verifyOtp = '/verify-otp/';
  static const String resetPassword = '/reset-password/';
  static const String getMe = '/get-me/';
  static const String orderOwn = '/order-own/';
  static const String addresses = '/addresses/';
  static const String officeAddresses = '/office-address/';
  
  // Helper methods for endpoints with IDs
  static String addressById(int addressId) => '/addresses/$addressId/';
  static String orderOwnById(int id) => '/order-own/$id/';
}

