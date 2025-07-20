import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../l10n/arb/app_localizations.dart';
import '../constants/app_colors.dart';

Widget ongoingVehicleCard({required String date, required String status, required BuildContext context}) {
  final l10n = AppLocalizations.of(context);
  final screenWidth = MediaQuery.of(context).size.width;
  final isMobile = screenWidth < 600;

  return Container(
    margin: EdgeInsets.symmetric(vertical: 8, horizontal: isMobile ? 8 : 16),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12),

    ),
    child: Row(
      children: [
        Container(
          width: isMobile ? screenWidth * 0.2 : 80,
          height: isMobile ? screenWidth * 0.2 : 80,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10),
              bottomLeft: Radius.circular(10),
            ),
            child: Image.asset('assets/images/v1.jpg', fit: BoxFit.cover),
          ),
        ),
        SizedBox(width: isMobile ? 10 : 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "N0567AZ",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: isMobile ? 16 : 18,
                ),
              ),
              SizedBox(height: 2),
              Text(
                "Toyota Corolla LE",
                style: TextStyle(
                  fontSize: isMobile ? 12 : 16,
                ),
              ),
              SizedBox(height: 8),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),

                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: isMobile ? 12 : 14,
                    color: _getStatusColor(status, l10n),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          height: 70,
          padding: EdgeInsets.only(right: 20),
          alignment: Alignment.topRight,
          child: Text(
            date,
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: isMobile ? 12 : 14,
            ),
          ),
        ),
      ],
    ),
  );
}

Color _getStatusColor(String status, AppLocalizations l10n) {
  if (status.contains(l10n.diagnostic)) {
    return AppColors.alert;
  } else if (status.contains(l10n.validation)) {
    return AppColors.secondary;
  } else {
    return AppColors.primary;
  }
}

