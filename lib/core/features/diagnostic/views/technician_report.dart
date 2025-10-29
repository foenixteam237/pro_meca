import 'package:flutter/material.dart';
import 'package:pro_meca/core/constants/app_colors.dart';
import 'package:pro_meca/core/constants/app_styles.dart';
import 'package:pro_meca/core/features/diagnostic/services/diagnostic_services.dart';
import 'package:pro_meca/core/models/maintenance_task.dart';
import 'package:pro_meca/core/utils/responsive.dart';
import 'package:provider/provider.dart';

import '../../../../l10n/arb/app_localizations.dart';
import '../../../constants/app_adaptive_colors.dart';
import '../../../models/visite.dart';
import '../../../models/report.dart';
import '../widgets/build_vehicle_info_section.dart';

class TechnicianReport extends StatefulWidget {
  final Visite visite;
  final String accessToken;
  final MaintenanceTask maintenanceTask;
  final bool isTech;
  final VoidCallback? onReportValidated; // Callback pour rafraîchir la liste

  const TechnicianReport({
    super.key,
    required this.visite,
    required this.accessToken,
    required this.maintenanceTask,
    required this.isTech,
    this.onReportValidated,
  });

  @override
  _TechnicianReportState createState() => _TechnicianReportState();
}

class _TechnicianReportState extends State<TechnicianReport> {
  final TextEditingController _dureeController = TextEditingController();
  final TextEditingController _completionController = TextEditingController();
  final TextEditingController _travauxController = TextEditingController();

  AppAdaptiveColors? appColors;

  List<Map<String, String>> _travaux = [];
  List<Map<String, dynamic>> _pieces = [];
  List<Map<String, String>> _dysfonctionnements = [];

