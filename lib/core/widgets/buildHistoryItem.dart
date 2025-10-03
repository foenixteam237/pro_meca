import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pro_meca/core/features/diagnostic/views/validation_diagnostic_screen.dart';
import 'package:pro_meca/core/features/diagnostic/views/validation_intervention.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_colors.dart';
import '../constants/app_styles.dart';
import '../features/diagnostic/views/diagnosticScreen.dart';
import '../features/diagnostic/views/page_intervention_tech.dart';
import '../models/visite.dart';
import '../utils/responsive.dart';

Widget buildHistoryItem(
  Visite visite,
  BuildContext context,
  String accessToken,
) {
  final isMobile = Responsive.isMobile(context);
  final screenWidth = MediaQuery.of(context).size.width;
  return GestureDetector(
    onTap: () {
      _showNextPageOther(visite, context, accessToken);
    },
    child: Container(
      width: double.infinity,
      height: isMobile ? screenWidth * 0.23 : 80,
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: isMobile ? screenWidth * 0.2 : 80,
            height: isMobile ? screenWidth * 0.23 : 80,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                bottomLeft: Radius.circular(10),
              ),
              child: _buildImage(visite.vehicle?.logo, accessToken),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      visite.vehicle?.licensePlate ?? "",
                      style: AppStyles.titleMedium(
                        context,
                      ).copyWith(fontSize: 14),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Text(
                        DateFormat.yMMMd().format(visite.updatedAt),
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
                Text(
                  "Propriètaire: ${visite.vehicle?.client?.firstName ?? ""}",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: isMobile ? 12 : 18,
                  ),
                  maxLines: 1,
                ),
                const SizedBox(height: 4),
                Text(
                  _statut(visite.status),
                  style: TextStyle(
                    fontSize: 13,
                    color: _visitColor(visite.status),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

String _statut(String statut) {
  switch (statut) {
    case 'ATTENTE_DIAGNOSTIC':
      return "Diagnostic";
    case 'ATTENTE_VALIDATION_DIAGNOSTIC':
      return "Attente validation diagnostic";
    case 'ATTENTE_INTERVENTION':
      return "Attente intervention";
    case 'ATTENTE_PIECE':
      return "Attente pièces";
    case 'ENCOURS':
      return "En cours";
    default:
      return "En cours";
  }
}

Widget _buildImage(String? imageUrl, String accessToken) {
  if (imageUrl != null) {
    return Image.network(
      imageUrl,
      headers: {'Authorization': 'Bearer $accessToken'},
      fit: BoxFit.cover,
    );
  } else {
    return Image.asset('assets/images/v1.jpg', fit: BoxFit.cover);
  }
}

Color _visitColor(String status) {
  switch (status) {
    case "ATTENTE_DIAGNOSTIC":
      return AppColors.alert;
    case "ATTENTE_INTERVENTION":
      return Colors.blue;
    case "ATTENTE_VALIDATION_DIAGNOSTIC":
      return Colors.purpleAccent;
    case "ENCOURS":
      return Colors.orange;
    case "ATTENTE_PIECE":
      return Colors.deepOrangeAccent;
    case "TERMINE":
      return Colors.green;
    default:
      return Colors.blueAccent;
  }
}

// Enum for intervention statuses
enum InterventionStatus {
  attenteCommandeClient("ATTENTE_COMMANDE_CLIENT"),
  attenteIntervention("ATTENTE_INTERVENTION"),
  ongoing("ONGOING"),
  attentePiece("ATTENTE_PIECE"),
  attenteMateriel("ATTENTE_MATERIEL"),
  attenteMaterielExterne("ATTENTE_MATERIEL_EXTERNE"),
  attenteValidationIntervention("ATTENTE_VALIDATION_INTERVENTION"),
  validated("VALIDATED"),
  cancelled("CANCELLED");

  final String value;
  const InterventionStatus(this.value);
}

void _showNextPageOther(
  Visite visite,
  BuildContext context,
  String accessToken,
) async {
  // Fetch isAdmin from SharedPreferences
  bool isAdmin = await SharedPreferences.getInstance().then(
    (prefs) => prefs.getBool('isAdmin') ?? false,
  );

  // Safely check diagnostics and interventions
  final hasDiagnostics = visite.diagnostics?.isNotEmpty ?? false;
  final interventions = visite.intervention ?? [];
  final hasInterventions = interventions.isNotEmpty;

  // Helper to map string status to InterventionStatus
  InterventionStatus getInterventionStatus(String status) {
    return InterventionStatus.values.firstWhere(
      (e) => e.value == status,
      orElse: () => InterventionStatus
          .cancelled, // Default to CANCELLED for unknown statuses
    );
  }

  // Helper to assign priority to statuses (lower number = higher priority)
  int statusPriority(InterventionStatus status) {
    switch (status) {
      case InterventionStatus.attenteCommandeClient:
        return 1;
      case InterventionStatus.attenteIntervention:
        return 2;
      case InterventionStatus.ongoing:
        return 3;
      case InterventionStatus.attentePiece:
        return 4;
      case InterventionStatus.attenteMateriel:
        return 5;
      case InterventionStatus.attenteMaterielExterne:
        return 6;
      case InterventionStatus.attenteValidationIntervention:
        return 7;
      case InterventionStatus.validated:
        return 8;
      case InterventionStatus.cancelled:
        return 9;
    }
  }

  // Determine navigation based on state and status
  void navigateBasedOnStatus() {
    if (!hasInterventions && hasDiagnostics && isAdmin) {
      // Case 1: Diagnostics exist, no interventions, admin -> ValidationDiagnosticScreen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ValidationDiagnosticScreen(
            idVisite: visite.id,
            visite: visite,
            accessToken: accessToken,
          ),
        ),
      );
      return;
    } else if (!hasDiagnostics) {
      // Case 2: No diagnostics -> DiagnosticPage
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DiagnosticPage(
            idVisite: visite.id,
            visite: visite,
            accessToken: accessToken,
          ),
        ),
      );
      return;
    } else if (hasInterventions) {
      // Case 3: Interventions exist, determine dominant status
      InterventionStatus? dominantStatus;
      for (var intervention in interventions) {
        final status = getInterventionStatus(intervention.status ?? "");
        if (dominantStatus == null ||
            statusPriority(status) < statusPriority(dominantStatus)) {
          dominantStatus = status;
        }
      }
      if (isAdmin) {
        // Admins: Navigate based on dominant status
        switch (dominantStatus) {
          case InterventionStatus.attenteValidationIntervention:
            // Navigate to ValidationInterventionScreen for validation
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ValidationInterventionScreen(
                  visiteId: visite.id,
                  isAdmin: isAdmin,
                  accessToken: accessToken,
                  visite: visite,
                ),
              ),
            );
            break;
          case InterventionStatus.cancelled:
            // No action needed for validated or cancelled interventions
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  "Pas de validation nécessaire pour cette intervention.",
                ),
                duration: const Duration(seconds: 3),
              ),
            );
            break;
          case InterventionStatus.attenteCommandeClient:
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ValidationInterventionScreen(
                  visiteId: visite.id,
                  isAdmin: isAdmin,
                  accessToken: accessToken,
                  visite: visite,
                ),
              ),
            );
            break;
          default:
            // Other statuses (e.g., ATTENTE_COMMANDE_CLIENT, ATTENTE_INTERVENTION)
            // may not require admin validation
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  "Pas d'action disponible pour cette intervention.",
                ),
                duration: const Duration(seconds: 3),
              ),
            );
        }
      } else {
        // Non-admins: Navigate to InterventionPage for actionable statuses
        switch (dominantStatus) {
          case InterventionStatus.attenteIntervention:
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    InterventionPage(visite: visite, accessToken: accessToken),
              ),
            );
            break;
          case InterventionStatus.ongoing:
          case InterventionStatus.attentePiece:
          case InterventionStatus.attenteMateriel:
          case InterventionStatus.attenteMaterielExterne:
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    InterventionPage(visite: visite, accessToken: accessToken),
              ),
            );
            break;
          case InterventionStatus.attenteCommandeClient:
          case InterventionStatus.attenteValidationIntervention:
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  "Pas d'action disponible pour cette intervention.",
                ),
                duration: const Duration(seconds: 3),
              ),
            );
            break;
          case InterventionStatus.validated:
          case InterventionStatus.cancelled:
            // Non-admins can't act on these statuses
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  "Pas d'action disponible pour cette intervention.",
                ),
                duration: const Duration(seconds: 3),
              ),
            );
            break;
          case null:
            // TODO: Handle this case.
            throw UnimplementedError();
        }
      }
      return;
    }

    // Fallback: No actionable state
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Pas d'action disponible pour cette visite."),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // Execute navigation
  navigateBasedOnStatus();
}
