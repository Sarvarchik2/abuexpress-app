import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

// Функция для обработки уведомлений в фоне (должна быть top-level)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint("Handling a background message: ${message.messageId}");
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  late final FirebaseMessaging _messaging;

  Future<void> initialize() async {
    _messaging = FirebaseMessaging.instance;
    // 1. Инициализация Firebase (если еще не инициализирован, лучше вызывать в main)
    
    // 2. Запрос разрешений
    await _requestPermission();

    // 3. Настройка обработчика сообщений в фоне
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // 4. Получение токена (и отправка на сервер) — мы теперь сделаем это в отдельном методе
    // который можно вызвать после логина. Но на всякий случай попробуем и здесь,
    // если пользователь уже залогинен.
    _syncToken();

    // Слушаем обновление токена
    _messaging.onTokenRefresh.listen((newToken) {
      debugPrint("FCM Token refreshed: $newToken");
      _sendTokenToServer(newToken);
    });

    // Включаем показ уведомлений на iOS, даже если приложение открыто (в Foreground)
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true, 
      badge: true,
      sound: true,
    );

    // 5. Обработка сообщений на переднем плане (когда приложение открыто)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('📩 Получено уведомление в открытом приложении (Foreground)!');
      debugPrint('Данные (Payload): ${message.data}');

      if (message.notification != null) {
        debugPrint('Заголовок: ${message.notification?.title}');
        debugPrint('Текст: ${message.notification?.body}');
        // Если вы добавите пакет flutter_local_notifications, здесь можно
        // показать красивый всплывающий Снекбар (SnackBar) внутри приложения.
      }
    });
    
    // 6. Обработка клика по уведомлению, когда приложение было свернуто (Background)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
       debugPrint('👆 Пользователь нажал на уведомление!');
       debugPrint('Данные (Payload) для перехода: ${message.data}');
       
       // Пример: если с бэкенда пришел ключ "order_id", можно сразу перейти на экран заказа
       // if (message.data.containsKey('order_id')) {
       //   Navigator.pushNamed(context, '/order_details', arguments: message.data['order_id']);
       // }
    });

    // 7. Обработка клика по уведомлению, если приложение было ПОЛНОСТЬЮ закрыто (Terminated)
    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      debugPrint('🚀 Приложение было запущено кликом по уведомлению!');
      debugPrint('Данные (Payload): ${initialMessage.data}');
      // Здесь тоже можно сохранить данные и сделать навигацию сразу после старта
    }
  }

  // Метод для ручного триггера отправки токена (например, после успешного логина)
  Future<void> syncToken() async {
    debugPrint("Manual sync of FMC token called (after login)");
    await _syncToken();
  }

  Future<void> _syncToken() async {
    final token = await _getToken();
    if (token != null) {
      await _sendTokenToServer(token);
    }
  }

  Future<void> _requestPermission() async {
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    debugPrint('User granted permission: ${settings.authorizationStatus}');
  }

  Future<String?> _getToken() async {
    try {
      if (!kIsWeb && Platform.isIOS) {
        debugPrint("Waiting for APNS token in background...");
        // Запускаем асинхронный процесс без блокировки метода
        _waitForAPNSTokenAndRegister();
        return null; // Возвращаем null сразу, чтобы не блокировать UI. Настоящий токен уйдет позже из _waitForAPNSTokenAndRegister
      }

      String? token = await _messaging.getToken();
      debugPrint('FCM Token (Android): $token');
      return token;
    } catch (e) {
      debugPrint('Error getting initial FCM token: $e');
      return null;
    }
  }

  // Фоновый метод, который будет долбиться пока не получит токен
  Future<void> _waitForAPNSTokenAndRegister() async {
    String? apnsToken;
    int attempts = 0;
    
    while (apnsToken == null && attempts < 30) { // Пробуем до 1 минуты
      attempts++;
      try {
         apnsToken = await _messaging.getAPNSToken();
         if (apnsToken != null) {
            debugPrint("✅ УРА! APNS token received in background: $apnsToken");
            // Как только APNS токен есть, запрашиваем FCM токен
            String? fcmToken = await _messaging.getToken();
            debugPrint('✅ FCM Token generated: $fcmToken');
            if (fcmToken != null) {
              await _sendTokenToServer(fcmToken);
            }
            break;
         }
      } catch (e) {
         debugPrint("APNS fetch attempt $attempts failed: $e");
      }
      // Ждем 2 секунды перед следующей попыткой
      await Future.delayed(const Duration(seconds: 2));
    }
    
    if (apnsToken == null) {
      debugPrint("❌ Failed to get APNS token after 30 attempts.");
    }
  }

  Future<void> _sendTokenToServer(String token) async {
    try {
      debugPrint('Sending FCM token to server...');
      final apiService = ApiService();
      
      // Get saved auth token if available
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('auth_token');
      if (authToken != null) {
        apiService.setAuthToken(authToken);
      }

      // Detect language
      String languageType = prefs.getString('language_code') ?? 'ru';

      // Device type - use strings as requested
      String deviceType = Platform.isIOS ? 'ios' : 'android';
      
      await apiService.addDevice(
        fcmToken: token,
        deviceType: deviceType,
        languageType: languageType,
      );
      
      debugPrint('FCM Token successfully sent to server');
    } catch (e) {
      debugPrint('Error sending FCM token to server: $e');
    }
  }
}
