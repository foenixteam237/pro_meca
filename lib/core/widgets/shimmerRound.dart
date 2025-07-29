import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class BrandShimmerWidget extends StatelessWidget {
  final int itemCount;
  final Axis scrollDirection;

  const BrandShimmerWidget({
    super.key,
    this.itemCount = 20,
    this.scrollDirection = Axis.vertical,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final baseColor = isDarkMode ? Colors.grey[700]! : Colors.grey[300]!;
    final highlightColor = isDarkMode ? Colors.grey[500]! : Colors.grey[100]!;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: GridView.builder(
        itemCount: itemCount,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.8,
        ),
        itemBuilder: (context, index) {
          return Column(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: 60,
                height: 10,
                color: Colors.white,
              ),
            ],
          );
        },
      ),
    );
  }
}
