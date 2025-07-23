import 'package:flutter/material.dart';
import 'package:pro_meca/features/settings/services/api_services.dart';
import 'package:pro_meca/features/settings/services/networkService.dart';
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
  bool _isConnected = false;
  String _connectionMessage = "";
  final ApiService _apiService = ApiService();

  late final LocaleProvider _localeProvider;

  @override
  void initState() {
    super.initState();
    _localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    _checkFirstLaunch().then((_) {
      if (!_isFirstLaunch) {
        _testConnection();
        // Si ce n'est pas le premier démarrage, attendre un instant puis naviguer
        // Future.delayed(const Duration(milliseconds: 1500), _navigateToHome);
      }
    });
  }

  Future<void> _testConnection() async {

    final pref =  await SharedPreferences.getInstance();

    bool isCheck = pref.getBool('remember_me') ?? false;
    String? accessToken =  pref.getString("accessToken");

    print("Test de connexion en cours et verification ischek $isCheck");
    // Vérification simple
    bool isConnected = await NetworkService.hasInternetAccess();

    // Écoute des changements

    if (mounted) {
      setState(() {
        _isLoading = true;
        _connectionMessage = '';
      });
    }
    // Si pas de connexion, afficher un message et ne pas continuer
    if (!isConnected) {
      setState(() {
        _isConnected = false;
        _connectionMessage = AppLocalizations.of(context).noInternetConnection;
        _isLoading = false;
      });
      return;
    } else {
      setState(() {
        _isConnected = true;
        _connectionMessage = AppLocalizations.of(context).connexionOk;
        Future.delayed(const Duration(seconds: 5));
      });
    }

    try {
      final isConnected = await _apiService.testConnection();

      if (mounted) {
        setState(() {
          _isConnected = isConnected;
          _connectionMessage = isConnected
              ? AppLocalizations.of(context).connectionSuccess
              : AppLocalizations.of(context).connectionFailed;
        });
      }

      // Si connecté, naviguer après un délai
      if (isConnected) {
        await Future.delayed(const Duration(seconds: 3));
        if(isCheck){
          //Si l'utilisateur a choisi se souvenir de moi au préalabe
          if(accessToken != null){
            //Tester la validité du token
            _navigateToTechHome();
          }
        }
        _navigateToHome();
      } else {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isConnected = false;
          _connectionMessage = AppLocalizations.of(context).connectionError;
          _isLoading = false;
        });
      }
    }
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
    Navigator.pushReplacementNamed(context, '/login');
  }

  void _navigateToTechHome() {
    //if(!mounted) return;
    Navigator.pushReplacementNamed(context, '/technician_home');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: Stack(
        children: [
          // Language selector (top-right)
          /// Positioned(top: 40, right: 20, child: _buildLanguageSwitcher()), decommenter pour avoir le bouton de switch de langue

          // Main content column
          SafeArea(
            child: Column(
              children: [
                // Logo en haut centré
                Padding(
                  padding: const EdgeInsets.only(top: 20),
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
        onPressed: () async {
          _setFirstLaunchDone();
          setState(() => _isLoading = true);
          await _testConnection();
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_connectionMessage.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              _connectionMessage,
              style: AppStyles.titleMedium(
                context,
              ).copyWith(color: _isConnected ? Colors.green : Colors.red),
            ),
          ),
        CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          strokeWidth: 3,
        ),
      ],
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
