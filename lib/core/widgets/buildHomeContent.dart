import 'package:flutter/material.dart';
import 'package:pro_meca/core/widgets/showVehicleSelectionModal.dart';
import '../../l10n/arb/app_localizations.dart';
import '../constants/app_colors.dart';
import 'completeVehiculeCard.dart';
import 'ongoingVehiculeCard.dart';

Widget buildHomeContent(BuildContext context) {
  final l10n = AppLocalizations.of(context);
  final screenSize = MediaQuery.of(context).size;
  final isMobile = screenSize.width < 600;
  return Stack(
    children: [
      SingleChildScrollView(
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
            _buildVehicleRow(context),
            const SizedBox(height: 20),
            _sectionTitle(l10n.ongoingVehicles, l10n),
            ongoingVehicleCard(
              date: "12/06/2023",
              status: l10n.diagnostic,
              context: context,
            ),
            ongoingVehicleCard(
              date: "12/06/2023",
              status: l10n.diagnostic,
              context: context,
            ),
            ongoingVehicleCard(
              date: "12/06/2023",
              status: l10n.diagnostic,
              context: context,
            ),
            ongoingVehicleCard(
              date: "12/06/2023",
              status: l10n.diagnostic,
              context: context,
            ),
            ongoingVehicleCard(
              date: "12/06/2023",
              status: l10n.diagnostic,
              context: context,
            ),
            ongoingVehicleCard(
              date: "10/06/2023",
              status: l10n.validation,
              context: context,
            ),
            ongoingVehicleCard(
              date: "10/06/2023",
              status: l10n.validation,
              context: context,
            ),
            ongoingVehicleCard(
              date: "10/06/2023",
              status: l10n.validation,
              context: context,
            ),
            ongoingVehicleCard(
              date: "10/06/2023",
              status: l10n.validation,
              context: context,
            ),
            ongoingVehicleCard(
              date: "10/06/2023",
              status: l10n.validation,
              context: context,
            ),
            ongoingVehicleCard(
              date: "10/06/2023",
              status: l10n.validation,
              context: context,
            ),
            // Ajouter un bouton de réception de véhicule
          ],
        ),
      ),
      Positioned(
        bottom: isMobile ? screenSize.height * 0.03 : 0.20,
        right: isMobile ? screenSize.width * 0.05 : screenSize.width * 0.07,
        child: FloatingActionButton(
          onPressed: () {
            /*
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ReceptionVehicleScreen(),
              ),
            );
            */
            showVehicleSelectionModal(context);
          },
          backgroundColor: AppColors.primary,
          shape: const CircleBorder(),
          child: Icon(Icons.add, size: screenSize.width * 0.09),
        ),
      ),
    ],
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

Widget _buildVehicleRow(BuildContext context) {
  return SingleChildScrollView(
    padding: EdgeInsets.only(top: 10),
    scrollDirection: Axis.horizontal,
    child: Row(
      children: List.generate(10, (index) => completedVehicleCard(context)),
    ),
  );
}
