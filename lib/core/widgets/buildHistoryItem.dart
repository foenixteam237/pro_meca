import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../constants/app_colors.dart';
import '../constants/app_styles.dart';
import '../features/reception/views/diagnosticScreen.dart';
import '../models/visite.dart';
import '../utils/responsive.dart';

Widget buildHistoryItem(Visite visite, BuildContext context, String accessToken) {
  final isMobile = Responsive.isMobile(context);
  final screenWidth = MediaQuery.of(context).size.width;
  return GestureDetector(
    onTap: (){
      _showNextPage(visite, context, accessToken);
    },
    child: Container(
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
              child:_buildImage(visite.vehicle?.logo, accessToken),
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
Widget _buildImage(String? imageUrl, String accessToken) {
  if(imageUrl != null){
    return Image.network(imageUrl, headers:{'Authorization': 'Bearer $accessToken'},
      fit: BoxFit.cover,
    );
  }else{
    return Image.asset('assets/images/v1.jpg', fit: BoxFit.cover);
  }

}
void _showNextPage(Visite visite,BuildContext context, String accessToken){
  switch(visite.status){
    case "ATTENTE_DIAGNOSTIC":
      Navigator.push(context, MaterialPageRoute(builder: (context) => DiagnosticPage(idVisite:  visite.id, visite: visite, accessToken: accessToken,))); {}
      break;
    case "ATTENTE_INTERVENTION":
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Véhicule en attente intervention!")),
      );
      break;
    case "ATTENTE_VALIDATION_DIAGNOSTIC":
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Véhicule en attente validation diagnostic!")),
      );
      break;
    default:
      break;
  }
}
Color _visitColor(String status) {
  switch(status){
    case "ATTENTE_DIAGNOSTIC":
      return AppColors.alert;
    case "ATTENTE_INTERVENTION":
      return Colors.blue;
    case "ATTENTE_VALIDATION_DIAGNOSTIC":
      return Colors.orange;
    case "TERMINE":
      return Colors.green;
    default:
      return Colors.blueAccent;
  }
}
