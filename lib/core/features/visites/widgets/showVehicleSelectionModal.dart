import 'package:flutter/material.dart';
import 'package:pro_meca/core/features/visites/views/vehicule_selection_content.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

void showVehicleSelectionModal(BuildContext context) {
  WoltModalSheet.show(
    context: context,
    pageListBuilder: (modalSheetContext) => [
      WoltModalSheetPage(
        trailingNavBarWidget: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        child: VehicleSelectionContent(context: context),
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
