import 'package:flutter/material.dart';
import 'package:pro_meca/core/constants/app_styles.dart';
import 'package:pro_meca/core/utils/responsive.dart';
import '../../../models/piecesCategorie.dart';
import '../views/liste_pieces_screen.dart';

class CategoryCard extends StatelessWidget {
  final PieceCategorie category;
  final String? getToken;
  final BuildContext pContext;

  const CategoryCard({super.key, required this.category, this.getToken, required this.pContext});

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
        Navigator.push(pContext, MaterialPageRoute(builder: (pContext) => PiecesPage( catId: category.id,)));
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Image Section
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              child: Image.network(
                category.logo,
                headers: {'Authorization': 'Bearer $getToken'},
                height: imageHeight,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (
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
                      Text(
                        'Nombre: ${category.count['pieces']}',
                        style: bodyStyle,
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
      ),
    );
  }
}
