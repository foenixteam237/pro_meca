import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:pro_meca/core/models/user.dart';
import 'package:pro_meca/services/dio_api_services.dart';
import '../constants/app_colors.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String profileImagePath;
  final String name;
  final String role;
  final Color nameColor;
  final Color roleColor;
  final Color appBarColor;
  final String accessToken;
  final VoidCallback? onInfoPressed;
  const CustomAppBar({
    super.key,
    required this.profileImagePath,
    required this.name,
    required this.role,
    required this.nameColor,
    required this.accessToken,
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
        future: ApiDioService().getSavedUser(),
        builder: (context, asyncSnapshot) {
          final user = asyncSnapshot.data;
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: Row(
              children: [
                buildProfileImage(user?.logo ?? "", avatarRadius),
                SizedBox(width: screenWidth * 0.02), // 2% de la largeur
                // Nom et rôle
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      user?.name ?? name,
                      style: TextStyle(
                        color: AppColors.customText(context),
                        fontWeight: FontWeight.w600,
                        fontSize: fontSizeName.toDouble(),
                      ),
                    ),
                    Text(
                      user?.role.name ?? role,
                      style: TextStyle(
                        color: AppColors.customText(context),
                        fontWeight: FontWeight.bold,
                        fontSize: fontSizeRole,
                      ),
                    ),
                  ],
                ),

                const Spacer(),

                // Bouton d'information (taille responsive)
                IconButton(
                  iconSize: screenWidth * 0.06, // 6% de la largeur
                  icon: Icon(Icons.exit_to_app_outlined, color: nameColor),
                  onPressed: () async {
                    await ApiDioService().logoutUser();
                    if (!context.mounted) return;
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget buildProfileImage(String imagePath, num avatarRadius) {
    if (imagePath.isNotEmpty) {
      return Container(
        width: avatarRadius.toDouble() * 1.5,
        height: avatarRadius.toDouble() * 1.5,
        decoration: BoxDecoration(shape: BoxShape.circle),
        child: ClipOval(
          child: CachedNetworkImage(
            imageUrl: imagePath.contains(ApiDioService().apiUrl)
                ? imagePath
                : ApiDioService().apiUrl + imagePath,
            fit: BoxFit.cover,
            httpHeaders: {'Authorization': 'Bearer $accessToken'},
            placeholder: (context, url) => CircularProgressIndicator(),
            errorWidget: (context, url, error) => Icon(Icons.person),
          ),
        ),
      );
    } else {
      return Container(
        width: avatarRadius.toDouble() * 2.5,
        height: avatarRadius.toDouble() * 2.5,
        decoration: BoxDecoration(shape: BoxShape.circle),
        child: ClipOval(
          child: Image.asset("assets/images/images.jpeg", fit: BoxFit.cover),
        ),
      );
    }
  }
}
