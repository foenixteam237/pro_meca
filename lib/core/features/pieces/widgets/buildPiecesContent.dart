import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  List<PieceCategorie> categorie = [];
  List<PieceCategorie> filteredCategorie = [];
  bool _isLoading = false;
  String _accessToken = "";
  String _searchText = "";

  @override
  void initState() {
    super.initState();
    _loadCategorie();
    _getToken();
  }

  Future<void> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString('accessToken')!;
  }

  Future<void> _loadCategorie() async {
    setState(() => _isLoading = true);
    try {
      categorie = await PiecesService().fetchPieceCategories(context);
      _filterCategories();
    } catch (e) {
      print(e);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _filterCategories() {
    setState(() {
      if (_searchText.isEmpty) {
        filteredCategorie = List.from(categorie);
      } else {
        filteredCategorie = categorie
            .where((cat) =>
        cat.name.toLowerCase().contains(_searchText.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final displayList = _isLoading
        ? List.generate(4, (index) => null)
        : filteredCategorie;

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
                  itemCount: displayList.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 3 / 4,
                  ),
                  itemBuilder: (context, index) {
                    if (_isLoading) {
                      return const CategoryCardShimmer();
                    } else if (filteredCategorie.isNotEmpty) {
                      final category = displayList[index];
                      return CategoryCard(
                        category: category!,
                        getToken: _accessToken,
                      );
                    } else {
                      // Gérer le cas où la liste est vide
                      return const Center(child: Text("Aucune catégorie disponible"));
                    }
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
              hintText: 'Nom catégorie',
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
            onChanged: (value) {
              _searchText = value;
              _filterCategories();
            },
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