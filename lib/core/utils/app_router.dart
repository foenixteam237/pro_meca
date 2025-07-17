import 'package:flutter/material.dart';
import 'package:pro_meca/features/auth/screens/login_screen.dart';
import 'package:pro_meca/features/home_tech.dart';

class AppRouter {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey();

  // Noms de routes
  static const String login = '/login';
  static const String welcome = '/welcome';

  // Générateur de routes
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return _fadeRoute(const LoginScreen(), settings);
      case welcome:
        return _fadeRoute(const WelcomeScreen(), settings);
      default:
        return _fadeRoute(
          Scaffold(
            body: Center(child: Text('Page ${settings.name} introuvable')),
          ),
          settings,
        );
    }
  }

  // Transition personnalisée
  static PageRouteBuilder _fadeRoute(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) {
        return FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
          child: child,
        );
      },
    );
  }
}
