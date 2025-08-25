import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class DiagnosticRowShimmer extends StatelessWidget {
  const DiagnosticRowShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Couleurs adaptées au thème
    final isDark = theme.brightness == Brightness.dark;
    final baseColor = isDark ? Colors.grey[700]! : Colors.grey[300]!;
    final highlightColor = isDark ? Colors.grey[500]! : Colors.grey[100]!;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0, top: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Champ Code erreur (placeholder)
          Expanded(
            flex: 2,
            child: Shimmer.fromColors(
              baseColor: baseColor,
              highlightColor: highlightColor,
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  color: baseColor,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          ),

          const SizedBox(width: 10),

          // Champ Détails du diagnostic (placeholder)
          Expanded(
            flex: 5,
            child: Shimmer.fromColors(
              baseColor: baseColor,
              highlightColor: highlightColor,
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  color: baseColor,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
