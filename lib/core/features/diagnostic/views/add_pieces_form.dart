import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:pro_meca/core/constants/app_adaptive_colors.dart';
import 'package:pro_meca/core/features/pieces/services/pieces_services.dart';
import 'package:pro_meca/core/models/categories.dart';
import 'package:pro_meca/core/models/pieces.dart';
import 'package:provider/provider.dart';

class PieceSelectionModal extends StatefulWidget {
  final Function(Map<String, dynamic>)? onPieceAdded;
  final VoidCallback? onCancel;
  final bool isMovement;

  const PieceSelectionModal({
    super.key,
    this.onPieceAdded,
    this.onCancel,
    this.isMovement = false,
  });

  @override
  State<PieceSelectionModal> createState() => _PieceSelectionModalState();
}

class _PieceSelectionModalState extends State<PieceSelectionModal> {
  final PiecesService _piecesServices = PiecesService();

  List<PieceCategorie> _categories = [];
  List<Piece> _filteredPieces = [];

  String? _selectedCategoryId;
  Piece? _selectedPiece;

  int _quantityToUse = 1;

  bool _isLoading = true;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final categoriesData = await _piecesServices.fetchCategorieWithPieces(
        context,
      );
      if (categoriesData.isNotEmpty) {
        _selectedCategoryId = categoriesData.first.id;
        _categories = categoriesData;
        _loadPiecesForCategory(_selectedCategoryId!);
      }
    } catch (error) {
      debugPrint('Erreur lors du chargement: $error');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _loadPiecesForCategory(String categoryId) {
    final category = _categories.firstWhere((c) => c.id == categoryId);
    final newPieces = category.pieces ?? [];
    setState(() {
      _filteredPieces = List<Piece>.from(newPieces);
      if (newPieces.isNotEmpty) {
        _updateSelectedPiece(newPieces.first);
      } else {
        _resetSelectedPiece();
      }
    });
  }

  void _updateSelectedPiece(Piece piece) {
    setState(() {
      _selectedPiece = piece;
      _quantityToUse = 1;
    });
  }

  void _resetSelectedPiece() {
    setState(() {
      _selectedPiece = null;
      _quantityToUse = 0;
    });
  }

  void _onCategorySelected(PieceCategorie? category) {
    if (category == null || category.id == _selectedCategoryId) return;
    setState(() {
      _selectedCategoryId = category.id;
      _selectedPiece = null;
    });
    _loadPiecesForCategory(category.id);
  }

  void _onPieceSelected(Piece? piece) {
    if (piece == null || piece.id == _selectedPiece?.id) return;
    if (piece.stock > 0) _updateSelectedPiece(piece);
  }

  void _decrementQuantity() {
    if (_quantityToUse > 1) setState(() => _quantityToUse--);
  }

  void _incrementQuantity() {
    if (widget.isMovement) {
      if (_selectedPiece != null) {
        setState(() => _quantityToUse++);
      }
    } else {
      if (_selectedPiece != null && _quantityToUse < _selectedPiece!.stock) {
        setState(() => _quantityToUse++);
      }
    }
  }

  void _addPiece() {
    if (_selectedPiece == null) return;
    if (!_formKey.currentState!.validate()) return;

    final pieceData = {
      'id': _selectedPiece!.id,
      'name': _selectedPiece!.name,
      'unitPrice': _selectedPiece!.sellingPrice,
      'reference': _selectedPiece!.reference,
      'quantity': _quantityToUse,
      'stock': _selectedPiece!.stock,
      'category': _selectedPiece!.category.name,
    };

    widget.onPieceAdded?.call(pieceData);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColor = Provider.of<AppAdaptiveColors>(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Form(
      key: _formKey,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDarkMode ? appColor.customBackground(context) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _isLoading
              ? Center(
                  child: CircularProgressIndicator(color: appColor.primary),
                )
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _Header(isDarkMode: isDarkMode, appColor: appColor),
                      const SizedBox(height: 20),
                      _Title(isDarkMode: isDarkMode),
                      const SizedBox(height: 30),
                      _buildCategoryDropdown(isDarkMode, appColor),
                      const SizedBox(height: 20),
                      _buildPieceDropdown(isDarkMode, appColor),
                      if (_selectedPiece != null) ...[
                        const SizedBox(height: 20),
                        _InfoRow(
                          "État de la pièce",
                          Piece.shortConditionLabel(_selectedPiece!.condition),
                          isDarkMode,
                        ),
                        const SizedBox(height: 20),
                        _InfoRow(
                          "En stock",
                          _selectedPiece!.stock.toString(),
                          isDarkMode,
                        ),
                        const SizedBox(height: 12),
                        _InfoRow(
                          "Prix unitaire",
                          "${_selectedPiece!.sellingPrice.toString()} Fcfa",
                          isDarkMode,
                        ),
                        const SizedBox(height: 20),
                        _QuantitySelector(
                          quantity: _quantityToUse,
                          maxQuantity: _selectedPiece!.stock,
                          onAdd: _incrementQuantity,
                          onRemove: _decrementQuantity,
                          isDarkMode: isDarkMode,
                          isMvt: widget.isMovement,
                          appColor: appColor,
                        ),
                        const SizedBox(height: 24),
                        _InfoRow(
                          "Prix total",
                          "${(_selectedPiece!.sellingPrice! * _quantityToUse).toStringAsFixed(0)} Fcfa",
                          isDarkMode,
                          bold: true,
                        ),
                      ],
                      const SizedBox(height: 30),
                      _ActionButtons(
                        onCancel: widget.onCancel,
                        onAdd: _selectedPiece == null ? null : _addPiece,
                        appColor: appColor,
                        isDarkMode: isDarkMode,
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).padding.bottom + 20,
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown(bool isDarkMode, AppAdaptiveColors appColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Label("Catégorie", isDarkMode),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: isDarkMode
                  ? Colors.white.withValues(alpha: 0.4)
                  : Colors.grey,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownSearch<PieceCategorie>(
            items: (filter, t) => _categories,
            compareFn: (item1, item2) => item1.id == item2.id,
            itemAsString: (item) => item.name,
            selectedItem: _categories.firstWhere(
              (c) => c.id == _selectedCategoryId,
              orElse: () => _categories.first,
            ),
            filterFn: (item, filter) {
              return item.name.toLowerCase().contains(filter.toLowerCase());
            },
            popupProps: PopupProps.menu(
              showSearchBox: true,
              searchFieldProps: TextFieldProps(
                decoration: InputDecoration(
                  hintText: "Rechercher une catégorie...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              menuProps: MenuProps(
                backgroundColor: isDarkMode
                    ? appColor.customBackground(context)
                    : Colors.white,
              ),
              listViewProps: ListViewProps(padding: EdgeInsets.zero),
              itemBuilder: (context, item, isDisabled, isSelected) {
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: appColor.primary,
                    child: Text(
                      item.name[0],
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(
                    item.name,
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                  subtitle: Text(
                    "${item.pieces?.length ?? 0} pièces disponibles",
                    style: TextStyle(
                      color: isDarkMode ? Colors.white70 : Colors.black54,
                    ),
                  ),
                );
              },
            ),
            decoratorProps: DropDownDecoratorProps(
              decoration: InputDecoration(
                hintText: "Sélectionner une catégorie",
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                hintStyle: TextStyle(
                  color: isDarkMode ? Colors.white70 : Colors.grey[600],
                ),
              ),
              baseStyle: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            onChanged: _onCategorySelected,
          ),
        ),
      ],
    );
  }

  Widget _buildPieceDropdown(bool isDarkMode, AppAdaptiveColors appColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Label("Nom de la pièce", isDarkMode),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: isDarkMode
                  ? Colors.white.withValues(alpha: 0.4)
                  : Colors.grey,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownSearch<Piece>(
            items: (filter, loadProps) => _filteredPieces,
            compareFn: (item1, item2) => item1.id == item2.id,
            itemAsString: (item) => item.name,
            selectedItem: _selectedPiece,
            filterFn: (item, filter) {
              return item.name.toLowerCase().contains(filter.toLowerCase());
            },
            popupProps: PopupProps.menu(
              showSearchBox: true,
              searchFieldProps: TextFieldProps(
                decoration: InputDecoration(
                  hintText: "Rechercher une pièce...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              menuProps: MenuProps(
                backgroundColor: isDarkMode
                    ? appColor.customBackground(context)
                    : Colors.white,
              ),
              listViewProps: ListViewProps(padding: EdgeInsets.zero),
              itemBuilder: (context, item, isDisabled, isSelected) {
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: appColor.primary,
                    child: Text(
                      item.name[0],
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(
                    item.name,
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                  subtitle: Text(
                    "Stock: ${item.stock} | ${item.sellingPrice} Fcfa",
                    style: TextStyle(
                      color: isDarkMode ? Colors.white70 : Colors.black54,
                    ),
                  ),
                  trailing: item.stock == 0
                      ? Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            "Rupture",
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        )
                      : null,
                );
              },
            ),

            decoratorProps: DropDownDecoratorProps(
              decoration: InputDecoration(
                hintText: "Sélectionner une pièce",
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                hintStyle: TextStyle(
                  color: isDarkMode ? Colors.white70 : Colors.grey[600],
                ),
              ),
              baseStyle: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            onChanged: _onPieceSelected,
            validator: (value) {
              if (value == null) {
                return "Pièce requise";
              }
              return null;
            },
          ),
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  final bool isDarkMode;
  final AppAdaptiveColors appColor;
  const _Header({required this.isDarkMode, required this.appColor});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.white30 : Colors.grey[300],
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

class _Title extends StatelessWidget {
  final bool isDarkMode;
  const _Title({required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        "Sélectionner une pièce",
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: isDarkMode ? Colors.white : Colors.black87,
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  final bool isDarkMode;
  const _Label(this.text, this.isDarkMode);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: isDarkMode ? Colors.white : Colors.black87,
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isDarkMode;
  final bool bold;
  const _InfoRow(this.label, this.value, this.isDarkMode, {this.bold = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: isDarkMode ? Colors.white70 : Colors.black87,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
      ],
    );
  }
}

class _QuantitySelector extends StatelessWidget {
  final int quantity;
  final int maxQuantity;
  final VoidCallback onAdd;
  final VoidCallback onRemove;
  final bool isDarkMode;
  final bool isMvt;
  final AppAdaptiveColors appColor;

  const _QuantitySelector({
    required this.quantity,
    required this.maxQuantity,
    required this.onAdd,
    required this.onRemove,
    required this.isDarkMode,
    required this.isMvt,
    required this.appColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Qté à utiliser",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: isDarkMode
                ? Colors.white.withValues(alpha: 0.2)
                : Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _button(Icons.remove, onRemove, isDarkMode, quantity > 1),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                child: Text(
                  "$quantity",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
              ),
              _button(
                Icons.add,
                onAdd,
                isDarkMode,
                isMvt ? true : quantity < maxQuantity,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _button(
    IconData icon,
    VoidCallback onTap,
    bool isDarkMode,
    bool enabled,
  ) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Icon(
          icon,
          size: 20,
          color: enabled
              ? (isDarkMode ? Colors.white70 : Colors.black54)
              : (isDarkMode ? Colors.white30 : Colors.grey),
        ),
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  final VoidCallback? onCancel;
  final VoidCallback? onAdd;
  final AppAdaptiveColors appColor;
  final bool isDarkMode;

  const _ActionButtons({
    required this.onCancel,
    required this.onAdd,
    required this.appColor,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: onCancel,
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.transparent,
              foregroundColor: isDarkMode ? Colors.white : Colors.black87,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              side: BorderSide(
                color: isDarkMode ? Colors.white30 : Colors.grey,
              ),
            ),
            child: const Text(
              "Annuler",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: onAdd,
            style: ElevatedButton.styleFrom(
              backgroundColor: onAdd == null ? Colors.grey : appColor.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              "Ajouter",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }
}
