import 'package:flutter/material.dart';

class AppAdaptiveColors extends ChangeNotifier {
  late Color _primary;
  late Color _secondary;

  AppAdaptiveColors() {
    _primary = const Color.fromARGB(255, 98, 173, 101); // par défaut
    _secondary = const Color(0xFF6871D7);
  }

  Color get primary => _primary;
  Color get secondary => _secondary;

  void updateColorsForRole(bool role) {
    if (role) {
      _primary = const Color(0xFF6871D7); // Bleu pour admin
      _secondary = const Color.fromARGB(255, 98, 173, 101); // Vert secondaire
    } else {
      _primary = const Color.fromARGB(255, 98, 173, 101); // Vert
      _secondary = const Color(0xFF6871D7); // Bleu
    }
    notifyListeners();
  }

  // Autres couleurs statiques ou fixes
  static const Color alert = Color(0xFFF44336);
  static const Color red_fade = Color(0xFFFDF5F5);
  static const Color background = Color(0xFFFFFFFF);
  static const Color text = Color(0xDE000000);

  Color customBackground(BuildContext context) {
    return Theme.of(context).scaffoldBackgroundColor;
  }

  Color customText(BuildContext context) {
    return Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;
  }
}
