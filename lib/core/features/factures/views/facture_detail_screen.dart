import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:open_file/open_file.dart';
import 'package:pro_meca/core/features/factures/services/pdf_facture_service.dart';
import 'package:pro_meca/core/features/factures/views/facture_edit_screen.dart';
import 'package:pro_meca/core/models/facture.dart';
import 'package:pro_meca/core/utils/formatting.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';

class FactureDetailScreen extends StatefulWidget {
  final Facture facture;

  const FactureDetailScreen({super.key, required this.facture});

  @override
  State<FactureDetailScreen> createState() => _FactureDetailScreenState();
}

class _FactureDetailScreenState extends State<FactureDetailScreen> {
  bool _isGeneratingPdf = false;
  Future<void> _generateAndSavePdf() async {
    if (_isGeneratingPdf) return;

    setState(() => _isGeneratingPdf = true);

    try {
      // Générer le PDF
      final File pdfFile = await PdfFactureService.generateFacturePdf(
        widget.facture,
      );

      // Lire les bytes
      final Uint8List pdfBytes = await pdfFile.readAsBytes();

      // Sauvegarder avec FilePicker
      final String? outputPath = await FilePicker.platform.saveFile(
        dialogTitle: 'Enregistrer la facture PDF',
        fileName: 'facture_${widget.facture.reference}.pdf',
        bytes: pdfBytes,
      );

      if (outputPath != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PDF enregistré avec succès'),
            action: SnackBarAction(
              label: 'Ouvrir',
              onPressed: () {
                _openFile(outputPath);
              },
            ),
            duration: const Duration(seconds: 4),
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Enregistrement annulé'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } on FileSystemException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur d\'accès au fichier: ${e.message}'),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } on PlatformException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur platforme: ${e.message}'),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur inattendue: $e'),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isGeneratingPdf = false);
      }
    }
  }

  Future<void> _openFile(String filePath) async {
    await OpenFile.open(filePath, type: 'application/pdf');
  }

  Future<void> _generateAndSharePdf() async {
    if (_isGeneratingPdf) return;

    setState(() => _isGeneratingPdf = true);

    try {
      final File pdfFile = await PdfFactureService.generateFacturePdf(
        widget.facture,
      );

      // Partager le fichier
      final params = ShareParams(
        text:
            'Facture ${widget.facture.reference} - ${widget.facture.client.fullName}',
        files: [XFile(pdfFile.path /* , mimeType: "application/pdf" */)],
        subject: 'Facture ${widget.facture.reference}',
      );

      final result = await SharePlus.instance.share(params);

      if (result.status == ShareResultStatus.success) {
        print('Facture partagée avec succès!');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du partage: $e'),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isGeneratingPdf = false);
      }
    }
  }

  void _editFacture() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FactureEditScreen(facture: widget.facture),
      ),
    ).then((updatedFacture) {
      if (updatedFacture != null && mounted) {
        // Rafraîchir l'affichage si nécessaire
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Facture mise à jour'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Facture ${widget.facture.reference}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _editFacture,
            tooltip: 'Modifier',
          ),
          IconButton(
            icon: _isGeneratingPdf
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.print),
            onPressed: _isGeneratingPdf ? null : _generateAndSavePdf,
            tooltip: 'Générer PDF',
          ),
          IconButton(
            icon: _isGeneratingPdf
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.share),
            onPressed: _isGeneratingPdf ? null : _generateAndSharePdf,
            tooltip: 'Partager',
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // En-tête
                _buildHeader(context),
                const SizedBox(height: 24),

                // Informations client et véhicule
                _buildClientVehicleInfo(),
                const SizedBox(height: 24),

                // Lignes de facture
                _buildInvoiceLines(context),
                const SizedBox(height: 24),

                // Totaux
                _buildTotals(),
                const SizedBox(height: 24),

                // Notes
                if (widget.facture.notes != null) _buildNotes(),
              ],
            ),
          ),

          // Overlay de chargement
          if (_isGeneratingPdf)
            Container(
              color: Colors.black.withValues(alpha: 0.5),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text(
                      'Génération du PDF en cours...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    Facture facture = widget.facture;
    return Card(
      // shape: RoundedRectangleBorder(
      //   borderRadius: BorderRadius.circular(16),
      //   side: BorderSide(
      //     color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
      //     width: 1,
      //   ),
      // ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  facture.reference,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: facture.statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    Facture.statusLabel(facture.status),
                    style: TextStyle(
                      color: facture.statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Date: ${_formatDate(facture.date)}',
                  style: const TextStyle(fontSize: 14),
                ),
                if (facture.dueDate != null)
                  Text(
                    'Échéance: ${_formatDate(facture.dueDate!)}',
                    style: const TextStyle(fontSize: 14),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClientVehicleInfo() {
    Facture facture = widget.facture;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'CLIENT',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    facture.client.fullName,
                    style: const TextStyle(fontSize: 16),
                  ),
                  if (facture.client.phone != null)
                    Text('Tél: ${facture.client.phone}'),
                  if (facture.client.email != null)
                    Text('Email: ${facture.client.email}'),
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'VÉHICULE',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    facture.visite.vehicle.licensePlate,
                    style: const TextStyle(fontSize: 16),
                  ),
                  if (facture.visite.vehicle.model != null)
                    Text('Modèle: ${facture.visite.vehicle.model}'),
                  if (facture.visite.vehicle.marque != null)
                    Text('Marque: ${facture.visite.vehicle.marque}'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInvoiceLines(BuildContext context) {
    Facture facture = widget.facture;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'DÉTAIL DES PRESTATIONS',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 16),
            Table(
              columnWidths: const {
                0: FlexColumnWidth(3),
                1: FlexColumnWidth(1),
                2: FlexColumnWidth(1.2),
                3: FlexColumnWidth(1.2),
              },
              border: TableBorder.all(color: Colors.grey.shade300),
              children: [
                TableRow(
                  children: const [
                    Padding(
                      padding: EdgeInsets.all(8),
                      child: Text(
                        'Description',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8),
                      child: Text(
                        'Qté',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 5),
                      child: Text(
                        'Prix U.',
                        textAlign: TextAlign.right,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 5),
                      child: Text(
                        'Total',
                        textAlign: TextAlign.right,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                ...facture.lines
                    .map(
                      (line) => TableRow(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: Text(line.description),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: Text(
                              line.quantity.toStringAsFixed(2),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 5,
                            ),
                            child: Text(
                              line.unitPrice.toStringAsFixed(0),
                              textAlign: TextAlign.right,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 5,
                            ),
                            child: Text(
                              line.totalHT.toStringAsFixed(0),
                              textAlign: TextAlign.right,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                    .toList(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotals() {
    Facture facture = widget.facture;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildTotalLine(
                  'Total HT:',
                  '${formatAmount(facture.totalHT.toStringAsFixed(0))} FCFA',
                ),
                _buildTotalLine(
                  'TVA:',
                  '${formatAmount(((facture.totalTTC - facture.totalHT)).toStringAsFixed(0))} FCFA',
                ),
                const Divider(),
                _buildTotalLine(
                  'Total TTC:',
                  '${formatAmount(facture.totalTTC.toStringAsFixed(0))} FCFA',
                  isBold: true,
                  color: Colors.green,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalLine(
    String label,
    String value, {
    bool isBold = false,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          const SizedBox(width: 16),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: color,
              fontSize: isBold ? 18 : 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotes() {
    Facture facture = widget.facture;
    return Column(
      children: [
        if (facture.totalTTCWord != null) ...[
          SizedBox(height: 30),
          Text(
            "ARRÉTÉ DE LE PRÉSENTE À LA SOMME DE ${facture.totalTTCWord!.toUpperCase()} FCFA",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          SizedBox(height: 30),
        ],
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'NOTES',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(facture.notes!),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
