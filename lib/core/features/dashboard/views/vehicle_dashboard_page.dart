import 'package:flutter/material.dart';
import 'package:pro_meca/core/utils/responsive.dart';
import 'package:pro_meca/core/widgets/buildHistoryList.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../l10n/arb/app_localizations.dart';
import '../../../constants/app_adaptive_colors.dart';
import '../../../constants/app_styles.dart';
import '../../../models/visite.dart';
import '../../../widgets/buildSmallCardShimmer.dart';
import '../../../widgets/buildStatusCardShimmer.dart';
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
      setState(() {
        _visites = visites;
        statVD = Visite.getVehicleStatsByStatus(_visites, "ATTENTE_DIAGNOSTIC");
        statVI = Visite.getVehicleStatsByStatus(
          _visites,
          "ATTENTE_VALIDATION_INTERVENTION",
        );
        statT = Visite.getVehicleStatsByStatus(_visites, "TERMINE");
        statIT = Visite.getVehicleStatsByStatus(
          _visites,
          "ATTENTE_INTERVENTION",
        );
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
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              VisiteListByStatus(contextParent: widget.context, status: "adia"),
        ),
      ),
      child: Container(
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
            Text(
              statVD['total'].toString(),
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
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
      constraints: const BoxConstraints(minHeight: 100, maxHeight: 120),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // En-tête avec icône et titre
          Row(
            children: [
              Icon(icon, color: appColors.primary, size: 28),
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

          //const SizedBox(height: 20),
          /*
          // Compteur "Aujourd'hui" avec animation
          _buildAnimatedCounterRow(
            label: "Ce jour",
            value: today,
            textStyle: const TextStyle(fontSize: 12),
          ),

          //const SizedBox(height: 10),

          // Compteur "Ce mois" avec animation
          _buildAnimatedCounterRow(
            label: "Ce mois",
            value: month,
            textStyle: const TextStyle(fontSize: 12),
          ),
            */
          // Compteur "Total" avec animation plus visible
          Expanded(
            child: _buildAnimatedCounterRow(
              label: "Total",
              value: total,
              textStyle: AppStyles.titleMedium(context),
              valueStyle: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 30,
                color:
                    appColors.primary, // Vous pouvez utiliser appColors.primary
              ),
              duration: const Duration(milliseconds: 1500),
            ),
          ),
          Icon(Icons.navigate_next_rounded, size: 34, color: appColors.primary),
        ],
      ),
    );
  }

  Widget _buildAnimatedCounterRow({
    required String label,
    required int value,
    TextStyle? textStyle,
    TextStyle? valueStyle,
    Duration duration = const Duration(milliseconds: 1000),
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: textStyle),
          TweenAnimationBuilder<int>(
            tween: IntTween(begin: 0, end: value),
            duration: duration,
            builder: (context, value, child) {
              return Text('$value', style: valueStyle ?? textStyle);
            },
            curve: Curves.easeOut,
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
                  child: _buildSmallCard(
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
                  child: _buildSmallCard(
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
                  child: _buildSmallCard(
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
                  child: _buildSmallCard(
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
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadData,
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
                      : _buildStatusCardWithImage(context),
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
