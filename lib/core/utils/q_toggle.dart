import 'package:flutter/material.dart';

class QToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final String label;
  final Color activeColor;
  final Color? inactiveColor;

  const QToggle({
    super.key,
    required this.value,
    required this.onChanged,
    required this.label,
    this.activeColor = Colors.green,
    this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final inactive =
        inactiveColor ?? theme.colorScheme.onSurface.withOpacity(0.38);

    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Étiquette à droite
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: value ? activeColor : theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(width: 12),

          // Toggle personnalisé
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 48,
            height: 28,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: value
                  ? activeColor.withOpacity(0.3)
                  : inactive.withOpacity(0.12),
            ),
            child: Stack(
              alignment: value ? Alignment.centerRight : Alignment.centerLeft,
              children: [
                // Bouton circulaire
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: value ? activeColor : inactive,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
