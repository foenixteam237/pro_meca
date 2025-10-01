import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:country_code_picker/country_code_picker.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pro_meca/core/constants/app_adaptive_colors.dart';
import 'package:pro_meca/core/constants/app_styles.dart';
import 'package:pro_meca/core/features/pieces/services/pieces_services.dart';
import 'package:pro_meca/core/models/pieces.dart';
import 'package:pro_meca/core/widgets/imagePicker.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:provider/provider.dart';

class CreatePieceForm extends StatefulWidget {
  final BuildContext pContext;
  final String idCateg;
  final VoidCallback? onPieceCreated;
  final Piece? initialData;
  final bool isEditMode;

  const CreatePieceForm({
    super.key,
    required this.pContext,
    required this.idCateg,
    this.onPieceCreated,
    this.initialData,
    this.isEditMode = false,
  });

  @override
  State<CreatePieceForm> createState() => _CreatePieceFormState();
}

class _CreatePieceFormState extends State<CreatePieceForm> {
  final _formKey = GlobalKey<FormState>();

  // Contrôleurs
  final _nameCtrl = TextEditingController();
  final _referenceCtrl = TextEditingController();
  final _barcodeCtrl = TextEditingController();
  final _stockCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _sellingPriceCtrl = TextEditingController();
  final _criticalStockCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _sourceNameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _sourceLocationCtrl = TextEditingController();
  final _sourceNotesCtrl = TextEditingController();

  final _locationFocus = FocusNode();
  final _locationFieldKey = GlobalKey<FormFieldState<String>>();

  // Variables d'état
  DateTime? _purchaseDate;
  String? _selectedSourceType;
  String _selectedCountryCode = '+237';
  String _selectedCountryIso = 'cm';
  String? _phoneError;
  String? _selectedCondition;
  bool _utilise = false;
  File? _selectedImage;
  bool _isLoading = false;

  // Données pour les dropdowns
  final sourceTypes = [
    {"value": "PRO_PARTICULIER", "label": "Ancien mécanicien"},
    {"value": "BUYAM_SELLAM", "label": "Lieu informel de revente"},
    {"value": "GARAGE", "label": "Professionnel identifié"},
    {"value": "PARTICULIER", "label": "Particulier"},
    {"value": "RECUPERATION", "label": "Récupération sur vieux véhicule"},
    {"value": "AUTRE", "label": "Source inconnue"},
  ];

  final conditions = [
    {"value": "NEW", "label": "Neuf - Jamais utilisé"},
    {"value": "USED_GOOD", "label": "Occasion - Excellent état"},
    {"value": "USED_WORN", "label": "Occasion - Usure normale"},
    {"value": "USED_DAMAGED", "label": "Occasion - À réparer"},
    {"value": "UNKNOWN", "label": "État non vérifié"},
  ];

  Timer? _debounce;
  static const _debounceDuration = Duration(milliseconds: 300);

  // Gestion des modèles compatibles
  List<PieceModel> _availableModels = [];
  List<PieceModel> _selectedModels = [];
  bool _isLoadingModels = false;
  final _modelSearchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Initialisation avec les données existantes si en mode édition
    if (widget.isEditMode && widget.initialData != null) {
      _initializeWithExistingData();
    }

    _locationFocus.addListener(() {
      if (!_locationFocus.hasFocus) {
        _locationFieldKey.currentState?.validate();
      }
    });

    // Charger les modèles disponibles
    _loadAvailableModels();

