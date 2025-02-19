import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _flutterLocalNotificationPlugin =
      FlutterLocalNotificationsPlugin();

  static initlizeLocalNotification(GlobalKey<NavigatorState> navigatorKey) {
    var androidInit =
        const AndroidInitializationSettings("@mipmap/ic_launcher");
    var initializationSettings = InitializationSettings(android: androidInit);
    _flutterLocalNotificationPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: (details) async {});
  }

  static showNotification(RemoteMessage event) async {
    debugPrint(event.data.toString());
    BigTextStyleInformation bigTextStyleInformation = BigTextStyleInformation(
      event.notification!.body.toString(),
      htmlFormatBigText: true,
      contentTitle: event.notification!.title.toString(),
      htmlFormatContentTitle: true,
    );

    var androidNotificationDetails = AndroidNotificationDetails(
      "com.hunt30.coyotex",
      "Coyotex",
      importance: Importance.high,
      styleInformation: bigTextStyleInformation,
      priority: Priority.high,
      color: Colors.blue,
      playSound: true,
      enableLights: true,
      enableVibration: true,
      ticker: 'ticker',
    );

    NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);

    await _flutterLocalNotificationPlugin.show(
      0,
      event.notification!.title,
      event.notification!.body,
      notificationDetails,
      payload: event.data['type'].toString(),
    );
  }

  messageInit(GlobalKey<NavigatorState> navigatorKey) async {
    initlizeLocalNotification(navigatorKey);
    requestPermission();

    await FirebaseMessaging.instance.getInitialMessage().then((event) async {
      if (event != null) {
        await NotificationService.showNotification(event);
        debugPrint(event.toString());
      }
    });

    FirebaseMessaging.onMessage.listen((event) async {
      await NotificationService.showNotification(event);
      debugPrint(event.notification!.title);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((event) async {
      await NotificationService.showNotification(event);
      debugPrint(event.notification!.title);
    });
  }

  static requestPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await messaging.requestPermission();
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint("User granted permission");
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      debugPrint("User granted provisional permission");
    } else {
      debugPrint("User denied permission");
    }
  }



  static Future<String?> getDeviceToken() async {
    try {
      FirebaseMessaging messaging = FirebaseMessaging.instance;

      // Request permission for push notifications
      NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        debugPrint("Push notifications permission denied.");
        return null;
      }

      // Ensure APNS token is available for iOS
      String? apnsToken = await messaging.getAPNSToken();
      if (apnsToken == null) {
        debugPrint("APNS token not available yet.");
        return null;
      }

      // Fetch the FCM token
      String? token = await messaging.getToken();
      debugPrint("FCM Device Token: $token");
      return token;
    } catch (e) {
      debugPrint("Error getting device token: $e");
      return null;
    }
  }
}
