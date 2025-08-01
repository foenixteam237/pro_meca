import 'package:flutter/material.dart';
import '../../../constants/app_styles.dart';
import '../../../models/piecesCategorie.dart';
import '../services/pieces_services.dart';
import 'buildCategorieCard.dart';
import 'buildCategorieShimmer.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});
  @override
  _CategoriesPageState createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  final List<Map<String, dynamic>> categories = [
    {'title': 'Pièces moteurs', 'count': 2435, 'image': 'assets/images/v1.jpg'},
    {'title': 'Transmissions', 'count': 1234, 'image': 'assets/images/v1.jpg'},
    {'title': 'Freinages', 'count': 2435, 'image': 'assets/images/v1.jpg'},
    {
      'title': 'Directions et suspension',
      'count': 1234,
      'image': 'assets/images/v1.jpg',
    },
    {
      'title': 'Directions et suspension',
      'count': 1234,
      'image': 'assets/images/v1.jpg',
    },
  ];
  List<PieceCategorie> categorie = [];
  bool _isLoading = false;
  @override
  void initState() {
    super.initState();
    _loadCategorie();
  }

  Future<void> _loadCategorie() async {
    setState(() => _isLoading = true);
    try {
      categorie = await PiecesService().fetchPieceCategories(context);
    } catch (e) {
      print(e);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSearchBar(),
              const SizedBox(height: 16),
              Text('Catégories', style: AppStyles.titleLarge(context)),
              const SizedBox(height: 12),
              Expanded(
                child: GridView.builder(
                  itemCount: _isLoading ? 4 : categorie.length, // Corrigé ici
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 3 / 4,
                  ),
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    return _isLoading
                        ? CategoryCardShimmer()
                        : CategoryCard(
                            category: category,
                            onTap: () => print("object"),
                          );
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
              suffixIcon: const Icon(Icons.search, color: Colors.green),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: const BorderSide(color: Colors.grey),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: const BorderSide(color: Colors.grey),
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
}
