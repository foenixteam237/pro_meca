import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:pro_meca/core/constants/app_colors.dart';
import 'package:pro_meca/core/widgets/customAppBar.dart';
import 'package:pro_meca/l10n/arb/app_localizations.dart';

class TechnicianHomeScreen extends StatefulWidget {
  const TechnicianHomeScreen({super.key});

  @override
  State<TechnicianHomeScreen> createState() => _TechnicianHomeScreenState();
}

class _TechnicianHomeScreenState extends State<TechnicianHomeScreen> {
  late PersistentTabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PersistentTabController(initialIndex: 0);
  }

  List<Widget> _buildScreens() {
    return [
      _buildHomeContent(),
      const Center(child: Text('Pièces Screen')),
      const Center(child: Text('Add Screen')),
      const Center(child: Text('Dashboard Screen')),
      const Center(child: Text('Profil Screen')),
    ];
  }

  List<PersistentBottomNavBarItem> _navBarsItems(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return [
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.home),
        title: l10n.home,
        activeColorPrimary: AppColors.primary,
        inactiveColorPrimary: Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.build),
        title: l10n.parts,
        activeColorPrimary: AppColors.primary,
        inactiveColorPrimary: Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.add, size: 30),
        title: "",
        activeColorPrimary: AppColors.primary,
        inactiveColorPrimary: Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.dashboard),
        title: l10n.dashboard,
        activeColorPrimary: AppColors.primary,
        inactiveColorPrimary: Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.person),
        title: l10n.profile,
        activeColorPrimary: AppColors.primary,
        inactiveColorPrimary: Colors.grey,
      ),
    ];
  }

  Widget _buildHomeContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [

          _sectionTitle("Véhicules terminés"),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _completedVehicleCard(),
                _completedVehicleCard(),
                _completedVehicleCard(),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _sectionTitle("Véhicules en cours"),
          _ongoingVehicleCard(
            date: "12/06/2023",
            status: "En diagnostique",
          ),
          _ongoingVehicleCard(
            date: "10/06/2023",
            status: "En validation",
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar:CustomAppBar(profileImagePath: "assets/images/images.jpeg", name: "Dilane", role: l10n.technicianRole),
      body: PersistentTabView(
        context,
        controller: _controller,
        screens: _buildScreens(),
        items: _navBarsItems(context),
        confineToSafeArea: true,
        backgroundColor: AppColors.background,
        handleAndroidBackButtonPress: true,
        resizeToAvoidBottomInset: true,
        stateManagement: true,
        decoration: NavBarDecoration(
          borderRadius: BorderRadius.circular(10.0),
          colorBehindNavBar: AppColors.background,
        ),
        navBarStyle: NavBarStyle.style15,
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        Text(
          'Voir plus',
          style: TextStyle(color: AppColors.primary, fontSize: 14),
        ),
      ],
    );
  }

  Widget _completedVehicleCard() {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.primary),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Image(
            image: AssetImage('assets/images/welcome_image.png'),
            width: 40,
            height: 40,
          ),
          SizedBox(height: 8),
          Text("N0567AZ", style: TextStyle(fontWeight: FontWeight.bold)),
          Text("Model: COROLLA LE"),
          SizedBox(height: 8),
          Text(
            "Voir la facture",
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _ongoingVehicleCard({required String date, required String status}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              'assets/images/welcome_image.png',
              width: 70,
              height: 70,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "N0567AZ",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const Text("Model: COROLLA LE"),
                Text(
                  status,
                  style: TextStyle(
                    color: status.contains("Diagnostique")
                        ? AppColors.alert
                        : status.contains("Validation")
                        ? AppColors.secondary
                        : AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          Text(date, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}