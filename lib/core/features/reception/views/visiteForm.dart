import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pro_meca/core/constants/app_adaptive_colors.dart';
import 'package:pro_meca/core/features/reception/services/reception_services.dart';
import 'package:pro_meca/core/models/client.dart';
import 'package:pro_meca/core/models/vehicle.dart';
import 'package:pro_meca/core/models/visite.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_styles.dart';
import '../../../utils/responsive.dart';

class ClientVehicleFormPage extends StatefulWidget {
  final String idBrand;
  final String idModel;
  final Vehicle? vehicle;
  const ClientVehicleFormPage({
    super.key,
    required this.idBrand,
    required this.idModel,
    this.vehicle,
  });
  @override
  State<ClientVehicleFormPage> createState() => _ClientVehicleFormPageState();
}

class _ClientVehicleFormPageState extends State<ClientVehicleFormPage> {
  DateTime? selectedDate;
  File? _selectedImage;
  final List<File> _vehicleConditionImages = [];
  bool isLoading = false;
  final ImagePicker _picker = ImagePicker();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final Map<String, TextEditingController> controllers = {
    'firstName': TextEditingController(),
    'lastName': TextEditingController(),
    'email': TextEditingController(),
    'phone': TextEditingController(),
    'chassis': TextEditingController(),
    'licensePlate': TextEditingController(),
    'year': TextEditingController(),
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
  };

  @override
  void initState() {
    super.initState();
    _controllerInit();
  }

