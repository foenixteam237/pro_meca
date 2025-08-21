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
  _PieceSelectionModalState createState() => _PieceSelectionModalState();
}

class _PieceSelectionModalState extends State<PieceSelectionModal> {
  final PiecesService _piecesServices = PiecesService();

  List<PieceCategorie> _categories = [];
  List<Piece> _pieces = [];
  List<Piece> _filteredPieces = [];

  String? _selectedCategoryId;
  String? _selectedCategoryName;
  String? _selectedPieceId;
  String? _selectedPieceName;

  String _selectedCondition = 'N/A';
  int _stockQuantity = 0;
  double _unitPrice = 0;
  int _quantityToUse = 1;

  bool _isLoading = true;
  bool _isSearchingCategory = false;
  bool _isSearchingPiece = false;

  final TextEditingController _categorySearchController =
      TextEditingController();
  final TextEditingController _pieceSearchController = TextEditingController();

  double get _totalPrice => _unitPrice * _quantityToUse;

  // Mémoization pour éviter les reconstructions inutiles
  late final List<DropdownMenuItem<String>> _categoryDropdownItems;
  List<DropdownMenuItem<String>> _pieceDropdownItems = [];

  @override
  void initState() {
    super.initState();
    _loadData();

    _categorySearchController.addListener(_onCategorySearchChanged);
    _pieceSearchController.addListener(_onPieceSearchChanged);
  }

  @override
  void dispose() {
    _categorySearchController.removeListener(_onCategorySearchChanged);
    _pieceSearchController.removeListener(_onPieceSearchChanged);
    _categorySearchController.dispose();
    _pieceSearchController.dispose();
    super.dispose();
  }

  void _onCategorySearchChanged() {
    final query = _categorySearchController.text;
    if (query.isEmpty && _isSearchingCategory) {
      setState(() => _isSearchingCategory = false);
    } else if (query.isNotEmpty && !_isSearchingCategory) {
      setState(() => _isSearchingCategory = true);
    }
  }

  void _onPieceSearchChanged() {
    final query = _pieceSearchController.text;
    if (query.isEmpty) {
      if (_filteredPieces.length != _pieces.length) {
        setState(() {
          _filteredPieces = _pieces;
          _isSearchingPiece = false;
        });
      }
      return;
    }

    final filtered = _pieces
        .where(
          (piece) =>
              piece.name.toLowerCase().contains(query.toLowerCase()) ||
              piece.reference.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();

    if (_filteredPieces.length != filtered.length) {
      setState(() {
        _filteredPieces = filtered;
        _isSearchingPiece = true;
      });
    }
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final categoriesData = await _piecesServices.fetchCategorieWithPieces(
        context,
      );

      if (categoriesData.isNotEmpty) {
        _selectedCategoryId = categoriesData.first.id;
        _selectedCategoryName = categoriesData.first.name;
        _loadPiecesForCategory(_selectedCategoryId!);
        // Préparer les items du dropdown des catégories
        _categoryDropdownItems = categoriesData.map((category) {
          return DropdownMenuItem<String>(
            value: category.id,
            child: Text(category.name),
          );
        }).toList();
      }

      setState(() {
        _categories = categoriesData;
        _isLoading = false;
      });
    } catch (error) {
      setState(() => _isLoading = false);
      print('Erreur lors du chargement: $error');
    }
  }

