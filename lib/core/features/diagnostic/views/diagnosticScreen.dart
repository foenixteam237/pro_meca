import 'package:flutter/material.dart';
import 'package:pro_meca/core/constants/app_styles.dart';
import 'package:pro_meca/core/features/diagnostic/services/diagnostic_services.dart';
import 'package:pro_meca/core/widgets/customAppBar.dart';
import 'package:pro_meca/l10n/arb/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../constants/app_adaptive_colors.dart';
import '../../../models/diagnostic_update.dart';
import '../../../models/dysfonctionnement.dart';
import '../../../models/visite.dart';
import '../widgets/build_problem_reported_section.dart';
import '../widgets/build_vehicle_info_section.dart';

class DiagnosticPage extends StatefulWidget {
  final String idVisite;
  final Visite? visite;
  final String? accessToken;

  const DiagnosticPage({
    super.key,
    required this.idVisite,
    this.visite,
    this.accessToken,
  });

  @override
  _DiagnosticPageState createState() => _DiagnosticPageState();
}

class _DiagnosticPageState extends State<DiagnosticPage> {
  late final TextEditingController problemReportedController;
  bool _isLoading = false;
  String urgencyLevel = "négligeable";

  // Nouvelle structure pour gérer plusieurs diagnostics
  List<DiagnosticEntry> diagnosticEntries = [];

  @override
  void initState() {
    super.initState();
    problemReportedController = TextEditingController(
      text: widget.visite?.constatClient ?? '',
    );

    // Ajouter un diagnostic vide par défaut
    diagnosticEntries.add(DiagnosticEntry());
  }

  @override
  void dispose() {
    problemReportedController.dispose();

    // Disposer tous les contrôleurs des diagnostics
    for (var entry in diagnosticEntries) {
      entry.codeController.dispose();
      entry.detailController.dispose();
    }

    super.dispose();
  }

  // Ajouter un nouveau diagnostic
  void _addDiagnostic() {
    setState(() {
      diagnosticEntries.add(DiagnosticEntry());
    });
  }

  // Supprimer un diagnostic
  void _removeDiagnostic(int index) {
    if (diagnosticEntries.length > 1) {
      setState(() {
        // Disposer les contrôleurs avant de supprimer
        diagnosticEntries[index].codeController.dispose();
        diagnosticEntries[index].detailController.dispose();
        diagnosticEntries.removeAt(index);
      });
    }
  }

  Future<void> createDiagnostic() async {
    if (_isLoading) return;

    // Valider qu'au moins un diagnostic a été saisi
    bool hasValidDiagnostic = false;
    for (var entry in diagnosticEntries) {
      if (entry.codeController.text.isNotEmpty ||
          entry.detailController.text.isNotEmpty) {
        hasValidDiagnostic = true;
        break;
      }
    }

    if (!hasValidDiagnostic) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Veuillez ajouter au moins un diagnostic"),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Préparer la liste des dysfonctionnements
      final List<Dysfonctionnement> dysfonctionnements = diagnosticEntries
          .where(
            (entry) =>
                entry.codeController.text.isNotEmpty ||
                entry.detailController.text.isNotEmpty,
          )
          .map(
            (entry) => Dysfonctionnement(
              code: entry.codeController.text,
              detail: entry.detailController.text,
            ),
          )
          .toList();

      final diagnostic = Diagnostic(
        id: widget.idVisite,
        niveauUrgence: urgencyLevel,
        dysfonctionnements: dysfonctionnements,
        validated: false,
      );

      final response = await DiagnosticServices().submitDiagnostic(
        diagnostic,
        widget.accessToken!,
      );

      if (response) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Diagnostic envoyé avec succès!")),
        );

