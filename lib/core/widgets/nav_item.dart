import 'package:flutter/material.dart';

class NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  const NavItem({required this.icon, required this.label, super.key});
  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {},
      icon: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 22),
          Text(label, style: const TextStyle(fontSize: 10)),
        ],
      ),
    );
  }
}
