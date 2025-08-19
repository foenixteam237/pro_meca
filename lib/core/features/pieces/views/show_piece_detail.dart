import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:pro_meca/core/constants/app_adaptive_colors.dart';
import 'package:pro_meca/core/constants/app_styles.dart';
import 'package:pro_meca/core/models/pieces.dart';
import 'package:pro_meca/core/utils/responsive.dart';

import '../services/pieces_services.dart';

void showPieceBottomSheet(
  BuildContext context,
  Piece piece,
  AppAdaptiveColors appColor,
) {
  int newQuantity = piece.stock;
  final TextEditingController quantityController = TextEditingController(
    text: piece.stock.toString(),
  );
  bool isLoading = false; // Nouvelle variable d'état
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              left: 15,
              right: 15,
              top: 10,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // IMAGE AVEC BORDERS RADIUS EN HAUT
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                  child: piece.logo!.isNotEmpty
                      ? Image.network(
                          piece.logo!,
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            height: 180,
                            color: Colors.grey[200],
                            child: const Icon(Icons.inventory, size: 48),
                          ),
                        )
                      : Image.asset(
                          'assets/images/moteur.jpg',
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                ),
                const SizedBox(height: 16),
                // INFORMATIONS PRINCIPALES
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Catégorie: ${piece.category.name.toUpperCase()}",
                          style: AppStyles.bodyMedium(
                            context,
                          ).copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        Text(piece.name, style: AppStyles.bodySmall(context)),
                      ],
                    ),
                    Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getConditionColor(piece.condition),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _formatCondition(piece.condition),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 4,
                            ),
                            child: Text(
                              "Stock: ${piece.stock}",
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // TITRE NOUVELLE QUANTITÉ
                const Center(
                  child: Text(
                    "NOUVELLE QUANTITÉ",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // TEXTFIELD POUR EDITER LA QUANTITÉ
                Center(
                  child: SizedBox(
                    width: Responsive.responsiveValue(
                      context,
                      mobile: MediaQuery.of(context).size.width * 0.5,
                      tablet: 200,
                    ),
                    child: TextField(
                      controller: quantityController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 8,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          newQuantity = int.tryParse(value) ?? newQuantity;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                // ACTIONS
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(
                            color: Theme.of(context).dividerColor,
                          ),
                        ),
                        child: const Text("ANNULER"),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          setState(() {
                            isLoading = true; // Démarrer le chargement
                          });
                          if (await updatePiece(
                            newQuantity,
                            piece.id,
                            context,
                          )) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: appColor.primary,
                                content: Text(
                                  "Quantité mise à jour avec succès!!!!!",
                                  style: AppStyles.bodyMedium(context),
                                ),
                              ),
                            );
                            Navigator.pop(context);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "Impossible de modifier la pièce.",
                                ),
                              ),
                            );
                          }
                          setState(() {
                            isLoading = false; // Arrêter le chargement
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: appColor.primary,
                        ),
                        child: isLoading
                            ? SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                "METTRE À JOUR",
                                style: TextStyle(color: Colors.white),
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

Future<bool> updatePiece(int qte, String id, BuildContext context) async {
  try {
    final formData = FormData();
    Map<String, dynamic> pieceData = {"stock": qte};

    formData.fields.add(MapEntry('data', jsonEncode(pieceData)));
    return await PiecesService().updatePiece(id, formData, context);
  } catch (e) {
    print(e);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Impossible de modifier la pièce. $e}")),
    );
    return false;
  }
}

// Couleur selon état (inchangé)
Color _getConditionColor(String condition) {
  switch (condition) {
    case 'NEW':
      return Colors.green;
    case 'USED_GOOD':
      return Colors.blue;
    case 'USED_WORN':
      return Colors.orange;
    case 'USED_DAMAGED':
      return Colors.red;
    default:
      return Colors.grey;
  }
}

// Format texte état (inchangé)
String _formatCondition(String condition) {
  switch (condition) {
    case 'NEW':
      return 'NEUF';
    case 'USED_GOOD':
      return 'OCCASION - EE';
    case 'USED_WORN':
      return 'OCCASION - UN';
    case 'USED_DAMAGED':
      return 'OCCASION - AR';
    default:
      return condition;
  }
}
