class LoginResponse {
  final String? email;
  final String? password;
  final String? accessToken;
  final String? refreshToken;
  final String? message;

  LoginResponse({
    this.email,
    this.password,
    this.accessToken,
    this.refreshToken,
    this.message,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      email: json['email'] as String?,
      password: json['password'] as String?,
      accessToken: json['access'] as String?,
      refreshToken: json['refresh'] as String?,
      message: json['message'] as String?,
    );
  }
}

