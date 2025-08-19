import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pro_meca/core/constants/app_adaptive_colors.dart';
import 'package:pro_meca/core/constants/app_styles.dart';
import 'package:pro_meca/core/features/pieces/services/pieces_services.dart';
import 'package:pro_meca/core/widgets/imagePicker.dart';
import 'package:provider/provider.dart';

class CreatePieceForm extends StatefulWidget {
  final BuildContext pContext;
  final String idCateg;
  const CreatePieceForm({super.key, required this.pContext, required this.idCateg});
  @override
  State<CreatePieceForm> createState() => _CreatePieceFormState();
}

class _CreatePieceFormState extends State<CreatePieceForm> {
  final _formKey = GlobalKey<FormState>();

  // Contrôleurs
  final TextEditingController _nomPieceController = TextEditingController();
  final TextEditingController _referenceController = TextEditingController();
  final TextEditingController _codeBarreController = TextEditingController();
  final TextEditingController _vendeurController = TextEditingController();
  final TextEditingController _telephoneController = TextEditingController();
  final TextEditingController _localisationController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _quantiteController = TextEditingController();
  final TextEditingController _limiteCritiqueController =
      TextEditingController();
  final TextEditingController _emplacementController = TextEditingController();
  final TextEditingController _dateAchatController = TextEditingController();
  final TextEditingController _prixVenteController = TextEditingController();
  // Dropdown État
  String? _etat = "PRO_PARTICULIER";
  String? _type = "NEW";
  // Checkbox utilisé
  bool _utilise = false;
  File? _selectedImage;
  bool _isLoading = false;


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

  Future<void> _selectImageSource() async {
    print("on essaie pcontext");

    try {
      final source = await showImageSourceDialog(widget.pContext);
      if (source == null) {
        print("null");
        return;
      }

      if (source == ImageSource.camera && !await Permission.camera.isGranted) {
        await Permission.camera.request();
      } else if (source == ImageSource.gallery && !await Permission.photos.isGranted) {
        await Permission.photos.request();
      }

      if((source == ImageSource.camera && await Permission.camera.isGranted) || (source == ImageSource.gallery && await Permission.photos.isGranted)) {
        final pickedFile = await ImagePicker().pickImage(
          source: source,
          maxWidth: 800,
          maxHeight: 800,
          imageQuality: 85,
        );

        if (pickedFile != null) {
          setState(() => _selectedImage = File(pickedFile.path));
        }
      }else{
        _showPermissionError();
      }

    } on PlatformException catch (e) {
     _showPermissionError(e.message);
    }
  }

  Map<String, dynamic> _buildRequestData() {
    return {
      "name": _nomPieceController.text.trim(),
      "reference": _referenceController.text.trim(),
      "barcode": _codeBarreController.text.trim(),
      "source" : {
        "type": _etat,
        "contactName": _vendeurController.text.trim(),
        "phone": _telephoneController.text.trim(),
        "location": _localisationController.text.trim(),
        "notes": _notesController.text.trim(),
      },
      "stock": int.tryParse(_quantiteController.text) ?? 0,
      "criticalStock": int.tryParse(_limiteCritiqueController.text) ?? 0,
      "location": _emplacementController.text.trim(),
      "condition": _type,
      "purchaseDate": _dateAchatController.text.trim(),
      "sellingPrice": double.tryParse(_prixVenteController.text) ?? 0.0,
      "isUsed": _utilise,
      "categoryId": widget.idCateg
    };
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return; // formulaire non valide
    }

