import 'package:flutter/material.dart';

import '../../../constants/app_styles.dart';
import '../../../utils/responsive.dart';

Widget buildProblemReportedSection(BuildContext context, TextEditingController problemReportedController ) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        "Problème signalé par le client",
        style: AppStyles.titleLarge(context),
      ),
      const SizedBox(height: 8),
      _buildMultilineInput(
        controller: problemReportedController,
        hint: "Exemple(Fumée blanche.........)",
        readOnly: true, // Rendre en lecture seule
        context: context,
      ),
    ],
  );
}

Widget _buildMultilineInput({
  required String hint,
  required TextEditingController controller,
  bool readOnly = false,
  required BuildContext context,
}) {
  return Container(
    height: Responsive.responsiveValue(
      context,
      mobile: MediaQuery.of(context).size.height * 0.2,
    ),
    padding: const EdgeInsets.all(5),
    child: TextField(
      controller: controller,
      maxLines: 5,
      readOnly: readOnly,
      decoration: InputDecoration(
        hintText: hint,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.green.withOpacity(0.1)),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.grey),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
  );
}

