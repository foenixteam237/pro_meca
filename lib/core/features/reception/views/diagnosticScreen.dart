import 'dart:math';

import 'package:flutter/material.dart';
import 'package:pro_meca/core/constants/app_styles.dart';
import 'package:pro_meca/core/utils/responsive.dart';
import 'package:pro_meca/core/widgets/customAppBar.dart';
import 'package:pro_meca/l10n/arb/app_localizations.dart';

class DiagnosticPage extends StatefulWidget {
  final String idVisite; // Paramètre pour l'identifiant de la visite
  const DiagnosticPage({super.key, required this.idVisite});
  @override
  _DiagnosticPageState createState() => _DiagnosticPageState();
}

class _DiagnosticPageState extends State<DiagnosticPage> {
  // Vous pouvez ajouter des contrôleurs ou des variables d'état ici si nécessaire
  final TextEditingController problemReportedController =
      TextEditingController();
  final TextEditingController problemIdentifiedController =
      TextEditingController();
  final TextEditingController errorCodeController = TextEditingController();
  String urgencyLevel = "Normal"; // Valeur par défaut pour le niveau d'urgence
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final screenSize = MediaQuery.of(context).size;

    final isMobile = screenSize.width < 600;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final avatarRadius = max(20, min(30, screenSize.width * 0.06));
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: CustomAppBar(
        profileImagePath: "assets/images/images.jpeg",
        name: "Dilane",
        role: l10n.technicianRole,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Infos véhicule
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: avatarRadius.toDouble(),
                          backgroundImage: AssetImage('assets/images/v1.jpg'),
                        ), // À adapter
                        SizedBox(width: isMobile ? 10 : 20),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              "N0567AZ",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              "Model: COROLLA LE",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Text(
                      "M MARTIN PETER",
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                SizedBox(height: isMobile ? 15 : 20),
                // Problème signalé
                Text("Problème signalé", style: AppStyles.titleMedium(context)),
                const SizedBox(height: 8),
                _buildMultilineInput(
                  controller: problemReportedController,
                  hint: "Fumée blanche.........",
                ),
                const SizedBox(height: 10),
                // Problème identifié
                Text(
                  "Problème identifié",
                  style: AppStyles.titleMedium(context),
                ),
                const SizedBox(height: 8),
                _buildMultilineInput(
                  controller: problemIdentifiedController,
                  hint: "Votre idée du problème",
                ),
                const SizedBox(height: 20),
                // Champs supplémentaires
                Row(
                  children: [
                    const Expanded(
                      flex: 2,
                      child: Text("Ce véhicule est-il électronique?"),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: _buildInputField(
                        controller: errorCodeController,
                        hint: "Code erreur",
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    const Expanded(flex: 2, child: Text("Niveau d'urgence")),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: urgencyLevel,
                            items: const [
                              DropdownMenuItem(
                                value: "Normal",
                                child: Text("Normal"),
                              ),
                              DropdownMenuItem(
                                value: "Élevé",
                                child: Text("Élevé"),
                              ),
                              DropdownMenuItem(
                                value: "Urgent",
                                child: Text("Urgent"),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() {
                                urgencyLevel =
                                    value ??
                                    "Normal"; // Mettre à jour la valeur
                              });
                            },
                            icon: const Icon(Icons.arrow_drop_down),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                // Bouton validé
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      // Ajouter la logique pour traiter la validation ici
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50), // Vert
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 16,
                      ),
                    ),
                    child: const Text("Validé", style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMultilineInput({
    required String hint,
    required TextEditingController controller,
  }) {
    return Container(
      height: Responsive.responsiveValue(
        context,
        mobile: MediaQuery.of(context).size.height * 0.2,
      ),
      padding: EdgeInsets.all(5),
      child: TextField(
        controller: controller,
        maxLines: 5,
        decoration: InputDecoration(
          hintText: hint,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          enabledBorder: OutlineInputBorder(
            // ignore: deprecated_member_use
            borderSide: BorderSide(color: Colors.green.withOpacity(0.1)),
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.green),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String hint,
    required TextEditingController controller,
  }) {
    return Container(
      height: 45,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(hintText: hint, border: InputBorder.none),
      ),
    );
  }
}
