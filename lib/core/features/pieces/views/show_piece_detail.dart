import 'package:flutter/material.dart';
import 'package:pro_meca/core/models/pieces.dart';

void showPieceBottomSheet(BuildContext context, Piece piece) {
  int newQuantity = piece.stock;
  final TextEditingController quantityController =
  TextEditingController(text: piece.stock.toString());

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
                  child: Image.asset(
                    "assets/images/moteur.jpg",
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 180,
                      color: Colors.grey[200],
                      child: const Icon(Icons.inventory, size: 48),
                    ),
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
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).hintColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          piece.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
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
                        Text(
                          "Stock: ${piece.stock}",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // TITRE NOUVELLE QUANTITÉ
                const Text(
                  "NOUVELLE QUANTITÉ",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),

                // TEXTFIELD POUR EDITER LA QUANTITÉ
                TextField(
                  controller: quantityController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    contentPadding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
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

                const SizedBox(height: 12),

                // BOUTONS + / -
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _roundActionButton(
                      icon: Icons.remove,
                      color: Colors.red.shade100,
                      iconColor: Colors.red.shade800,
                      onTap: () {
                        if (newQuantity > 0) {
                          setState(() {
                            newQuantity--;
                            quantityController.text = newQuantity.toString();
                          });
                        }
                      },
                    ),
                    const SizedBox(width: 32),
                    _roundActionButton(
                      icon: Icons.add,
                      color: Colors.green.shade100,
                      iconColor: Colors.green.shade800,
                      onTap: () {
                        setState(() {
                          newQuantity++;
                          quantityController.text = newQuantity.toString();
                        });
                      },
                    ),
                  ],
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
                        onPressed: () {
                          Navigator.pop(context, newQuantity);
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Theme.of(context).primaryColor,
                        ),
                        child: const Text("METTRE À JOUR"),
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

// Bouton rond réutilisable
Widget _roundActionButton({
  required IconData icon,
  required Color color,
  required Color iconColor,
  required VoidCallback onTap,
}) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(50),
    child: Container(
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      padding: const EdgeInsets.all(8),
      child: Icon(icon, color: iconColor),
    ),
  );
}

// Couleur selon état
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

// Format texte état
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
