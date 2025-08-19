import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

Future<ImageSource?> showImageSourceDialog(BuildContext context) {
  return showDialog<ImageSource>(
    context: context,
    builder: (context) => AlertDialog(
      actionsAlignment: MainAxisAlignment.center,
      title: Center(
        child: Text(
          'Choisir une source d\'image',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, ImageSource.camera),
          child: const Text('Caméra'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, ImageSource.gallery),
          child: const Text('Galerie'),
        ),
      ],
    ),
  ).catchError((error) {
    // Gérer l'erreur ici si nécessaire
    print('Erreur lors de l\'affichage du dialogue : $error');
  });
}
