import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pro_meca/core/constants/app_adaptive_colors.dart';
import 'package:pro_meca/core/features/auth/services/auth_services.dart';
import 'package:pro_meca/core/models/user.dart';
import 'package:pro_meca/core/utils/responsive.dart';
import 'package:pro_meca/services/dio_api_services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pro_meca/core/constants/app_colors.dart';
import '../../../../l10n/arb/app_localizations.dart';
import 'package:country_code_picker/country_code_picker.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isChecked = false;
  bool _obscurePassword = true;
  bool _isLoading = false;
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _selectedCountryCode = '+237';
  String _selectedCountryIso = 'cm'; // Code ISO du pays
  String? _emailError;
  String? _phoneError;

  // Expressions régulières par pays
  final Map<String, RegExp> _phoneRegex = {
    'cm': RegExp(
      r'^[2367]\d{8}$',
    ), // Cameroun: 9 chiffres commençant par 2,3,6 ou 7
    'ga': RegExp(r'^\d{8}$'), // Gabon: 8 chiffres
    'td': RegExp(r'^\d{8}$'), // Tchad: 8 chiffres
    'cf': RegExp(r'^\d{8}$'), // Centrafrique: 8 chiffres
    'ng': RegExp(
      r'^[789]\d{9}$',
    ), // Nigeria: 10 chiffres commençant par 7,8 ou 9
    'gq': RegExp(r'^\d{9}$'), // Guinée équatoriale: 9 chiffres
    'co': RegExp(r'^\d{10}$'), // Congo: 10 chiffres
  };
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.index = 1;

    // Pré-remplissage pour l'environnement de développement
    if (dotenv.env["FLUTTER_ENV"] == "dev") {
      _phoneController.text = dotenv.env["TECHNICIAN_NUMBER"] ?? "";
      _emailController.text = dotenv.env["TECHNICIAN_EMAIL"] ?? "";
    }

    _loadCheckboxState();
    if (_isChecked) {
      User? user = ApiDioService().getSavedUser() as User?;
      if (user != null) {
        Navigator.pushReplacementNamed(context, '/technician_home');
      }
    }

    _tabController.addListener(_onTabIndexChanged);
  }

  void _onTabIndexChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabIndexChanged);
    _tabController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
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

  bool _validateEmail(String email) {
    final emailRegex = RegExp(
      r'^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$',
    );
    return emailRegex.hasMatch(email);
  }

  bool _validatePhone(String phone) {
    final regex = _phoneRegex[_selectedCountryIso.toLowerCase()];
    return regex != null && regex.hasMatch(phone);
  }

  bool _checkMail() {
    // Réinitialiser l'erreur
    setState(() {
      _emailError = null;
    });
    if (_emailController.text.isEmpty) {
      setState(() => _emailError = AppLocalizations.of(context).emailRequired);
      return false;
    } else if (!_validateEmail(_emailController.text)) {
      setState(
        () => _emailError = AppLocalizations.of(context).errorsInvalidEmail,
      );
      return false;
    } else {
      return true;
    }
  }

  String _checkPhone() {
    // Réinitialiser l'erreur
    setState(() {
      _phoneError = null;
    });
    final phone = _phoneController.text.replaceAll(' ', '');
    if (phone.isEmpty) {
      setState(() => _phoneError = AppLocalizations.of(context).phoneRequired);
      return '';
    } else if (!_validatePhone(phone)) {
      setState(() => _phoneError = AppLocalizations.of(context).invalidPhone);
      return '';
    }
    return phone;
  }

  Future<void> _handleLogin() async {
    String email = '';
    String identifier = '';

    if (_tabController.index == 0) {
      // Mode email
      if (_checkMail()) {
        email = _emailController.text;
      } else {
        return;
      }
    } else {
      // Mode téléphone
      final phone = _checkPhone();
      if (phone.isNotEmpty) {
        identifier = '${_selectedCountryCode}_$phone';
      } else {
        return;
      }
    }

    // Validation du mot de passe
    if (_passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).passwordRequired),
          backgroundColor: AppColors.alert,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      Map<String, dynamic> response = await AuthServices().authenticateUser(
        identifier: identifier,
        mail: email,
        password: _passwordController.text,
        rememberMe: _isChecked,
      );

      User user = User.fromJson(response['data']['user']);
      _redirectUserBasedOnRole(user);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).authLoginFailed),
          backgroundColor: AppColors.alert,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _redirectUserBasedOnRole(User user) {
    final appColors = Provider.of<AppAdaptiveColors>(context, listen: false);
    appColors.updateColorsForRole(user.isCompanyAdmin);
    if (user.isCompanyAdmin) {
      Navigator.pushReplacementNamed(context, '/admin_home', arguments: user);
    } else if (user.role.name == "technicien" ||
        user.role.name == "receptionniste") {
      Navigator.pushReplacementNamed(
        context,
        '/technician_home',
        arguments: user,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final size = MediaQuery.of(context).size;
    final bool isMobile = Responsive.isMobile(context);
    final theme = Theme.of(context);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // Arrière-plan décoratif
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.background,
                    AppColors.primary.withAlpha(10),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? size.width * 0.03 : size.width * 0.2,
              vertical: isMobile ? 10 : 40,
            ),
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: size.height - MediaQuery.of(context).padding.top,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: isMobile ? size.height * 0.001 : 40.0),

                      // Logo
                      Hero(
                        tag: 'app-logo',
                        child: Image.asset(
                          'assets/images/promeca_logo.png',
                          height: isMobile ? size.height * 0.2 : 0.15,
                          fit: BoxFit.contain,
                        ),
                      ),

                      // SizedBox(height: isMobile ? 5 : 40),

                      // Titre
                      Text(
                        l10n.appWelcome,
                        style: theme.textTheme.headlineMedium!.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      SizedBox(height: isMobile ? 0.04 : 50),

                      // Sélecteur Email/Phone
                      Column(
                        children: [
                          // Barre d'onglets
                          TabBar(
                            padding: EdgeInsets.only(left: 10, right: 10, bottom: 20),
                            controller: _tabController,
                            labelColor: AppColors.secondary,
                            unselectedLabelColor: AppColors.background,
                            indicatorSize: TabBarIndicatorSize.label,
                            indicatorColor: AppColors.secondary,
                            tabs: [
                              Tab(
                                text: l10n.authEmail,
                                icon: Icon(Icons.email),
                              ),
                              Tab(
                                text: l10n.authPhone,
                                icon: Icon(Icons.phone),
                              ),
                            ],
                          ),

                          // Contenu des onglets
                          SizedBox(
                            height: 70,
                            child: TabBarView(
                              controller: _tabController,
                              children: [
                                Column(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(
                                        top: 10.0,
                                        left: 10,
                                        right: 10,
                                      ),
                                      child: _buildEmailInput(l10n),
                                    ),
                                  ],
                                ),

                                Padding(
                                  padding: EdgeInsets.only(
                                    top: 10.0,
                                    left: 10,
                                    right: 10,
                                  ),
                                  child: _buildPhoneInput(l10n),
                                ),
                              ],
                            ),
                          ),
                          if (_emailError != null &&
                              _tabController.index == 0) ...[
                            Padding(
                              padding: EdgeInsets.only(left: 10, right: 10),
                              child: Text(
                                _emailError!,
                                style: Theme.of(context).textTheme.titleSmall
                                    ?.copyWith(color: AppColors.secondary),
                                textAlign: TextAlign.start,
                              ),
                            ),
                          ],

                          if (_tabController.index == 1) ...[
                            Column(
                              // crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "$_selectedCountryCode  ${_getPhoneFormatHint()}",
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppColors.background,
                                  ),
                                ),

                                if (_phoneError != null &&
                                    _tabController.index == 1) ...[
                                  Padding(
                                    padding: EdgeInsets.only(
                                      left: 10,
                                      right: 10,
                                    ),
                                    child: Text(
                                      _phoneError!,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall
                                          ?.copyWith(
                                            color: AppColors.alert.withOpacity(0.7),
                                          ),
                                      textAlign: TextAlign.start,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ],
                      ),

                      // Champ Mot de passe
                      Padding(
                        padding: EdgeInsets.only(top: 10, left: 10, right: 10),
                        child: TextField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: l10n.authPassword,
                            prefixIcon: Icon(Icons.lock_outline),
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
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),

                      // Options
                      Row(
                        children: [
                          Transform.scale(
                            scale: 1.3,
                            child: Checkbox(
                              value: _isChecked,
                              onChanged: _updateCheckboxState,
                              fillColor: WidgetStateProperty.resolveWith<Color>(
                                (states) => AppColors.primary,
                              ),
                            ),
                          ),
                          Text(
                            l10n.authRememberMe,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),

                      SizedBox(height: 15),

                      // Bouton de connexion
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: isMobile
                              ? size.width * 0.2
                              : size.width * 0.4,
                        ),
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 5,
                          ),
                          child: _isLoading
                              ? SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  l10n.authLogin,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                      SizedBox(height: 25),
                      TextButton(
                        onPressed: () {},
                        child: Text(
                          l10n.authForgotPassword,
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),

                      Spacer(),

                      // Message d'information
                      Padding(
                        padding: EdgeInsets.only(bottom: 20),
                        child: Text(
                          l10n.authLoginMessage,
                          style: Theme.of(context).textTheme.titleMedium,
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

  Widget _buildEmailInput(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: l10n.authEmail,
            prefixIcon: Icon(Icons.email_outlined),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            filled: true,
          ),
          onChanged: (value) {
            if (_emailError != null) {
              setState(() => _emailError = null);
            }
          },
        ),
      ],
    );
  }

  Widget _buildPhoneInput(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey),
              ),
              child: CountryCodePicker(
                countryFilter: const ['CM', 'GA', 'TD', 'CE', 'NG', 'GQ', 'CG'],
                initialSelection: 'CM',
                favorite: ['CM', 'TD', 'CE'],
                showCountryOnly: false,
                showOnlyCountryWhenClosed: false,
                alignLeft: false,
                searchDecoration: InputDecoration(
                  hintText: l10n.searchCountry,
                  border: OutlineInputBorder(),
                ),
                headerText: l10n.selectCountry,
                textStyle: TextStyle(fontSize: 14, color: AppColors.text),
                flagWidth: 20,
                padding: EdgeInsets.zero,
                onChanged: (country) {
                  setState(() {
                    _selectedCountryCode = country.dialCode!;
                    _selectedCountryIso = country.code!.toLowerCase();
                    if (_phoneError != null) {
                      _phoneError = null;
                    }
                  });
                },
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                ],
                decoration: InputDecoration(
                  labelText: l10n.authPhoneNumber,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                ),
                onChanged: (value) {
                  if (_phoneError != null) {
                    setState(() => _phoneError = null);
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _getPhoneFormatHint() {
    // 'CM', 'GA', 'TD', 'CE', 'NG', 'GQ', 'CG'
    switch (_selectedCountryIso.toLowerCase()) {
      case 'cm':
        return AppLocalizations.of(context).phoneFormatCM;
      case 'ga':
        return AppLocalizations.of(context).phoneFormatGA;
      case 'td':
        return AppLocalizations.of(context).phoneFormatTD;
      case 'ce':
        return AppLocalizations.of(context).phoneFormatCF;
      case 'ng':
        return AppLocalizations.of(context).phoneFormatNG;
      case 'gq':
        return AppLocalizations.of(context).phoneFormatGQ;
      case 'cg':
        return AppLocalizations.of(context).phoneFormatCO;
      default:
        return AppLocalizations.of(context).phoneFormatDefault;
    }
  }

  // Widget _buildLanguageSwitcher(BuildContext context, LocaleProvider provider) {
  //   return Padding(
  //     padding: const EdgeInsets.only(top: 8.0),
  //     child: PopupMenuButton<String>(
  //       icon: Icon(Icons.language, color: AppColors.primary),
  //       onSelected: (code) => provider.setLocale(Locale(code)),
  //       itemBuilder: (context) => [
  //         PopupMenuItem(value: 'fr', child: Text('Français 🇫🇷')),
  //         PopupMenuItem(value: 'en', child: Text('English 🇬🇧')),
  //       ],
  //     ),
  //   );
  // }
}
