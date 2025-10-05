import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pro_meca/core/features/factures/views/facture_edit_screen.dart';
import 'package:pro_meca/core/models/facture.dart';
import 'package:provider/provider.dart';
import 'package:pro_meca/core/constants/app_adaptive_colors.dart';
import 'package:pro_meca/core/constants/app_styles.dart';
import 'package:pro_meca/core/utils/responsive.dart';
import '../services/facture_services.dart';
import '../widgets/facture_list_shimmer.dart';
import 'facture_detail_screen.dart';
import 'package:open_file/open_file.dart';

class FactureListScreen extends StatefulWidget {
  const FactureListScreen({super.key});

  @override
  State<FactureListScreen> createState() => _FactureListScreenState();
}

class _FactureListScreenState extends State<FactureListScreen> {
  final FactureService _factureService = FactureService();
  final TextEditingController _searchController = TextEditingController();

  List<Facture> _factures = [];
  List<Facture> _filteredFactures = [];
  bool _isLoading = true;
  int _totalCount = 0;
  int _skip = 0;
  final int _take = 10;
  bool _hasMore = false;

  bool _isGeneratingWord = false;

  // Filtres
  String? _selectedStatus;
  String? _selectedPeriod;
  DateTime? _startDate;
  DateTime? _endDate;

  final List<Map<String, dynamic>> _periods = [
    {'label': 'Aujourd\'hui', 'days': 0},
    {'label': 'Cette semaine', 'days': 7},
    {'label': 'Ce mois', 'days': 30},
    {'label': 'Ce trimestre', 'days': 90},
    {'label': 'Cette année', 'days': 365},
    // {'label': 'Personnalisée', 'days': null},
  ];

  final List<String> _statusList = [
    'Tous',
    'DRAFT',
    'OK',
    'SENT',
    'PARTIAL',
    'PAID',
    'OVERDUE',
    'CANCELLED',
  ];

  @override
  void initState() {
    super.initState();
    _loadFactures();
    _selectedPeriod = 'Ce mois';
    _applyPeriodFilter('Ce mois');
  }

