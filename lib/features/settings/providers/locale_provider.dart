// features/settings/providers/locale_provider.dart
import 'dart:ui';
import 'package:flutter/material.dart';

class LocaleProvider with ChangeNotifier {
  Locale? _locale;

  Locale get locale => _locale ?? _getFallbackLocale();

  Future<void> init() async {
    final deviceLocale = await _getDeviceLocale();
    if (['fr', 'en'].contains(deviceLocale.languageCode)) {
      _locale = deviceLocale;
    } else {
      _locale = _getFallbackLocale();
    }
    notifyListeners();
  }

  Future<Locale> _getDeviceLocale() async {
    try {
      final String localeCode = (PlatformDispatcher.instance.locales.first).languageCode;
      return Locale(localeCode);
    } catch (e) {
      return _getFallbackLocale();
    }
  }

  Locale _getFallbackLocale() => const Locale('fr'); // Français par défaut si non supporté

  void setLocale(Locale locale) {
    if (!['fr', 'en'].contains(locale.languageCode)) return;
    _locale = locale;
    notifyListeners();
  }
}