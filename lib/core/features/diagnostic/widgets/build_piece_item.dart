import 'package:flutter/material.dart';
import 'package:pro_meca/core/constants/app_adaptive_colors.dart';
import 'package:pro_meca/services/dio_api_services.dart';
import 'package:provider/provider.dart';
import '../../../constants/app_styles.dart';
import '../../../models/pieces.dart';

Widget buildPieceItems(Map<String, dynamic> piece, BuildContext context) {
  final appColor = Provider.of<AppAdaptiveColors>(context);
  return GestureDetector(
    //onTap: () => showPieceBottomSheet(context, piece, appColor),
    child: Container(
      margin: const EdgeInsets.symmetric(vertical: 1, horizontal: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: appColor.primary.withOpacity(0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            // Image de la pièce
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: piece['name'].isNotEmpty
                  ? Image.network(
                      piece['name'],
                      headers: {
                        'Authorization':
                            'Bearer ${ApiDioService().getAuthHeaders()}',
                      },
                      width: 75,
                      height: 75,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          'assets/images/moteur.jpg',
                          width: 75,
                          height: 75,
                          fit: BoxFit.cover,
                        ),
                      ),
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image(
                        image: AssetImage('assets/images/moteur.jpg'),
                        width: 75,
                        height: 75,
                        fit: BoxFit.cover,
                      ),
                    ),
            ),

            const SizedBox(width: 12),

            // Infos (nom + quantité + en stock)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(piece['name'], style: AppStyles.bodyLarge(context)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text("Ref:", style: AppStyles.titleMedium(context)),
                      SizedBox(width: 5),
                      Text(
                        piece['reference'].toString(),
                        style: AppStyles.bodyMedium(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text("Quantité:", style: AppStyles.titleMedium(context)),
                      SizedBox(width: 5),
                      Text(
                        piece['quantity'].toString(),
                        style: AppStyles.bodyMedium(context),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget conditionSet(String condition, BuildContext context) {
  switch (condition) {
    case 'NEW':
      return Text("Neuf", style: AppStyles.bodySmall(context));
    case 'USED_GOOD':
      return Text("Occasion - EE", style: AppStyles.bodySmall(context));
    case 'USED_WORN':
      return Text("Occasion - UN", style: AppStyles.bodySmall(context));
    case 'USED_DAMAGED':
      return Text("Occasion - AR", style: AppStyles.bodySmall(context));
    case 'UNKNOWN':
      return Text("Inconnu", style: AppStyles.bodySmall(context));
    default:
      return Text("Inconnu", style: AppStyles.bodySmall(context));
  }
}