  Future<void> _loadFactures() async {
    setState(() => _isLoading = true);
    try {
      final filters = _buildFilters();
      final response = await _factureService.getFactures(
        skip: _skip,
        take: _take,
        filters: filters,
      );

      if (kDebugMode) {
        print("1ere facture.lines= ${response.factures[0].lines.toString()}");
      }

      setState(() {
        _factures = response.factures;
        _filteredFactures = _factures;
        _totalCount = response.totalCount;
        _hasMore = response.hasMore;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Erreur chargement factures: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du chargement des factures: $e')),
      );
      setState(() => _isLoading = false);
    }
  }

  Map<String, dynamic> _buildFilters() {
    final filters = <String, dynamic>{};

    if (_selectedStatus != null && _selectedStatus != 'Tous') {
      filters['status'] = _selectedStatus;
    }

    if (_startDate != null) {
      filters['dateFrom'] = _startDate!.toIso8601String();
    }

    if (_endDate != null) {
      filters['dateTo'] = _endDate!.toIso8601String();
    }

    return filters;
  }

  void _applyPeriodFilter(String period) {
    final now = DateTime.now();
    setState(() {
      _selectedPeriod = period;
      switch (period) {
        case 'Aujourd\'hui':
          _startDate = DateTime(now.year, now.month, now.day);
          _endDate = now;
          break;
        case 'Cette semaine':
          _startDate = now.subtract(const Duration(days: 7));
          _endDate = now;
          break;
        case 'Ce mois':
          _startDate = DateTime(now.year, now.month, 1);
          _endDate = now;
          break;
        case 'Ce trimestre':
          final quarterStart = (now.month - 1) ~/ 3 * 3 + 1;
          _startDate = DateTime(now.year, quarterStart, 1);
          _endDate = now;
          break;
        case 'Cette année':
          _startDate = DateTime(now.year, 1, 1);
          _endDate = now;
          break;
        case 'Personnalisée':
          // La sélection de date se fera via un sélecteur
          break;
      }
    });
    _loadFactures();
  }

  void _filterFactures() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredFactures = _factures.where((facture) {
        final matchesSearch =
            facture.reference.toLowerCase().contains(query) ||
            facture.client.fullName.toLowerCase().contains(query) ||
            facture.visite.vehicle.licensePlate.toLowerCase().contains(query);

        final matchesStatus =
            _selectedStatus == null ||
            _selectedStatus == 'Tous' ||
            facture.status == _selectedStatus;

        return matchesSearch && matchesStatus;
      }).toList();
    });
  }

  void _showFilterDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Filtrer les factures',
                    style: AppStyles.titleMedium(context),
                  ),
                  const SizedBox(height: 16),

                  // Période
                  Text('Période', style: AppStyles.bodyMedium(context)),
                  Wrap(
                    spacing: 8,
                    children: _periods.map((period) {
                      return FilterChip(
                        label: Text(period['label']),
                        selected: _selectedPeriod == period['label'],
                        onSelected: (selected) {
                          if (selected) {
                            _applyPeriodFilter(period['label']);
                            Navigator.pop(context);
                          }
                        },
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 16),

                  // Statut
                  Text('Statut', style: AppStyles.bodyMedium(context)),
                  Wrap(
                    spacing: 8,
                    children: _statusList.map((status) {
                      return FilterChip(
                        label: Text(
                          status == 'Tous'
                              ? 'Tous'
                              : Facture.statusLabel(status),
                        ),
                        selected: _selectedStatus == status,
                        onSelected: (selected) {
                          setState(() {
                            _selectedStatus = selected ? status : null;
                          });
                        },
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              _selectedStatus = null;
                              _selectedPeriod = 'Ce mois';
                            });
                            _applyPeriodFilter('Ce mois');
                            Navigator.pop(context);
                          },
                          child: const Text('Réinitialiser'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            _loadFactures();
                            Navigator.pop(context);
                          },
                          child: const Text('Appliquer'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showFactureActions(BuildContext context, Facture facture) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(
                  Icons.visibility,
                  color: Theme.of(context).primaryColor,
                ),
                title: const Text('Voir les détails'),
                onTap: () {
                  Navigator.pop(context);
                  _viewFactureDetails(facture);
                },
              ),
              if (facture.status == 'DRAFT')
                ListTile(
                  leading: Icon(
                    Icons.edit,
                    color: Theme.of(context).primaryColor,
                  ),
                  title: const Text('Modifier'),
                  onTap: () {
                    Navigator.pop(context);
                    _editFacture(facture);
                  },
                ),
              ListTile(
                leading: Icon(Icons.description, color: Colors.blue),
                title: const Text('Générer Word'),
                onTap: () {
                  Navigator.pop(context);
                  _generateWordFacture(facture);
                },
              ),
              if (facture.status == 'DRAFT')
                ListTile(
                  leading: Icon(Icons.check_circle, color: Colors.green),
                  title: const Text('Valider la commande'),
                  onTap: () {
                    Navigator.pop(context);
                    _validateCommande(facture);
                  },
                ),
              ListTile(
                leading: Icon(Icons.delete, color: Colors.red),
                title: const Text('Supprimer'),
                onTap: () {
                  Navigator.pop(context);
                  _confirmDelete(facture);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _viewFactureDetails(Facture facture) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FactureDetailScreen(facture: facture),
      ),
    );
  }

  void _editFacture(Facture facture) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FactureEditScreen(facture: facture),
      ),
    ).then((updatedFacture) {
      if (updatedFacture != null) {
        // Rafraîchir la liste si nécessaire
        _loadFactures();
      }
    });
  }

  Future<void> _generateWordFacture(Facture facture) async {
    final result = await showDialog<Map<String, bool>>(
      context: context,
      builder: (BuildContext dialogContext) {
        bool tva = true;
        bool ir = false;

        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              title: Text("Options fiscales"),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildToggleSwitch(
                    value: tva,
                    onChanged: (value) {
                      setDialogState(() {
                        tva = value;
                      });
                    },
                    label: "TVA (${facture.tvaRate}%)",
                    icon: Icons.attach_money,
                  ),
                  const SizedBox(height: 20),
                  _buildToggleSwitch(
                    value: ir,
                    onChanged: (value) {
                      setDialogState(() {
                        ir = value;
                      });
                    },
                    label: "IR (${facture.irRate}%)",
                    icon: Icons.percent_outlined,
                  ),
                ],
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop({"tva": tva, "ir": ir});
                  },
                  child: Text("OK"),
                ),
              ],
            );
          },
        );
      },
    );

    if (kDebugMode) {
      print("Résultat showDialog = $result");
    }

    if (result == null) return;
    if (_isGeneratingWord) return;

    setState(() => _isGeneratingWord = true);

    try {
      // Télécharger les bytes du fichier Word depuis le serveur
      final Uint8List wordBytes = await _factureService
          .generateWordFactureBytes(
            facture.visite.id,
            tva: result['tva']! ? 1 : 0,
            ir: result['ir']! ? 1 : 0,
          );

      // Utiliser FilePicker pour sauvegarder le fichier
      final String? outputPath = await FilePicker.platform.saveFile(
        dialogTitle: 'Enregistrer la facture Word',
        fileName: 'facture_${facture.reference}.docx',
        bytes: wordBytes,
        lockParentWindow: true,
      );

      if (outputPath != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Facture Word enregistrée: ${outputPath.split('/').last}',
            ),
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: 'Ouvrir',
              onPressed: () {
                // ouvrir le fichier
                _openFile(outputPath);
              },
            ),
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
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du téléchargement: $e'),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isGeneratingWord = false);
      }
    }
  }

  Future<void> _openFile(String filePath) async {
    await OpenFile.open(
      filePath,
      type:
          'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    );
  }

  Future<void> _validateCommande(Facture facture) async {
    try {
      final interventionIds = facture.lines
          .where((line) => line.interventionId != null)
          .map((line) => line.interventionId!)
          .toList();

      if (interventionIds.isNotEmpty) {
        final success = await _factureService.updateInterventionsOrdered(
          interventionIds,
        );
        if (success) {
          await _factureService.updateFactureStatus(facture.id, 'OK');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Commande validée avec succès')),
          );
          _loadFactures();
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la validation: $e')),
      );
    }
  }

  void _confirmDelete(Facture facture) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Confirmation"),
        content: Text(
          "Voulez-vous supprimer la facture ${facture.reference} ?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text("Annuler"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _deleteFacture(facture);
            },
            child: const Text("Supprimer", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteFacture(Facture facture) async {
    try {
      final success = await _factureService.deleteFacture(facture.id);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Facture ${facture.reference} supprimée avec succès'),
          ),
        );
        _loadFactures();
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur suppression: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Provider.of<AppAdaptiveColors>(context);
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 600;

    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: RefreshIndicator(
              onRefresh: _loadFactures,
              color: appColors.primary,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: Responsive.responsiveValue(
                    context,
                    mobile: screenSize.height * 0.025,
                    tablet: screenSize.height * 0.02,
                    desktop: screenSize.height * 0.03,
                  ),
                  vertical: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 🔍 Champ de recherche
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              onChanged: (_) => _filterFactures(),
                              decoration: InputDecoration(
                                hintText:
                                    'Rechercher par référence, client ou véhicule',
                                border: InputBorder.none,
                                suffixIcon: Icon(
                                  Icons.search,
                                  color: appColors.primary,
                                ),
                                hintStyle: TextStyle(
                                  color: Theme.of(context).hintColor,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 📊 En-tête avec statistiques
                    _buildHeader(appColors, context),
                    const SizedBox(height: 16),

                    // 🎛️ Barre d'outils
                    _buildToolbar(context, appColors),
                    const SizedBox(height: 16),

                    // 📋 Liste des factures
                    Expanded(
                      child: _isLoading
                          ? const FactureListShimmer()
                          : _filteredFactures.isEmpty
                          ? const Center(child: Text('Aucune facture trouvée.'))
                          : isMobile
                          ? _buildMobileList()
                          : _buildDesktopTable(),
                    ),

                    // 📄 Pagination
                    if (!isMobile && _factures.isNotEmpty) _buildPagination(),
                  ],
                ),
              ),
            ),
          ),
          // Overlay de chargement pour Word
          if (_isGeneratingWord)
            Container(
              color: Colors.black.withValues(alpha: 0.5),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text(
                      'Téléchargement du fichier Word...',
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

  Widget _buildHeader(AppAdaptiveColors appColors, BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Factures', style: AppStyles.titleLarge(context)),
                Text(
                  '$_totalCount facture(s) au total',
                  style: AppStyles.bodySmall(context),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${_getTotalAmount()} FCFA',
                  style: AppStyles.titleMedium(context)!.copyWith(
                    color: appColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text('Montant total', style: AppStyles.bodySmall(context)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getTotalAmount() {
    final total = _factures.fold(0.0, (sum, facture) => sum + facture.totalTTC);
    return total.toStringAsFixed(0);
  }

  Widget _buildToolbar(BuildContext context, AppAdaptiveColors appColors) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Liste des factures', style: AppStyles.titleMedium(context)),
        Row(
          children: [
            IconButton(
              onPressed: () => _showFilterDialog(context),
              icon: Icon(Icons.filter_list, color: appColors.primary),
              tooltip: "Filtrer",
            ),
            IconButton(
              onPressed: _loadFactures,
              icon: Icon(Icons.refresh, color: appColors.primary),
              tooltip: "Actualiser",
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildToggleSwitch({
    required bool value,
    required ValueChanged<bool> onChanged,
    required String label,
    required IconData icon,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: value ? Colors.green : Colors.grey),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(width: 8),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: Theme.of(context).primaryColor,
        ),
      ],
    );
  }

  Widget _buildMobileList() {
    return ListView.separated(
      itemCount: _filteredFactures.length,
      separatorBuilder: (_, __) =>
          Divider(color: Colors.grey.withOpacity(0.4), height: 1),
      itemBuilder: (context, index) {
        final facture = _filteredFactures[index];
        return _buildMobileFactureItem(facture);
      },
    );
  }

  Widget _buildMobileFactureItem(Facture facture) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: facture.statusColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.receipt, color: facture.statusColor),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              facture.reference,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              facture.client.fullName,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              facture.visite.vehicle.licensePlate,
              style: const TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: facture.statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    Facture.statusLabel(facture.status),
                    style: TextStyle(
                      fontSize: 10,
                      color: facture.statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  '${facture.totalTTC.toStringAsFixed(0)} FCFA',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: () => _showFactureActions(context, facture),
        ),
        onTap: () => _viewFactureDetails(facture),
      ),
    );
  }

  Widget _buildDesktopTable() {
    return SingleChildScrollView(
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Référence')),
          DataColumn(label: Text('Client')),
          DataColumn(label: Text('Véhicule')),
          DataColumn(label: Text('Montant TTC'), numeric: true),
          DataColumn(label: Text('Statut')),
          DataColumn(label: Text('Date')),
          DataColumn(label: Text('Actions')),
        ],
        rows: _filteredFactures.map((facture) {
          return DataRow(
            cells: [
              DataCell(
                Text(
                  facture.reference,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              DataCell(Text(facture.client.fullName)),
              DataCell(Text(facture.visite.vehicle.licensePlate)),
              DataCell(Text('${facture.totalTTC.toStringAsFixed(0)} FCFA')),
              DataCell(
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: facture.statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    Facture.statusLabel(facture.status),
                    style: TextStyle(
                      color: facture.statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              DataCell(Text(_formatDate(facture.date))),
              DataCell(
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (value) {
                    switch (value) {
                      case 'view':
                        _viewFactureDetails(facture);
                        break;
                      case 'edit':
                        _editFacture(facture);
                        break;
                      case 'word':
                        _generateWordFacture(facture);
                        break;
                      case 'validate':
                        _validateCommande(facture);
                        break;
                      case 'delete':
                        _confirmDelete(facture);
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'view',
                      child: Text('Voir détails'),
                    ),
                    if (facture.status == 'DRAFT')
                      const PopupMenuItem(
                        value: 'edit',
                        child: Text('Modifier'),
                      ),
                    const PopupMenuItem(
                      value: 'word',
                      child: Text('Générer Word'),
                    ),
                    if (facture.status == 'DRAFT')
                      const PopupMenuItem(
                        value: 'validate',
                        child: Text('Valider commande'),
                      ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('Supprimer'),
                    ),
                  ],
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPagination() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: _skip > 0
                ? () {
                    setState(() => _skip -= _take);
                    _loadFactures();
                  }
                : null,
          ),
          Text(
            '${_skip + 1}-${_skip + _filteredFactures.length} sur $_totalCount',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios),
            onPressed: _hasMore
                ? () {
                    setState(() => _skip += _take);
                    _loadFactures();
                  }
                : null,
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
