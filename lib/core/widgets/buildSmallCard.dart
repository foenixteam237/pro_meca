import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/app_adaptive_colors.dart';
import '../constants/app_styles.dart';
import '../utils/responsive.dart';

Widget buildSmallCard(
  BuildContext context, {
  required IconData icon,
  required String title,
  required int today,
  required int month,
  required int total,
}) {
  final appColors = Provider.of<AppAdaptiveColors>(context);
  final height = MediaQuery.of(context).size.height;
  return Container(
    width: Responsive.responsiveValue(
      context,
      mobile: MediaQuery.of(context).size.width * 0.45,
      tablet: MediaQuery.of(context).size.width * 0.22,
    ),
    constraints: const BoxConstraints(minHeight: 100, maxHeight: 120),
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      border: Border.all(color: Colors.grey.withOpacity(0.3)),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // En-tête avec icône et titre
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: appColors.primary, size: 28),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: Responsive.responsiveValue(
                    context,
                    mobile: 12,
                    tablet: 14,
                  ),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),

        //const SizedBox(height: 20),
        /*
          // Compteur "Aujourd'hui" avec animation
          _buildAnimatedCounterRow(
            label: "Ce jour",
            value: today,
            textStyle: const TextStyle(fontSize: 12),
          ),

          //const SizedBox(height: 10),

          // Compteur "Ce mois" avec animation
          _buildAnimatedCounterRow(
            label: "Ce mois",
            value: month,
            textStyle: const TextStyle(fontSize: 12),
          ),
            */
        // Compteur "Total" avec animation plus visible
        SizedBox(height: height <= 600 ? height * 0.02 : height * 0.002),
        Expanded(
          child: _buildAnimatedCounterRow(
            label: "Total",
            value: total,
            textStyle: height <= 600
                ? AppStyles.titleMedium(
                    context,
                  ).copyWith(fontSize: height * 0.02)
                : AppStyles.titleMedium(
                    context,
                  ).copyWith(fontSize: height * 0.03),
            valueStyle: height <= 600
                ? AppStyles.titleMedium(context)
                : AppStyles.titleMedium(context).copyWith(fontSize: 24),
            duration: const Duration(milliseconds: 1500),
          ),
        ),
        Icon(Icons.navigate_next_rounded, size: 34, color: appColors.primary),
      ],
    ),
  );
}

Widget _buildAnimatedCounterRow({
  required String label,
  required int value,
  TextStyle? textStyle,
  TextStyle? valueStyle,
  Duration duration = const Duration(milliseconds: 1000),
}) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: textStyle),
        Expanded(
          child: TweenAnimationBuilder<int>(
            tween: IntTween(begin: 0, end: value),
            duration: duration,
            builder: (context, value, child) {
              return Text('$value', style: valueStyle ?? textStyle);
            },
            curve: Curves.easeOut,
          ),
        ),
      ],
    ),
  );
}
