import 'package:flutter/material.dart';
import 'package:pro_meca/core/constants/app_styles.dart';
import 'package:pro_meca/core/features/visites/services/reception_services.dart';
import 'package:provider/provider.dart';

import '../constants/app_adaptive_colors.dart';
import '../features/visites/widgets/vehicule_inf_shimmer.dart';
import '../models/visite.dart';
import 'buildHistoryItem.dart';

class HistoryList extends StatelessWidget {
  final List<Visite> visites;
  final bool isLoading;
  final VoidCallback? onVoirPlus;
  final String accessToken;
  final BuildContext contextParent;
  final String title;

  const HistoryList({
    super.key,
    required this.title,
    required this.visites,
    required this.isLoading,
    required this.accessToken,
    required this.contextParent,
    this.onVoirPlus,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = Provider.of<AppAdaptiveColors>(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(top: 20, bottom: 4),
            child: Row(
              children: [
                Text(title, style: AppStyles.titleMedium(context)),
                const Spacer(),
                GestureDetector(
                  onTap: onVoirPlus,
                  child: Text(
                    "Voir plus",
                    style: TextStyle(color: appColors.primary),
                  ),
                ),
              ],
            ),
          ),
        ],
        if (isLoading)
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: Column(
              children: List.generate(
                10,
                (_) => const VehicleInfoCardShimmer(),
              ),
            ),
          )
        else if (visites.isEmpty)
          const Padding(
            padding: EdgeInsets.all(20.0),
            child: Center(child: Text("Aucune visite trouvée.")),
          )
        else
          ...visites.map(
            (v) => Dismissible(
              key: ValueKey(
                v.id,
              ), // ⚠️ Utilise un identifiant unique de ta visite
              direction: DismissDirection
                  .endToStart, // ou DismissDirection.horizontal pour les deux côtés
              background: Container(
                color: Colors.red,
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              confirmDismiss: (direction) async {
                // Optionnel : demander confirmation avant suppression
                return await showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text("Confirmer la suppression"),
                    content: const Text(
                      "Voulez-vous vraiment supprimer cette visite ?",
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(false),
                        child: const Text("Annuler"),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(true),
                        child: const Text("Supprimer"),
                      ),
                    ],
                  ),
                );
              },
              onDismissed: (direction) async {
                // Ici tu appelles ton API / Provider pour supprimer la visite
                // Exemple :
                // context.read<VisiteProvider>().deleteVisite(v.id, accessToken);
                await ReceptionServices().deleteVisite(v.id);
                // ignore: use_build_context_synchronously
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      "Visite du véhicule immatriculé ${v.vehicle!.licensePlate} a été supprimée avec succès.",
                    ),
                  ),
                );
              },
              child: buildHistoryItem(v, contextParent, accessToken),
            ),
          ),
      ],
    );
  }
}
