// features/auth/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:pro_meca/core/constants/app_styles.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(AppStyles.paddingMedium),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('ÉroVeca', style: AppStyles.headline1(context)),
            const SizedBox(height: 40),
            TextField(
              decoration: AppStyles.inputDecoration(
                context,
                label: 'Matricule employé',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              obscureText: true,
              decoration: AppStyles.inputDecoration(
                context,
                label: 'Mot de passe',
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Checkbox(value: true, onChanged: (value) {}),
                Text(
                  'Se souvenir de moi',
                  style: AppStyles.bodyMedium(context),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    'Mot de passe oublié?',
                    style: AppStyles.bodyMedium(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: AppStyles.primaryButton(context),
                onPressed: () {},
                child: const Text('Connexion'),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Si vous n\'avez pas de compte, veuillez vous rapprocher de votre chef.',
              style: AppStyles.bodySmall(context),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
