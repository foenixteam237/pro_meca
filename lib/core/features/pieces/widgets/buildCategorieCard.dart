import 'package:flutter/material.dart';
import 'package:pro_meca/core/constants/app_styles.dart';
import 'package:pro_meca/core/utils/responsive.dart';

import '../../../models/piecesCategorie.dart';

class CategoryCard extends StatelessWidget {
  final PieceCategorie category;
  final String? getToken;
  const CategoryCard({super.key, required this.category, this.getToken});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return GestureDetector(
      onTap: () {},
      child: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
              child: Image.network(
                category.logo,
                headers: {'Authorization': 'Bearer $getToken'},
                height: Responsive.responsiveValue(
                  context,
                  mobile: height * 0.18,
                  tablet: 200,
                  desktop: 300,
                ),
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
                        'assets/images/v1.jpg', // Remplacez par le chemin de votre image par défaut
                        height: Responsive.responsiveValue(
                          context,
                          mobile: height * 0.18,
                          tablet: 200,
                          desktop: 300,
                        ),
                        width: double.infinity,
                        fit: BoxFit.cover,
                      );
                    },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${category.name}".toUpperCase(),
                        style: AppStyles.caption(context),
                        textAlign: TextAlign.start,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: height * 0.03),
                      Text('Nombre: ${category.count['pieces']}'),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "${category.description}",
                    style: AppStyles.bodySmall(context),
                    textAlign: TextAlign.start,
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
