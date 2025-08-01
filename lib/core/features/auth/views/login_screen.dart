import 'package:flutter/material.dart';
import 'package:pro_meca/core/constants/app_adaptive_colors.dart';
import 'package:pro_meca/core/features/auth/services/auth_services.dart';
import 'package:pro_meca/core/models/user.dart';
import 'package:pro_meca/core/utils/responsive.dart';
import 'package:pro_meca/services/dio_api_services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pro_meca/core/constants/app_colors.dart';
import 'package:pro_meca/core/constants/app_styles.dart';
import 'package:pro_meca/core/providers/locale_provider.dart';
import '../../../../l10n/arb/app_localizations.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isChecked = false;
  bool _obscurePassword =
      true; // Variable pour gérer la visibilité du mot de passe
  bool _isLoading = false; // Variable pour gérer l'état de chargement
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  @override
  void initState() {
    super.initState();
    _loadCheckboxState();
    if (_isChecked) {
      User? user = ApiDioService().getSavedUser() as User?;
      if (user != null) {
        Navigator.pushReplacementNamed(context, '/technician_home');
      }
    }
  }

  _loadCheckboxState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isChecked = prefs.getBool('remember_me') ?? false;
    });
  }

  _updateCheckboxState(bool? value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isChecked = value ?? false;
    });
    await prefs.setBool('remember_me', _isChecked);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final int height = MediaQuery.of(context).size.height.toInt();
    final int width = MediaQuery.of(context).size.width.toInt();
    final bool isMobile = Responsive.isMobile(context);
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // Contenu principal avec SingleChildScrollView pour le scroll
          Padding(
            padding: EdgeInsets.all(isMobile ? width * 0.03 : height * 0.05),
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight:
                      MediaQuery.of(context).size.height -
                      MediaQuery.of(context).padding.top,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      // Logo en haut
                      Padding(
                        padding: EdgeInsets.only(
                          top: isMobile ? height * 0.001 : 40.0,
                        ),
                        child: Image.asset(
                          'assets/images/promeca_logo.png',
                          height: isMobile ? height * 0.3 : height * 0.15,
                          fit: BoxFit.fill,
                        ),
                      ),
                      // Titre "Bienvenue !"
                      Text(
                        l10n.appWelcome,
                        style: AppStyles.headline2(context).copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      SizedBox(height: isMobile ? height * 0.04 : 40),
                      // Champ matricule employé
                      TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: l10n.authPhoneNumber,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          filled: true,
                        ),
                      ),
                      SizedBox(height: isMobile ? height * 0.02 : 40),
                      // Champ mot de passe avec suffixIcon
                      TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: l10n.authPassword,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          filled: true,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Case à cocher "Se souvenir de moi"
                      Row(
                        children: [
                          Checkbox(
                            value: _isChecked,
                            onChanged: _updateCheckboxState,
                            fillColor: WidgetStateProperty.resolveWith<Color>((
                              Set<WidgetState> states,
                            ) {
                              return AppColors.primary;
                            }),
                          ),
                          Text(
                            l10n.authRememberMe,
                            style: isMobile
                                ? AppStyles.bodyMedium(context)
                                : null,
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: () {},
                            child: Text(
                              l10n.authForgotPassword,
                              style: AppStyles.bodySmall(
                                context,
                              ).copyWith(color: AppColors.primary),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: isMobile ? height * 0.03 : 40),
                      // Bouton de connexion
                      SizedBox(
                        width: isMobile ? width * 0.4 : double.infinity,
                        height: isMobile ? height * 0.07 : 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: _isLoading
                              ? null
                              : () async {
                                  setState(() {
                                    _isLoading = true; // Démarre le chargement
                                  });
                                  String phoneNumber = _phoneController.text;
                                  String password = _passwordController.text;
                                  try {
                                    Map<String, dynamic> response =
                                        await AuthServices().authenticateUser(
                                          identifier: phoneNumber,
                                          password: password,
                                          mail: phoneNumber,
                                          rememberMe: _isChecked,
                                        );
                                    User user = User.fromJson(
                                      response['data']['user'],
                                    );
                                    print(user.role.name);
                                    if (user.isCompanyAdmin) {
                                      final appColors = Provider.of<AppAdaptiveColors>(context, listen: false);
                                      appColors.updateColorsForRole(user.isCompanyAdmin); // role: 'admin', 'reception', etc.

                                      Navigator.pushReplacementNamed(
                                        context,
                                        '/admin_home',
                                        arguments: user,
                                      );
                                    } else if (user.role.name == "technicien" ||
                                        user.role.name == "receptionniste") {
                                      Navigator.pushReplacementNamed(
                                        context,
                                        '/technician_home',
                                        arguments: user,
                                      );
                                    }
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(l10n.authLoginFailed),
                                      ),
                                    );
                                  } finally {
                                    setState(() {
                                      _isLoading =
                                          false; // Arrête le chargement
                                    });
                                  }
                                },
                          child: _isLoading
                              ? SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: AppColors.background,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  l10n.authLogin,
                                  style: AppStyles.bodyLarge(context).copyWith(
                                    color: AppColors.background,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: Text(
                          l10n.authLoginMessage,
                          style: AppStyles.bodySmall(
                            context,
                          ).copyWith(color: AppColors.primary),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Sélecteur de langue en haut à droite à implementer uniquement dans les prochaines versions
          /**
        Positioned(
        top: 40,
        right: 20,
        child: _buildLanguageSwitcher(context, localeProvider),
        ),
        */
        ],
      ),
    );
  }

  Widget _buildLanguageSwitcher(BuildContext context, LocaleProvider provider) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: PopupMenuButton<String>(
        icon: Icon(Icons.language, color: AppColors.primary),
        onSelected: (code) => provider.setLocale(Locale(code)),
        itemBuilder: (context) => [
          PopupMenuItem(value: 'fr', child: Text('Français 🇫🇷')),
          PopupMenuItem(value: 'en', child: Text('English 🇬🇧')),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
