import 'package:flutter/material.dart';
import 'package:pro_meca/core/constants/app_adaptive_colors.dart';
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

class InterventionForm extends StatefulWidget {
  final Widget header;
  final String visiteId;
  final Dysfonctionnement dys;
  final String? techName;
  const InterventionForm({
    super.key,
    required this.header,
    required this.visiteId,
    required this.dys,
    required this.techName,
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

  List<Map<String, dynamic>> priorities = [
    {'value': 4, 'name': 'Haute'},
    {'value': 3, 'name': 'Moyenne'},
    {'value': 2, 'name': 'Basse'},
  ];

  bool isLoading = false;
  bool showOtherTypeField = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _loadTypesIntervention();
    _loadTechnicians(); // À implémenter pour charger les techniciens depuis l'API
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
          content: Text(
            'Erreur lors du chargement des types d\'intervention: $error',
          ),
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
            print('Pièce ajoutée: $pieceData');
            Navigator.pop(context);
          },
          onCancel: () {
            Navigator.pop(context);
          },
        ),
      ),
    );
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
      "dateDebut": DateTime.now().toIso8601String(),
      "pieces": [], // À compléter avec la liste des pièces
      "priority": priorities.firstWhere(
        (p) => p['name'] == selectedPriority,
        orElse: () => {'value': 3},
      )['value'],
      "costEstimate": int.tryParse(_priceController.text) ?? 0,
      "affectedToId": selectedAssigneeId,
      "visiteId": widget.visiteId,
    };
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final formData = _prepareFormData();
      print('Données à envoyer: $formData');

      // Envoyer les données à l'API
      // DiagnosticServices().createIntervention(formData).then((response) {
      //   // Gérer la réponse
      // }).catchError((error) {
      //   // Gérer l'erreur
      // });
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
        nameColor: appColors.primary,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
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
                              'Diagnostic: Moteur sèche',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Container(
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
                          ),
                        ],
                      ),

                      Text(
                        'Code: N/A',
                        style: AppStyles.bodySmall(
                          context,
                        ).copyWith(color: Colors.grey[600]),
                      ),

                      SizedBox(height: 24),

                      Text(
                        'Information sur l\'intervention',
                        style: AppStyles.titleLarge(context),
                      ),

                      SizedBox(height: 16),

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
                            'Listes des pièces',
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
                              backgroundColor: Colors.blue[700],
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

                      // Parts List
                      _buildPartItem('Oil moteur', 'Prix: 35000', false),
                      _buildPartItem(
                        'Plaquettes de frein avant',
                        'Prix: 24000',
                        true,
                      ),

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

                      _buildPriceRow('Prix total des pièces', '178000 Fcfa'),
                      _buildPriceRow('Prix main d\'oeuvre', '20000 Fcfa'),
                      Divider(color: Colors.grey[300]),
                      _buildPriceRow(
                        'Montant total',
                        '198000 Fcfa',
                        isTotal: true,
                      ),

                      SizedBox(height: 32),

                      // Add Intervention Button
                      Center(
                        child: ElevatedButton(
                          onPressed: _submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[700],
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
          icon: Icon(Icons.keyboard_arrow_down, color: Colors.blue[700]),
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
          icon: Icon(Icons.keyboard_arrow_down, color: Colors.blue[700]),
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
          icon: Icon(Icons.keyboard_arrow_down, color: Colors.blue[700]),
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
          icon: Icon(Icons.keyboard_arrow_down, color: Colors.blue[700]),
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

  Widget _buildPartItem(String name, String price, bool isRetired) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: TextStyle(fontWeight: FontWeight.w500)),
                Text(
                  price,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: isRetired ? Colors.red : Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: isTotal
                ? AppStyles.bodyMedium(context)
                : AppStyles.bodySmall(context),
          ),
          Text(
            amount,
            style: isTotal
                ? AppStyles.bodyMedium(context)
                : AppStyles.bodySmall(context),
          ),
        ],
      ),
    );
  }
}