    // Initialiser les modèles sélectionnés en mode édition
    if (widget.isEditMode && widget.initialData != null) {
      _selectedModels = widget.initialData!.modeleCompatibles ?? [];
    }
  }

  void _initializeWithExistingData() {
    final piece = widget.initialData!;

    _nameCtrl.text = piece.name;
    _referenceCtrl.text = piece.reference;
    _barcodeCtrl.text = piece.barcode ?? '';
    _stockCtrl.text = piece.stock.toString();
    _criticalStockCtrl.text = piece.criticalStock?.toString() ?? '';
    _locationCtrl.text = piece.location ?? '';
    _sellingPriceCtrl.text = piece.sellingPrice?.toString() ?? '';
    _notesCtrl.text = piece.notes ?? '';
    _purchaseDate = piece.purchaseDate;
    _selectedCondition = piece.condition;
    _utilise = piece.isUsed;

    // Source
    _selectedSourceType = piece.source?.type;
    _sourceNameCtrl.text = piece.source?.contactName ?? '';
    _sourceLocationCtrl.text = piece.source?.location ?? '';
    _sourceNotesCtrl.text = piece.source?.notes ?? '';

    // Téléphone
    if (piece.source?.phone != null && piece.source!.phone!.isNotEmpty) {
      _parseAndSetPhoneNumber(piece.source!.phone!);
    }
  }

  void _parseAndSetPhoneNumber(String phone) {
    if (phone.startsWith('+')) {
      final parts = phone.split('_');
      if (parts.isNotEmpty) {
        _selectedCountryCode = parts[0];
        _phoneCtrl.text = parts.length > 1
            ? parts[1]
            : phone.substring(_selectedCountryCode.length);
      } else {
        _phoneCtrl.text = phone;
      }
    } else {
      _phoneCtrl.text = phone.contains("_") ? phone.split('_')[1] : phone;
    }
  }

  Future<void> _loadAvailableModels({String searchQuery = ''}) async {
    setState(() => _isLoadingModels = true);
    try {
      final models = await PiecesService().fetchVehicleModels(
        context,
        searchQuery: searchQuery.isEmpty ? null : searchQuery,
      );
      setState(() => _availableModels = models);
    } catch (e) {
      debugPrint('Erreur chargement modèles: $e');
    } finally {
      setState(() => _isLoadingModels = false);
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _nameCtrl.dispose();
    _referenceCtrl.dispose();
    _barcodeCtrl.dispose();
    _stockCtrl.dispose();
    _criticalStockCtrl.dispose();
    _locationFocus.dispose();
    _locationCtrl.dispose();
    _sellingPriceCtrl.dispose();
    _notesCtrl.dispose();
    _sourceNameCtrl.dispose();
    _sourceLocationCtrl.dispose();
    _sourceNotesCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _scanBarcode() async {
    var result = await BarcodeScanner.scan();
    if (result.rawContent.isNotEmpty) {
      setState(() => _barcodeCtrl.text = result.rawContent);
    }
  }

  void _pickPurchaseDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _purchaseDate ?? DateTime.now(),
      firstDate: DateTime(1990),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() => _purchaseDate = date);
    }
  }

  bool _validateLocation(String value) {
    if (value.isEmpty) return false;

    // Premier caractère obligatoirement une lettre majuscule
    if (!value[0].contains(RegExp(r'[A-Z]'))) {
      return false;
    }

    // Si d'autres caractères sont présents, valider le format complet
    if (value.length > 1) {
      return RegExp(r'^[A-Z](-\d+)*(-[A-Z])?$').hasMatch(value);
    }

    return true;
  }

  Widget _buildModelSelector() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Modèles compatibles',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 10),

            // Barre de recherche
            TextField(
              controller: _modelSearchCtrl,
              decoration: InputDecoration(
                labelText: 'Rechercher un modèle',
                prefixIcon: Icon(Icons.search),
                suffixIcon: _modelSearchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () {
                          _modelSearchCtrl.clear();
                          _loadAvailableModels();
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                if (value.length >= 2) {
                  _loadAvailableModels(searchQuery: value);
                } else if (value.isEmpty) {
                  _loadAvailableModels();
                }
              },
            ),

            SizedBox(height: 10),

            // Liste des modèles disponibles
            Container(
              height: 150,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: _isLoadingModels
                  ? Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: _availableModels.length,
                      itemBuilder: (context, index) {
                        final model = _availableModels[index];
                        final isSelected = _selectedModels.any(
                          (m) => m.id == model.id,
                        );

                        return CheckboxListTile(
                          title: Text(model.displayName),
                          value: isSelected,
                          onChanged: (bool? selected) {
                            setState(() {
                              if (selected == true) {
                                _selectedModels.add(model);
                              } else {
                                _selectedModels.removeWhere(
                                  (m) => m.id == model.id,
                                );
                              }
                            });
                          },
                          dense: true,
                        );
                      },
                    ),
            ),

            SizedBox(height: 10),

            // Modèles sélectionnés
            if (_selectedModels.isNotEmpty) ...[
              Text('Modèles sélectionnés:'),
              SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: _selectedModels.map((model) {
                  return Chip(
                    label: Text(model.displayName),
                    onDeleted: () {
                      setState(() {
                        _selectedModels.remove(model);
                      });
                    },
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPhoneInput() {
    return Row(
      children: [
        Column(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey),
              ),
              child: CountryCodePicker(
                initialSelection: 'CM',
                favorite: ['CM', 'TD', 'CE'],
                onChanged: (country) {
                  setState(() {
                    _selectedCountryCode = country.dialCode!;
                    _selectedCountryIso = country.code!.toLowerCase();
                    if (_phoneError != null) _phoneError = null;
                  });
                },
                dialogBackgroundColor: Colors.transparent,
                boxDecoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      // color: Colors.black.withOpacity(0.1),
                      blurRadius: 0,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        SizedBox(width: 10),
        Expanded(
          child: TextFormField(
            controller: _phoneCtrl,
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
            ],
            decoration: InputDecoration(
              labelText: 'Téléphone source',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showPermissionError([String? message]) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message ??
              'Permission refusée. Veuillez autoriser l\'accès dans les paramètres',
        ),
        action: SnackBarAction(label: 'Paramètres', onPressed: openAppSettings),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> _selectImageSource() async {
    try {
      final source = await showImageSourceDialog(widget.pContext);
      if (source == null) return;

      if (source == ImageSource.camera && !await Permission.camera.isGranted) {
        await Permission.camera.request();
      } else if (source == ImageSource.gallery &&
          !await Permission.photos.isGranted) {
        await Permission.photos.request();
      }

      if ((source == ImageSource.camera && await Permission.camera.isGranted) ||
          (source == ImageSource.gallery &&
              await Permission.photos.isGranted)) {
        final pickedFile = await ImagePicker().pickImage(
          source: source,
          maxWidth: 800,
          maxHeight: 800,
          imageQuality: 85,
        );

        if (pickedFile != null) {
          setState(() => _selectedImage = File(pickedFile.path));
        }
      } else {
        _showPermissionError();
      }
    } on PlatformException catch (e) {
      _showPermissionError(e.message);
    }
  }

  Map<String, dynamic> _buildRequestData() {
    final Map<String, dynamic> data = {
      "name": _nameCtrl.text,
      "reference": _referenceCtrl.text,
      ...(_barcodeCtrl.text.isNotEmpty ? {"barcode": _barcodeCtrl.text} : {}),
      "stock": int.tryParse(_stockCtrl.text) ?? 0,
      "criticalStock": int.tryParse(_criticalStockCtrl.text) ?? 0,
      "location": _locationCtrl.text,
      "sellingPrice": double.tryParse(_sellingPriceCtrl.text),
      "purchaseDate": _purchaseDate?.toIso8601String(),
      "condition": _selectedCondition,
      ...(_notesCtrl.text.isNotEmpty ? {"notes": _notesCtrl.text} : {}),

      "source": {
        "type": _selectedSourceType,
        "contactName": _sourceNameCtrl.text,
        "phone": _phoneCtrl.text.isEmpty
            ? ''
            : '${_selectedCountryCode}_${_phoneCtrl.text}',
        "location": _sourceLocationCtrl.text.isEmpty
            ? ''
            : _sourceLocationCtrl.text,
        "notes": _sourceNotesCtrl.text.isEmpty ? '' : _sourceNotesCtrl.text,
      },

      "isUsed": _utilise,
      "categoryId": widget.isEditMode && widget.initialData != null
          ? widget.initialData!.category.id
          : widget.idCateg,
      "modeleIds": _selectedModels.map((model) => model.id).toList(),
    };

    if (widget.isEditMode && widget.initialData != null) {
      data["id"] = widget.initialData!.id;
    }

    return data;
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
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

      bool success;
      if (widget.isEditMode && widget.initialData != null) {
        success = await PiecesService().updatePiece(
          widget.initialData!.id,
          formData,
          context,
        );
      } else {
        success = await PiecesService().addPiece(formData, context);
      }

      if (success) {
        widget.onPieceCreated?.call();
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint(
        "Erreur ${widget.isEditMode ? 'édition' : 'création'} pièce: $e",
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Échec ${widget.isEditMode ? 'modification' : 'création'} de la pièce",
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _maybeGenerateReference() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;

    try {
      final ref = await PiecesService().getNextReference(name);
      setState(() => _referenceCtrl.text = ref);
    } catch (e) {
      debugPrint('Erreur génération référence : $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur génération référence')));
    }
  }

  void _onNameChanged(String value) {
    _debounce?.cancel();
    if (value.trim().isEmpty) return;
    _debounce = Timer(_debounceDuration, _maybeGenerateReference);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.isEditMode)
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.edit, size: 16, color: Colors.blue),
                    SizedBox(width: 8),
                    Text(
                      'Mode édition',
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

            Center(
              child: GestureDetector(
                onTap: _selectImageSource,
                child: CircleAvatar(
                  radius: 65,
                  backgroundImage: _selectedImage != null
                      ? FileImage(_selectedImage!)
                      : (widget.isEditMode &&
                                widget.initialData?.logo != null &&
                                widget.initialData!.logo!.isNotEmpty
                            ? NetworkImage(widget.initialData!.logo!)
                                  as ImageProvider
                            : null),
                  child:
                      _selectedImage == null &&
                          (!widget.isEditMode ||
                              widget.initialData?.logo == null ||
                              widget.initialData!.logo!.isEmpty)
                      ? Text(
                          'Cliquez pour ajouter une image',
                          textAlign: TextAlign.center,
                        )
                      : null,
                ),
              ),
            ),

            const SizedBox(height: 20),
            Text(
              'Identification',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 10),
            TextFormField(
              controller: _nameCtrl,
              decoration: InputDecoration(labelText: 'Nom de la pièce *'),
              validator: (v) => v!.isEmpty ? 'Nom requis' : null,
              onChanged: widget.isEditMode ? null : _onNameChanged,
            ),
            SizedBox(height: 10),
            TextFormField(
              readOnly: widget
                  .isEditMode, // En mode édition, la référence n'est pas modifiable
              controller: _referenceCtrl,
              inputFormatters: [UpperCaseTextFormatter()],
              decoration: InputDecoration(labelText: 'Référence *'),
              validator: (v) => v!.isEmpty ? 'Référence requise' : null,
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _barcodeCtrl,
                    decoration: InputDecoration(labelText: 'Code-barres'),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.qr_code_scanner),
                  onPressed: _scanBarcode,
                ),
              ],
            ),
            Divider(),
            SizedBox(height: 10),
            Text(
              'Origine (Source)',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 10),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(labelText: 'Type de source'),
              value: _selectedSourceType,
              items: sourceTypes
                  .map(
                    (e) => DropdownMenuItem(
                      value: e["value"],
                      child: Text(e["label"]!),
                    ),
                  )
                  .toList(),
              onChanged: (v) => setState(() => _selectedSourceType = v),
              validator: (v) => v == null ? 'Sélectionnez un type' : null,
            ),
            SizedBox(height: 10),
            TextFormField(
              controller: _sourceNameCtrl,
              decoration: InputDecoration(labelText: 'Nom du contact'),
            ),
            SizedBox(height: 10),
            _buildPhoneInput(),
            SizedBox(height: 10),
            TextFormField(
              controller: _sourceLocationCtrl,
              decoration: InputDecoration(labelText: 'Localisation source'),
            ),
            SizedBox(height: 10),
            TextFormField(
              controller: _sourceNotesCtrl,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: 'Notes sur la source (Ex: "Contacté via Facebook")',
                labelStyle: TextStyle(fontSize: 13),
              ),
            ),

            Divider(),
            SizedBox(height: 10),
            Text('Stock & Prix', style: Theme.of(context).textTheme.titleLarge),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _stockCtrl,
                    decoration: InputDecoration(
                      labelText: 'Qté actuelle',
                      prefixIcon: Icon(Icons.inventory, color: Colors.blue),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                      hintText: 'Stock disponible',
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                    ],
                    keyboardType: TextInputType.number,
                  ),
                ),
                SizedBox(width: 15),
                Expanded(
                  child: TextFormField(
                    controller: _criticalStockCtrl,
                    decoration: InputDecoration(
                      labelText: 'Seuil alerte',
                      prefixIcon: Icon(Icons.warning, color: Colors.orange),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.orange),
                      ),
                      hintText: 'Stock minimum avant alerte',
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                    ],
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            TextFormField(
              key: _locationFieldKey,
              controller: _locationCtrl,
              focusNode: _locationFocus,
              decoration: InputDecoration(
                labelText: 'Localisation pièce (A-12-4-B)',
                helperText:
                    'Exemple : A-12-4-B  →  Zone-Rangée-Étagère-Position',
                suffixIcon: const Icon(Icons.info_outline, size: 20),
              ),
              inputFormatters: [UpperCaseTextFormatter()],
              validator: (v) {
                if (v!.isEmpty) return null;
                return _validateLocation(v)
                    ? null
                    : 'Format invalide <Zone>-<Rangée>-<Étagère>-<Position>';
              },
            ),
            SizedBox(height: 10),

            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'État physique de la pièce',
              ),
              value: _selectedCondition,
              items: conditions
                  .map(
                    (e) => DropdownMenuItem(
                      value: e['value'],
                      child: Text(e['label']!),
                    ),
                  )
                  .toList(),
              onChanged: (v) {
                if (v != null && v.isNotEmpty) {
                  setState(() {
                    _selectedCondition = v;
                    if (v.contains("USED")) {
                      _utilise = true;
                    }
                  });
                }
              },
              validator: (v) => v == null ? 'Sélectionnez un état' : null,
            ),
            SizedBox(height: 10),
            TextFormField(
              controller: _sellingPriceCtrl,
              decoration: InputDecoration(labelText: 'Prix de vente *'),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
              ],
              validator: (v) => v!.isEmpty ? 'Prix obligatoire' : null,
            ),
            SizedBox(height: 10),
            ListTile(
              title: Text(
                _purchaseDate == null
                    ? 'Choisir date d\'achat'
                    : 'Date achat : ${DateFormat('dd/MM/yyyy').format(_purchaseDate!.toLocal())}',
              ),
              trailing: Icon(Icons.date_range),
              onTap: _pickPurchaseDate,
            ),

            Divider(),
            SizedBox(height: 10),
            Text(
              'Notes / Observations pièce',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            TextFormField(
              controller: _notesCtrl,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Notes (format, conditionnement, etc.)',
              ),
            ),
            SizedBox(height: 10),
            _buildModelSelector(),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey[700],
                    side: const BorderSide(color: Colors.grey),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            color: Colors.blueAccent,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Annuler'),
                ),
                ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppAdaptiveColors().secondary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(widget.isEditMode ? 'Modifier' : 'Enregistrer'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
