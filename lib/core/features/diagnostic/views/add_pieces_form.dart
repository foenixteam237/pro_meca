import 'package:flutter/material.dart';
import 'package:pro_meca/core/constants/app_adaptive_colors.dart';
import 'package:pro_meca/core/constants/app_styles.dart';
import 'package:pro_meca/core/features/pieces/services/pieces_services.dart';
import 'package:pro_meca/core/models/categories.dart';
import 'package:pro_meca/core/models/pieces.dart';
import 'package:provider/provider.dart';

class PieceSelectionModal extends StatefulWidget {
  final Function(Map<String, dynamic>)? onPieceAdded;
  final VoidCallback? onCancel;

  const PieceSelectionModal({super.key, this.onPieceAdded, this.onCancel});

  @override
  State<PieceSelectionModal> createState() => _PieceSelectionModalState();
}

class _PieceSelectionModalState extends State<PieceSelectionModal> {
  final PiecesService _piecesServices = PiecesService();

  List<PieceCategorie> _categories = [];
  List<Piece> _pieces = [];
  List<Piece> _filteredPieces = [];

  String? _selectedCategoryId;
  String? _selectedPieceId;

  String _selectedCondition = 'N/A';
  int _stockQuantity = 0;
  double _unitPrice = 0;
  int _quantityToUse = 1;

  bool _isLoading = true;

  final TextEditingController _categorySearchController =
      TextEditingController();
  final TextEditingController _pieceSearchController = TextEditingController();

  double get _totalPrice => _unitPrice * _quantityToUse;

  List<DropdownMenuItem<String>> _categoryDropdownItems = [];
  List<DropdownMenuItem<String>> _pieceDropdownItems = [];

  @override
  void initState() {
    super.initState();
    _loadData();
    _pieceSearchController.addListener(_onPieceSearchChanged);
  }

