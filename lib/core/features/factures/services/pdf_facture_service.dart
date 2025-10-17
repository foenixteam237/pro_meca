import 'dart:io';
import 'package:number_to_words_english/number_to_words_english.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'package:pro_meca/core/models/facture.dart';
import 'package:pro_meca/core/utils/formatting.dart';

class PdfFactureService {
  static late pw.Font _regularFont;
  static late pw.Font _boldFont;
  static bool _fontsLoaded = false;

  static Future<void> _loadFonts() async {
    if (_fontsLoaded) return;

    // Charger les polices depuis les assets
    final regularData = await rootBundle.load(
      'assets/fonts/Roboto-Regular.ttf',
    );
    final boldData = await rootBundle.load('assets/fonts/Roboto-Bold.ttf');

    _regularFont = pw.Font.ttf(regularData);
    _boldFont = pw.Font.ttf(boldData);
    _fontsLoaded = true;
  }

  static Future<File> generateFacturePdf(
    Facture facture, {
    bool tva = true,
    bool ir = false,
  }) async {
    await _loadFonts();

    final pdf = pw.Document();

    // Styles avec les polices chargées
    final headerStyle = pw.TextStyle(
      font: _boldFont,
      fontWeight: pw.FontWeight.bold,
      fontSize: 24,
      color: PdfColors.blue800,
    );

    final titleStyle = pw.TextStyle(
      font: _boldFont,
      fontWeight: pw.FontWeight.bold,
      fontSize: 14,
    );

    final normalStyle = pw.TextStyle(font: _regularFont, fontSize: 12);

    final smallStyle = pw.TextStyle(font: _regularFont, fontSize: 10);

    final totalToPay = !tva && !ir
        ? facture.totalHT.toInt()
        : !tva && ir
        ? roundToNextMultipleOf5(
            facture.totalHT * (1 - facture.irRate / 100),
          ).toInt()
        : tva && !ir
        ? facture.totalTTC.toInt()
        : roundToNextMultipleOf5(
            facture.totalTTC * (1 - facture.irRate / 100),
          ).toInt();

    // Construction du PDF
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return [
            // En-tête
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('FACTURE', style: headerStyle),
                    pw.SizedBox(height: 5),
                    pw.Text(facture.reference, style: titleStyle),
                    pw.SizedBox(height: 10),
                    pw.Text(
                      'Date: ${_formatDate(facture.date)}',
                      style: normalStyle,
                    ),
                    if (facture.dueDate != null)
                      pw.Text(
                        'Échéance: ${_formatDate(facture.dueDate!)}',
                        style: normalStyle,
                      ),
                  ],
                ),
                if (facture.status == "DRAFT")
                  pw.Container(
                    padding: const pw.EdgeInsets.all(10),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.blue800),
                      borderRadius: pw.BorderRadius.circular(5),
                    ),
                    child: pw.Text(
                      _escapeText(Facture.statusLabel(facture.status)),
                      style: pw.TextStyle(
                        font: _boldFont,
                        color: _getStatusColor(facture.status),
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),

            pw.SizedBox(height: 30),

            // Informations client et véhicule
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('CLIENT', style: titleStyle),
                      pw.SizedBox(height: 8),
                      pw.Text(
                        _escapeText(facture.client.fullName),
                        style: normalStyle,
                      ),
                      if (facture.client.phone != null)
                        pw.Text(
                          'Tél: ${_escapeText(facture.client.phone!)}',
                          style: smallStyle,
                        ),
                      if (facture.client.email != null)
                        pw.Text(
                          'Email: ${_escapeText(facture.client.email!)}',
                          style: smallStyle,
                        ),
                    ],
                  ),
                ),
                if (facture.visite != null)
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('VÉHICULE', style: titleStyle),
                        pw.SizedBox(height: 8),
                        pw.Text(
                          _escapeText(facture.visite!.vehicle.licensePlate),
                          style: normalStyle,
                        ),
                        if (facture.visite!.vehicle.model != null)
                          pw.Text(
                            'Modèle: ${_escapeText(facture.visite!.vehicle.model!)}',
                            style: smallStyle,
                          ),
                        if (facture.visite!.vehicle.marque != null)
                          pw.Text(
                            'Marque: ${_escapeText(facture.visite!.vehicle.marque!)}',
                            style: smallStyle,
                          ),
                      ],
                    ),
                  ),
              ],
            ),

            pw.SizedBox(height: 30),

            // Lignes de facture
            pw.Text('DÉTAIL DES PRESTATIONS', style: titleStyle),
            pw.SizedBox(height: 10),

            // Table des lignes de facture
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300),
              children: [
                // En-tête du tableau
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey100),
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text('Description', style: titleStyle),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(
                        'Qté',
                        style: titleStyle,
                        textAlign: pw.TextAlign.center,
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(
                        'Prix U.',
                        style: titleStyle,
                        textAlign: pw.TextAlign.right,
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(
                        'Total HT',
                        style: titleStyle,
                        textAlign: pw.TextAlign.right,
                      ),
                    ),
                  ],
                ),
                // Lignes de données
                for (final line in facture.lines)
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(
                          _escapeText(line.description),
                          style: normalStyle,
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(
                          line.quantity.toStringAsFixed(2),
                          style: normalStyle,
                          textAlign: pw.TextAlign.center,
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(
                          '${_formatAmount(line.unitPrice)} FCFA',
                          style: normalStyle,
                          textAlign: pw.TextAlign.right,
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(
                          '${_formatAmount(line.totalHT)} FCFA',
                          style: pw.TextStyle(font: _boldFont, fontSize: 12),
                          textAlign: pw.TextAlign.right,
                        ),
                      ),
                    ],
                  ),
              ],
            ),

            pw.SizedBox(height: 20),

            // Totaux
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.end,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    _buildTotalLine(
                      'Total HT:',
                      '${_formatAmount(facture.totalHT)} FCFA',
                    ),
                    if (tva)
                      _buildTotalLine(
                        'TVA (${facture.tvaRate}%):',
                        '${_formatAmount(facture.totalTTC - facture.totalHT)} FCFA',
                      ),
                    if (ir)
                      _buildTotalLine(
                        'IR (${facture.irRate}%):',
                        '${_formatAmount(!tva ? facture.totalHT - roundToNextMultipleOf5(facture.totalHT * (1 - facture.irRate / 100)) : ((facture.totalTTC - roundToNextMultipleOf5(facture.totalTTC * (1 - facture.irRate / 100)))))} FCFA',
                      ),
                    pw.SizedBox(height: 5),
                    _buildTotalLine(
                      'Total à payer:',
                      '${formatAmount(totalToPay)} FCFA',
                      isBold: true,
                      color: PdfColors.green,
                    ),
                  ],
                ),
              ],
            ),

            // Notes
            if (facture.status == "DRAFT" &&
                facture.notes != null &&
                facture.notes!.isNotEmpty) ...[
              pw.SizedBox(height: 30),
              pw.Text('NOTES', style: titleStyle),
              pw.SizedBox(height: 5),
              pw.Text(_escapeText(facture.notes!), style: normalStyle),
            ] else if (facture.totalTTCWord != null) ...[
              pw.SizedBox(height: 30),
              pw.Text(
                "TOTAL A PAYER: ${totalToPay.toFrench().toUpperCase()} FCFA",
                style: titleStyle,
              ),
            ],
          ];
        },
        footer: _buildFooter,
      ),
    );

    // Sauvegarde du fichier
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/facture_${facture.reference}.pdf');
    await file.writeAsBytes(await pdf.save());

    return file;
  }

  static pw.Widget _buildFooter(pw.Context context) {
    return pw.Column(
      children: [
        pw.Divider(),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'Document généré le ${_formatDate(DateTime.now())}',
              style: pw.TextStyle(
                font: _regularFont,
                fontSize: 10,
                color: PdfColors.grey600,
              ),
            ),
            pw.Container(
              alignment: pw.Alignment.centerRight,
              child: pw.Text(
                "Page ${context.pageNumber} / ${context.pagesCount}",
                style: pw.TextStyle(fontSize: 10, color: PdfColors.grey),
              ),
            ),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildTotalLine(
    String label,
    String value, {
    bool isBold = false,
    PdfColor? color,
  }) {
    return pw.Row(
      mainAxisSize: pw.MainAxisSize.min,
      children: [
        pw.Text(
          _escapeText(label),
          style: pw.TextStyle(
            font: isBold ? _boldFont : _regularFont,
            fontWeight: isBold ? pw.FontWeight.bold : null,
          ),
        ),
        pw.SizedBox(width: 20),
        pw.Text(
          _escapeText(value),
          style: pw.TextStyle(
            font: isBold ? _boldFont : _regularFont,
            fontWeight: isBold ? pw.FontWeight.bold : null,
            color: color,
          ),
        ),
      ],
    );
  }

  // Échapper les caractères problématiques
  static String _escapeText(String text) {
    return text
        .replaceAll('œ', 'oe')
        .replaceAll('Œ', 'OE')
        .replaceAll('æ', 'ae')
        .replaceAll('Æ', 'AE')
        .replaceAll('€', 'EUR')
        .replaceAll('«', '"')
        .replaceAll('»', '"')
        .replaceAll('…', '...');
  }

  static String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  static String _formatAmount(double amount) {
    return amount
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]} ',
        );
  }

  static PdfColor _getStatusColor(String status) {
    switch (status) {
      case 'DRAFT':
        return PdfColors.orange;
      case 'OK':
        return PdfColors.green;
      case 'SENT':
        return PdfColors.blue;
      case 'PARTIAL':
        return PdfColors.amber;
      case 'PAID':
        return PdfColors.green;
      case 'OVERDUE':
        return PdfColors.red;
      case 'CANCELLED':
        return PdfColors.grey;
      default:
        return PdfColors.grey;
    }
  }
}
