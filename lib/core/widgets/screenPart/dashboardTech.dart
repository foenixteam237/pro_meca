import 'package:flutter/material.dart';

class VehicleDashboardPage extends StatelessWidget {
  const VehicleDashboardPage({super.key});

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Immatriculation du véhicule',
          prefixIcon: const Icon(Icons.search),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          const Text(
            "Véhicules entrés depuis le",
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          const Spacer(),
          const Text(
            "01/01/2025",
            style: TextStyle(fontWeight: FontWeight.w500),
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
        border: Border.all(color: Colors.blue),
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
          const Expanded(
            child: Text(
              "En attente diagnostic",
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
    return Container(
      width: 150,
      margin: const EdgeInsets.all(6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blue),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.blue),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text("Ce jour    $today"),
          Text("Ce mois  $month"),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.bottomRight,
            child: Text(
              "$total",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Wrap(
        alignment: WrapAlignment.center,
        children: [
          _buildSmallCard(
            icon: Icons.access_time_outlined,
            title: "Attente validation\ndiagnostic",
            today: 10,
            month: 5,
            total: 15,
          ),
          _buildSmallCard(
            icon: Icons.rule_folder_outlined,
            title: "En attente validation\nintervention",
            today: 20,
            month: 3,
            total: 23,
          ),
          _buildSmallCard(
            icon: Icons.settings,
            title: "En cours de réparation",
            today: 10,
            month: 4,
            total: 14,
          ),
          _buildSmallCard(
            icon: Icons.directions_car_filled,
            title: "Terminés",
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
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
          ).copyWith(top: 12, bottom: 4),
          child: Row(
            children: const [
              Text("Historique", style: TextStyle(fontWeight: FontWeight.bold)),
              Spacer(),
              Text("voir plus", style: TextStyle(color: Colors.blue)),
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
              "https://www.toyota.com/content/dam/toyota/vehicles/2025/crownsignia/mlp/owners-video/CRS_MY25_LCH_WelcomeMat_TCOM_Desktop_1920x79.mp4?wid=1920",
        ),
        _buildHistoryItem(
          plate: "N0567AZ",
          model: "COROLLA LE",
          status: "Attente diagnostic",
          date: "07/02/2025",
          statusColor: Colors.orange,
          imageUrl:
              "https://www.toyota.com/content/dam/toyota/vehicles/2025/crownsignia/mlp/owners-video/CRS_MY25_LCH_WelcomeMat_TCOM_Desktop_1920x79.mp4?wid=1920",
        ),
        _buildHistoryItem(
          plate: "N0567AZ",
          model: "COROLLA LE",
          status: "Attente validation intervention",
          date: "07/02/2025",
          statusColor: Colors.green,
          imageUrl:
              "https://www.toyota.com/content/dam/toyota/vehicles/2025/crownsignia/mlp/owners-video/CRS_MY25_LCH_WelcomeMat_TCOM_Desktop_1920x79.mp4?wid=1920",
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
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
