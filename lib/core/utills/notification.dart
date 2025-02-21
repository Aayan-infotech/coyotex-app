import 'dart:io';
import 'dart:math';

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

  // static showNotification(RemoteMessage event) async {
  //   debugPrint(event.data.toString());
  //   BigTextStyleInformation bigTextStyleInformation = BigTextStyleInformation(
  //     event.notification!.body.toString(),
  //     htmlFormatBigText: true,
  //     contentTitle: event.notification!.title.toString(),
  //     htmlFormatContentTitle: true,
  //   );

  //   var androidNotificationDetails = AndroidNotificationDetails(
  //     "com.hunt30.coyotex",
  //     "Coyotex",
  //     importance: Importance.high,
  //     styleInformation: bigTextStyleInformation,
  //     priority: Priority.high,
  //     color: Colors.blue,
  //     playSound: true,
  //     enableLights: true,
  //     enableVibration: true,
  //     ticker: 'ticker',
  //   );

  //   NotificationDetails notificationDetails =
  //       NotificationDetails(android: androidNotificationDetails);

  //   await _flutterLocalNotificationPlugin.show(
  //     0,
  //     event.notification!.title,
  //     event.notification!.body,
  //     notificationDetails,
  //     payload: event.data['type'].toString(),
  //   );
  // }

  // static showNotification(RemoteMessage event) async {
  //   debugPrint(event.data.toString());
  //   Random random = Random();
  //   int id = random.nextInt(1000);

  //   if (Platform.isAndroid) {
  //     // Android-specific notification details
  //     BigTextStyleInformation bigTextStyleInformation = BigTextStyleInformation(
  //       event.notification!.body.toString(),
  //       htmlFormatBigText: true,
  //       contentTitle: event.notification!.title.toString(),
  //       htmlFormatContentTitle: true,
  //     );

  //     var androidNotificationDetails = AndroidNotificationDetails(
  //       "com.hunt30.coyotex",
  //       "Coyotex",
  //       importance: Importance.high,
  //       styleInformation: bigTextStyleInformation,
  //       priority: Priority.high,
  //       color: Colors.blue,
  //       playSound: true,
  //       enableLights: true,
  //       enableVibration: true,
  //       ticker: 'ticker',
  //     );

  //     NotificationDetails notificationDetails = NotificationDetails(
  //       android: androidNotificationDetails,
  //     );

  //     await _flutterLocalNotificationPlugin.show(
  //       0,
  //       event.notification!.title,
  //       event.notification!.body,
  //       notificationDetails,
  //       payload: event.data['type'].toString(),
  //     );
  //   } else if (Platform.isIOS || Platform.isMacOS) {
  //     // iOS/macOS-specific notification details
  //     var darwinNotificationDetails = DarwinNotificationDetails(
  //       presentSound: true,
  //       presentAlert: true,
  //       presentBadge: true,
  //     );

  //     NotificationDetails notificationDetails = NotificationDetails(
  //       iOS: darwinNotificationDetails,
  //       macOS: darwinNotificationDetails,
  //     );

  //     await _flutterLocalNotificationPlugin.show(
  //       id,
  //       event.notification!.title,
  //       event.notification!.body,
  //       notificationDetails,
  //       payload: "Text", //event.data['type'].toString(),
  //     );
  //   }
  // }
  static showNotification(RemoteMessage message) async {
    try {
      //  Alert.log(runtimeType.toString(),"In Notification method");

      // Generate a random ID for the notification
      Random random = Random();
      int id = random.nextInt(1000);

      // Android-specific notification details
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        "mychannel",
        "my channel",
        importance: Importance.max,
        priority: Priority.high,
      );

      // iOS-specific notification details
      const DarwinNotificationDetails iosPlatformChannelSpecifics =
          DarwinNotificationDetails();

      // Combine the platform-specific details
      const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iosPlatformChannelSpecifics,
      );

      // Alert.log(runtimeType.toString(),"my id is ${id.toString()}");

      // Display the notification
      await _flutterLocalNotificationPlugin.show(
        id,
        message.notification?.title,
        message.notification?.body,
        platformChannelSpecifics,
        payload: 'Item X', // Optional: Pass some data to the notification
      );
    } on Exception catch (e) {
      print(e);
      // Alert.log(runtimeType.toString(),'Error>>>$e');
    }
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
      // String? apnsToken = await messaging.getAPNSToken();
      // if (apnsToken == null) {
      //   debugPrint("APNS token not available yet.");
      //   return null;
      // }

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
