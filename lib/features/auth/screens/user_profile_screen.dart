import 'package:flutter/material.dart';
import 'package:pro_meca/core/models/user.dart';
import 'package:pro_meca/features/settings/services/api_services.dart';
import 'package:provider/provider.dart';
import 'package:pro_meca/core/constants/app_colors.dart';
import 'package:pro_meca/core/constants/app_styles.dart';
import 'package:pro_meca/features/settings/providers/theme_provider.dart';
import 'package:pro_meca/l10n/arb/app_localizations.dart';

import '../../../core/widgets/editable_textField.dart';

@override
Widget buildProfil(BuildContext context) {
  final l10n = AppLocalizations.of(context);
  final themeProvider = Provider.of<ThemeProvider>(context);
  final isDarkMode = themeProvider.themeMode == ThemeMode.dark;
  final textColor = isDarkMode ? Colors.white : AppColors.text;

  return Scaffold(
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: FutureBuilder(
        future: ApiService().getSavedUser(),
        builder: (context, asyncSnapshot) {
          final user = asyncSnapshot.data;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section profil
              _buildProfileHeader(context, l10n, user),
              const SizedBox(height: 10),

              // Informations utilisateur
              _buildUserInfoSection(context, l10n, textColor, user),
              const SizedBox(height: 24),

              // Bouton de mise à jour
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    // Action de mise à jour
                  },
                  child: Text(
                    l10n.updateProfile,
                    style: AppStyles.buttonText(context),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    ),
  );
}

Widget _buildProfileHeader(
  BuildContext context,
  AppLocalizations l10n,
  User? user,
) {
  return Center(
    child: Column(
      children: [
        Stack(
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage('assets/images/images.jpeg'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          user?.name ?? "",
          style: AppStyles.titleLarge(
            context,
          ).copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          user?.role.name ?? l10n.technicianRole,
          style: AppStyles.bodyMedium(
            context,
          ).copyWith(color: AppColors.primary),
        ),
      ],
    ),
  );
}

Widget _buildUserInfoSection(
  BuildContext context,
  AppLocalizations l10n,
  Color textColor,
  User? user,
) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          // ignore: deprecated_member_use
          color: Colors.black.withOpacity(0.05),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow(l10n.nameLabel, user?.name ?? "", context),
        const Divider(height: 24, color: Colors.black12),
        _buildInfoRow(
          l10n.biographyLabel,
          user?.bio ?? l10n.certifiedTechnician,
          context,
        ),
        const Divider(height: 24, color: Colors.black12),
        _buildInfoRow(
          l10n.phoneNumberLabel,
          user?.phone ?? '+237 657899898',
          context,
        ),
        const Divider(height: 24, color: Colors.black12),
        _buildInfoRow(l10n.certificationsLabel, 'TechForm', context),
        const Divider(height: 24, color: Colors.black12),
        _buildInfoRow(
          l10n.roleLabel,
          user?.role.name ?? l10n.technicianRole,
          context,
        ),
        const Divider(height: 24, color: Colors.black12),
        _buildInfoRow(l10n.permissionsLabel, l10n.permissionsDetails, context),
      ],
    ),
  );
}

Widget _buildInfoRow(String label, String value, BuildContext context) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: AppStyles.bodySmall(
          context,
        ).copyWith(color: Theme.of(context).hintColor),
      ),
      const SizedBox(height: 4),
      EditableTextField(value: value),
    ],
  );
}
