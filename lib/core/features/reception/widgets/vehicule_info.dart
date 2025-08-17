import 'package:flutter/material.dart';
import 'package:pro_meca/core/models/vehicle.dart';
import 'package:pro_meca/l10n/arb/app_localizations.dart';

import '../views/visiteForm.dart';

class VehicleInfoCard extends StatelessWidget {
  final Vehicle vehicle;
  final String accessToken;
  const VehicleInfoCard({super.key, required this.vehicle, required this.accessToken});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final l10n = AppLocalizations.of(context);
    return GestureDetector(
      onTap: (){
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ClientVehicleFormPage(
              idBrand: vehicle.marqueId,
              idModel: vehicle.modelId,
              vehicle: vehicle,
            ),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8, horizontal: isMobile ? 8 : 16),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                child: _buildImage(vehicle.logo)
              ),
            ),
            SizedBox(width: isMobile ? 10 : 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "${l10n.immatVehicule}: ${vehicle.licensePlate}".toUpperCase(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: isMobile ? 12 : 18,
                        ),
                        maxLines: 1,
                      ),
                      Text(
                        vehicle.color.toString(),
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: isMobile ? 12 : 14,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 2),
                  Text(
                    "${l10n.modele}: ${vehicle.chassis}",
                    style: TextStyle(fontSize: isMobile ? 12 : 16),
                  ),
                  SizedBox(height: 2),
                  Container(
                    padding: EdgeInsets.only(top: 3),
                    child: Text(
                      "${l10n.property}: ${vehicle.client?.lastName}",
                      style: TextStyle(
                        fontSize: isMobile ? 12 : 14,
                        fontWeight: FontWeight.w500,
                      ),
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

  Widget _buildImage(String? imageUrl) {
    if(imageUrl != null){
      return Image.network(imageUrl, headers:{'Authorization': 'Bearer $accessToken'},
        fit: BoxFit.cover,
      );
    }else{
      return Image.asset('assets/images/v1.jpg', fit: BoxFit.cover);
    }

  }
}
