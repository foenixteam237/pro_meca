import 'package:flutter/material.dart';
import 'package:pro_meca/core/constants/app_adaptive_colors.dart';
import 'package:pro_meca/core/models/visite.dart';
import 'package:pro_meca/core/widgets/customAppBar.dart';
import 'package:pro_meca/l10n/arb/app_localizations.dart';
import 'package:provider/provider.dart';

class ValidationDiagnosticScreen extends StatelessWidget {
  final String idVisite;
  final String accessToken;
  final Visite visite;
  const ValidationDiagnosticScreen({
    super.key,
    required this.idVisite,
    required this.visite,
    required this.accessToken,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = Provider.of<AppAdaptiveColors>(context);
    AppLocalizations l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      appBar: CustomAppBar(
        profileImagePath: "assets/images/images.jpeg",
        name: "Dilane",
        role: l10n.technicianRole,
        nameColor: appColors.primary,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header - Profil technicien
              Row(
                children: [
                  const CircleAvatar(
                    radius: 24,
                    backgroundImage: AssetImage("assets/technician.jpg"),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "Eric Anderson",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        "Technicien",
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Icon(Icons.info_outline, color: Colors.blue),
                ],
              ),
              const SizedBox(height: 20),

              // Infos véhicule
              Row(
                children: [
                  const CircleAvatar(
                    backgroundImage: AssetImage("assets/toyota.png"),
                    radius: 20,
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "N0567AZ",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        "Model: COROLLA LE",
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                    ],
                  ),
                  const Spacer(),
                  const Text(
                    "M MARTIN PETER",
                    style: TextStyle(color: Colors.black54, fontSize: 13),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Problème signalé
              const Text(
                "Problème signalé par le client",
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                height: 80,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  "Fumée blanche.........",
                  style: TextStyle(color: Colors.black87, fontSize: 14),
                ),
              ),
              const SizedBox(height: 20),

              // Images véhicule
              const Text(
                "Images du véhicule",
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 70,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    VehicleImageCard("assets/car.jpg"),
                    VehicleImageCard("assets/car_engine.jpg"),
                    VehicleImageCard("assets/car_diagnose.jpg"),
                    VehicleImageCard("assets/workshop.jpg"),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Niveau intervention
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    "Niveau d'intervention",
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                  Text(
                    "Normal",
                    style: TextStyle(color: Colors.green, fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Diagnostic technicien
              const Text(
                "Diagnostic fait par le technicien",
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
              ),
              const SizedBox(height: 10),
              DiagnosticRow(code: "N/A", desc: "Moteur sèche"),
              DiagnosticRow(code: "ER2376", desc: "Huile vidange"),
              const SizedBox(height: 20),

              // Interventions à faire
              const Text(
                "Interventions à faire",
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue.shade100),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        "assets/intervention.jpg",
                        width: 70,
                        height: 70,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            "Direction",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          Text(
                            "Priorité: avertissement",
                            style: TextStyle(
                              color: Colors.orange,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            "Technicien: Dilane Tech",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {},
                      child: const Text("Détails"),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Bouton de validation
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 60,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () {},
                  child: const Text(
                    "Validé",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Widget pour images véhicule
class VehicleImageCard extends StatelessWidget {
  final String image;
  const VehicleImageCard(this.image, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.asset(image, width: 80, height: 70, fit: BoxFit.cover),
      ),
    );
  }
}

// Widget pour ligne diagnostic
class DiagnosticRow extends StatelessWidget {
  final String code, desc;
  const DiagnosticRow({super.key, required this.code, required this.desc});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text("$code   $desc", style: const TextStyle(fontSize: 14)),
          ),
          const Icon(Icons.check_circle, color: Colors.green),
          const SizedBox(width: 8),
          const Icon(Icons.cancel, color: Colors.red),
        ],
      ),
    );
  }
}
