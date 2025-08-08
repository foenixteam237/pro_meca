import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../utils/responsive.dart';

Widget buildSmallCardShimmer(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final baseColor = isDark ? Colors.grey[800]! : Colors.grey[300]!;
  final highlightColor = isDark ? Colors.grey[700]! : Colors.grey[100]!;

  return Shimmer.fromColors(
    baseColor: baseColor,
    highlightColor: highlightColor,
    period: const Duration(milliseconds: 1500),
    child: Container(
      width: Responsive.responsiveValue(
        context,
        mobile: MediaQuery.of(context).size.width * 0.45,
        tablet: MediaQuery.of(context).size.width * 0.22,
      ),
      constraints: const BoxConstraints(
        minHeight: 100,
        maxHeight: 120,
      ),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ligne icône + titre
          Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: baseColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  height: Responsive.responsiveValue(
                    context,
                    mobile: 14,
                    tablet: 16,
                  ),
                  decoration: BoxDecoration(
                    color: baseColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Ligne "Ce jour"
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 40,
                height: 12,
                color: baseColor,
              ),
              Container(
                width: 20,
                height: 12,
                color: baseColor,
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Ligne "Ce mois"
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 40,
                height: 12,
                color: baseColor,
              ),
              Container(
                width: 20,
                height: 12,
                color: baseColor,
              ),
            ],
          ),
          const Spacer(),
          // Ligne "Total"
          Align(
            alignment: Alignment.centerRight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 40,
                  height: 18,
                  color: baseColor,
                ),
                Container(
                  width: 30,
                  height: 18,
                  color: baseColor,
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}