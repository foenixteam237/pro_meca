import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

Widget buildPieceItemShimmer(BuildContext context) {
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;

  // Couleurs adaptées au thème avec plus de contraste
  final baseColor = isDark ? Colors.grey.shade800 : Colors.grey.shade300;
  final highlightColor = isDark ? Colors.grey.shade600 : Colors.grey.shade100;
  final shimmerDuration = const Duration(milliseconds: 1200); // Animation plus rapide

  return Shimmer.fromColors(
    baseColor: baseColor,
    highlightColor: highlightColor,
    period: shimmerDuration,
    direction: ShimmerDirection.ltr, // Direction gauche à droite
    child: Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.dividerColor.withOpacity(0.3)),
        color: theme.cardColor,
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image placeholder avec effet de contour
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: baseColor,
                borderRadius: BorderRadius.circular(8),
              ),
            ),

            const SizedBox(width: 12),

            // Contenu texte
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Première ligne (nom + condition)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        height: 18,
                        width: 120,
                        decoration: BoxDecoration(
                          color: baseColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      Container(
                        height: 16,
                        width: 70,
                        decoration: BoxDecoration(
                          color: baseColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Deuxième ligne (stock)
                  Row(
                    children: [
                      Container(
                        height: 16,
                        width: 24,
                        decoration: BoxDecoration(
                          color: baseColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        height: 16,
                        width: 60,
                        decoration: BoxDecoration(
                          color: baseColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}