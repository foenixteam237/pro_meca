import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class VehicleInfoCardShimmer extends StatelessWidget {
  const VehicleInfoCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;

    // Couleurs adaptées au thème
    final baseColor = isDark ? Colors.grey[800]! : Colors.grey[300]!;
    final highlightColor = isDark ? Colors.grey[700]! : Colors.grey[100]!;

    return Container(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: isMobile ? 8 : 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: isDark ? Colors.grey[900] : Colors.white,
      ),
      child: Row(
        children: [
          Shimmer.fromColors(
            baseColor: baseColor,
            highlightColor: highlightColor,
            child: Container(
              width: isMobile ? screenWidth * 0.2 : 80,
              height: isMobile ? screenWidth * 0.2 : 80,
              decoration: BoxDecoration(
                color: baseColor,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          SizedBox(width: isMobile ? 10 : 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Shimmer.fromColors(
                  baseColor: baseColor,
                  highlightColor: highlightColor,
                  child: Container(
                    height: isMobile ? 14 : 18,
                    width: 120,
                    color: baseColor,
                  ),
                ),
                SizedBox(height: 2),
                Shimmer.fromColors(
                  baseColor: baseColor,
                  highlightColor: highlightColor,
                  child: Container(
                    height: isMobile ? 12 : 16,
                    width: 80,
                    color: baseColor,
                  ),
                ),
                SizedBox(height: 2),
                Shimmer.fromColors(
                  baseColor: baseColor,
                  highlightColor: highlightColor,
                  child: Container(
                    height: isMobile ? 12 : 14,
                    width: 100,
                    color: baseColor,
                  ),
                ),
              ],
            ),
          ),
          Shimmer.fromColors(
            baseColor: baseColor,
            highlightColor: highlightColor,
            child: Container(
              height: 70,
              width: 40,
              margin: EdgeInsets.only(right: 20),
              color: baseColor,
            ),
          ),
        ],
      ),
    );
  }
}