// widgets/parts_list.dart
import 'package:flutter/material.dart';
import 'package:pro_meca/core/models/categories.dart';

class Part {
  final String name;
  final String reference;
  final String category;
  final int quantity;
  final int criticalStock;
  final double sellingPrice;
  final String? imageUrl;
  final String compatibility;

  Part({
    required this.name,
    required this.reference,
    required this.category,
    required this.quantity,
    required this.criticalStock,
    required this.sellingPrice,
    this.imageUrl,
    required this.compatibility,
  });
}

class PartsList extends StatelessWidget {
  final String searchQuery;
  final PieceCategorie? selectedCategory;

  const PartsList({
    super.key,
    required this.searchQuery,
    this.selectedCategory,
  });

  @override
  Widget build(BuildContext context) {
    // Filtrage des pièces basé sur la recherche et la catégorie
    final filteredParts = _getFilteredParts();

    return Expanded(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Liste des pièces (${filteredParts.length})'),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => _navigateToAddPart(context),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredParts.length,
              itemBuilder: (context, index) =>
                  _buildPartCard(filteredParts[index], context),
            ),
          ),
        ],
      ),
    );
  }

  List<Part> _getFilteredParts() {
    // Logique de filtrage réelle à implémenter
    return [
      Part(
        name: 'Piston hydraulique',
        reference: 'REF123',
        category: 'Moteur',
        quantity: 3,
        criticalStock: 5,
        sellingPrice: 105900,
        compatibility: 'Tous modèles XJ',
      ),
      Part(
        name: 'Joint d\'étanchéité',
        reference: 'REF456',
        category: 'Transmission',
        quantity: 15,
        criticalStock: 10,
        sellingPrice: 20000,
        compatibility: 'Série ZT 2020+',
      ),
    ].where((part) {
      final matchesSearch =
          part.name.contains(searchQuery) ||
          part.reference.contains(searchQuery);
      final matchesCategory =
          selectedCategory == null || part.category == selectedCategory!.name;
      return matchesSearch && matchesCategory;
    }).toList();
  }

  Widget _buildPartCard(Part part, BuildContext context) {
    final isCritical = part.quantity <= part.criticalStock;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: part.imageUrl != null
            ? Image.network(part.imageUrl!)
            : const Icon(Icons.inventory_2),
        title: Text(part.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(part.compatibility),
            Text(
              '${part.quantity} en stock',
              style: TextStyle(color: isCritical ? Colors.red : Colors.black),
            ),
            Text('${part.sellingPrice} €'),
          ],
        ),
        onTap: () => _navigateToPartDetail(context, part),
      ),
    );
  }

  void _navigateToAddPart(BuildContext context) {
    // Navigation vers l'écran d'ajout
  }

  void _navigateToPartDetail(BuildContext context, Part part) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PartDetailScreen(part: part)),
    );
  }
}

class PartDetailScreen extends StatelessWidget {
  final Part part;

  const PartDetailScreen({super.key, required this.part});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(part.name),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Fiche technique'),
              Tab(text: 'Historique'),
            ],
          ),
        ),
        body: TabBarView(
          children: [_buildTechnicalSheet(), _buildUsageHistory()],
        ),
      ),
    );
  }

  Widget _buildTechnicalSheet() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Détails techniques
      ],
    );
  }

  Widget _buildUsageHistory() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Historique d'utilisation
      ],
    );
  }
}
