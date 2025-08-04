import 'package:flutter/material.dart';
class UserListShimmer extends StatelessWidget {
  const UserListShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final itemCount = 8;
    return ListView.separated(
      itemCount: itemCount,
      separatorBuilder: (_, __) => const Divider(color: Colors.grey, height: 1),
      itemBuilder: (context, index) {
        return ListTile(
          leading: ShimmerBox(width: 48, height: 48, shape: BoxShape.circle),
          title: Align(
            alignment: Alignment.centerLeft,
            child: ShimmerBox(width: 120, height: 14),
          ),
          subtitle: Align(
            alignment: Alignment.centerLeft,
            child: ShimmerBox(width: 80, height: 12),
          ),
        );
      },
    );
  }
}
class ShimmerBox extends StatefulWidget {
  final double width;
  final double height;
  final BoxShape shape;

  const ShimmerBox({super.key, required this.width, required this.height, this.shape = BoxShape.rectangle});

  @override
  State<ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<ShimmerBox> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 1200), vsync: this)..repeat(reverse: true);
    _colorAnimation = ColorTween(begin: Colors.grey[300], end: Colors.grey[100]).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _colorAnimation,
      builder: (_, __) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: _colorAnimation.value,
          shape: widget.shape,
          borderRadius: widget.shape == BoxShape.rectangle ? BorderRadius.circular(8) : null,
        ),
      ),
    );
  }
}