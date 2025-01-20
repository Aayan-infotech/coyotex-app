import 'package:coyotex/feature/auth/screens/splash_screen.dart';
import 'package:coyotex/feature/auth/screens/welcome_screen.dart';
import 'package:flutter/material.dart';

class AppRoutes {
  static const String splash = '/splash';
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String signup = '/signup';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => SplashScreen());
      case welcome:
        return MaterialPageRoute(builder: (_) => WelcomeScreen());
      // case login:
      //   return MaterialPageRoute(builder: (_) => LoginScreen());
      // case signup:
      //   return MaterialPageRoute(builder: (_) => SignupScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
