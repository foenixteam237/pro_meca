import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pro_meca/core/constants/app_colors.dart';
import 'package:pro_meca/core/constants/app_styles.dart';
import 'package:pro_meca/core/utils/responsive.dart';
import 'package:pro_meca/features/settings/providers/locale_provider.dart';

import '../l10n/arb/app_localizations.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  bool _isFirstLaunch = true;
  bool _isLoading = false;
  late final LocaleProvider _localeProvider;

  @override
  void initState() {
    super.initState();
    _localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    _checkFirstLaunch().then((_) {
      if (!_isFirstLaunch) {
        // Si ce n'est pas le premier démarrage, attendre un instant puis naviguer
        Future.delayed(const Duration(milliseconds: 1500), _navigateToHome);
      }
    });
  }

  Future<void> _checkFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isFirstLaunch = prefs.getBool('first_launch') ?? true;
    });
  }

  Future<void> _setFirstLaunchDone() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('first_launch', false);
    if (mounted) {
      setState(() => _isFirstLaunch = false);
    }
  }

  void _navigateToHome() {
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/technician-home');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: Stack(
        children: [
          // Language selector (top-right)
          Positioned(top: 40, right: 20, child: _buildLanguageSwitcher()),

          // Main content column
          SafeArea(
            child: Column(
              children: [
                // Logo en haut centré
                Padding(
                  padding: const EdgeInsets.only(top: 40),
                  child: Image.asset(
                    'assets/images/promeca_logo.png',
                    width: Responsive.responsiveValue(
                      context,
                      mobile: MediaQuery.of(context).size.width * 0.4,
                      tablet: MediaQuery.of(context).size.width * 0.3,
                    ),
                    fit: BoxFit.contain,
                  ),
                ),

                // Espace flexible pour pousser le contenu vers le bas
                const Spacer(),

                // Image principale au centre
                Center(
                  child: Image.asset(
                    'assets/images/welcome_image.png',
                    width: Responsive.responsiveValue(
                      context,
                      mobile: MediaQuery.of(context).size.width * 0.8,
                      tablet: MediaQuery.of(context).size.width * 0.6,
                    ),
                    fit: BoxFit.contain,
                  ),
                ),

                // Espace flexible pour pousser le bouton vers le bas
                const Spacer(),

                // Bouton Start ou indicateur de chargement en bas
                Padding(
                  padding: EdgeInsets.only(
                    bottom: Responsive.isMobile(context) ? 40 : 60,
                  ),
                  child: _isFirstLaunch
                      ? _buildStartButton(l10n)
                      : _buildProgressIndicator(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStartButton(AppLocalizations l10n) {
    return SizedBox(
      width: Responsive.responsiveValue(
        context,
        mobile: MediaQuery.of(context).size.width * 0.6,
        tablet: MediaQuery.of(context).size.width * 0.4,
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          padding: EdgeInsets.symmetric(
            vertical: Responsive.isMobile(context) ? 16 : 24,
            horizontal: 24,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        onPressed: () {
          _setFirstLaunchDone();
          setState(() => _isLoading = true);
          _navigateToHome();
        },
        child: Text(
          l10n.appStart,
          style: AppStyles.buttonText(context).copyWith(
            fontSize: Responsive.responsiveValue(
              context,
              mobile: 18,
              tablet: 22,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return CircularProgressIndicator(
      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
      strokeWidth: 3,
    );
  }

  Widget _buildLanguageSwitcher() {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.language, color: AppColors.primary),
      onSelected: (code) => _localeProvider.setLocale(Locale(code)),
      itemBuilder: (context) => [
        PopupMenuItem(value: 'fr', child: Text('Français 🇫🇷')),
        PopupMenuItem(value: 'en', child: Text('English 🇬🇧')),
      ],
    );
  }
}
