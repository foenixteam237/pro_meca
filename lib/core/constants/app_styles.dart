import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_adaptive_colors.dart';

class AppStyles {
  // Text Styles
  static TextStyle headline1(BuildContext context) {
    return Theme.of(context).textTheme.headlineLarge!.copyWith(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      color: Theme.of(context).colorScheme.onSurface,
    );
  }

  static TextStyle headline2(BuildContext context) {
    return Theme.of(context).textTheme.headlineMedium!.copyWith(
      fontSize: 28,
      fontWeight: FontWeight.bold,
      color: Theme.of(context).colorScheme.onSurface,
    );
  }

  static TextStyle headline3(BuildContext context) {
    return Theme.of(context).textTheme.headlineSmall!.copyWith(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      color: Theme.of(context).colorScheme.onSurface,
    );
  }

  static TextStyle titleLarge(BuildContext context) {
    return Theme.of(context).textTheme.titleLarge!.copyWith(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: Theme.of(context).colorScheme.onSurface,
    );
  }

  static TextStyle titleMedium(BuildContext context) {
    return Theme.of(context).textTheme.titleMedium!.copyWith(
      fontSize: 18,
      fontWeight: FontWeight.w500,
      color: Theme.of(context).colorScheme.onSurface,
    );
  }

  static TextStyle bodyLarge(BuildContext context) {
    return Theme.of(context).textTheme.bodyLarge!.copyWith(
      fontSize: 16,
      fontWeight: FontWeight.normal,
      color: Theme.of(context).colorScheme.onSurface,
    );
  }

  static TextStyle bodyMedium(BuildContext context) {
    return Theme.of(context).textTheme.bodyMedium!.copyWith(
      fontSize: 14,
      fontWeight: FontWeight.normal,
      color: Theme.of(context).colorScheme.onSurface,
    );
  }

  static TextStyle bodySmall(BuildContext context) {
    return Theme.of(context).textTheme.bodySmall!.copyWith(
      fontSize: 12,
      fontWeight: FontWeight.normal,
      color: Theme.of(context).colorScheme.onSurface,
    );
  }

  static TextStyle caption(BuildContext context) {
    final appColors = Provider.of<AppAdaptiveColors>(context);
    return Theme.of(context).textTheme.labelSmall!.copyWith(
      fontSize: 14,
      fontWeight: FontWeight.bold,
      color: appColors.primary,
    );
  }
  static TextStyle buttonText(BuildContext context) {
    return Theme.of(context).textTheme.labelLarge!.copyWith(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: Colors.white,
      letterSpacing: 1.0,
    );
  }

  // Button Styles
  static ButtonStyle primaryButton(BuildContext context) {
    return ElevatedButton.styleFrom(
      backgroundColor: AppAdaptiveColors().primary,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      textStyle: buttonText(context),
    );
  }

  static ButtonStyle secondaryButton(BuildContext context) {
    final appColors = Provider.of<AppAdaptiveColors>(context);
    return ElevatedButton.styleFrom(
      backgroundColor: appColors.secondary,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      textStyle: buttonText(context),
    );
  }

  static ButtonStyle outlineButton(BuildContext context) {
    final appColors = Provider.of<AppAdaptiveColors>(context);
    return OutlinedButton.styleFrom(
      foregroundColor: appColors.primary,
      side: BorderSide(color: appColors.primary),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      textStyle: buttonText(context).copyWith(color: appColors.primary),
    );
  }

  static ButtonStyle textButton(BuildContext context) {
    final appColors = Provider.of<AppAdaptiveColors>(context);
    return TextButton.styleFrom(
      foregroundColor: appColors.primary,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      textStyle: buttonText(context).copyWith(color: appColors.primary),
    );
  }

  // Card Styles
  static BoxDecoration cardDecoration(BuildContext context) {
    return BoxDecoration(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  // Input Field Styles
  static InputDecoration inputDecoration(
    BuildContext context, {
    String? label,
    String? hint,
  }) {

    final appColors = Provider.of<AppAdaptiveColors>(context);
    return InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: Theme.of(context).inputDecorationTheme.fillColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade400),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: appColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: AppAdaptiveColors.alert.withOpacity(0.2)),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  // Alert Styles
  static BoxDecoration alertDecoration(
    BuildContext context, {
    bool isError = false,
  }) {
    final appColors = Provider.of<AppAdaptiveColors>(context);
    return BoxDecoration(
      color: isError
          ? AppAdaptiveColors.alert.withOpacity(0.2)
          : appColors.secondary.withOpacity(0.2),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(
        color: isError ? AppAdaptiveColors.alert.withOpacity(0.2) : appColors.secondary,
        width: 1,
      ),
    );
  }

  // Spacing Constants
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double marginSmall = 8.0;
  static const double marginMedium = 16.0;
  static const double marginLarge = 24.0;
  static const double borderRadiusSmall = 4.0;
  static const double borderRadiusMedium = 8.0;
  static const double borderRadiusLarge = 12.0;
}
