import 'package:flutter/material.dart';
import 'package:pro_meca/core/constants/app_colors.dart';
import 'package:pro_meca/core/constants/app_styles.dart';
import 'package:pro_meca/core/utils/responsive.dart';

class BrandPickerWidget extends StatefulWidget {
  final Function(String selectedBrand) onBrandSelected;

  const BrandPickerWidget({
    super.key,
    required this.onBrandSelected,
  });

  @override
  State<BrandPickerWidget> createState() => _BrandPickerWidgetState();
}

class _BrandPickerWidgetState extends State<BrandPickerWidget> {
  String? _selectedBrand;
  final TextEditingController _searchController = TextEditingController();
  List<String> _filteredBrands = [];
  final List<String> _allBrands = List.generate(25, (index) => 'Mitsubishi');

  @override
  void initState() {
    super.initState();
    _filteredBrands = _allBrands;
    _searchController.addListener(_filterBrands);
  }

  void _filterBrands() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredBrands = _allBrands.where((brand) =>
          brand.toLowerCase().contains(query)
      ).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.responsiveValue(
          context,
          mobile: MediaQuery.of(context).size.width * 0.04,
          tablet: MediaQuery.of(context).size.width * 0.1,
          desktop: MediaQuery.of(context).size.width * 0.2,
        ),
        vertical: Responsive.responsiveValue(context, mobile: MediaQuery.of(context).size.height * 0.02 ),
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Indicateur de progression
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              4,
                  (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: 30,
                height: 5,
                decoration: BoxDecoration(
                  color: index < 1
                      ? AppColors.primary
                      : Colors.grey[300],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Choisir la marque',
            style: AppStyles.titleMedium(context),
          ),
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

          // Grille des marques
          SizedBox(
            height: Responsive.responsiveValue(
                context,
                mobile: 400,
                tablet: 600,
                desktop: 800
            ),
            child: GridView.builder(
              itemCount: _filteredBrands.length,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemBuilder: (context, index) {
                final brand = _filteredBrands[index];
                final isSelected = _selectedBrand == brand;

                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedBrand = brand);
                    widget.onBrandSelected(brand);
                  },
                  child: CircleAvatar(
                    radius: 30,
                    backgroundColor: isSelected
                        ? AppColors.primary
                        : Colors.grey[300],
                    child: Image.asset(
                      'assets/images/welcome_image.png',
                      fit: BoxFit.fill,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          // Boutons bas
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: BorderSide(color: AppColors.primary),
                    backgroundColor: AppColors.primary
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Retour',
                    style: AppStyles.buttonText(context)?.copyWith(
                      color: Colors.white
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedBrand != null
                        ? AppColors.primary
                        : Colors.grey,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: _selectedBrand != null
                      ? () {
                    Navigator.pop(context);
                  }
                      : null,
                  child: Text(
                    'Suivant',
                    style: AppStyles.buttonText(context)?.copyWith(
                      color: Colors.white,
                    ),
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