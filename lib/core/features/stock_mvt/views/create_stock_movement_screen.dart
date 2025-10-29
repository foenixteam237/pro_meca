// create_stock_movement_screen.dart
import 'dart:convert';

import 'package:country_code_picker/country_code_picker.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show FilteringTextInputFormatter;
import 'package:intl/intl.dart';
import 'package:pro_meca/core/constants/app_adaptive_colors.dart';
import 'package:pro_meca/core/constants/app_colors.dart';
import 'package:pro_meca/core/constants/app_styles.dart';
import 'package:pro_meca/core/features/diagnostic/views/add_pieces_form.dart';
import 'package:pro_meca/core/features/factures/views/facture_detail_screen.dart';
import 'package:pro_meca/core/features/stock_mvt/services/stock_movement_service.dart';
import 'package:pro_meca/core/models/facture.dart';
import 'package:pro_meca/core/features/factures/services/facture_services.dart';
import 'package:pro_meca/core/models/stock_movement.dart';
import 'package:pro_meca/core/utils/validations.dart';
import 'package:provider/provider.dart';

class CreateStockMovementScreen extends StatefulWidget {
  final BuildContext parentContext;
  const CreateStockMovementScreen({super.key, required this.parentContext});

  @override
  State<CreateStockMovementScreen> createState() =>
      _CreateStockMovementScreenState();
}

class _CreateStockMovementScreenState extends State<CreateStockMovementScreen> {
  final StockMovementService _stockMovementService = StockMovementService();
  final FactureService _factureService = FactureService();
  final _formKey = GlobalKey<FormState>();

  // Données du mouvement
  final List<StockMovement> _mvtStocks = [];

  String _movementType = 'OUT';
  DateTime _mvtDate = DateTime.now();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _dateController = TextEditingController(
    text: DateFormat("y-M-d HH:mm:ss").format(DateTime.now()),
  );

  // Facturation
  bool _createFacture = false;
  Client? _selectedClient;
  final TextEditingController _clientSearchController = TextEditingController();
  List<Client> _searchClientResults = [];
  bool _searchingClient = false;

  // Formulaire client (nouveau client)
  final TextEditingController _clientFirstNameController =
      TextEditingController();
  final TextEditingController _clientLastNameController =
      TextEditingController();
  final TextEditingController _phoneCtrl = TextEditingController();
  final TextEditingController _clientEmailController = TextEditingController();
  final TextEditingController _clientAddressController =
      TextEditingController();
  final TextEditingController _clientCityController = TextEditingController();

  // Formulaire facture
  // final TextEditingController _factureReferenceController =
  //     TextEditingController();
  final TextEditingController _factureDateController = TextEditingController();
  final TextEditingController _factureDueDateController =
      TextEditingController();
  final TextEditingController _factureNotesController = TextEditingController();

  bool? _emailCheckResult;
  bool _emailChecking = false;
  bool _emailValid = true;
  bool _phoneValid = true;
  bool? _phoneCheckResult;
  bool _phoneChecking = false;
  String _selectedCountryCode = '+237';
  String _selectedCountryIso = 'cm';
  String? _phoneError;

  bool _isLoading = false;
  bool? _showNewClientForm = false;

  final DateFormat _dateFormat = DateFormat('yyyy-MM-ddTHH:mm:ss+01:00');

  bool _includeTVA = true;
  bool _includeIR = false;

  @override
  void initState() {
    super.initState();
    _dateController.text = DateFormat("y-M-d HH:mm:ss").format(DateTime.now());
    _factureDateController.text = DateFormat("y-M-d").format(DateTime.now());
    _factureDueDateController.text = DateFormat(
      "y-M-d",
    ).format(DateTime.now().add(Duration(days: 30)));
    // _generateFactureReference();
  }

  String _parsePhoneNumber(String phone) {
    String natPhone = '';
    if (phone.startsWith('+')) {
      final parts = phone.split('_');
      if (parts.isNotEmpty) {
        _selectedCountryCode = parts[0];
        natPhone = parts.length > 1
            ? parts[1]
            : phone.substring(_selectedCountryCode.length);
      } else {
        natPhone = phone;
      }
    } else {
      natPhone = phone.contains("_") ? phone.split('_')[1] : phone;
    }

    return natPhone;
  }

  // void _generateFactureReference() {
  //   final now = DateTime.now();
  //   final reference =
  //       'FACT-${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-${now.millisecond}';
  //   _factureReferenceController.text = reference;
  // }

