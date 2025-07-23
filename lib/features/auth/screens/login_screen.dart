import 'package:flutter/material.dart';
import 'package:pro_meca/core/models/user.dart';
import 'package:pro_meca/features/settings/services/api_services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pro_meca/core/constants/app_colors.dart';
import 'package:pro_meca/core/constants/app_styles.dart';
import 'package:pro_meca/features/settings/providers/locale_provider.dart';
import '../../../l10n/arb/app_localizations.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isChecked = false;
  bool _obscurePassword =
      true; // Variable pour gérer la visibilité du mot de passe
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  @override
  void initState() {
    super.initState();
    _loadCheckboxState();
    if (_isChecked) {
      // Si l'utilisateur a choisi de se souvenir de lui, on charge les données
      // de connexion ici

      User? user = ApiService().getSavedUser() as User?;
      if (user != null) {
        // Rediriger vers la page d'accueil si l'utilisateur est déjà connecté
        print("Il existe un utilisateur: $user");
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

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // Contenu principal
          Padding(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              children: [
                // Logo en haut
                Padding(
                  padding: const EdgeInsets.only(top: 70.0),
                  child: Image.asset(
                    'assets/images/promeca_logo.png', // Remplacez par votre chemin d'image
                    height: 200,
                    fit: BoxFit.contain,
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
                const SizedBox(height: 40),
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
                const SizedBox(height: 20),
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
                          _obscurePassword =
                              !_obscurePassword; // Inverse la visibilité
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
                      style: AppStyles.bodyMedium(context),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        l10n.authForgotPassword,
                        style: AppStyles.bodyMedium(
                          context,
                        ).copyWith(color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                // Bouton de connexion
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () async {
                      String phoneNumber = _phoneController.text;
                      String password = _passwordController.text;
                      // Logique d'authentification ici
                      try {
                        // Appel de la fonction authenticateUser et récupération de la réponse
                        Map<String, dynamic> response = await ApiService()
                            .authenticateUser(
                              identifier: phoneNumber,
                              password: password,
                              mail: phoneNumber,
                              rememberMe: _isChecked,
                            );
                        User user = User.fromJson(response['data']['user']);
                        print(user.role.name);
                        // Afficher un message de succès
                        if (user.isCompanyAdmin) {
                          showModalBottomSheet(
                            context: context,
                            builder: (context) {
                              return Center(
                                child: Text("${l10n.connectionSuccess}"),
                              );
                            },
                          );
                        } else if (user.role.name == "Technician" ||
                            user.role.name == "receptionniste") {
                          Navigator.pushReplacementNamed(
                            // ignore: use_build_context_synchronously
                            context,
                            '/technician_home',
                            arguments: user,
                          );
                        }
                        // Rediriger vers la page d'accueil si l'authentification réussie

                        //On va recuperer l'utilisateur connecté se trouvant dans les preferences enregistré dans la fonction
                        //authenticateUser
                      } catch (e) {
                        // Afficher un message d'erreur
                        // ignore: use_build_context_synchronously
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.authLoginFailed)),
                        );
                      }
                    },
                    child: Text(
                      l10n.authLogin,
                      style: AppStyles.bodyLarge(context).copyWith(
                        color: AppColors.background,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                // Espacer pour pousser le message vers le bas
                const Spacer(),
                // Message en bas de page
                Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
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

  //
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
