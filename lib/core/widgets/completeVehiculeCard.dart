
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pro_meca/l10n/arb/app_localizations.dart';
import '../constants/app_colors.dart';

Widget completedVehicleCard(BuildContext context) {
  final l10n = AppLocalizations.of(context);
  final screenWidth = MediaQuery.of(context).size.width;

  return Container(
    width: screenWidth * 0.4, // 40% de la largeur d'écran
    constraints: const BoxConstraints(maxWidth: 200), // Largeur max
    margin: EdgeInsets.only(right: screenWidth * 0.03),
    padding: EdgeInsets.all(screenWidth * 0.02),
    decoration: BoxDecoration(
      border: Border.all(color: AppColors.primary),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          'assets/images/welcome_image.png',
          width: screenWidth * 0.08, // 8% de la largeur
          height: screenWidth * 0.08,
        ),
        SizedBox(height: screenWidth * 0.02),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "N0567AZ",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: screenWidth * 0.035, // 3.5% de la largeur
              ),
            ),
            Text(
              "Model: COROLLA LE",
              style: TextStyle(fontSize: screenWidth * 0.03),
            ),
            SizedBox(height: screenWidth * 0.02),
          ],
        ),
        Text(
          l10n.seeInvoice,
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
            fontSize: screenWidth * 0.03,
          ),
        ),
      ],
    ),
  );
}
