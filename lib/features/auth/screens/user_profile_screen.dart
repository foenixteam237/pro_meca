import 'package:flutter/material.dart';
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section profil
            _buildProfileHeader(context, l10n),
            const SizedBox(height: 10),

            // Informations utilisateur
            _buildUserInfoSection(context, l10n, textColor),
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
                  style: AppStyles.buttonText(context)
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, AppLocalizations l10n) {
    final screenSize = MediaQuery
        .of(context)
        .size;
    final isMobile = screenSize.width < 600;
    final isDarkMode = Theme
        .of(context)
        .brightness == Brightness.dark;
    return Center(
      child: Column(
        children: [
          Stack(
            children: [
              const CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage('assets/images/images.jpeg'),
              ),
            ]
          ),
          const SizedBox(height: 8),
          Text(
            'TOM FISHER',
            style: AppStyles.titleLarge(context).copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.administratorRole,
            style: AppStyles.bodyMedium(context).copyWith(
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserInfoSection(
      BuildContext context, AppLocalizations l10n, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow(l10n.nameLabel, 'ALBERT JOSHUA', context),
          const Divider(height: 24, color: Colors.black12,),
          _buildInfoRow(l10n.biographyLabel, l10n.certifiedTechnician, context),
          const Divider(height: 24, color: Colors.black12,),
          _buildInfoRow(l10n.phoneNumberLabel, '+237 657899898', context),
          const Divider(height: 24, color: Colors.black12,),
          _buildInfoRow(l10n.certificationsLabel, 'TechForm', context),
          const Divider(height: 24, color: Colors.black12,),
          _buildInfoRow(l10n.roleLabel, l10n.technicianRole, context),
          const Divider(height: 24, color: Colors.black12,),
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
          style: AppStyles.bodySmall(context).copyWith(
            color: Theme.of(context).hintColor,
          ),
        ),
        const SizedBox(height: 4),
        EditableTextField(value: value),
      ],
    );
  }
