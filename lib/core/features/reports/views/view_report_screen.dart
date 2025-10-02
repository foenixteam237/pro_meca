import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pro_meca/core/features/reports/services/report_services.dart';
import 'package:pro_meca/core/features/reports/widgets/pdf_preview_page.dart';
import 'package:pro_meca/core/models/global_report.dart';
import 'package:pro_meca/core/constants/app_adaptive_colors.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

class VisiteReportScreen extends StatefulWidget {
  final String? visiteId;
  const VisiteReportScreen({super.key, this.visiteId});

  @override
  State<VisiteReportScreen> createState() => _VisiteReportScreenState();
}

class _VisiteReportScreenState extends State<VisiteReportScreen> {
  Uint8List? _logoBytes;
  bool _isLogoDownloaded = false;
  bool isLoading = true;
  String errorMessage = '';

  // Données fictives pour tester
  GlobalReport globalReport = GlobalReport.fromJson({
    "visite": {
      "id": "vis-12345",
      "dateEntree": "2023-10-15T08:30:00Z",
      "dateSortie": "2023-10-16T16:45:00Z",
      "status": "TERMINEE",
    },
    "vehicle": {
      "licensePlate": "AB-123-CD",
      "chassis": "VF7XBRFVE12345678",
      "marque": "Renault",
      "model": "Clio",
      "year": 2020,
    },
    "client": {
      "name": "Issiaka Martin",
      "email": "martin.issaka@email.com",
      "phone": "+237699325633",
    },
    "interventions": [
      {
        "id": "int-001",
        "reference": "2310-01",
        "type": "Réparation",
        "subType": "Moteur",
        "title": "Remplacement des bougies d'allumage",
        "status": "VALIDATED",
        "technicien": "Abdoulaye SAKINI",
        "dateDebut": "2023-10-15T09:00:00Z",
        "dateFin": "2023-10-15T11:30:00Z",
        "mainOeuvre": 120,
        "diagnostic": "P20A2 - Problème d'allumage",
        "travauxRealises": ["Remplacement bougies", "Nettoyage injecteurs"],
        "piecesUtilisees": [
          {
            "reference": "BOUGIE-1234",
            "name": "Bougie d'allumage",
            "quantity": 3,
          },
          {
            "reference": "BOUGIE-1235",
            "name": "Bougie d'allumage",
            "quantity": 1,
          },
        ],
        "workedHours": 2.5,
        "completed": 100,
        "piecesPrevue": [
          {
            "reference": "BOUGIE-1234",
            "name": "Bougie d'allumage",
            "quantity": 4,
          },
          {
            "reference": "LIQ-REF",
            "name": "Liquide de refroidissement",
            "quantity": 1,
          },
        ],
      },
      {
        "id": "int-002",
        "reference": "2310-02",
        "type": "Entretien",
        "subType": "Freinage",
        "title": "Remplacement des plaquettes de frein",
        "status": "VALIDATED",
        "technicien": "Pierre HONTA",
        "dateDebut": "2023-10-15T13:00:00Z",
        "dateFin": "2023-10-15T15:45:00Z",
        "mainOeuvre": 180,
        "diagnostic": "Usure normale des plaquettes",
        "travauxRealises": [
          "Remplacement plaquettes avant",
          "Contrôle disques",
        ],
        "piecesUtilisees": [
          {
            "reference": "PLAQ-5678",
            "name": "Plaquette de frein avant gauche",
            "quantity": 1,
          },
          {
            "reference": "PLAQ-5679",
            "name": "Plaquette de frein avant droite",
            "quantity": 1,
          },
        ],
        "workedHours": 2.75,
        "completed": 100,
        "piecesPrevue": [
          {
            "reference": "PLAQ-5678",
            "name": "Plaquette de frein avant gauche",
            "quantity": 1,
          },
          {
            "reference": "PLAQ-5679",
            "name": "Plaquette de frein avant droite",
            "quantity": 1,
          },
        ],
      },
    ],
    "resume": {
      "totalInterventions": 2,
      "interventionsValidees": 2,
      "totalHeuresTravail": 5.25,
      "totalMainOeuvre": 300,
    },
  });

