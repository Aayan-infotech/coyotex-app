import 'package:coyotex/core/utills/constant.dart';
import 'package:coyotex/core/utills/notification.dart';
import 'package:coyotex/feature/auth/data/purchase_provider.dart';
import 'package:coyotex/feature/auth/data/view_model/user_view_model.dart';
import 'package:coyotex/feature/auth/screens/splash_screen.dart';
import 'package:coyotex/feature/homeScreen/screens/index_provider.dart';
import 'package:coyotex/feature/map/view_model/classes/location_provider.dart';
import 'package:coyotex/feature/map/view_model/classes/route_provider.dart';
import 'package:coyotex/feature/map/view_model/map_provider.dart';
import 'package:coyotex/feature/trip/view_model/trip_view_model.dart';
import 'package:coyotex/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

Future<void> _firebaseMessginBackgroundHandler(RemoteMessage event) async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await NotificationService.showNotification(event);
  debugPrint("background-------");
}

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );
//   Stripe.publishableKey = publishableKey;

//   final RemoteMessage? message =
//       await FirebaseMessaging.instance.getInitialMessage();
//   FirebaseMessaging.onBackgroundMessage(_firebaseMessginBackgroundHandler);

//   runApp(MyApp(
//     message: message,
//   ));
// }

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  Stripe.publishableKey = publishableKey;

  // Disable landscape mode
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  final RemoteMessage? message =
      await FirebaseMessaging.instance.getInitialMessage();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessginBackgroundHandler);

  runApp(
    ChangeNotifierProvider(
      create: (context) => IndexProvider(),
      child: MyApp(
        message: message,
      ),
    ),
  );
}

class MyApp extends StatefulWidget {
  RemoteMessage? message;

  MyApp({super.key, this.message});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  @override
  void initState() {
    NotificationService().messageInit(navigatorKey);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MapProvider()),
        ChangeNotifierProvider(create: (_) => UserViewModel()),
        ChangeNotifierProvider(create: (_) => TripViewModel()),
        ChangeNotifierProvider(create: (_) => LocationProvider()),
        ChangeNotifierProvider(create: (_) => RouteProvider()),
        ChangeNotifierProvider(create: (_) => IndexProvider()),
        ChangeNotifierProvider(create: (_) => PurchaseProvider())
      ],
      child: MaterialApp(
        title: 'Coyotex',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
          textTheme: GoogleFonts.montserratTextTheme(),
          fontFamily: 'Montserrat',
        ),
        home: const SplashScreen(),
      ),
    );
  }
}
