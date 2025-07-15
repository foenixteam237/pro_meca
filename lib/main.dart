import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pro_meca/core/utils/localization.dart';
import 'package:pro_meca/features/home_tech.dart';
import 'package:provider/provider.dart';

// Importez vos fichiers ici (dans le bon ordre selon votre structure)
import 'core/constants/app_themes.dart';
import 'features/settings/providers/locale_provider.dart';
import 'features/settings/providers/theme_provider.dart';
import 'features/auth/screens/login_screen.dart';

void main() async {
  // Assurez-vous que les bindings Flutter sont initialisés
  WidgetsFlutterBinding.ensureInitialized();

  // Initialisez GoogleFonts
  GoogleFonts.config.allowRuntimeFetching = true;
  // Initialiser le Provider
  final themeProvider = ThemeProvider();
  await themeProvider.loadThemePrefs(); // Charger les préférences
  final localeProvider = LocaleProvider();
  await localeProvider.init(); // Charge la locale avant le runApp
  runApp(
    // MultiProvider pour gérer plusieurs états
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final localeProvider = Provider.of<LocaleProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: AppLocalizations.of(context).translate('app.title'),

      // Thèmes
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      themeMode: themeProvider.themeMode,

      // Localisation
      locale: localeProvider.locale,
      supportedLocales: [
        const Locale('fr', 'FR'), // Français
        const Locale('en', 'US'), // Anglais
      ],
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      localeResolutionCallback: (locale, supportedLocales) {
        for (var supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == locale?.languageCode) {
            return supportedLocale;
          }
        }
        return supportedLocales.first;
      },

      // Routage
      home: const WelcomeScreen(),

      // Configuration générale
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(
              1.0,
            ), // Empêche le redimensionnement du texte par le système
          ),
          child: child!,
        );
      },
    );
  }
}

// Widget d'initialisation pour charger les ressources
class AppInitialization extends StatelessWidget {
  const AppInitialization({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Future.wait([
        // Ajoutez ici vos futures d'initialisation si nécessaire
        // Par exemple : Préchargement des polices, initialisation de Firebase, etc.
      ]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return const WelcomeScreen();
        } else {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
      },
    );
  }
}
