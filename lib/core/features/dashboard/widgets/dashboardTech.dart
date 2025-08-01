import 'package:flutter/material.dart';
import 'package:pro_meca/core/utils/responsive.dart';
import 'package:provider/provider.dart';

import '../../../../l10n/arb/app_localizations.dart';
import '../../../constants/app_adaptive_colors.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_styles.dart';

class VehicleDashboardPage extends StatelessWidget {
  final BuildContext context;
  const VehicleDashboardPage({super.key, required this.context});

  Widget _buildSearchBar() {
    final appColors = Provider.of<AppAdaptiveColors>(context);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Immatriculation du véhicule',
          prefixIcon:  Icon(Icons.search, color: appColors.primary,),
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(color: Colors.grey),
          ),
        ),
      ),
    );
  }

  Widget _buildEntryBanner() {
    final appColors = Provider.of<AppAdaptiveColors>(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Text(
            "Véhicules entrés depuis le",
            style: AppStyles.titleLarge(context),
          ),
          const Spacer(),
           Text(
            "01/01/2025",
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: appColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCardWithImage() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              "https://tmna.aemassets.toyota.com/is/image/toyota/toyota/vehicles/2025/crownsignia/gallery/CRS_MY25_0011_V001_desktop.png?fmt=jpeg&fit=crop&qlt=90&wid=1024",
              height: 60,
              width: 60,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              AppLocalizations.of(context).waitingDiagnotics,
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          const Text(
            "12",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallCard({
    required IconData icon,
    required String title,
    required int today,
    required int month,
    required int total,
  }) {

    final appColors = Provider.of<AppAdaptiveColors>(context);
    return Container(
      width: Responsive.responsiveValue(
        context,
        mobile: MediaQuery.of(context).size.width * 0.45, // Réduit légèrement
        tablet: MediaQuery.of(context).size.width * 0.22,
      ),
      constraints: BoxConstraints(
        minHeight: 100, // Hauteur minimale
        maxHeight: 120, // Hauteur maximale
      ),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: appColors.primary, size: 20),
              const SizedBox(width: 8),
              Expanded(
                // Wrap avec Expanded
                child: Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: Responsive.responsiveValue(
                      context,
                      mobile: 12,
                      tablet: 14,
                    ),
                  ),
                  maxLines: 2, // Autoriser 2 lignes
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Ce jour", style: TextStyle(fontSize: 12)),
              Text('$today', style: TextStyle(fontSize: 12)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Ce mois", style: TextStyle(fontSize: 12)),
              Text("$month", style: TextStyle(fontSize: 12)),
            ],
          ),
          const Spacer(),
          Align(
            alignment: Alignment.centerRight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Total", style: TextStyle(fontSize: 18)),
                Text(
                  "$total",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        shrinkWrap: true,
        physics:
            const NeverScrollableScrollPhysics(), // important pour éviter le scroll interne
        children: [
          _buildSmallCard(
            icon: Icons.access_time_outlined,
            title: AppLocalizations.of(context).waitingValidationDiagnostic,
            today: 10,
            month: 5,
            total: 15,
          ),
          _buildSmallCard(
            icon: Icons.rule_folder_outlined,
            title: AppLocalizations.of(context).waitingValidation,
            today: 20,
            month: 3,
            total: 23,
          ),
          _buildSmallCard(
            icon: Icons.settings,
            title: AppLocalizations.of(context).repairing,
            today: 10,
            month: 4,
            total: 14,
          ),
          _buildSmallCard(
            icon: Icons.directions_car_filled,
            title: AppLocalizations.of(context).finished,
            today: 10,
            month: 4,
            total: 14,
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem({
    required String plate,
    required String model,
    required String status,
    required String date,
    required Color statusColor,
    required String imageUrl,
  }) {

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.07),
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              imageUrl,
              height: 55,
              width: 70,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  plate,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text("Modèle: $model", style: const TextStyle(fontSize: 13)),
                const SizedBox(height: 4),
                Text(
                  status,
                  style: TextStyle(fontSize: 13, color: statusColor),
                ),
              ],
            ),
          ),
          Text(date, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildHistoryList() {

    final appColors = Provider.of<AppAdaptiveColors>(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
          ).copyWith(top: 20, bottom: 4),
          child: Row(
            children: [
              Text("Historique", style: AppStyles.titleLarge(context)),
              Spacer(),
              Text(
                "voir plus",
                style: TextStyle(
                  color: appColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        _buildHistoryItem(
          plate: "N0567AZ",
          model: "COROLLA LE",
          status: "Attente validation diagnostic",
          date: "07/02/2025",
          statusColor: Colors.red,
          imageUrl:
              "https://tmna.aemassets.toyota.com/is/image/toyota/toyota/vehicles/2025/crownsignia/gallery/CRS_MY25_0018_V001_desktop.png?fmt=jpeg&fit=crop&qlt=90&wid=1024",
        ),
        _buildHistoryItem(
          plate: "N0567AZ",
          model: "COROLLA LE",
          status: "Attente diagnostic",
          date: "07/02/2025",
          statusColor: Colors.orange,
          imageUrl:
              "https://tmna.aemassets.toyota.com/is/image/toyota/toyota/vehicles/2025/crownsignia/gallery/CRS_MY25_0009_V001_desktop.png?fmt=jpeg&fit=crop&qlt=90&wid=1024",
        ),
        _buildHistoryItem(
          plate: "N0567AZ",
          model: "COROLLA LE",
          status: "Attente validation intervention",
          date: "07/02/2025",
          statusColor: Colors.green,
          imageUrl:
              "https://tmna.aemassets.toyota.com/is/image/toyota/toyota/vehicles/2025/crownsignia/mlp/mosiac/CRS_MY25_0012_V001.png?wid=1440&hei=810&fmt=jpg&fit=crop",
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildSearchBar(),
              _buildEntryBanner(),
              _buildStatusCardWithImage(),
              _buildStatusGrid(),
              _buildHistoryList(),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