  Future<bool> _checkEmail() async {
    if (_emailCheckResult == true) {
      return true;
    }
    if (_clientEmailController.text.isEmpty) {
      setState(() => _emailCheckResult = null);
      return true;
    }
    setState(() => _emailChecking = true);
    try {
      final exists = await _stockMovementService.checkEmailExists(
        _clientEmailController.text,
      );
      setState(() {
        _emailValid = !exists;
        _emailCheckResult = !exists;
      });
    } catch (e) {
      setState(() {
        _emailValid = false;
        _emailCheckResult = false;
      });
    } finally {
      setState(() => _emailChecking = false);
    }
    return _emailValid;
  }

  Future<bool> _checkPhone() async {
    if (_phoneCheckResult == true) {
      return true;
    }
    if (_phoneCtrl.text.isEmpty) {
      setState(() => _phoneCheckResult = null);
      return false;
    }

    setState(() => _phoneChecking = true);
    try {
      final exists = await _stockMovementService.checkPhoneExists(
        "${_selectedCountryCode}_${_phoneCtrl.text}",
      );

      setState(() {
        _phoneValid = !exists;
        _phoneCheckResult = !exists;
      });
    } catch (e) {
      setState(() {
        _phoneValid = false;
        _phoneCheckResult = false;
      });
    } finally {
      setState(() => _phoneChecking = false);
    }
    return _phoneValid;
  }

