import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pro_meca/core/constants/app_styles.dart';
import 'package:pro_meca/core/utils/responsive.dart';
import 'package:pro_meca/core/widgets/customAppBar.dart';
import 'package:pro_meca/l10n/arb/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../constants/app_adaptive_colors.dart';
import '../../../models/diagnostic.dart';
import '../../../models/visite.dart';
import '../../../widgets/build_image.dart';
import '../services/reception_services.dart';

class DiagnosticPage extends StatefulWidget {
  final String idVisite;
  final Visite? visite;
  final String? accessToken;

  const DiagnosticPage({
    super.key,
    required this.idVisite,
    this.visite,
    this.accessToken
  });

  @override
  _DiagnosticPageState createState() => _DiagnosticPageState();
}

class _DiagnosticPageState extends State<DiagnosticPage> {
  late final TextEditingController problemReportedController;
  late final TextEditingController problemIdentifiedController;
  late final TextEditingController errorCodeController;
  String urgencyLevel = "négligeable";
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    problemReportedController = TextEditingController(text: widget.visite?.constatClient ?? '');
    problemIdentifiedController = TextEditingController();
    errorCodeController = TextEditingController();
  }

  @override
  void dispose() {
    problemReportedController.dispose();
    problemIdentifiedController.dispose();
    errorCodeController.dispose();
    super.dispose();
  }

  Future<void> createDiagnostic() async {
    if (_isLoading) return;

    // Validate required fields
    if (problemIdentifiedController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez identifier le problème")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {

      final diagnostic = Diagnostic(visiteId: widget.idVisite, problemReported: problemReportedController.text, problemIdentified: problemIdentifiedController.text, errorCode: errorCodeController.text, urgencyLevel: urgencyLevel);
      final response = await ReceptionServices().submitDiagnostic(
          diagnostic,
          widget.accessToken!
      );

      if (response) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Diagnostic envoyé avec succès!")),
        );
        if (mounted) Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Échec de l'envoi du diagnostic")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur: ${e.toString()}")),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 600;
    final appColors = Provider.of<AppAdaptiveColors>(context);

    return Scaffold(
      appBar: CustomAppBar(
        profileImagePath: "assets/images/images.jpeg",
        name: "Dilane",
        role: l10n.technicianRole,
        nameColor: appColors.primary,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Vehicle Info Section
              _buildVehicleInfoSection(context, isMobile, appColors, l10n),

              const SizedBox(height: 20),

              // Problem Reported Section
              _buildProblemReportedSection(context),

              const SizedBox(height: 10),

              // Problem Identified Section
              _buildProblemIdentifiedSection(context),

              const SizedBox(height: 20),

              // Additional Fields Section
              _buildAdditionalFieldsSection(context),

              const SizedBox(height: 30),

              // Submit Button
              _buildSubmitButton(context, appColors),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVehicleInfoSection(
      BuildContext context,
      bool isMobile,
      AppAdaptiveColors appColors,
      AppLocalizations l10n
      ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            buildImage(widget.visite!.vehicle!.logo, context, widget.accessToken!),
            SizedBox(width: isMobile ? 10 : 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  "${l10n.immatVehicule}: ${widget.visite!.vehicle!.licensePlate}",
                  style: AppStyles.titleMedium(context),
                ),
                Text(
                  "Entrée: ${DateFormat.yMMMd().format(widget.visite!.dateEntree)}",
                  style: AppStyles.titleMedium(context).copyWith(
                      fontSize: 12
                  ),
                ),
              ],
            ),
          ],
        ),
        Text(
          widget.visite!.vehicle!.client!.firstName,
          style: AppStyles.titleMedium(context).copyWith(
              fontSize: 12
          ),
        ),
      ],
    );
  }

  Widget _buildProblemReportedSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Problème signalé", style: AppStyles.titleMedium(context)),
        const SizedBox(height: 8),
        _buildMultilineInput(
          controller: problemReportedController,
          hint: "Fumée blanche.........",
        ),
      ],
    );
  }

  Widget _buildProblemIdentifiedSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Problème identifié",
          style: AppStyles.titleMedium(context),
        ),
        const SizedBox(height: 8),
        _buildMultilineInput(
          controller: problemIdentifiedController,
          hint: "Votre idée du problème",
        ),
      ],
    );
  }

  Widget _buildAdditionalFieldsSection(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            const Expanded(
              flex: 2,
              child: Text("Ce véhicule est-il électronique?"),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 2,
              child: TextField(
                controller: errorCodeController,
                decoration: const InputDecoration(
                  hintText: "Code erreur",
                  border: OutlineInputBorder(),
                ),
              ),
            )
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            const Expanded(flex: 2, child: Text("Niveau d'urgence")),
            const SizedBox(width: 10),
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: urgencyLevel,
                    items: const [
                      DropdownMenuItem(
                        value: "négligeable",
                        child: Text("négligeable"),
                      ),
                      DropdownMenuItem(
                        value: "mineur",
                        child: Text("mineur"),
                      ),
                      DropdownMenuItem(
                        value: "majeur",
                        child: Text("majeur"),
                      ),
                      DropdownMenuItem(
                        value: "critique",
                        child: Text("critique"),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        urgencyLevel = value ?? "négligeable";
                      });
                    },
                    icon: const Icon(Icons.arrow_drop_down),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSubmitButton(BuildContext context, AppAdaptiveColors appColors) {
    return Center(
      child: ElevatedButton(
        onPressed: _isLoading ? null : createDiagnostic,
        style: AppStyles.primaryButton(context).copyWith(
          backgroundColor: MaterialStateProperty.all<Color>(appColors.primary),
        ),
        child: _isLoading
            ? const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 2,
          ),
        )
            : Text("Validé", style: AppStyles.buttonText(context)),
      ),
    );
  }

  Widget _buildMultilineInput({
    required String hint,
    required TextEditingController controller,
  }) {
    return Container(
      height: Responsive.responsiveValue(
        context,
        mobile: MediaQuery.of(context).size.height * 0.2,
      ),
      padding: const EdgeInsets.all(5),
      child: TextField(
        controller: controller,
        maxLines: 5,
        decoration: InputDecoration(
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
            borderSide: const BorderSide(color: Colors.grey),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}