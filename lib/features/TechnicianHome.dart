import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:pro_meca/core/constants/app_colors.dart';
import 'package:pro_meca/core/widgets/customAppBar.dart';
import 'package:pro_meca/features/auth/screens/user_profile_screen.dart';
import 'package:pro_meca/l10n/arb/app_localizations.dart';

import '../core/widgets/buildHomeContent.dart';

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
      buildHomeContent(context),
      const Center(child: Text('Pièces Screen')),
      const Center(child: Text('Dashboard Screen')),
      ProfileScreen(),
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
                padding: const EdgeInsets.only(top: 5),
                controller: _controller,
                screens: _buildScreens(),
                navBarHeight: isMobile
                    ? screenSize.height * 0.07
                    : screenSize.height * 0.08,
                items: _navBarsItems(context),
                confineToSafeArea: true,
                handleAndroidBackButtonPress: true,
                resizeToAvoidBottomInset: true,
                backgroundColor: isDarkMode
                    ? const Color(0xFF1E1E1E)
                    : AppColors.background,
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
