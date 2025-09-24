import 'package:flutter/material.dart';
import 'package:pro_meca/core/constants/app_adaptive_colors.dart';
import 'package:pro_meca/core/features/pieces/views/piece_detail_screen.dart';
import 'package:pro_meca/services/dio_api_services.dart';
import 'package:provider/provider.dart';
import '../../../constants/app_styles.dart';
import '../../../models/pieces.dart';

Widget buildPieceItems(
  Piece piece,
  BuildContext context,
  int index, {
  VoidCallback? onPieceUpdated,
}) {
  final appColor = Provider.of<AppAdaptiveColors>(context);
  final theme = Theme.of(context);

  return Container(
    margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
    decoration: BoxDecoration(
      color: theme.cardColor,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                PieceDetailScreen(piece: piece, onPieceUpdated: onPieceUpdated),
          ),
        ),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Image de la pièce avec badge de stock
              Stack(
                children: [
                  _buildPieceImage(piece, context),
                  if (piece.stock <= (piece.criticalStock ?? 0))
                    Positioned(
                      top: -4,
                      right: -4,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.warning,
                          color: Colors.white,
                          size: 12,
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(width: 16),

              // Informations principales
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Première ligne : Nom + État
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            piece.name,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _buildConditionBadge(piece.condition, context),
                      ],
                    ),

                    const SizedBox(height: 6),

                    // Deuxième ligne : Référence
                    Text(
                      piece.reference,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.hintColor,
                        fontSize: 13,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Troisième ligne : Stock + Prix
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Stock
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: piece.inStock!
                                    ? Colors.green
                                    : Colors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${piece.stock} en stock',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: piece.inStock!
                                    ? Colors.green
                                    : Colors.red,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),

                        // Prix
                        if (piece.sellingPrice != null)
                          Text(
                            '${piece.sellingPrice!.toStringAsFixed(0)} FCFA',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: appColor.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    ),

                    // Quatrième ligne : Localisation si disponible
                    if (piece.location != null && piece.location!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Row(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              size: 12,
                              color: theme.hintColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              piece.location!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.hintColor,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),

              // Flèche indicateur
              const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
            ],
          ),
        ),
      ),
    ),
  );
}

Widget _buildPieceImage(Piece piece, BuildContext context) {
  return Container(
    width: 60,
    height: 60,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(10),
      color: Colors.grey[100],
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: piece.logo!.isNotEmpty
          ? Image.network(
              piece.logo!,
              headers: {
                'Authorization': 'Bearer ${ApiDioService().getAuthHeaders()}',
              },
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                        : null,
                    strokeWidth: 2,
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) =>
                  _buildPlaceholderImage(),
            )
          : _buildPlaceholderImage(),
    ),
  );
}

Widget _buildPlaceholderImage() {
  return Container(
    color: Colors.grey[200],
    child: const Icon(Icons.inventory_2, color: Colors.grey, size: 30),
  );
}

Widget _buildConditionBadge(String condition, BuildContext context) {
  final Map<String, Map<String, dynamic>> conditionStyles = {
    'NEW': {'color': Colors.green, 'text': 'NEUF', 'icon': Icons.new_releases},
    'USED_GOOD': {
      'color': Colors.blue,
      'text': 'OCCASION - EE',
      'icon': Icons.thumb_up,
    },
    'USED_WORN': {
      'color': Colors.orange,
      'text': 'OCCASION - UN',
      'icon': Icons.autorenew,
    },
    'USED_DAMAGED': {
      'color': Colors.red,
      'text': 'OCCASION - AR',
      'icon': Icons.build,
    },
    'UNKNOWN': {
      'color': Colors.grey,
      'text': 'NON VÉRIFIÉ',
      'icon': Icons.help_outline,
    },
  };

  final style = conditionStyles[condition] ?? conditionStyles['UNKNOWN']!;

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: style['color'] as Color,
      borderRadius: BorderRadius.circular(6),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(style['icon'] as IconData, size: 12, color: Colors.white),
        const SizedBox(width: 4),
        Text(
          style['text'] as String,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );
}