        if (mounted) {
          var route = '';
          final pref = await SharedPreferences.getInstance();
          bool isAdmin = pref.getBool('isAdmin') ?? false;

          if (isAdmin) {
            route = '/admin_home';
          } else {
            route = '/technician_home';
          }

          Navigator.pushNamedAndRemoveUntil(
            context,
            route,
            (Route<dynamic> route) => false,
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Échec de l'envoi du diagnostic")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Erreur: ${e.toString()}")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 600;
    final appColors = Provider.of<AppAdaptiveColors>(context);

    return Scaffold(
      appBar: CustomAppBar(
        profileImagePath: "assets/images/images.jpeg",
        name: "Dilane",
        role: l10n.technicianRole,
        accessToken: widget.accessToken ?? "",
        nameColor: appColors.primary,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Vehicle Info Section
              buildVehicleInfoSection(
                context,
                isMobile,
                appColors,
                l10n,
                widget.visite,
                widget.accessToken,
              ),

              const SizedBox(height: 20),

              // Problem Reported Section
              buildProblemReportedSection(context, problemReportedController),

              const SizedBox(height: 10),

              // Urgency Level
              _buildUrgencySection(context),

              const SizedBox(height: 10),

              // Diagnostics Section
              _buildDiagnosticsSection(context),

              const SizedBox(height: 20),

              // Submit Button
              _buildSubmitButton(context, appColors),
            ],
          ),
        ),
      ),
    );
  }

  /*
  Widget _buildProblemReportedSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Problème signalé par le client",
          style: AppStyles.titleMedium(context),
        ),
        const SizedBox(height: 8),
        _buildMultilineInput(
          controller: problemReportedController,
          hint: "Exemple(Fumée blanche.........)",
          readOnly: true, // Rendre en lecture seule
        ),
      ],
    );
  }
*/
  Widget _buildDiagnosticsSection(BuildContext context) {
    final appColor = Provider.of<AppAdaptiveColors>(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Diagnostic du technicien",
              style: AppStyles.titleMedium(context),
            ),
            IconButton(
              icon: Icon(Icons.add_circle, color: appColor.primary),
              onPressed: _addDiagnostic,
              tooltip: "Ajouter un diagnostic",
            ),
          ],
        ),
        const SizedBox(height: 10),

        ...diagnosticEntries.asMap().entries.map((entry) {
          final index = entry.key;
          final diagnostic = entry.value;

          return Padding(
            padding: const EdgeInsets.only(bottom: 15),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Champ Code erreur
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: diagnostic.codeController,
                      decoration: const InputDecoration(
                        hintText: "Code erreur (facultatif)",
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 16,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  // Champ Détails du diagnostic
                  Expanded(
                    flex: 5,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextField(
                          controller: diagnostic.detailController,
                          maxLines: 1,
                          decoration: const InputDecoration(
                            hintText: "Détails du diagnostic*",
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 16,
                            ),
                          ),
                        ),
                        if (diagnostic.detailController.text.isEmpty)
                          const Padding(
                            padding: EdgeInsets.only(top: 4),
                            child: Text(
                              "Ce champ est obligatoire",
                              style: TextStyle(color: Colors.red, fontSize: 12),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Bouton Supprimer
                  if (diagnosticEntries.length > 1)
                    Padding(
                      padding: const EdgeInsets.only(left: 8, top: 12),
                      child: IconButton(
                        icon: const Icon(
                          Icons.remove_circle,
                          color: Colors.red,
                          size: 28,
                        ),
                        onPressed: () => _removeDiagnostic(index),
                      ),
                    ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildUrgencySection(BuildContext context) {
    return Row(
      children: [
        const Expanded(flex: 2, child: Text("Niveau d'intervention")),
        const SizedBox(width: 10),
        Expanded(
          flex: 2,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: urgencyLevel,
                items: const [
                  DropdownMenuItem(
                    value: "négligeable",
                    child: Text("négligeable"),
                  ),
                  DropdownMenuItem(value: "mineur", child: Text("mineur")),
                  DropdownMenuItem(value: "majeur", child: Text("majeur")),
                  DropdownMenuItem(value: "critique", child: Text("critique")),
                ],
                onChanged: (value) {
                  setState(() {
                    urgencyLevel = value ?? "négligeable";
                  });
                },
                icon: const Icon(Icons.arrow_drop_down),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(BuildContext context, AppAdaptiveColors appColors) {
    return Center(
      child: ElevatedButton(
        onPressed: _isLoading ? null : createDiagnostic,
        style: AppStyles.primaryButton(context).copyWith(
          backgroundColor: WidgetStateProperty.all<Color>(appColors.primary),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text("Soumettre", style: AppStyles.buttonText(context)),
      ),
    );
  }

  /* Widget _buildMultilineInput({
    required String hint,
    required TextEditingController controller,
    bool readOnly = false,
  }) {
    return Container(
      height: Responsive.responsiveValue(
        context,
        mobile: MediaQuery.of(context).size.height * 0.2,
      ),
      padding: const EdgeInsets.all(5),
      child: TextField(
        controller: controller,
        maxLines: 5,
        readOnly: readOnly,
        decoration: InputDecoration(
          hintText: hint,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.green.withOpacity(0.1)),
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.grey),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
*/
}

// Nouvelle classe pour représenter une entrée de diagnostic
class DiagnosticEntry {
  final TextEditingController codeController;
  final TextEditingController detailController;

  DiagnosticEntry()
    : codeController = TextEditingController(),
      detailController = TextEditingController();
}