  bool _isLoadingReport = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    appColors = Provider.of<AppAdaptiveColors>(context, listen: false);
    if (!widget.isTech) {
      _loadReport();
    }
  }

  Future<void> _loadReport() async {
    if (_isLoadingReport) return;
    setState(() => _isLoadingReport = true);

    try {
      final report = await DiagnosticServices().fetchReportByInterventionId(
        widget.maintenanceTask.id,
      );

      setState(() {
        _dysfonctionnements = report.content.diagnostic.map((diag) {
          final parts = diag.split(' - ');
          return {
            'code': parts.isNotEmpty ? parts[0] : 'N/A',
            'description': parts.length > 1 ? parts[1] : diag,
          };
        }).toList();

        _pieces = report.content.piecesUtilisees.map((piece) {
          return {
            'id': piece.reference,
            'nom': piece.name,
            'prix': '',
            'quantite': piece.quantity.toString(),
            'supprime': 'false',
          };
        }).toList();

        _travaux = report.content.travauxRealises
            .map((t) => {'nom': t, 'supprime': 'false'})
            .toList();
        _dureeController.text = report.content.workedHours.toString();
        _completionController.text = report.content.completed.toString();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erreur chargement rapport: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoadingReport = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.customBackground(context),
      appBar: AppBar(
        title: const Text('Rapport d\'intervention'),
        backgroundColor: appColors!.primary,
      ),
      bottomNavigationBar: _buildFooterButton(),
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          child: _isLoadingReport
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
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
                      const SizedBox(height: 12),
                      _buildInterventionTitleCard(),
                      const SizedBox(height: 20),
                      _buildInterventionDetailsCard(),
                      const SizedBox(height: 20),
                      _buildDysfonctionnementsCard(),
                      const SizedBox(height: 20),
                      _buildTravauxCard(),
                      const SizedBox(height: 20),
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.customBackground(context),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.maintenanceTask.title,
                  style: AppStyles.titleMedium(
                    context,
                  ).copyWith(fontSize: 14, fontWeight: FontWeight.w600),
                  overflow: TextOverflow.clip,
                ),
                const SizedBox(height: 4),
                RichText(
                  text: TextSpan(
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                    children: [
                      const TextSpan(text: 'Priorité: '),
                      TextSpan(
                        text: widget.maintenanceTask.priority.toString(),
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
          ),
          Row(
            children: [
              Text(
                widget.maintenanceTask.reference ?? "REF NOT FOUND",
                style: AppStyles.titleMedium(context).copyWith(fontSize: 14),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.check_circle, color: Colors.green, size: 24),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInterventionDetailsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.customBackground(context),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
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
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  label: 'Durée (h):',
                  controller: _dureeController,
                  readOnly: !widget.isTech,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: _buildTextField(
                  label: 'Taux de complétion (%):',
                  controller: _completionController,
                  readOnly: !widget.isTech,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDysfonctionnementsCard() {
    final dys = widget.visite.diagnostics?.first.dysfonctionnements ?? [];

    void showAddDialog() {
      String? selectedCode;
      showDialog(
        context: context,
        builder: (_) => StatefulBuilder(
          builder: (ctx, setStateDialog) => AlertDialog(
            title: const Text("Ajout dysfonctionnement"),
            content: DropdownButton<String>(
              value: selectedCode,
              hint: const Text("Sélectionner"),
              isExpanded: true,
              items: dys
                  .map(
                    (d) => DropdownMenuItem(
                      value: d.code,
                      child: Text('${d.code} - ${d.detail}'),
                    ),
                  )
                  .toList(),
              onChanged: widget.isTech
                  ? (v) => setStateDialog(() => selectedCode = v)
                  : null,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(AppLocalizations.of(context).cancel),
              ),
              ElevatedButton(
                onPressed: widget.isTech && selectedCode != null
                    ? () {
                        final selected = dys.firstWhere(
                          (d) => d.code == selectedCode,
                        );
                        setState(() {
                          _dysfonctionnements.add({
                            'code': selected.code ?? "",
                            'description': selected.detail,
                          });
                        });
                        Navigator.pop(ctx);
                      }
                    : null,
                child: Text(AppLocalizations.of(context).add),
              ),
            ],
          ),
        ),
      );
    }

    return _buildSectionCard(
      title: "Mes dysfonctionnements résolus",
      addButton: widget.isTech ? showAddDialog : null,
      children: _dysfonctionnements.map(_buildDysfonctionnementItem).toList(),
    );
  }

  Widget _buildDysfonctionnementItem(Map<String, String> item) {
    return _buildReadonlyItem(
      code: item['code']!,
      description: item['description']!,
      onRemove: widget.isTech
          ? () => setState(() => _dysfonctionnements.remove(item))
          : null,
    );
  }

  Widget _buildTravauxCard() {
    return _buildSectionCard(
      title: 'Travaux effectués',
      addButton: widget.isTech
          ? () {
              if (_travauxController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Veuillez saisir un travail'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              setState(() {
                _travaux.add({
                  'nom': _travauxController.text.trim(),
                  'supprime': 'false',
                });
                _travauxController.clear();
              });
            }
          : null,
      inputHint: widget.isTech ? 'Travaux effectués' : null,
      inputController: widget.isTech ? _travauxController : null,
      children: _travaux.map(_buildTravauxItem).toList(),
    );
  }

  Widget _buildTravauxItem(Map<String, String> item) {
    return _buildReadonlyItem(
      code: "Travail",
      description: item['nom']!,
      onRemove: widget.isTech
          ? () => setState(() => _travaux.remove(item))
          : null,
    );
  }

  Widget _buildPiecesCard() {
    return _buildSectionCard(
      title: 'Liste des pièces utilisées',
      addButton:
          widget.isTech && (widget.maintenanceTask.pieces?.isNotEmpty ?? false)
          ? _showAddPieceDialog
          : null,
      children: _pieces.map(_buildPieceItem).toList(),
    );
  }

  Widget _buildPieceItem(Map<String, dynamic> item) {
    return _buildReadonlyItem(
      code: item['nom'],
      description: 'Quantité: ${item['quantite']}',
      onRemove: widget.isTech
          ? () => setState(() => _pieces.remove(item))
          : null,
    );
  }

  Widget _buildReadonlyItem({
    required String code,
    required String description,
    VoidCallback? onRemove,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.customBackground(context),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              code,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(description)),
          if (onRemove != null) ...[
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.remove_circle, color: Colors.red),
              onPressed: onRemove,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    VoidCallback? addButton,
    String? inputHint,
    TextEditingController? inputController,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: AppColors.customBackground(context),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: AppStyles.titleMedium(
                    context,
                  ).copyWith(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
              if (addButton != null)
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
                    onPressed: addButton,
                  ),
                ),
            ],
          ),
          if (inputHint != null) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: inputController,
                    decoration: InputDecoration(
                      hintText: inputHint,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
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
                    onPressed: addButton,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    String? value,
    TextEditingController? controller,
    bool readOnly = false,
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
        const SizedBox(height: 4),
        TextField(
          controller: controller ?? TextEditingController(text: value),
          readOnly: readOnly,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.all(12),
          ),
          style: const TextStyle(fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildFooterButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _handleSubmit,
        style: AppStyles.primaryButton(context).copyWith(
          backgroundColor: WidgetStateProperty.all(appColors!.primary),
        ),
        child: _isSubmitting
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                widget.isTech
                    ? 'Soumettre le rapport'
                    : 'Valider l\'intervention',
                style: AppStyles.titleMedium(context).copyWith(
                  color: AppColors.customBackground(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);

    try {
      if (widget.isTech) {
        // === TECHNICIEN : Créer le rapport ===
        if (_travaux.isEmpty &&
            _dysfonctionnements.isEmpty &&
            _dureeController.text.isEmpty &&
            _completionController.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Veuillez remplir au moins un champ'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        final rapport = {
          "content": {
            "diagnostic": _dysfonctionnements
                .map((d) => "${d['code']} - ${d['description']}")
                .toList(),
            "pieces_utilisees": _pieces
                .map(
                  (p) => {"id": p['id'], "quantity": int.parse(p['quantite'])},
                )
                .toList(),
            "travaux_realises": _travaux.map((t) => t['nom']).toList(),
            "workedHours": int.parse(_dureeController.text),
            "completed": int.parse(_completionController.text),
          },
          "interventionId": widget.maintenanceTask.id,
        };

        final success = await DiagnosticServices().createReport(
          report: rapport,
          context: context,
        );
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Rapport créé avec succès !'),
              backgroundColor: appColors?.primary,
            ),
          );
          Navigator.pop(context);
        }
      } else {
        // === ADMIN : Valider l'intervention ===
        final report = {
          "interventionIds": [widget.maintenanceTask.id],
        };

        final success = await DiagnosticServices().validateIntervention(
          context: context,
          report: report,
        );

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Intervention validée !'),
              backgroundColor: appColors?.primary,
            ),
          );
          widget.onReportValidated?.call(); // Rafraîchit la liste
          Navigator.pop(context);
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showAddPieceDialog() {
    String? selectedName;
    String quantite = '';
    String? error;

    final pieces = widget.maintenanceTask.pieces ?? [];

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setStateDialog) => AlertDialog(
          title: const Text("Ajouter une pièce"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButton<String>(
                value: selectedName,
                hint: const Text("Sélectionner"),
                isExpanded: true,
                items: pieces
                    .map(
                      (p) => DropdownMenuItem<String>(
                        value: p['name'].toString(),
                        child: Text('${p['name']} (Max: ${p['quantity']})'),
                      ),
                    )
                    .toList(),
                onChanged: widget.isTech
                    ? (v) => setStateDialog(() => selectedName = v)
                    : null,
              ),
              TextField(
                decoration: InputDecoration(
                  labelText: "Quantité",
                  errorText: error,
                ),
                keyboardType: TextInputType.number,
                readOnly: !widget.isTech,
                onChanged: widget.isTech
                    ? (v) {
                        setStateDialog(() {
                          quantite = v;
                          final max =
                              pieces.firstWhere(
                                (p) => p['name'] == selectedName,
                                orElse: () => {},
                              )['quantity'] ??
                              0;
                          final q = int.tryParse(v) ?? 0;
                          error = (q <= 0)
                              ? "Quantité invalide"
                              : (q > max)
                              ? "Stock insuffisant"
                              : null;
                        });
                      }
                    : null,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(AppLocalizations.of(context).cancel),
            ),
            ElevatedButton(
              onPressed:
                  widget.isTech &&
                      selectedName != null &&
                      quantite.isNotEmpty &&
                      error == null
                  ? () {
                      final p = pieces.firstWhere(
                        (x) => x['name'] == selectedName,
                      );
                      if (_pieces.any((x) => x['id'] == p['id'])) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Pièce déjà ajoutée'),
                            backgroundColor: Colors.orange,
                          ),
                        );
                        return;
                      }
                      setState(() {
                        _pieces.add({
                          'id': p['id'],
                          'nom': selectedName!,
                          'prix': p['price'] ?? '',
                          'quantite': quantite,
                          'supprime': 'false',
                        });
                      });
                      Navigator.pop(ctx);
                    }
                  : null,
              child: Text(AppLocalizations.of(context).add),
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
    _travauxController.dispose();
    super.dispose();
  }
}
