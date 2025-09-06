import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'package:pro_meca/core/models/global_report.dart';

class PdfPreviewPage extends StatelessWidget {
  final GlobalReport globalReport;
  final Uint8List logoBytes;
  final companyName = 'Auto Express';

  const PdfPreviewPage({
    super.key,
    required this.globalReport,
    required this.logoBytes,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aperçu du PDF'),
        actions: [
          // Sélecteur de format de page
          _buildPageFormatSelector(context),
        ],
      ),
      body: PdfPreview(
        build: (format) => _generatePdf(format, globalReport, logoBytes),
        allowSharing: true,
        allowPrinting: true,
        canChangePageFormat: true,
      ),
    );
  }

  Widget _buildPageFormatSelector(BuildContext context) {
    return PopupMenuButton<PdfPageFormat>(
      icon: const Icon(Icons.pageview),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: PdfPageFormat.a4,
          child: Text('A4 (210 × 297 mm)'),
        ),
        PopupMenuItem(
          value: PdfPageFormat.letter,
          child: Text('Lettre (216 × 279 mm)'),
        ),
        PopupMenuItem(
          value: PdfPageFormat.legal,
          child: Text('Légal (216 × 356 mm)'),
        ),
      ],
      onSelected: (format) {
        // Rafraîchir l'aperçu avec le nouveau format
        Printing.layoutPdf(
          onLayout: (_) => _generatePdf(format, globalReport, logoBytes),
        );
      },
    );
  }

  Future<Uint8List> _generatePdf(
    PdfPageFormat format,
    GlobalReport globalReport,
    Uint8List logoBytes,
  ) async {
    final pdf = pw.Document(
      title: 'Rapport de Visite',
      author: companyName,
      creator: 'ProMéca',
    );
    // Ajouter une page au document
    pdf.addPage(
      pw.MultiPage(
        pageFormat: format,
        margin: pw.EdgeInsets.all(20),
        build: (context) => [
          // En-tête avec logo
          _buildHeader(logoBytes),
          pw.SizedBox(height: 20),

          // Informations sur la visite
          _buildVisitInfo(globalReport),
          pw.SizedBox(height: 20),

          // Résumé de la visite
          _buildSummary(globalReport),
          pw.SizedBox(height: 20),

          // Interventions réalisées
          _buildInterventions(globalReport),
          pw.SizedBox(height: 20),

          // Détail des coûts
          _buildCosts(globalReport),
          pw.SizedBox(height: 20),

          // Section de signature
          _buildSignatureSection(),
        ],
      ),
    );

    return pdf.save();
  }

  pw.Widget _buildHeader(Uint8List logoBytes) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Image(pw.MemoryImage(logoBytes), height: 60),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text(
              'RAPPORT DE VISITE',
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
            pw.Text(
              '$companyName - Expert en Automobile',
              style: pw.TextStyle(fontSize: 10),
            ),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildVisitInfo(GlobalReport globalReport) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final dateEntree = DateTime.parse(globalReport.visite.dateEntree);
    final dateSortie = DateTime.parse(globalReport.visite.dateSortie);

    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.blue, width: 1),
        borderRadius: pw.BorderRadius.circular(5),
      ),
      padding: pw.EdgeInsets.all(10),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Informations de la visite',
            style: pw.TextStyle(
              fontSize: 14,

              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue,
            ),
          ),
          pw.Divider(),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Véhicule:',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Text(
                      '${globalReport.vehicle.marque} ${globalReport.vehicle.model}',
                    ),
                    pw.Text('Plaque: ${globalReport.vehicle.licensePlate}'),
                    pw.Text('Année: ${globalReport.vehicle.year}'),
                    pw.Text('Chassis: ${globalReport.vehicle.chassis}'),
                  ],
                ),
              ),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Client:',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Text(globalReport.client.name),
                    pw.Text(globalReport.client.phone),
                    pw.Text(globalReport.client.email),
                  ],
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 10),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Entrée: ${dateFormat.format(dateEntree)}'),
              pw.Text('Sortie: ${dateFormat.format(dateSortie)}'),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildSummary(GlobalReport globalReport) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        color: PdfColors.blue50,
        borderRadius: pw.BorderRadius.circular(5),
      ),
      padding: pw.EdgeInsets.all(10),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem(
            'Interventions',
            '${globalReport.resume.totalInterventions}',
          ),
          _buildSummaryItem(
            'Validées',
            '${globalReport.resume.interventionsValidees}',
          ),
          _buildSummaryItem(
            'Heures',
            '${globalReport.resume.totalHeuresTravail}h',
          ),
          _buildSummaryItem(
            'Main d\'oeuvre',
            '${globalReport.resume.totalMainOeuvre} CFA',
          ),
        ],
      ),
    );
  }

  pw.Widget _buildSummaryItem(String title, String value) {
    return pw.Column(
      children: [
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 16,

            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue,
          ),
        ),
        pw.Text(
          title,
          style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
        ),
      ],
    );
  }

  pw.Widget _buildInterventions(GlobalReport globalReport) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Interventions Réalisées',
          style: pw.TextStyle(
            fontSize: 14,

            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue,
          ),
        ),
        pw.Divider(),
        ...globalReport.interventions.map<pw.Widget>((intervention) {
          final dateFormat = DateFormat('HH:mm');
          final dateDebut = DateTime.parse(intervention.dateDebut);
          final dateFin = DateTime.parse(intervention.dateFin);

          return pw.Container(
            margin: pw.EdgeInsets.only(bottom: 10),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey300),
              borderRadius: pw.BorderRadius.circular(5),
            ),
            padding: pw.EdgeInsets.all(10),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      intervention.title,
                      style: pw.TextStyle(
                        fontSize: 12,

                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Container(
                      decoration: pw.BoxDecoration(
                        color: intervention.status == 'VALIDATED'
                            ? PdfColors.green
                            : PdfColors.orange,
                        borderRadius: pw.BorderRadius.circular(10),
                      ),
                      padding: pw.EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      child: pw.Text(
                        intervention.status == 'VALIDATED'
                            ? 'Validée'
                            : 'En attente',
                        style: pw.TextStyle(
                          color: PdfColors.white,
                          fontSize: 8,
                        ),
                      ),
                    ),
                  ],
                ),
                pw.Text(
                  '${dateFormat.format(dateDebut)} - ${dateFormat.format(dateFin)} : ${intervention.technicien}',
                  style: pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
                ),
                pw.SizedBox(height: 5),
                pw.Text(
                  'Diagnostic: ${intervention.diagnostic}',
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontStyle: pw.FontStyle.italic,
                  ),
                ),
                pw.SizedBox(height: 5),
                pw.Text(
                  'Travaux réalisés:',
                  style: pw.TextStyle(
                    fontSize: 10,

                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                ...intervention.travauxRealises.map<pw.Widget>(
                  (travail) =>
                      pw.Text('- $travail', style: pw.TextStyle(fontSize: 9)),
                ),
                pw.SizedBox(height: 5),
                pw.Text(
                  'Pièces utilisées:',
                  style: pw.TextStyle(
                    fontSize: 10,

                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Wrap(
                  children: intervention.piecesUtilisees
                      .map<pw.Widget>(
                        (piece) => pw.Container(
                          margin: pw.EdgeInsets.only(right: 5, bottom: 5),
                          padding: pw.EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 2,
                          ),
                          decoration: pw.BoxDecoration(
                            color: PdfColors.grey200,
                            borderRadius: pw.BorderRadius.circular(3),
                          ),
                          child: pw.Text(
                            piece,
                            style: pw.TextStyle(fontSize: 8),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  pw.Widget _buildCosts(GlobalReport globalReport) {
    final totalPieces = 185.0;
    final totalMainOeuvre = globalReport.resume.totalMainOeuvre.toDouble();
    final tva = (totalPieces + totalMainOeuvre) * 0.1925;
    final totalTTC = totalPieces + totalMainOeuvre + tva;

    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(5),
      ),
      padding: pw.EdgeInsets.all(10),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Détail des Coûts',
            style: pw.TextStyle(
              fontSize: 14,

              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue,
            ),
          ),
          pw.Divider(),
          _buildCostLine('Main d\'oeuvre', totalMainOeuvre),
          _buildCostLine('Pièces détachées', totalPieces),
          _buildCostLine('Sous-total', totalMainOeuvre + totalPieces),
          _buildCostLine('TVA (19,25%)', tva),
          pw.Divider(thickness: 1),
          _buildCostLine('TOTAL TTC', totalTTC, isTotal: true),
        ],
      ),
    );
  }

  pw.Widget _buildCostLine(String label, double value, {bool isTotal = false}) {
    final numberFormat = NumberFormat.currency(
      locale: 'fr-CM',
      symbol: 'CFA',
      decimalDigits: 0,
    );

    return pw.Padding(
      padding: pw.EdgeInsets.symmetric(vertical: 3),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: isTotal ? 12 : 10,

              fontWeight: isTotal ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
          pw.Text(
            numberFormat.format(value),
            style: pw.TextStyle(
              fontSize: isTotal ? 12 : 10,
              fontWeight: isTotal ? pw.FontWeight.bold : pw.FontWeight.normal,
              color: isTotal ? PdfColors.blue : PdfColors.black,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildSignatureSection() {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(5),
      ),
      padding: pw.EdgeInsets.all(10),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Validation',
            style: pw.TextStyle(
              fontSize: 14,

              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue,
            ),
          ),
          pw.Divider(),
          pw.Text(
            'Le client atteste que les travaux ont été réalisés de manière satisfaisante:',
            style: pw.TextStyle(fontSize: 10),
          ),
          pw.SizedBox(height: 15),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
            children: [
              pw.Column(
                children: [
                  pw.Container(width: 120, height: 1, color: PdfColors.grey),
                  pw.SizedBox(height: 3),
                  pw.Text(
                    'Signature du client',
                    style: pw.TextStyle(fontSize: 8),
                  ),
                ],
              ),
              pw.Column(
                children: [
                  pw.Container(width: 120, height: 1, color: PdfColors.grey),
                  pw.SizedBox(height: 3),
                  pw.Text(
                    'Signature responsable',
                    style: pw.TextStyle(fontSize: 8),
                  ),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 15),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.center,
            children: [
              pw.Text(
                'Visite validée le ${DateFormat('dd/MM/yyyy').format(DateTime.now())}',
                style: pw.TextStyle(
                  fontSize: 10,
                  color: PdfColors.green,

                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
