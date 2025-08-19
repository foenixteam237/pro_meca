import 'package:flutter/material.dart';
import 'package:pro_meca/core/constants/app_adaptive_colors.dart';
import 'package:pro_meca/core/constants/app_styles.dart';
import 'package:pro_meca/core/features/pieces/services/pieces_services.dart';
import 'package:pro_meca/core/features/pieces/widgets/add_pieces_form.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

import '../../../models/pieces.dart';
import '../widgets/buildPiecesItems.dart';
import '../widgets/buildPiecesItemsShimmer.dart';

// Ajout de l'enum pour les filtres
enum StockFilter { all, inStock, outOfStock }

class PiecesPage extends StatefulWidget {
  final String catId;
  const PiecesPage({super.key, required this.catId});

  @override
  State<PiecesPage> createState() => _PiecesPageState();
}

class _PiecesPageState extends State<PiecesPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Piece> pieces = [];
  List<Piece> filteredPieces = [];
  bool isLoading = true;
  String errorMessage = '';
  String query = "";

  // Variables pour le filtrage
  StockFilter currentFilter = StockFilter.all;
  bool isFilterDialogOpen = false;

  @override
  void initState() {
    super.initState();
    _loadPieces();
  }

  Future<void> _loadPieces() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final List<Piece> fetchedPieces = await PiecesService().fetchPieces(
        context,
        widget.catId,
      );

      setState(() {
        pieces = fetchedPieces;
        isLoading = false;
        _applyFilters(); // Appliquer les filtres après chargement
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Échec du chargement des pièces';
      });
    }
  }

  // Fonction pour appliquer les filtres
  void _applyFilters() {
    List<Piece> result = pieces;

    // Filtre par texte de recherche
    if (query.isNotEmpty) {
      result = result
          .where((p) => p.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }

    // Filtre par statut de stock
    switch (currentFilter) {
      case StockFilter.inStock:
        result = result.where((p) => p.inStock!).toList();
        break;
      case StockFilter.outOfStock:
        result = result.where((p) => !p.inStock!).toList();
        break;
      case StockFilter.all:
        // Pas de filtre supplémentaire
        break;
    }

    setState(() {
      filteredPieces = result;
    });
  }

  // Fonction pour afficher le dialogue de filtrage
  void _showFilterDialog() {
    setState(() {
      isFilterDialogOpen = true;
    });

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Filtrer les pièces',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Statut de stock:',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 10),
                  // Option: Toutes les pièces
                  RadioListTile<StockFilter>(
                    title: const Text('Toutes les pièces'),
                    value: StockFilter.all,
                    groupValue: currentFilter,
                    onChanged: (StockFilter? value) {
                      if (value != null) {
                        setState(() {
                          currentFilter = value;
                        });
                      }
                    },
                  ),
                  // Option: En stock
                  RadioListTile<StockFilter>(
                    title: const Text('En stock'),
                    value: StockFilter.inStock,
                    groupValue: currentFilter,
                    onChanged: (StockFilter? value) {
                      if (value != null) {
                        setState(() {
                          currentFilter = value;
                        });
                      }
                    },
                  ),
                  // Option: Rupture de stock
                  RadioListTile<StockFilter>(
                    title: const Text('Rupture de stock'),
                    value: StockFilter.outOfStock,
                    groupValue: currentFilter,
                    onChanged: (StockFilter? value) {
                      if (value != null) {
                        setState(() {
                          currentFilter = value;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          setState(() {
                            isFilterDialogOpen = false;
                          });
                        },
                        child: const Text('Annuler'),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          setState(() {
                            isFilterDialogOpen = false;
                            _applyFilters(); // Appliquer les filtres
                          });
                        },
                        child: const Text('Appliquer'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    ).then((_) {
      setState(() {
        isFilterDialogOpen = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final appColor = Provider.of<AppAdaptiveColors>(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Liste des Pièces'),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => _addNewPiece(appColor),
            icon: Icon(Icons.add, color: appColor.primary, size: 32),
            tooltip: 'Ajouter une pièce',
          ),
        ],
      ),
      body: Column(
        children: [
          // Barre de recherche et filtres
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) {
                      setState(() => query = val);
                      _applyFilters(); // Appliquer les filtres à chaque changement
                    },
                    decoration: InputDecoration(
                      hintText: "Rechercher une pièce...",
                      border: InputBorder.none,
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                      ),
                    ),
                  ),
                ),
                // Bouton de filtrage avec indicateur visuel
                Stack(
                  children: [
                    IconButton(
                      onPressed: _showFilterDialog,
                      icon: Icon(
                        Icons.filter_alt_outlined,
                        color: currentFilter != StockFilter.all
                            ? appColor
                                  .primary // Couleur différente quand un filtre est actif
                            : Colors.grey,
                        size: 32,
                      ),
                      tooltip: 'Filtrer',
                    ),
                    if (currentFilter != StockFilter.all)
                      Positioned(
                        top: 5,
                        right: 5,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: appColor.primary,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 10,
                            minHeight: 10,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),

          // Affichage du filtre actif
          if (currentFilter != StockFilter.all)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              child: Row(
                children: [
                  Chip(
                    label: Text(
                      currentFilter == StockFilter.inStock
                          ? 'En stock'
                          : 'Rupture de stock',
                      style: TextStyle(color: appColor.primary),
                    ),
                    backgroundColor: appColor.primary.withOpacity(0.1),
                    deleteIcon: const Icon(Icons.close, size: 18),
                    onDeleted: () {
                      setState(() {
                        currentFilter = StockFilter.all;
                        _applyFilters();
                      });
                    },
                  ),
                ],
              ),
            ),

          // État de chargement/erreur
          if (isLoading)
            Expanded(
              child: ListView.builder(
                itemCount: 5,
                itemBuilder: (context, index) => buildPieceItemShimmer(context),
              ),
            )
          else if (errorMessage.isNotEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      errorMessage,
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _loadPieces,
                      child: const Text('Réessayer'),
                    ),
                  ],
                ),
              ),
            )
          else if (filteredPieces.isEmpty)
            const Expanded(
              child: Center(
                child: Text(
                  "Aucune pièce trouvée",
                  style: TextStyle(fontSize: 18),
                ),
              ),
            )
          else
            // Liste des pièces
            Expanded(
              child: RefreshIndicator(
                color: appColor.primary,
                onRefresh: _loadPieces,
                child: ListView.builder(
                  itemCount: filteredPieces.length,
                  itemBuilder: (context, index) {
                    final piece = filteredPieces[index];
                    return buildPieceItems(piece, context, index);
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _addNewPiece(AppAdaptiveColors appColor) {
    WoltModalSheet.show(
      context: context,
      pageListBuilder: (modalSheetContext) => [
        WoltModalSheetPage(
          topBar: Container(
            padding: EdgeInsets.all(10),
            alignment: Alignment.center,
            child: Text(
              "Créer une nouvelle pièce",
              textAlign: TextAlign.center,
              style: AppStyles.titleLarge(context),
            ),
          ),
          trailingNavBarWidget: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
          child: CreatePieceForm(pContext: context),
        ),
      ],
      modalTypeBuilder: (context) {
        final screenWidth = MediaQuery.of(context).size.width;
        return screenWidth > 700
            ? WoltModalType.alertDialog()
            : WoltModalType.sideSheet();
      },
      onModalDismissedWithBarrierTap: () => Navigator.pop(context),
    );
  }
}
