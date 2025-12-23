import 'package:flutter/foundation.dart';
import '../models/api/user_info.dart';

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

  void setAuthToken(String? token) {
    _authToken = token;
    notifyListeners();
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void clearUser() {
    _userInfo = null;
    _authToken = null;
    notifyListeners();
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

