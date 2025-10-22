import 'package:flutter/material.dart';
import 'package:pro_meca/core/constants/app_styles.dart';
import 'package:pro_meca/core/utils/responsive.dart';
import '../../../models/categories.dart';
import '../views/liste_pieces_screen.dart';

class CategoryCard extends StatelessWidget {
  final PieceCategorie category;
  final String? getToken;
  final BuildContext pContext;
  final Function(PieceCategorie) onEdit;
  final Function(PieceCategorie) onDelete;

  const CategoryCard({
    super.key,
    required this.category,
    this.getToken,
    required this.pContext,
    required this.onEdit,
    required this.onDelete,
  });

  void _showDeleteConfirmation(BuildContext context) {
    if (category.count > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Impossible de supprimer: ${category.count} pièce(s) associée(s)",
          ),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirmer la suppression"),
          content: Text(
            "Êtes-vous sûr de vouloir supprimer la catégorie \"${category.name}\" ?",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onDelete(category);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Supprimer'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final double imageHeight = Responsive.responsiveValue(
      context,
      mobile: height * 0.17,
      tablet: 180,
      desktop: 220,
    );

    final double paddingValue = Responsive.responsiveValue(
      context,
      mobile: 10,
      tablet: 14,
      desktop: 16,
    );

    final TextStyle titleStyle = AppStyles.caption(context).copyWith(
      fontSize: Responsive.responsiveValue(
        context,
        mobile: 14,
        tablet: 16,
        desktop: 18,
      ),
    );

    final TextStyle bodyStyle = AppStyles.bodySmall(context).copyWith(
      fontSize: Responsive.responsiveValue(
        context,
        mobile: 12,
        tablet: 14,
        desktop: 16,
      ),
    );

    return GestureDetector(
      onTap: () {
        Navigator.push(
          pContext,
          MaterialPageRoute(
            builder: (pContext) => PiecesPage(catId: category.id),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          children: [
            Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Image Section
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                  child: category.logo.isNotEmpty
                      ? Image.network(
                          category.logo,
                          headers: {'Authorization': 'Bearer $getToken'},
                          height: imageHeight,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (
                                BuildContext context,
                                Object error,
                                StackTrace? stackTrace,
                              ) {
                                debugPrint(error.toString());
                                return Image.asset(
                                  'assets/images/v1.jpg',
                                  height: imageHeight,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                );
                              },
                        )
                      : Image.asset(
                          'assets/images/v1.jpg',
                          height: imageHeight,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                ),

                /// Text Section
                Padding(
                  padding: EdgeInsets.all(paddingValue),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// Title and Count
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              category.name.toUpperCase(),
                              style: titleStyle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: category.count == 0
                                  ? Colors.grey.shade300
                                  : Colors.lightBlue.shade50,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${category.count} pièce(s)',
                              style: bodyStyle.copyWith(
                                color: category.count == 0
                                    ? Colors.grey.shade600
                                    : Colors.deepPurpleAccent,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      /// Description
                      Text(
                        category.description,
                        style: bodyStyle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            /// Menu contextuel pour éditer/supprimer
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_vert,
                    size: 20,
                    color: Colors.grey.shade700,
                  ),
                  onSelected: (value) {
                    if (value == 'edit') {
                      onEdit(category);
                    } else if (value == 'delete') {
                      _showDeleteConfirmation(context);
                    }
                  },
                  itemBuilder: (BuildContext context) => [
                    PopupMenuItem<String>(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(
                            Icons.edit,
                            size: 20,
                            color: Colors.blue.shade600,
                          ),
                          const SizedBox(width: 8),
                          const Text('Modifier'),
                        ],
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'delete',
                      enabled: category.count == 0,
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete,
                            size: 20,
                            color: category.count == 0
                                ? Colors.red.shade600
                                : Colors.grey.shade400,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Supprimer',
                            style: TextStyle(
                              color: category.count == 0
                                  ? Colors.red.shade600
                                  : Colors.grey.shade400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            /// Badge "Vide" si aucune pièce
            if (category.count == 0)
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.shade300),
                  ),
                  child: Text(
                    'Vide',
                    style: bodyStyle.copyWith(
                      color: Colors.orange.shade800,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
