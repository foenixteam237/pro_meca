import 'package:flutter/material.dart';
import 'package:pro_meca/core/utils/responsive.dart';
import 'package:pro_meca/core/widgets/buildHistoryList.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../l10n/arb/app_localizations.dart';
import '../../../constants/app_adaptive_colors.dart';
import '../../../constants/app_styles.dart';
import '../../../models/visite.dart';
import '../../../widgets/buildSmallCard.dart';
import '../../../widgets/buildSmallCardShimmer.dart';
import '../../../widgets/buildStatusCardShimmer.dart';
import '../../../widgets/statutCardWithImage.dart';
import '../../diagnostic/views/visite_list_by_status.dart';
import '../../visites/services/reception_services.dart';

class VehicleDashboardPage extends StatefulWidget {
  final BuildContext context;
  const VehicleDashboardPage({super.key, required this.context});

  @override
  State<VehicleDashboardPage> createState() => _VehicleDashboardPageState();
}

class _VehicleDashboardPageState extends State<VehicleDashboardPage> {
  List<Visite> _visites = [];
  bool _isLoading = true;
  String accessToken = "";
  Map<String, int> statVD = {"total": 0};
  Map<String, int> statVI = {"total": 0};
  Map<String, int> statT = {"total": 0};
  Map<String, int> statIT = {"total": 0};

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
      final statit = await ReceptionServices().fetchVisitesWithVehicleStatus(
          "aint"
      );
      setState(() {
        _visites = visites;
        statVD = Visite.getVehicleStatsByStatus(_visites, "ATTENTE_DIAGNOSTIC");
        statVI = Visite.getVehicleStatsByStatus(
          _visites,
          "ATTENTE_VALIDATION_INTERVENTION",
        );
        statT = Visite.getVehicleStatsByStatus(_visites, "TERMINE");
        statIT = {"total": statit.length};
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


  Widget _buildStatusGrid(BuildContext context, List<Visite> visites) {
    final statsAttenteV = Visite.getVehicleStatsByStatus(
      visites,
      "ATTENTE_VALIDATION_DIAGNOSTIC",
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: _isLoading
            ? [
                buildSmallCardShimmer(context),
                buildSmallCardShimmer(context),
                buildSmallCardShimmer(context),
                buildSmallCardShimmer(context),
              ]
            : [
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VisiteListByStatus(
                        contextParent: widget.context,
                        status: "avdia",
                      ),
                    ),
                  ),
                  child: buildSmallCard(
                    context,
                    icon: Icons.access_time_outlined,
                    title: AppLocalizations.of(
                      context,
                    ).waitingValidationDiagnostic,
                    today: statsAttenteV['today']!,
                    month: statsAttenteV['month']!,
                    total: statsAttenteV['total']!,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VisiteListByStatus(
                        contextParent: widget.context,
                        status: "aint",
                      ),
                    ),
                  ),
                  child: buildSmallCard(
                    context,
                    icon: Icons.settings,
                    title: AppLocalizations.of(context).waitingInterventions,
                    today: 10,
                    month: 4,
                    total: statIT['total']!,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VisiteListByStatus(
                        contextParent: widget.context,
                        status: "avin",
                      ),
                    ),
                  ),
                  child: buildSmallCard(
                    context,
                    icon: Icons.rule_folder_outlined,
                    title: AppLocalizations.of(context).waitingValidation,
                    today: 20,
                    month: 3,
                    total: statVI['total']!,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VisiteListByStatus(
                        contextParent: widget.context,
                        status: "term",
                      ),
                    ),
                  ),
                  child: buildSmallCard(
                    context,
                    icon: Icons.directions_car_filled,
                    title: AppLocalizations.of(context).finished,
                    today: 10,
                    month: 4,
                    total: statT['total']!,
                  ),
                ),
              ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appColor = Provider.of<AppAdaptiveColors>(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadData,
          color: appColor.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: Column(
                children: [
                  //_buildSearchBar(context), à implementer en cas de besoin
                  //_buildEntryBanner(context),
                  _isLoading
                      ? buildStatusCardWithImageShimmer(context)
                      : buildStatusCardWithImage(context, () {Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          VisiteListByStatus(contextParent: widget.context, status: "adia"),
                    ),
                  );}, AppLocalizations.of(context).waitingDiagnotics,statVD['total']!),
                  _buildStatusGrid(context, _visites),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: HistoryList(
                      title: "Historiques",
                      visites: _visites,
                      isLoading: _isLoading,
                      contextParent: widget.context,
                      accessToken: accessToken,
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
