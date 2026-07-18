import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../firebase_options.dart';
import 'notification_payload.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await NotificationService._handleMessage(message);
}

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  FirebaseMessaging? _messaging;
  FlutterLocalNotificationsPlugin? _localNotifications;
  bool _initialized = false;

  static NotificationPayload? pendingNavigationPayload;

  static const _channels = <String, AndroidNotificationChannel>{
    'siniestro': AndroidNotificationChannel(
      'siniestros',
      'Siniestros',
      description: 'Actualizaciones de tus siniestros',
      importance: Importance.high,
    ),
    'asignacion': AndroidNotificationChannel(
      'peritajes',
      'Peritajes',
      description: 'Asignaciones de peritaje',
      importance: Importance.high,
    ),
  };

  static AndroidNotificationChannel get _fallbackChannel =>
      AndroidNotificationChannel(
        'sistema',
        'Sistema',
        description: 'Avisos de cuenta y términos',
        importance: Importance.defaultImportance,
      );

  void Function(String token)? onTokenRefreshed;
  void Function(RemoteMessage message)? onMessageOpenedApp;
  void Function(NotificationPayload payload)? onNotificationTap;
  void Function(RemoteMessage message)? onForegroundMessage;

  Future<void> initialize() async {
    if (_initialized) return;

    _messaging = FirebaseMessaging.instance;
    _localNotifications = FlutterLocalNotificationsPlugin();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _createChannels();

    await _localNotifications!.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
      onDidReceiveNotificationResponse: (response) {
        if (response.payload == null) return;
        try {
          final data = jsonDecode(response.payload!) as Map<String, dynamic>;
          onNotificationTap?.call(NotificationPayload.fromJson(data));
        } catch (_) {}
      },
    );

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    FirebaseMessaging.onMessage.listen(_showForegroundNotification);

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      onMessageOpenedApp?.call(message);
    });

    final msg = await _messaging!.getInitialMessage();
    if (msg != null) {
      pendingNavigationPayload = NotificationPayload.fromMessage(msg);
    }

    _messaging!.onTokenRefresh.listen((token) {
      onTokenRefreshed?.call(token);
    });

    _initialized = true;
  }

  Future<void> requestPermission() async {
    final messaging = FirebaseMessaging.instance;
    await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  Future<String?> getToken() async {
    final messaging = FirebaseMessaging.instance;
    return messaging.getToken();
  }

  Future<void> deleteToken() async {
    final messaging = FirebaseMessaging.instance;
    await messaging.deleteToken();
  }

  Future<void> _createChannels() async {
    final plugin = _localNotifications!.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (plugin == null) return;
    for (final channel in _channels.values) {
      await plugin.createNotificationChannel(channel);
    }
    await plugin.createNotificationChannel(_fallbackChannel);
  }

  static AndroidNotificationChannel _channelFor(RemoteMessage message) {
    final type = message.data['type'] as String?;
    return _channels[type] ?? _fallbackChannel;
  }

  Future<void> _showForegroundNotification(RemoteMessage message) async {
    onForegroundMessage?.call(message);
    await _handleMessage(message);
  }

  static Future<void> _handleMessage(RemoteMessage message) async {
    final notification = message.notification;
    final data = message.data;

    if (notification == null) return;

    final channel = _channelFor(message);
    final androidDetails = AndroidNotificationDetails(
      channel.id,
      channel.name,
      channelDescription: channel.description,
      importance: channel.importance,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();

    await NotificationService.instance._localNotifications?.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      ),
      payload: data.isNotEmpty ? jsonEncode(data) : null,
    );
  }
}
