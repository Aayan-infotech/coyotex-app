// import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _flutterLocalNotificationPlugin =
      FlutterLocalNotificationsPlugin();

  //--------------------------------Initialize Local Notification---------------------------//
  static initlizeLocalNotification(GlobalKey<NavigatorState> navigatorKey) {
    var androidInit =
        const AndroidInitializationSettings("@mipmap/ic_launcher");
    var initializationSettings = InitializationSettings(android: androidInit);
    _flutterLocalNotificationPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: (details) async {

    });
  }

  static showNotification(RemoteMessage event) async {
    debugPrint(event.data.toString());
    BigTextStyleInformation bigTextStyleInformation = BigTextStyleInformation(
        event.notification!.body.toString(),
        htmlFormatBigText: true,
        contentTitle: event.notification!.title.toString(),
        htmlFormatContentTitle: true);

    var platformChannelSpecifics = AndroidNotificationDetails(
      "com.hunt30.coyotex", "Coyotex",
      importance: Importance.high,
      styleInformation: bigTextStyleInformation,
      priority: Priority.defaultPriority,
      color: Colors.blue,

      // playSound: false,
    );

    NotificationDetails notificationDetails =
        NotificationDetails(android: platformChannelSpecifics);
    await _flutterLocalNotificationPlugin.show(0, event.notification!.title,
        event.notification!.body, notificationDetails,
        payload: event.data['type'].toString());
    // await LocalNotification().storeNotification(
    //     body: event.data['body'],
    //     title: event.data['title'],
    //     type: event.data['type']);
  }

  messageInit(GlobalKey<NavigatorState> navigatorKey) async {
    // await FirebaseMessaging.instance.subscribeToTopic("all");
    // await FirebaseMessaging.instance.unsubscribeFromTopic("unsubscribe");
    initlizeLocalNotification(navigatorKey);

    // NotificationService.initializePushNotitfication();
    requestPermission();

    await FirebaseMessaging.instance.getInitialMessage().then((event) async {
      if (event != null) {
        await NotificationService.showNotification(event);
        // _handleNotificationTap(event.data['type'], context);
        debugPrint(event.toString());
      }
    });

    FirebaseMessaging.onMessage.listen((event) async {
      await NotificationService.showNotification(event);

      // _handleNotificationTap(event.data['type'], context);
      debugPrint(event.notification!.title);
      debugPrint("onMeess");
    });

    FirebaseMessaging.onMessageOpenedApp.listen((event) async {
      await NotificationService.showNotification(event);
      // _handleNotificationTap(event.data['type'], context);
      debugPrint(event.notification!.title);
      debugPrint("onMeessageApp");
    });
  }
  static void testFirebaseNotification() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint("🔔 New FCM Message Received!");
      debugPrint("Title: ${message.notification?.title}");
      debugPrint("Body: ${message.notification?.body}");
      debugPrint("Data: ${message.data}");
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint("🔔 Notification Clicked!");
      debugPrint("Title: ${message.notification?.title}");
      debugPrint("Body: ${message.notification?.body}");
      debugPrint("Data: ${message.data}");
    });

    debugPrint("📡 Listening for Firebase messages...");
  }

  _handleNotificationTap(String payloadd, BuildContext context) {
    // if (payloadd == 'chat') {
    //   // Navigator.push(context, route);

    // } else if (payloadd == 'connection') {

    // } else {
    //   debugPrint("No Route Added");
    // }
  }

  static requestPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await messaging.requestPermission();
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint("User granted permissition");
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      debugPrint("User granted provisional permissition");
    } else {
      debugPrint("User denied permissition");
    }
  }

//SET DEVICE TOKEN
  static getDeviceToken() async {
    await FirebaseMessaging.instance.getToken().then((value) {
      print("device token");
      print(value);
    });
  }
}
