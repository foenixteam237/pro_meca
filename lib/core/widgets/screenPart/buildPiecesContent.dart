import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_styles.dart';
import '../../utils/responsive.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  _CategoriesPageState createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  final List<Map<String, dynamic>> categories = [
    {
      'title': 'Pièces moteurs',
      'count': 2435,
      'image': 'assets/images/v1.jpg',
    },
    {
      'title': 'Transmissions',
      'count': 1234,
      'image': 'assets/images/v1.jpg',
    },
    {
      'title': 'Freinages',
      'count': 2435,
      'image': 'assets/images/v1.jpg',
    },
    {
      'title': 'Directions et suspension',
      'count': 1234,
      'image': 'assets/images/v1.jpg',
    },
    {
      'title': 'Directions et suspension',
      'count': 1234,
      'image': 'assets/images/v1.jpg',
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSearchBar(),
              const SizedBox(height: 16),
               Text(
                'Catégories',
                style: AppStyles.titleLarge(context),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: GridView.builder(
                  itemCount: categories.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 3 / 4,
                  ),
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    return _buildCategoryCard(category);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            decoration: InputDecoration(
              hintText: 'immatriculation du véhicule',
              filled: true,
              fillColor: Colors.white,
              prefixIcon: const Icon(Icons.search, color: Colors.green),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: const BorderSide(color: Colors.green),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: const BorderSide(color: Colors.green),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Container(
          padding: const EdgeInsets.all(10),

          child: const Icon(Icons.filter_list, color: Colors.green),
        ),
      ],
    );
  }

  Widget _buildCategoryCard(Map<String, dynamic> category) {
    return GestureDetector(
      onTap: ()=> print(category['title']),
      child: Container(
        height: Responsive.responsiveValue(context, mobile: 150, tablet: 200),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.green),
          borderRadius: BorderRadius.circular(10),
          color: AppColors.background,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
              child: Image.asset(
                category['image'],
                height: Responsive.responsiveValue(context, mobile: 170, tablet: 200, desktop: 300),
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category['title'],
                    style: AppStyles.caption(context),
                    textAlign: TextAlign.start,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 5,),
                  Text('Nombre: ${category['count']}'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
