// import 'package:coyotex/utils/app_dialogue_box.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'dart:math';

// import '../../firebase_options.dart';


// class FcmService {
//   final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
//   FlutterLocalNotificationsPlugin();

//   Future<void> initService() async {
//     await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
//     FirebaseMessaging.instance.requestPermission();
//     _initializeLocalNotifications();
//     initFcmToken();
//     _initFcmListeners();
//   }

//   Future<void> initFcmToken() async {
//     var fcmToken = await FirebaseMessaging.instance.getToken();
//     // Alert.log("runtimeType", "FCM TOKEN => $fcmToken");
//     // if (fcmToken != null) Prefs().putData(Prefs.fcmToken, fcmToken);

//     FirebaseMessaging.instance.onTokenRefresh.listen((fcmToken) {
//       // Alert.log("runtimeType", "FCM REGEN TOKEN => $fcmToken");
//       // Prefs().putData(Prefs.fcmToken, fcmToken);
//     })
//   }

//   void _initializeLocalNotifications() {
//     const AndroidInitializationSettings initializationSettingsAndroid =
//     AndroidInitializationSettings('@mipmap/ic_launcher');

//     const DarwinInitializationSettings initializationSettingsIOS =
//     DarwinInitializationSettings();

//     const InitializationSettings initializationSettings = InitializationSettings(
//       android: initializationSettingsAndroid,
//       iOS: initializationSettingsIOS,
//     );

//     _flutterLocalNotificationsPlugin.initialize(
//       initializationSettings,
//       onDidReceiveNotificationResponse: _onNotificationResponse,
//     );
//   }

//   Future<void> _onNotificationResponse(NotificationResponse response) async {
//     // Handle notification tap
//     Alert.log(runtimeType.toString(),'Notification tapped with payload: ${response.payload}');
//     // Add your custom logic here based on the payload or action
//   }

//   void _initFcmListeners() {
//     FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//     //  Alert.log(runtimeType.toString(), "FCM MESSAGE RECEIVED => ${message.notification?.title}");
//       _displayNotification(message);
//     });

//     FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//      // Alert.log(runtimeType.toString(), "FCM MESSAGE TAPPED => ${message.notification?.title}");
//       // Handle any logic when the notification is tapped
//     });
//   }

//   void _displayNotification(RemoteMessage message) async {
//     try {
//     //  Alert.log(runtimeType.toString(),"In Notification method");

//       // Generate a random ID for the notification
//       Random random = Random();
//       int id = random.nextInt(1000);

//       // Android-specific notification details
//       const AndroidNotificationDetails androidPlatformChannelSpecifics =
//       AndroidNotificationDetails(
//         "mychannel",
//         "my channel",
//         importance: Importance.max,
//         priority: Priority.high,
//       );

//       // iOS-specific notification details
//       const DarwinNotificationDetails iosPlatformChannelSpecifics =
//       DarwinNotificationDetails();

//       // Combine the platform-specific details
//       const NotificationDetails platformChannelSpecifics = NotificationDetails(
//         android: androidPlatformChannelSpecifics,
//         iOS: iosPlatformChannelSpecifics,
//       );

//      // Alert.log(runtimeType.toString(),"my id is ${id.toString()}");

//       // Display the notification
//       await _flutterLocalNotificationsPlugin.show(
//         id,
//         message.notification?.title,
//         message.notification?.body,
//         platformChannelSpecifics,
//         payload: 'Item X', // Optional: Pass some data to the notification
//       );
//     } on Exception catch (e) {
//      // Alert.log(runtimeType.toString(),'Error>>>$e');
//     }
//   }
// }