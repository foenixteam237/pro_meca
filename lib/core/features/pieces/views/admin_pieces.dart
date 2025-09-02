import 'package:flutter/material.dart';
import 'package:pro_meca/core/constants/app_styles.dart';
import 'package:pro_meca/core/features/pieces/views/categoriePageScreen.dart';
import 'package:pro_meca/core/widgets/statutCardWithImage.dart';
import 'package:provider/provider.dart';

import '../../../constants/app_adaptive_colors.dart';

class PartsInventoryScreen extends StatefulWidget {
  const PartsInventoryScreen({super.key});

  @override
  State<PartsInventoryScreen> createState() => _PartsInventoryScreenState();
}

class _PartsInventoryScreenState extends State<PartsInventoryScreen> {
  TextEditingController searchController = TextEditingController();
  String searchQuery = '';

  // Données factices pour les statistiques
  int entries = 42;
  int exits = 28;
  int piecesLessThan5 = 7;
  int piecesLessThan10 = 12;

  // Données factices pour la liste des pièces
  List<Map<String, dynamic>> parts = [
    {
      'name': 'Piston hydraulique',
      'category': 'Moteur',
      'date': 'Ajouté le 12/05/2023',
      'compatibility': 'Tous modèles XJ',
      'quantity': 3,
      'status': 'critical'
    },
    {
      'name': 'Joint d\'étanchéité',
      'category': 'Transmission',
      'date': 'Ajouté le 08/05/2023',
      'compatibility': 'Série ZT 2020+',
      'quantity': 15,
      'status': 'normal'
    },
    {
      'name': 'Filtre à air',
      'category': 'Filtration',
      'date': 'Ajouté le 15/05/2023',
      'compatibility': 'Tous modèles',
      'quantity': 2,
      'status': 'critical'
    },
    {
      'name': 'Bougie d\'allumage',
      'category': 'Moteur',
      'date': 'Ajouté le 22/05/2023',
      'compatibility': 'Essence uniquement',
      'quantity': 45,
      'status': 'normal'
    },
    {
      'name': 'Disque de frein',
      'category': 'Freinage',
      'date': 'Ajouté le 18/05/2023',
      'compatibility': 'Modèles 2015-2022',
      'quantity': 8,
      'status': 'normal'
    },
  ];

  @override
  Widget build(BuildContext context) {
    final appColor = Provider.of<AppAdaptiveColors>(context);
    final filteredParts = parts.where((part) {
      return part['name'].toString().toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding:  EdgeInsets.only(top: 20),
            child: Column(
              children: [
                // Barre de recherche
                _buildSearchBar( appColor),

                // Section Gestions de pièces avec bouton +
                _buildSectionHeader(appColor),

                buildStatusCardWithImage(context, (){
                  Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        CategoriesPage(parentContext: context),
                  ),
                );}, "Liste des pièces par catégorie", 10,),
                // Cards statistiques
                _buildStatsCards(),
          
                const SizedBox(height: 24),
          
                // Section pièces en rupture
                _buildOutOfStockSection(),
                SizedBox(height: 12,),
                ...filteredParts.map(
                  (part) {
                    return _buildPartItem(part);
                  },

                )
                // Liste des pièces
                //Expanded(child: _buildPartsList()),


                
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(AppAdaptiveColors appColor) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      height: 44,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: TextField(
              controller: searchController,
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Nom de la pièce',
                hintStyle: TextStyle(color: Colors.grey[500]),
                border: InputBorder.none,
              ),
            ),
          ),
          SizedBox(width: 12,),
          Icon(
            Icons.search,
            color: appColor.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(AppAdaptiveColors appColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          Text(
            'Gestions de pièces',
            style: AppStyles.titleLarge(context),
          ),
          const Spacer(),
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: appColor.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.more_vert,
              color: Colors.white,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatsCard(
              title: 'Inventaires',
              entries: entries,
              exits: exits,
              total: entries + exits,
              icon: Icons.inventory_2_outlined,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatsCard(
              title: 'Seuils critiques',
              piecesLessThan5: piecesLessThan5,
              piecesLessThan10: piecesLessThan10,
              total: piecesLessThan5 + piecesLessThan10,
              icon: Icons.warning_outlined,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard({
    required String title,
    int? entries,
    int? exits,
    int? piecesLessThan5,
    int? piecesLessThan10,
    required int total,
    required IconData icon,
  }) {
    final appColor = Provider.of<AppAdaptiveColors>(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                icon,
                size: 24,
                color: appColor.primary,
              ),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (entries != null && exits != null) ...[
            _buildStatRow('Entrées', entries),
            const SizedBox(height: 8),
            _buildStatRow('Sorties', exits),
          ],
          if (piecesLessThan5 != null && piecesLessThan10 != null) ...[
            _buildStatRow('Pièces <5', piecesLessThan5),
            const SizedBox(height: 8),
            _buildStatRow('Pièces <10', piecesLessThan10),
          ],
          const SizedBox(height: 12),
          Text(
            total.toString(),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, int value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        Text(
          value.toString(),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildOutOfStockSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Pièces en rupture',
            style: AppStyles.titleLarge(context),
          ),
          Text(
            'voir plus',
            style: AppStyles.bodyMedium(context),
          ),
        ],
      ),
    );
  }

  Widget _buildPartsList() {
    // Filtrer les pièces selon la recherche
    final filteredParts = parts.where((part) {
      return part['name'].toString().toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        itemCount: filteredParts.length,
        itemBuilder: (context, index) {
          final part = filteredParts[index];
          return _buildPartItem(part);
        },
      ),
    );
  }

  Widget _buildPartItem(Map<String, dynamic> part) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.settings,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  part['name'],
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  part['category'],
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
                if (part['compatibility'] != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'compatibilité: ${part['compatibility']}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: part['status'] == 'critical'
                      ? Colors.red[100]
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Quantité: ${part['quantity']}',
                  style: TextStyle(
                    fontSize: 12,
                    color: part['status'] == 'critical'
                        ? Colors.red[700]
                        : Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}