    setState(() => _isLoading = true);
    try {
      final data = _buildRequestData();

      FormData formData = FormData();
      formData.fields.add(MapEntry('data', jsonEncode(data)));
      if (_selectedImage != null) {
        formData.files.add(
          MapEntry(
            "logo",
            await MultipartFile.fromFile(
              _selectedImage!.path,
              filename: _selectedImage!.path.split('/').last,
            ),
          ),
        );
      }
      bool create = await PiecesService().addPiece(formData, context);
      if (create) {
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur: $e")),
      );
    }finally{
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appColor = Provider.of<AppAdaptiveColors>(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.only(right: 5, left: 5, top: 20),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            // Image circulaire
            GestureDetector(
              onTap: () => _selectImageSource(),
              child: CircleAvatar(
                radius: 65,
                backgroundImage: _selectedImage != null
                    ? FileImage(_selectedImage!) // Affiche l'image sélectionnée
                    : AssetImage("assets/images/moteur.jpg") as ImageProvider,
              ),
            ),
            const SizedBox(height: 20),
            // Champs du formulaire
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildTextField(
                      "Nom de la pièce",
                      _nomPieceController,
                      isRequired: true,
                    ),
                    _buildTextField("Référence", _referenceController),
                  ],
                ),
                const SizedBox(height: 8),
                _buildTextField(
                  "Code barre de la pièce",
                  _codeBarreController,
                  flex: 2,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildTextField(
                      "Nom vendeur",
                      _vendeurController,
                      isRequired: true,
                    ),
                    _buildTextField(
                      "Téléphone vendeur",
                      _telephoneController,
                      isRequired: true,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildTextField(
                      "Localisation",
                      _localisationController,
                      isRequired: true,
                    ),
                    _buildTextField("Notes", _notesController),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildTextField(
                      "Quantité",
                      _quantiteController,
                      keyboard: TextInputType.number,
                      isRequired: true,
                    ),
                    _buildTextField(
                      "Limite critique",
                      _limiteCritiqueController,
                      keyboard: TextInputType.number,
                      isRequired: true,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildTextField("Emplacement", _emplacementController),
                    _buildDropdownEtat(),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildTextField("Date achat", _dateAchatController),
                    _buildTextField(
                      "Prix de vente",
                      _prixVenteController,
                      keyboard: TextInputType.number,
                      isRequired: true,
                      appColors: appColor,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Checkbox utilisé
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Checkbox(
                      activeColor: appColor.primary,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(4)),
                      ),
                      side: BorderSide(color: appColor.primary, width: 2),
                      value: _utilise,
                      onChanged: (val) {
                        setState(() => _utilise = val ?? false);
                      },
                    ),
                    Text("Utilisé", style: AppStyles.bodyLarge(context)),
                  ],
                ),
                _buildDropdownType(),
              ],
            ),
            const SizedBox(height: 20),
            // Boutons action
            Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildActionButton("Annuler", Colors.red, () {
                    Navigator.pop(context);
                  }),
                  _buildActionButton("Créer la pièce", appColor.primary, () {
                    if (_formKey.currentState!.validate()) {
                      // 🚀 Ici tu envoies les données au backend
                      _submitForm();
                      debugPrint(
                        "Création de la pièce : ${_nomPieceController.text}",
                      );
                    }
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Champ texte personnalisé
  Widget _buildTextField(
    String hint,
    TextEditingController controller, {
    int flex = 1,
    TextInputType keyboard = TextInputType.text,
    bool isRequired = false, // Ajout de l'argument isRequired
    AppAdaptiveColors? appColors,
  }) {
    return SizedBox(
      width: flex == 2
          ? double.infinity
          : (MediaQuery.of(context).size.width / 2) - 32,
      child: TextFormField(
        controller: controller,
        keyboardType: keyboard,
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: appColors?.primary ?? Colors.black),
          ),
        ),
        validator: (val) {
          if (isRequired && (val == null || val.isEmpty)) {
            return "Champ requis"; // Message d'erreur pour les champs requis
          }
          return null; // Pas d'erreur
        },
      ),
    );
  }

  /// Dropdown Etat
  Widget _buildDropdownEtat() {
    return SizedBox(
      width: (MediaQuery.of(context).size.width / 2) - 28,
      child: DropdownButtonFormField<String>(
        value: _etat,
        decoration: InputDecoration(
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
        ),
        items:  [
          DropdownMenuItem(value: "PRO_PARTICULIER", child: Text("Ancien mécanicien", style: AppStyles.bodyMedium(context))),
          DropdownMenuItem(value: "BUYAM_SELLAM", child: Text("Vendeur informel", style: AppStyles.bodyMedium(context))),
          DropdownMenuItem(value: "GARAGE", child: Text("Professionnel ",style: AppStyles.bodyMedium(context)),),
          DropdownMenuItem(value: "PARTICULIER", child: Text("Vendeur particulier", style: AppStyles.bodyMedium(context))),
          DropdownMenuItem(value: "RECUPERATION", child: Text("Pièces récupérées", style: AppStyles.bodyMedium(context))),
          DropdownMenuItem(value: "Autres", child: Text("Source inconnue",style: AppStyles.bodyMedium(context))),
        ],
        onChanged: (val) => setState(() => _etat = val),
        validator: (val) =>
            val == null ? "Champ requis" : null, // Validation pour le dropdown
      ),
    );
  }
  Widget _buildDropdownType() {
    return SizedBox(
      width: (MediaQuery.of(context).size.width / 2) - 28,
      child: DropdownButtonFormField<String>(
        value: _type,
        decoration: InputDecoration(
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
        ),
        items:  [
          DropdownMenuItem(value: "NEW", child: Text("Neuve", style: AppStyles.bodyMedium(context))),
          DropdownMenuItem(value: "USED_GOOD", child: Text("Excellent état", style: AppStyles.bodyMedium(context))),
          DropdownMenuItem(value: "USED_WORN", child: Text("Usure normale ",style: AppStyles.bodyMedium(context)),),
          DropdownMenuItem(value: "USED_DAMAGED", child: Text("À réparer", style: AppStyles.bodyMedium(context))),
          DropdownMenuItem(value: "RECUPERATION", child: Text("Pièces récupérées", style: AppStyles.bodyMedium(context))),
          DropdownMenuItem(value: "UNKNOWN", child: Text("UNKNOWN",style: AppStyles.bodyMedium(context))),
        ],
        onChanged: (val) => setState(() => _type = val),
        validator: (val) =>
        val == null ? "Champ requis" : null, // Validation pour le dropdown
      ),
    );
  }

  /// Bouton action (Annuler / Créer la pièce)
  Widget _buildActionButton(String text, Color color, VoidCallback onPressed) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        minimumSize: const Size(140, 45),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onPressed: onPressed,
      child: _isLoading && color != Colors.red ? const SizedBox(
        height: 22,
        width: 22,
        child: CircularProgressIndicator(
          color: Colors.white,
          strokeWidth: 2,
        ),
      ) : Text(text, style: const TextStyle(color: Colors.white)),
    );
  }
}
