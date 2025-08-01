import 'package:flutter/material.dart';
import 'package:pro_meca/core/features/auth/screens/login_screen.dart';
import 'package:pro_meca/core/features/home/AdminHome.dart';
import 'package:pro_meca/core/features/reception/views/choseBrandScreen.dart';

import '../features/home/TechnicianHome.dart';
import '../../welcome_screen.dart';

class AppRouter {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey();

  // Noms de routes
  static const String login = '/login';
  static const String welcome = '/welcome';
  static const String technicianHome = '/technician_home';
  static const String brandPicker = '/brand_picker';
  static const String modelPicker = "/model_picker";
  static const String clientVehicleForm = "/client_vehicle_form";
  static const String adminHoe = "/admin_home";

  // Générateur de routes
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return _fadeRoute(const LoginScreen(), settings);
      case welcome:
        return _fadeRoute(const WelcomeScreen(), settings);
      case technicianHome:
        return _fadeRoute(TechnicianHomeScreen(), settings);
      case adminHoe:
        return _fadeRoute(AdminHomeScreen(), settings);
      case brandPicker:
        return _fadeRoute(
          BrandPickerScreen(
            onBrandSelected: (selectedBrand) {
              // Logique pour gérer la marque sélectionnée
            },
          ),
          settings,
        );
      default:
        return _fadeRoute(
          Scaffold(
            body: Center(child: Text('Page ${settings.name} introuvables')),
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
