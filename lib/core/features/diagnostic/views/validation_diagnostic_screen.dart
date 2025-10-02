import 'package:flutter/material.dart';
import 'package:pro_meca/core/constants/app_adaptive_colors.dart';
import 'package:pro_meca/core/constants/app_styles.dart';
import 'package:pro_meca/core/features/diagnostic/services/diagnostic_services.dart';
import 'package:pro_meca/core/features/diagnostic/views/intervention_create_page.dart';
import 'package:pro_meca/core/features/diagnostic/widgets/build_intervention_widget.dart';
import 'package:pro_meca/core/features/diagnostic/widgets/build_vehicle_shimmer.dart';
import 'package:pro_meca/core/models/dysfonctionnement.dart';
import 'package:pro_meca/core/models/maintenance_task.dart';
import 'package:pro_meca/core/models/photo_visite.dart';
import 'package:pro_meca/core/models/visite.dart';
import 'package:pro_meca/core/utils/responsive.dart';
import 'package:pro_meca/core/widgets/customAppBar.dart';
import 'package:pro_meca/l10n/arb/app_localizations.dart';
import 'package:pro_meca/services/dio_api_services.dart';
import 'package:provider/provider.dart';

//import 'package:pro_meca/core/models/diagnostic.dart';
import 'package:pro_meca/core/models/diagnostic_update.dart';
import '../../../models/maintenance.dart';
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
  List<MaintenanceTask> mains = [];
  List<Photo>? photos = [];
  bool isLoadingDiagnostics = false;
  String? errorMessage;
  Map<String, String> header = {};
  int index = 0;
  bool isCreateInt = false;
  @override
  void initState() {
    super.initState();
    // Initialisation du controller avec la valeur de la visite
    problemReportedController = TextEditingController(
      text: widget.visite.constatClient,
    );
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() {
      isLoadingDiagnostics = true;
    });
    try {
      // Exécuter les appels de manière concurrente
      final diagnosticsFuture = DiagnosticServices().fetchDiagnostic(
        widget.idVisite,
      );
      final headersFuture = ApiDioService().getAuthHeaders();

      // Attendre les deux futures
      diagnostics = await diagnosticsFuture;
      header = await headersFuture;

      setState(() {
        // Aplatir la liste des dysfonctionnements
        dysfonctionnements = diagnostics
            .expand((diag) => diag.dysfonctionnements)
            .toList();
        photos = widget.visite.photos;
        isLoadingDiagnostics = false;
      });
    } catch (e) {
      // Gestion des erreurs plus informative
      print("Erreur lors du chargement des catégories : $e");
      // Vous pouvez également afficher un message d'erreur à l'utilisateur ici
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

  void _addMainTask(MaintenanceTask main) {
    setState(() {
      mains.add(main);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Intervention ${main.title} ajoutée avec succès'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    });
  }

  void _removeMainTask(int index) {
    setState(() {
      mains.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Intervention retirée avec succès'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _interventionCreate() async {
    if (mains.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Aucune intervention ajoutée, veuillez ajouter au moins une intervention',
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    try {
      setState(() => isCreateInt = true);

      final main = Maintenance(
        diagId: widget.visite.diagnostics!.first.id,
        maintenance: mains,
        replaceExisting: false,
        visiteId: widget.idVisite,
      );
      print(main.toJson());
      final isCreate = await DiagnosticServices().createMaintenanceTask(
        main.toJson(),
      );

      if (isCreate) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Diagnostic validé avec succès'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() {
        !isCreateInt;
      });
      throw (errorMessage: e);
    } finally {
      setState(() {
        isCreateInt = false;
      });
    }
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
        accessToken: widget.accessToken,
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
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (photos != null && photos!.isNotEmpty)
                        ...photos!.map(
                              (photo) => VehicleImageCard(photo.logo, header),
                        )
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
              ),
              const SizedBox(height: 20),

              // Diagnostic technicien
              Text(
                "Diagnostic fait par le technicien",
                style: AppStyles.titleLarge(context),
              ),
              const SizedBox(height: 10),
              // Liste des diagnostics
              isLoadingDiagnostics
                  ? DiagnosticRowShimmer()
                  : dysfonctionnements.isEmpty
                  ? const Text("Aucun diagnostic disponible.")
                  : Column(
                      children: dysfonctionnements
                          .map(
                            (dys) => GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => InterventionForm(
                                    header: buildVehicleInfoSection(
                                      context,
                                      isMobile,
                                      appColors,
                                      l10n,
                                      widget.visite,
                                      widget.accessToken,
                                    ),
                                    visiteId: widget.idVisite,
                                    accessToken: widget.accessToken,
                                    dys: dys,
                                    techName: "Dilane Tech",
                                    onTaskAdd: (taskAdd) {
                                      //ici ajouter une logique pour ajouter l'intervention à la liste
                                      _addMainTask(taskAdd);
                                    },
                                  ),
                                ),
                              ),
                              child: DiagnosticRow(
                                code: dys.code ?? "N/A",
                                desc: dys.detail,
                              ),
                            ),
                          )
                          .toList(),
                    ),

              const SizedBox(height: 10),

              // Interventions à faire
              const Text(
                "Interventions à faire",
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
              ),
              const SizedBox(height: 10),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: mains.map((inter) {
                  index++;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: interventionItem(inter, context),
                  );
                }).toList(),
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
                  onPressed: () {
                    _interventionCreate();
                  },
                  child: isCreateInt
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text("Validé", style: AppStyles.buttonText(context)),
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
    const double imageWidth = 80;
    const double imageHeight = 70;
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          image,
          width: imageWidth,
          height: imageHeight,
          headers: headers,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              width: imageWidth,
              height: imageHeight,
              color: Colors.grey.shade300,
              child: Center(child: CircularProgressIndicator()),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: imageWidth,
              height: imageHeight,
              color: Colors.grey.shade300,
              child: Image.asset(
                "assets/images/moteur.jpg",
                width: imageWidth,
                height: imageHeight,
                fit: BoxFit.cover,
              ),
            );
          },
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
      padding: const EdgeInsets.only(bottom: 10.0, top: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Champ Code erreur
          Expanded(
            flex: 2,
            child: AbsorbPointer(
              child: TextField(
                readOnly: true,
                controller: TextEditingController(text: code),
                decoration: const InputDecoration(
                  hintText: "Code erreur (facultatif)",
                  label: Text("Code erreur"),
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 16,
                  ),
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
                AbsorbPointer(
                  child: TextField(
                    readOnly: true,
                    controller: TextEditingController(text: desc),
                    maxLines: 1,
                    decoration: const InputDecoration(
                      hintText: "Détails du diagnostic*",
                      label: Text("Détails du diagnostic"),
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 16,
                      ),
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
