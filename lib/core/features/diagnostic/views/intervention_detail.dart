import 'package:flutter/material.dart';
import 'package:pro_meca/core/constants/app_adaptive_colors.dart';
import 'package:pro_meca/core/constants/app_colors.dart';
import 'package:pro_meca/core/constants/app_styles.dart';
import 'package:pro_meca/core/models/maintenance_task.dart';
import 'package:provider/provider.dart';

class InterventionDetailPage extends StatelessWidget {
  final MaintenanceTask main;
  const InterventionDetailPage({super.key, required this.main});

  @override
  Widget build(BuildContext context) {
    final appColors = Provider.of<AppAdaptiveColors>(context);
    print(main.pieces);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: appColors.primary,
        elevation: 0,
        title: Text(
          'Détails Intervention',
          style: AppStyles.titleMedium(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Intervention
            _buildInterventionCard(context),

            const SizedBox(height: 16),

            // Section Pièces
            _buildPiecesSection(context),

            const SizedBox(height: 80), // Espace pour le bouton flottant
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: () {
            // Action pour terminer l'intervention
            _showTerminerDialog(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
          ),
          child: const Text(
            'Terminée',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  Widget _buildInterventionCard(BuildContext context) {
    Color priorityColor = _getPriorityColor(main.priority);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.customBackground(context),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Titre de l\'intervention',
                style: AppStyles.titleMedium(context),
              ),
              Text(
                'référence: ${main.reference}',
                style: AppStyles.titleMedium(context).copyWith(fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Priorité:', style: AppStyles.titleMedium(context)),
              Text(
                "priorite",
                style: AppStyles.titleMedium(
                  context,
                ).copyWith(color: priorityColor),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow('Type d\'intervention', main.typeName, context),
          const SizedBox(height: 12),
          _buildInfoRow('Sous type', main.subType, context),
          const SizedBox(height: 12),
          _buildInfoRow('Initiée le:', main.dateDebut.toString(), context),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppStyles.titleMedium(context)),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildPiecesSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.customBackground(context),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Listes des pièces',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...main.pieces!.map((piece) => _buildPieceItem(piece)),
        ],
      ),
    );
  }

  Widget _buildPieceItem(Piece piece) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  piece.name ?? 'Nom de la pièce',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  // ignore: unnecessary_null_comparison
                  'Quantité: ${piece.quantity != null ? piece.quantity.toStringAsFixed(2) : 'N/A'}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getPriorityColor(int priorite) {
    switch (priorite) {
      case 1:
        return Colors.green;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showChangerStatutDialog(BuildContext context) {
    final List<String> statuts = [
      'En cours',
      'En attente',
      'Suspendue',
      'En révision',
      'Terminée',
    ];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Changer le statut'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: statuts.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(statuts[index]),
                  leading: Radio<String>(
                    value: statuts[index],
                    groupValue:
                        null, // Vous pouvez gérer l'état sélectionné ici
                    onChanged: (String? value) {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Statut changé vers: $value'),
                          backgroundColor: Colors.orange,
                        ),
                      );
                    },
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Statut changé vers: ${statuts[index]}'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
          ],
        );
      },
    );
  }

  void _showTerminerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Terminer l\'intervention'),
          content: const Text(
            'Êtes-vous sûr de vouloir marquer cette intervention comme terminée ?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Logique pour terminer l'intervention
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Intervention marquée comme terminée'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text('Confirmer'),
            ),
          ],
        );
      },
    );
  }
}
