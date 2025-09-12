import 'package:flutter/material.dart';
import 'package:pro_meca/core/constants/app_adaptive_colors.dart';
import 'package:pro_meca/core/constants/app_colors.dart';
import 'package:pro_meca/core/constants/app_styles.dart';
import 'package:pro_meca/core/features/diagnostic/services/diagnostic_services.dart';
import 'package:pro_meca/core/features/diagnostic/widgets/build_intervention_widget.dart';
import 'package:pro_meca/core/features/diagnostic/widgets/build_vehicle_info_section.dart';
import 'package:pro_meca/core/models/maintenance_task.dart';
import 'package:pro_meca/core/widgets/customAppBar.dart';
import 'package:dio/dio.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../l10n/arb/app_localizations.dart';
import '../../../models/visite.dart';
import '../../../utils/responsive.dart';

class ValidationInterventionScreen extends StatefulWidget {
  final String visiteId;
  final bool isAdmin;
  final String accessToken;
  final Visite visite;
  const ValidationInterventionScreen({
    super.key,
    required this.visiteId,
    required this.isAdmin,
    required this.accessToken,
    required this.visite,
  });

  @override
  _ValidationInterventionScreenState createState() =>
      _ValidationInterventionScreenState();
}

class _ValidationInterventionScreenState
    extends State<ValidationInterventionScreen> {
  late List<MaintenanceTask> tasks =
      []; // Initialisé comme liste vide par défaut
  final Map<String, bool> interventionStatuses = {};
  bool isConfirming = false;
  int validatedCount = 0;
  bool isLoading = true; // Pour le chargement initial des interventions
  bool hasError = false; // Pour gérer les erreurs

  @override
  void initState() {
    super.initState();
    _fetchData(widget.visiteId);
  }

  Future<void> _fetchData(String visiteId) async {
    setState(() {
      isLoading = true;
      hasError = false;
    });
    try {
      final fetchedTasks = await DiagnosticServices().fetchIntervention(
        visiteId,
      );
      print(
        'Données récupérées: $fetchedTasks',
      ); // Log pour vérifier les données
      if (fetchedTasks != null) {
        setState(() {
          tasks = fetchedTasks;
          interventionStatuses
              .clear(); // Réinitialiser pour éviter les doublons

          for (var task in tasks) {
            interventionStatuses[task.id] = false;
          }
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          hasError = true; // Si null, considérer comme erreur
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        hasError = true;
      });
      print('Erreur lors du fetch des données: $e');
    }
  }

  Future<void> updateInterventionStatus(
    String interventionId,
    bool hasBeenOrdered,
  ) async {
    try {
      await DiagnosticServices().updateInterventionStatus(
        interventionId,
        hasBeenOrdered,
      );
      setState(() {
        interventionStatuses[interventionId] = hasBeenOrdered;
        validatedCount++;
      });
    } on DioException catch (e) {
      print("Erreur Dio lors de la mise à jour: $e");
      setState(() {
        validatedCount++; // Avancer la progression malgré l'erreur
      });
    } catch (e) {
      print("Erreur inattendue: $e");
      setState(() {
        validatedCount++; // Avancer la progression malgré l'erreur
      });
    }
  }

  Future<void> _confirmInterventions() async {
    final appColors = Provider.of<AppAdaptiveColors>(context, listen: false);
    if (isConfirming) return;
    setState(() {
      isConfirming = true;
      validatedCount = 0;
    });

    for (var task in tasks) {
      await updateInterventionStatus(
        task.id,
        interventionStatuses[task.id] ?? false,
      );
    }

    if (mounted) {
      setState(() {
        isConfirming = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Toutes les interventions ont été validées avec succès !',
          ),
          backgroundColor: AppColors.primary,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _toggleStatus(String id, bool isValidated) {
    setState(() {
      interventionStatuses[id] = isValidated;
    });
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Provider.of<AppAdaptiveColors>(context);
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: CustomAppBar(
        profileImagePath: "profileImagePath",
        name: "name",
        role: "role",
        nameColor: appColors.primary,
        accessToken: "accessToken",
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child:buildVehicleInfoSection(context, Responsive.isMobile(context), appColors, AppLocalizations.of(context), widget.visite, widget.accessToken),
          ),
          Expanded(
            child: isLoading
                ? Shimmer.fromColors(
                    baseColor: isDarkTheme
                        ? Colors.grey[700]!
                        : Colors.grey[300]!,
                    highlightColor: isDarkTheme
                        ? Colors.grey[600]!
                        : Colors.grey[100]!,
                    child: ListView.builder(
                      padding: EdgeInsets.all(16.0),
                      itemCount: 3, // Simule 3 éléments de chargement
                      itemBuilder: (context, index) {
                        return Container(
                          margin: const EdgeInsets.only(top: 10),
                          height: 100,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.blue.shade100),
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.white,
                          ),
                        );
                      },
                    ),
                  )
                : hasError
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Erreur lors du chargement des interventions.',
                          style: TextStyle(fontSize: 16, color: Colors.red),
                        ),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => _fetchData(widget.visiteId),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: appColors.primary,
                          ),
                          child: Text(
                            'Réessayer',
                            style: AppStyles.buttonText(context),
                          ),
                        ),
                      ],
                    ),
                  )
                : tasks.isEmpty
                ? Center(child: Text('Aucune intervention trouvée.'))
                : ListView.builder(
                    padding: EdgeInsets.all(16.0),
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      final isValidated =
                          interventionStatuses[task.id] ?? false;
                      if (widget.isAdmin) {
                        return InterventionCard(
                          title: task.title,
                          technician: task.technician ?? 'N/A',
                          status: isValidated ? 'Validée' : 'Annulée',
                          priority: task.priority.toString(),
                          appColors: appColors,
                          imageUrl:
                              'https://tmna.aemassets.toyota.com/is/image/toyota/toyota/vehicles/2025/crownsignia/gallery/CRS_MY25_0011_V001_desktop.png?fmt=jpeg&fit=crop&qlt=90&wid=1024',
                          taskId: task.id,
                          isValidated: isValidated,
                          onStatusChanged: (id, validated) =>
                              _toggleStatus(id, validated),
                        );
                      } else if (task.hasBeenOrdered == true) {
                        return interventionItem(task, context);
                      }
                    },
                  ),
          ),
          if (widget.isAdmin)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: isConfirming
                  ? SizedBox(
                      height: 50,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          LinearProgressIndicator(
                            value: tasks.isEmpty
                                ? 0
                                : validatedCount / tasks.length,
                            backgroundColor: Colors.grey.shade300,
                            color: appColors.primary,
                            minHeight: 50,
                          ),
                          Text(
                            validatedCount > 0 && validatedCount <= tasks.length
                                ? '${tasks[validatedCount - 1].title} validé avec succès'
                                : 'Validation en cours...',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  : ElevatedButton(
                      onPressed: _confirmInterventions,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: appColors.primary,
                        minimumSize: Size(double.infinity, 50),
                      ),
                      child: Text(
                        'Confirmé',
                        style: AppStyles.buttonText(context),
                      ),
                    ),
            ),
        ],
      ),
    );
  }
}

