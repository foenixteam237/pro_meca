import 'package:flutter/material.dart';
import 'package:pro_meca/core/constants/app_adaptive_colors.dart';
import 'package:pro_meca/core/constants/app_styles.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

void ShowWoltModalSheet(
  AppAdaptiveColors appColor,
  BuildContext context,
  String title,
  Widget form,
) {
  WoltModalSheet.show(
    context: context,
    pageListBuilder: (modalSheetContext) => [
      WoltModalSheetPage(
        topBar: Container(
          padding: EdgeInsets.all(10),
          alignment: Alignment.center,
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: AppStyles.titleLarge(context),
          ),
        ),
        trailingNavBarWidget: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        child: form,
      ),
    ],
    modalTypeBuilder: (context) {
      final screenWidth = MediaQuery.of(context).size.width;
      return screenWidth > 700
          ? WoltModalType.alertDialog()
          : WoltModalType.sideSheet();
    },
    onModalDismissedWithBarrierTap: () => Navigator.pop(context),
  );
}
