import 'package:flutter/material.dart';
import 'package:pro_meca/l10n/arb/app_localizations.dart';

class VehicleInfoCard extends StatelessWidget {
  final Map<String, dynamic> vehicle;

  const VehicleInfoCard({super.key, required this.vehicle});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final l10n = AppLocalizations.of(context);
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: isMobile ? 8 : 16),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Container(
            width: isMobile ? screenWidth * 0.2 : 80,
            height: isMobile ? screenWidth * 0.2 : 80,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
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
                  "${l10n.immatVehicule}: ${vehicle['immatriculation']}",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: isMobile ? 14 : 18,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  "${l10n.modele}: ${vehicle['modele']}",
                  style: TextStyle(fontSize: isMobile ? 12 : 16),
                ),
                SizedBox(height: 2),
                Container(
                  padding: EdgeInsets.only(top: 3),
                  child: Text(
                    "${l10n.property}: ${vehicle['proprietaire']}",
                    style: TextStyle(
                      fontSize: isMobile ? 12 : 14,
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
              vehicle['type'].toString(),
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
}
