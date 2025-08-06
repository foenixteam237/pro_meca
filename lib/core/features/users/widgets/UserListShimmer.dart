import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class UserListShimmer extends StatelessWidget {
  const UserListShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final itemCount = 8;

    return Shimmer.fromColors(
      baseColor: isDarkMode ? Colors.grey[800]! : Colors.grey[300]!,
      highlightColor: isDarkMode ? Colors.grey[700]! : Colors.grey[100]!,
      period: const Duration(milliseconds: 1500),
      child: ListView.separated(
        padding: const EdgeInsets.all(8),
        itemCount: itemCount,
        separatorBuilder: (_, __) => Divider(
          color: isDarkMode ? Colors.grey[800] : Colors.grey[300],
          height: 1,
        ),
        itemBuilder: (context, index) {
          return ListTile(
            leading: _ShimmerBox(
              width: 48,
              height: 48,
              shape: BoxShape.circle,
              isDarkMode: isDarkMode,
            ),
            title: Align(
              alignment: Alignment.centerLeft,
              child: _ShimmerBox(
                width: 120,
                height: 14,
                isDarkMode: isDarkMode,
              ),
            ),
            subtitle: Align(
              alignment: Alignment.centerLeft,
              child: _ShimmerBox(
                width: 80,
                height: 12,
                isDarkMode: isDarkMode,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final BoxShape shape;
  final bool isDarkMode;

  const _ShimmerBox({
    required this.width,
    required this.height,
    this.shape = BoxShape.rectangle,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[800] : Colors.grey[300],
        shape: shape,
        borderRadius: shape == BoxShape.rectangle
            ? BorderRadius.circular(4)
            : null,
        boxShadow: [
          if (isDarkMode)
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 2,
            ),
        ],
      ),
    );
  }
}