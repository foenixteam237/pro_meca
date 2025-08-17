import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../constants/app_adaptive_colors.dart';
import '../../../constants/app_styles.dart';
import '../../../models/piecesCategorie.dart';
import '../services/pieces_services.dart';
import '../widgets/buildCategorieCard.dart';
import '../widgets/buildCategorieShimmer.dart';
import '../../../utils/responsive.dart';

class CategoriesPage extends StatefulWidget {
  final BuildContext parentContext;
  const CategoriesPage({super.key, required this.parentContext});
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
    _getToken().then((_) => _loadCategorie());
  }

  Future<void> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString('accessToken') ?? '';
  }

  Future<void> _loadCategorie() async {
    setState(() => _isLoading = true);
    try {
      categorie = await PiecesService().fetchPieceCategories(context);
      _filterCategories();
    } catch (e) {
      debugPrint(e.toString());
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
    final displayList =
    _isLoading ? List.generate(4, (index) => null) : filteredCategorie;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(
            Responsive.responsiveValue(context, mobile: 12, tablet: 24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSearchBar(context),
              const SizedBox(height: 16),
              Text('Catégories', style: AppStyles.titleLarge(context)),
              const SizedBox(height: 12),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // Détermine dynamiquement le nombre de colonnes
                    int crossAxisCount = 2;
                    double width = constraints.maxWidth;

                    if (width >= 1200) {
                      crossAxisCount = 5;
                    } else if (width >= 900) {
                      crossAxisCount = 4;
                    } else if (width >= 600) {
                      crossAxisCount = 3;
                    }

                    return GridView.builder(
                      itemCount: displayList.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
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
                            pContext: widget.parentContext,
                            category: category!,
                            getToken: _accessToken,
                          );
                        } else {
                          return const Center(
                              child: Text("Aucune catégorie disponible"));
                        }
                      },
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

  Widget _buildSearchBar(BuildContext context) {
    final appColors =  Provider.of<AppAdaptiveColors>(context);
    return Row(
      children: [
        Expanded(
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Nom catégorie',
              filled: true,
              suffixIcon:  Icon(Icons.search, color: appColors.primary),
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
          child:  Icon(Icons.filter_list, color: appColors.primary),
        ),
      ],
    );
  }
}
