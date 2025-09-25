import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../constants/app_styles.dart';
import '../../../models/dysfonctionnement.dart';

Widget buildDiagnosticCard(BuildContext context, Dysfonctionnement dys) {
  return Column(
    children: [
      Row(
        children: [
          Expanded(
            child: Text(
              'Diagnostic: ${dys.detail}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          /*Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'TECHNICIAN 1',
                              style: AppStyles.bodySmall(context),
                            ),
                          ),*/
        ],
      ),

      Text(
        'Code: ${dys.code}',
        style: AppStyles.bodySmall(
          context,
        ).copyWith(color: Colors.grey[600]),
      ),
    ],
  );
}