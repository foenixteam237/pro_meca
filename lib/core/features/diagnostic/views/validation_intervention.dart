import 'package:flutter/material.dart';
import 'package:pro_meca/core/constants/app_adaptive_colors.dart';
import 'package:pro_meca/core/constants/app_colors.dart';
import 'package:pro_meca/core/constants/app_styles.dart';
import 'package:pro_meca/core/features/diagnostic/services/diagnostic_services.dart';
import 'package:pro_meca/core/features/diagnostic/views/technician_report.dart';
import 'package:pro_meca/core/features/diagnostic/widgets/build_intervention_widget.dart';
import 'package:pro_meca/core/features/diagnostic/widgets/build_vehicle_info_section.dart';
import 'package:pro_meca/core/models/maintenance_task.dart';
import 'package:pro_meca/core/widgets/customAppBar.dart';
import 'package:dio/dio.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../l10n/arb/app_localizations.dart';
import '../../../models/visite.dart';
import '../../../utils/responsive.dart';

class ValidationInterventionScreen extends StatefulWidget {
  final String visiteId;
  final bool isAdmin;
  final String accessToken;
  final Visite visite;
  final bool fromAVIN;
  final VoidCallback onValidated; // ← Callback pour rafraîchir

  const ValidationInterventionScreen({
    super.key,
    required this.visiteId,
    required this.isAdmin,
    required this.accessToken,
    required this.visite,
    required this.fromAVIN,
    required this.onValidated,
  });

  @override
  _ValidationInterventionScreenState createState() =>
      _ValidationInterventionScreenState();
}

class _ValidationInterventionScreenState
    extends State<ValidationInterventionScreen> {
  List<MaintenanceTask> tasks = [];
  final Set<String> _selectedIds = {};
  bool isLoading = true;
  bool hasError = false;
  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });

    try {
      final fetchedTasks = await DiagnosticServices().fetchIntervention(
        widget.visiteId,
      );
      setState(() {
        tasks = fetchedTasks;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        hasError = true;
      });
      print('Erreur fetch: $e');
    }
  }

  void _toggleSelection(String id) {
    setState(() {
      _selectedIds.contains(id)
          ? _selectedIds.remove(id)
          : _selectedIds.add(id);
    });
  }

  Future<void> _validateSelectedInterventions() async {
    if (_selectedIds.isEmpty || isSubmitting) return;

    setState(() => isSubmitting = true);

    final report = {"interventionIds": _selectedIds.toList()};

    try {
      final success = await DiagnosticServices().validateIntervention(
        context: context,
        report: report,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${_selectedIds.length} intervention(s) validée(s) !',
            ),
            backgroundColor: AppColors.primary,
          ),
        );

        widget.onValidated(); // ← Appelle le callback
        Navigator.pop(context); // ← Retour fluide
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Provider.of<AppAdaptiveColors>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: CustomAppBar(
        profileImagePath: "profileImagePath",
        name: "name",
        role: "role",
        nameColor: appColors.primary,
        accessToken: "accessToken",
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: buildVehicleInfoSection(
              context,
              Responsive.isMobile(context),
              appColors,
              AppLocalizations.of(context),
              widget.visite,
              widget.accessToken,
            ),
          ),
          Expanded(child: _buildBody(isDark)),
          if (widget.fromAVIN) _buildBottomButtons(appColors),
        ],
      ),
    );
  }

  Widget _buildBody(bool isDark) {
    if (isLoading) {
      return Shimmer.fromColors(
        baseColor: isDark ? Colors.grey[700]! : Colors.grey[300]!,
        highlightColor: isDark ? Colors.grey[600]! : Colors.grey[100]!,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: 3,
          itemBuilder: (_, __) => Container(
            margin: const EdgeInsets.only(top: 10),
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade100),
            ),
          ),
        ),
      );
    }

    if (hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Erreur de chargement',
              style: TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchData,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: Text('Réessayer', style: AppStyles.buttonText(context)),
            ),
          ],
        ),
      );
    }

    if (tasks.isEmpty) {
      return const Center(child: Text('Aucune intervention trouvée.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        final isSelected = _selectedIds.contains(task.id);

        if (widget.isAdmin) {
          return InterventionCard(
            task: task,
            isSelected: isSelected,
            onTap: () => _toggleSelection(task.id),
            onOpenReport: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TechnicianReport(
                    visite: widget.visite,
                    accessToken: widget.accessToken,
                    maintenanceTask: task,
                    isTech: false,
                    onReportValidated: () {
                      widget.onValidated(); // ← Rafraîchit la liste
                      Navigator.pop(context);
                    },
                  ),
                ),
              );
            },
          );
        } else if (task.hasBeenOrdered == true) {
          return interventionItem(task, context, () {});
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildBottomButtons(AppAdaptiveColors appColors) {
    final canValidate = _selectedIds.isNotEmpty && !isSubmitting;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: canValidate ? _validateSelectedInterventions : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: appColors.primary,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      'Valider ${_selectedIds.length} intervention${_selectedIds.length > 1 ? 's' : ''}',
                      style: AppStyles.buttonText(
                        context,
                      ).copyWith(fontWeight: FontWeight.w600),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class InterventionCard extends StatelessWidget {
  final MaintenanceTask task;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onOpenReport;

  const InterventionCard({
    super.key,
    required this.task,
    required this.isSelected,
    required this.onTap,
    required this.onOpenReport,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onOpenReport,
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.only(top: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.withOpacity(0.1) : null,
          border: Border.all(color: Colors.blue.shade100),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Checkbox(
              value: isSelected,
              onChanged: (_) => onTap(),
              activeColor: AppColors.primary,
            ),
            const SizedBox(width: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                'https://tmna.aemassets.toyota.com/is/image/toyota/toyota/vehicles/2025/crownsignia/gallery/CRS_MY25_0011_V001_desktop.png?fmt=jpeg&fit=crop&qlt=90&wid=1024',
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Image.asset(
                  "assets/images/moteur.jpg",
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    "Priorité: ${task.priority}",
                    style: const TextStyle(color: Colors.orange, fontSize: 13),
                  ),
                  Text(
                    "Technicien: ${task.technician ?? 'N/A'}",
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
            const Icon(Icons.description, color: Colors.blue),
          ],
        ),
      ),
    );
  }
}
