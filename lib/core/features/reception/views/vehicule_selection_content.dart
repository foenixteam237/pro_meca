import 'package:flutter/material.dart';
import 'package:pro_meca/core/constants/app_colors.dart';
import 'package:pro_meca/core/features/reception/services/reception_services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pro_meca/core/utils/responsive.dart';
import '../../../models/vehicle.dart';
import '../widgets/vehicule_inf_shimmer.dart';
import '../widgets/vehicule_info.dart';

class VehicleSelectionContent extends StatefulWidget {
  const VehicleSelectionContent({super.key});
  @override
  State<VehicleSelectionContent> createState() =>
      _VehicleSelectionContentState();
}

class _VehicleSelectionContentState extends State<VehicleSelectionContent> {
  final TextEditingController _searchController = TextEditingController();

  List<Vehicle> _vehicles = [];
  late String _accessToken;
  bool _isLoading = false;
  bool _hasSearched = false;

  @override
  void initState() {
    super.initState();
    _initAccessToken();
  }

  Future<void> _initAccessToken() async {
    final pref = await SharedPreferences.getInstance();
    _accessToken = pref.getString('accessToken') ?? '';
  }

  Future<void> _searchVehicles() async {
    final plate = _searchController.text.trim();
    if (plate.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez entrer une immatriculation.')),
      );
      return;
    }
    setState(() {
      _isLoading = true;
      _hasSearched = true;
      _vehicles = [];
    });
    try {
      // Cette méthode doit retourner une liste de véhicules correspondant à la recherche
      List<Vehicle> vehicles = await ReceptionServices().fetchVehicles(context, plate);
      setState(() => _vehicles = vehicles);
    } catch (e) {
      setState(() => _vehicles = []);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _goToAddVehicle() {
    Navigator.pushReplacementNamed(context, "/brand_picker");
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = Responsive.isDesktop(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Champ de recherche immatriculation
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _searchController,
                    onSubmitted: (_) => _searchVehicles(),
                    decoration: InputDecoration(
                      hintText: 'Entrer l\'immatriculation du véhicule...',
                      hintStyle: TextStyle(color: Theme.of(context).hintColor),
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _vehicles = [];
                            _hasSearched = false;
                          });
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
                  Icons.search,
                  color: AppColors.primary,
                  size: Responsive.responsiveValue(
                    context,
                    mobile: MediaQuery.sizeOf(context).width * 0.1,
                    tablet: MediaQuery.sizeOf(context).width * 0.2,
                    desktop: MediaQuery.sizeOf(context).width * 0.3,
                  ),
                ),
                onPressed: _isLoading ? null : _searchVehicles,
              ),
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
            const VehicleInfoCardShimmer()
          else if (!_hasSearched)
            Column(
              children: [
                const SizedBox(height: 32),
                Icon(Icons.car_repair, size: 56, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  "Veuillez entrer une immatriculation pour rechercher un véhicule.",
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
              ],
            )
          else if (_vehicles.isEmpty)
              Column(
                children: [
                  const Icon(Icons.directions_car_filled, size: 48, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'Aucun véhicule trouvé',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _goToAddVehicle,
                    child: const Text('Ajouter un nouveau véhicule'),
                  ),
                ],
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _vehicles.length,
                itemBuilder: (context, index) {
                  return VehicleInfoCard(vehicle: _vehicles[index], accessToken: _accessToken);
                },
              ),
        ],
      ),
    );
  }
}