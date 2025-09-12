import 'package:flutter/material.dart';
import 'package:pro_meca/core/constants/app_adaptive_colors.dart';
import 'package:pro_meca/core/constants/app_colors.dart';
import 'package:pro_meca/core/constants/app_styles.dart';
import 'package:pro_meca/core/features/diagnostic/services/diagnostic_services.dart';
import 'package:pro_meca/core/features/diagnostic/views/add_pieces_form.dart';
import 'package:pro_meca/core/features/users/services/users_services.dart';
import 'package:pro_meca/core/models/dysfonctionnement.dart';
import 'package:pro_meca/core/models/role.dart';
import 'package:pro_meca/core/models/user.dart';
import 'package:pro_meca/core/widgets/customAppBar.dart';
import 'package:pro_meca/l10n/arb/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:pro_meca/core/models/type_intervention.dart';

import '../../../models/maintenance_task.dart';
import '../../../widgets/functions.dart';

class InterventionForm extends StatefulWidget {
  final Widget header;
  final String visiteId;
  final Dysfonctionnement dys;
  final String? techName;
  final String accessToken;
  final Function(MaintenanceTask)? onTaskAdd;
  const InterventionForm({
    super.key,
    required this.header,
    required this.visiteId,
    required this.dys,
    required this.techName,
    required this.accessToken,
    this.onTaskAdd,
  });

  @override
  // ignore: library_private_types_in_public_api
  _InterventionFormState createState() => _InterventionFormState();
}

