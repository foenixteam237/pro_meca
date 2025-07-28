import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_styles.dart';

class ClientVehicleFormPage extends StatefulWidget {
  const ClientVehicleFormPage({super.key});

  @override
  State<ClientVehicleFormPage> createState() => _ClientVehicleFormPageState();
}

class _ClientVehicleFormPageState extends State<ClientVehicleFormPage> {
  DateTime? selectedDate;

  // Éléments à bord
  final Map<String, bool> onboardItems = {
    "Extincteur": false,
    "Papier du": false,
    "Cric": false,
    "Kit médical": false,
    "Boîte à outil": false,
  };

  final TextEditingController otherItemsController = TextEditingController();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(1990),
      lastDate: DateTime(2100),
    );

    if (picked != null && picked != selectedDate) {
      setState(() => selectedDate = picked);
    }
  }

  Widget _buildInputField({
    required String hint,
    IconData? icon,
    bool isMultiline = false,
    bool isReadOnly = false,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        readOnly: isReadOnly,
        onTap: onTap,
        maxLines: isMultiline ? 5 : 1,
        decoration: InputDecoration(
          prefixIcon: icon != null ? Icon(icon, color: AppColors.primary) : null,
          hintText: hint,
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.green),
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.green),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildCheckBoxRow(String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Radio<bool>(
          value: true,
          groupValue: onboardItems[label],
          onChanged: (_) {
            setState(() => onboardItems[label] = !(onboardItems[label] ?? false));
          },
          activeColor: Colors.green,
        ),
        Text(label, style: const TextStyle(fontSize: 13)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar:AppBar(
        title: const Text("Informations du client"),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  3,
                      (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 30,
                    height: 5,
                    decoration: BoxDecoration(
                      color: index < 3 ? AppColors.primary : Colors.grey[300],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildInputField(hint: "Nom du client", icon: Icons.person),
              _buildInputField(hint: "Mail", icon: Icons.email),
              _buildInputField(hint: "Téléphone", icon: Icons.phone),

              const SizedBox(height: 20),
              const Text("Détail du véhicule",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),

              _buildInputField(hint: "Numéro du chassis"),
              _buildInputField(hint: "Immatriculation"),
              _buildInputField(hint: "Année de sortie"),
              _buildInputField(hint: "Couleur"),
              _buildInputField(hint: "Kilométrage"),

              /// Image du véhicule
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: InkWell(
                  onTap: () {
                    // Image picker logique
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.green),
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white,
                    ),
                    child: Row(
                      children: const [
                        Expanded(child: Text("Image du véhicule")),
                        Icon(Icons.photo_camera_outlined, color: AppColors.primary),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
              const Text("Éléments à bord", style: TextStyle(fontWeight: FontWeight.bold)),

              Wrap(
                spacing: 8,
                runSpacing: 0,
                children: onboardItems.keys.map((label) => _buildCheckBoxRow(label)).toList(),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: TextFormField(
                  controller: otherItemsController,
                  decoration: InputDecoration(
                    hintText: "Autres éléments déclarés à bord",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.green),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),
              const Text("Problème signalé", style: TextStyle(fontWeight: FontWeight.bold)),

              _buildInputField(hint: "", isMultiline: true),

              const SizedBox(height: 16),
              /// Date d'entrée
              InkWell(
                onTap: () => _selectDate(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          selectedDate != null
                              ? "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}"
                              : "Date d'entrée",
                          style: const TextStyle(color: Colors.black87),
                        ),
                      ),
                      const Icon(Icons.calendar_today, color: AppColors.primary),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              /// Boutons bas
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Action retour
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child:  Text("Retour", style: AppStyles.buttonText(context),),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Action terminé
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child:  Text("Terminé", style: AppStyles.buttonText(context)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
