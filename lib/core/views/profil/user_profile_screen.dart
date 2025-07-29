import 'package:flutter/material.dart';
import 'package:pro_meca/core/models/user.dart';
import 'package:pro_meca/services/dio_api_services.dart';
import 'package:provider/provider.dart';
import 'package:pro_meca/core/constants/app_colors.dart';
import 'package:pro_meca/core/constants/app_styles.dart';
import 'package:pro_meca/core/providers/theme_provider.dart';
import 'package:pro_meca/l10n/arb/app_localizations.dart';
import '../../widgets/editable_textField.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? _user;
  bool _isLoading = true;
  String? _errorMessage;
  @override
  void initState() {
    super.initState();
    _fetchUser();
  }

  Future<void> _fetchUser() async {
    try {
      final user = await ApiDioService().getSavedUser();
      setState(() {
        _user = user;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors du chargement des données utilisateur';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;
    final textColor = isDarkMode ? Colors.white : AppColors.text;
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : _errorMessage != null
            ? Center(child: Text(_errorMessage!))
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section profil
                  _buildProfileHeader(context, l10n, _user),
                  const SizedBox(height: 10),
                  // Informations utilisateur
                  _buildUserInfoSection(context, l10n, textColor, _user),
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
          const CircleAvatar(
            radius: 50,
            backgroundImage: AssetImage('assets/images/images.jpeg'),
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
            user?.bio ?? "Pas de bio disponible",
            context,
          ),
          const Divider(height: 24, color: Colors.black12),
          _buildInfoRow(l10n.phoneNumberLabel, user?.phone ?? "", context),
          if (user?.isCompanyAdmin ?? false) ...[
            ///Renvoyé la liste des certifications de l'utilisateur
            const Divider(height: 24, color: Colors.black12),
            _buildInfoRow(
              l10n.certificationsLabel,
              user?.companyId ?? "Aucune certification",
              context,
            ),
          ],
          const Divider(height: 24, color: Colors.black12),
          _buildInfoRow(
            l10n.roleLabel,
            user?.role.name ?? l10n.technicianRole,
            context,
          ),
          if (user?.isCompanyAdmin ?? false) ...[
            ///Renvoyé la liste des permissions de l'utilisateur
            const Divider(height: 24, color: Colors.black12),
            _buildInfoRow(
              l10n.permissionsLabel,
              l10n.permissionsDetails,
              context,
            ),
          ],
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
}