  void _loadPiecesForCategory(String categoryId) {
    final category = _categories.firstWhere(
      (cat) => cat.id == categoryId,
      orElse: () => PieceCategorie(
        id: '',
        name: '',
        description: '',
        logo: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );

    if (category.id.isEmpty) return;

    final newPieces = category.pieces ?? [];
    final newFilteredPieces = List<Piece>.from(newPieces);

    // Préparer les items du dropdown des pièces
    final newPieceDropdownItems = newFilteredPieces.map((piece) {
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

    Piece? newSelectedPiece;
    if (newPieces.isNotEmpty) {
      newSelectedPiece = newPieces.first;
    }

    setState(() {
      _pieces = newPieces;
      _filteredPieces = newFilteredPieces;
      _pieceDropdownItems = newPieceDropdownItems;

      if (newSelectedPiece != null) {
        _updateSelectedPiece(newSelectedPiece);
      } else {
        _resetSelectedPiece();
      }
    });
  }

  void _updateSelectedPiece(Piece piece) {
    setState(() {
      _selectedPieceId = piece.id;
      _selectedPieceName = piece.name;
      _stockQuantity = piece.stock;
      _unitPrice = piece.sellingPrice.toDouble();
      _quantityToUse = 1;
      _selectedCondition = piece.condition;
    });
  }

  void _resetSelectedPiece() {
    setState(() {
      _selectedPieceId = null;
      _selectedPieceName = null;
      _stockQuantity = 0;
      _unitPrice = 0;
      _quantityToUse = 0;
    });
  }

  void _onCategorySelected(String? categoryId) {
    if (categoryId != null && categoryId != _selectedCategoryId) {
      final category = _categories.firstWhere(
        (cat) => cat.id == categoryId,
        orElse: () => PieceCategorie(
          id: '',
          name: '',
          description: '',
          logo: '',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );

      if (category.id.isNotEmpty) {
        _loadPiecesForCategory(categoryId);
        setState(() {
          _selectedCategoryId = categoryId;
          _selectedCategoryName = category.name;
          _categorySearchController.text = category.name;
          _isSearchingCategory = false;
        });
      }
    }
  }

  void _onPieceSelected(String? pieceId) {
    if (pieceId != null && pieceId != _selectedPieceId) {
      final piece = _pieces.firstWhere(
        (p) => p.id == pieceId,
        orElse: () => Piece(
          id: '',
          name: '',
          reference: '',
          barcode: '',
          logo: '',
          sourceId: '',
          originVehicle: '',
          recoveryDate: null,
          isUsed: false,
          stock: 0,
          criticalStock: 0,
          location: '',
          condition: '',
          sellingPrice: 0,
          purchaseDate: null,
          taxRate: 0.0,
          categoryId: '',
          notes: '',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          category: Category(id: '', name: '', description: '', logo: ''),
        ),
      );

      if (piece.stock > 0) {
        setState(() {
          _updateSelectedPiece(piece);
          _pieceSearchController.text = piece.name;
          _isSearchingPiece = false;
        });
      }
    }
  }

  void _decrementQuantity() {
    if (_quantityToUse > 1) {
      setState(() => _quantityToUse--);
    }
  }

  void _incrementQuantity() {
    if (_quantityToUse < _stockQuantity) {
      setState(() => _quantityToUse++);
    }
  }

  void _addPiece() {
    if (_selectedPieceId == null) return;

    final pieceData = {
      'pieceId': _selectedPieceId,
      'category': _selectedCategoryName,
      'name': _selectedPieceName,
      'condition': _selectedCondition,
      'unitPrice': _unitPrice,
      'quantity': _quantityToUse,
      'totalPrice': _totalPrice,
      'stock': _stockQuantity,
    };

    widget.onPieceAdded?.call(pieceData);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(),
                const SizedBox(height: 20),
                _buildTitle(),
                const SizedBox(height: 30),
                _buildCategoryDropdown(),
                const SizedBox(height: 20),
                _buildPieceDropdown(),
                const SizedBox(height: 20),
                _buildConditionSection(),
                const SizedBox(height: 24),
                _buildStockAndPriceInfo(),
                const SizedBox(height: 20),
                _buildQuantitySection(),
                const SizedBox(height: 24),
                _buildTotalPrice(),
                const SizedBox(height: 30),
                _buildActionButtons(),
                SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
              ],
            ),
    );
  }

  Widget _buildHeader() {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return const Center(
      child: Text(
        'Sélectionner une pièce',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel('Catégorie'),
        const SizedBox(height: 8),
        _buildSearchableDropdown(
          controller: _categorySearchController,
          hintText: 'Rechercher une catégorie',
          items: _categoryDropdownItems,
          selectedValue: _selectedCategoryId,
          onChanged: _onCategorySelected,
          isSearching: _isSearchingCategory,
        ),
      ],
    );
  }

  Widget _buildPieceDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel('Nom de la pièce'),
        const SizedBox(height: 8),
        _buildSearchableDropdown(
          controller: _pieceSearchController,
          hintText: 'Rechercher une pièce',
          items: _pieceDropdownItems,
          selectedValue: _selectedPieceId,
          onChanged: _onPieceSelected,
          isSearching: _isSearchingPiece,
          enabled: _selectedCategoryId != null,
        ),
      ],
    );
  }

  Widget _buildSearchableDropdown({
    required TextEditingController controller,
    required String hintText,
    required List<DropdownMenuItem<String>> items,
    required String? selectedValue,
    required Function(String?) onChanged,
    required bool isSearching,
    bool enabled = true,
  }) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: enabled ? Colors.white : Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: selectedValue,
          items: items,
          onChanged: enabled ? onChanged : null,
        ),
      ),
    );
  }

  Widget _buildConditionSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildSectionLabel('État de la pièce'),
        Text(_selectedCondition),
      ],
    );
  }

  Widget _buildStockAndPriceInfo() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow('En stock', '$_stockQuantity'),
              const SizedBox(height: 12),
              _buildInfoRow(
                'Prix unitaire',
                '${_unitPrice.toStringAsFixed(0)} Fcfa',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuantitySection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Qté à utiliser',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        _buildQuantityControl(),
      ],
    );
  }

  Widget _buildQuantityControl() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildQuantityButton(Icons.remove, _decrementQuantity),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Text(
              '$_quantityToUse',
              style: AppStyles.bodyMedium(
                context,
              ).copyWith(color: Colors.black),
            ),
          ),
          _buildQuantityButton(Icons.add, _incrementQuantity),
        ],
      ),
    );
  }

  Widget _buildTotalPrice() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Prix Total',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          Text(
            '${_totalPrice.toStringAsFixed(0)} Fcfa',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    final appColor = Provider.of<AppAdaptiveColors>(context);
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: widget.onCancel,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[600],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Annuler',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),

        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _selectedPieceId == null ? null : _addPiece,
            style: ElevatedButton.styleFrom(
              backgroundColor: _selectedPieceId == null
                  ? Colors.grey[400]
                  : appColor.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Ajouter',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildQuantityButton(IconData icon, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Icon(icon, size: 20, color: Colors.black54),
      ),
    );
  }
}
