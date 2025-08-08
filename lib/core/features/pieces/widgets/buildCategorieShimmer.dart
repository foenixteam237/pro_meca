import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:pro_meca/core/utils/responsive.dart';

class CategoryCardShimmer extends StatelessWidget {
  const CategoryCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final screnHeigth = MediaQuery.of(context).size.height;
    final baseColor = isDark ? Colors.grey[800]! : Colors.grey[300]!;
    final highlightColor = isDark ? Colors.grey[700]! : Colors.grey[100]!;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Container(
        height: Responsive.responsiveValue(context, mobile: screnHeigth * 0.2, tablet: 200),
        decoration: BoxDecoration(
          border: Border.all(color: baseColor),
          borderRadius: BorderRadius.circular(10),
          color: isDark ? Colors.grey[900] : Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
              child: Container(
                height: Responsive.responsiveValue(
                  context,
                  mobile: 170,
                  tablet: 200,
                  desktop: 300,
                ),
                width: double.infinity,
                color: baseColor,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 16,
                    width: screenWidth * 0.25,
                    color: baseColor,
                  ),
                  const SizedBox(height: 5),
                  Container(
                    height: 12,
                    width: screenWidth * 0.15,
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
}