class InterventionCard extends StatelessWidget {
  final String title;
  final String technician;
  final String status;
  final String priority;
  final String imageUrl;
  final AppAdaptiveColors appColors;
  final String taskId;
  final bool isValidated;
  final Function(String, bool) onStatusChanged;

  InterventionCard({
    required this.title,
    required this.technician,
    required this.status,
    required this.priority,
    required this.imageUrl,
    required this.appColors,
    required this.taskId,
    required this.isValidated,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blue.shade100),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              imageUrl,
              width: 70,
              height: 70,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Image.asset(
                  "assets/images/moteur.jpg",
                  width: 70,
                  height: 70,
                  fit: BoxFit.cover,
                );
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                Text(
                  "Priorité: $priority",
                  style: TextStyle(color: Colors.orange, fontSize: 13),
                ),
                Text(
                  "Technicien: $technician",
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
          Column(
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: !isValidated
                      ? Colors.red
                      : Colors.grey.shade400,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  onStatusChanged(taskId, false);
                },
                child: Icon(Icons.delete, color: AppAdaptiveColors.red_fade),
              ),
              SizedBox(height: 8),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isValidated
                      ? AppColors.primary
                      : Colors.grey.shade400,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  onStatusChanged(taskId, true);
                },
                child: Icon(Icons.check, color: AppAdaptiveColors.red_fade),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
