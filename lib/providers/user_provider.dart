import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/api/user_info.dart';
import '../services/notification_service.dart';

class UserProvider extends ChangeNotifier {
  UserInfo? _userInfo;
  bool _isLoading = false;
  String? _authToken;

  UserInfo? get userInfo => _userInfo;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _userInfo != null;
  String? get authToken => _authToken;

  String? get fullName => _userInfo?.fullName;
  String? get email => _userInfo?.email;
  String? get phoneNumber => _userInfo?.phoneNumber;
  int? get userId => _userInfo?.id;

  void setUserInfo(UserInfo? userInfo) {
    _userInfo = userInfo;
    notifyListeners();
  }

  Future<void> setAuthToken(String? token) async {
    _authToken = token;
    notifyListeners();
    
    final prefs = await SharedPreferences.getInstance();
    if (token != null) {
      await prefs.setString('auth_token', token);
    } else {
      await prefs.remove('auth_token');
    }
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  Future<void> clearUser() async {
    // Удаляем токен с сервера перед выходом из аккаунта
    await NotificationService().deleteToken();
    
    _userInfo = null;
    _authToken = null;
    notifyListeners();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  Future<bool> checkAuth() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    
    if (token != null && token.isNotEmpty) {
      _authToken = token;
      notifyListeners();
      return true;
    }
    return false;
  }

  String getInitials() {
    if (_userInfo?.fullName == null || _userInfo!.fullName.isEmpty) {
      return 'АЖ';
    }
    
    final fullName = _userInfo!.fullName.trim();
    if (fullName.isEmpty) {
      return 'АЖ';
    }
    
    final names = fullName.split(' ').where((name) => name.isNotEmpty).toList();
    
    if (names.length >= 2) {
      final first = names[0];
      final second = names[1];
      if (first.isNotEmpty && second.isNotEmpty) {
        return '${first[0]}${second[0]}'.toUpperCase();
      } else if (first.isNotEmpty) {
        return first[0].toUpperCase();
      }
    } else if (names.isNotEmpty && names[0].isNotEmpty) {
      return names[0][0].toUpperCase();
    }
    
    return 'АЖ';
  }
}

