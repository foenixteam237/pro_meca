
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pro_meca/core/constants/app_colors.dart';
import 'package:pro_meca/core/constants/app_styles.dart';
import 'package:pro_meca/core/features/diagnostic/services/diagnostic_services.dart';
import 'package:pro_meca/core/models/dysfonctionnement.dart';
import 'package:pro_meca/core/models/maintenance_task.dart';
import 'package:pro_meca/core/utils/responsive.dart';
import 'package:provider/provider.dart';

import '../../../../l10n/arb/app_localizations.dart';
import '../../../constants/app_adaptive_colors.dart';
import '../../../models/visite.dart';
import '../widgets/build_vehicle_info_section.dart';

class TechnicianReport extends StatefulWidget {
  final Visite visite;
  final String accessToken;
  final MaintenanceTask maintenanceTask;

  const TechnicianReport({
    super.key,
    required this.visite,
    required this.accessToken,
    required this.maintenanceTask,
  });

  @override
  _TechnicianReportState createState() => _TechnicianReportState();
}

class _TechnicianReportState extends State<TechnicianReport> {
  final TextEditingController _dureeController = TextEditingController();
  final TextEditingController _completionController = TextEditingController();
  final TextEditingController _dysfonctionnementController =
      TextEditingController();
  final TextEditingController _travauxController = TextEditingController();
  AppAdaptiveColors? appColors;

  final List<Map<String, String>> _travaux = [];

  final List<Map<String, dynamic>> _pieces = [];

  final List<Map<String, String>> _dysfonctionnements = [];

