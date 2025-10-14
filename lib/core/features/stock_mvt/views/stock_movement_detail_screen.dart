// stock_movement_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:pro_meca/core/models/stock_movement.dart';

class StockMovementDetailScreen extends StatelessWidget {
  final StockMovement movement;

  const StockMovementDetailScreen({super.key, required this.movement});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Détail Mouvement')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard('Pièce', [
              _buildInfoRow('Nom', movement.piece.name),
              _buildInfoRow('Référence', movement.piece.reference),
              _buildInfoRow('Catégorie', movement.piece.category),
            ]),

            const SizedBox(height: 16),

            _buildInfoCard('Mouvement', [
              _buildInfoRow(
                'Type',
                movement.typeLabel,
                valueColor: movement.typeColor,
              ),
              _buildInfoRow('Quantité', movement.quantity.toString()),
              _buildInfoRow('Date', _formatDate(movement.date)),
              _buildInfoRow(
                'Prix de vente',
                '${movement.sellingPriceAtMovement} FCFA',
              ),
              _buildInfoRow(
                'Solde après mouvement',
                movement.stockAfterMovement.toString(),
              ),
            ]),

            if (movement.description != null) ...[
              const SizedBox(height: 16),
              _buildInfoCard('Description', [Text(movement.description!)]),
            ],

            if (movement.facture != null) ...[
              const SizedBox(height: 16),
              _buildInfoCard('Facture associée', [
                _buildInfoRow('Référence', movement.facture!.reference),
                _buildInfoRow('Client', movement.facture!.client.fullName),
                _buildInfoRow('Date', _formatDate(movement.facture!.date)),
              ]),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w500)),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: valueColor),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
