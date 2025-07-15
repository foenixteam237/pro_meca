// features/auth/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:pro_meca/core/constants/app_styles.dart';
import 'package:pro_meca/core/utils/localization.dart';

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
            Text(
              AppLocalizations.of(context).translate("app.title"),
              style: AppStyles.headline1(context)),
            const SizedBox(height: 40),
            TextField(
              decoration: AppStyles.inputDecoration(
                context,
                label: AppLocalizations.of(context).translate("auth.phone_number"),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              obscureText: true,
              decoration: AppStyles.inputDecoration(
                context,
                label: AppLocalizations.of(context).translate("auth.password"),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Checkbox(value: true, onChanged: (value) {}),
                Text(
                  AppLocalizations.of(context).translate("auth.remember_me"),
                  style: AppStyles.bodyMedium(context),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    AppLocalizations.of(context).translate("auth.forgot_password"),
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
                child:  Text(AppLocalizations.of(context).translate("auth.login")),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context).translate("auth.login_message"),
              style: AppStyles.bodySmall(context),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
