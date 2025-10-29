import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../l10n/arb/app_localizations.dart';
import '../../../constants/app_adaptive_colors.dart';
import '../../../constants/app_styles.dart';
import '../../../models/visite.dart';
import '../../../widgets/build_image.dart';

Widget buildVehicleInfoSection(
  BuildContext context,
  bool isMobile,
  AppAdaptiveColors appColors,
  AppLocalizations l10n,
  Visite? visite,
  String? accessToken,
) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          buildImage(visite!.vehicle!.logo, context, accessToken!),
          SizedBox(width: isMobile ? 10 : 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                "${l10n.immatVehicule}: ${visite.vehicle!.licensePlate}",
                style: AppStyles.titleMedium(context).copyWith(fontSize: 14),
              ),
              Text(
                "Entrée: ${DateFormat.yMMMd().format(visite.dateEntree)}",
                style: AppStyles.titleMedium(context).copyWith(fontSize: 12),
              ),
            ],
          ),
        ],
      ),
      Expanded(
        child: Text(
          "${visite.vehicle!.client!.firstName} ${visite.vehicle!.client!.lastName}",
          style: AppStyles.bodyMedium(context).copyWith(fontSize: 14),
          textAlign: TextAlign.right,
        ),
      ),
    ],
  );
}
