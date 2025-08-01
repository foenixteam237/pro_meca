import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pro_meca/core/constants/app_colors.dart';
import 'package:pro_meca/core/constants/app_styles.dart';
import 'package:pro_meca/core/models/modele.dart';
import 'package:pro_meca/core/utils/responsive.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../services/api_services.dart';
import '../../../widgets/shimmerRound.dart';
import 'clientVehicleFormPage.dart';

class ModelSelectionScreen extends StatefulWidget {
  final String selectedBrand; // Ajout de la marque sélectionnée
  final Function(String) onModelSelected;
  final VoidCallback onBack;
  const ModelSelectionScreen({
    super.key,
    required this.selectedBrand,
    required this.onModelSelected,
    required this.onBack,
  });
  @override
  State<ModelSelectionScreen> createState() => _ModelSelectionScreenState();
}

class _ModelSelectionScreenState extends State<ModelSelectionScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedModel;
  String? _selectedModelId;

  late List<Modele> _filteredModeles = [];
  late List<Modele> _allModeles = [];
  Timer? _debounce; // Ajout d'un Timer pour le debounce
  late String _idSelectedBrand;
  late String _accessToken;
  final apiService = ApiService();
  bool _isLoading = true;
  @override
  void initState() {
    super.initState();
    _idSelectedBrand = widget.selectedBrand;
    _filteredModeles = _allModeles;
    _loadModels();
    _searchController.addListener(_onSearchChanged);
  }

  Future<void> _loadModels() async {
    try {
      setState(() => _isLoading = true);
      final List<Modele>? models = await apiService.getModelsByBrand(
        _idSelectedBrand,
      );
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('accessToken');

      setState(() {
        _allModeles = models!;
        _filteredModeles = models;
        _accessToken = accessToken!;
        _isLoading = false;
      });
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur: ${e.toString()}')));
    }
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _filterModels();
    });
  }

  void _filterModels() {
    setState(() {
      _filteredModeles = _allModeles
          .where(
            (model) => model.name.toLowerCase().contains(
              _searchController.text.toLowerCase(),
            ),
          )
          .toList();
      print(_selectedModel);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel(); // Annuler le Timer lors de la destruction
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Ajout d'un Scaffold
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: const Text('Sélectionner un modèle')),
      body: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: Responsive.responsiveValue(
            context,
            mobile: MediaQuery.of(context).size.width * 0.05,
            tablet: MediaQuery.of(context).size.width * 0.1,
            desktop: MediaQuery.of(context).size.width * 0.2,
          ),
          vertical: 10,
        ),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                3,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 30,
                  height: 5,
                  decoration: BoxDecoration(
                    color: index < 2 ? AppColors.primary : Colors.grey[300],
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
                hintText: 'Entrer le modèle du véhicule',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
            const SizedBox(height: 16),
            // Grille des modèles
            Expanded(child: _buildModelGrid()),
            // Boutons en bas
            Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: AppColors.primary),
                        backgroundColor: AppColors.primary,
                      ),
                      child: Text(
                        'Retour',
                        style: AppStyles.buttonText(context),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _selectedModel != null
                          ? () {
                              // Ajoutez ici la logique pour passer à l'étape suivante
                              // Par exemple, appeler widget.onNext();
                              print(
                                "l'id du modèle est : $_selectedModelId et celle de la marque est : ${widget.selectedBrand}",
                              );
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => ClientVehicleFormPage(
                                    idBrand: widget.selectedBrand,
                                    idModel: _selectedModelId!,
                                  ),
                                ),
                              );
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        'Suivant',
                        style: AppStyles.buttonText(context),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(String? logo) {
    if (logo != null) {
      return Image.network(
        logo,
        headers: {'Authorization': 'Bearer $_accessToken'},
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          color: Colors.grey,
          child: const Icon(Icons.directions_car),
        ),
      );
    }

    return Image.asset(
      "assets/images/v1.jpg",
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        color: Colors.grey,
        child: const Icon(Icons.directions_car),
      ),
    );
  }

  Widget _buildModelGrid() {
    if (_isLoading) {
      return BrandShimmerWidget();
    }

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 0.8,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      itemCount: _filteredModeles.length,
      itemBuilder: (context, index) {
        final model = _filteredModeles[index];
        return GestureDetector(
          onTap: () {
            setState(() => _selectedModel = model.name);
            _selectedModelId = model.id;
            widget.onModelSelected(model.id);
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Cercle avec image du modèle
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _selectedModel == model.name
                      ? AppColors.primary
                      : Colors.grey.withOpacity(0.1),
                  border: Border.all(
                    color: _selectedModel == model.name
                        ? AppColors.primary
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: ClipOval(child: _buildImage(model.logo)),
              ),
              const SizedBox(height: 2),
              // Nom du modèle
              Text(
                model.name,
                textAlign: TextAlign.center,
                style: AppStyles.bodySmall(context),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ],
          ),
        );
      },
    );
  }
}
