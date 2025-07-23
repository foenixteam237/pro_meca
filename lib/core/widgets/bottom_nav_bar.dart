import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

class PersistentNavBar extends StatelessWidget {
  final int initialIndex;
  final List<Widget> screens;
  final List<PersistentBottomNavBarItem> navItems;
  final Color backgroundColor;
  final Color activeColor;
  final Color inactiveColor;
  final double navBarHeight;
  final bool showElevation;
  final NavBarStyle navBarStyle;

  const PersistentNavBar({
    super.key,
    this.initialIndex = 0,
    required this.screens,
    required this.navItems,
    this.backgroundColor = Colors.white,
    this.activeColor = Colors.blue,
    this.inactiveColor = Colors.grey,
    this.navBarHeight = 60.0,
    this.showElevation = true,
    this.navBarStyle = NavBarStyle.style15,
  });

  @override
  Widget build(BuildContext context) {
    final controller = PersistentTabController(initialIndex: initialIndex);

    return PersistentTabView(
      context,
      controller: controller,
      screens: screens,
      items: navItems,
      confineToSafeArea: true,
      backgroundColor: backgroundColor,
      handleAndroidBackButtonPress: true,
      resizeToAvoidBottomInset: true,
      stateManagement: true,
      decoration: NavBarDecoration(
        borderRadius: BorderRadius.circular(10.0),
        colorBehindNavBar: backgroundColor,
      ),
      navBarStyle: navBarStyle,
      navBarHeight: navBarHeight,
    );
  }
}