  @override
  Widget build(BuildContext context) {
    appColors ??= Provider.of<AppAdaptiveColors>(context);
    return Scaffold(
      backgroundColor: AppColors.customBackground(context),
      appBar: AppBar(
        title: Text('Rapport d\'intervention'),
        backgroundColor: appColors!.primary,
      ),
      bottomNavigationBar: _buildFooterButton(),
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              children: [
                buildVehicleInfoSection(
                  context,
                  Responsive.isMobile(context),
                  appColors!,
                  AppLocalizations.of(context),
                  widget.visite,
                  widget.accessToken,
                ),
                SizedBox(height: 12),
                _buildInterventionTitleCard(),
                SizedBox(height: 20),
                _buildInterventionDetailsCard(),
                SizedBox(height: 20),
                _buildDysfonctionnementsCard(),
                SizedBox(height: 20),
                _buildTravauxCard(),
                SizedBox(height: 20),
                _buildPiecesCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInterventionTitleCard() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.customBackground(context),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.maintenanceTask.title,
                style: AppStyles.titleMedium(
                  context,
                ).copyWith(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 4),
              RichText(
                text: TextSpan(
                  style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  children: [
                    TextSpan(text: 'Priorité: '),
                    TextSpan(
                      text: '${widget.maintenanceTask.priority}',
                      style: AppStyles.bodyMedium(context).copyWith(
                        fontWeight: FontWeight.w500,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Row(
            children: [
              Text(
                widget.maintenanceTask.reference ?? "REF NOT FOUND",
                style: AppStyles.titleMedium(context).copyWith(fontSize: 14),
              ),
              SizedBox(width: 8),
              Icon(Icons.check_circle, color: Colors.green, size: 24),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInterventionDetailsCard() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.customBackground(context),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildTextField(
            label: 'Type d\'intervention',
            value: widget.maintenanceTask.typeName,
            readOnly: true,
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  label: 'Durée (h):',
                  controller: _dureeController,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  label: 'Taux de complétion(%):',
                  controller: _completionController,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDysfonctionnementsCard() {
    // Liste des dysfonctionnements disponibles (à adapter selon votre source de données)

    final List<Dysfonctionnement> dys =
        widget.visite.diagnostics!.first.dysfonctionnements;
    void showAddDysfonctionnementDialog() {
      String?
      selectedDysfonctionnement; // Stocke le code du dysfonctionnement sélectionné

      showDialog(
        context: context,
        builder: (BuildContext dialogContext) => StatefulBuilder(
          builder: (dialogContext, setDialogState) => AlertDialog(
            title: Text("Ajout dysfonctionnement"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButton<String>(
                  value: selectedDysfonctionnement,
                  hint: Text("Selectionner un dysfonctionnement"),
                  isExpanded: true,
                  items: dys.map((dysf) {
                    return DropdownMenuItem<String>(
                      value: dysf.code,
                      child: Text('${dysf.code} - ${dysf.detail}'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setDialogState(() {
                      selectedDysfonctionnement = value;
                    });
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: Text(AppLocalizations.of(context).cancel),
              ),
              ElevatedButton(
                onPressed: selectedDysfonctionnement != null
                    ? () {
                        final Dysfonctionnement selectedDysf = dys.firstWhere(
                          (dysf) => dysf.code == selectedDysfonctionnement,
                        );
                        setState(() {
                          print(selectedDysf.detail);
                          _dysfonctionnements.add({
                            'code': ?selectedDysf.code,
                            'description': selectedDysf.detail,
                          });
                        });
                        Navigator.of(dialogContext).pop();
                      }
                    : null, // Désactiver le bouton si aucun dysfonctionnement n'est sélectionné
                child: Text(AppLocalizations.of(context).add),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.customBackground(context),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Mes dysfonctionnements",
                style: AppStyles.titleMedium(
                  context,
                ).copyWith(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: appColors?.primary,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.add,
                    color: AppColors.customBackground(context),
                    size: 18,
                  ),
                  padding: EdgeInsets.zero,
                  onPressed: showAddDysfonctionnementDialog,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          ...(_dysfonctionnements.map(
            (dysf) => _buildDysfonctionnementItem(dysf),
          )),
        ],
      ),
    );
  }

  Widget _buildDysfonctionnementItem(Map<String, String> dysfonctionnement) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: TextField(
              readOnly: true,
              decoration: InputDecoration(
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.all(12),
              ),
              style: TextStyle(fontSize: 14),
              controller: TextEditingController(
                text: dysfonctionnement['code'],
              ),
            ),
          ),
          SizedBox(width: 4),
          Expanded(
            child: TextField(
              readOnly: true,
              decoration: InputDecoration(
                hintText: 'Description',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: EdgeInsets.all(12),
              ),
              style: TextStyle(fontSize: 14),
              controller: TextEditingController(
                text: dysfonctionnement['description'],
              ),
              onChanged: (value) {
                dysfonctionnement['description'] = value;
              },
            ),
          ),
          SizedBox(width: 4),
          IconButton(
            icon: Icon(Icons.remove_circle, color: Colors.red),
            onPressed: () {
              setState(() {
                _dysfonctionnements.remove(dysfonctionnement);
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTravauxCard() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.customBackground(context),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Travaux effectués',
            style: AppStyles.titleMedium(
              context,
            ).copyWith(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _travauxController,
                  decoration: InputDecoration(
                    hintText: 'Travaux effectués',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: EdgeInsets.all(12),
                  ),
                  style: TextStyle(fontSize: 14),
                ),
              ),
              SizedBox(width: 8),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: appColors?.primary,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.add,
                    color: AppColors.customBackground(context),
                    size: 18,
                  ),
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    if (_travauxController.text.isNotEmpty) {
                      setState(() {
                        _travaux.add({
                          'nom': _travauxController.text,
                          'supprime': 'false',
                        });
                        _travauxController.clear();
                      });
                    }
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          ...(_travaux.map((travail) => _buildTravauxItem(travail))),
        ],
      ),
    );
  }

  Widget _buildTravauxItem(Map<String, String> travail) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.customBackground(context),
        borderRadius: BorderRadius.circular(8),
        //border: Border.all(color: Colors.grey) //à méditer..............
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            travail['nom']!,
            style: AppStyles.titleMedium(context).copyWith(fontSize: 14),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _travaux.remove(travail);
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              minimumSize: Size(0, 28),
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            ),
            child: Text(
              'Supprimé',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPiecesCard() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.customBackground(context),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Liste des pièces',
                style: AppStyles.titleMedium(
                  context,
                ).copyWith(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: appColors?.primary,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.add,
                    color: AppColors.customBackground(context),
                    size: 18,
                  ),
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    if (widget.maintenanceTask.pieces!.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Aucune pièce disponible pour cette intervention.',
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                    } else {
                      _showAddPieceDialog();
                    }
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          ...(_pieces.map((piece) => _buildPieceItem(piece))),
        ],
      ),
    );
  }

  Widget _buildPieceItem(Map<String, dynamic> piece) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.customBackground(context),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                piece['nom'],
                style: AppStyles.titleMedium(
                  context,
                ).copyWith(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              Text(
                'Quantité: ${piece['quantite']}',
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _pieces.remove(piece);
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              minimumSize: Size(0, 28),
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            ),
            child: Text(
              'Supprimé',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    String? value,
    TextEditingController? controller,
    bool readOnly = false,
    Color? backgroundColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppStyles.titleMedium(
            context,
          ).copyWith(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 4),
        TextField(
          controller: controller ?? TextEditingController(text: value),
          readOnly: readOnly,
          decoration: InputDecoration(
            filled: backgroundColor != null,
            fillColor: backgroundColor,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: EdgeInsets.all(12),
          ),
          style: TextStyle(fontSize: 14),
          keyboardType: TextInputType.number,
        ),
      ],
    );
  }

  Widget _buildFooterButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () async {
          // Action pour terminer l'intervention
          Map<String, dynamic> rapport = {
            "content": {
              "diagnostic": _dysfonctionnements
                  .map((dys) => "${dys['code']} - ${dys['description']}")
                  .toList(),
              "pieces_utilisees": _pieces
                  .map(
                    (piece) => {
                      "id": piece['id'],
                      "quantity": int.parse(piece['quantite']),
                    },
                  )
                  .toList(),
              "travaux_realises": _travaux
                  .map((travail) => travail['nom'])
                  .toList(),
              "workedHours": int.parse(_dureeController.text),
              "completed": int.parse(_completionController.text),
            },
            "interventionId": widget.maintenanceTask.id,
          };
          final isCreate = await DiagnosticServices().createReport(
            report: rapport,
            context: context,
          );

          if (isCreate) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Rapport créé avec succès !'),
                backgroundColor: appColors?.primary,
              ),
            );
            Navigator.pop(
              context,
            ); // Fermer la page après la création du rapport
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Échec de la création du rapport.'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        style: AppStyles.primaryButton(context),
        child: Text('Terminée', style: AppStyles.buttonText(context)),
      ),
    );
  }

  void _showAddPieceDialog() {
    String? selectedPiece; // Stocke le nom de la pièce sélectionnée
    String quantite = ''; // Stocke la quantité saisie
    String? errorMessage; // Stocke le message d'erreur pour la validation

    final pieces = widget.maintenanceTask.pieces;
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: Text("Ajouter une pièce"), // Localisé
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButton<String>(
                value: selectedPiece,
                hint: Text("Selectionner une pièce"), // Localisé
                isExpanded: true,
                items: pieces?.map((piece) {
                  return DropdownMenuItem<String>(
                    value: piece['name'],
                    child: Text(
                      '${piece['name']} (Stock: ${piece['quantity']})',
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setDialogState(() {
                    selectedPiece = value;
                    errorMessage =
                        null; // Réinitialiser l'erreur lors du changement
                  });
                },
              ),
              TextField(
                decoration: InputDecoration(
                  labelText: "Quantité",
                  errorText: errorMessage,
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setDialogState(() {
                    quantite = value;
                    // Valider la quantité
                    if (value.isNotEmpty && selectedPiece != null) {
                      final selectedPieceData = pieces?.firstWhere(
                        (piece) => piece['name'] == selectedPiece,
                      );
                      final quantiteInt = int.tryParse(value);
                      if (quantiteInt == null || quantiteInt <= 0) {
                        errorMessage = "Veuillez mettre une quantité";
                      } else if (quantiteInt > selectedPieceData['quantity']) {
                        errorMessage =
                            "Quantité doit etre inferieur ou égal au stock";
                      } else {
                        errorMessage = null;
                      }
                    } else {
                      errorMessage = null;
                    }
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(AppLocalizations.of(context).cancel), // Localisé
            ),
            ElevatedButton(
              onPressed:
                  selectedPiece != null &&
                      quantite.isNotEmpty &&
                      errorMessage == null
                  ? () {
                      final selectedPieceData = pieces?.firstWhere(
                        (pieces) => pieces['name'] == selectedPiece,
                      );
                      setState(() {
                        final piece = _pieces.where(
                          (piece) => piece['id'] == selectedPieceData['id'],
                        );

                        if (piece.isNotEmpty && piece.first['id'] == selectedPieceData['id']) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Cette pièce existe déjà dans la liste des pièces.',
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                        } else {
                          _pieces.add({
                            'id': selectedPieceData['id'],
                            'nom': selectedPiece!,
                            'prix': selectedPieceData['price'],
                            'quantite': quantite,
                            'supprime': 'false',
                          });
                        }
                      });
                      Navigator.of(dialogContext).pop();
                    }
                  : null, // Désactiver le bouton si les conditions ne sont pas remplies
              child: Text(AppLocalizations.of(context).add), // Localisé
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _dureeController.dispose();
    _completionController.dispose();
    _dysfonctionnementController.dispose();
    _travauxController.dispose();
    super.dispose();
  }
}
