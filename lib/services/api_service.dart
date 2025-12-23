import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/api/login_request.dart';
import '../models/api/login_response.dart';
import '../models/api/user_info.dart';
import '../models/api/order_own.dart';
import '../models/api/order_own_create_request.dart';
import '../models/api/receiver.dart';
import '../models/api/receiver_create_request.dart';

class ApiService {
  final String baseUrl;
  final http.Client client;
  String? _authToken;

  ApiService({
    this.baseUrl = ApiConfig.baseUrl,
    http.Client? client,
    String? authToken,
  }) : client = client ?? http.Client(),
       _authToken = authToken;

  void setAuthToken(String? token) {
    _authToken = token;
  }

  Map<String, String> _getHeaders({Map<String, String>? additionalHeaders}) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    
    if (_authToken != null && _authToken!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_authToken';
      debugPrint('=== AUTH HEADER SET ===');
      debugPrint('Token: ${_authToken!.substring(0, 20)}...');
    } else {
      debugPrint('=== NO AUTH TOKEN ===');
      debugPrint('_authToken is null or empty');
    }
    
    if (additionalHeaders != null) {
      headers.addAll(additionalHeaders);
    }
    
    debugPrint('=== REQUEST HEADERS ===');
    debugPrint('Headers: $headers');
    
    return headers;
  }

  /// Выполняет вход пользователя
  /// 
  /// Возвращает [LoginResponse] при успешном входе (201)
  /// Выбрасывает исключение при ошибке
  Future<LoginResponse> login(LoginRequest request) async {
    try {
      final url = Uri.parse('$baseUrl${ApiConfig.login}');
      
      // Отправляем данные напрямую, без обертки 'data'
      final requestBody = request.toJson();

      debugPrint('=== LOGIN REQUEST ===');
      debugPrint('URL: $url');
      debugPrint('Body: ${jsonEncode(requestBody)}');

      final response = await client.post(
        url,
        headers: _getHeaders(),
        body: jsonEncode(requestBody),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          debugPrint('=== LOGIN TIMEOUT ===');
          throw Exception('Время ожидания истекло. Проверьте подключение к интернету.');
        },
      );

      debugPrint('=== LOGIN RESPONSE ===');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Headers: ${response.headers}');
      debugPrint('Body: ${response.body}');

      // Проверяем успешные статусы (200 или 201)
      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('=== LOGIN SUCCESS ===');
        debugPrint('Response Body: ${response.body}');
        
        try {
          // Пытаемся распарсить как JSON
          final jsonData = jsonDecode(response.body);
          
          if (jsonData is Map<String, dynamic>) {
            debugPrint('Response Data (JSON): $jsonData');
            final loginResponse = LoginResponse.fromJson(jsonData);
            
            // Сохраняем токен для дальнейшего использования
            if (loginResponse.accessToken != null) {
              setAuthToken(loginResponse.accessToken);
              debugPrint('=== TOKEN SAVED ===');
              debugPrint('Access Token: ${loginResponse.accessToken!.substring(0, 20)}...');
            }
            
            return loginResponse;
          } else {
            // Если это не объект, но статус успешный - считаем успешным
            debugPrint('Response is not a JSON object, but status is ${response.statusCode}');
            // Возвращаем минимальный ответ с email из запроса
            return LoginResponse(
              email: request.email,
            );
          }
        } catch (e) {
          // Если не JSON, но статус успешный - считаем успешным
          debugPrint('Response is not JSON, but status is ${response.statusCode}: ${response.body}');
          debugPrint('Parse error: $e');
          // Возвращаем минимальный ответ с email из запроса
          return LoginResponse(
            email: request.email,
          );
        }
      } else {
        // Пытаемся получить сообщение об ошибке из ответа
        String errorMessage = 'Ошибка входа';
        try {
          final errorData = jsonDecode(response.body) as Map<String, dynamic>;
          debugPrint('=== LOGIN ERROR DATA ===');
          debugPrint('Error Data: $errorData');
          
          // Обработка ошибок валидации (формат: {"email": ["сообщение"], "password": ["сообщение"]})
          if (errorData.containsKey('email') || errorData.containsKey('password')) {
            final List<String> errors = [];
            if (errorData['email'] is List) {
              errors.addAll((errorData['email'] as List).map((e) => e.toString()));
            }
            if (errorData['password'] is List) {
              errors.addAll((errorData['password'] as List).map((e) => e.toString()));
            }
            errorMessage = errors.isNotEmpty ? errors.join(', ') : errorMessage;
          } else {
            // Обычные ошибки - но проверяем, не является ли это успешным ответом с message
            final message = errorData['message'] as String?;
            if (message != null && 
                (message.toLowerCase().contains('success') || 
                 message.toLowerCase().contains('logged in'))) {
              // Это успешный ответ, но попал в блок ошибок из-за статус кода
              // Возвращаем успешный ответ
              debugPrint('=== DETECTED SUCCESS MESSAGE IN ERROR BLOCK ===');
              final loginResponse = LoginResponse.fromJson(errorData);
              if (loginResponse.accessToken != null) {
                setAuthToken(loginResponse.accessToken);
                debugPrint('=== TOKEN SAVED ===');
              }
              return loginResponse;
            }
            
            errorMessage = message ?? 
                          errorData['error'] as String? ??
                          errorData['detail'] as String? ??
                          errorMessage;
          }
        } catch (e) {
          debugPrint('=== ERROR PARSING FAILED ===');
          debugPrint('Error: $e');
          debugPrint('Response body: ${response.body}');
          
          // Если не удалось распарсить ошибку, используем стандартное сообщение
          if (response.statusCode == 401) {
            errorMessage = 'Неверный email или пароль';
          } else if (response.statusCode == 400) {
            errorMessage = 'Неверные данные для входа';
          } else if (response.statusCode >= 500) {
            errorMessage = 'Ошибка сервера. Попробуйте позже';
          } else {
            errorMessage = 'Ошибка ${response.statusCode}: ${response.body}';
          }
        }
        debugPrint('=== THROWING ERROR ===');
        debugPrint('Error Message: $errorMessage');
        throw Exception(errorMessage);
      }
    } on http.ClientException catch (e) {
      debugPrint('=== HTTP CLIENT EXCEPTION ===');
      debugPrint('Error: ${e.message}');
      throw Exception('Ошибка подключения: ${e.message}');
    } on FormatException catch (e) {
      debugPrint('=== FORMAT EXCEPTION ===');
      debugPrint('Error: $e');
      throw Exception('Ошибка обработки ответа сервера');
    } catch (e, stackTrace) {
      debugPrint('=== UNKNOWN ERROR ===');
      debugPrint('Error: $e');
      debugPrint('Stack Trace: $stackTrace');
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Неизвестная ошибка: $e');
    }
  }

  /// Получает информацию о текущем пользователе
  /// 
  /// Возвращает [UserInfo] при успешном запросе (200)
  /// Выбрасывает исключение при ошибке
  Future<UserInfo> getMe() async {
    try {
      final url = Uri.parse('$baseUrl${ApiConfig.getMe}');

      debugPrint('=== GET ME REQUEST ===');
      debugPrint('URL: $url');

      final response = await client.get(
        url,
        headers: _getHeaders(),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          debugPrint('=== GET ME TIMEOUT ===');
          throw Exception('Время ожидания истекло. Проверьте подключение к интернету.');
        },
      );

      debugPrint('=== GET ME RESPONSE ===');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Headers: ${response.headers}');
      debugPrint('Body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final jsonData = jsonDecode(response.body);
          if (jsonData is! Map<String, dynamic>) {
            debugPrint('=== GET ME INVALID JSON FORMAT ===');
            debugPrint('Response is not a Map: $jsonData');
            throw Exception('Неверный формат ответа сервера');
          }
          debugPrint('=== GET ME SUCCESS ===');
          debugPrint('Response Data: $jsonData');
          
          // Извлекаем данные из поля 'data', если оно есть
          final userData = jsonData['data'] as Map<String, dynamic>? ?? jsonData;
          debugPrint('=== USER DATA EXTRACTED ===');
          debugPrint('User Data: $userData');
          
          return UserInfo.fromJson(userData);
        } catch (e) {
          debugPrint('=== GET ME JSON PARSE ERROR ===');
          debugPrint('Error: $e');
          debugPrint('Response body: ${response.body}');
          throw Exception('Ошибка обработки ответа: $e');
        }
      } else {
        String errorMessage = 'Ошибка получения информации о пользователе';
        try {
          final errorData = jsonDecode(response.body) as Map<String, dynamic>;
          debugPrint('=== GET ME ERROR DATA ===');
          debugPrint('Error Data: $errorData');
          
          errorMessage = errorData['message'] as String? ?? 
                        errorData['error'] as String? ??
                        errorData['detail'] as String? ??
                        errorMessage;
        } catch (e) {
          debugPrint('=== ERROR PARSING FAILED ===');
          debugPrint('Error: $e');
          debugPrint('Response body: ${response.body}');
          
          if (response.statusCode == 401) {
            errorMessage = 'Требуется авторизация';
          } else if (response.statusCode == 403) {
            errorMessage = 'Доступ запрещен';
          } else if (response.statusCode >= 500) {
            errorMessage = 'Ошибка сервера. Попробуйте позже';
          } else {
            errorMessage = 'Ошибка ${response.statusCode}: ${response.body}';
          }
        }
        debugPrint('=== THROWING ERROR ===');
        debugPrint('Error Message: $errorMessage');
        throw Exception(errorMessage);
      }
    } on http.ClientException catch (e) {
      debugPrint('=== HTTP CLIENT EXCEPTION ===');
      debugPrint('Error: ${e.message}');
      throw Exception('Ошибка подключения: ${e.message}');
    } on FormatException catch (e) {
      debugPrint('=== FORMAT EXCEPTION ===');
      debugPrint('Error: $e');
      throw Exception('Ошибка обработки ответа сервера');
    } catch (e, stackTrace) {
      debugPrint('=== UNKNOWN ERROR ===');
      debugPrint('Error: $e');
      debugPrint('Stack Trace: $stackTrace');
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Неизвестная ошибка: $e');
    }
  }

  /// Получить список собственных заказов пользователя
  Future<List<OrderOwn>> getOrderOwn() async {
    try {
      final url = Uri.parse('$baseUrl${ApiConfig.orderOwn}');

      debugPrint('=== GET ORDER OWN REQUEST ===');
      debugPrint('URL: $url');

      final response = await client.get(
        url,
        headers: _getHeaders(),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          debugPrint('=== GET ORDER OWN TIMEOUT ===');
          throw Exception('Время ожидания истекло. Проверьте подключение к интернету.');
        },
      );

      debugPrint('=== GET ORDER OWN RESPONSE ===');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final jsonData = jsonDecode(response.body);
          
          // Проверяем, является ли ответ массивом
          if (jsonData is List) {
            debugPrint('=== GET ORDER OWN SUCCESS ===');
            debugPrint('Found ${jsonData.length} orders');
            return jsonData
                .map((item) => OrderOwn.fromJson(item as Map<String, dynamic>))
                .toList();
          } else if (jsonData is Map<String, dynamic>) {
            // Если ответ обернут в объект (например, {"results": [...]})
            if (jsonData.containsKey('results') && jsonData['results'] is List) {
              final results = jsonData['results'] as List;
              debugPrint('=== GET ORDER OWN SUCCESS (wrapped) ===');
              debugPrint('Found ${results.length} orders');
              return results
                  .map((item) => OrderOwn.fromJson(item as Map<String, dynamic>))
                  .toList();
            } else if (jsonData.containsKey('data') && jsonData['data'] is List) {
              final data = jsonData['data'] as List;
              debugPrint('=== GET ORDER OWN SUCCESS (data) ===');
              debugPrint('Found ${data.length} orders');
              return data
                  .map((item) => OrderOwn.fromJson(item as Map<String, dynamic>))
                  .toList();
            } else {
              debugPrint('=== GET ORDER OWN INVALID FORMAT ===');
              debugPrint('Response is not a list or wrapped list: $jsonData');
              throw Exception('Неверный формат ответа сервера');
            }
          } else {
            debugPrint('=== GET ORDER OWN INVALID FORMAT ===');
            debugPrint('Response is not a list: $jsonData');
            throw Exception('Неверный формат ответа сервера');
          }
        } catch (e) {
          debugPrint('=== GET ORDER OWN JSON PARSE ERROR ===');
          debugPrint('Error: $e');
          debugPrint('Response body: ${response.body}');
          throw Exception('Ошибка обработки ответа: $e');
        }
      } else {
        String errorMessage = 'Ошибка получения заказов';
        try {
          final errorData = jsonDecode(response.body) as Map<String, dynamic>;
          debugPrint('=== GET ORDER OWN ERROR DATA ===');
          debugPrint('Error Data: $errorData');
          
          errorMessage = errorData['message'] as String? ?? 
                        errorData['error'] as String? ??
                        errorData['detail'] as String? ??
                        errorMessage;
        } catch (e) {
          debugPrint('=== ERROR PARSING FAILED ===');
          debugPrint('Error: $e');
          debugPrint('Response body: ${response.body}');
          
          if (response.statusCode == 401) {
            errorMessage = 'Требуется авторизация';
          } else if (response.statusCode == 403) {
            errorMessage = 'Доступ запрещен';
          } else if (response.statusCode >= 500) {
            errorMessage = 'Ошибка сервера. Попробуйте позже';
          } else {
            errorMessage = 'Ошибка ${response.statusCode}: ${response.body}';
          }
        }
        debugPrint('=== THROWING ERROR ===');
        debugPrint('Error Message: $errorMessage');
        throw Exception(errorMessage);
      }
    } on http.ClientException catch (e) {
      debugPrint('=== HTTP CLIENT EXCEPTION ===');
      debugPrint('Error: ${e.message}');
      throw Exception('Ошибка подключения: ${e.message}');
    } on FormatException catch (e) {
      debugPrint('=== FORMAT EXCEPTION ===');
      debugPrint('Error: $e');
      throw Exception('Ошибка обработки ответа сервера');
    } catch (e, stackTrace) {
      debugPrint('=== UNKNOWN ERROR ===');
      debugPrint('Error: $e');
      debugPrint('Stack Trace: $stackTrace');
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Неизвестная ошибка: $e');
    }
  }

  /// Создать новый заказ
  Future<OrderOwn> createOrderOwn(OrderOwnCreateRequest request) async {
    try {
      final url = Uri.parse('$baseUrl${ApiConfig.orderOwn}');

      // Отправляем данные напрямую, без обертки 'data'
      // Сервер не видит данные внутри обертки 'data'
      final requestBody = request.toJson();
      
      debugPrint('=== CREATE ORDER OWN REQUEST ===');
      debugPrint('URL: $url');
      debugPrint('Request Body: ${jsonEncode(requestBody)}');

      final response = await client.post(
        url,
        headers: _getHeaders(),
        body: jsonEncode(requestBody),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          debugPrint('=== CREATE ORDER OWN TIMEOUT ===');
          throw Exception('Время ожидания истекло. Проверьте подключение к интернету.');
        },
      );

      debugPrint('=== CREATE ORDER OWN RESPONSE ===');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Body: ${response.body}');

      if (response.statusCode == 201) {
        try {
          final jsonData = jsonDecode(response.body);
          if (jsonData is! Map<String, dynamic>) {
            debugPrint('=== CREATE ORDER OWN INVALID JSON FORMAT ===');
            debugPrint('Response is not a Map: $jsonData');
            throw Exception('Неверный формат ответа сервера');
          }
          debugPrint('=== CREATE ORDER OWN SUCCESS ===');
          debugPrint('Response Data: $jsonData');
          
          // Проверяем, обернут ли ответ в 'data'
          Map<String, dynamic> orderData;
          if (jsonData.containsKey('data') && jsonData['data'] is Map<String, dynamic>) {
            orderData = jsonData['data'] as Map<String, dynamic>;
            debugPrint('=== ORDER DATA EXTRACTED FROM WRAPPER ===');
          } else {
            orderData = jsonData;
            debugPrint('=== ORDER DATA USED DIRECTLY ===');
          }
          
          debugPrint('=== ORDER DATA ===');
          debugPrint('Order Data: $orderData');
          
          return OrderOwn.fromJson(orderData);
        } catch (e) {
          debugPrint('=== CREATE ORDER OWN JSON PARSE ERROR ===');
          debugPrint('Error: $e');
          debugPrint('Response body: ${response.body}');
          throw Exception('Ошибка обработки ответа: $e');
        }
      } else {
        String errorMessage = 'Ошибка создания заказа';
        try {
          final errorData = jsonDecode(response.body) as Map<String, dynamic>;
          debugPrint('=== CREATE ORDER OWN ERROR DATA ===');
          debugPrint('Error Data: $errorData');
          
          // Обработка ошибок валидации (формат: {"field": ["сообщение"], ...})
          final fieldErrors = <String, String>{};
          final errorMessages = <String>[];
          
          errorData.forEach((key, value) {
            String fieldName = key;
            String errorText = '';
            
            if (value is List && value.isNotEmpty) {
              errorText = value.first.toString();
            } else if (value is String) {
              errorText = value;
            } else {
              errorText = value.toString();
            }
            
            // Переводим названия полей на русский для пользователя
            final fieldNames = {
              'track_number': 'Номер отслеживания',
              'market_name': 'Название магазина',
              'url_product': 'Ссылка на товар',
              'product_name': 'Название товара',
              'product_price': 'Цена товара',
              'product_quantity': 'Количество товара',
              'product_color': 'Цвет товара',
              'receiver_address': 'Адрес доставки',
              'product_weight': 'Вес товара',
              'product_size': 'Размер товара',
            };
            
            final displayName = fieldNames[fieldName] ?? fieldName;
            fieldErrors[displayName] = errorText;
            errorMessages.add('$displayName: $errorText');
          });
          
          if (fieldErrors.isNotEmpty) {
            // Формируем список незаполненных полей
            final missingFields = fieldErrors.keys.toList();
            errorMessage = 'Не заполнены обязательные поля:\n${missingFields.join(', ')}';
            debugPrint('=== VALIDATION ERRORS ===');
            debugPrint('Missing fields: $missingFields');
            debugPrint('All errors: $errorMessages');
          } else if (errorData.containsKey('message')) {
            errorMessage = errorData['message'] as String;
          } else if (errorData.containsKey('error')) {
            errorMessage = errorData['error'] as String;
          } else if (errorData.containsKey('detail')) {
            errorMessage = errorData['detail'] as String;
          }
        } catch (e) {
          debugPrint('=== ERROR PARSING FAILED ===');
          debugPrint('Error: $e');
          debugPrint('Response body: ${response.body}');
          
          if (response.statusCode == 400) {
            errorMessage = 'Неверные данные запроса. Проверьте заполнение всех полей';
          } else if (response.statusCode == 401) {
            errorMessage = 'Требуется авторизация';
          } else if (response.statusCode == 403) {
            errorMessage = 'Доступ запрещен';
          } else if (response.statusCode >= 500) {
            errorMessage = 'Ошибка сервера. Попробуйте позже';
          } else {
            errorMessage = 'Ошибка ${response.statusCode}: ${response.body}';
          }
        }
        debugPrint('=== THROWING ERROR ===');
        debugPrint('Error Message: $errorMessage');
        throw Exception(errorMessage);
      }
    } on http.ClientException catch (e) {
      debugPrint('=== HTTP CLIENT EXCEPTION ===');
      debugPrint('Error: ${e.message}');
      throw Exception('Ошибка подключения: ${e.message}');
    } on FormatException catch (e) {
      debugPrint('=== FORMAT EXCEPTION ===');
      debugPrint('Error: $e');
      throw Exception('Ошибка обработки ответа сервера');
    } catch (e, stackTrace) {
      debugPrint('=== UNKNOWN ERROR ===');
      debugPrint('Error: $e');
      debugPrint('Stack Trace: $stackTrace');
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Неизвестная ошибка: $e');
    }
  }

  /// Получить заказ по ID
  Future<OrderOwn> getOrderOwnById(int id) async {
    try {
      final url = Uri.parse('$baseUrl${ApiConfig.orderOwn}$id/');

      debugPrint('=== GET ORDER OWN BY ID REQUEST ===');
      debugPrint('URL: $url');

      final response = await client.get(
        url,
        headers: _getHeaders(),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          debugPrint('=== GET ORDER OWN BY ID TIMEOUT ===');
          throw Exception('Время ожидания истекло. Проверьте подключение к интернету.');
        },
      );

      debugPrint('=== GET ORDER OWN BY ID RESPONSE ===');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final jsonData = jsonDecode(response.body);
          if (jsonData is! Map<String, dynamic>) {
            debugPrint('=== GET ORDER OWN BY ID INVALID JSON FORMAT ===');
            debugPrint('Response is not a Map: $jsonData');
            throw Exception('Неверный формат ответа сервера');
          }
          debugPrint('=== GET ORDER OWN BY ID SUCCESS ===');
          debugPrint('Response Data: $jsonData');
          return OrderOwn.fromJson(jsonData);
        } catch (e) {
          debugPrint('=== GET ORDER OWN BY ID JSON PARSE ERROR ===');
          debugPrint('Error: $e');
          debugPrint('Response body: ${response.body}');
          throw Exception('Ошибка обработки ответа: $e');
        }
      } else {
        String errorMessage = 'Ошибка получения заказа';
        try {
          final errorData = jsonDecode(response.body) as Map<String, dynamic>;
          debugPrint('=== GET ORDER OWN BY ID ERROR DATA ===');
          debugPrint('Error Data: $errorData');
          
          errorMessage = errorData['message'] as String? ?? 
                        errorData['error'] as String? ??
                        errorData['detail'] as String? ??
                        errorMessage;
        } catch (e) {
          debugPrint('=== ERROR PARSING FAILED ===');
          debugPrint('Error: $e');
          debugPrint('Response body: ${response.body}');
          
          if (response.statusCode == 401) {
            errorMessage = 'Требуется авторизация';
          } else if (response.statusCode == 403) {
            errorMessage = 'Доступ запрещен';
          } else if (response.statusCode == 404) {
            errorMessage = 'Заказ не найден';
          } else if (response.statusCode >= 500) {
            errorMessage = 'Ошибка сервера. Попробуйте позже';
          } else {
            errorMessage = 'Ошибка ${response.statusCode}: ${response.body}';
          }
        }
        debugPrint('=== THROWING ERROR ===');
        debugPrint('Error Message: $errorMessage');
        throw Exception(errorMessage);
      }
    } on http.ClientException catch (e) {
      debugPrint('=== HTTP CLIENT EXCEPTION ===');
      debugPrint('Error: ${e.message}');
      throw Exception('Ошибка подключения: ${e.message}');
    } on FormatException catch (e) {
      debugPrint('=== FORMAT EXCEPTION ===');
      debugPrint('Error: $e');
      throw Exception('Ошибка обработки ответа сервера');
    } catch (e, stackTrace) {
      debugPrint('=== UNKNOWN ERROR ===');
      debugPrint('Error: $e');
      debugPrint('Stack Trace: $stackTrace');
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Неизвестная ошибка: $e');
    }
  }

  /// Получить список адресов доставки
  Future<List<Receiver>> getAddresses() async {
    try {
      final url = Uri.parse('$baseUrl${ApiConfig.addresses}');

      debugPrint('=== GET ADDRESSES REQUEST ===');
      debugPrint('URL: $url');

      final response = await client.get(
        url,
        headers: _getHeaders(),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          debugPrint('=== GET ADDRESSES TIMEOUT ===');
          throw Exception('Время ожидания истекло. Проверьте подключение к интернету.');
        },
      );

      debugPrint('=== GET ADDRESSES RESPONSE ===');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Headers: ${response.headers}');
      debugPrint('Body: ${response.body}');
      debugPrint('Request Headers: ${_getHeaders()}');

      if (response.statusCode == 200) {
        try {
          final jsonData = jsonDecode(response.body);
          
          if (jsonData is List) {
            debugPrint('=== GET ADDRESSES SUCCESS ===');
            debugPrint('Found ${jsonData.length} addresses');
            return jsonData
                .map((item) => Receiver.fromJson(item as Map<String, dynamic>))
                .toList();
          } else if (jsonData is Map<String, dynamic>) {
            if (jsonData.containsKey('results') && jsonData['results'] is List) {
              final results = jsonData['results'] as List;
              debugPrint('=== GET ADDRESSES SUCCESS (wrapped) ===');
              debugPrint('Found ${results.length} addresses');
              return results
                  .map((item) => Receiver.fromJson(item as Map<String, dynamic>))
                  .toList();
            } else if (jsonData.containsKey('data') && jsonData['data'] is List) {
              final data = jsonData['data'] as List;
              debugPrint('=== GET ADDRESSES SUCCESS (data) ===');
              debugPrint('Found ${data.length} addresses');
              return data
                  .map((item) => Receiver.fromJson(item as Map<String, dynamic>))
                  .toList();
            } else {
              debugPrint('=== GET ADDRESSES INVALID FORMAT ===');
              throw Exception('Неверный формат ответа сервера');
            }
          } else {
            debugPrint('=== GET ADDRESSES INVALID FORMAT ===');
            throw Exception('Неверный формат ответа сервера');
          }
        } catch (e) {
          debugPrint('=== GET ADDRESSES JSON PARSE ERROR ===');
          debugPrint('Error: $e');
          throw Exception('Ошибка обработки ответа: $e');
        }
      } else {
        String errorMessage = 'Ошибка получения адресов';
        debugPrint('=== GET ADDRESSES ERROR ===');
        debugPrint('Status Code: ${response.statusCode}');
        debugPrint('Response Body: ${response.body}');
        
        try {
          final errorData = jsonDecode(response.body) as Map<String, dynamic>;
          debugPrint('=== ERROR DATA PARSED ===');
          debugPrint('Error Data: $errorData');
          
          errorMessage = errorData['message'] as String? ?? 
                        errorData['error'] as String? ??
                        errorData['detail'] as String? ??
                        errorMessage;
        } catch (e) {
          debugPrint('=== ERROR PARSING FAILED ===');
          debugPrint('Parse Error: $e');
          debugPrint('Response body: ${response.body}');
          
          if (response.statusCode == 401) {
            errorMessage = 'Требуется авторизация. Пожалуйста, войдите снова';
            debugPrint('=== 401 UNAUTHORIZED ===');
            debugPrint('Token: ${_authToken != null ? "${_authToken!.substring(0, 20)}..." : "null"}');
          } else if (response.statusCode == 403) {
            errorMessage = 'Доступ запрещен';
          } else if (response.statusCode == 404) {
            errorMessage = 'Адреса не найдены';
          } else if (response.statusCode >= 500) {
            errorMessage = 'Ошибка сервера. Попробуйте позже';
          } else {
            errorMessage = 'Ошибка ${response.statusCode}: ${response.body.isNotEmpty ? response.body : "Неизвестная ошибка"}';
          }
        }
        
        debugPrint('=== THROWING ERROR ===');
        debugPrint('Error Message: $errorMessage');
        throw Exception(errorMessage);
      }
    } on http.ClientException catch (e) {
      debugPrint('=== HTTP CLIENT EXCEPTION ===');
      throw Exception('Ошибка подключения: ${e.message}');
    } on FormatException {
      debugPrint('=== FORMAT EXCEPTION ===');
      throw Exception('Ошибка обработки ответа сервера');
    } catch (e, stackTrace) {
      debugPrint('=== UNKNOWN ERROR ===');
      debugPrint('Error: $e');
      debugPrint('Stack Trace: $stackTrace');
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Неизвестная ошибка: $e');
    }
  }

  /// Создать новый адрес доставки
  Future<Receiver> createAddress(ReceiverCreateRequest request) async {
    try {
      final url = Uri.parse('$baseUrl${ApiConfig.addresses}');

      debugPrint('=== CREATE ADDRESS REQUEST ===');
      debugPrint('URL: $url');
      debugPrint('Body: ${jsonEncode(request.toJson())}');

      final response = await client.post(
        url,
        headers: _getHeaders(),
        body: jsonEncode(request.toJson()),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          debugPrint('=== CREATE ADDRESS TIMEOUT ===');
          throw Exception('Время ожидания истекло. Проверьте подключение к интернету.');
        },
      );

      debugPrint('=== CREATE ADDRESS RESPONSE ===');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Body: ${response.body}');

      if (response.statusCode == 201) {
        try {
          final jsonData = jsonDecode(response.body);
          if (jsonData is! Map<String, dynamic>) {
            debugPrint('=== CREATE ADDRESS INVALID JSON FORMAT ===');
            throw Exception('Неверный формат ответа сервера');
          }
          debugPrint('=== CREATE ADDRESS SUCCESS ===');
          return Receiver.fromJson(jsonData);
        } catch (e) {
          debugPrint('=== CREATE ADDRESS JSON PARSE ERROR ===');
          debugPrint('Error: $e');
          throw Exception('Ошибка обработки ответа: $e');
        }
      } else {
        String errorMessage = 'Ошибка создания адреса';
        try {
          final errorData = jsonDecode(response.body) as Map<String, dynamic>;
          
          if (errorData.containsKey('data') && errorData['data'] is Map) {
            final dataErrors = errorData['data'] as Map<String, dynamic>;
            final errorMessages = <String>[];
            dataErrors.forEach((key, value) {
              if (value is List) {
                errorMessages.addAll(value.map((e) => e.toString()));
              } else {
                errorMessages.add(value.toString());
              }
            });
            if (errorMessages.isNotEmpty) {
              errorMessage = errorMessages.join(', ');
            }
          } else {
            errorMessage = errorData['message'] as String? ?? 
                          errorData['error'] as String? ??
                          errorData['detail'] as String? ??
                          errorMessage;
          }
        } catch (e) {
          if (response.statusCode == 400) {
            errorMessage = 'Неверные данные запроса';
          } else if (response.statusCode == 401) {
            errorMessage = 'Требуется авторизация';
          } else if (response.statusCode == 403) {
            errorMessage = 'Доступ запрещен';
          } else if (response.statusCode >= 500) {
            errorMessage = 'Ошибка сервера. Попробуйте позже';
          }
        }
        throw Exception(errorMessage);
      }
    } on http.ClientException catch (e) {
      debugPrint('=== HTTP CLIENT EXCEPTION ===');
      throw Exception('Ошибка подключения: ${e.message}');
    } on FormatException {
      debugPrint('=== FORMAT EXCEPTION ===');
      throw Exception('Ошибка обработки ответа сервера');
    } catch (e, stackTrace) {
      debugPrint('=== UNKNOWN ERROR ===');
      debugPrint('Error: $e');
      debugPrint('Stack Trace: $stackTrace');
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Неизвестная ошибка: $e');
    }
  }

  /// Получить адрес по ID
  Future<Receiver> getAddressById(int addressId) async {
    try {
      final url = Uri.parse('$baseUrl${ApiConfig.addressById(addressId)}');

      debugPrint('=== GET ADDRESS BY ID REQUEST ===');
      debugPrint('URL: $url');

      final response = await client.get(
        url,
        headers: _getHeaders(),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          debugPrint('=== GET ADDRESS BY ID TIMEOUT ===');
          throw Exception('Время ожидания истекло. Проверьте подключение к интернету.');
        },
      );

      debugPrint('=== GET ADDRESS BY ID RESPONSE ===');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final jsonData = jsonDecode(response.body);
          if (jsonData is! Map<String, dynamic>) {
            debugPrint('=== GET ADDRESS BY ID INVALID JSON FORMAT ===');
            throw Exception('Неверный формат ответа сервера');
          }
          debugPrint('=== GET ADDRESS BY ID SUCCESS ===');
          return Receiver.fromJson(jsonData);
        } catch (e) {
          debugPrint('=== GET ADDRESS BY ID JSON PARSE ERROR ===');
          debugPrint('Error: $e');
          throw Exception('Ошибка обработки ответа: $e');
        }
      } else {
        String errorMessage = 'Ошибка получения адреса';
        try {
          final errorData = jsonDecode(response.body) as Map<String, dynamic>;
          errorMessage = errorData['message'] as String? ?? 
                        errorData['error'] as String? ??
                        errorData['detail'] as String? ??
                        errorMessage;
        } catch (e) {
          if (response.statusCode == 401) {
            errorMessage = 'Требуется авторизация';
          } else if (response.statusCode == 403) {
            errorMessage = 'Доступ запрещен';
          } else if (response.statusCode == 404) {
            errorMessage = 'Адрес не найден';
          } else if (response.statusCode >= 500) {
            errorMessage = 'Ошибка сервера. Попробуйте позже';
          }
        }
        throw Exception(errorMessage);
      }
    } on http.ClientException catch (e) {
      debugPrint('=== HTTP CLIENT EXCEPTION ===');
      throw Exception('Ошибка подключения: ${e.message}');
    } on FormatException {
      debugPrint('=== FORMAT EXCEPTION ===');
      throw Exception('Ошибка обработки ответа сервера');
    } catch (e, stackTrace) {
      debugPrint('=== UNKNOWN ERROR ===');
      debugPrint('Error: $e');
      debugPrint('Stack Trace: $stackTrace');
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Неизвестная ошибка: $e');
    }
  }
}

