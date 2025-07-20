import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pro_meca/core/constants/app_colors.dart';
import 'package:pro_meca/core/constants/app_styles.dart';
import 'package:pro_meca/features/settings/providers/locale_provider.dart';

import '../../../l10n/arb/app_localizations.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);

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
                  decoration: InputDecoration(
                    labelText: l10n.authPhoneNumber,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                  ),
                ),
                const SizedBox(height: 20),

                // Champ mot de passe
                TextField(
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: l10n.authPassword,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                  ),
                ),
                const SizedBox(height: 10),

                // Case à cocher "Se souvenir de mot"
                Row(
                  children: [
                    Checkbox(
                      value: false,
                      onChanged: (value) {},
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
                    onPressed: () {
                      Navigator.pushReplacementNamed(
                        context,
                        '/technician_home',
                      );
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

          // Sélecteur de langue en haut à droite
          Positioned(
            top: 40,
            right: 20,
            child: _buildLanguageSwitcher(context, localeProvider),
          ),
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
}
