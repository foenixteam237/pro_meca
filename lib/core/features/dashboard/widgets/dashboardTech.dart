import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pro_meca/core/utils/responsive.dart';
import 'package:pro_meca/core/widgets/buildHistoryList.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../l10n/arb/app_localizations.dart';
import '../../../constants/app_adaptive_colors.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_styles.dart';
import '../../../models/visite.dart';
import '../../reception/services/reception_services.dart';
import '../../reception/widgets/vehicule_inf_shimmer.dart';

class VehicleDashboardPage extends StatefulWidget {
  const VehicleDashboardPage({super.key});

  @override
  State<VehicleDashboardPage> createState() => _VehicleDashboardPageState();
}

class _VehicleDashboardPageState extends State<VehicleDashboardPage> {
  List<Visite> _visites = [];
  bool _isLoading = true;
  String accessToken = "";
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final pref = await SharedPreferences.getInstance();
      accessToken = pref.getString("accessToken") ?? "";
      final visites = await ReceptionServices().fetchVisitesWithVehicle();
      setState(() {
        _visites = visites;
        _isLoading = false;
      });
    } catch (e, stack) {
      // Affiche une erreur (ex: snackbar) ou log
      print("Erreur lors du chargement des visites: $e");
      print(stack);
      setState(() {
        _visites = [];
        _isLoading = false;
      });
    }
  }

  Widget _buildSearchBar(BuildContext context) {
    final appColors = Provider.of<AppAdaptiveColors>(context);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Immatriculation du véhicule',
          prefixIcon: Icon(Icons.search, color: appColors.primary),
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(color: Colors.grey),
          ),
        ),
      ),
    );
  }

  Widget _buildEntryBanner(BuildContext context) {
    final appColors = Provider.of<AppAdaptiveColors>(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Text(
            "Véhicules entrés depuis le",
            style: AppStyles.titleLarge(context),
          ),
          const Spacer(),
          Text(
            "01/01/2025",
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: appColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCardWithImage(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              "https://tmna.aemassets.toyota.com/is/image/toyota/toyota/vehicles/2025/crownsignia/gallery/CRS_MY25_0011_V001_desktop.png?fmt=jpeg&fit=crop&qlt=90&wid=1024",
              height: 60,
              width: 60,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              AppLocalizations.of(context).waitingDiagnotics,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          const Text(
            "12",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallCard(
      BuildContext context, {
        required IconData icon,
        required String title,
        required int today,
        required int month,
        required int total,
      }) {
    final appColors = Provider.of<AppAdaptiveColors>(context);
    return Container(
      width: Responsive.responsiveValue(
        context,
        mobile: MediaQuery.of(context).size.width * 0.45,
        tablet: MediaQuery.of(context).size.width * 0.22,
      ),
      constraints: const BoxConstraints(
        minHeight: 100,
        maxHeight: 120,
      ),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: appColors.primary, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: Responsive.responsiveValue(
                      context,
                      mobile: 12,
                      tablet: 14,
                    ),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Ce jour", style: TextStyle(fontSize: 12)),
              Text('$today', style: const TextStyle(fontSize: 12)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Ce mois", style: TextStyle(fontSize: 12)),
              Text("$month", style: const TextStyle(fontSize: 12)),
            ],
          ),
          const Spacer(),
          Align(
            alignment: Alignment.centerRight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Total", style: TextStyle(fontSize: 18)),
                Text(
                  "$total",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusGrid(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _buildSmallCard(
            context,
            icon: Icons.access_time_outlined,
            title: AppLocalizations.of(context).waitingValidationDiagnostic,
            today: 10,
            month: 5,
            total: 17,
          ),
          _buildSmallCard(
            context,
            icon: Icons.rule_folder_outlined,
            title: AppLocalizations.of(context).waitingValidation,
            today: 20,
            month: 3,
            total: 23,
          ),
          _buildSmallCard(
            context,
            icon: Icons.settings,
            title: AppLocalizations.of(context).repairing,
            today: 10,
            month: 4,
            total: 14,
          ),
          _buildSmallCard(
            context,
            icon: Icons.directions_car_filled,
            title: AppLocalizations.of(context).finished,
            today: 10,
            month: 4,
            total: 14,
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(Visite visite) {
    final isMobile = Responsive.isMobile(context);
    final screenWidth = MediaQuery.of(context).size.width;
    return Container(
      width: double.infinity,
      height: isMobile ? screenWidth * 0.23 : 80,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.07),
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: isMobile ? screenWidth * 0.2 : 80,
            height: isMobile ? screenWidth * 0.2 : 80,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
            child: ClipRRect(borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10),
              bottomLeft: Radius.circular(10),
            ),
              child:_buildImage(visite.vehicle?.logo),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      visite.vehicle?.licensePlate ?? "",
                      style: AppStyles.titleMedium(context).copyWith(
                        fontSize: 14
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Text(DateFormat.yMMMd().format(visite.dateEntree), style: const TextStyle(fontSize: 12)),
                    )
                  ],
                ),
                Text("Propriètaire: ${visite.vehicle?.client?.firstName ?? ""}", style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: isMobile ? 12 : 18,
                ),
                  maxLines: 1,
                ),
                const SizedBox(height: 4),
                Text(
                  _statut(visite.status),
                  style: TextStyle(fontSize: 13, color: _visitColor(visite.status)),
                ),
              ],
            ),
          ),

        ],
      ),
    );
  }

  String _statut(String statut){
    switch(statut){
      case 'ATTENTE_DIAGNOSTIC':
        return "Diagnostic";
      case 'ATTENTE_VALIDATION_DIAGNOSTIC':
        return "Attente validation diagnostic";
      case 'ATTENTE_INTERVENTION':
        return "Attente intervention";
      case 'ATTENTE_PIECE':
        return "Attente pièces";
      default:
        return "Element externe";
    }
  }
  Widget _buildImage(String? imageUrl) {
    if(imageUrl != null){
      return Image.network(imageUrl, headers:{'Authorization': 'Bearer $accessToken'},
        fit: BoxFit.cover,
      );
    }else{
      return Image.asset('assets/images/v1.jpg', fit: BoxFit.cover);
    }

  }
  Color _visitColor(String status) {
    switch(status){
      case "ATTENTE_DIAGNOSTIC":
        return AppColors.alert;
      case "ATTENTE_INTERVENTION":
        return Colors.green;
      default:
        return Colors.white;
    }
  }

  Widget buildHistoryList(BuildContext context) {
    final appColors = Provider.of<AppAdaptiveColors>(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
          ).copyWith(top: 20, bottom: 4),
          child: Row(
            children: [
              Text("Historique", style: AppStyles.titleLarge(context)),
              const Spacer(),
              Text(
                "voir plus",
                style: TextStyle(
                  color: appColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        if (_isLoading)
          Padding(
            padding: EdgeInsets.all(20.0),
            child: Column(
              children: [
              ...List.generate(10, (_) => VehicleInfoCardShimmer()),
              ]
            ),
          )
        else if (_visites.isEmpty)
          const Padding(
            padding: EdgeInsets.all(20.0),
            child: Center(child: Text("Aucune visite trouvée.")),
          )
        else
          ..._visites.map((v) => _buildHistoryItem(v)).toList(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildSearchBar(context),
              _buildEntryBanner(context),
              _buildStatusCardWithImage(context),
              _buildStatusGrid(context),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: HistoryList(title: "Historique", visites: _visites, isLoading: _isLoading, context: context, accessToken: accessToken),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}