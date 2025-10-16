import 'dart:async';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:pro_meca/core/features/stock_mvt/services/stock_movement_service.dart';

class PieceSearchDropdown extends StatefulWidget {
  final TextEditingController searchController;
  final Function(Map<String, dynamic> piece) onPieceSelected;
  final Map<String, dynamic>? selectedPiece;

  const PieceSearchDropdown({
    super.key,
    required this.searchController,
    required this.onPieceSelected,
    this.selectedPiece,
  });

  @override
  State<PieceSearchDropdown> createState() => _PieceSearchDropdownState();
}

class _PieceSearchDropdownState extends State<PieceSearchDropdown> {
  final StockMovementService _stockMovementService = StockMovementService();

  List<Map<String, dynamic>> _searchResults = [];
  bool _isLoading = false;
  bool _showDropdown = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _loadInitialPieces();

    widget.searchController.addListener(() {
      if (_debounce?.isActive ?? false) _debounce!.cancel();
      _debounce = Timer(const Duration(milliseconds: 500), () {
        _searchPieces(widget.searchController.text.trim());
      });
    });
  }

  Future<void> _loadInitialPieces() async {
    debugPrint("ou suis je");
    setState(() => _isLoading = true);
    try {
      final response = await _stockMovementService.getPieces(
        skip: 0,
        take: 10,
        search: '',
      );
      setState(() {
        _searchResults = (response['data'] as List)
            .cast<Map<String, dynamic>>();
        if (kDebugMode) {
          debugPrint("search pieces result=$_searchResults");
        }
      });
    } catch (e) {
      debugPrint('Erreur chargement pièces initial: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _searchPieces(String query) async {
    debugPrint("je cherche $query");
    if (query.isEmpty) {
      _loadInitialPieces();
      return;
    }

    setState(() {
      _isLoading = true;
      _showDropdown = true;
    });

    try {
      final response = await _stockMovementService.getPieces(
        skip: 0,
        take: 20,
        search: query,
      );
      setState(() {
        _searchResults = (response['data'] as List)
            .cast<Map<String, dynamic>>();
      });
    } catch (e) {
      debugPrint('Erreur recherche pièces1: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur lors de la recherche des pièces'),
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _selectPiece(Map<String, dynamic> piece) {
    widget.onPieceSelected(piece);
    setState(() {
      _showDropdown = false;
    });
    widget.searchController.text = piece['name'] ?? '';
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: widget.searchController,
          decoration: InputDecoration(
            labelText: 'Rechercher une pièce',
            hintText: 'Tapez le nom ou la référence...',
            prefixIcon: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.search),
            border: const OutlineInputBorder(),
            suffixIcon: widget.selectedPiece != null
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      widget.searchController.clear();
                      widget.onPieceSelected({});
                      setState(() {
                        _showDropdown = true;
                      });
                    },
                  )
                : null,
          ),
          onTap: () {
            setState(() {
              _showDropdown = true;
            });
          },
        ),

        // Dropdown des résultats
        if (_showDropdown && _searchResults.isNotEmpty)
          Card(
            margin: const EdgeInsets.only(top: 4),
            elevation: 4,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 200),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  final piece = _searchResults[index];
                  return ListTile(
                    leading: const Icon(Icons.inventory_2),
                    title: Text(piece['name'] ?? 'Sans nom'),
                    subtitle: Text(
                      'Réf: ${piece['reference'] ?? 'N/A'} - Stock: ${piece['stock'] ?? 0} - ${piece['sellingPrice'] != null ? '${piece['sellingPrice']} FCFA' : 'Prix non défini'}',
                    ),
                    trailing: const Icon(Icons.add_circle_outline),
                    onTap: () => _selectPiece(piece),
                  );
                },
              ),
            ),
          ),

        // Pièce sélectionnée
        if (widget.selectedPiece != null &&
            widget.selectedPiece!.isNotEmpty) ...[
          const SizedBox(height: 12),
          Card(
            color: Colors.green[50],
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.selectedPiece!['name'] ?? '',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Réf: ${widget.selectedPiece!['reference'] ?? 'N/A'} - Stock: ${widget.selectedPiece!['stock'] ?? 0}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],

        if (_showDropdown && _searchResults.isEmpty && !_isLoading)
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Aucune pièce trouvée',
              style: TextStyle(color: Colors.grey),
            ),
          ),
      ],
    );
  }
}
