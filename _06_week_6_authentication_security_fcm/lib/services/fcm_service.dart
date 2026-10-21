import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// 1. Background Handler HARUS berupa fungsi top-level
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Dilarang keras menggunakan BuildContext di sini!
  debugPrint("Handling a background message: ${message.messageId}");
}

void registerBackgroundHandler() {
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
}

final FlutterLocalNotificationsPlugin _localNotifications =
    FlutterLocalNotificationsPlugin();

// 2. Inisialisasi Local Notification untuk Foreground
Future<void> initLocalNotifications(
    void Function(String route) navigate) async {
  const AndroidInitializationSettings initSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const DarwinInitializationSettings initSettingsIOS =
      DarwinInitializationSettings();

  const InitializationSettings initSettings = InitializationSettings(
    android: initSettingsAndroid,
    iOS: initSettingsIOS,
  );

  await _localNotifications.initialize(
    initSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) {
      final route = response.payload;
      if (route != null) {
        navigate(route); // Callback untuk go_router
      }
    },
  );
}

// 3. Handle Permission, Token, dan Topic
Future<void> initFcmToken(
    {required Future<void> Function(String) onToken}) async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  // Request permission (Penting untuk iOS & Android 13+)
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    debugPrint('User granted permission');

    // Get Token
    String? token = await messaging.getToken();
    if (token != null) await onToken(token);

    // Simulasi POST token baru ke backend saat token kedaluwarsa (onTokenRefresh)
    messaging.onTokenRefresh.listen((newToken) {
      debugPrint("MENGIRIM POST KE BACKEND: Token Baru = $newToken");
      // TODO: Panggil Dio/HTTP POST ke API backend di sini
    });

    // Subscribe Topic
    await messaging.subscribeToTopic('pengumuman-kampus');
    debugPrint('Subscribed to topic: pengumuman-kampus');
  } else {
    debugPrint('User declined or has not accepted permission');
  }
}

// 4. Handle Notifikasi saat aplikasi Foreground & Background (klik banner)
void listenForeground(void Function(String route) navigate) {
  // State: FOREGROUND
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    debugPrint('Got a message whilst in the foreground!');
    if (message.notification != null) {
      // Tampilkan local notification manual agar banner muncul di foreground
      _showLocalNotification(message);
    }
  });

  // State: BACKGROUND (Aplikasi terbuka tapi di latar belakang)
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    debugPrint('A new onMessageOpenedApp event was published!');
    final route = message.data['route'];
    if (route != null) navigate(route);
  });
}

// 5. Handle Notifikasi saat aplikasi Terminated (Mati total)
Future<void> handleTerminated(void Function(String route) navigate) async {
  RemoteMessage? initialMessage =
      await FirebaseMessaging.instance.getInitialMessage();

  if (initialMessage != null) {
    final route = initialMessage.data['route'];
    if (route != null) {
      // Navigasi setelah delay kecil agar router siap
      Future.delayed(const Duration(milliseconds: 500), () {
        navigate(route);
      });
    }
  }
}

String routeFromMessage(Map<String, dynamic> data) {
  final route = data['route'] as String?;
  if (route == null || route.isEmpty) return '/';
  return route.startsWith('/') ? route : '/$route';
}

// Helper untuk memunculkan notifikasi manual di Foreground
Future<void> _showLocalNotification(RemoteMessage message) async {
  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'campus_channel',
    'Campus Notifications',
    importance: Importance.max,
    priority: Priority.high,
  );

  const NotificationDetails platformDetails = NotificationDetails(
    android: androidDetails,
    iOS: DarwinNotificationDetails(
        presentAlert: true, presentBadge: true, presentSound: true),
  );

  await _localNotifications.show(
    message.hashCode,
    message.notification?.title,
    message.notification?.body,
    platformDetails,
    payload:
        message.data['route'], // Simpan data route ke payload untuk klik event
  );
}
