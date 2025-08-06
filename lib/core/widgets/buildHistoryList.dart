import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pro_meca/core/constants/app_styles.dart';
import 'package:provider/provider.dart';

import '../constants/app_adaptive_colors.dart';
import '../constants/app_colors.dart';
import '../features/reception/widgets/vehicule_inf_shimmer.dart';
import '../models/visite.dart';
import '../utils/responsive.dart';

class HistoryList extends StatelessWidget {
  final List<Visite> visites;
  final bool isLoading;
  final VoidCallback? onVoirPlus;
  final BuildContext context;
  final String accessToken;
  final String title;

  const HistoryList({
    super.key,
    required this.title,
    required this.visites,
    required this.isLoading,
    required this.context,
    required this.accessToken,
    this.onVoirPlus,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = Provider.of<AppAdaptiveColors>(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                  style: TextStyle(
                    color: appColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
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
          ...visites.map((v) => _buildHistoryItem(v)), // À compléter
      ],
    );
  }

  Widget _buildHistoryItem(Visite visite) {
    final isMobile = Responsive.isMobile(context);
    final screenWidth = MediaQuery.of(context).size.width;
    return Container(
      width: double.infinity,
      height: isMobile ? screenWidth * 0.23 : 80,
      margin: const EdgeInsets.symmetric( vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: isMobile ? screenWidth * 0.2 : 80,
            height: isMobile ? screenWidth * 0.23 : 80,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
            child: ClipRRect(borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10),
              bottomLeft: Radius.circular(10),
            ),
              child:_buildImage(visite.vehicle?.logo),
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
                      style: AppStyles.titleMedium(context).copyWith(
                          fontSize: 14
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Text(DateFormat.yMMMd().format(visite.dateEntree), style: const TextStyle(fontSize: 12)),
                    )
                  ],
                ),
                Text("Propriètaire: ${visite.vehicle?.client?.firstName ?? ""}", style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: isMobile ? 12 : 18,
                ),
                  maxLines: 1,
                ),
                const SizedBox(height: 4),
                Text(
                  _statut(visite.status),
                  style: TextStyle(fontSize: 13, color: _visitColor(visite.status)),
                ),
              ],
            ),
          ),

        ],
      ),
    );
  }
  String _statut(String statut){
    switch(statut){
      case 'ATTENTE_DIAGNOSTIC':
        return "Diagnostic";
      case 'ATTENTE_VALIDATION_DIAGNOSTIC':
        return "Attente validation diagnostic";
      case 'ATTENTE_INTERVENTION':
        return "Attente intervention";
      case 'ATTENTE_PIECE':
        return "Attente pièces";
      default:
        return "Element externe";
    }
  }
  Widget _buildImage(String? imageUrl) {
    if(imageUrl != null){
      return Image.network(imageUrl, headers:{'Authorization': 'Bearer $accessToken'},
        fit: BoxFit.cover,
      );
    }else{
      return Image.asset('assets/images/v1.jpg', fit: BoxFit.cover);
    }

  }
  Color _visitColor(String status) {
    switch(status){
      case "ATTENTE_DIAGNOSTIC":
        return AppColors.alert;
      case "ATTENTE_INTERVENTION":
        return Colors.green;
      default:
        return Colors.white;
    }
  }

}