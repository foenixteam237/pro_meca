import 'package:flutter/material.dart';

class AppColors {

  static const Color primary = Color.fromARGB(
    255,
    98,
    173,
    101,
  ); // Vert professionnel
  static const Color secondary = Color(0xFF2E5AAC); // Bleu
  static const Color alert = Color(0xFFF44336); // Rouge
  static const Color red_fade = Color(0xFFFDF5F5);
  static const Color background = Color(0xFFFFFFFF); // Blanc
  static const Color text = Color(0xDE000000); // Noir 87%

  // Couleur dynamique qui suit le thème
  static Color customBackground(BuildContext context) {
    return Theme.of(context).scaffoldBackgroundColor;
  }

  // Texte adaptatif
  static Color customText(BuildContext context) {
    return Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;
  }
  // Ajoutez d'autres couleurs au besoin
}
