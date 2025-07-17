import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pro_meca/core/constants/app_colors.dart';
import 'package:pro_meca/core/constants/app_styles.dart';
import 'package:pro_meca/core/utils/responsive.dart';
import 'package:pro_meca/features/settings/providers/locale_provider.dart';

import '../l10n/app_localizations.dart';

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
    _checkFirstLaunch();
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
    setState(() => _isLoading = true);
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: Stack(
        children: [
          // Background
          Positioned.fill(
            child: Image.asset(
              'assets/images/promeca_logo.png',
              fit: BoxFit.cover,
            ),
          ),

          // Language selector (top-right)
          Positioned(top: 40, right: 20, child: _buildLanguageSwitcher()),

          // Main content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Image.asset(
                  'assets/images/promeca_logo.png',
                  width: Responsive.responsiveValue(
                    context,
                    mobile: MediaQuery.of(context).size.width * 0.6,
                    tablet: MediaQuery.of(context).size.width * 0.4,
                  ),
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 40),

                // Start button or loader
                if (_isFirstLaunch && !_isLoading)
                  _buildStartButton(l10n)
                else
                  _buildProgressIndicator(),
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
          _navigateToHome();
        },
        child: Text(
          l10n.appStart, // Utilisation directe de la traduction générée
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
