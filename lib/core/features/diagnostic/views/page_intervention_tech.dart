import 'package:flutter/material.dart';
import 'package:pro_meca/core/constants/app_adaptive_colors.dart';
import 'package:pro_meca/core/constants/app_styles.dart';
import 'package:pro_meca/core/features/diagnostic/views/intervention_detail.dart';
import 'package:pro_meca/core/features/diagnostic/views/technician_report.dart';
import 'package:pro_meca/core/features/diagnostic/widgets/build_vehicle_info_section.dart';
import 'package:pro_meca/core/models/diagnostic_update.dart';
import 'package:pro_meca/core/models/maintenance_task.dart';
import 'package:pro_meca/core/models/visite.dart';
import 'package:pro_meca/core/utils/responsive.dart';
import 'package:pro_meca/l10n/arb/app_localizations.dart';
import 'package:provider/provider.dart';

class InterventionPage extends StatefulWidget {
  final String accessToken;
  final Visite visite;
  const InterventionPage({
    super.key,
    required this.accessToken,
    required this.visite,
  });

  @override
  // ignore: library_private_types_in_public_api
  _InterventionPageState createState() => _InterventionPageState();
}

class _InterventionPageState extends State<InterventionPage> {
  AppAdaptiveColors? appColors;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    appColors ??= Provider.of<AppAdaptiveColors>(context);
    final Diagnostic diagnostic = widget.visite.diagnostics!.first;
    final List<MaintenanceTask> main= [];
    widget.visite.intervention!.map(
        (e) {
          if(e.status != "ATTENTE_VALIDATION_INTERVENTION"){
            main.add(e);
          }
        }
    );
    return Scaffold(
      appBar: AppBar(
        title: Text('Interventions'),
        backgroundColor: appColors!.primary,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Widget pour les informations sur la visite/voiture
            buildVehicleInfoSection(
              context,
              Responsive.isMobile(context),
              appColors!,
              AppLocalizations.of(context),
              widget.visite,
              widget.accessToken,
            ),
            SizedBox(height: 16),
            Text(
              'Liste des interventions en attente',
              style: AppStyles.titleMedium(context),
            ),
            SizedBox(height: 10),
            widget.visite.intervention != null &&
                    widget.visite.intervention!.isNotEmpty
                ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ...main.map(
                          (intervention) =>  buildInterventionCard(
                              nom: intervention.title,
                              priorite: intervention.priority,
                            onVoirPlusPressed: (){
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => InterventionDetailPage(
                                    main: intervention,
                                  ),
                                ),
                              );
                            },
                            onRapportPressed: (){
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => TechnicianReport(
                                    visite: widget.visite,
                                    accessToken: widget.accessToken,
                                    maintenanceTask: intervention,
                                  ),
                                ),
                              );
                            }
                          ),
                        ),
                      ],
                    ),
                  )
                : Center(
                    child: Text(
                      'Aucune intervention disponible.',
                      style: AppStyles.bodyMedium(context),
                    ),
                  ),
            Text(
              'Liste des interventions terminées',
              style: AppStyles.titleMedium(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildInterventionCard({
    required String nom,
    required int priorite,
    VoidCallback? onRapportPressed,
    VoidCallback? onVoirPlusPressed,
  }) {
    // Définir les couleurs selon la priorité
    Color getPriorityColor(String priorite) {
      switch (priorite.toLowerCase()) {
        case 'normale':
          return Colors.green;
        case 'élevée':
        case 'elevee':
          return Colors.orange;
        case 'critique':
        case 'urgente':
          return Colors.red;
        default:
          return Colors.grey;
      }
    }

    String getPriorityText(int priorite) {
      switch (priorite) {
        case 1:
          return "Très basse";
        case 2:
          return "Basse";
        case 3:
          return "Normale";
        case 4:
          return "Critique";
        case 5:
          return "Urgente";
        default:
          return "Inconnue";
      }
    }

    return Container(
      margin: EdgeInsets.all(5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: appColors!.primary),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            // Image/Icône à gauche
            Container(
              width: 60,
              height: 90,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: Image.asset(
                    'assets/images/moteur.jpg',
                    fit: BoxFit.cover,
                  ).image,
                  fit: BoxFit.cover,
                ),
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
              ),
            ),

            const SizedBox(width: 10),

            // Contenu principal
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nom de l'intervention
                  Text(
                    nom,
                    style: AppStyles.titleMedium(
                      context,
                    ).copyWith(fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  // Priorité
                  Row(
                    children: [
                      const Text(
                        'Priorité: ',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      Text(
                        getPriorityText(priorite),
                        style: TextStyle(
                          fontSize: 12,
                          color: getPriorityColor(getPriorityText(priorite)),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // Boutons d'action
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      buildActionButton(
                        background: appColors!.primary,
                        onPressed: ()=>onRapportPressed!(),
                        text: 'Rapport',
                      ),
                      /*
                      const SizedBox(width: 6),

                      buildActionButton(
                        background: appColors!.primary,
                        text: 'Proceder',
                        onPressed: ()=> onVoirPlusPressed!(),
                      ),*/
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildActionButton({
    required String text,
    required VoidCallback onPressed,
    required Color background,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: background,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 2,
      ),
      child: Text(
        text,
        style: AppStyles.buttonText(context).copyWith(fontSize: 12),
      ),
    );
  }
}
