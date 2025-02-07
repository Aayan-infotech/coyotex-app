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

  static getDeviceToken() async {
    await FirebaseMessaging.instance.getToken().then((value) {
      debugPrint("Device Token: $value");
    });
  }
}
