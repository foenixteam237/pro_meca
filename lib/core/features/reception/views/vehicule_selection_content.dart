import 'package:flutter/material.dart';
import 'package:pro_meca/core/constants/app_colors.dart';
import 'package:pro_meca/core/features/reception/services/reception_services.dart';
import 'package:pro_meca/core/features/reception/views/choseBrandScreen.dart';
import 'package:pro_meca/core/models/vehicle.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';
import 'package:pro_meca/core/utils/responsive.dart';
import '../widgets/vehicule_inf_shimmer.dart';
import '../widgets/vehicule_info.dart';
import 'dart:async';

class VehicleSelectionContent extends StatefulWidget {
  const VehicleSelectionContent({super.key});
  @override
  State<VehicleSelectionContent> createState() =>
      _VehicleSelectionContentState();
}

class _VehicleSelectionContentState extends State<VehicleSelectionContent> {
  final TextEditingController _searchController = TextEditingController();

  List<Vehicle> vehicles = [];
  List<Vehicle> _filteredVehicle = [];

  bool _isLoading = false;
  Timer? _debounce;
  @override
  void initState() {
    super.initState();
    _loadVehicles();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _loadVehicles() async {
    setState(() => _isLoading = true);
    try {
      vehicles = await ReceptionServices().fetchVehicles(context);

      _filteredVehicle = vehicles;

    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur: ${e.toString()}')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _searchVehicles(_searchController.text);
    });
  }

  void _searchVehicles(String query) {
    final lowerCaseQuery = query.toLowerCase();

    _filteredVehicle = vehicles.where((vehicle) {
      final plate = vehicle.licensePlate.toString().toLowerCase();
      final propertyName = vehicle.client?.firstName.toString().toLowerCase();
      final propertyLast = vehicle.client?.lastName.toString().toLowerCase();

      return plate.contains(lowerCaseQuery) ||
          propertyName!.contains(lowerCaseQuery) ||
          propertyLast!.contains(lowerCaseQuery);
    }).toList();
    setState(() {});
  }

  void _showAddVehicleDialog() {
    String selectedBrand = '';
    String selectedModel = '';
    final clientInfoFormKey = GlobalKey<FormState>();
    final vehicleDetailsFormKey = GlobalKey<FormState>();

    WoltModalSheet.show(
      context: context,
      pageListBuilder: (modalContext) => [
        // Étape 1: Choix de la marque
        WoltModalSheetPage(
          topBarTitle: const Text('Choisir la marque'),
          trailingNavBarWidget: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(modalContext),
          ),
          child: BrandPickerWidget(
            onBrandSelected: (brand) {
              selectedBrand = brand;
            },
          ),
        ),
      ],
      modalTypeBuilder: (context) {
        final screenWidth = MediaQuery.of(context).size.width;
        return screenWidth > 700
            ? WoltModalType.dialog()
            : WoltModalType.dialog();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    print('Step 4 building ');
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Rechercher un véhicule...',
                      hintStyle: TextStyle(color: Theme.of(context).hintColor),
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          _searchController.clear();
                          _searchVehicles('');
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 2),
              IconButton(
                icon: Icon(
                  Icons.add,
                  color: AppColors.primary,
                  size: Responsive.responsiveValue(
                    context,
                    mobile: MediaQuery.sizeOf(context).width * 0.1,
                    tablet: MediaQuery.sizeOf(context).width * 0.2,
                    desktop: MediaQuery.sizeOf(context).width * 0.3,
                  ),
                ),
                onPressed: () {
                  //_showAddVehicleDialog();
                  // Redirige vers l'écran de sélection de marque
                  Navigator.pushReplacementNamed(context, "/brand_picker");
                },
              ),
            ],
          ),
          SizedBox(
            height: Responsive.responsiveValue(context, mobile: 0, tablet: 10),
          ),
          if (_isLoading)
            Column(
              children: List.generate(
                6, // nombre de shimmer cards à afficher
                    (index) => const VehicleInfoCardShimmer(),
              ),
            )
          else if (_filteredVehicle.isEmpty)
            Column(
              children: [
                const Icon(Icons.car_repair, size: 48, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  _searchController.text.isEmpty
                      ? 'Aucun véhicule enregistré'
                      : 'Aucun véhicule trouvé',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: ()=>
                      Navigator.pushReplacementNamed(context, "/brand_picker"),
                  child: const Text('Ajouter un nouveau véhicule'),
                ),
              ],
            )
          else
            ListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: _filteredVehicle.map((vehicle) {
                return VehicleInfoCard(vehicle: vehicle);
              }).toList(),
            ),
        ],
      ),
    );
  }
}
