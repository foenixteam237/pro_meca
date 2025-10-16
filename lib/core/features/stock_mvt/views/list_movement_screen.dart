// stock_movement_screen.dart
import 'package:flutter/material.dart';
import 'package:pro_meca/core/features/stock_mvt/services/stock_movement_service.dart';
import 'package:pro_meca/core/features/stock_mvt/views/create_stock_movement_screen.dart';
import 'package:pro_meca/core/features/stock_mvt/views/stock_movement_detail_screen.dart';
import 'package:pro_meca/core/models/stock_movement.dart';

class StockMovementScreen extends StatefulWidget {
  const StockMovementScreen({super.key});

  @override
  State<StockMovementScreen> createState() => _StockMovementScreenState();
}

class _StockMovementScreenState extends State<StockMovementScreen> {
  final StockMovementService _stockMovementService = StockMovementService();
  final TextEditingController _searchController = TextEditingController();

  List<StockMovement> _movements = [];
  List<StockMovement> _filteredMovements = [];
  bool _isLoading = true;
  int _totalCount = 0;
  int _skip = 0;
  final int _take = 10;
  bool _hasMore = false;

  // Filtres
  String? _selectedPeriod;
  DateTime? _startDate;
  DateTime? _endDate;
  String? _selectedType;

  final List<Map<String, dynamic>> _periods = [
    {'label': 'Aujourd\'hui', 'days': 0},
    {'label': 'Cette semaine', 'days': 7},
    {'label': 'Ce mois', 'days': 30},
    {'label': 'Ce trimestre', 'days': 90},
    {'label': 'Cette année', 'days': 365},
    // {'label': 'Personnalisée', 'days': null},
  ];

  final List<String> _types = ['Tous', 'IN', 'OUT'];

  @override
  void initState() {
    super.initState();
    _loadMovements();
    _selectedPeriod = 'Ce mois';
    _applyPeriodFilter('Ce mois');
  }

  Future<void> _loadMovements() async {
    setState(() => _isLoading = true);
    try {
      final filters = _buildFilters();
      final response = await _stockMovementService.getMovements(
        skip: _skip,
        take: _take,
        filters: filters,
      );

      setState(() {
        _movements = response.movements;
        _filteredMovements = _movements;
        _totalCount = response.totalCount;
        _hasMore = response.hasMore;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Erreur chargement mouvements: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur lors du chargement: $e')));
      setState(() => _isLoading = false);
    }
  }

  Map<String, dynamic> _buildFilters() {
    final filters = <String, dynamic>{};

    if (_selectedType != null && _selectedType != 'Tous') {
      filters['type'] = _selectedType;
    }

    if (_startDate != null) {
      filters['dateFrom'] = _startDate!.toIso8601String();
    }

    if (_endDate != null) {
      filters['dateTo'] = _endDate!.toIso8601String();
    }

    final query = _searchController.text;
    if (query.isNotEmpty) {
      filters['search'] = query;
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
    _loadMovements();
  }

  void _filterMovements() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredMovements = _movements.where((movement) {
        final matchesSearch =
            movement.piece.name.toLowerCase().contains(query) ||
            movement.piece.reference.toLowerCase().contains(query) ||
            movement.piece.category.toLowerCase().contains(query);

        final matchesType =
            _selectedType == null ||
            _selectedType == 'Tous' ||
            movement.type == _selectedType;

        return matchesSearch && matchesType;
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
                    'Filtrer les mouvements',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  // Période
                  Text(
                    'Période',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
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

                  // Type
                  Text('Type', style: TextStyle(fontWeight: FontWeight.w500)),
                  Wrap(
                    spacing: 8,
                    children: _types.map((type) {
                      return FilterChip(
                        label: Text(
                          type == 'Tous'
                              ? 'Tous'
                              : type == 'IN'
                              ? 'Entrée'
                              : 'Sortie',
                        ),
                        selected: _selectedType == type,
                        onSelected: (selected) {
                          setState(() {
                            _selectedType = selected ? type : null;
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
                              _selectedType = null;
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
                            _loadMovements();
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

  void _showMovementDetails(StockMovement movement) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StockMovementDetailScreen(movement: movement),
      ),
    );
  }

  void _createNewMovement() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CreateStockMovementScreen()),
    ).then((_) => _loadMovements());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mouvements de Stock'),
        actions: [
          IconButton(
            onPressed: () => _showFilterDialog(context),
            icon: const Icon(Icons.filter_list),
          ),
          IconButton(
            onPressed: _loadMovements,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          // Barre de recherche
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => _filterMovements(),
              decoration: InputDecoration(
                hintText: 'Rechercher par pièce, référence ou catégorie',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),

          // Statistiques
          _buildStatsHeader(),
          const SizedBox(height: 16),

          // Liste
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredMovements.isEmpty
                ? const Center(child: Text('Aucun mouvement trouvé.'))
                : ListView.builder(
                    itemCount: _filteredMovements.length,
                    itemBuilder: (context, index) {
                      final movement = _filteredMovements[index];
                      return _buildMovementItem(movement);
                    },
                  ),
          ),

          // Pagination
          _buildPagination(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createNewMovement,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildStatsHeader() {
    final totalIn = _movements
        .where((m) => m.type == 'IN')
        .fold<int>(0, (sum, m) => sum + m.quantity);
    final totalOut = _movements
        .where((m) => m.type == 'OUT')
        .fold<int>(0, (sum, m) => sum + m.quantity);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem('Total Entrées', totalIn, Colors.green),
            _buildStatItem('Total Sorties', totalOut, Colors.red),
            _buildStatItem('Mouvements', _totalCount, Colors.blue),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, int value, Color color) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildMovementItem(StockMovement movement) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: movement.typeColor.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            movement.type == 'IN' ? Icons.arrow_downward : Icons.arrow_upward,
            color: movement.typeColor,
          ),
        ),
        title: Text(
          movement.piece.name,
          style: TextStyle(overflow: TextOverflow.ellipsis),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Réf: ${movement.piece.reference}',
              style: TextStyle(overflow: TextOverflow.ellipsis),
            ),
            Text(
              'Catégorie: ${movement.piece.category}',
              style: TextStyle(overflow: TextOverflow.ellipsis),
            ),
            Text('Quantité: ${movement.quantity}'),
            if (movement.stockAfterMovement != null)
              Text('Stock après: ${movement.stockAfterMovement}'),
            if (movement.facture != null)
              Text(
                'Facture: ${movement.facture!.reference}',
                style: TextStyle(overflow: TextOverflow.ellipsis),
              ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              movement.typeLabel,
              style: TextStyle(
                color: movement.typeColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(_formatDate(movement.date)),
            Text(
              movement.sellingPriceAtMovement != null
                  ? '${movement.sellingPriceAtMovement} FCFA'
                  : 'Prix: N/A',
            ),
          ],
        ),
        onTap: () => _showMovementDetails(movement),
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
                    _loadMovements();
                  }
                : null,
          ),
          Text(
            '${_filteredMovements.isEmpty ? 0 : _skip + 1}-${_skip + _filteredMovements.length} sur $_totalCount',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios),
            onPressed: _hasMore
                ? () {
                    setState(() => _skip += _take);
                    _loadMovements();
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
}
