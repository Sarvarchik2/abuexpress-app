import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

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

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<void> initialize() async {
    // 1. Инициализация Firebase (если еще не инициализирован, лучше вызывать в main)
    
    // 2. Запрос разрешений
    await _requestPermission();

    // 3. Настройка обработчика сообщений в фоне
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // 4. Получение токена (и отправка на сервер)
    await _getToken();

    // 5. Обработка сообщений на переднем плане
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Got a message whilst in the foreground!');
      debugPrint('Message data: ${message.data}');

      if (message.notification != null) {
        debugPrint('Message also contained a notification: ${message.notification}');
        // Здесь можно показать локальное уведомление или обновить UI
      }
    });
    
    // Обработка открытия приложения по клику на уведомление
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
       debugPrint('A new onMessageOpenedApp event was published!');
       // Навигация
    });
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
      String? token = await _messaging.getToken();
      debugPrint('FCM Token: $token');
      // TODO: Отправить этот токен на бэкенд для привязки к пользователю
      return token;
    } catch (e) {
      debugPrint('Error getting FCM token: $e');
      return null;
    }
  }
}
