import 'dart:math';

import 'package:flutter/material.dart';
import 'package:pro_meca/core/models/user.dart';
import 'package:pro_meca/features/settings/services/api_services.dart';
import '../constants/app_colors.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String profileImagePath;
  final String name;
  final String role;
  final Color nameColor;
  final Color roleColor;
  final Color appBarColor;
  final VoidCallback? onInfoPressed;

  const CustomAppBar({
    super.key,
    required this.profileImagePath,
    required this.name,
    required this.role,
    this.nameColor = AppColors.primary,
    this.roleColor = Colors.black45,
    this.appBarColor = AppColors.background,
    this.onInfoPressed,
  });

  @override
  Size get preferredSize {
    // Hauteur responsive basée sur la hauteur de l'écran (5% de la hauteur totale)
    final screenHeight = MediaQueryData.fromView(
      // ignore: deprecated_member_use
      WidgetsBinding.instance.window,
    ).size.height;
    return Size.fromHeight(screenHeight * 0.07); // 7% de la hauteur d'écran
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Tailles responsive
    final horizontalPadding = screenWidth * 0.03; // 3% de la largeur d'écran
    final fontSizeRole = screenWidth * 0.03; // 3% de la largeur
    final avatarRadius = max(
      20,
      min(30, screenWidth * 0.045),
    ); // Entre 20 et 30
    final fontSizeName = max(14, min(16, screenWidth * 0.04)); // Entre 14 et 18

    return AppBar(
      backgroundColor: AppBarTheme.of(context).backgroundColor,
      elevation: 1,
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      title: FutureBuilder<User?>(
        future: ApiService().getSavedUser(),
        builder: (context, asyncSnapshot) {
          final user = asyncSnapshot.data;
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: Row(
              children: [
                // Image de profil
                CircleAvatar(
                  radius: avatarRadius.toDouble(),
                  backgroundImage: AssetImage(profileImagePath),
                ),
                SizedBox(width: screenWidth * 0.02), // 2% de la largeur
                // Nom et rôle
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      user?.name ?? name,
                      style: TextStyle(
                        color: nameColor,
                        fontWeight: FontWeight.w600,
                        fontSize: fontSizeName.toDouble(),
                      ),
                    ),
                    Text(
                      user?.role.name ?? role,
                      style: TextStyle(
                        color: AppColors.customText(context),
                        fontSize: fontSizeRole,
                      ),
                    ),
                  ],
                ),

                const Spacer(),

                // Bouton d'information (taille responsive)
                IconButton(
                  iconSize: screenWidth * 0.06, // 6% de la largeur
                  icon: Icon(Icons.info_outline, color: nameColor),
                  onPressed: onInfoPressed,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
