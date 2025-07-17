import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pro_meca/l10n/arb/app_localizations.dart';

class TechnicianHomeScreen extends StatelessWidget {
  const TechnicianHomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final l10n = AppLocalizations.of(
      context,
    ); // Assurez-vous que l10n est correctement initialisé
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 100,
        backgroundColor: Colors.white,
        elevation: 0,
        flexibleSpace: Padding(
          padding: const EdgeInsets.only(top: 40, left: 16, right: 16),
          child: Row(
            children: [
              Text(
                l10n.appTitle, // Utilisation de la localisation
                style: GoogleFonts.pacifico(fontSize: 24, color: Colors.green),
              ),
              const Spacer(),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search, color: Colors.green),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(
                            hintText: 'Immatriculation du véhicule',
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle(
              l10n.completedVehicles,
            ), // Utilisation de la localisation
            const SizedBox(height: 10),
            SizedBox(
              height: 140,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 2,
                itemBuilder: (context, index) {
                  return _completedVehicleCard();
                },
              ),
            ),
            const SizedBox(height: 20),
            _sectionTitle(
              l10n.ongoingVehicles,
            ), // Utilisation de la localisation
            const SizedBox(height: 10),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 4,
              itemBuilder: (context, index) {
                return _ongoingVehicleCard(
                  date: "07/02/2025",
                  status: switch (index) {
                    0 => l10n.repair,
                    1 => l10n.clientValidation,
                    2 => l10n.diagnostic,
                    _ => l10n.repair,
                  },
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 6,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: const [
            _NavItem(icon: Icons.home, label: "Home"),
            _NavItem(icon: Icons.build, label: "Pièces"),
            SizedBox(width: 48), // Space for FAB
            _NavItem(icon: Icons.dashboard, label: "Dashboard"),
            _NavItem(icon: Icons.person, label: "Profil"),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        Text(
          'Voir plus',
          style: TextStyle(color: Colors.green[700], fontSize: 14),
        ),
      ],
    );
  }

  Widget _completedVehicleCard() {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.green),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Image(
            image: AssetImage('assets/welcome_image.png'),
            width: 40,
            height: 40,
          ),
          SizedBox(height: 8),
          Text("N0567AZ", style: TextStyle(fontWeight: FontWeight.bold)),
          Text("Model: COROLLA LE"),
          SizedBox(height: 8),
          Text(
            "Voir la facture",
            style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _ongoingVehicleCard({required String date, required String status}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              'assets/welcome_image.jpg',
              width: 70,
              height: 70,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "N0567AZ",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const Text("Model: COROLLA LE"),
                Text(
                  status,
                  style: TextStyle(
                    color: status.contains("Diagnostique")
                        ? Colors.red
                        : status.contains("Validation")
                        ? Colors.orange
                        : Colors.blue,
                  ),
                ),
              ],
            ),
          ),
          Text(date, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {},
      icon: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 22),
          Text(label, style: const TextStyle(fontSize: 10)),
        ],
      ),
    );
  }
}
