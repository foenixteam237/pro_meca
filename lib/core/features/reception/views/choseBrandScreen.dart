import 'package:flutter/material.dart';
import 'package:pro_meca/core/constants/app_colors.dart';
import 'package:pro_meca/core/constants/app_styles.dart';
import 'package:pro_meca/core/models/brand.dart';
import 'package:pro_meca/core/utils/responsive.dart';
import 'package:pro_meca/services/dio_api_services.dart';

import '../../../widgets/shimmerRound.dart';
import 'ModelSelectedScreen.dart'; // Ajoutez cette dépendance dans pubspec.yaml

class BrandPickerScreen extends StatefulWidget {
  final Function(String selectedBrand) onBrandSelected;

  const BrandPickerScreen({super.key, required this.onBrandSelected});

  @override
  State<BrandPickerScreen> createState() => _BrandPickerScreenState();
}

class _BrandPickerScreenState extends State<BrandPickerScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sélection de la marque')),
      body: BrandPickerWidget(onBrandSelected: widget.onBrandSelected),
    );
  }
}

class BrandPickerWidget extends StatefulWidget {
  final Function(String selectedBrand) onBrandSelected;

  const BrandPickerWidget({super.key, required this.onBrandSelected});

  @override
  State<BrandPickerWidget> createState() => _BrandPickerWidgetState();
}

class _BrandPickerWidgetState extends State<BrandPickerWidget> {
  String? _selectedBrand;
  Brand? _selectedBrandObject;
  final TextEditingController _searchController = TextEditingController();
  List<Brand> _filteredBrand = [];
  List<Brand> _brands = [];
  final apiService = ApiDioService();
  bool _isLoading = true;

  Future<void> _loadBrands() async {
    try {
      setState(() => _isLoading = true);

      final List<Brand> brands = await apiService.getAllBrands();

      setState(() {
        _brands = brands;
        _filteredBrand = _brands;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur: ${e.toString()}')));
    }
  }

  @override
  void initState() {
    super.initState();
    _loadBrands();
    _searchController.addListener(_filterBrands);
  }

  void _filterBrands() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredBrand = _brands
          .where((brand) => brand.name.toLowerCase().contains(query))
          .toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildBrandGrid() {
    if (_isLoading) {
      print("En cours de chargement");
      return BrandShimmerWidget();
    }

    return GridView.builder(
      itemCount: _filteredBrand.length,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.8,
      ),
      itemBuilder: (context, index) {
        final brand = _filteredBrand[index];
        final isSelected = _selectedBrand == brand.name;
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedBrand = brand.name;
              _selectedBrandObject = brand;
              widget.onBrandSelected(brand.name);
            });
          },
          child: Column(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: isSelected
                    ? AppColors.primary
                    : Colors.grey[300],
                child:
                    brand.logoUrl.toString().isNotEmpty && brand.logoUrl != null
                    ? Image.network(
                        brand.logoUrl.toString(),
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            Icon(Icons.directions_car),
                      )
                    : Image.asset(
                        'assets/images/welcome_image.png',
                        fit: BoxFit.fill,
                      ),
              ),
              const SizedBox(height: 4),
              Text(
                brand.name,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.responsiveValue(
          context,
          mobile: MediaQuery.of(context).size.width * 0.05,
          tablet: MediaQuery.of(context).size.width * 0.1,
          desktop: MediaQuery.of(context).size.width * 0.2,
        ),
        vertical: 30,
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          // Indicateur de progression
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              3,
              (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: 30,
                height: 5,
                decoration: BoxDecoration(
                  color: index < 1 ? AppColors.primary : Colors.grey[300],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('Choisir la marque', style: AppStyles.titleMedium(context)),
          const SizedBox(height: 12),
          // Champ de recherche
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Entrer la marque',
              prefixIcon: const Icon(Icons.search),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Grille des marques avec Shimmer
          Expanded(
            child: SizedBox(
              height: Responsive.responsiveValue(
                context,
                mobile: 500,
                tablet: 600,
                desktop: 800,
              ),
              child: _buildBrandGrid(),
            ),
          ),
          const SizedBox(height: 16),
          // Boutons bas
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    backgroundColor: AppColors.primary,
                    side: BorderSide(color: AppColors.primary),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: Text('Retour', style: AppStyles.buttonText(context)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedBrandObject?.name != null
                        ? AppColors.primary
                        : Colors.grey,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: _selectedBrandObject?.name != null && !_isLoading
                      ? () {
                          print(_selectedBrandObject?.id);
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ModelSelectionScreen(
                                selectedBrand: _selectedBrandObject!.id,
                                onModelSelected: (model) {
                                  print(model);
                                },
                                onBack: () => Navigator.pop(context),
                              ),
                            ),
                          );
                        }
                      : null,
                  child: Text(
                    'Suivant',
                    style: AppStyles.buttonText(
                      context,
                    ).copyWith(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
