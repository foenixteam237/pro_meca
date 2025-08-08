import 'package:flutter/material.dart';
import 'package:pro_meca/core/constants/app_styles.dart';
import 'package:provider/provider.dart';

import '../constants/app_adaptive_colors.dart';
import '../features/reception/widgets/vehicule_inf_shimmer.dart';
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
        if(title.isNotEmpty) ...[Padding(
          padding: const EdgeInsets.only(top: 20, bottom: 4),
          child: Row(
            children: [
              Text(title, style: AppStyles.titleMedium(context)),
              const Spacer(),
              GestureDetector(
                onTap: onVoirPlus,
                child: Text(
                  "Voir plus",
                  style: TextStyle(
                    color: appColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),],
        if (isLoading)
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: Column(
              children: List.generate(10, (_) => const VehicleInfoCardShimmer()),
            ),
          )
        else if (visites.isEmpty)
          const Padding(
            padding: EdgeInsets.all(20.0),
            child: Center(child: Text("Aucune visite trouvée.")),
          )
        else
          ...visites.map((v) => buildHistoryItem(v, contextParent, accessToken)), // À compléter
      ],
    );
  }
}