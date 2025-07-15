// features/settings/providers/theme_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  // Valeur par défaut : système
  ThemeMode _themeMode = ThemeMode.system;

  // Clé pour le stockage local
  static const String _prefsKey = 'theme_mode';

  ThemeMode get themeMode => _themeMode;

  // Charger les préférences depuis le stockage local
  Future<void> loadThemePrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTheme = prefs.getString(_prefsKey);

    if (savedTheme != null) {
      _themeMode = ThemeMode.values.firstWhere(
        (e) => e.toString() == savedTheme,
        orElse: () => ThemeMode.system,
      );
      notifyListeners();
    }
  }

  // Changer le thème et sauvegarder la préférence
  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, mode.toString());
  }

  // Méthode utilitaire pour le texte affiché
  String getThemeName() {
    switch (_themeMode) {
      case ThemeMode.system:
        return 'Système';
      case ThemeMode.light:
        return 'Clair';
      case ThemeMode.dark:
        return 'Sombre';
    }
  }

  // Méthode pour basculer entre les thèmes
  Future<void> toggleTheme() async {
    if (_themeMode == ThemeMode.dark) {
      await setThemeMode(ThemeMode.light);
    } else {
      await setThemeMode(ThemeMode.dark);
    }
  }
}
