import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:pro_meca/core/constants/app_colors.dart';
import 'package:pro_meca/core/constants/app_themes.dart';
import 'package:pro_meca/core/widgets/customAppBar.dart';
import 'package:pro_meca/features/settings/providers/theme_provider.dart';
import 'package:pro_meca/l10n/arb/app_localizations.dart';
import 'package:provider/provider.dart';

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
      const Center(child: Text('Dashboard Screen')),
      const Center(child: Text('Profil Screen')),
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
        inactiveColorPrimary:isDarkMode? Colors.white: Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.build),
        title: l10n.parts,
        activeColorPrimary: AppColors.primary,
        inactiveColorPrimary: isDarkMode? Colors.white: Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.dashboard),
        title: l10n.dashboard,
        activeColorPrimary: AppColors.primary,
        inactiveColorPrimary: isDarkMode? Colors.white: Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.person),
        title: l10n.profile,
        activeColorPrimary: AppColors.primary,
        inactiveColorPrimary: isDarkMode? Colors.white: Colors.grey,
      ),
    ];
  }

  Widget _buildHomeContent() {
    final l10n = AppLocalizations.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(15),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: l10n.vehicleRegistrationHint,
                suffixIcon: Icon(Icons.search, color: AppColors.primary),
              ),
            ),
          ),
          _sectionTitle(l10n.completedVehicles, l10n),
          _buildVehicleRow(),
          const SizedBox(height: 20),
          _sectionTitle(l10n.ongoingVehicles, l10n),
          _ongoingVehicleCard(date: "12/06/2023", status: l10n.diagnostic),
          _ongoingVehicleCard(date: "10/06/2023", status: l10n.validation),
        ],
      ),
    );
  }

  Widget _buildVehicleRow() {
    return SingleChildScrollView(
      padding: EdgeInsets.only(top: 10),
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(3, (index) => _completedVehicleCard()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 600;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: CustomAppBar(
        profileImagePath: "assets/images/images.jpeg",
        name: "Dilane",
        role: l10n.technicianRole,
      ),
      backgroundColor: AppColors.customBackground(context),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              PersistentTabView(
                context,
                padding: const EdgeInsets.only(top: 8),
                controller: _controller,
                screens: _buildScreens(),
                navBarHeight: isMobile ? 60 : 70,
                items: _navBarsItems(context),
                confineToSafeArea: true,
                handleAndroidBackButtonPress: true,
                resizeToAvoidBottomInset: true,
                backgroundColor: isDarkMode ? AppColors.customBackground(context): Colors.white,
                stateManagement: true,
                decoration: NavBarDecoration(
                  border: Border(top: BorderSide(color: Colors.black12)),
                ),
                navBarStyle: NavBarStyle.style1,
              ),
              Positioned(
                bottom: isMobile ? 80 : 90,
                right: isMobile ? 16 : 24,
                child: FloatingActionButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ReceptionVehicleScreen(),
                      ),
                    );
                  },
                  backgroundColor: AppColors.primary,
                  shape: const CircleBorder(),
                  child: Icon(Icons.add),
                ),
              ),// Ajouter un bouton de réception de véhicule
            ],
          );
        },
      ),
    );
  }

  Widget _sectionTitle(String title, AppLocalizations l10n) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        Text(
          l10n.viewMore,
          style: TextStyle(color: AppColors.primary, fontSize: 14),
        ),
      ],
    );
  }

  Widget _completedVehicleCard() {
    final l10n = AppLocalizations.of(context);
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      width: screenWidth * 0.4, // 40% de la largeur d'écran
      constraints: const BoxConstraints(maxWidth: 200), // Largeur max
      margin: EdgeInsets.only(right: screenWidth * 0.03),
      padding: EdgeInsets.all(screenWidth * 0.02),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.primary),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/welcome_image.png',
            width: screenWidth * 0.08, // 8% de la largeur
            height: screenWidth * 0.08,
          ),
          SizedBox(height: screenWidth * 0.02),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "N0567AZ",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: screenWidth * 0.035, // 3.5% de la largeur
                ),
              ),
              Text(
                "Model: COROLLA LE",
                style: TextStyle(fontSize: screenWidth * 0.03),
              ),
              SizedBox(height: screenWidth * 0.02),
            ],
          ),
          Text(
            l10n.seeInvoice,
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
              fontSize: screenWidth * 0.03,
            ),
          ),
        ],
      ),
    );
  }

  Widget _ongoingVehicleCard({required String date, required String status}) {
    final l10n = AppLocalizations.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Container(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: isMobile ? 8 : 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),

      ),
      child: Row(
        children: [
          Container(
            width: isMobile ? screenWidth * 0.2 : 80,
            height: isMobile ? screenWidth * 0.2 : 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                bottomLeft: Radius.circular(10),
              ),
              child: Image.asset('assets/images/v1.jpg', fit: BoxFit.cover),
            ),
          ),
          SizedBox(width: isMobile ? 10 : 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "N0567AZ",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: isMobile ? 16 : 18,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  "Toyota Corolla LE",
                  style: TextStyle(
                    fontSize: isMobile ? 12 : 16,
                  ),
                ),
                SizedBox(height: 8),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),

                  child: Text(
                    status,
                    style: TextStyle(
                      fontSize: isMobile ? 12 : 14,
                      color: _getStatusColor(status, l10n),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 70,
            padding: EdgeInsets.only(right: 20),
            alignment: Alignment.topRight,
            child: Text(
              date,
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: isMobile ? 12 : 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status, AppLocalizations l10n) {
    if (status.contains(l10n.diagnostic)) {
      return AppColors.alert;
    } else if (status.contains(l10n.validation)) {
      return AppColors.secondary;
    } else {
      return AppColors.primary;
    }
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