  @override
  void dispose() {
    _categorySearchController.dispose();
    _pieceSearchController.dispose();
    super.dispose();
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
        _categoryDropdownItems = categoriesData.map((category) {
          return DropdownMenuItem<String>(
            value: category.id,
            child: Text(category.name),
          );
        }).toList();
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
    _filteredPieces = List<Piece>.from(newPieces);
    _pieceDropdownItems = newPieces.map((piece) {
      return DropdownMenuItem<String>(
        value: piece.id,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(piece.name),
            Text(
              'Ref: ${piece.reference}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      );
    }).toList();
    setState(() {
      _pieces = newPieces;
      _filteredPieces = newPieces;
      if (newPieces.isNotEmpty) {
        _updateSelectedPiece(newPieces.first);
      } else {
        _resetSelectedPiece();
      }
    });
  }

  void _onPieceSearchChanged() {
    final query = _pieceSearchController.text.toLowerCase();
    if (query.isEmpty) {
      setState(() => _filteredPieces = _pieces);
      return;
    }
    setState(() {
      _filteredPieces = _pieces.where((piece) {
        return piece.name.toLowerCase().contains(query) ||
            piece.reference.toLowerCase().contains(query);
      }).toList();
    });
  }

  void _updateSelectedPiece(Piece piece) {
    setState(() {
      _selectedPieceId = piece.id;
      _stockQuantity = piece.stock;
      _unitPrice = piece.sellingPrice.toDouble();
      _quantityToUse = 1;
      _selectedCondition = piece.condition;
    });
  }

  void _resetSelectedPiece() {
    setState(() {
      _selectedPieceId = null;
      _stockQuantity = 0;
      _unitPrice = 0;
      _quantityToUse = 0;
      _selectedCondition = 'N/A';
    });
  }

  void _onCategorySelected(String? categoryId) {
    if (categoryId == null || categoryId == _selectedCategoryId) return;
    _selectedCategoryId = categoryId;
    _loadPiecesForCategory(categoryId);
  }

  void _onPieceSelected(String? pieceId) {
    if (pieceId == null || pieceId == _selectedPieceId) return;
    final piece = _pieces.firstWhere((p) => p.id == pieceId);
    if (piece.stock > 0) _updateSelectedPiece(piece);
  }

  void _decrementQuantity() {
    if (_quantityToUse > 1) setState(() => _quantityToUse--);
  }

  void _incrementQuantity() {
    if (_quantityToUse < _stockQuantity) setState(() => _quantityToUse++);
  }

  void _addPiece() {
    if (_selectedPieceId == null) return;

    final pieceData = {
      'pieceId': _selectedPieceId,
      'unitPrice': _unitPrice,
      'quantity': _quantityToUse,
    };

    widget.onPieceAdded?.call(pieceData);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColor = Provider.of<AppAdaptiveColors>(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode ? appColor.customBackground(context) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _isLoading
            ? Center(child: CircularProgressIndicator(color: appColor.primary))
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
                    const SizedBox(height: 20),
                    _InfoRow(
                      "État de la pièce",
                      _selectedCondition,
                      isDarkMode,
                    ),
                    const SizedBox(height: 20),
                    _InfoRow("En stock", "$_stockQuantity", isDarkMode),
                    const SizedBox(height: 12),
                    _InfoRow(
                      "Prix unitaire",
                      "${_unitPrice.toStringAsFixed(0)} Fcfa",
                      isDarkMode,
                    ),
                    const SizedBox(height: 20),
                    _QuantitySelector(
                      quantity: _quantityToUse,
                      onAdd: _incrementQuantity,
                      onRemove: _decrementQuantity,
                      isDarkMode: isDarkMode,
                      appColor: appColor,
                    ),
                    const SizedBox(height: 24),
                    _InfoRow(
                      "Prix total",
                      "${_totalPrice.toStringAsFixed(0)} Fcfa",
                      isDarkMode,
                      bold: true,
                    ),
                    const SizedBox(height: 30),
                    _ActionButtons(
                      onCancel: widget.onCancel,
                      onAdd: _selectedPieceId == null ? null : _addPiece,
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
    );
  }

  Widget _buildCategoryDropdown(bool isDarkMode, AppAdaptiveColors appColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Label("Catégorie", isDarkMode),
        const SizedBox(height: 8),
        SearchableDropdown(
          value: _selectedCategoryId,
          hint: "Rechercher une catégorie",
          items: _categoryDropdownItems,
          onChanged: _onCategorySelected,
          enabled: true,
          isDarkMode: isDarkMode,
          appColor: appColor,
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
        SearchableDropdown(
          value: _selectedPieceId,
          hint: "Rechercher une pièce",
          items: _pieceDropdownItems,
          onChanged: _onPieceSelected,
          enabled: _selectedCategoryId != null,
          isDarkMode: isDarkMode,
          appColor: appColor,
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
          color: isDarkMode
              ? appColor.customBackground(context)
              : Colors.grey[300],
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
        Text(value, style: AppStyles.titleMedium(context)),
      ],
    );
  }
}

class _QuantitySelector extends StatelessWidget {
  final int quantity;
  final VoidCallback onAdd;
  final VoidCallback onRemove;
  final bool isDarkMode;
  final AppAdaptiveColors appColor;

  const _QuantitySelector({
    required this.quantity,
    required this.onAdd,
    required this.onRemove,
    required this.isDarkMode,
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
                ? Colors.white.withOpacity(0.2)
                : Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _button(Icons.remove, onRemove, isDarkMode),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                child: Text(
                  "$quantity",
                  style: AppStyles.bodyMedium(
                    context,
                  ).copyWith(color: isDarkMode ? Colors.white : Colors.black),
                ),
              ),
              _button(Icons.add, onAdd, isDarkMode),
            ],
          ),
        ),
      ],
    );
  }

  Widget _button(IconData icon, VoidCallback onTap, bool isDarkMode) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Icon(
          icon,
          size: 20,
          color: isDarkMode ? Colors.white70 : Colors.black54,
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
          child: ElevatedButton(
            onPressed: onCancel,
            style: ElevatedButton.styleFrom(
              backgroundColor: isDarkMode ? Colors.red[700] : Colors.red[600],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
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

class SearchableDropdown extends StatelessWidget {
  final String? value;
  final String hint;
  final List<DropdownMenuItem<String>> items;
  final void Function(String?)? onChanged;
  final bool enabled;
  final bool isDarkMode;
  final AppAdaptiveColors appColor;

  const SearchableDropdown({
    super.key,
    required this.value,
    required this.hint,
    required this.items,
    required this.onChanged,
    required this.enabled,
    required this.isDarkMode,
    required this.appColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: enabled
            ? (isDarkMode ? appColor.customBackground(context) : Colors.white)
            : (isDarkMode
                  ? appColor.customBackground(context)
                  : Colors.grey[100]),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDarkMode ? Colors.white.withOpacity(0.4) : Colors.grey,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: value,
          items: items,
          onChanged: enabled ? onChanged : null,
          dropdownColor: isDarkMode
              ? appColor.customBackground(context)
              : Colors.white,
          icon: Icon(
            Icons.keyboard_arrow_down,
            color: isDarkMode ? Colors.white70 : Colors.black54,
          ),
          hint: Text(
            hint,
            style: TextStyle(
              color: isDarkMode ? Colors.white70 : Colors.grey[600],
            ),
          ),
        ),
      ),
    );
  }
}
