import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
class AppLocalizations {
  final Locale locale;
  AppLocalizations(this.locale);
  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();
  static AppLocalizations of(BuildContext context) {
    final instance = Localizations.of<AppLocalizations>(context, AppLocalizations);
    if (instance == null) {
      // Mode dégradé avec logs détaillés
      debugPrint('''
      ERREUR: AppLocalizations non trouvé. Vérifiez que :
      1. Vous avez bien ajouté AppLocalizations.delegate dans MaterialApp
      2. Le contexte provient d'un widget sous MaterialApp
      3. Les fichiers de traduction existent dans assets/translations/
      ''');
      // Retourne une instance vide plutôt que de crasher
      return AppLocalizations(const Locale('fr'));
    }
    return instance;
  }
  Map<String, String>? _localizedStrings;
  Future<bool> load() async {
    try {
      final jsonString = await rootBundle.loadString(
        'assets/translations/${locale.languageCode}.json',
      );
      final jsonMap = json.decode(jsonString) as Map<String, dynamic>;
      _localizedStrings = jsonMap.map((key, value) => MapEntry(key, value.toString()));
      return true;
    } catch (e) {
      debugPrint('Erreur de chargement des traductions: $e');
      return false;
    }
  }
  String translate(String key) {
    assert(_localizedStrings != null, 'Traductions non chargées');
    return _localizedStrings![key] ?? '[Traduction manquante: $key]';
  }
}
class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();
  @override
  bool isSupported(Locale locale) => ['fr', 'en'].contains(locale.languageCode);
  @override
  Future<AppLocalizations> load(Locale locale) async {
    final localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }
  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}