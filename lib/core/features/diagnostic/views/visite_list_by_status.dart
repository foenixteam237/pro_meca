import 'package:flutter/material.dart';
import 'package:pro_meca/core/widgets/buildHistoryList.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../constants/app_adaptive_colors.dart';
import '../../../constants/app_styles.dart';
import '../../../models/visite.dart';
import '../../visites/services/reception_services.dart';

class VisiteListByStatus extends StatefulWidget {
  final BuildContext contextParent;
  final String status;
  const VisiteListByStatus({
    super.key,
    required this.contextParent,
    required this.status,
  });

  @override
  State<VisiteListByStatus> createState() => _VisiteListByStatusState();
}

class _VisiteListByStatusState extends State<VisiteListByStatus> {
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
      final isAdmin = pref.getBool("isAdmin") ?? false;
      late final List<Visite> visites;

      if (isAdmin) {
        visites = await ReceptionServices().fetchVisitesWithVehicleStatus(
          widget.status,
        );
      } else {
        switch (widget.status) {
          case "aint":
            visites = await ReceptionServices()
                .fetchVisitesWithVehicleStatusAndUser("aint");
            break;
          case "avdia":
            visites = await ReceptionServices().fetchVisitesWithVehicleStatus(
              widget.status,
            );
            print(visites);
            break;
          case "avin":
            visites = await ReceptionServices().fetchVisitesWithVehicleStatus(
              widget.status,
            );
            break;
          case "term":
            visites = await ReceptionServices().fetchVisitesWithVehicleStatus(
              widget.status,
            );
            break;
          default:
            visites = await ReceptionServices()
                .fetchVisitesWithVehicleStatusAndUser(widget.status);
        }
      }
      setState(() {
        _visites = visites;
        _isLoading = false;
      });
    } catch (e) {
      // Affiche une erreur (ex: snackbar) ou log
      print("Erreur lors du chargement des visites: $e");
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
          Text("Liste des visites", style: AppStyles.titleMedium(context)),
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

  @override
  Widget build(BuildContext context) {
    final appColors = Provider.of<AppAdaptiveColors>(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: RefreshIndicator(
          color: appColors.primary,
          onRefresh: _loadData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                _buildSearchBar(context),
                _buildEntryBanner(context),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  child: HistoryList(
                    title: "",
                    visites: _visites,
                    isLoading: _isLoading,
                    contextParent: widget.contextParent,
                    accessToken: accessToken,
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
