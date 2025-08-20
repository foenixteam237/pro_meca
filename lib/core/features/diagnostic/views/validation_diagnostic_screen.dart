import 'package:flutter/material.dart';
import 'package:pro_meca/core/constants/app_adaptive_colors.dart';
import 'package:pro_meca/core/constants/app_styles.dart';
import 'package:pro_meca/core/features/diagnostic/services/diagnostic_services.dart';
import 'package:pro_meca/core/models/dysfonctionnement.dart';
import 'package:pro_meca/core/models/photo_visite.dart';
import 'package:pro_meca/core/models/visite.dart';
import 'package:pro_meca/core/utils/responsive.dart';
import 'package:pro_meca/core/widgets/customAppBar.dart';
import 'package:pro_meca/l10n/arb/app_localizations.dart';
import 'package:pro_meca/services/dio_api_services.dart';
import 'package:provider/provider.dart';

import '../../../models/diagnostic.dart';
import '../widgets/build_problem_reported_section.dart';
import '../widgets/build_vehicle_info_section.dart';

class ValidationDiagnosticScreen extends StatefulWidget {
  final String idVisite;
  final String accessToken;
  final Visite visite;

  const ValidationDiagnosticScreen({
    super.key,
    required this.idVisite,
    required this.visite,
    required this.accessToken,
  });

  @override
  State<ValidationDiagnosticScreen> createState() =>
      _ValidationDiagnosticScreenState();
}

class _ValidationDiagnosticScreenState
    extends State<ValidationDiagnosticScreen> {
  late final TextEditingController problemReportedController;
  List<Diagnostic> diagnostics = [];
  List<Dysfonctionnement> dysfonctionnements = [];
  List<Photo>? photos = [];
  bool isLoadingDiagnostics = false;
  String? errorMessage;
  Map<String, String> header = {};

  @override
  void initState() {
    super.initState();
    // Initialisation du controller avec la valeur de la visite
    problemReportedController = TextEditingController(
      text: widget.visite.constatClient ?? '',
    );
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() {
      isLoadingDiagnostics = true;
    });

    try {
      dysfonctionnements = widget.visite.diagnostics
          .expand((diagnostic) => diagnostic.dysfonctionnements)
          .toList();
      photos = widget.visite.photos;
      header = await ApiDioService().getAuthHeaders();
    } catch (e) {
      throw Exception("Erreur inconnue $e");
    } finally {
      setState(() {
        isLoadingDiagnostics = false;
      });
    }
  }

  @override
  void dispose() {
    // N'oubliez pas de disposer le controller
    problemReportedController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Provider.of<AppAdaptiveColors>(context);
    final l10n = AppLocalizations.of(context);
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: CustomAppBar(
        profileImagePath: "assets/images/images.jpeg",
        name: "Dilane",
        role: l10n.technicianRole,
        nameColor: appColors.primary,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildVehicleInfoSection(
                context,
                isMobile,
                appColors,
                l10n,
                widget.visite,
                widget.accessToken,
              ),
              const SizedBox(height: 20),
              buildProblemReportedSection(context, problemReportedController),

              // Images véhicule
              Text("Images du véhicule", style: AppStyles.titleLarge(context)),
              const SizedBox(height: 8),
              SizedBox(
                height: Responsive.responsiveValue(
                  context,
                  mobile: screenHeight * 0.1,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (photos != null && photos!.isNotEmpty)
                      ...photos!
                          .map((photo) => VehicleImageCard(photo.logo, header))
                          .toList()
                    else
                      ...List.generate(
                        4,
                        (index) => VehicleImageCard(
                          "assets/images/moteur.jpg",
                          header,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Diagnostic technicien
              Text(
                "Diagnostic fait par le technicien",
                style: AppStyles.titleLarge(context),
              ),
              const SizedBox(height: 10),
              // Liste des diagnostics
              if (dysfonctionnements.isNotEmpty)
                ...dysfonctionnements.map(
                  (dys) =>
                      DiagnosticRow(code: dys.code ?? "N/A", desc: dys.detail),
                )
              else
                const Text("Aucun diagnostic trouvé pour cette visite."),
              const SizedBox(height: 10),

              // Interventions à faire
              const Text(
                "Interventions à faire",
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue.shade100),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        "assets/images/moteur.jpg",
                        width: 70,
                        height: 70,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            "Direction",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          Text(
                            "Priorité: avertissement",
                            style: TextStyle(
                              color: Colors.orange,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            "Technicien: Dilane Tech",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: appColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        print(widget.visite.diagnostics.toList().length);
                      },
                      child: Text(
                        "Détails",
                        style: AppStyles.buttonText(
                          context,
                        ).copyWith(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Bouton de validation
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: appColors.primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 60,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () {},
                  child: Text("Validé", style: AppStyles.buttonText(context)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Widget pour images véhicule
class VehicleImageCard extends StatelessWidget {
  final String image;
  final Map<String, String> headers;
  const VehicleImageCard(this.image, this.headers, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          image,
          width: 80,
          height: 70,
          headers: headers,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            width: 80,
            height: 70,
            color: Colors.grey.shade300,
            child: Image.asset(
              "assets/images/moteur.jpg",
              width: 70,
              height: 70,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}

// Widget pour ligne diagnostic
class DiagnosticRow extends StatelessWidget {
  final String code, desc;
  const DiagnosticRow({super.key, required this.code, required this.desc});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Champ Code erreur
          Expanded(
            flex: 2,
            child: TextField(
              readOnly: true,
              controller: TextEditingController(text: code),
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
                  readOnly: true,
                  controller: TextEditingController(text: desc),
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
