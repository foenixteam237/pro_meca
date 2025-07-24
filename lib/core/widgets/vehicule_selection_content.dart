import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:pro_meca/core/constants/app_colors.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';
import 'package:pro_meca/core/utils/responsive.dart';
import 'vehicule_info.dart';
import 'dart:async';

class VehicleSelectionContent extends StatefulWidget {
  const VehicleSelectionContent({super.key});
  @override
  State<VehicleSelectionContent> createState() =>
      _VehicleSelectionContentState();
}

class _VehicleSelectionContentState extends State<VehicleSelectionContent> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _vehicles = [];
  List<Map<String, dynamic>> _filteredVehicles = [];
  bool _isLoading = false;
  Timer? _debounce;
  @override
  void initState() {
    super.initState();
    _loadVehicles();
    print("Step3");
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
      final response = {
        'data': [
          {
            'id': 1,
            'marque': 'MAZDA',
            'type': 'Voiture',
            'modele': 'CX-5',
            'immatriculation': '1234ABC',
            'proprietaire': 'John Doe',
          },
          {
            'id': 2,
            'marque': 'HONDA',
            'type': 'Moto',
            'modele': 'CBR500R',
            'immatriculation': '5678DEF',
            'proprietaire': 'Jane Smith',
          },
          {
            'id': 3,
            'marque': 'TOYOTA',
            'type': 'Camion',
            'modele': 'Hilux',
            'immatriculation': '9101GHI',
            'proprietaire': 'Alice Johnson',
          },
          {
            'id': 2,
            'marque': 'HONDA',
            'type': 'Moto',
            'modele': 'CBR500R',
            'immatriculation': '5678DEF',
            'proprietaire': 'Jane Smith',
          },
          {
            'id': 3,
            'marque': 'TOYOTA',
            'type': 'Camion',
            'modele': 'Hilux',
            'immatriculation': '9101GHI',
            'proprietaire': 'Alice Johnson',
          },
        ],
      };
      _vehicles = List<Map<String, dynamic>>.from(response['data']!);
      _filteredVehicles = _vehicles;
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
    _filteredVehicles = _vehicles.where((vehicle) {
      final plate = vehicle['immatriculation']?.toString().toLowerCase() ?? '';
      final brand = vehicle['marque']?.toString().toLowerCase() ?? '';
      final model = vehicle['modele']?.toString().toLowerCase() ?? '';
      return plate.contains(lowerCaseQuery) ||
          brand.contains(lowerCaseQuery) ||
          model.contains(lowerCaseQuery);
    }).toList();
    setState(() {});
  }

  void _showAddVehicleDialog() {
    WoltModalSheet.show(
      context: context,
      pageListBuilder: (modalSheetContext) => [
        WoltModalSheetPage(
          topBarTitle: const Text('Ajouter un véhicule'),
          child: const Center(child: Text("Pas disponible pour le moment")),
          stickyActionBar: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Annuler'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      await _loadVehicles();
                    },
                    child: const Text('Enregistrer'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
      modalTypeBuilder: (context) {
        final screenWidth = MediaQuery.of(context).size.width;
        return screenWidth > 700
            ? WoltModalType.alertDialog()
            : WoltModalType.alertDialog();
      },
      onModalDismissedWithBarrierTap: () => Navigator.pop(context),
    );
  }

  @override
  Widget build(BuildContext context) {
    print('Step 4 building ');
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
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
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
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
                  _showAddVehicleDialog();
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_filteredVehicles.isEmpty)
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
                  onPressed: _showAddVehicleDialog,
                  child: const Text('Ajouter un nouveau véhicule'),
                ),
              ],
            )
          else
            Container(
              child: ListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: _filteredVehicles.map((vehicle) {
                  return VehicleInfoCard(vehicle: vehicle);
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}
