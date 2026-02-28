import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';
import '../models/notification.dart';

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
  
  // Локальное состояние уведомлений
  final ValueNotifier<List<NotificationItem>> notificationsNotifier = ValueNotifier([]);

  Future<void> _loadNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final notificationsJson = prefs.getString('saved_notifications');
    if (notificationsJson != null) {
      try {
        final List<dynamic> decoded = jsonDecode(notificationsJson);
        final notifications = decoded.map((e) => NotificationItem.fromJson(e)).toList();
        notificationsNotifier.value = notifications;
      } catch (e) {
        debugPrint('Error loading saved notifications: $e');
      }
    }
  }

  Future<void> _saveNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = notificationsNotifier.value.map((e) => e.toJson()).toList();
    await prefs.setString('saved_notifications', jsonEncode(jsonList));
  }

  void markAsRead(String id) {
    bool changed = false;
    for (var n in notificationsNotifier.value) {
      if (n.id == id && !n.isRead) {
        n.isRead = true;
        changed = true;
      }
    }
    if (changed) {
      // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
      notificationsNotifier.notifyListeners();
      _saveNotifications();
    }
  }

  void _addNewNotification(RemoteMessage message) {
    final id = message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString();
    
    // Исключаем дубликаты
    if (notificationsNotifier.value.any((n) => n.id == id)) return;

    final typeStr = message.data['status']?.toString().toLowerCase() ?? '';
    final String? orderId = message.data['order_id']?.toString();
    
    NotificationType type = NotificationType.appUpdate;
    if (typeStr.contains('transit') || typeStr.contains('shipped')) {
      type = NotificationType.parcelInTransit;
    } else if (typeStr.contains('arrived') || typeStr.contains('warehouse')) {
      type = NotificationType.parcelArrived;
    } else if (typeStr.contains('delivered')) {
      type = NotificationType.parcelDelivered;
    }

    final String title = message.notification?.title ?? "Abuexpress";
    String body = message.notification?.body ?? "Новое уведомление";

    // Улучшаем локальное отображение, если бэкенд прислал скупой текст:
    if (orderId != null && body == 'Update: delivered') {
      body = 'Ваша посылка (Заказ #$orderId) доставлена';
    } else if (orderId != null && body.startsWith('Update:')) {
       body = 'Статус заказа #$orderId изменился на: $typeStr';
    }

    final newItem = NotificationItem(
      id: id,
      title: title,
      description: body,
      dateTime: DateTime.now(),
      type: type,
      orderId: orderId,
      isRead: false,
    );
    
    notificationsNotifier.value = [newItem, ...notificationsNotifier.value];
    _saveNotifications();
  }

  Future<void> initialize() async {
    _messaging = FirebaseMessaging.instance;
    
    // Загружаем сохраненные уведомления
    await _loadNotifications();

    // 1. Инициализация Firebase (если еще не инициализирован, лучше вызывать в main)
    
    // 2. Запрос разрешений
    await _requestPermission();

    // 3. Настройка обработчика сообщений в фоне
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

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
        
        // Сохраняем уведомление в локальный список
        _addNewNotification(message);
      }
    });
    
    // 6. Обработка клика по уведомлению, когда приложение было свернуто (Background)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
       debugPrint('👆 Пользователь нажал на уведомление!');
       debugPrint('Данные (Payload) для перехода: ${message.data}');
       
       // Сохраняем уведомление
       _addNewNotification(message);
    });

    // 7. Обработка клика по уведомлению, если приложение было ПОЛНОСТЬЮ закрыто (Terminated)
    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      debugPrint('🚀 Приложение было запущено кликом по уведомлению!');
      debugPrint('Данные (Payload): ${initialMessage.data}');
      
      // Сохраняем уведомление
      _addNewNotification(initialMessage);
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

  // Состояние, чтобы не запускать несколько процессов получения токена параллельно
  bool _isFetchingApns = false;

  // Фоновый метод, который будет долбиться пока не получит токен
  Future<void> _waitForAPNSTokenAndRegister() async {
    if (_isFetchingApns) return; // Уже ищем токен, не запускаем дубликат
    _isFetchingApns = true;
    
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
    
    _isFetchingApns = false;

    if (apnsToken == null) {
      debugPrint("❌ Failed to get APNS token after 30 attempts.");
    }
  }

  Future<void> _sendTokenToServer(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastSentToken = prefs.getString('last_sent_fcm_token');
      
      if (lastSentToken == token) {
        debugPrint('FCM Token already sent & saved on this device. Skipping duplicate.');
        return; 
      }

      debugPrint('Sending FCM token to server...');
      final apiService = ApiService();
      
      // Get saved auth token if available
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
      
      // Сохраняем в память самого телефона, чтобы при следующих входах не отправлять повторно
      await prefs.setString('last_sent_fcm_token', token);
      debugPrint('FCM Token successfully sent to server and cached on device.');
    } catch (e) {
      debugPrint('Error sending FCM token to server: $e');
    }
  }
}
