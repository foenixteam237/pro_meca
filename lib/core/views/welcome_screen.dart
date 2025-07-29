import 'package:flutter/material.dart';
import 'package:pro_meca/features/settings/services/dio_api_services.dart';
import 'package:pro_meca/features/settings/services/networkService.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pro_meca/core/constants/app_colors.dart';
import 'package:pro_meca/core/constants/app_styles.dart';
import 'package:pro_meca/core/utils/responsive.dart';
import 'package:pro_meca/features/settings/providers/locale_provider.dart';

import '../../l10n/arb/app_localizations.dart';

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
  final ApiDioService _apiService = ApiDioService();
  late final LocaleProvider _localeProvider;

  late final SharedPreferences _prefs;
  bool _isCheck = false;
  String? _accessToken;
  int _expireAt = 0;
  @override
  void initState() {
    super.initState();
    _localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    _initializePreferences();
  }

  Future<void> _initializePreferences() async {
    _prefs = await SharedPreferences.getInstance();
    _isFirstLaunch = _prefs.getBool('first_launch') ?? true;
    _isCheck = _prefs.getBool('remember_me') ?? false;
    _accessToken = _prefs.getString("accessToken");
    _expireAt = _prefs.getInt("expiresAt") ?? 0;
    if (!_isFirstLaunch) {
      await _testConnection();
    }
    setState(() {});
  }

  Future<void> _testConnection() async {
    setState(() {
      _isLoading = true;
      _connectionMessage = '';
    });
    bool isConnected = await NetworkService.hasInternetAccess();
    if (!isConnected) {
      setState(() {
        _isConnected = false;
        _connectionMessage = AppLocalizations.of(context).noInternetConnection;
        _isLoading = false;
      });
      return;
    }
    // Test de la connexion à l'API
    try {
      final isConnected = await _apiService.testConnection();
      setState(() {
        _isConnected = isConnected;
        _connectionMessage = isConnected
            ? AppLocalizations.of(context).connectionSuccess
            : AppLocalizations.of(context).connectionFailed;
      });
      if (isConnected) {
        await Future.delayed(const Duration(seconds: 3));
        _navigateToNextScreen();
      }
    } catch (e) {
      setState(() {
        _isConnected = false;
        _connectionMessage = AppLocalizations.of(context).connectionError;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _navigateToNextScreen() {
    if (_isCheck &&
        _accessToken != null &&
        _expireAt > DateTime.now().millisecondsSinceEpoch ~/ 1000) {
      print("Connecté avec un token valide");
      _navigateToTechHome();
    } else {
      //Faire une demande de token avec le refresh token
      print("Pas de token valide ou session expirée ");
      _navigateToHome();
    }
  }

  void _navigateToHome() {
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }

  void _navigateToTechHome() {
    Navigator.pushReplacementNamed(context, '/technician_home');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Image.asset(
                    'assets/images/promeca_logo.png',
                    width: Responsive.responsiveValue(
                      context,
                      mobile: MediaQuery.of(context).size.width * 0.3,
                      tablet: MediaQuery.of(context).size.width * 0.04,
                    ),
                    fit: BoxFit.contain,
                  ),
                ),
                const Spacer(),
                Center(
                  child: Image.asset(
                    'assets/images/welcome_image.png',
                    width: Responsive.responsiveValue(
                      context,
                      mobile: MediaQuery.of(context).size.width * 0.6,
                      tablet: MediaQuery.of(context).size.width * 0.8,
                    ),
                    fit: BoxFit.contain,
                  ),
                ),
                const Spacer(),
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
          await _setFirstLaunchDone();
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

  Future<void> _setFirstLaunchDone() async {
    await _prefs.setBool('first_launch', false);
    setState(() => _isFirstLaunch = false);
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