  @override
  void initState() {
    super.initState();
    _downloadCompanyLogo();
    _loadGolbalreport();
  }

  // Téléchargement et stockage du logo
  Future<void> _downloadCompanyLogo() async {
    try {
      // URL du logo de l'entreprise (à remplacer par l'URL réelle)
      const String logoUrl =
          'https://pigment.github.io/fake-logos/logos/small/color/auto-speed.png';

      // Téléchargement du logo
      final response = await http.get(Uri.parse(logoUrl));
      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;

        // Sauvegarde du logo dans le stockage local
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/company_logo.png');
        await file.writeAsBytes(bytes);

        setState(() {
          _logoBytes = bytes;
          _isLogoDownloaded = true;
        });
      }
    } catch (e) {
      // En cas d'erreur, utiliser un logo par défaut intégré dans l'application
      final byteData = await rootBundle.load('assets/images/logo.svg');
      setState(() {
        _logoBytes = byteData.buffer.asUint8List();
        _isLogoDownloaded = true;
      });
    }
  }

  Future<void> _loadGolbalreport() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final GlobalReport globalRep = await ReportService().fetchGlobalReport(
        context,
        widget.visiteId!,
      );

      setState(() {
        globalReport = globalRep;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Échec du chargement du rapport de visite';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final appColor = Provider.of<AppAdaptiveColors>(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Rapport de Visite'),
        centerTitle: true,
        // backgroundColor: Colors.blue[800],
        // foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: isLoading
          ? Expanded(child: CircularProgressIndicator.adaptive())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // En-tête avec infos véhicule et client
                  _buildHeaderSection(),
                  const SizedBox(height: 24),

                  // Résumé de la visite
                  _buildSummarySection(),
                  const SizedBox(height: 24),

                  // Liste des interventions
                  _buildInterventionsSection(),
                  const SizedBox(height: 24),

                  // Section pièces et coûts
                  _buildCostsSection(),
                  const SizedBox(height: 24),

                  // Signature et validation
                  _buildSignatureSection(),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isLogoDownloaded
            ? () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => PdfPreviewPage(
                      globalReport: globalReport,
                      logoBytes: _logoBytes!,
                    ),
                  ),
                );
              }
            : null,
        tooltip: 'Générer le PDF',
        child: const Icon(Icons.picture_as_pdf),
      ),
    );
  }

  Widget _buildHeaderSection() {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final dateEntree = DateTime.parse(globalReport.visite.dateEntree);
    final dateSortie = DateTime.parse(globalReport.visite.dateSortie);

    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.directions_car, color: Colors.blue[700], size: 28),
                const SizedBox(width: 10),
                Text(
                  '${globalReport.vehicle.marque} ${globalReport.vehicle.model}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(
                  Icons.confirmation_number,
                  size: 20,
                  color: Colors.grey,
                ),
                const SizedBox(width: 8),
                Text('Plaque: ${globalReport.vehicle.licensePlate}'),
                const Spacer(),
                const Icon(Icons.calendar_today, size: 20, color: Colors.grey),
                const SizedBox(width: 8),
                Text('${globalReport.vehicle.year}'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.person, size: 20, color: Colors.grey),
                const SizedBox(width: 8),
                Text('Client: ${globalReport.client.name}'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.phone, size: 20, color: Colors.grey),
                const SizedBox(width: 8),
                Text(globalReport.client.phone),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Entrée:',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    Text(dateFormat.format(dateEntree)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'Sortie:',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    Text(dateFormat.format(dateSortie)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummarySection() {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Résumé de la visite',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryItem(
                  'Interventions',
                  '${globalReport.resume.totalInterventions}',
                  Icons.build,
                  Colors.blue,
                ),
                _buildSummaryItem(
                  'Validées',
                  '${globalReport.resume.interventionsValidees}',
                  Icons.verified,
                  Colors.green,
                ),
                _buildSummaryItem(
                  'Heures',
                  '${globalReport.resume.totalHeuresTravail}h',
                  Icons.access_time,
                  Colors.orange,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildInterventionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Interventions réalisées',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: globalReport.interventions.length,
          itemBuilder: (context, index) {
            final intervention = globalReport.interventions[index];
            return _buildInterventionCard(intervention);
          },
        ),
      ],
    );
  }

  Widget _buildInterventionCard(Intervention intervention) {
    final dateFormat = DateFormat('HH:mm');
    final dateDebut = DateTime.parse(intervention.dateDebut);
    final dateFin = DateTime.parse(intervention.dateFin);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: ExpansionTile(
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.blue[50],
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.build, color: Colors.blue[700], size: 20),
        ),
        title: Text(
          intervention.title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          '${dateFormat.format(dateDebut)} - ${dateFormat.format(dateFin)} • ${intervention.technicien}',
          style: const TextStyle(fontSize: 12),
        ),
        trailing: Chip(
          label: Text(
            intervention.status == 'VALIDATED' ? 'Validée' : 'En attente',
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
          backgroundColor: intervention.status == 'VALIDATED'
              ? Colors.green
              : Colors.orange,
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Diagnostic: ${intervention.diagnostic}',
                  style: const TextStyle(fontStyle: FontStyle.italic),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Travaux réalisés:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                ...intervention.travauxRealises
                    .map<Widget>(
                      (travail) => Padding(
                        padding: const EdgeInsets.only(left: 8.0, top: 4),
                        child: Text('• $travail'),
                      ),
                    )
                    ,
                const SizedBox(height: 12),
                const Text(
                  'Pièces utilisées:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Wrap(
                  spacing: 8,
                  children: intervention.piecesUtilisees
                      .map<Widget>(
                        (piece) => Chip(
                          label: Text(
                            "${piece.reference} X${piece.quantity}",
                            style: const TextStyle(fontSize: 12),
                          ),
                          backgroundColor: Colors.grey[200],
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCostsSection() {
    // Calculer le total des pièces (simulation)
    final totalPieces = 185.0;
    final totalMainOeuvre = globalReport.resume.totalMainOeuvre.toDouble();
    final tva = (totalPieces + totalMainOeuvre) * 0.1925;
    final totalTTC = totalPieces + totalMainOeuvre + tva;

    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Détail des coûts',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildCostLine(
              'Main d\'œuvre',
              '${totalMainOeuvre.toStringAsFixed(2)} CFA',
            ),
            _buildCostLine(
              'Pièces détachées',
              '${totalPieces.toStringAsFixed(2)} CFA',
            ),
            _buildCostLine(
              'Sous-total',
              '${(totalMainOeuvre + totalPieces).toStringAsFixed(2)} CFA',
            ),
            _buildCostLine('TVA (19,25%)', '${tva.toStringAsFixed(2)} CFA'),
            const Divider(thickness: 1.5),
            _buildCostLine(
              'TOTAL TTC',
              '${totalTTC.toStringAsFixed(2)} CFA',
              isTotal: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCostLine(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? Colors.blue[800] : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignatureSection() {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Validation',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Le client atteste que les travaux ont été réalisés de manière satisfaisante:',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Container(width: 130, height: 2, color: Colors.grey),
                    const SizedBox(height: 4),
                    const Text(
                      'Signature du client',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Container(width: 130, height: 2, color: Colors.grey),
                    const SizedBox(height: 4),
                    const Text(
                      'Signature responsable',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle, color: Colors.green[700], size: 20),
                const SizedBox(width: 8),
                Text(
                  'Visite validée le ${DateFormat('dd/MM/yyyy').format(DateTime.now())}',
                  style: TextStyle(
                    color: Colors.green[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
