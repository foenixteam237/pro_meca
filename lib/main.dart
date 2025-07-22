import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:pro_meca/core/utils/app_router.dart';
import 'package:pro_meca/l10n/arb/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:pro_meca/core/constants/app_themes.dart';
import 'package:pro_meca/features/settings/providers/theme_provider.dart';
import 'package:pro_meca/features/settings/providers/locale_provider.dart';

void main() async {
  // Initialisation obligatoire pour les packages
  WidgetsFlutterBinding.ensureInitialized();

  // Initialisation des providers
  final themeProvider = ThemeProvider();
  final localeProvider = LocaleProvider();

  // Chargement des préférences
  await Future.wait([
    themeProvider.loadThemePrefs(),
    localeProvider.loadLocalePrefs(),
  ]);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: themeProvider),
        ChangeNotifierProvider.value(value: localeProvider),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, LocaleProvider>(
      builder: (context, themeProvider, localeProvider, child) {
        return MaterialApp(
          // ============ CONFIGURATION DES LANGUES ============
          title: 'ProMéca',
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          locale: localeProvider.locale,
          localeResolutionCallback: (deviceLocale, supportedLocales) {
            // Fallback vers français si langue non supportée
            for (final locale in supportedLocales) {
              if (locale.languageCode == deviceLocale?.languageCode) {
                //return deviceLocale; à decommenter afin de permettre la gestion des langues dans l'application
                return const Locale('fr');
              }
            }
            return const Locale('fr');
          },

          // ============ CONFIGURATION DES THEMES ============
          theme: AppThemes.lightTheme,
          darkTheme: AppThemes.darkTheme,
          themeMode: themeProvider.themeMode,

          // ============ GESTION DES ROUTES ============
          initialRoute: AppRouter.welcome,
          onGenerateRoute: AppRouter.generateRoute,
          navigatorKey: AppRouter.navigatorKey,

          // ============ OPTIMISATIONS ============
          debugShowCheckedModeBanner: false,
          builder: (context, child) {
            // Désactive le redimensionnement texte système
            return MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: TextScaler.linear(1.0)),
              child: child!,
            );
          },
        );
      },
    );
  }
}
