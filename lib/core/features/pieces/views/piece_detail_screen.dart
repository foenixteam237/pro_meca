import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pro_meca/core/constants/app_styles.dart';
import 'package:pro_meca/core/features/pieces/widgets/add_pieces_form.dart';
import 'package:pro_meca/core/models/pieces.dart';
import '../services/pieces_services.dart';

class PieceDetailScreen extends StatefulWidget {
  final Piece piece;
  final VoidCallback? onPieceUpdated;

  const PieceDetailScreen({
    super.key,
    required this.piece,
    this.onPieceUpdated,
  });

  @override
  State<PieceDetailScreen> createState() => _PieceDetailScreenState();
}

class _PieceDetailScreenState extends State<PieceDetailScreen>
    with SingleTickerProviderStateMixin {
  int _currentQuantity = 0;
  final TextEditingController _quantityController = TextEditingController();
  bool _isLoading = false;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _currentQuantity = widget.piece.stock;
    _quantityController.text = widget.piece.stock.toString();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _updateQuantity() async {
    if (_currentQuantity == widget.piece.stock) return;

    setState(() => _isLoading = true);
    try {
      if (await _updatePieceData({'stock': _currentQuantity})) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Theme.of(context).primaryColor,
            content: Text(
              "Quantité mise à jour avec succès!",
              style: AppStyles.bodyMedium(context),
            ),
          ),
        );
        widget.onPieceUpdated?.call();
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Echec mise à jour quantité")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<bool> _updatePieceData(Map<String, dynamic> data) async {
    try {
      final formData = FormData();
      formData.fields.add(MapEntry('data', jsonEncode(data)));
      return await PiecesService().updatePiece(
        widget.piece.id,
        formData,
        context,
      );
    } catch (e) {
      debugPrint("Erreur mise à jour: $e");
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Détails de la pièce'),
        actions: [
          // IconButton(
          //   icon: Icon(Icons.edit),
          //   onPressed: () {
          //     _tabController.animateTo(1); // Basculer vers l'onglet d'édition
          //   },
          //   tooltip: 'Modifier tous les champs',
          // ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(icon: Icon(Icons.visibility), text: 'Vue rapide'),
            Tab(icon: Icon(Icons.edit), text: 'Édition complète'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildQuickViewTab(),
          PieceEditForm(
            piece: widget.piece,
            onPieceUpdated: widget.onPieceUpdated,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickViewTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          _buildPieceImage(),
          SizedBox(height: 20),
          _buildBasicInfo(),
          SizedBox(height: 20),
          _buildQuickQuantityEditor(),
          SizedBox(height: 20),
          _buildAdditionalInfo(),
        ],
      ),
    );
  }

  Widget _buildPieceImage() {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey[100],
      ),
      child: widget.piece.logo!.isNotEmpty
          ? ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                widget.piece.logo!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildPlaceholderImage(),
              ),
            )
          : _buildPlaceholderImage(),
    );
  }

  Widget _buildPlaceholderImage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2, size: 48, color: Colors.grey),
          SizedBox(height: 8),
          Text('Aucune image', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildBasicInfo() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.piece.name,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Chip(
                  label: Text(widget.piece.category.name),
                  backgroundColor: Theme.of(
                    context,
                  ).primaryColor.withOpacity(0.1),
                ),
                SizedBox(width: 8),
                Chip(
                  label: Text(
                    _formatCondition(widget.piece.condition),
                    style: TextStyle(color: Colors.white),
                  ),
                  backgroundColor: _getConditionColor(widget.piece.condition),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text('Référence: ${widget.piece.reference}'),
            if (widget.piece.barcode != null &&
                widget.piece.barcode!.isNotEmpty)
              Text('Code-barres: ${widget.piece.barcode}'),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickQuantityEditor() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Text(
            //   'Gestion du stock',
            //   style: Theme.of(
            //     context,
            //   ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            // ),
            // SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Quantité actuelle'),
                      SizedBox(height: 8),
                      TextField(
                        controller: _quantityController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _currentQuantity = int.tryParse(value) ?? 0;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 16),
                Column(
                  children: [
                    Text('Stock critique'),
                    SizedBox(height: 8),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color:
                            widget.piece.criticalStock != null &&
                                widget.piece.stock <=
                                    widget.piece.criticalStock!
                            ? Colors.orange[100]
                            : Colors.green[100],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        widget.piece.criticalStock?.toString() ?? 'N/A',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color:
                              widget.piece.criticalStock != null &&
                                  widget.piece.stock <=
                                      widget.piece.criticalStock!
                              ? Colors.orange[800]
                              : Colors.green[800],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _currentQuantity != widget.piece.stock
                    ? _updateQuantity
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: _isLoading
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text('Mettre à jour la quantité'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompatibleModels() {
    if (widget.piece.modeleCompatibles == null ||
        widget.piece.modeleCompatibles!.isEmpty) {
      return SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Modèles compatibles',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: widget.piece.modeleCompatibles!.map((model) {
                return Chip(
                  label: Text(
                    model.displayName,
                    style: TextStyle(fontSize: 12),
                  ),
                  backgroundColor: Theme.of(
                    context,
                  ).primaryColor.withOpacity(0.1),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdditionalInfo() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informations complémentaires',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            _buildInfoRow(
              'Prix de vente',
              '${widget.piece.sellingPrice?.toStringAsFixed(2) ?? 'N/A'} FCFA',
            ),
            _buildInfoRow(
              'Emplacement',
              widget.piece.location ?? 'Non spécifiée',
            ),
            if (widget.piece.purchaseDate != null)
              _buildInfoRow(
                'Date d\'achat',
                DateFormat('dd/MM/yyyy').format(widget.piece.purchaseDate!),
              ),
            if (widget.piece.notes != null && widget.piece.notes!.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 8),
                  Text('Notes:', style: TextStyle(fontWeight: FontWeight.w500)),
                  SizedBox(height: 4),
                  Text(widget.piece.notes!),
                ],
              ),
            _buildCompatibleModels(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text('$label: ', style: TextStyle(fontWeight: FontWeight.w500)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Color _getConditionColor(String condition) {
    switch (condition) {
      case 'NEW':
        return Colors.green;
      case 'USED_GOOD':
        return Colors.blue;
      case 'USED_WORN':
        return Colors.orange;
      case 'USED_DAMAGED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatCondition(String condition) {
    switch (condition) {
      case 'NEW':
        return 'NEUF';
      case 'USED_GOOD':
        return 'OCCASION - EE';
      case 'USED_WORN':
        return 'OCCASION - UN';
      case 'USED_DAMAGED':
        return 'OCCASION - AR';
      default:
        return condition;
    }
  }
}

class PieceEditForm extends StatefulWidget {
  final Piece piece;
  final VoidCallback? onPieceUpdated;

  const PieceEditForm({super.key, required this.piece, this.onPieceUpdated});

  @override
  State<PieceEditForm> createState() => _PieceEditFormState();
}

class _PieceEditFormState extends State<PieceEditForm> {
  @override
  Widget build(BuildContext context) {
    return CreatePieceForm(
      pContext: context,
      idCateg: widget.piece.category.id,
      onPieceCreated: widget.onPieceUpdated,
      initialData: widget.piece,
      isEditMode: true,
    );
  }
}