  Future<void> _selectImageSource({bool isVehicleImage = true}) async {
    final action = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppColors.primary),
              title: const Text('Prendre une photo'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: AppColors.primary),
              title: const Text('Choisir depuis la galerie'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (action != null) {
      try {
        if (action == ImageSource.camera && !await Permission.camera.isGranted) {
          await Permission.camera.request();
        } else if (action == ImageSource.gallery && !await Permission.photos.isGranted) {
          await Permission.photos.request();
        }

        if ((action == ImageSource.camera && await Permission.camera.isGranted) ||
            (action == ImageSource.gallery && await Permission.photos.isGranted)) {
          final image = await _picker.pickImage(
            source: action,
            maxWidth: 800,
            maxHeight: 800,
            imageQuality: 85,
          );

          if (image != null) {
            setState(() {
              if (isVehicleImage) {
                _selectedImage = File(image.path);
              } else {
                if (_vehicleConditionImages.length < 4) {
                  _vehicleConditionImages.add(File(image.path));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Maximum 4 images autorisées')),
                  );
                }
              }
            });
          }
        } else {
          _showPermissionError();
        }
      } on PlatformException catch (e) {
        _showPermissionError(e.message);
      }
    }
  }

  void _showPermissionError([String? message]) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message ?? 'Permission refusée. Veuillez autoriser l\'accès dans les paramètres'),
        action: SnackBarAction(
          label: 'Paramètres',
          onPressed: openAppSettings,
        ),
        backgroundColor: Colors.red,
      ),
    );
  }

  bool _isFormValid() {
    return _formKey.currentState?.validate() ?? false;
  }

  void _submitForm() async {
    if (!_isFormValid()) {
      if (selectedDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Veuillez sélectionner une date d\'entrée')),
        );
      }
      if (_selectedImage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Veuillez ajouter une image du véhicule')),
        );
      }
      return;
    }

    setState(() => isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final companyId = prefs.getString('companyId') ?? '';

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
      String clientId = "";
      if(widget.vehicle?.client?.id == null) clientId = await ReceptionServices().createClient(client.toMap(), context);
      if(widget.vehicle?.client?.id != null) clientId = widget.vehicle!.clientId;

      if (clientId.isNotEmpty) {
        final vehicle = Vehicle(
          marqueId: widget.idBrand,
          modelId: widget.idModel,
          year: int.tryParse(controllers['year']!.text) ?? 0,
          chassis: controllers['chassis']!.text,
          licensePlate: controllers['licensePlate']!.text,
          color: "",
          kilometrage: int.tryParse(controllers['mileage']!.text) ?? 0,
          clientId: clientId,
          companyId: companyId,
        );
        String? createdVehicle = "";
        // Envoyer la photo principale du véhicule
        FormData vehicleFormData = FormData.fromMap(await vehicle.toJson(_selectedImage));

        if(widget.vehicle == null) {
          createdVehicle =
          await ReceptionServices().createVehicle(vehicleFormData);
        }else{
          createdVehicle = widget.vehicle?.id;
        }

        if (createdVehicle != null) {
          final v = Visite(
              id: "",
              dateEntree: selectedDate ?? DateTime.now(),
              dateSortie: null,
              vehicleId: createdVehicle,
              status: "ATTENTE_DIAGNOSTIC",
              constatClient: controllers["reportedProblem"]!.text,
              elementsBord: ElementsBords(
                extincteur: onboardItems['Extincteur'] ?? false,
                dossier: onboardItems['Papier du véhicule'] ?? false,
                cric: onboardItems['Cric'] ?? false,
                boitePharmacie: onboardItems['Kit médical'] ?? false,
                boiteOutils: onboardItems['Boîte à outil'] ?? false,
                essuieGlace: false,
                autres: controllers['otherItems']!.text,
              ),
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
              diagnostics: [], companyId: ''
          );

          FormData vData = FormData.fromMap({
            "data": jsonEncode(v.toJson()), // Pas besoin de .toString()
          });

          int position = 0;
          for (var image in _vehicleConditionImages) {
            vData.files.add(MapEntry(
              'photos',
              await MultipartFile.fromFile(
                image.path,
                filename: 'condition_${position}_${DateTime.now().millisecondsSinceEpoch}.jpg',
              ),
            ));
            position++;
          }

          debugPrint("\nFILES (${vData.files.length}):");
          for (var file in vData.files) {
            debugPrint("  ${file.key}: ${file.value.filename} (${file.value.length} bytes)");
          }
          // Envoyer la visite avec les photos d'état
          await ReceptionServices().createVisite(vData, context);
          Navigator.pop(context);
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: ${e.toString()}')),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _controllerInit() {
    controllers['firstName']!.text = widget.vehicle?.client?.firstName ?? '';
    controllers['lastName']!.text = widget.vehicle?.client?.lastName ?? '';
    controllers['email']!.text = widget.vehicle?.client?.email ?? '';
    controllers['phone']!.text = widget.vehicle?.client?.phone ?? '';
    controllers['chassis']!.text = widget.vehicle?.chassis ?? '';
    controllers['licensePlate']!.text = widget.vehicle?.licensePlate ?? '';
    controllers['year']!.text = widget.vehicle?.year.toString() ?? '';
    controllers['mileage']!.text = widget.vehicle?.kilometrage.toString() ?? '';
  }

  @override
  void dispose() {
    controllers.forEach((_, c) => c.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appColor = Provider.of<AppAdaptiveColors>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Réception du véhicule"),
        elevation: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.only(right: 10, left: 10),
        child: Form(
          key: _formKey,
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.vehicle == null) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        3,
                            (index) => Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: 30,
                          height: 5,
                          decoration: BoxDecoration(
                            color: index == 2 ? appColor.primary : Colors.grey[300],
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Informations client
                  _buildSectionTitle("Informations du client"),
                  _buildStyledField(
                    hint: "Nom du client",
                    controller: controllers['lastName']!,
                    icon: Icons.person,
                    validator: (value) => value!.isEmpty ? 'Champ obligatoire' : null,
                  ),
                  _buildStyledField(
                    hint: "Prénom du client",
                    controller: controllers['firstName']!,
                    icon: Icons.person_outline,
                    validator: (value) => value!.isEmpty ? 'Champ obligatoire' : null,

                  ),
                  _buildStyledField(
                    hint: "Mail",
                    controller: controllers['email']!,
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) => value!.isNotEmpty && !value.contains('@')
                        ? 'Email invalide' : null,
                  ),
                  _buildStyledField(
                    hint: "Téléphone",
                    controller: controllers['phone']!,
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    validator: (value) => value!.isEmpty ? 'Champ obligatoire' : null,
                  ),

                  // Détails véhicule
                  _buildSectionTitle("Détail du véhicule"),
                  _buildStyledField(
                    hint: "Numéro de châssis",
                    controller: controllers['chassis']!,
                    validator: (value) => value!.isEmpty ? 'Champ obligatoire' : null,
                  ),
                  _buildStyledField(
                    hint: "Immatriculation",
                    controller: controllers['licensePlate']!,
                    validator: (value) => value!.isEmpty ? 'Champ obligatoire' : null,
                  ),
                  _buildStyledField(
                    hint: "Année de sortie",
                    controller: controllers['year']!,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value!.isEmpty) return 'Champ obligatoire';
                      final year = int.tryParse(value) ?? 0;
                      if (year <= 1900 || year > DateTime.now().year + 1) {
                        return 'Année invalide';
                      }
                      return null;
                    },
                  ),
                  _buildStyledField(
                    hint: "Kilométrage*",
                    controller: controllers['mileage']!,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value!.isEmpty) return 'Champ obligatoire';
                      final km = int.tryParse(value) ?? -1;
                      if (km < 0) return 'Valeur invalide';
                      return null;
                    },
                  ),

                  // Images
                  _buildSectionTitle("Image principale du véhicule"),
                  const SizedBox(height: 8),
                  Center(
                    child: _buildImagePreview(
                      _selectedImage,
                          () => _selectImageSource(isVehicleImage: true),
                      size: 100,
                    ),
                  ),
                  const SizedBox(height: 20),

                  _buildSectionTitle("Photos de l'état du véhicule (max 4)"),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      ..._vehicleConditionImages.asMap().entries.map((entry) {
                        return Stack(
                          children: [
                            _buildImagePreview(
                              entry.value,
                                  () => _viewImage(entry.value),
                              size: Responsive.responsiveValue(context, mobile: 85),
                            ),
                            Positioned(
                              top: -5,
                              right: -5,
                              child: IconButton(
                                icon: const Icon(Icons.close, color: Colors.red),
                                onPressed: () => _removeConditionImage(entry.key),
                              ),
                            ),
                          ],
                        );
                      }),
                      if (_vehicleConditionImages.length < 4)
                        _buildImagePreview(
                          null,
                              () => _selectImageSource(isVehicleImage: false),
                          size: Responsive.responsiveValue(context, mobile: 85),
                        ),
                    ],
                  ),

                  // Éléments à bord - Version Wrap
                  _buildSectionTitle("Éléments à bord"),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: onboardItems.entries.map((entry) {
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Checkbox(
                            value: entry.value,
                            onChanged: (value) => setState(() => onboardItems[entry.key] = value ?? false),
                            activeColor: AppColors.primary,
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          Text(entry.key),
                        ],
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 8),
                  _buildStyledField(
                    hint: "Autres éléments déclarés à bord",
                    controller: controllers['otherItems']!,
                  ),
                  // Problème signalé
                  _buildSectionTitle("Problème signalé"),
                  _buildStyledField(
                    hint: "Décrivez le problème...",
                    controller: controllers['reportedProblem']!,
                    isMultiline: true,
                    validator: (value) => value!.isEmpty ? 'Champ obligatoire' : null,

                  ),

                  // Date
                  _buildSectionTitle("Date d'entrée"),
                  _buildDateField(),
                  const SizedBox(height: 30),

                  // Boutons
                  if (isLoading)
                    const Center(child: CircularProgressIndicator())
                  else
                    _buildActionButtons(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _viewImage(File image) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: PhotoView(image: image),
      ),
    );
  }

  void _removeConditionImage(int index) {
    setState(() {
      _vehicleConditionImages.removeAt(index);
    });
  }

  Widget _buildImagePreview(File? image, VoidCallback onTap, {required double size}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: size,
        width: size,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: image != null
            ? ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(image, fit: BoxFit.cover),
        )
            : const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_a_photo, size: 30, color: Colors.grey),
              SizedBox(height: 4),
              Text('Ajouter', style: TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateField() {
    final appColor = Provider.of<AppAdaptiveColors>(context);
    return InkWell(
      onTap: () => _selectDate(context, appColor.primary),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                selectedDate != null
                    ? "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}"
                    : "Date d'entrée",
                style: AppStyles.bodySmall(context),
              ),
            ),
            const Icon(
              Icons.calendar_today,
              color: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildStyledField({
    required String hint,
    required TextEditingController controller,
    IconData? icon,
    TextInputType? keyboardType,
    bool isMultiline = false,
    String? Function(String?)? validator,
  }) {
    final appColor = Provider.of<AppAdaptiveColors>(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: isMultiline ? 5 : 1,
        validator: validator,
        decoration: InputDecoration(
          prefixIcon: icon != null ? Icon(icon, color: appColor.primary) : null,
          hintText: hint,
          filled: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.grey),
            borderRadius: BorderRadius.circular(16),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide:  BorderSide(color: appColor.primary, width: 1.5),
            borderRadius: BorderRadius.circular(16),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.red),
            borderRadius: BorderRadius.circular(16),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.red, width: 1.5),
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    final appColor = Provider.of<AppAdaptiveColors>(context);
    return  Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: appColor.primary.withOpacity(0.7),
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
            onPressed: isLoading ? null : _submitForm,
            style: ElevatedButton.styleFrom(
              backgroundColor: appColor.primary,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: isLoading
                ? CircularProgressIndicator(color: Colors.white)
                : Text(
              "Terminé",
              style: AppStyles.buttonText(context),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context, Color color) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(1990),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme:  ColorScheme.light(
            primary: color,
            onPrimary: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }
}

class PhotoView extends StatelessWidget {
  final File image;

  const PhotoView({super.key, required this.image});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: InteractiveViewer(
          panEnabled: true,
          minScale: 0.5,
          maxScale: 3.0,
          child: Image.file(image),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pop(context),
        child: const Icon(Icons.close),
      ),
    );
  }
}