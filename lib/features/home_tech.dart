import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_styles.dart';
import '../core/utils/localization.dart';
import '../core/utils/responsive.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  bool _isFirstLaunch = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
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
    setState(() => _isFirstLaunch = false);
  }

  void _navigateToHome() {
    setState(() => _isLoading = true);
    Future.delayed(const Duration(milliseconds: 500), () {
      Navigator.pushReplacementNamed(context, '/home');
    });
  }

  @override
  Widget build(BuildContext context) {
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

          // Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Image.asset(
                  'assets/images/promeca_logo.png',
                  width: MediaQuery.of(context).size.width * 0.6,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 40),

                // Bouton Start ou Loading
                if (_isFirstLaunch && !_isLoading)
                  _buildStartButton(context)
                else
                  _buildProgressIndicator(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStartButton(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.6,
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
          AppLocalizations.of(context).translate('start'),
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
}