class _InterventionFormState extends State<InterventionForm> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _otherTypeController = TextEditingController();

  // Contrôleurs pour les valeurs sélectionnées
  String? selectedInterventionTypeId;
  String? selectedInterventionTypeName;
  String? selectedSubTypeId;
  String? selectedSubTypeName;
  String? selectedAssigneeId;
  String selectedAssigneeName = 'Technicien affecté';
  String selectedPriority = 'Priorité';

  // Add lists for dropdown data
  List<InterventionType> interventionTypes = [];
  List<SubType> interventionSubTypes = [];

  // Données pour les techniciens (à récupérer depuis l'API)
  List<User> assigneesTech = [];

  // Liste des pièces ajoutées
  List<Map<String, dynamic>> piecesList = [];

  //1:Très haute, 2: Haute, 3:Moyenne, 4:Basse, 5:Très basse
  List<Map<String, dynamic>> priorities = [
    {'value': 1, 'name': 'Très Haute'},
    {'value': 2, 'name': 'Haute'},
    {'value': 3, 'name': 'Moyenne'},
    {'value': 4, 'name': 'Basse'},
    {'value': 5, 'name': 'Très Basse'},
  ];

  bool isLoading = false;
  bool showOtherTypeField = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _loadTypesIntervention();
    _loadTechnicians();
  }

  Future<void> _loadTypesIntervention() async {
    setState(() {
      isLoading = true;
    });

    try {
      final types = await DiagnosticServices().fetchInterventionTypes();

      setState(() {
        interventionTypes = types;
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Erreur lors du chargement des types d\'intervention: $error',
          ),
        ),
      );
    }
  }

  Future<void> _loadTechnicians() async {
    setState(() {
      isLoading = true;
    });
    try {
      final types = await UserService().getAllTechnician();

      setState(() {
        assigneesTech = types;
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors du chargement des techniciens: $error'),
        ),
      );
    }
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
        ),
      ),
    );
  }

  void _addPiece(Map<String, dynamic> pieceData) {
    setState(() {
      // Vérifier si la pièce existe déjà en comparant les ID
      int existingIndex = piecesList.indexWhere(
        (piece) => piece['id'] == pieceData['id'],
      );

      if (existingIndex != -1) {
        // La pièce existe déjà, on additionne les quantités
        int existingQuantity = piecesList[existingIndex]['quantity'] ?? 0;
        int newQuantity = pieceData['quantity'] ?? 0;
        piecesList[existingIndex]['quantity'] = existingQuantity + newQuantity;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Quantité de "${pieceData['name'] ?? 'Inconnue'}" mise à jour: ${piecesList[existingIndex]['quantity']}',
            ),
            backgroundColor: AppColors.primary,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        // Nouvelle pièce, on l'ajoute à la liste
        piecesList.add(pieceData);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Pièce "${pieceData['name'] ?? 'Inconnue'}" ajoutée avec succès',
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }

      print('Liste des pièces mise à jour: $piecesList');
    });
  }

  void _removePiece(int index) {
    setState(() {
      piecesList.removeAt(index);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Pièce retirée'),
        backgroundColor: Colors.orange,
        duration: Duration(seconds: 2),
      ),
    );
  }

  double _calculateTotalPiecesPrice() {
    return piecesList.fold(0.0, (sum, piece) {
      double unitPrice = piece['unitPrice']?.toDouble() ?? 0.0;
      int quantity = piece['quantity'] ?? 1;
      return sum + (unitPrice * quantity);
    });
  }

  double _calculateTotalPrice() {
    double piecesTotal = _calculateTotalPiecesPrice();
    double laborPrice = double.tryParse(_priceController.text) ?? 0.0;
    return piecesTotal + laborPrice;
  }

  void _loadSubTypes(String interventionTypeId, String interventionTypeName) {
    final selectedType = interventionTypes.firstWhere(
      (type) => type.id == interventionTypeId,
      orElse: () =>
          InterventionType(id: '', name: '', subTypes: [], companyId: ''),
    );

    setState(() {
      selectedInterventionTypeId = interventionTypeId;
      selectedInterventionTypeName = interventionTypeName;
      interventionSubTypes = selectedType.subTypes;

      // Vérifier si c'est le type "AUTRE"
      showOtherTypeField = interventionTypeName.toUpperCase() == 'AUTRE';

      if (!showOtherTypeField && interventionSubTypes.isNotEmpty) {
        selectedSubTypeId = interventionSubTypes.first.id;
        selectedSubTypeName = interventionSubTypes.first.name;
      } else {
        selectedSubTypeId = null;
        selectedSubTypeName = null;
      }
    });
  }

  Map<String, dynamic> _prepareFormData() {
    return {
      "title": _titleController.text,
      "typeName": selectedInterventionTypeName,
      "subType": showOtherTypeField
          ? _otherTypeController.text
          : selectedSubTypeName,
      "dateDebut": DateTime.parse(
        formatedDate(DateTime.now()),
      ).toIso8601String(),
      "pieces": piecesList,
      "priority": priorities.firstWhere(
        (p) => p['name'] == selectedPriority,
        orElse: () => {'value': 3},
      )['value'],
      "costEstimate": _calculateTotalPrice().toInt(),
      "mainOeuvre": double.tryParse(_priceController.text)?.toInt() ?? 0.0,
      "affectedToId": selectedAssigneeId,
      "visiteId": widget.visiteId,
      'tech': selectedAssigneeName,
    };
  }

  void _submitForm() {
    print(MaintenanceTask.fromJson(_prepareFormData()));
    if (_formKey.currentState!.validate()) {
      widget.onTaskAdd?.call(MaintenanceTask.fromJson(_prepareFormData()));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Provider.of<AppAdaptiveColors>(context);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: CustomAppBar(
        profileImagePath: "assets/images/images.jpeg",
        name: "Dilane",
        role: l10n.technicianRole,
        accessToken: widget.accessToken,
        nameColor: appColors.primary,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: appColors.primary,))
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Vehicle Info Card
                      widget.header,
                      SizedBox(height: 20),

                      // Diagnostic Section
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Diagnostic: ${widget.dys.detail}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          /*Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'TECHNICIAN 1',
                              style: AppStyles.bodySmall(context),
                            ),
                          ),*/
                        ],
                      ),

                      Text(
                        'Code: ${widget.dys.code}',
                        style: AppStyles.bodySmall(
                          context,
                        ).copyWith(color: Colors.grey[600]),
                      ),

                      SizedBox(height: 10),

                      Text(
                        'Information sur l\'intervention',
                        style: AppStyles.titleLarge(context),
                      ),

                      SizedBox(height: 10),

                      // Title Input
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: TextFormField(
                          controller: _titleController,
                          decoration: InputDecoration(
                            hintText: 'Titre de l\'intervention',
                            hintStyle: TextStyle(color: Colors.grey[500]),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 15,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez saisir un titre';
                            }
                            return null;
                          },
                        ),
                      ),

                      SizedBox(height: 12),

                      // Intervention Type Dropdown
                      _buildInterventionTypeDropdown(),

                      SizedBox(height: 12),

                      // Sub Type Dropdown or Other Type Field
                      showOtherTypeField
                          ? _buildOtherTypeField()
                          : _buildSubTypeDropdown(),

                      SizedBox(height: 16),

                      // Assignee Dropdown
                      _buildAssigneeDropdown(),

                      SizedBox(height: 16),

                      // Priority Dropdown
                      _buildPriorityDropdown(),

                      SizedBox(height: 16),

                      // Prix main d'oeuvre
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: TextFormField(
                          controller: _priceController,
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            setState(() {}); // Pour recalculer les prix
                          },
                          decoration: InputDecoration(
                            hintText: 'Prix main d\'oeuvre',
                            label: Text('Prix main d\'oeuvre'),
                            hintStyle: TextStyle(color: Colors.grey[500]),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 15,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez saisir un prix';
                            }
                            if (int.tryParse(value) == null) {
                              return 'Veuillez saisir un nombre valide';
                            }
                            return null;
                          },
                        ),
                      ),

                      SizedBox(height: 24),

                      // Listes des pièces
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Listes des pièces (${piecesList.length})',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              _showPieceSelectionModal(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: appColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                            ),
                            child: Text(
                              'Ajouter',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 16),

                      // Parts List - Affichage dynamique des pièces
                      if (piecesList.isEmpty)
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
                                SizedBox(height: 4),
                                Text(
                                  'Cliquez sur "Ajouter" pour sélectionner des pièces',
                                  style: AppStyles.bodySmall(context),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        ...piecesList.asMap().entries.map((entry) {
                          int index = entry.key;
                          Map<String, dynamic> piece = entry.value;

                          return _buildPartItem(
                            piece['name'] ?? 'Pièce inconnue',
                            'Prix: ${piece['unitPrice']?.toString() ?? '0'} Fcfa',
                            piece['quantity'],
                            index,
                          );
                        }),

                      SizedBox(height: 24),

                      // Price Estimation
                      Text(
                        'Estimation des prix de cette intervention',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      SizedBox(height: 16),

                      _buildPriceRow(
                        'Prix total des pièces',
                        '${_calculateTotalPiecesPrice().toStringAsFixed(0)} Fcfa',
                      ),
                      _buildPriceRow(
                        'Prix main d\'oeuvre',
                        '${_priceController.text.isNotEmpty ? _priceController.text : '0'} Fcfa',
                      ),
                      Divider(color: Colors.grey[300]),
                      _buildPriceRow(
                        'Montant total',
                        '${_calculateTotalPrice().toStringAsFixed(0)} Fcfa',
                        isTotal: true,
                      ),

                      SizedBox(height: 32),

                      // Add Intervention Button
                      Center(
                        child: ElevatedButton(
                          onPressed: _submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: appColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: 40,
                              vertical: 15,
                            ),
                          ),
                          child: Text(
                            'Ajouter l\'intervention',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildInterventionTypeDropdown() {
    final appColors =  Provider.of<AppAdaptiveColors>(context);
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.grey[300]!),
      ),
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedInterventionTypeName,
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down, color: appColors.primary),
          items: [
            DropdownMenuItem<String>(
              value: null,
              child: Text(
                'Type d\'intervention',
                style: TextStyle(color: Colors.grey[500]),
              ),
            ),
            ...interventionTypes.map((type) {
              return DropdownMenuItem<String>(
                value: type.name,
                child: Text(type.name),
              );
            }),
          ],
          onChanged: (value) {
            if (value != null) {
              final selectedType = interventionTypes.firstWhere(
                (type) => type.name == value,
                orElse: () => InterventionType(
                  id: '',
                  name: '',
                  subTypes: [],
                  companyId: '',
                ),
              );

              _loadSubTypes(selectedType.id, selectedType.name);
            }
          },
        ),
      ),
    );
  }

  Widget _buildSubTypeDropdown() {
    final appColors =  Provider.of<AppAdaptiveColors>(context);
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.grey[300]!),
      ),
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedSubTypeName,
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down, color: appColors.primary),
          items: [
            DropdownMenuItem<String>(
              value: null,
              child: Text(
                'sous-type d\'intervention',
                style: TextStyle(color: Colors.grey[500]),
              ),
            ),
            ...interventionSubTypes.map((subType) {
              return DropdownMenuItem<String>(
                value: subType.name,
                child: Text(subType.name),
              );
            }),
          ],
          onChanged: (value) {
            if (value != null) {
              final selectedSubType = interventionSubTypes.firstWhere(
                (subType) => subType.name == value,
                orElse: () => SubType(id: '', name: '', typeName: ''),
              );

              setState(() {
                selectedSubTypeId = selectedSubType.id;
                selectedSubTypeName = selectedSubType.name;
              });
            }
          },
        ),
      ),
    );
  }

  Widget _buildOtherTypeField() {
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(25)),
      child: TextFormField(
        controller: _otherTypeController,
        decoration: InputDecoration(
          hintText: 'Précisez le type d\'intervention',
          hintStyle: TextStyle(color: Colors.grey[500]),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Veuillez préciser le type d\'intervention';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildAssigneeDropdown() {
    final appColors =  Provider.of<AppAdaptiveColors>(context);
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.grey[300]!),
      ),
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedAssigneeName,
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down, color: appColors.primary),
          items: [
            DropdownMenuItem<String>(
              value: 'Technicien affecté',
              child: Text(
                'Technicien affecté',
                style: TextStyle(color: Colors.grey[500]),
              ),
            ),
            ...assigneesTech.map((assignee) {
              return DropdownMenuItem<String>(
                value: assignee.name,
                child: Text(assignee.name),
              );
            }),
          ],
          onChanged: (value) {
            if (value != 'Technicien affecté') {
              final selectedAssignee = assigneesTech.firstWhere(
                (a) => a.name == value,
                orElse: () => User(
                  id: '',
                  name: '',
                  email: '',
                  phone: '',
                  isCompanyAdmin: false,
                  createdAt: '',
                  updatedAt: '',
                  role: Role(id: 2, name: "name", companyId: "companyId"),
                ),
              );

              setState(() {
                selectedAssigneeId = selectedAssignee.id;
                selectedAssigneeName = selectedAssignee.name;
              });
            }
          },
        ),
      ),
    );
  }

  Widget _buildPriorityDropdown() {
    final appColors =  Provider.of<AppAdaptiveColors>(context);
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.grey[300]!),
      ),
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedPriority,
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down, color: appColors.primary),
          items: [
            DropdownMenuItem<String>(
              value: 'Priorité',
              child: Text(
                'Priorité',
                style: TextStyle(color: Colors.grey[500]),
              ),
            ),
            ...priorities.map((priority) {
              return DropdownMenuItem<String>(
                value: priority['name'],
                child: Text(priority['name']),
              );
            }),
          ],
          onChanged: (value) {
            if (value != 'Priorité') {
              setState(() {
                selectedPriority = value!;
              });
            }
          },
        ),
      ),
    );
  }

  Widget _buildPartItem(String name, String price, int qte, int index) {
    final appColors =  Provider.of<AppAdaptiveColors>(context);
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.build_outlined,
              color: appColors.primary,
              size: 20,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                ),
                SizedBox(height: 4),
                Text(
                  price,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                SizedBox(height: 4),
                Text(
                  "Quantité: $qte",
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => _removePiece(index),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              minimumSize: Size(0, 32),
            ),
            child: Text(
              'Retirer',
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String amount, {bool isTotal = false}) {
    final appColors =  Provider.of<AppAdaptiveColors>(context);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: isTotal
                ? AppStyles.bodyMedium(
                    context,
                  ).copyWith(fontWeight: FontWeight.w600)
                : AppStyles.bodySmall(context),
          ),
          Text(
            amount,
            style: isTotal
                ? AppStyles.bodyMedium(context).copyWith(
                    fontWeight: FontWeight.w600,
                    color: appColors.primary,
                  )
                : AppStyles.bodySmall(context),
          ),
        ],
      ),
    );
  }
}
