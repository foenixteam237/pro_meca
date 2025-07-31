import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pro_meca/core/features/reception/services/reception_services.dart';
import 'package:pro_meca/core/models/client.dart';
import 'package:pro_meca/core/models/vehicle.dart';
import 'package:pro_meca/core/models/visite.dart';
import 'package:pro_meca/services/dio_api_services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_styles.dart';

class ClientVehicleFormPage extends StatefulWidget {
  final String idBrand;
  final String idModel;
  const ClientVehicleFormPage({
    super.key,
    required this.idBrand,
    required this.idModel,
  });
  @override
  State<ClientVehicleFormPage> createState() => _ClientVehicleFormPageState();
}

class _ClientVehicleFormPageState extends State<ClientVehicleFormPage> {
  DateTime? selectedDate;
  File? _selectedImage;
  bool isSelected = false;
  final ImagePicker _picker = ImagePicker();
  // Contrôleurs pour les champs du client et du véhicule
  final Map<String, TextEditingController> controllers = {
    'firstName': TextEditingController(),
    'lastName': TextEditingController(),
    'email': TextEditingController(),
    'phone': TextEditingController(),
    'chassis': TextEditingController(),
    'licensePlate': TextEditingController(),
    'year': TextEditingController(),
    'color': TextEditingController(),
    'mileage': TextEditingController(),
    'reportedProblem': TextEditingController(),
    'otherItems': TextEditingController(),
  };
  final Map<String, bool> onboardItems = {
    "Extincteur": false,
    "Papier du véhicule": false,
    "Cric": false,
    "Kit médical": false,
    "Boîte à outil": false,
    "Essuie Glace": false,
  };
  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    await Permission.photos.request();
    await Permission.camera.request();
  }

  Future<void> _selectImageSource() async {
    print("Allons chercher notre picture");
    final action = await showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choisir une source d\'image'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, ImageSource.camera),
            child: const Text('Caméra'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, ImageSource.gallery),
            child: const Text('Galerie'),
          ),
        ],
      ),
    );
    if (action != null) {
      if (action == ImageSource.camera) {
        await _takePhoto();
      } else {
        await _pickImage();
      }
    }
  }

  Future<void> _pickImage() async {
    if (await Permission.photos.isGranted) {
      final image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      if (image != null) {
        setState(() {
          isSelected = true;
          _selectedImage = File(image.path);
        });
      }
    }
  }

  Future<void> _takePhoto() async {
    if (await Permission.camera.isGranted) {
      final photo = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      if (photo != null) {
        setState(() {
          isSelected = true;
          _selectedImage = File(photo.path);
        });
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(1990),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != selectedDate) {
      setState(() => selectedDate = picked);
    }
  }

  bool isYearValid(int year) {
    int currentYear = DateTime.now().year;
    return (year <= currentYear && year != 0);
  }

  void _submitForm() async {

    try {
      final prefs = await SharedPreferences.getInstance();
      final companyId = prefs.getString('companyId') ?? '';
      if (controllers['firstName']!.text.isNotEmpty &&
          controllers['lastName']!.text.isNotEmpty &&
          controllers['phone']!.text.isNotEmpty &&
          controllers['email']!.text.isNotEmpty &&
          controllers['chassis']!.text.isNotEmpty &&
          controllers['licensePlate']!.text.isNotEmpty &&
          isYearValid(int.tryParse(controllers['year']!.text) ?? 0) &&
          controllers['color']!.text.isNotEmpty &&
          controllers['mileage']!.text.isNotEmpty &&
          selectedDate != null &&
          controllers['reportedProblem']!.text.isNotEmpty) {
        // Récupération des données du client et du véhicule
        final client = Client(
          id: "",
          firstName: controllers['firstName']!.text,
          lastName: controllers['lastName']!.text,
          phone: controllers['phone']!.text,
          email: controllers['email']!.text,
          companyId: companyId,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        final clientId = await ReceptionServices().createClient(client.toMap(),context, );

        if (clientId.isNotEmpty) {
          // Création de l'objet Vehicle
          final vehicule = Vehicle(
            marqueId: widget.idBrand,
            modelId: widget.idModel,
            year: int.tryParse(controllers['year']!.text) ?? 0,
            chassis: controllers['chassis']!.text,
            licensePlate: controllers['licensePlate']!.text,
            color: controllers['color']!.text,
            kilometrage: int.tryParse(controllers['mileage']!.text) ?? 0,
            clientId: clientId,
            companyId: companyId,
          );
          // Création du FormData
          FormData formData = FormData.fromMap(
            await vehicule.toJson(_selectedImage),
          );
          // Appel à l'API
          final vehicle = await ReceptionServices().createVehicle(formData);

          if (vehicle != null) {
            final ext = onboardItems['Extincteur'] ?? false;
            final papier = onboardItems['Papier du véhicule'] ?? false;
            final crics = onboardItems['Cric'] ?? false;
            final boitePharmacie = onboardItems['Kit médical'] ?? false;
            final boiteOutils = onboardItems['Boîte à outil'] ?? false;
            final essuieGlace = onboardItems['Essuie Glace'] ?? false;

            final visite = Visite(
              id: "",
              dateEntree: selectedDate ?? DateTime.now(),
              vehicleId: vehicle,
              status: "ATTENTE_DIAGNOSTIC",
              constatClient: controllers["reportedProblem"]!.text,
              elementsBord: ElementsBord(
                extincteur: ext,
                dossier: papier,
                cric: crics,
                boitePharmacie: boitePharmacie,
                boiteOutils: boiteOutils,
                essuieGlace: essuieGlace,
              ),
              companyId: companyId,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            );
           var rep = await ReceptionServices().createVisite(visite.toJson(), context);

            if (rep != null && rep == 201) {
              Navigator.pushNamed(context, '/confirm_screen');
            }
          }
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Veuillez remplir tous les champs et respecter les formats des champs. ',
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur: ${e.toString()}')));
    }
  }

  @override
  void dispose() {
    controllers.forEach((key, controller) => controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Reception du véhicule")),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ... (votre code existant pour les indicateurs de progression)
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
              const SizedBox(height: 20),
              const Text(
                "Information du client",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ..._buildInputFields(),
              const SizedBox(height: 20),
              const Text(
                "Détail du véhicule",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              ..._buildVehicleInputFields(),
              // Image du véhicule
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: InkWell(
                  onTap: _selectImageSource,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.green.withOpacity(0.1)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            isSelected
                                ? "Image déjà sélectionnée "
                                : "Sélectionnez une image",
                          ),
                        ),
                        Icon(
                          Icons.photo_camera_outlined,
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Éléments à bord",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Wrap(
                spacing: 8,
                runSpacing: 0,
                children: onboardItems.keys
                    .map((label) => _buildCheckBoxRow(label))
                    .toList(),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: TextFormField(
                  controller: controllers['otherItems'],
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
              _buildInputField(
                hint: "Problème signalé",
                controller: controllers['reportedProblem']!,
                isMultiline: true,
              ),
              const SizedBox(height: 16),
              // Date d'entrée
              InkWell(
                onTap: () => _selectDate(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
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
                      const Icon(
                        Icons.calendar_today,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              // Boutons bas
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.withOpacity(0.7),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        "Retour",
                        style: AppStyles.buttonText(context),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        "Terminé",
                        style: AppStyles.buttonText(context),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildInputFields() {
    return [
      _buildInputField(
        hint: "Nom du client",
        controller: controllers['lastName']!,
        icon: Icons.person,
      ),
      _buildInputField(
        hint: "Prénom du client",
        controller: controllers['firstName']!,
        icon: Icons.person,
      ),
      _buildInputField(
        hint: "Mail",
        controller: controllers['email']!,
        icon: Icons.email,
        keyboardType: TextInputType.emailAddress,
      ),
      _buildInputField(
        hint: "Téléphone",
        controller: controllers['phone']!,
        icon: Icons.phone,
        keyboardType: TextInputType.phone,
      ),
    ];
  }

  List<Widget> _buildVehicleInputFields() {
    return [
      _buildInputField(
        hint: "Numéro du châssis",
        controller: controllers['chassis']!,
      ),
      _buildInputField(
        hint: "Immatriculation",
        controller: controllers['licensePlate']!,
      ),
      _buildInputField(
        hint: "Année de sortie",
        controller: controllers['year']!,
        keyboardType: TextInputType.datetime,
      ),
      _buildInputField(hint: "Couleur", controller: controllers['color']!),
      _buildInputField(
        hint: "Kilométrage",
        controller: controllers['mileage']!,
        keyboardType: TextInputType.number,
      ),
    ];
  }

  Widget _buildInputField({
    required String hint,
    required TextEditingController controller,
    IconData? icon,
    bool isMultiline = false,
    bool isReadOnly = false,
    VoidCallback? onTap,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        controller: controller,
        readOnly: isReadOnly,
        onTap: onTap,
        maxLines: isMultiline ? 5 : 1,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          prefixIcon: icon != null
              ? Icon(icon, color: AppColors.primary)
              : null,
          hintText: hint,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.green.withOpacity(0.1)),
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
        Checkbox(
          value: onboardItems[label],
          onChanged: (value) {
            setState(() {
              onboardItems[label] = value ?? false;
              print(" le $label est $value");
            });
          },
          activeColor: Colors.green,
        ),
        Text(label, style: const TextStyle(fontSize: 13)),
      ],
    );
  }
}
