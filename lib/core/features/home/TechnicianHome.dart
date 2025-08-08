import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:pro_meca/core/constants/app_adaptive_colors.dart';
import 'package:pro_meca/core/constants/app_colors.dart';
import 'package:pro_meca/core/utils/responsive.dart';
import 'package:pro_meca/core/widgets/buildHistoryList.dart';
import 'package:pro_meca/core/widgets/customAppBar.dart';
import 'package:pro_meca/core/features/pieces/widgets/buildPiecesContent.dart';
import 'package:pro_meca/core/features/profil/user_profile_screen.dart';
import 'package:pro_meca/l10n/arb/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/visite.dart';
import '../reception/services/reception_services.dart';
import 'widgets/buildHomeContent.dart';
import '../dashboard/views/vehicle_dashboard_page.dart';

class TechnicianHomeScreen extends StatefulWidget {
  const TechnicianHomeScreen({super.key});
  @override
  State<TechnicianHomeScreen> createState() => _TechnicianHomeScreenState();
}

class _TechnicianHomeScreenState extends State<TechnicianHomeScreen> {
  late PersistentTabController _controller;
  List<Visite> _visites = [];
  bool _isLoading = true;
  String accessToken = "";

  @override
  void initState() {
    super.initState();
    _loadData();
    _controller = PersistentTabController(initialIndex: 0);
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
  List<Widget> _buildScreens() {
    return [
      HomeContent(historyList: HistoryList(title: AppLocalizations.of(context).ongoingVehicles, visites: _visites, contextParent: context,isLoading: _isLoading, accessToken: accessToken), onRefresh: ()=>_loadData(), context: context,),
      CategoriesPage(),
      VehicleDashboardPage(context: context,),
      ProfileScreen(con: context),
    ];
  }

  List<PersistentBottomNavBarItem> _navBarsItems(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return [
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.home),
        title: l10n.home,
        activeColorPrimary: AppColors.primary,
        inactiveColorPrimary: isDarkMode ? Colors.white : Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.build),
        title: l10n.parts,
        activeColorPrimary: AppColors.primary,
        inactiveColorPrimary: isDarkMode ? Colors.white : Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.dashboard),
        title: l10n.dashboard,
        activeColorPrimary: AppColors.primary,
        inactiveColorPrimary: isDarkMode ? Colors.white : Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.person),
        title: l10n.profile,
        activeColorPrimary: AppColors.primary,
        inactiveColorPrimary: isDarkMode ? Colors.white : Colors.grey,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 600;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final appColors = Provider.of<AppAdaptiveColors>(context);

    return Scaffold(
      appBar: CustomAppBar(
        profileImagePath: "assets/images/images.jpeg",
        name: "Dilane",
        role: l10n.technicianRole,
        nameColor: appColors.primary,
      ),
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColors.customBackground(context),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              PersistentTabView(
                context,
                padding: EdgeInsets.only(
                  top: Responsive.responsiveValue(
                    context,
                    mobile: screenSize.height * 0.01,
                    tablet: screenSize.height * 0.04,
                  ),
                ),
                controller: _controller,
                screens: _buildScreens(),
                navBarHeight: isMobile
                    ? screenSize.height * 0.09
                    : screenSize.height * 0.1,
                items: _navBarsItems(context),
                confineToSafeArea: true,
                handleAndroidBackButtonPress: true,
                resizeToAvoidBottomInset: false,
                backgroundColor: isDarkMode
                    ? const Color(0xFF1E1E1E)
                    : appColors.customBackground(context),
                stateManagement: true,
                decoration: NavBarDecoration(
                  border: Border(top: BorderSide(color: Colors.black12)),
                ),
                navBarStyle: NavBarStyle.style1,
              ),
            ],
          );
        },
      ),
    );
  }
}

class ReceptionVehicleScreen extends StatelessWidget {
  const ReceptionVehicleScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Réception du véhicule')),
      body: Center(child: const Text('Page de réception du véhicule')),
    );
  }
}