  void _showPieceSelectionModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, controller) => PieceSelectionModal(
          onPieceAdded: (pieceData) {
            _addPiece(pieceData);
            Navigator.pop(context);
          },
          onCancel: () {
            Navigator.pop(context);
          },
          isMovement: true,
        ),
      ),
    );
  }

  void _addPiece(Map<String, dynamic> pieceData) {
    if (pieceData['id'] == null) {
      debugPrint('❌ ERREUR: pieceData sans ID: $pieceData');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: Pièce sans identifiant'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    setState(() {
      // Vérifier si la pièce existe déjà en comparant les ID
      int existingIndex = _mvtStocks.indexWhere(
        (mvt) => mvt.piece.id == pieceData['id'],
      );

      if (existingIndex != -1) {
        // La pièce existe déjà, on additionne les quantités
        int existingQuantity = _mvtStocks[existingIndex].quantity;
        int newQuantity = pieceData['quantity'] ?? 0;
        _mvtStocks[existingIndex].quantity = existingQuantity + newQuantity;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Quantité de "${pieceData['name'] ?? 'Pièce sans nom'}" mise à jour: ${_mvtStocks[existingIndex].quantity}',
            ),
            backgroundColor: AppColors.primary,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        // Nouvelle pièce, on l'ajoute à la liste
        _mvtStocks.add(
          StockMovement(
            date: _mvtDate,
            piece: PieceMvt(
              id: pieceData['id'],
              name: pieceData['name'] ?? '',
              reference: pieceData['reference'] ?? '',
              category: pieceData['category'] ?? '',
              currentStock: pieceData['stock'],
            ),
            quantity: pieceData['quantity'],
            sellingPriceAtMovement: pieceData['unitPrice'],
            stockAfterMovement: _movementType == 'IN'
                ? pieceData['stock'] + pieceData['quantity']
                : pieceData['stock'] - pieceData['quantity'],
            type: _movementType,
          ),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Pièce "${pieceData['name'] ?? 'Sans nom'}" ajoutée avec succès',
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }

      if (kDebugMode) {
        print('Liste des pièces mise à jour: $_mvtStocks');
      }
    });
  }

  void _removePiece(int index) {
    setState(() {
      _mvtStocks.removeAt(index);
    });
  }

  void _searchClient(String query) async {
    if (query.length < 2) {
      setState(() {
        _searchClientResults = [];
      });
      return;
    }

    setState(() {
      _searchingClient = true;
    });

    try {
      final clients = await _factureService.searchClients(query);
      setState(() {
        _searchClientResults = clients;
      });
    } catch (e) {
      if (kDebugMode) {
        debugPrint("Erreur recherche client: $e");
      }
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erreur recherche client')));
      }
    } finally {
      setState(() {
        _searchingClient = false;
      });
    }
  }

  void _selectClient(Client client) {
    setState(() {
      _selectedClient = client;
      _clientSearchController.text = client.fullName;
      _searchClientResults = [];
      _showNewClientForm = null;

      // Pré-remplir les champs du client
      _clientFirstNameController.text = client.firstName;
      _clientLastNameController.text = client.lastName;
      _phoneCtrl.text = client.phone ?? '';
      _clientEmailController.text = client.email ?? '';
      _clientAddressController.text = client.address ?? '';
      _clientCityController.text = client.city ?? '';
    });
  }

  Future<void> _createNewClient() async {
    if (_clientFirstNameController.text.isEmpty || _phoneCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Le prénom et le téléphone sont obligatoires'),
        ),
      );
      return;
    }

    if (!_emailValid || !_phoneValid) return;

    if (await _checkEmail() == false) return;
    if (await _checkPhone() == false) return;

    setState(() => _isLoading = true);

    try {
      final clientData = {
        'firstName': _clientFirstNameController.text,
        ...(_clientLastNameController.text.isEmpty
            ? {}
            : {'lastName': _clientLastNameController.text}),
        ...(_phoneCtrl.text.isEmpty
            ? {}
            : {'phone': '${_selectedCountryCode}_${_phoneCtrl.text}'}),
        ...(_clientEmailController.text.isEmpty
            ? {}
            : {'email': _clientEmailController.text}),
        ...(_clientAddressController.text.isEmpty
            ? {}
            : {'address': _clientAddressController.text}),
        ...(_clientCityController.text.isEmpty
            ? {}
            : {'city': _clientCityController.text}),
      };

      FormData formData = FormData();

      formData.fields.add(MapEntry('data', jsonEncode(clientData)));

      final newClient = await _factureService.createClient(formData);
      _selectClient(newClient);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Client créé avec succès')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur création client: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Méthode pour valider et parser les dates en toute sécurité
  DateTime? _safeParseDate(String dateString, {bool allowFuture = false}) {
    if (dateString.isEmpty) return null;

    try {
      final date = DateTime.parse(dateString);

      // Vérifier que c'est une date valide (éviter les dates comme 2023-02-30)
      if (date.year < 2000 || date.year > 2100) return null;

      // Vérifier que la date n'est pas dans le futur (sauf si autorisé)
      if (!allowFuture && date.isAfter(DateTime.now())) {
        return null;
      }

      return date;
    } catch (e) {
      debugPrint('Erreur parsing date: $e');
      return null;
    }
  }

  // Méthode pour valider toutes les dates avant envoi
  bool _validateDates() {
    // Valider la date du mouvement
    final movementDate = _safeParseDate(_dateController.text);
    if (movementDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Date du mouvement invalide')),
      );
      return false;
    }

    // Valider la date de facture si création de facture
    if (_createFacture) {
      final factureDate = _safeParseDate(
        _factureDateController.text,
        allowFuture: true,
      );
      if (factureDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Date de facture invalide')),
        );
        return false;
      }

      // Valider la date d'échéance si renseignée
      if (_factureDueDateController.text.isNotEmpty) {
        final dueDate = _safeParseDate(
          _factureDueDateController.text,
          allowFuture: true,
        );
        if (dueDate == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Date d\'échéance invalide')),
          );
          return false;
        }

        // Vérifier que l'échéance est après la date de facture
        if (dueDate.isBefore(factureDate)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('L\'échéance doit être après la date de facture'),
            ),
          );
          return false;
        }
      }
    }

    return true;
  }

  Future<void> _createMovement() async {
    DateTime.now().toUtc().add(const Duration(hours: 1)); // GMT+1
    if (!_formKey.currentState!.validate()) return;

    if (!_validateDates()) {
      return;
    }

    // Vérifier que toutes les pièces sont sélectionnées
    for (final mvt in _mvtStocks) {
      if (mvt.piece.id == null || mvt.piece.id!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Veuillez sélectionner une pièce pour chaque ligne'),
          ),
        );
        return;
      }
    }

    if (_mvtStocks.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ajoutez au moins une pièce')),
      );
      return;
    }

    if (_createFacture && _selectedClient == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sélectionnez ou créez un client pour la facture'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      Map<String, dynamic>? factureData;

      // Créer la facture si demandé
      if (_createFacture && _selectedClient != null) {
        final factureDate = _safeParseDate(
          _factureDateController.text,
          allowFuture: true,
        )!;
        final dueDate = _factureDueDateController.text.isNotEmpty
            ? _safeParseDate(_factureDueDateController.text, allowFuture: true)
            : null;
        factureData = {
          // 'reference': _factureReferenceController.text,
          'date': _dateFormat.format(factureDate),
          if (dueDate != null) 'dueDate': _dateFormat.format(dueDate),
          'clientId': _selectedClient!.id,
          if (_factureNotesController.text.isNotEmpty)
            'notes': _factureNotesController.text,
          'lines': _mvtStocks
              .map(
                (mvt) => {
                  'pieceId': mvt.piece.id,
                  'description': mvt.piece.name,
                  'quantity': mvt.quantity,
                  'unitPrice': mvt.sellingPriceAtMovement ?? 0,
                },
              )
              .toList(),
          'includeTVA': _includeTVA,
          'includeIR': _includeIR,
        };
      }

      String? factureId;

      // Créer les mouvements de stock
      StockMovement? lastCreatedMvt;
      for (final mvt in _mvtStocks) {
        final movementData = {
          'pieceId': mvt.piece.id,
          'type': _movementType,
          'quantity': mvt.quantity,
          'date': '${_mvtDate.toIso8601String().split('.')[0]}Z',
          if (_descriptionController.text.isNotEmpty)
            'description': _descriptionController.text,
          if (factureId != null)
            'factureId': factureId
          else if (factureData != null)
            'facture': factureData,
          if (mvt.sellingPriceAtMovement != null)
            'sellingPriceAtMovement': mvt.sellingPriceAtMovement,
          if (mvt.stockAfterMovement != null)
            'stockAfterMovement': mvt.stockAfterMovement,
        };
        lastCreatedMvt = await _stockMovementService.createMovement(
          movementData,
        );

        if (lastCreatedMvt.facture != null &&
            lastCreatedMvt.facture!.id.isNotEmpty &&
            factureId == null) {
          factureId = lastCreatedMvt.facture?.id;
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mouvement créé avec succès')),
      );

      // Navigation après succès
      if (_createFacture && lastCreatedMvt?.facture != null) {
        _showFacturePreview(lastCreatedMvt!.facture!);
      } else {
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint('Erreur création mouvement: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur lors de la création: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showFacturePreview(Facture facture) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Facture créée avec succès'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Référence: ${facture.reference}'),
            Text('Client: ${facture.client.fullName}'),
            Text('Total HT: ${facture.totalHT.toStringAsFixed(0)} FCFA'),
            const SizedBox(height: 16),
            const Text('Voulez-vous générer le PDF de la facture ?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
          ElevatedButton(
            onPressed: () {
              // Naviguer vers l'écran de détail de la facture pour générer le PDF
              Navigator.push(
                widget.parentContext,
                MaterialPageRoute(
                  builder: (context) => FactureDetailScreen(facture: facture),
                ),
              );
              Navigator.pop(context);
            },
            child: const Text('Générer PDF'),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(
    BuildContext context,
    TextEditingController controller, {
    DateTime? lastDate,
  }) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: lastDate ?? DateTime.now(),
      locale: Locale('fr', 'FR'),
    );

    if (picked != null) {
      // Get the current time
      final currentTime = DateTime.now();
      // Combine the picked date with the current time
      final combinedDateTime = DateTime(
        picked.year,
        picked.month,
        picked.day,
        currentTime.hour,
        currentTime.minute,
        currentTime.second,
      );
      // Format and set the controller text
      controller.text = DateFormat("y-M-d HH:mm:ss").format(combinedDateTime);
      setState(() {
        _mvtDate = combinedDateTime;
      });
    }
  }

  double get _totalAmount {
    return _mvtStocks.fold(
      0.0,
      (sum, mvt) => sum + (mvt.quantity * (mvt.sellingPriceAtMovement ?? 0)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Provider.of<AppAdaptiveColors>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Nouveau Mouvement de Stock')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Type de mouvement
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: 16,
                        right: 16,
                        bottom: 10,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Type de Mouvement',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            value: _movementType,
                            decoration: const InputDecoration(
                              labelText: 'Type',
                              border: OutlineInputBorder(),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'IN',
                                child: Text('Entrée de stock'),
                              ),
                              DropdownMenuItem(
                                value: 'OUT',
                                child: Text('Sortie de stock'),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _movementType = value!;
                                _createFacture = value == 'OUT'
                                    ? _createFacture
                                    : false;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Date et description
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: 16,
                        right: 16,
                        bottom: 10,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Informations Générales',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _dateController,
                            decoration: const InputDecoration(
                              labelText: 'Date du mouvement',
                              border: OutlineInputBorder(),
                              suffixIcon: Icon(Icons.calendar_today),
                            ),
                            readOnly: true,
                            onTap: () => _selectDate(context, _dateController),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'La date est obligatoire';
                              }
                              try {
                                DateTime.parse(value);
                                return null;
                              } catch (e) {
                                return 'Date invalide';
                              }
                            },
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _descriptionController,
                            decoration: InputDecoration(
                              labelText: 'Motif(s)',
                              hintText:
                                  'Exemples: perte, casse, don, ou utilisation interne',
                              border: OutlineInputBorder(),
                              alignLabelWithHint: true,
                            ),
                            maxLines: 3,
                            textAlignVertical: TextAlignVertical.top,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Divider(),

                  // Liste des pièces ajoutées
                  Card(
                    // elevation: 4,
                    // shape: RoundedRectangleBorder(
                    //   borderRadius: BorderRadius.circular(16),
                    //   side: BorderSide(
                    //     color: Theme.of(
                    //       context,
                    //     ).dividerColor.withValues(alpha: 0.3),
                    //     width: 1,
                    //   ),
                    // ),
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: 16,
                        right: 16,
                        bottom: 10,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Pièces Ajoutées (${_mvtStocks.length})',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Spacer(),
                              if (_mvtStocks.isNotEmpty)
                                Text(
                                  'Total: ${_totalAmount.toStringAsFixed(0)} FCFA',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                              // else
                              //   ElevatedButton(
                              //     onPressed: () {
                              //       _showPieceSelectionModal(context);
                              //     },
                              //     style: ElevatedButton.styleFrom(
                              //       backgroundColor: appColors.primary,
                              //     ),
                              //     child: Text(
                              //       'Ajouter',
                              //       style: TextStyle(color: Colors.white),
                              //     ),
                              //   ),
                            ],
                          ),

                          if (_mvtStocks.isEmpty)
                            Container(
                              padding: EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.grey[300]!,
                                  style: BorderStyle.solid,
                                ),
                                borderRadius: BorderRadius.circular(8),
                                color: appColors.customBackground(context),
                              ),
                              child: Center(
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.build_outlined,
                                      size: 48,
                                      color: appColors.primary,
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Aucune pièce ajoutée',
                                      style: AppStyles.bodyMedium(context),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          else ...[
                            const SizedBox(height: 12),
                            ..._mvtStocks.map(
                              (mvt) =>
                                  _buildPieceItem(_mvtStocks.indexOf(mvt), mvt),
                            ),
                          ],
                          // Bouton d'ajout d'une pièce
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  _showPieceSelectionModal(context);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: appColors.primary,
                                ),
                                child: Text(
                                  'Ajouter une pièce',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Divider(),

                  // Facturation (uniquement pour les sorties)
                  if (_movementType == 'OUT') ...[
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.only(
                          left: 16,
                          right: 16,
                          bottom: 10,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text(
                                  'Facturation',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Spacer(),
                                Switch(
                                  value: _createFacture,
                                  onChanged: (value) {
                                    setState(() {
                                      _createFacture = value;
                                    });
                                  },
                                ),
                              ],
                            ),
                            if (_createFacture) ...[
                              const SizedBox(height: 16),
                              _buildFactureForm(),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Bouton de soumission
                  ElevatedButton(
                    onPressed: _createMovement,
                    child: const Text('Créer le mouvement'),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  Widget _buildToggleSwitch({
    required bool value,
    required ValueChanged<bool> onChanged,
    required String label,
    required IconData icon,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: value ? Colors.green : Colors.grey),
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: Theme.of(context).primaryColor,
        ),
      ],
    );
  }

  Widget _buildPieceItem(int index, StockMovement mvt) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Couleurs adaptées au thème
    final textColor = isDark ? Colors.grey[300]! : Colors.black87;
    final refTextColor = isDark ? Colors.grey[400]! : Colors.grey[600]!;
    final chipBgBaseColor = isDark ? Colors.grey[700]! : Colors.grey[200]!;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /* ----------  Titre  ---------- */
            Row(
              children: [
                /* Partie texte (nom + ref) */
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /* Nom de la pièce – texte tronqué si trop long */
                      Text(
                        mvt.piece.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      /* Référence – plus petite */
                      Text(
                        'Réf: ${mvt.piece.reference}',
                        style: TextStyle(fontSize: 12, color: refTextColor),
                      ),
                    ],
                  ),
                ),
                /* Bouton suppression */
                IconButton(
                  icon: const Icon(Icons.remove_circle, color: Colors.red),
                  onPressed: () => _removePiece(index),
                ),
              ],
            ),
            const SizedBox(height: 8),

            /* ----------  Chips  ---------- */
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                Chip(
                  label: Text(
                    'Qté: ${mvt.quantity}',
                    style: TextStyle(color: textColor),
                  ),
                  backgroundColor: chipBgBaseColor.withValues(alpha: 0.5),
                ),
                // Chip(
                //   label: Text(
                //     'Prix: ${mvt.sellingPriceAtMovement.toStringAsFixed(0)} FCFA',
                //     style: TextStyle(color: textColor),
                //   ),
                //   backgroundColor: chipBgBaseColor.withValues(alpha: 0.3),
                // ),
                Chip(
                  label: Text(
                    mvt.sellingPriceAtMovement != null
                        ? 'Total: ${(mvt.quantity * mvt.sellingPriceAtMovement!).toStringAsFixed(0)} FCFA'
                        : 'Total: N/A',
                    style: TextStyle(color: textColor),
                  ),
                  backgroundColor: chipBgBaseColor.withValues(alpha: 0.4),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFactureForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Recherche client
        TextFormField(
          controller: _clientSearchController,
          decoration: InputDecoration(
            labelText: 'Rechercher un client',
            border: const OutlineInputBorder(),
            suffixIcon: _searchingClient
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : IconButton(
                    onPressed: () {
                      return _searchClient(_clientSearchController.text);
                    },
                    icon: Icon(Icons.search),
                  ),
          ),
          onChanged: _searchClient,
        ),

        // Résultats de recherche
        if (_searchClientResults.isNotEmpty)
          Card(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 200),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _searchClientResults.length,
                itemBuilder: (context, index) {
                  final client = _searchClientResults[index];
                  return ListTile(
                    title: Text(client.fullName),
                    subtitle: Text(_parsePhoneNumber(client.phone ?? '')),
                    trailing: const Icon(Icons.add),
                    onTap: () => _selectClient(client),
                  );
                },
              ),
            ),
          ),

        // Option nouveau client
        if (_searchClientResults.isEmpty &&
            _clientSearchController.text.isNotEmpty)
          ListTile(
            leading: const Icon(Icons.person_add),
            title: _selectedClient == null
                ? Text('Créer un nouveau client')
                : _selectedClient!.fullName.toLowerCase().contains(
                    _clientSearchController.text.toLowerCase(),
                  )
                ? Text(
                    '${_showNewClientForm == null ? "Continuer avec" : "Afficher"} ${_selectedClient!.fullName}',
                    style: TextStyle(overflow: TextOverflow.ellipsis),
                  )
                : Text('Créer un nouveau client'),
            onTap: () {
              setState(() {
                if (_selectedClient == null) {
                  setNewClient();
                } else {
                  if (_selectedClient!.fullName.toLowerCase().contains(
                    _clientSearchController.text.toLowerCase(),
                  )) {
                    _showNewClientForm = _showNewClientForm == false
                        ? null
                        : false;
                  } else {
                    _selectedClient = null;
                    setNewClient();
                  }
                }
              });
            },
          ),

        // Formulaire nouveau client
        if (_showNewClientForm == true ||
            _showNewClientForm == null /* || _selectedClient == null */ ) ...[
          const SizedBox(height: 16),
          const Text(
            'Informations du Client',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  enabled: _showNewClientForm == true,
                  controller: _clientFirstNameController,
                  decoration: const InputDecoration(
                    labelText: 'Prénom *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Le prénom est obligatoire';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  enabled: _showNewClientForm == true,
                  controller: _clientLastNameController,
                  decoration: const InputDecoration(
                    labelText: 'Nom',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Téléphone client
          _buildPhoneInput(),
          const SizedBox(height: 12),
          TextFormField(
            enabled: _showNewClientForm == true,
            controller: _clientEmailController,
            decoration: InputDecoration(
              labelText: 'Email',
              border: OutlineInputBorder(),
              suffixIcon: _emailChecking
                  ? const SizedBox(
                      width: 15,
                      height: 15,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(
                      _emailValid ? Icons.check_circle : Icons.error,
                      color: _emailValid ? Colors.green : Colors.red,
                    ),
              errorText: _emailValid ? null : 'Email invalide ou déjà utilisé',
            ),
            keyboardType: TextInputType.emailAddress,
            onChanged: (email) => setState(() {
              _emailValid = validateEmail(email);
              if (email.isNotEmpty) {
                _emailCheckResult = null;
              }
            }),

            validator: (value) => _emailValid ? null : 'Email invalide',
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  enabled: _showNewClientForm == true,
                  controller: _clientAddressController,
                  decoration: const InputDecoration(
                    labelText: 'Adresse',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  enabled: _showNewClientForm == true,
                  controller: _clientCityController,
                  decoration: const InputDecoration(
                    labelText: 'Ville',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_showNewClientForm == true)
            ElevatedButton(
              onPressed: _createNewClient,
              child: const Text('Créer le client'),
            ),
        ],

        // Informations facture
        if (_selectedClient != null) ...[
          const SizedBox(height: 16),
          const Text(
            'Informations de la Facture',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          // TextFormField(
          //   controller: _factureReferenceController,
          //   decoration: const InputDecoration(
          //     labelText: 'Référence facture',
          //     border: OutlineInputBorder(),
          //   ),
          //   validator: (value) {
          //     if (value == null || value.isEmpty) {
          //       return 'La référence est obligatoire';
          //     }
          //     return null;
          //   },
          // ),
          // const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _factureDateController,
                  decoration: const InputDecoration(
                    labelText: 'Date facture',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  readOnly: true,
                  onTap: () => _selectDate(context, _factureDateController),
                  validator: (value) {
                    try {
                      if (value == null) return 'Date invalide';
                      DateTime.parse(value);
                      return null;
                    } catch (e) {
                      return 'Date invalide';
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _factureDueDateController,
                  decoration: const InputDecoration(
                    labelText: 'Échéance (optionnelle)',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  readOnly: true,
                  onTap: () => _selectDate(
                    context,
                    _factureDueDateController,
                    lastDate: DateTime(3200),
                  ),
                  validator: (value) {
                    try {
                      if (value == null) return 'Date invalide';
                      DateTime.parse(value);
                      return null;
                    } catch (e) {
                      return 'Date invalide';
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                child: _buildToggleSwitch(
                  value: _includeTVA,
                  onChanged: (value) => setState(() => _includeTVA = value),
                  label: 'TVA',
                  icon: Icons.attach_money,
                ),
              ),
              Container(
                child: _buildToggleSwitch(
                  value: _includeIR,
                  onChanged: (value) => setState(() => _includeIR = value),
                  label: 'IR',
                  icon: Icons.percent_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _factureNotesController,
            decoration: const InputDecoration(
              labelText: 'Notes (optionnel)',
              border: OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
            maxLines: 3,
            textAlignVertical: TextAlignVertical.top,
          ),
        ],
      ],
    );
  }

  void setNewClient() {
    String prenom = _clientSearchController.text.isNotEmpty
        ? _clientSearchController.text.split(' ')[0]
        : '';
    _showNewClientForm = true;
    _clientFirstNameController.text = prenom;
    _clientLastNameController.text = _clientSearchController.text
        .substring(prenom.length)
        .trim();
    _phoneCtrl.text = '';
    _clientEmailController.text = '';
    _clientAddressController.text = '';
    _clientCityController.text = '';
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
                enabled: _showNewClientForm == true,
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
            enabled: _showNewClientForm == true,
            controller: _phoneCtrl,
            keyboardType: TextInputType.phone,
            onChanged: (phone) => setState(() {
              _phoneValid = validatePhone(phone, _selectedCountryIso);
              _phoneCheckResult = null;
            }),
            onEditingComplete: _checkPhone,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
            ],
            decoration: InputDecoration(
              labelText: 'Téléphone',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              suffixIcon: _phoneChecking
                  ? const SizedBox(
                      width: 15,
                      height: 15,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(
                      _phoneValid ? Icons.check_circle : Icons.error,
                      color: _phoneValid ? Colors.green : Colors.red,
                    ),
              errorText: _phoneValid ? null : 'Invalide ou déjà utilisé',
            ),
            validator: (value) {
              if (value!.isEmpty) return 'Champ requis';
              if (!validatePhone(_phoneCtrl.text, _selectedCountryIso)) {
                return 'Téléphone invalide';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }
}
