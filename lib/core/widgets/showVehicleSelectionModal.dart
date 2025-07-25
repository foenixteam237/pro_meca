import 'package:flutter/material.dart';
import 'package:pro_meca/core/widgets/vehicule_selection_content.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

void showVehicleSelectionModal(BuildContext context) {
  print("Step 2");
  WoltModalSheet.show(
    context: context,
    pageListBuilder: (modalSheetContext) => [
      WoltModalSheetPage(
        trailingNavBarWidget: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        child: const VehicleSelectionContent(),
      ),
    ],
    modalTypeBuilder: (context) {
      final screenWidth = MediaQuery.of(context).size.width;
      return screenWidth > 700
          ? WoltModalType.alertDialog()
          : WoltModalType.dialog();
    },
    onModalDismissedWithBarrierTap: () => Navigator.pop(context),
  );
}
