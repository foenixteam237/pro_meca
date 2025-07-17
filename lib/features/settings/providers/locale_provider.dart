import 'package:flutter/material.dart';
import 'package:pro_meca/core/utils/app_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider with ChangeNotifier {
  Locale? _locale;
  static const String _prefsKey = 'selected_locale';

  /// Get current locale (fallback to French if not set)
  Locale get locale => _locale ?? const Locale('fr');

  /// Initialize provider from saved preferences
  Future<void> loadLocalePrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLocale = prefs.getString(_prefsKey);

    if (savedLocale != null) {
      // Cas 1: Utiliser la langue sauvegardée
      _locale = Locale(savedLocale);
    } else {
      // Cas 2: Détecter la langue du téléphone
      final deviceLocale = WidgetsBinding.instance.window.locales.first;
      _locale = _getSupportedLocale(deviceLocale);
    }
    notifyListeners();
  }

  /// Change app language
  Future<void> setLocale(Locale newLocale) async {
    if (!_isSupported(newLocale)) return;

    _locale = newLocale;
    notifyListeners();

    // Sauvegarder la préférence
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, newLocale.languageCode);
  }

  /// Reset to device language
  Future<void> resetToSystemLocale() async {
    final deviceLocale = WidgetsBinding.instance.window.locales.first;
    _locale = _getSupportedLocale(deviceLocale);
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsKey);
  }

  // ============ HELPERS ============

  /// Vérifie si la locale est supportée
  bool _isSupported(Locale locale) {
    return const ['fr', 'en'].contains(locale.languageCode);
  }

  /// Trouve la meilleure locale supportée
  Locale _getSupportedLocale(Locale deviceLocale) {
    // 1. Vérifie la langue exacte (fr_FR → fr)
    if (_isSupported(deviceLocale)) return deviceLocale;

    // 2. Vérifie juste le code langue (es → fr)
    if (const ['fr', 'en'].contains(deviceLocale.languageCode)) {
      return Locale(deviceLocale.languageCode);
    }

    // 3. Fallback vers français
    return const Locale('fr');
  }

  // ============ STATIC UTILS ============

  /// Liste des locales supportées (pour MaterialApp)
  static const List<Locale> supportedLocales = [
    Locale('fr'), // Français
    Locale('en'), // Anglais
  ];

  /// Callback pour MaterialApp
  static Locale localeResolutionCallback(
    Locale? deviceLocale,
    Iterable<Locale> supportedLocales,
  ) {
    // Priorité 1: Locale sauvegardée
    final provider = _getProvider(deviceLocale?.toString());
    if (provider._locale != null) return provider._locale!;

    // Priorité 2: Langue du téléphone
    if (deviceLocale != null && provider._isSupported(deviceLocale)) {
      return deviceLocale;
    }

    // Priorité 3: Premier choix supporté
    for (final locale in supportedLocales) {
      if (provider._isSupported(locale)) return locale;
    }

    // Fallback final
    return const Locale('fr');
  }

  // Permet d'accéder au provider depuis les callbacks statiques
  static LocaleProvider _getProvider([String? debugLocale]) {
    try {
      return Provider.of<LocaleProvider>(
        AppRouter.navigatorKey.currentContext!,
        listen: false,
      );
    } catch (e) {
      debugPrint('Impossible d\'accéder au LocaleProvider: $e');
      debugPrint('Locale debug: $debugLocale');
      return LocaleProvider(); // Fallback pour les tests
    }
  }
}
