
import 'package:flutter/material.dart';
import 'package:pro_meca/core/constants/app_adaptive_colors.dart';
import 'package:pro_meca/core/models/maintenance_task.dart';
import 'package:provider/provider.dart';

Widget interventionItem(MaintenanceTask main, BuildContext context){
  final appColors = Provider.of<AppAdaptiveColors>(context);
  return Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      border: Border.all(color: Colors.blue.shade100),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(
            "assets/images/moteur.jpg",
            width: 70,
            height: 70,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children:  [
              Text(
                main.title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              Text(
                "Priorité: ${main.priority}",
                style: TextStyle(
                  color: Colors.orange,
                  fontSize: 13,
                ),
              ),
              Text(
                "Technicien: ${main.technician}",
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
        Column(
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                //removeMainTask;
              },
              child: Icon(
                Icons.delete,
                color: AppAdaptiveColors.red_fade,
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: appColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                print(main.technician);
              },
              child: Icon(
                Icons.info,
                color: AppAdaptiveColors.red_fade,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}